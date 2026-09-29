import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_repository.dart';
import '../../../core/content/models/weapon_models.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/skin_art_card.dart';
import '../collection_routes.dart';
import '../collection_strings.dart';
import '../data/collection_search.dart';
import '../data/loadout_view.dart';
import '../data/query_memory.dart';
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
            SkinFilterBar(query: _query, sorts: _sorts, onChanged: _setQuery),
            Expanded(
              child: LoadoutDataBuilder(
                puuid: account.puuid,
                loading: const SkeletonList(itemHeight: 84, spacing: 10),
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
                  return AdaptiveRefresh(
                    onRefresh: () => refreshCollection(ref, account.puuid),
                    child: skins.isEmpty
                        ? ListView(
                            children: [
                              if (_query.isFiltering)
                                EmptyView(
                                  title: CollectionStrings.noResultsTitle,
                                  message: CollectionStrings.noResults,
                                  icon: Icons.search_off,
                                  action: _query.tiers.isEmpty
                                      ? null
                                      : OutlinedButton.icon(
                                          onPressed: () => _setQuery(
                                            _query.copyWith(tiers: {}),
                                          ),
                                          icon: const Icon(
                                            Icons.filter_alt_off_outlined,
                                          ),
                                          label: const Text(
                                            CollectionStrings.clearTiers,
                                          ),
                                        ),
                                )
                              else
                                const EmptyView(
                                  message: CollectionStrings.noSkinsForWeapon,
                                  icon: Icons.inventory_2_outlined,
                                ),
                            ],
                          )
                        : ListView.separated(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                            itemCount: skins.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (context, i) {
                              final skin = skins[i];
                              return SkinRow(
                                key: ValueKey(skin.uuid),
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

/// One owned skin: render on a rarity glow, name, rarity tag, owned levels
/// / variants and "Đang dùng" (accent frame).
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
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final muted = scheme.onSurfaceVariant;
    final color = skinTierColor(ref, context, skin.contentTierUuid);
    final tierName = skinTierName(ref, skin.contentTierUuid);
    final levels = owned.ownedLevels(skin).length;
    final chromas = owned.ownedChromas(skin).length;
    final details = [
      if (skin.levels.length > 1)
        CollectionStrings.levelCount(levels, skin.levels.length),
      if (skin.chromas.length > 1)
        CollectionStrings.chromaCount(chromas, skin.chromas.length),
    ];
    final narrow = MediaQuery.sizeOf(context).width < 360;
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
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  color.withValues(alpha: dark ? 0.24 : 0.14),
                  color.withValues(alpha: 0),
                ],
                stops: const [0, 0.6],
              ),
              border: Border(left: BorderSide(color: color, width: 4)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 12, 8, 12),
              child: Row(
                children: [
                  SizedBox(
                    width: narrow ? 96 : 120,
                    height: 56,
                    child: NetImage(skin.image, fit: BoxFit.contain),
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
                          skinLabel(skin),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
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
