import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_repository.dart';
import '../../../core/content/models/weapon_models.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/ui/content_tier_badge.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../collection_routes.dart';
import '../collection_strings.dart';
import '../data/collection_search.dart';
import '../data/loadout_view.dart';
import '../data/skin_query.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';

/// S34 "Chọn skin" for one weapon: search, tier chips, sort (Độ hiếm · Tên
/// · Giá), owned skins with "Mặc định" first. Route
/// `/collection/weapons/:weaponId`.
class WeaponSkinsScreen extends ConsumerStatefulWidget {
  const WeaponSkinsScreen({super.key, required this.weaponId});

  final String weaponId;

  @override
  ConsumerState<WeaponSkinsScreen> createState() => _WeaponSkinsScreenState();
}

class _WeaponSkinsScreenState extends ConsumerState<WeaponSkinsScreen> {
  SkinQuery _query = const SkinQuery();

  String get _weaponId => widget.weaponId.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final weapon = ref.watch(contentProvider).value?.weapon(_weaponId);
    return Scaffold(
      appBar: AppBar(
        title: Text(weapon?.displayName ?? CollectionStrings.weaponSkinsTitle),
      ),
      body: CollectionAccountGate(
        builder: (context, account) => Column(
          children: [
            CollectionSearchField(
              hint: CollectionStrings.searchSkins,
              onChanged: (v) =>
                  setState(() => _query = _query.copyWith(search: v)),
            ),
            SkinFilterBar(
              query: _query,
              sorts: const [SkinSort.rarity, SkinSort.name, SkinSort.price],
              onChanged: (q) => setState(() => _query = q),
            ),
            Expanded(
              child: LoadoutDataBuilder(
                puuid: account.puuid,
                loading: const SkeletonList(itemHeight: 64),
                builder: (context, snapshot, owned, db) {
                  final w = db.weapon(_weaponId);
                  if (w == null) {
                    return const EmptyView(
                      message: CollectionStrings.weaponNotFound,
                      icon: Icons.help_outline,
                    );
                  }
                  final gun = snapshot.loadout.gun(_weaponId);
                  final all = owned.ownedSkinsForWeapon(_weaponId);
                  final standard = [
                    for (final s in all)
                      if (s.isStandard &&
                          _query.tiers.isEmpty &&
                          matchesSearch(_query.search, [
                            s.displayName,
                            CollectionStrings.defaultSkin,
                          ]))
                        s,
                  ];
                  final skins = [
                    ...standard,
                    ...querySkins(
                      all.where((s) => !s.isStandard),
                      _query,
                      db: db,
                      prices: ref.watch(priceServiceProvider),
                    ),
                  ];
                  return RefreshIndicator(
                    onRefresh: () => refreshCollection(ref, account.puuid),
                    child: skins.isEmpty
                        ? ListView(
                            children: [
                              EmptyView(
                                message: _query.isFiltering
                                    ? CollectionStrings.noResults
                                    : CollectionStrings.noSkinsForWeapon,
                                icon: Icons.search_off,
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: skins.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, i) {
                              final skin = skins[i];
                              return SkinRow(
                                skin: skin,
                                owned: owned,
                                equipped: gun?.skinId == skin.uuid,
                                onTap: () => unawaited(
                                  context.push(
                                    CollectionRoutes.weaponSkin(
                                      _weaponId,
                                      skin.uuid,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One owned skin: image, name, tier, owned levels / variants, "Đang dùng".
class SkinRow extends ConsumerWidget {
  const SkinRow({
    super.key,
    required this.skin,
    required this.owned,
    required this.equipped,
    required this.onTap,
  });

  final WeaponSkin skin;
  final OwnedItems owned;
  final bool equipped;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final tint = contentTierTint(
      ref,
      skin.contentTierUuid,
      fallback: theme.colorScheme.surfaceContainerHigh,
    );
    final levels = owned.ownedLevels(skin).length;
    final chromas = owned.ownedChromas(skin).length;
    final details = [
      if (skin.levels.length > 1)
        CollectionStrings.levelCount(levels, skin.levels.length),
      if (skin.chromas.length > 1)
        CollectionStrings.chromaCount(chromas, skin.chromas.length),
    ];
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: equipped ? tint.withValues(alpha: 1) : tint,
                width: 3,
              ),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          child: Row(
            children: [
              SizedBox(
                width: 96,
                height: 44,
                child: NetImage(skin.image, fit: BoxFit.contain),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skinLabel(skin),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (equipped) const EquippedBadge(),
                        if (skin.contentTierUuid != null)
                          ContentTierBadge(
                            contentTierUuid: skin.contentTierUuid,
                            size: 14,
                            showName: true,
                            style: theme.textTheme.labelSmall,
                          ),
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
                ),
              ),
              Icon(Icons.chevron_right, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}
