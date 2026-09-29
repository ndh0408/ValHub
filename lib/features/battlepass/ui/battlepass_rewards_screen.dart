import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/util/format.dart';
import '../../skin_detail/skin_detail_sheet.dart';
import '../battlepass_strings.dart';
import '../data/battlepass_models.dart';
import '../providers/battlepass_providers.dart';
import 'widgets/bp_ui_bits.dart';
import 'widgets/overview_bits.dart';
import 'widgets/reward_tile.dart';

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

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(BattlePassStrings.rewardsTitle)),
        body: const EmptyView(
          message: CommonStrings.errorNoAccount,
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
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: BpOfflineNotice(receivedAt: overview.contracts.receivedAt),
            ),
          ),
        );
      }
      if (pass == null || pass.levelCount == 0) {
        slivers.add(
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              message: BattlePassStrings.noRewards,
              icon: Icons.card_giftcard,
            ),
          ),
        );
      } else {
        slivers.add(
          SliverToBoxAdapter(
            child: _RewardsBody(
              pass: pass,
              isPremium: overview.isPremiumFor(pass.contract.uuid),
              db: db,
              currentChapterKey: _currentChapterKey,
              onTap: _openReward,
            ),
          ),
        );
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
    slivers.add(const SliverToBoxAdapter(child: SizedBox(height: 32)));

    final title = widget.contractId == null || pass == null
        ? BattlePassStrings.rewardsTitle
        : pass.contract.displayName;
    return Scaffold(
      appBar: AppBar(
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
      ),
      body: RefreshIndicator(
        onRefresh: () => refreshBattlePass(ref, puuid),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: slivers,
        ),
      ),
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
        unawaited(
          Scrollable.ensureVisible(
            ctx,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutCubic,
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
    unawaited(
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        builder: (_) => RewardPreviewSheet(reward: reward),
      ),
    );
  }
}

/// Summary card + every chapter (built eagerly so the current chapter can
/// be scrolled into view; a pass has ≈ 70 rewards).
class _RewardsBody extends StatelessWidget {
  const _RewardsBody({
    required this.pass,
    required this.isPremium,
    required this.db,
    required this.currentChapterKey,
    required this.onTap,
  });

  final PassProgress pass;
  final bool? isPremium;
  final ContentDb db;
  final GlobalKey currentChapterKey;
  final void Function(ResolvedReward reward) onTap;

  @override
  Widget build(BuildContext context) {
    final chapters = buildRewardTrack(
      pass.contract,
      level: pass.level,
      isPremium: isPremium,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SummaryCard(pass: pass, isPremium: isPremium),
        for (final c in chapters)
          _ChapterSection(
            key: c.isCurrent ? currentChapterKey : null,
            chapter: c,
            level: pass.level,
            premium: [for (final t in c.premium) ResolvedReward.resolve(t, db)],
            free: [for (final t in c.free) ResolvedReward.resolve(t, db)],
            onTap: onTap,
          ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.pass, required this.isPremium});

  final PassProgress pass;
  final bool? isPremium;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final premium = isPremium;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      pass.contract.displayName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (premium != null) ...[
                    const SizedBox(width: 8),
                    BpBadge(
                      premium
                          ? BattlePassStrings.premium
                          : BattlePassStrings.free,
                      color: premium ? valColorsOf(context).warning : muted,
                      filled: premium,
                      icon: premium ? Icons.workspace_premium : null,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                BattlePassStrings.levelSummary(
                  formatNumber(pass.level),
                  formatNumber(pass.levelCount),
                  formatNumber(pass.unlockedLevels),
                ),
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: 8),
              BpProgressBar(value: pass.totalFraction, height: 4),
              if (premium == false) ...[
                const SizedBox(height: 10),
                Text(
                  BattlePassStrings.premiumHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: valColorsOf(context).warning,
                  ),
                ),
              ],
            ],
          ),
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
    required this.premium,
    required this.free,
    required this.onTap,
  });

  final RewardChapter chapter;
  final int level;
  final List<ResolvedReward> premium;
  final List<ResolvedReward> free;
  final void Function(ResolvedReward reward) onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final title = chapter.isEpilogue
        ? BattlePassStrings.epilogue
        : BattlePassStrings.chapter(chapter.number);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
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
                  style: theme.textTheme.titleMedium,
                ),
              ),
              if (chapter.isCurrent) ...[
                const SizedBox(width: 8),
                const BpBadge(
                  BattlePassStrings.currentChapter,
                  color: ValColors.red,
                ),
              ],
              const Spacer(),
              Text(
                BattlePassStrings.chapterProgress(
                  chapter.levelsReached(level),
                  chapter.levelCount,
                ),
                style: theme.textTheme.labelMedium?.copyWith(color: muted),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _RewardGrid(rewards: premium, onTap: onTap),
          if (free.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.card_giftcard,
                  size: 14,
                  color: ValColors.teal,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    BattlePassStrings.freeTrack,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: ValColors.teal,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _RewardGrid(rewards: free, onTap: onTap),
          ],
        ],
      ),
    );
  }
}

/// Rows of equal-height tiles (3 columns on a 360 dp phone).
class _RewardGrid extends StatelessWidget {
  const _RewardGrid({required this.rewards, required this.onTap});

  final List<ResolvedReward> rewards;
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

/// Larger preview of a non-skin reward (card, spray, buddy, title…).
class RewardPreviewSheet extends StatelessWidget {
  const RewardPreviewSheet({super.key, required this.reward});

  final ResolvedReward reward;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final tier = reward.tier;
    final state = switch (tier.state) {
      RewardState.unlocked => BattlePassStrings.rewardUnlocked,
      RewardState.locked => BattlePassStrings.rewardLocked,
      RewardState.needsPremium => BattlePassStrings.rewardNeedsPremium,
    };
    final image = reward.image;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (image != null) ...[
              SizedBox(height: 180, child: NetImage(image)),
              const SizedBox(height: 16),
            ],
            Text(
              reward.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              [
                reward.typeLabel,
                BattlePassStrings.levelShort(tier.level),
                if (tier.isFree) BattlePassStrings.free,
                state,
              ].join(BattlePassStrings.dot),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: muted),
            ),
          ],
        ),
      ),
    );
  }
}
