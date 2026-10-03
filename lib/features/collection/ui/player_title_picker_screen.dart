import 'package:valvn/core/l10n/labels/content_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/riot/riot_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../data/collection_items.dart';
import '../data/collection_search.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/identity_preview.dart';
import 'widgets/loadout_actions.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S32 "Đổi danh hiệu" (+ "Không có danh hiệu"). Route `/collection/title`.
///
/// A live preview of the lobby banner (name + title over the equipped
/// card), a pinned search and the owned titles as a grouped list; tapping a
/// title equips it at once (no penalty, easy to change back).
class PlayerTitlePickerScreen extends ConsumerStatefulWidget {
  const PlayerTitlePickerScreen({super.key});

  @override
  ConsumerState<PlayerTitlePickerScreen> createState() =>
      _PlayerTitlePickerScreenState();
}

class _PlayerTitlePickerScreenState
    extends ConsumerState<PlayerTitlePickerScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return NoAccountPage(title: context.l10n.collectionPlayerTitleTitle);
    }
    final puuid = account.puuid;
    final search = CollectionSearchField(
      hint: context.l10n.collectionSearchTitles,
      initialValue: _search,
      onChanged: (v) => setState(() => _search = v),
    );
    return SubPageScaffold(
      title: context.l10n.collectionPlayerTitleTitle,
      subtitle: context.l10n.collectionPlayerTitleSubtitle,
      onRefresh: () => refreshCollection(ref, puuid),
      slivers: loadoutSlivers(
        ref,
        puuid: puuid,
        loading: const _TitlePickerSkeleton(),
        data: (snapshot, owned, db) {
          final identity = snapshot.loadout.identity;
          final equipped = identity.titleOrNone;
          final equippedTitle = db.title(equipped);
          final card = identity.playerCardId == null
              ? null
              : db.card(identity.playerCardId!);
          final showNone = matchesSearch(_search, [
            context.l10n.collectionNoTitle,
          ]);
          final all = ownedTitles(owned, db);
          final titles = [
            for (final t in all)
              if (matchesSearch(_search, [
                t.localizedText(context.l10n),
                t.displayName,
              ]))
                t,
          ];
          final saving = snapshot.isPending;
          final filtering = _search.trim().isNotEmpty;

          Future<void> pick(String id, String label) async {
            if (id == equipped || saving) return;
            Haptics.selection();
            await applyLoadoutChange(
              context,
              ref,
              puuid: puuid,
              change: SetPlayerTitle(id),
              successMessage: context.l10n.collectionEquippedItem(label),
            );
          }

          return [
            if (snapshot.isFromCache)
              const SliverToBoxAdapter(child: CachedLoadoutBanner()),
            SliverToBoxAdapter(child: SavingBar(visible: saving)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: IdentityPreview(
                  cardArt: card?.wideArt,
                  name: account.gameName,
                  title: equippedTitle == null || equippedTitle.isNoTitle
                      ? null
                      : equippedTitle.localizedText(context.l10n),
                  badge: ArtPill(
                    label: context.l10n.collectionPreview,
                    icon: Icons.visibility_outlined,
                  ),
                ),
              ),
            ),
            pinnedSearchSliver(
              context,
              key: const ValueKey('title-search'),
              search: search,
            ),
            SliverToBoxAdapter(
              child: SummaryStrip(
                text: filtering
                    ? context.l10n.collectionSummaryFilteredItems(
                        titles.length,
                        all.length,
                      )
                    : context.l10n.collectionTitlesCount(
                        formatNumber(all.length),
                      ),
                highlighted: filtering,
              ),
            ),
            if (!showNone && titles.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(
                  title: context.l10n.collectionNoResultsTitle,
                  message: context.l10n.collectionNoResults,
                  icon: Icons.search_off,
                ),
              )
            else
              SliverToBoxAdapter(
                child: GroupedSection(
                  children: [
                    if (showNone)
                      _TitleRow(
                        key: const ValueKey(SpecialIds.noTitle),
                        label: context.l10n.collectionNoTitle,
                        muted: true,
                        selected: equipped == SpecialIds.noTitle,
                        enabled: !saving,
                        onTap: () => unawaited(
                          pick(
                            SpecialIds.noTitle,
                            context.l10n.collectionNoTitle,
                          ),
                        ),
                      ),
                    for (final t in titles)
                      _TitleRow(
                        key: ValueKey(t.uuid),
                        label: t.localizedText(context.l10n),
                        selected: t.uuid == equipped,
                        enabled: !saving,
                        onTap: () => unawaited(
                          pick(t.uuid, t.localizedText(context.l10n)),
                        ),
                      ),
                  ],
                ),
              ),
          ];
        },
      ),
    );
  }
}

/// One title: medal icon (block for "Không có danh hiệu"), the text and a
/// check on the equipped one.
class _TitleRow extends StatelessWidget {
  const _TitleRow({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.muted = false,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final gold = valColorsOf(context).gold;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected
            ? scheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        child: InkWell(
          onTap: enabled || selected ? onTap : null,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 54),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
              child: Row(
                children: [
                  IconTile(
                    icon: muted ? Icons.block : Icons.military_tech_outlined,
                    color: muted ? scheme.onSurfaceVariant : gold,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      label,
                      style: muted
                          ? theme.textTheme.bodyLarge?.copyWith(
                              fontStyle: FontStyle.italic,
                              color: scheme.onSurfaceVariant,
                            )
                          : theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: selected
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: ValMotion.fast,
                    transitionBuilder: (child, a) =>
                        ScaleTransition(scale: a, child: child),
                    child: selected
                        ? Icon(
                            Icons.check_circle,
                            key: const ValueKey('on'),
                            color: legibleAccent(context, scheme.primary),
                          )
                        : const SizedBox(key: ValueKey('off'), width: 24),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitlePickerSkeleton extends StatelessWidget {
  const _TitlePickerSkeleton();

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: AspectRatio(
            aspectRatio: kWideCardRatio,
            child: Skeleton(radius: ValRadius.card, shimmer: false),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 16),
          child: Skeleton(height: 44, radius: ValRadius.pill, shimmer: false),
        ),
        SkeletonGroupedRows(rows: 6, rowHeight: 54, shimmer: false),
      ],
    ),
  );
}
