import 'package:valvn/core/l10n/labels/view_labels.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/ui/saved_copy_notice.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/segmented_tabs.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../../skin_detail/skin_detail_sheet.dart';
import '../data/battlepass_models.dart';
import '../providers/battlepass_providers.dart';
import 'widgets/bp_ui_bits.dart';
import 'widgets/overview_bits.dart';
import 'widgets/reward_tile.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Reward filter of S21, remembered across launches
/// (`UiMemory` key `battlepass.rewardsFilter`).
enum RewardsFilter {
  all,
  unlocked,
  locked;

  String label(AppLocalizations l10n) => switch (this) {
    all => l10n.battlePassFilterAll,
    unlocked => l10n.battlePassFilterUnlocked,
    locked => l10n.battlePassFilterLocked,
  };

  bool keeps(RewardTier tier) => switch (this) {
    all => true,
    unlocked => tier.isUnlocked,
    locked => !tier.isUnlocked,
  };
}

/// `UiMemory` key of the remembered [RewardsFilter].
const kRewardsFilterMemoryKey = 'battlepass.rewardsFilter';

/// S21 "Phần thưởng Battle Pass". Route `/battlepass/rewards`
/// (`?contract=<uuid>` shows an event pass instead of the battle pass).
///
/// Chapters "Chương 1…" + "Phần mở rộng", each with its premium-track tiers
/// then its free-track rewards ("Miễn phí"). Opens scrolled to the current
/// chapter. Tapping a skin opens S15.
class BattlePassRewardsScreen extends ConsumerStatefulWidget {
  const BattlePassRewardsScreen({super.key, this.contractId});

  /// Contract to show; `null` = the current battle pass.
  final String? contractId;

  @override
  ConsumerState<BattlePassRewardsScreen> createState() =>
      _BattlePassRewardsScreenState();
}

