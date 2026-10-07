import 'collection_labels.dart';

import 'package:valvn/core/l10n/labels/economy_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/currency_amount.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/skin_art_card.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/price_estimate.dart';
import '../collection_routes.dart';
import '../data/collection_search.dart';
import '../data/loadout_view.dart';
import '../data/query_memory.dart';
import '../data/skin_query.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/gun_hero.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S34 "Chọn skin" for one weapon: the equipped render as the header art
/// (flies in from the weapon grid), pinned search + sort (Độ hiếm · Tên ·
/// Giá) + rarity chips, then the owned skins with "Mặc định" first. Route
/// `/collection/weapons/:weaponId`.
class WeaponSkinsScreen extends ConsumerStatefulWidget {
  const WeaponSkinsScreen({super.key, required this.weaponId});

  final String weaponId;

  @override
  ConsumerState<WeaponSkinsScreen> createState() => _WeaponSkinsScreenState();
}

class _WeaponSkinsScreenState extends ConsumerState<WeaponSkinsScreen> {
  static const _sorts = [SkinSort.rarity, SkinSort.name, SkinSort.price];

  late SkinQuery _query = readSkinQuery(
    ref.read(uiMemoryProvider),
    CollectionMemoryKeys.weaponSkins,
    allowedSorts: _sorts,
  );

  void _setQuery(SkinQuery q) {
    setState(() => _query = q);
    writeSkinQuery(
      ref.read(uiMemoryProvider),
      CollectionMemoryKeys.weaponSkins,
      q,
    );
  }

