import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../../wishlist/wishlist_routes.dart';
import '../collection_routes.dart';
import '../collection_strings.dart';
import '../data/buddy_options.dart';
import '../data/collection_items.dart';
import '../providers/collection_providers.dart';
import 'browse_collection_screen.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/level_border_sheet.dart';
import 'widgets/loadout_actions.dart';

/// TAB 3 "Bộ sưu tập" hub (S30). Route `/collection`.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return const TabPageScaffold(
        title: CollectionStrings.title,
        body: EmptyView(
          message: CommonStrings.errorNoAccount,
          icon: Icons.person_off_outlined,
        ),
      );
    }
    return TabPageScaffold(
      title: CollectionStrings.title,
      onRefresh: () => refreshCollection(ref, account.puuid),
      slivers: [
        SliverToBoxAdapter(child: _Header(account: account)),
        SliverToBoxAdapter(child: _LoadoutSection(puuid: account.puuid)),
        SliverToBoxAdapter(child: _IdentitySection(account: account)),
        SliverToBoxAdapter(child: _BrowseSection(puuid: account.puuid)),
        SliverToBoxAdapter(child: _ValueCard(puuid: account.puuid)),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }
}

// ------------------------------------------------------------------ header

class _Header extends ConsumerWidget {
  const _Header({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puuid = account.puuid;
    final loadout = ref.watch(loadoutProvider(puuid));
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final snapshot = loadout.value;
    if (snapshot == null) {
      if (loadout.hasError && !loadout.isLoading) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Card(
            child: ErrorView(
              error: loadout.error!,
              puuid: puuid,
              compact: true,
              onRetry: () => ref.invalidate(loadoutProvider(puuid)),
            ),
          ),
        );
      }
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Skeleton(height: 110, radius: 18),
      );
    }
    final identity = snapshot.loadout.identity;
    final card = identity.playerCardId == null
        ? null
        : db.card(identity.playerCardId!);
    final title = db.title(identity.titleOrNone);
    final theme = Theme.of(context);
    final titleText = title == null || title.isNoTitle ? null : title.text;
    const onBanner = Colors.white;
    final onBannerMuted = Colors.white.withValues(alpha: 0.8);
    return Column(
      children: [
        if (snapshot.isFromCache) const CachedLoadoutBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Semantics(
            button: true,
            label:
                '${CollectionStrings.equippedCard}: '
                '${card?.displayName ?? CommonStrings.unknownItem}. '
                '${CollectionStrings.tapToChangeCard}',
            excludeSemantics: true,
            child: Material(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(18),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => unawaited(context.push(CollectionRoutes.card)),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: NetImage(
                        card?.wideArt,
                        fit: BoxFit.cover,
                        showSkeleton: false,
                        error: const SizedBox.shrink(),
                      ),
                    ),
                    // Figma: purple → red equipped-card banner.
                    const Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xF24A2A7A), Color(0xB3D9404F)],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(18, 18, 48, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            CollectionStrings.equippedCard.toUpperCase(),
                            style: ValText.label.copyWith(
                              color: onBannerMuted,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            card?.displayName ?? CommonStrings.unknownItem,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: ValText.display(24, color: onBanner),
                          ),
                          if (titleText != null) ...[
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Text(
                                  CollectionStrings.bannerTitlePrefix,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: onBannerMuted,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    titleText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: onBanner,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Positioned(
                      right: 14,
                      top: 14,
                      child: Icon(
                        Icons.edit_outlined,
                        size: 20,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SavingBar(visible: snapshot.isPending),
      ],
    );
  }
}

// ------------------------------------------------------------ loadout rows

class _LoadoutSection extends ConsumerWidget {
  const _LoadoutSection({required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final snapshot = ref.watch(loadoutProvider(puuid)).value;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final presets = ref.watch(loadoutPresetsProvider(puuid));
    final identity = snapshot?.loadout.identity;
    final cardName = identity?.playerCardId == null
        ? null
        : db.card(identity!.playerCardId!)?.displayName;
    final titleText = identity == null
        ? null
        : db.title(identity.titleOrNone)?.text ?? CollectionStrings.noTitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(CollectionStrings.sectionLoadout),
        GroupedSection(
          children: [
            HubRow(
              icon: Icons.badge_outlined,
              color: TierColors.premium,
              title: CollectionStrings.rowCard,
              value: cardName,
              onTap: () => unawaited(context.push(CollectionRoutes.card)),
            ),
            HubRow(
              icon: Icons.military_tech_outlined,
              color: TierColors.ultra,
              title: CollectionStrings.rowTitle,
              value: titleText,
              onTap: () => unawaited(context.push(CollectionRoutes.title)),
            ),
            HubRow(
              icon: Icons.gps_fixed,
              color: TierColors.select,
              title: CollectionStrings.rowWeapons,
              onTap: () => unawaited(context.push(CollectionRoutes.weapons)),
            ),
            HubRow(
              icon: Icons.emoji_emotions_outlined,
              color: ValColors.green,
              title: CollectionStrings.rowExpressions,
              onTap: () =>
                  unawaited(context.push(CollectionRoutes.expressions)),
            ),
            HubRow(
              icon: Icons.bookmarks_outlined,
              color: const Color(0xFFB07CE8),
              title: CollectionStrings.rowPresets,
              value: CollectionStrings.presetCount(presets.length),
              onTap: () => unawaited(context.push(CollectionRoutes.presets)),
            ),
          ],
        ),
      ],
    );
  }
}

// ----------------------------------------------------------- identity

class _IdentitySection extends ConsumerWidget {
  const _IdentitySection({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puuid = account.puuid;
    final snapshot = ref.watch(loadoutProvider(puuid)).value;
    if (snapshot == null) return const SizedBox.shrink();
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final identity = snapshot.loadout.identity;
    final border = identity.isAutoLevelBorder
        ? null
        : db.levelBorder(identity.preferredLevelBorderId!);
    final enabled = !snapshot.isPending;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(CollectionStrings.sectionIdentity),
        GroupedSection(
          children: [
            HubRow(
              color: TierColors.exclusive,
              icon: Icons.filter_frames_outlined,
              title: CollectionStrings.rowLevelBorder,
              value: border?.displayName.isNotEmpty ?? false
                  ? border!.displayName
                  : CollectionStrings.levelBorderAuto,
              onTap: () =>
                  unawaited(showLevelBorderSheet(context, account: account)),
            ),
            SwitchListTile(
              secondary: const IconTile(
                icon: Icons.visibility_off_outlined,
                color: ValColors.red,
              ),
              title: const Text(CollectionStrings.hideAccountLevel),
              subtitle: Text(
                CollectionStrings.hideAccountLevelHint,
                style: theme.textTheme.bodySmall,
              ),
              value: identity.hideAccountLevel,
              onChanged: enabled
                  ? (v) => unawaited(
                      applyLoadoutChange(
                        context,
                        ref,
                        puuid: puuid,
                        change: SetHideAccountLevel(v),
                      ),
                    )
                  : null,
            ),
            SwitchListTile(
              secondary: const IconTile(
                icon: Icons.person_off_outlined,
                color: ValColors.red,
              ),
              title: const Text(CollectionStrings.incognito),
              subtitle: Text(
                CollectionStrings.incognitoHint,
                style: theme.textTheme.bodySmall,
              ),
              value: snapshot.loadout.incognito,
              onChanged: enabled
                  ? (v) => unawaited(
                      applyLoadoutChange(
                        context,
                        ref,
                        puuid: puuid,
                        change: SetIncognito(v),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------- browse rows

class _BrowseSection extends ConsumerWidget {
  const _BrowseSection({required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(ownedItemsProvider(puuid)).value;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final snapshot = ref.watch(loadoutProvider(puuid)).value;
    // Skins newer than the cached content: re-download it (debounced).
    ref.listen(ownedItemsProvider(puuid), (_, next) {
      if (next.value?.unknownSkinLevels.isNotEmpty ?? false) {
        unawaited(ref.read(contentMissReporterProvider).report());
      }
    });
    final wishlist = ref.watch(wishlistProvider(puuid));
    String? count(int Function(OwnedItems o) f) =>
        owned == null ? null : formatNumber(f(owned));
    Widget tile(CollectionBrowseType type, Color color, String? value) =>
        _BrowseTile(
          title: type.label,
          color: color,
          value: value == null ? null : CollectionStrings.itemsCount(value),
          onTap: () => unawaited(context.push(CollectionRoutes.browse(type))),
        );
    final tiles = [
      tile(
        CollectionBrowseType.skin,
        TierColors.premium,
        count((o) => o.ownedCollectibleSkins.length),
      ),
      tile(
        CollectionBrowseType.buddy,
        TierColors.exclusive,
        count((o) => buddyOptions(o, db, snapshot?.loadout).length),
      ),
      tile(
        CollectionBrowseType.spray,
        TierColors.select,
        count((o) => ownedSprays(o, db).length),
      ),
      tile(
        CollectionBrowseType.card,
        TierColors.deluxe,
        count((o) => ownedCards(o, db).length),
      ),
      tile(
        CollectionBrowseType.title,
        TierColors.ultra,
        count((o) => ownedTitles(o, db).length),
      ),
      tile(
        CollectionBrowseType.flex,
        const Color(0xFFB07CE8),
        count((o) => ownedFlex(o, db).length),
      ),
      _BrowseTile(
        title: CollectionStrings.rowWishlist,
        color: ValColors.red,
        value: CollectionStrings.wishlistCount(wishlist.length),
        onTap: () => unawaited(context.push(WishlistRoutes.wishlist)),
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionLabel(CollectionStrings.sectionBrowse),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i += 2) ...[
                if (i > 0) const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: tiles[i]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: i + 1 < tiles.length
                            ? tiles[i + 1]
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// "DUYỆT BỘ SƯU TẬP" tile: colored diamond, name, item count.
class _BrowseTile extends StatelessWidget {
  const _BrowseTile({
    required this.title,
    required this.color,
    required this.value,
    required this.onTap,
  });

  final String title;
  final Color color;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ValCard(
      onTap: onTap,
      radius: 14,
      padding: const EdgeInsets.fromLTRB(12, 12, 10, 12),
      child: Row(
        children: [
          DiamondPip(size: 22, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (value != null)
                  Text(
                    value!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------ value footer

class _ValueCard extends ConsumerWidget {
  const _ValueCard({required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(ownedItemsProvider(puuid));
    final theme = Theme.of(context);
    final gold = valColorsOf(context).gold;
    final Widget child;
    if (owned.value case final o?) {
      final value = ref.watch(priceServiceProvider).ownedCollectionValue(o);
      final amount = value.isEstimate
          ? formatEstimatedVp(value.totalVp)
          : formatVp(value.totalVp);
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            CollectionStrings.collectionValue.toUpperCase(),
            style: ValText.label.copyWith(color: gold),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount, style: ValText.display(34, color: gold)),
          ),
          const SizedBox(height: 4),
          Text(
            CollectionStrings.excludedRewards,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (value.skinCount > 0)
            Text(
              [
                CollectionStrings.valueSkinCount(value.pricedCount),
                if (value.rewardCount > 0)
                  CollectionStrings.valueRewardCount(value.rewardCount),
                if (value.isEstimate) CollectionStrings.valueHasEstimates,
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      );
    } else if (owned.hasError && !owned.isLoading) {
      child = ErrorView(
        error: owned.error!,
        puuid: puuid,
        compact: true,
        onRetry: () => ref.invalidate(entitlementsProvider(puuid)),
      );
    } else {
      child = const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 140, height: 12),
          SizedBox(height: 8),
          Skeleton(width: 180, height: 28),
          SizedBox(height: 8),
          Skeleton(width: 160, height: 12),
        ],
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: DecoratedBox(
        // Figma: gold-bordered value card with a faint gold wash.
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ValRadius.card),
          border: Border.all(color: gold.withValues(alpha: 0.55)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              gold.withValues(alpha: 0.16),
              theme.colorScheme.surfaceContainer,
            ],
            stops: const [0, 0.7],
          ),
        ),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