class _BattlePassRewardsScreenState
    extends ConsumerState<BattlePassRewardsScreen> {
  final _currentChapterKey = GlobalKey();
  bool _scrolledToCurrent = false;
  bool _missReported = false;
  late RewardsFilter _filter = ref
      .read(uiMemoryProvider)
      .readEnum(
        kRewardsFilterMemoryKey,
        RewardsFilter.values,
        RewardsFilter.all,
      );

  void _setFilter(RewardsFilter next) {
    setState(() => _filter = next);
    ref.read(uiMemoryProvider).writeEnum(kRewardsFilterMemoryKey, next);
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return SubPageScaffold(
        title: context.l10n.battlePassRewardsTitle,
        body: EmptyView(
          message: context.l10n.commonErrorNoAccount,
          icon: Icons.person_off_outlined,
        ),
      );
    }
    final puuid = account.puuid;
    final value = ref.watch(battlePassOverviewProvider(puuid));
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final overview = value.value;
    final pass = overview == null ? null : _passOf(overview, db);

    final slivers = <Widget>[];
    Widget? header;
    if (overview != null) {
      if (value.hasError && !value.isLoading) {
        slivers.add(
          SliverToBoxAdapter(
            child: ErrorView(
              error: value.error!,
              puuid: puuid,
              compact: true,
              onRetry: () => _retry(puuid),
            ),
          ),
        );
      }
      if (overview.contracts.isFromCache) {
        slivers.add(
          SliverToBoxAdapter(
            child: SavedCopyNotice(
              puuid: puuid,
              receivedAt: overview.contracts.receivedAt,
            ),
          ),
        );
      }
      if (pass == null || pass.levelCount == 0) {
        slivers.add(
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              title: context.l10n.battlePassNoRewardsTitle,
              message: context.l10n.battlePassNoRewards,
              icon: Icons.card_giftcard,
            ),
          ),
        );
      } else {
        final isPremium = overview.isPremiumFor(pass.contract.uuid);
        // Pinned frosted filter: "Tất cả · Đã mở khóa · Còn khóa".
        header = SegmentedTabs<RewardsFilter>(
          expand: true,
          tabs: [
            for (final f in RewardsFilter.values)
              SegmentedTab(value: f, label: f.label(context.l10n)),
          ],
          selected: _filter,
          onChanged: _setFilter,
        );
        slivers.addAll([
          SliverToBoxAdapter(
            child: _SummaryCard(pass: pass, isPremium: isPremium),
          ),
          SliverToBoxAdapter(
            child: _RewardsBody(
              pass: pass,
              isPremium: isPremium,
              db: db,
              currentChapterKey: _currentChapterKey,
              onTap: _openReward,
              filter: _filter,
              onShowAll: () => _setFilter(RewardsFilter.all),
            ),
          ),
        ]);
        _afterData(pass, overview, db);
      }
    } else {
      slivers.add(
        SliverFillRemaining(
          hasScrollBody: false,
          child: AsyncValueView<BattlePassOverview>(
            value: value,
            puuid: puuid,
            onRetry: () => _retry(puuid),
            loading: const RewardsSkeleton(),
            data: (_) => const SizedBox.shrink(),
          ),
        ),
      );
    }
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 16)));

    return SubPageScaffold(
      title: context.l10n.battlePassRewardsTitle,
      subtitle: pass?.contract.displayName,
      onRefresh: () => refreshBattlePass(ref, puuid),
      header: header,
      headerHeight: 60,
      slivers: slivers,
    );
  }

  /// The battle pass, or the event pass named by `?contract=`.
  PassProgress? _passOf(BattlePassOverview overview, ContentDb db) {
    final id = widget.contractId?.trim().toLowerCase();
    if (id == null || id.isEmpty) return overview.battlePass;
    final known = overview.passFor(id);
    if (known != null) return known;
    final contract = db.contract(id);
    return contract == null
        ? null
        : PassProgress.compute(contract, overview.contracts.progressFor(id));
  }

  void _retry(String puuid) => retryBattlePass(ref, puuid);

  /// Post-frame side effects: scroll to the current chapter once, and
  /// report rewards missing from the content (new patch).
  void _afterData(
    PassProgress pass,
    BattlePassOverview overview,
    ContentDb db,
  ) {
    final scroll = !_scrolledToCurrent && pass.level > 0;
    if (scroll) _scrolledToCurrent = true;
    var missing = false;
    if (!_missReported && !db.isEmpty) {
      _missReported = true;
      missing = pass.contract.chapters.any(
        (c) => [for (final l in c.levels) ?l.reward, ...c.freeRewards].any(
          (r) =>
              r.type != ContractRewardType.unknown &&
              db.item(r.type.itemTypeId, r.uuid) == null,
        ),
      );
    }
    if (!scroll && !missing) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (missing) {
        unawaited(
          ref
              .read(contentMissReporterProvider)
              .report()
              .catchError((Object _) {}),
        );
      }
      final ctx = _currentChapterKey.currentContext;
      if (scroll && ctx != null) {
        // Leave room for the pinned app bar and filter strip.
        final size = MediaQuery.sizeOf(ctx);
        final chrome = MediaQuery.paddingOf(ctx).top + kToolbarHeight + 60 + 8;
        unawaited(
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
            alignment: (chrome / size.height).clamp(0.0, 0.5),
          ),
        );
      }
    });
  }

  void _openReward(ResolvedReward reward) {
    final r = reward.tier.reward;
    if (r == null) return;
    if (reward.isSkin) {
      unawaited(
        showSkinDetailSheet(
          context,
          skinOrLevelUuid: r.uuid,
          mode: reward.tier.isUnlocked
              ? SkinDetailMode.owned
              : SkinDetailMode.catalog,
        ),
      );
      return;
    }
    unawaited(showRewardPreviewSheet(context, reward));
  }
}

/// Every chapter kept by [filter] (built eagerly so the current chapter
/// can be scrolled into view; a pass has ≈ 70 rewards).
class _RewardsBody extends StatelessWidget {
  const _RewardsBody({
    required this.pass,
    required this.isPremium,
    required this.db,
    required this.currentChapterKey,
    required this.onTap,
    required this.filter,
    required this.onShowAll,
  });

