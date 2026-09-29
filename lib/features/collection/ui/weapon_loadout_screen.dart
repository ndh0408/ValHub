import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/ui/content_tier_badge.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/section_header.dart';
import '../collection_routes.dart';
import '../collection_strings.dart';
import '../data/loadout_view.dart';
import '../data/weapon_sections.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';

/// S33 "Trang bị vũ khí": weapons by category with the equipped skin and
/// buddy. Route `/collection/weapons`.
class WeaponLoadoutScreen extends ConsumerWidget {
  const WeaponLoadoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.weaponLoadoutTitle)),
      body: CollectionAccountGate(
        builder: (context, account) => LoadoutDataBuilder(
          puuid: account.puuid,
          loading: const CollectionGridSkeleton(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
          ),
          builder: (context, snapshot, owned, db) {
            final loadout = snapshot.loadout;
            final sections = weaponSections(
              db.weapons,
              onlyIds: {for (final g in loadout.guns) g.weaponId},
            );
            return RefreshIndicator(
              onRefresh: () => refreshCollection(ref, account.puuid),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        if (snapshot.isFromCache) const CachedLoadoutBanner(),
                        SavingBar(visible: snapshot.isPending),
                      ],
                    ),
                  ),
                  if (sections.isEmpty)
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        message: CollectionStrings.weaponNotFound,
                      ),
                    ),
                  for (final section in sections) ...[
                    SliverToBoxAdapter(
                      child: SectionHeader(
                        section.category.label.isEmpty
                            ? CollectionStrings.otherWeapons
                            : section.category.label,
                        uppercase: true,
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: tileExtent(context, image: 72),
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, i) => WeaponTile(
                            weapon: section.weapons[i],
                            gun: loadout.gun(section.weapons[i].uuid),
                            db: db,
                          ),
                          childCount: section.weapons.length,
                        ),
                      ),
                    ),
                  ],
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

/// One weapon: name, equipped skin render and name, buddy icon.
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
    final skin = equippedSkin(gun, db);
    final buddy = equippedBuddy(gun, db);
    final tint = contentTierTint(
      ref,
      skin?.contentTierUuid,
      fallback: theme.colorScheme.surfaceContainerHigh,
    );
    final skinName = skin == null ? null : skinLabel(skin);
    return Semantics(
      button: true,
      label: [weapon.displayName, ?skinName, ?buddy?.displayName].join(', '),
      excludeSemantics: true,
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(4),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () =>
              unawaited(context.push(CollectionRoutes.weapon(weapon.uuid))),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tint.withValues(alpha: 0.35),
                  tint.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
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
                            style: theme.textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.1,
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
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
                      child: NetImage(
                        gunRender(gun, db, weapon: weapon),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  Text(
                    skinName ?? CollectionStrings.defaultSkin,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.2,
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
