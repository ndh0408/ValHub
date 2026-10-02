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
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/ui/price_estimate.dart';
import '../../../core/util/format.dart';
import '../../wishlist/wishlist_routes.dart';
import '../collection_routes.dart';
import '../data/buddy_options.dart';
import '../data/collection_items.dart';
import '../data/hub_art.dart';
import '../data/loadout_view.dart';
import '../providers/collection_providers.dart';
import 'browse_collection_screen.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/level_border_sheet.dart';
import 'widgets/loadout_actions.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// TAB 3 "Bộ sưu tập" hub (S30). Route `/collection`.
///
/// ValBuddy-style layout: the wide equipped player card as a rounded
/// banner (name caption under it), then grouped rows with red outline
/// icons ("Trang bị", "Hiển thị với người chơi khác", "Duyệt bộ sưu tập")
/// and the collection value at store prices.
class CollectionScreen extends ConsumerWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return TabPageScaffold(
        title: context.l10n.collectionTitle,
        body: EmptyView(
          message: context.l10n.commonErrorNoAccount,
          icon: Icons.person_off_outlined,
        ),
      );
    }
    return TabPageScaffold(
      title: context.l10n.collectionTitle,
      onRefresh: () => refreshCollection(ref, account.puuid),
      slivers: [
        SliverToBoxAdapter(child: _Header(account: account)),
        SliverToBoxAdapter(child: _LoadoutSection(puuid: account.puuid)),
        SliverToBoxAdapter(child: _BrowseSection(puuid: account.puuid)),
        SliverToBoxAdapter(child: _ValueCard(puuid: account.puuid)),
        SliverToBoxAdapter(child: _IdentitySection(account: account)),
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
    final theme = Theme.of(context);
    if (snapshot == null) {
      if (loadout.hasError && !loadout.isLoading) {
        return ErrorView(
          error: loadout.error!,
          puuid: puuid,
          compact: true,
          onRetry: () => ref.invalidate(loadoutProvider(puuid)),
        );
      }
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: _bannerRatio,
              child: Skeleton(radius: ValRadius.card),
            ),
            SizedBox(height: 10),
            Skeleton(width: 140, height: 12),
          ],
        ),
      );
    }
    final identity = snapshot.loadout.identity;
    final card = identity.playerCardId == null
        ? null
        : db.card(identity.playerCardId!);
    final cardName = card?.displayName ?? context.l10n.commonUnknownItem;
    return Column(
      children: [
        if (snapshot.isFromCache) const CachedLoadoutBanner(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Semantics(
            button: true,
            label:
                '${context.l10n.collectionEquippedCard}: $cardName. '
                '${context.l10n.collectionTapToChangeCard}',
            excludeSemantics: true,
            child: _CardBanner(
              art: card?.wideArt,
              heroTag: CollectionHeroTags.equippedCard,
              onTap: () {
                Haptics.selection();
                unawaited(context.push(CollectionRoutes.card));
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
          child: ExcludeSemantics(
            child: Text(
              cardName,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        SavingBar(visible: snapshot.isPending),
      ],
    );
  }
}

const _bannerRatio = 452 / 128;

/// Rounded wide player-card art with a thin accent frame and an edit hint.
class _CardBanner extends StatelessWidget {
  const _CardBanner({
    required this.art,
    required this.onTap,
    required this.heroTag,
  });

  final String? art;
  final VoidCallback onTap;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AspectRatio(
      aspectRatio: _bannerRatio,
      child: Hero(
        tag: heroTag,
        child: Material(
          color: scheme.surfaceContainerHigh,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ValRadius.card),
            side: BorderSide(color: scheme.primary.withValues(alpha: 0.45)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                NetImage(
                  art,
                  fit: BoxFit.cover,
                  error: Icon(
                    Icons.badge_outlined,
                    size: 36,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(6),
                      child: Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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
        : db.title(identity.titleOrNone)?.text ??
              context.l10n.collectionNoTitle;
    final cardArt = identity?.playerCardId == null
        ? null
        : db.card(identity!.playerCardId!)?.smallArt;
    final weaponArt = firstImage(
      snapshot?.loadout.guns ?? const <GunLoadout>[],
      (g) => gunRender(g, db, weapon: db.weapon(g.weaponId)),
    );
    void go(String route) => unawaited(context.push(route));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CollectionSectionTitle(context.l10n.collectionSectionLoadout),
        GroupedSection(
          children: [
            HubRow(
              icon: Icons.flag_outlined,
              image: cardArt,
              title: context.l10n.collectionPlayerCardTitle,
              value: cardName,
              onTap: () => go(CollectionRoutes.card),
            ),
            HubRow(
              icon: Icons.text_fields,
              title: context.l10n.collectionPlayerTitleTitle,
              value: titleText,
              onTap: () => go(CollectionRoutes.title),
            ),
            HubRow(
              icon: Icons.gps_fixed,
              image: weaponArt,
              title: context.l10n.collectionRowWeapons,
              onTap: () => go(CollectionRoutes.weapons),
            ),
            HubRow(
              icon: Icons.auto_fix_high_outlined,
              title: context.l10n.collectionRowExpressions,
              onTap: () => go(CollectionRoutes.expressions),
            ),
            HubRow(
              icon: Icons.inventory_2_outlined,
              title: context.l10n.collectionRowPresets,
              value: context.l10n.collectionPresetCount(presets.length),
              onTap: () => go(CollectionRoutes.presets),
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
    Widget toggle({
      required IconData icon,
      required String title,
      required String hint,
      required bool value,
      required LoadoutChange Function(bool v) change,
    }) => SwitchListTile.adaptive(
      secondary: HubIcon(icon),
      title: Text(
        title,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        hint,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(14, 4, 12, 4),
      value: value,
      onChanged: enabled
          ? (v) {
              Haptics.light();
              unawaited(
                applyLoadoutChange(
                  context,
                  ref,
                  puuid: puuid,
                  change: change(v),
                ),
              );
            }
          : null,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CollectionSectionTitle(context.l10n.collectionSectionIdentity),
        GroupedSection(
          children: [
            HubRow(
              icon: Icons.filter_frames_outlined,
              title: context.l10n.collectionRowLevelBorder,
              value: border?.displayName.isNotEmpty ?? false
                  ? border!.displayName
                  : context.l10n.collectionLevelBorderAuto,
              onTap: () =>
                  unawaited(showLevelBorderSheet(context, account: account)),
            ),
            toggle(
              icon: Icons.visibility_off_outlined,
              title: context.l10n.collectionHideAccountLevel,
              hint: context.l10n.collectionHideAccountLevelHint,
              value: identity.hideAccountLevel,
              change: SetHideAccountLevel.new,
            ),
            toggle(
              icon: Icons.person_off_outlined,
              title: context.l10n.collectionIncognito,
              hint: context.l10n.collectionIncognitoHint,
              value: snapshot.loadout.incognito,
              change: SetIncognito.new,
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
    Widget row(
      CollectionBrowseType type,
      IconData icon,
      String? value, {
      String? image,
    }) => HubRow(
      icon: icon,
      image: image,
      title: type.label,
      value: value,
      onTap: () => unawaited(context.push(CollectionRoutes.browse(type))),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CollectionSectionTitle(context.l10n.collectionSectionBrowse),
        GroupedSection(
          children: [
            row(
              CollectionBrowseType.skin,
              Icons.bolt_outlined,
              count((o) => o.ownedCollectibleSkins.length),
              image: owned == null
                  ? null
                  : showcaseSkinImage(owned.ownedCollectibleSkins, db),
            ),
            row(
              CollectionBrowseType.buddy,
              Icons.workspace_premium_outlined,
              count((o) => buddyOptions(o, db, snapshot?.loadout).length),
              image: owned == null
                  ? null
                  : firstImage(
                      buddyOptions(owned, db, snapshot?.loadout),
                      (o) => o.buddy.image,
                    ),
            ),
            row(
              CollectionBrowseType.spray,
              Icons.format_paint_outlined,
              count((o) => ownedSprays(o, db).length),
              image: owned == null
                  ? null
                  : firstImage(ownedSprays(owned, db), (x) => x.image),
            ),
            row(
              CollectionBrowseType.card,
              Icons.image_outlined,
              count((o) => ownedCards(o, db).length),
              image: owned == null
                  ? null
                  : firstImage(ownedCards(owned, db), (x) => x.smallArt),
            ),
            row(
              CollectionBrowseType.title,
              Icons.text_fields,
              count((o) => ownedTitles(o, db).length),
            ),
            row(
              CollectionBrowseType.flex,
              Icons.back_hand_outlined,
              count((o) => ownedFlex(o, db).length),
              image: owned == null
                  ? null
                  : firstImage(ownedFlex(owned, db), (x) => x.displayIcon),
            ),
            HubRow(
              icon: Icons.favorite_border,
              title: context.l10n.collectionRowWishlist,
              value: context.l10n.collectionWishlistCount(wishlist.length),
              onTap: () => unawaited(context.push(WishlistRoutes.wishlist)),
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ value card

class _ValueCard extends ConsumerWidget {
  const _ValueCard({required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final owned = ref.watch(ownedItemsProvider(puuid));
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final gold = valColorsOf(context).gold;
    final Widget child;
    VoidCallback? onTap;
    if (owned.value case final o?) {
      final value = ref.watch(priceServiceProvider).ownedCollectionValue(o);
      final amount = value.isEstimate
          ? formatEstimatedVp(value.totalVp)
          : formatVp(value.totalVp);
      onTap = () => unawaited(
        context.push(CollectionRoutes.browse(CollectionBrowseType.skin)),
      );
      child = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.collectionCollectionValue.toUpperCase(),
                  style: ValText.label.copyWith(color: gold),
                ),
              ),
              Icon(Icons.chevron_right, color: muted),
            ],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(amount, style: ValText.display(34, color: gold)),
          ),
          PriceEstimate(
            value.totalVp,
            style: theme.textTheme.bodyMedium,
            color: theme.colorScheme.onSurface,
          ),
          const SizedBox(height: 2),
          Text(
            [
              context.l10n.collectionOwnedSkinsStat(
                formatNumber(o.ownedCollectibleSkins.length),
              ),
              context.l10n.collectionValueAtStorePrices,
            ].join(' · '),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.collectionExcludedRewards,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          ),
          if (value.skinCount > 0)
            Text(
              [
                context.l10n.collectionValueSkinCount(value.pricedCount),
                if (value.rewardCount > 0)
                  context.l10n.collectionValueRewardCount(value.rewardCount),
                if (value.isEstimate) context.l10n.collectionValueHasEstimates,
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
        ],
      );
    } else if (owned.hasError && !owned.isLoading) {
      return Padding(
        padding: const EdgeInsets.only(top: 16),
        child: ErrorView(
          error: owned.error!,
          puuid: puuid,
          compact: true,
          onRetry: () => ref.invalidate(entitlementsProvider(puuid)),
        ),
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
      child: Semantics(
        button: onTap != null,
        hint: onTap == null ? null : context.l10n.collectionValueSeeSkins,
        child: Material(
          color: theme.colorScheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ValRadius.card),
            side: BorderSide(color: gold.withValues(alpha: 0.55)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Ink(
              // Gold-bordered value card with a faint gold wash.
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    gold.withValues(alpha: 0.16),
                    gold.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.7],
                ),
              ),
              child: Padding(padding: const EdgeInsets.all(16), child: child),
            ),
          ),
        ),
      ),
    );
  }
}