  final PassProgress pass;
  final bool? isPremium;
  final ContentDb db;
  final GlobalKey currentChapterKey;
  final void Function(ResolvedReward reward) onTap;
  final RewardsFilter filter;
  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    final chapters = buildRewardTrack(
      pass.contract,
      level: pass.level,
      isPremium: isPremium,
    );
    final sections = <Widget>[];
    for (final c in chapters) {
      final premium = [
        for (final t in c.premium)
          if (filter.keeps(t)) ResolvedReward.resolve(t, db, context.l10n),
      ];
      final free = [
        for (final t in c.free)
          if (filter.keeps(t)) ResolvedReward.resolve(t, db, context.l10n),
      ];
      if (premium.isEmpty && free.isEmpty) continue;
      sections.add(
        _ChapterSection(
          key: c.isCurrent ? currentChapterKey : null,
          chapter: c,
          level: pass.level,
          nextLevel: pass.isComplete ? null : pass.level + 1,
          premium: premium,
          free: free,
          onTap: onTap,
        ),
      );
    }
    // No AnimatedSwitcher: the current chapter carries a GlobalKey, which
    // must not exist twice during a cross-fade.
    if (sections.isEmpty) {
      return EmptyView(
        message: context.l10n.battlePassNoRewardsInFilter,
        icon: Icons.filter_alt_off_outlined,
        action: TextButton(
          onPressed: onShowAll,
          child: Text(context.l10n.battlePassShowAllRewards),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: sections,
    );
  }
}

/// Level, unlocked count and the whole-pass progress bar; the Premium badge
/// on a gold-tinted card for owners.
class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.pass, required this.isPremium});

  final PassProgress pass;
  final bool? isPremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final colors = valColorsOf(context);
    final premium = isPremium;
    final gold = colors.gold;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: ValCard(
        padding: const EdgeInsets.all(16),
        gradient: premium == true
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gold.withValues(alpha: 0.16),
                  gold.withValues(alpha: 0),
                ],
              )
            : null,
        borderColor: premium == true ? gold.withValues(alpha: 0.4) : null,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    context.l10n.battlePassSummary(
                      formatNumber(pass.level),
                      formatNumber(pass.levelCount),
                      formatNumber(pass.unlockedLevels),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (premium != null) ...[
                  const SizedBox(width: 8),
                  BpBadge(
                    premium
                        ? context.l10n.battlePassPremium
                        : context.l10n.battlePassFree,
                    color: premium ? gold : muted,
                    filled: premium,
                    icon: premium ? Icons.workspace_premium : null,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 10),
            BpProgressBar(value: pass.totalFraction),
            if (premium == false) ...[
              const SizedBox(height: 12),
              Text(
                context.l10n.battlePassPremiumHint,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: legibleAccent(context, colors.warning),
                  height: 1.4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChapterSection extends StatelessWidget {
  const _ChapterSection({
    super.key,
    required this.chapter,
    required this.level,
    required this.nextLevel,
    required this.premium,
    required this.free,
    required this.onTap,
  });

  final RewardChapter chapter;
  final int level;

  /// The level whose reward comes next (marked "Tiếp theo").
  final int? nextLevel;
  final List<ResolvedReward> premium;
  final List<ResolvedReward> free;
  final void Function(ResolvedReward reward) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final colors = valColorsOf(context);
    final title = chapter.isEpilogue
        ? context.l10n.battlePassEpilogue
        : context.l10n.battlePassChapter(chapter.number);
    final reached = chapter.levelsReached(level);
    final done = reached >= chapter.levelCount;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: ValText.sectionTitle.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (chapter.isCurrent) ...[
                const SizedBox(width: 8),
                BpBadge(
                  context.l10n.battlePassCurrentChapter,
                  color: theme.colorScheme.primary,
                ),
              ],
              const Spacer(),
              Text(
                context.l10n.battlePassChapterProgress(
                  reached,
                  chapter.levelCount,
                ),
                style: theme.textTheme.labelMedium?.copyWith(
                  color: done ? legibleAccent(context, colors.win) : muted,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ValProgressBar(
            value: chapter.levelCount == 0 ? 0 : reached / chapter.levelCount,
            height: 3,
            color: done ? colors.win : theme.colorScheme.primary,
          ),
          const SizedBox(height: 12),
          _RewardGrid(rewards: premium, nextLevel: nextLevel, onTap: onTap),
          if (free.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(
                  Icons.card_giftcard,
                  size: 14,
                  color: legibleAccent(context, colors.win),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.l10n.battlePassFreeTrack,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: legibleAccent(context, colors.win),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _RewardGrid(rewards: free, nextLevel: null, onTap: onTap),
          ],
        ],
      ),
    );
  }
}

/// Rows of equal-height tiles (3 columns on a 360 dp phone).
class _RewardGrid extends StatelessWidget {
  const _RewardGrid({
    required this.rewards,
    required this.nextLevel,
    required this.onTap,
  });

  final List<ResolvedReward> rewards;
  final int? nextLevel;
  final void Function(ResolvedReward reward) onTap;

  static const _spacing = 8.0;
  static const _maxTileWidth = 150.0;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = math.max(
          3,
          ((width + _spacing) / (_maxTileWidth + _spacing)).ceil(),
        );
        final rows = <Widget>[];
        for (var i = 0; i < rewards.length; i += columns) {
          final slice = rewards.sublist(
            i,
            math.min(i + columns, rewards.length),
          );
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < columns; j++) ...[
                    if (j > 0) const SizedBox(width: _spacing),
                    Expanded(
                      child: j < slice.length
                          ? RewardTile(
                              reward: slice[j],
                              isNext:
                                  !slice[j].tier.isFree &&
                                  slice[j].tier.level == nextLevel,
                              onTap: slice[j].tier.reward == null
                                  ? null
                                  : () => onTap(slice[j]),
                            )
                          : const SizedBox.shrink(),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) const SizedBox(height: _spacing),
              rows[r],
            ],
          ],
        );
      },
    );
  }
}

