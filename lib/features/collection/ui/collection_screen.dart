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
import '../../../core/ui/section_header.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/tab_page_scaffold.dart';
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
        child: AspectRatio(aspectRatio: 452 / 128, child: Skeleton(radius: 4)),
      );
    }
    final identity = snapshot.loadout.identity;
    final card = identity.playerCardId == null
        ? null
        : db.card(identity.playerCardId!);
    final title = db.title(identity.titleOrNone);
    final theme = Theme.of(context);
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
              borderRadius: BorderRadius.circular(4),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => unawaited(context.push(CollectionRoutes.card)),
                child: AspectRatio(
                  aspectRatio: 452 / 128,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      NetImage(card?.wideArt, fit: BoxFit.cover),
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [Color(0xCC0F1923), Color(0x000F1923)],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 10, 60, 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              account.riotId,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (title != null && !title.isNoTitle)
                              Text(
                                title.text,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: valColorsOf(context).win,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const Positioned(
                        right: 10,
                        bottom: 10,
                        child: Icon(Icons.edit_outlined, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          child: Row(
            children: [
              Text(
                '${CollectionStrings.equippedCard}: ',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Expanded(
                child: Text(
                  card?.displayName ?? CommonStrings.unknownItem,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium,
                ),
              ),
            ],
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
        const SectionHeader(CollectionStrings.sectionLoadout),
        HubRow(
          icon: Icons.badge_outlined,
          title: CollectionStrings.rowCard,
          value: cardName,
          onTap: () => unawaited(context.push(CollectionRoutes.card)),
        ),
        HubRow(
          icon: Icons.military_tech_outlined,
          title: CollectionStrings.rowTitle,
          value: titleText,
          onTap: () => unawaited(context.push(CollectionRoutes.title)),
        ),
        HubRow(
          icon: Icons.gps_fixed,
          title: CollectionStrings.rowWeapons,
          onTap: () => unawaited(context.push(CollectionRoutes.weapons)),
        ),
        HubRow(
          icon: Icons.emoji_emotions_outlined,
          title: CollectionStrings.rowExpressions,
          onTap: () => unawaited(context.push(CollectionRoutes.expressions)),
        ),
        HubRow(
          icon: Icons.bookmarks_outlined,
          title: CollectionStrings.rowPresets,
          value: CollectionStrings.presetCount(presets.length),
          onTap: () => unawaited(context.push(CollectionRoutes.presets)),
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
        const SectionHeader(CollectionStrings.sectionIdentity),
        HubRow(
          icon: Icons.filter_frames_outlined,
          title: CollectionStrings.rowLevelBorder,
          value: border?.displayName.isNotEmpty ?? false
              ? border!.displayName
              : CollectionStrings.levelBorderAuto,
          onTap: () =>
              unawaited(showLevelBorderSheet(context, account: account)),
        ),
        SwitchListTile(
          secondary: const Icon(
            Icons.visibility_off_outlined,
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
          secondary: const Icon(
            Icons.person_off_outlined,
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
    Widget row(CollectionBrowseType type, IconData icon, String? value) =>
        HubRow(
          icon: icon,
          title: type.label,
          value: value,
          onTap: () => unawaited(context.push(CollectionRoutes.browse(type))),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SectionHeader(CollectionStrings.sectionBrowse),
        row(
          CollectionBrowseType.skin,
          Icons.auto_awesome_outlined,
          count((o) => o.ownedCollectibleSkins.length),
        ),
        row(
          CollectionBrowseType.buddy,
          Icons.key_outlined,
          count((o) => buddyOptions(o, db, snapshot?.loadout).length),
        ),
        row(
          CollectionBrowseType.spray,
          Icons.format_paint_outlined,
          count((o) => ownedSprays(o, db).length),
        ),
        row(
          CollectionBrowseType.card,
          Icons.badge_outlined,
          count((o) => ownedCards(o, db).length),
        ),
        row(
          CollectionBrowseType.title,
          Icons.military_tech_outlined,
          count((o) => ownedTitles(o, db).length),
        ),
        row(
          CollectionBrowseType.flex,
          Icons.stars_outlined,
          count((o) => ownedFlex(o, db).length),
        ),
        HubRow(
          icon: Icons.favorite_border,
          title: CollectionStrings.rowWishlist,
          value: CollectionStrings.wishlistCount(wishlist.length),
          onTap: () => unawaited(context.push(WishlistRoutes.wishlist)),
        ),
      ],
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
            style: theme.textTheme.labelMedium?.copyWith(
              letterSpacing: 1.2,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount, style: theme.textTheme.headlineMedium),
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
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(4),
          border: const Border(
            left: BorderSide(color: ValColors.red, width: 3),
          ),
        ),
        child: Padding(padding: const EdgeInsets.all(16), child: child),
      ),
    );
  }
}