  String get _weaponId => widget.weaponId.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final weapon = db.weapon(_weaponId);
    final title =
        weapon?.displayName ?? context.l10n.collectionWeaponSkinsTitle;
    final account = ref.watch(activeAccountProvider);
    if (account == null) return NoAccountPage(title: title);
    final puuid = account.puuid;
    final gun = ref.watch(loadoutProvider(puuid)).value?.loadout.gun(_weaponId);
    final equipped = equippedSkin(gun, db);
    final tint =
        equipped != null &&
            !equipped.isStandard &&
            equipped.contentTierUuid != null
        ? skinTierColor(ref, context, equipped.contentTierUuid)
        : null;
    return SubPageScaffold(
      title: title,
      subtitle: equipped == null
          ? null
          : context.l10n.collectionEquippedLine(
              equipped.equippedLabel(context.l10n),
            ),
      hero: GunHero(
        render: gunRender(gun, db, weapon: weapon),
        tint: tint,
        heroTag: CollectionHeroTags.gun(_weaponId),
      ),
      heroHeight: 200,
      onRefresh: () => refreshCollection(ref, puuid),
      header: SearchStrip(
        search: CollectionSearchField(
          hint: context.l10n.collectionSearchSkins,
          initialValue: _query.search,
          onChanged: (v) => setState(() => _query = _query.copyWith(search: v)),
        ),
        filters: SkinFilterBar(
          query: _query,
          sorts: _sorts,
          onChanged: _setQuery,
        ),
      ),
      headerHeight: searchStripHeight(context, filters: true),
      slivers: loadoutSlivers(
        ref,
        puuid: puuid,
        loading: const _SkinRowsSkeleton(),
        data: (snapshot, owned, db) {
          final w = db.weapon(_weaponId);
          if (w == null) {
            return [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyView(
                  message: context.l10n.collectionWeaponNotFound,
                  icon: Icons.help_outline,
                ),
              ),
            ];
          }
          final gun = snapshot.loadout.gun(_weaponId);
          final prices = ref.watch(priceServiceProvider);
          final all = owned.ownedSkinsForWeapon(_weaponId);
          final standard = [
            for (final s in all)
              if (s.isStandard &&
                  _query.tiers.isEmpty &&
                  matchesSearch(_query.search, [
                    s.displayName,
                    context.l10n.collectionDefaultSkin,
                  ]))
                s,
          ];
          final skins = [
            ...standard,
            ...querySkins(
              all.where((s) => !s.isStandard),
              _query,
              db: db,
              prices: prices,
            ),
          ];
          final collectible = all.where((s) => !s.isStandard).length;
          return [
            if (snapshot.isFromCache)
              const SliverToBoxAdapter(child: CachedLoadoutBanner()),
            SliverToBoxAdapter(child: SavingBar(visible: snapshot.isPending)),
            SliverToBoxAdapter(
              child: SummaryStrip(
                text: _query.isFiltering
                    ? context.l10n.collectionSummaryFilteredItems(
                        skins.length,
                        all.length,
                      )
                    : context.l10n.collectionOwnedForWeapon(collectible),
                highlighted: _query.isFiltering,
              ),
            ),
            if (skins.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _query.isFiltering
                    ? EmptyView(
                        title: context.l10n.collectionNoResultsTitle,
                        message: context.l10n.collectionNoResults,
                        icon: Icons.search_off,
                        action: _query.tiers.isEmpty
                            ? null
                            : OutlinedButton.icon(
                                onPressed: () =>
                                    _setQuery(_query.copyWith(tiers: {})),
                                icon: const Icon(Icons.filter_alt_off_outlined),
                                label: Text(context.l10n.collectionClearTiers),
                              ),
                      )
                    : EmptyView(
                        message: context.l10n.collectionNoSkinsForWeapon,
                        icon: Icons.inventory_2_outlined,
                      ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverList.separated(
                  itemCount: skins.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final skin = skins[i];
                    return SkinRow(
                      key: ValueKey(skin.uuid),
                      skin: skin,
                      owned: owned,
                      quote: skin.isStandard
                          ? null
                          : prices.priceForSkin(skin.uuid),
                      equipped: gun?.skinId == skin.uuid,
                      onTap: () {
                        Haptics.selection();
                        unawaited(
                          context.push(
                            CollectionRoutes.weaponSkin(_weaponId, skin.uuid),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
          ];
        },
      ),
    );
  }
}

class _SkinRowsSkeleton extends StatelessWidget {
  const _SkinRowsSkeleton();

  @override
  Widget build(BuildContext context) => const SkeletonList(
    itemCount: 5,
    itemHeight: 92,
    spacing: 10,
    padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
  );
}

/// One owned skin: render on a rarity glow (Hero into "Tùy chỉnh skin"),
/// rarity tag, name, owned levels / variants, the store price with its VND
/// estimate (or the reward source) and "Đang dùng" (accent frame).
class SkinRow extends ConsumerWidget {
  const SkinRow({
    super.key,
    required this.skin,
    required this.owned,
    required this.equipped,
    required this.onTap,
    this.quote,
  });

  final WeaponSkin skin;
  final OwnedItems owned;
  final bool equipped;
  final VoidCallback onTap;

  /// Store price / reward source; `null` hides the price line (Standard).
  final PriceQuote? quote;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final muted = scheme.onSurfaceVariant;
    final color = skinTierColor(ref, context, skin.contentTierUuid);
    final tierName = skinTierName(ref, context, skin.contentTierUuid);
    final levels = owned.ownedLevels(skin).length;
    final chromas = owned.ownedChromas(skin).length;
    final details = [
      if (skin.levels.length > 1)
        context.l10n.collectionLevelCount(levels, skin.levels.length),
      if (skin.chromas.length > 1)
        context.l10n.collectionChromaCount(chromas, skin.chromas.length),
    ];
    final narrow = MediaQuery.sizeOf(context).width < 360;
    final q = quote;
    return Semantics(
      button: true,
      selected: equipped,
      child: Material(
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ValRadius.card),
          side: BorderSide(
            color: equipped
                ? scheme.primary
                : color.withValues(alpha: dark ? 0.3 : 0.45),
            width: equipped ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.centerStart,
                end: AlignmentDirectional.centerEnd,
                colors: [
                  color.withValues(alpha: dark ? 0.24 : 0.14),
                  color.withValues(alpha: 0),
                ],
                stops: const [0, 0.6],
              ),
              border: BorderDirectional(
                start: BorderSide(color: color, width: 4),
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(10, 12, 8, 12),
              child: Row(
                children: [
                  SizedBox(
                    width: narrow ? 96 : 120,
                    height: 56,
                    child: Hero(
                      tag: CollectionHeroTags.skin(skin.uuid),
                      child: NetImage(skin.image, fit: BoxFit.contain),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tierName != null) ...[
                          TierTag(label: tierName, color: color),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          skin.equippedLabel(context.l10n),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (q != null) ...[
                          const SizedBox(height: 4),
                          _PriceLine(quote: q),
                        ],
                        if (equipped || details.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              if (equipped) const EquippedBadge(),
                              for (final d in details)
                                Text(
                                  d,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: muted,
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: muted),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "[VP] 1.775 · ≈ 268.000 ₫" or the reward source ("Phần thưởng Battle
/// Pass").
class _PriceLine extends StatelessWidget {
  const _PriceLine({required this.quote});

  final PriceQuote quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final vp = quote.vp;
    if (vp == null) {
      final caption = quote.caption(context.l10n);
      if (caption == null) return const SizedBox.shrink();
      return Row(
        children: [
          Icon(
            quote.isReward ? Icons.card_giftcard : Icons.remove_circle_outline,
            size: 13,
            color: muted,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              caption,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(color: muted),
            ),
          ),
        ],
      );
    }
    return Wrap(
      spacing: 8,
      runSpacing: 2,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        // Each part scales down instead of overflowing a narrow column at
        // large text sizes.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: CurrencyAmount.vp(
            vp,
            estimate: quote.isEstimate,
            iconSize: 13,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: PriceEstimate(
            vp,
            interactive: false,
            style: theme.textTheme.labelSmall,
          ),
        ),
      ],
    );
  }
}