/// Opens the preview of a non-skin reward (card, spray, buddy, title…) in
/// the shared sheet chrome.
Future<void> showRewardPreviewSheet(
  BuildContext context,
  ResolvedReward reward,
) => showValSheet<void>(
  context,
  title: reward.name,
  subtitle: reward.typeLabel,
  builder: (context, _) => RewardPreviewSheet(reward: reward),
);

/// Body of the reward preview: art on a state-tinted glow, then level,
/// track and state rows.
class RewardPreviewSheet extends StatelessWidget {
  const RewardPreviewSheet({super.key, required this.reward});

  final ResolvedReward reward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final tier = reward.tier;
    final (stateLabel, stateColor, stateIcon) = switch (tier.state) {
      RewardState.unlocked => (
        context.l10n.battlePassRewardUnlocked,
        colors.win,
        Icons.check_circle,
      ),
      RewardState.locked => (
        context.l10n.battlePassRewardLocked,
        muted,
        Icons.lock_outline,
      ),
      RewardState.needsPremium => (
        context.l10n.battlePassRewardNeedsPremium,
        colors.warning,
        Icons.lock,
      ),
    };
    final image = reward.image;
    final isTitle = reward.type == ContractRewardType.title;
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ValRadius.card),
            gradient: RadialGradient(
              radius: 0.9,
              colors: [
                stateColor.withValues(alpha: 0.28),
                stateColor.withValues(alpha: 0.03),
              ],
            ),
            border: Border.all(color: stateColor.withValues(alpha: 0.35)),
          ),
          child: SizedBox(
            height: 200,
            child: Center(
              child: image != null && !isTitle
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: NetImage(
                        image,
                        fit: BoxFit.contain,
                        error: Icon(
                          Icons.card_giftcard,
                          color: muted,
                          size: 48,
                        ),
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        reward.name,
                        textAlign: TextAlign.center,
                        style: ValText.display(
                          26,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        GroupedSection(
          margin: EdgeInsets.zero,
          children: [
            GroupedRow(
              icon: Icons.flag_outlined,
              title: context.l10n.battlePassRewardLevelLabel,
              value: context.l10n.battlePassLevelShort(tier.level),
            ),
            GroupedRow(
              icon: Icons.category_outlined,
              title: context.l10n.battlePassRewardTypeLabel,
              value: reward.typeLabel,
            ),
            GroupedRow(
              icon: tier.isFree
                  ? Icons.card_giftcard
                  : Icons.workspace_premium_outlined,
              title: context.l10n.battlePassRewardTrackLabel,
              value: tier.isFree
                  ? context.l10n.battlePassFree
                  : context.l10n.battlePassPremium,
            ),
            GroupedRow(
              leading: Icon(stateIcon, size: 22, color: stateColor),
              title: context.l10n.battlePassRewardStatusLabel,
              value: stateLabel,
            ),
          ],
        ),
      ],
    );
  }
}
