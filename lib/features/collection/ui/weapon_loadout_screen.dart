import 'collection_labels.dart';

import 'package:valvn/core/l10n/labels/content_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../collection_routes.dart';
import '../data/collection_search.dart';
import '../data/loadout_view.dart';
import '../data/weapon_sections.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Weapon grid: tile width limit and render height.
const _weaponMaxExtent = 220.0;
const _weaponArtHeight = 80.0;

/// S33 "Trang bị vũ khí": weapons by category (buy-menu order) with the
/// equipped skin render, rarity edge and buddy; searchable by weapon,
/// category, skin or buddy name. Route `/collection/weapons`.
class WeaponLoadoutScreen extends ConsumerStatefulWidget {
  const WeaponLoadoutScreen({super.key});

  @override
  ConsumerState<WeaponLoadoutScreen> createState() =>
      _WeaponLoadoutScreenState();
}

class _WeaponLoadoutScreenState extends ConsumerState<WeaponLoadoutScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return NoAccountPage(title: context.l10n.collectionWeaponLoadoutTitle);
    }
    final puuid = account.puuid;
    final snapshot = ref.watch(loadoutProvider(puuid)).value;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    String? subtitle;
    if (snapshot != null) {
      final guns = snapshot.loadout.guns;
      final custom = guns.where((g) {
        final skin = equippedSkin(g, db);
        return skin != null && !skin.isStandard;
      }).length;
      subtitle = context.l10n.collectionWeaponLoadoutSubtitle(
        custom,
        guns.length,
      );
    }
    return SubPageScaffold(
      title: context.l10n.collectionWeaponLoadoutTitle,
      subtitle: subtitle,
      onRefresh: () => refreshCollection(ref, puuid),
      header: SearchStrip(
        search: CollectionSearchField(
          hint: context.l10n.collectionSearchWeapons,
          initialValue: _search,
          onChanged: (v) => setState(() => _search = v),
        ),
      ),
      headerHeight: searchStripHeight(context),
      slivers: loadoutSlivers(
        ref,
        puuid: puuid,
        loading: const _WeaponsSkeleton(),
        data: (snapshot, owned, db) {
          final loadout = snapshot.loadout;
          bool matches(Weapon w) {
            final gun = loadout.gun(w.uuid);
            return matchesSearch(_search, [
              w.displayName,
              context.l10n.weaponCategory(w.category),
              equippedSkin(gun, db)?.displayName,
              equippedBuddy(gun, db)?.displayName,
            ]);
          }

          final sections = [
            for (final s in weaponSections(
              db.weapons,
              onlyIds: {for (final g in loadout.guns) g.weaponId},
            ))
              if (s.weapons.where(matches).toList() case final list
                  when list.isNotEmpty)
                WeaponSection(s.category, list),
          ];
          return [
            if (snapshot.isFromCache)
              const SliverToBoxAdapter(child: CachedLoadoutBanner()),
            SliverToBoxAdapter(child: SavingBar(visible: snapshot.isPending)),
            if (sections.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _search.trim().isEmpty
                    ? EmptyView(
                        message: context.l10n.collectionWeaponNotFound,
                        icon: Icons.gps_off_outlined,
                      )
                    : EmptyView(
                        title: context.l10n.collectionNoResultsTitle,
                        message: context.l10n.collectionNoResults,
                        icon: Icons.search_off,
                      ),
              ),
            for (final section in sections) ...[
              SliverToBoxAdapter(
                child: SectionLabel(
                  context.l10n.weaponCategory(section.category).isEmpty
                      ? context.l10n.collectionOtherWeapons
                      : context.l10n.weaponCategory(section.category),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: _weaponMaxExtent,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: tileExtent(
                      context,
                      image: _weaponArtHeight,
                    ),
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => WeaponTile(
                      key: ValueKey(section.weapons[i].uuid),
                      weapon: section.weapons[i],
                      gun: loadout.gun(section.weapons[i].uuid),
                      db: db,
                    ),
                    childCount: section.weapons.length,
                  ),
                ),
              ),
            ],
          ];
        },
      ),
    );
  }
}

class _WeaponsSkeleton extends StatelessWidget {
  const _WeaponsSkeleton();

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < 2; i++) ...[
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Skeleton(width: 96, height: 12, shimmer: false),
          ),
          SkeletonTileGrid(
            maxExtent: _weaponMaxExtent,
            tileHeight: tileExtent(context, image: _weaponArtHeight),
            rows: 2,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            shimmer: false,
          ),
        ],
      ],
    ),
  );
}

/// One weapon: name, equipped skin render (Hero into its skin list) and
/// name, buddy icon, rarity glow and edge.
class WeaponTile extends ConsumerWidget {
  const WeaponTile({
    super.key,
    required this.weapon,
    required this.gun,
    required this.db,
  });

  final Weapon weapon;
  final GunLoadout? gun;
  final ContentDb db;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final skin = equippedSkin(gun, db);
    final buddy = equippedBuddy(gun, db);
    final hasTier =
        skin?.contentTierUuid != null && !(skin?.isStandard ?? true);
    final color = hasTier
        ? skinTierColor(ref, context, skin!.contentTierUuid)
        : null;
    final skinName = skin?.equippedLabel(context.l10n);
    return Semantics(
      button: true,
      label: [weapon.displayName, ?skinName, ?buddy?.displayName].join(', '),
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ValRadius.card),
          side: BorderSide(
            color:
                color?.withValues(alpha: dark ? 0.3 : 0.45) ??
                valColorsOf(context).hairline,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () {
            Haptics.selection();
            unawaited(context.push(CollectionRoutes.weapon(weapon.uuid)));
          },
          child: Ink(
            decoration: BoxDecoration(
              gradient: color == null
                  ? null
                  : RadialGradient(
                      center: const Alignment(0, 0.1),
                      radius: 0.9,
                      colors: [
                        color.withValues(alpha: dark ? 0.3 : 0.18),
                        color.withValues(alpha: 0),
                      ],
                    ),
              border: color == null
                  ? null
                  : Border(bottom: BorderSide(color: color, width: 3)),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 22,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            weapon.displayName.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ValText.label.copyWith(
                              fontSize: 11,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        if (buddy != null)
                          Tooltip(
                            message: buddy.displayName,
                            child: NetImage(
                              buddy.image,
                              width: 22,
                              height: 22,
                              showSkeleton: false,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Hero(
                        tag: CollectionHeroTags.gun(weapon.uuid),
                        child: NetImage(
                          gunRender(gun, db, weapon: weapon),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    skinName ?? context.l10n.collectionDefaultSkin,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      color: skin == null || skin.isStandard
                          ? scheme.onSurfaceVariant
                          : null,
                    ),
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
