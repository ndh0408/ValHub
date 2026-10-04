import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/sub_page.dart';
import '../../../../core/util/search_text.dart';
import '../../community_routes.dart';
import '../../providers/community_providers.dart';
import '../../providers/skin_vote_providers.dart';
import '../../data/community_models.dart';
import 'star_rating.dart';

/// One bounded read per visible catalog page. Missing statistics stay unknown;
/// the real content catalog is still available during a Community outage.
final catalogStatsProvider = FutureProvider.autoDispose
    .family<Map<String, SkinStats>, ({String puuid, String ids})>((ref, key) {
      return ref
          .watch(communityApiProvider)
          .skinVotes(key.ids.split(','), puuid: key.puuid);
    });

class SkinCatalogSliver extends ConsumerStatefulWidget {
  const SkinCatalogSliver({super.key, required this.puuid});
  final String puuid;
  @override
  ConsumerState<SkinCatalogSliver> createState() => _SkinCatalogSliverState();
}

class _SkinCatalogSliverState extends ConsumerState<SkinCatalogSliver> {
  String _query = '';
  ContentDb? _indexed;
  List<({WeaponSkin skin, String weapon, String search})> _items = [];

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(contentProvider).value;
    final weapon = ref.watch(topSkinsFilterProvider.select((f) => f.weapon));
    if (!identical(db, _indexed)) {
      _indexed = db;
      _items = [
        if (db != null)
          for (final w in db.weapons)
            for (final s in w.skins)
              if (s.isCollectible)
                (
                  skin: s,
                  weapon: w.displayName,
                  search: foldForSearch('${s.displayName} ${w.displayName}'),
                ),
      ]..sort((a, b) => compareNames(a.skin.displayName, b.skin.displayName));
    }
    final terms = foldForSearch(_query.trim()).split(RegExp(r'\s+'));
    final matches = [
      for (final item in _items)
        if ((weapon == null || item.skin.weaponUuid == weapon) &&
            terms.every(item.search.contains))
          item,
    ];
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.communityRankingCatalogTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                TextField(
                  key: const ValueKey('skins-inline-search'),
                  decoration: InputDecoration(
                    labelText: context.l10n.collectionSearchSkins,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onChanged: (value) => setState(() {
                    _query = value;
                  }),
                ),
                if (matches.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      db == null
                          ? context.l10n.communityRankingCatalogUnavailable
                          : context.l10n.communityRankingNoSearch,
                    ),
                  ),
              ],
            ),
          ),
        ),
        SliverList.builder(
          itemCount: matches.length,
          itemBuilder: (context, index) {
            final item = matches[index];
            // Only the page containing a laid-out row requests statistics.
            final start = (index ~/ 30) * 30;
            final ids = matches
                .skip(start)
                .take(30)
                .map((i) => i.skin.uuid)
                .join(',');
            return Consumer(
              builder: (context, ref, _) {
                final rating = ref
                    .watch(
                      catalogStatsProvider((puuid: widget.puuid, ids: ids)),
                    )
                    .value?[item.skin.uuid]
                    ?.rating;
                return ListTile(
                  key: ValueKey('inline-catalog-${item.skin.uuid}'),
                  leading: SizedBox(
                    width: 64,
                    height: 48,
                    child: NetImage(item.skin.image, fit: BoxFit.contain),
                  ),
                  title: Text(item.skin.displayName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.weapon),
                      if (rating != null && rating.count > 0)
                        RatingBadge(rating: rating),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => openSkinReview(context, item.skin.uuid),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

/// Search actual content, independently of the presence of leaderboard votes.
/// Selection opens the existing review page; it never casts a vote or joins.
Future<void> showSkinCatalog(BuildContext context, {String? weapon}) async {
  final skin = await showValSheet<String>(
    context,
    title: context.l10n.communityRankingExplore,
    scrollable: true,
    useRootNavigator: true,
    builder: (_, controller) =>
        _SkinCatalog(weapon: weapon, controller: controller),
  );
  if (context.mounted && skin != null) await openSkinReview(context, skin);
}

class _SkinCatalog extends ConsumerStatefulWidget {
  const _SkinCatalog({required this.weapon, required this.controller});
  final String? weapon;
  final ScrollController? controller;
  @override
  ConsumerState<_SkinCatalog> createState() => _SkinCatalogState();
}

class _SkinCatalogState extends ConsumerState<_SkinCatalog> {
  String _query = '';
  late bool _allWeapons = widget.weapon == null;
  ContentDb? _indexed;
  List<({WeaponSkin skin, String weaponName, String search})> _items = [];

  void _index(ContentDb db) {
    if (identical(db, _indexed)) return;
    _indexed = db;
    _items = [
      for (final weapon in db.weapons)
        for (final skin in weapon.skins)
          if (skin.isCollectible)
            (
              skin: skin,
              weaponName: weapon.displayName,
              search: foldForSearch(
                '${skin.displayName} ${weapon.displayName}',
              ),
            ),
    ]..sort((a, b) => compareNames(a.skin.displayName, b.skin.displayName));
  }

  @override
  Widget build(BuildContext context) {
    final content = ref.watch(contentProvider);
    final db = content.value;
    if (db != null) _index(db);
    final query = foldForSearch(_query.trim());
    final items = [
      for (final item in _items)
        if ((_allWeapons || item.skin.weaponUuid == widget.weapon) &&
            query.split(RegExp(r'\s+')).every(item.search.contains))
          item,
    ];
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: TextField(
              key: const ValueKey('skins-catalog-search'),
              decoration: InputDecoration(
                labelText: context.l10n.collectionSearchSkins,
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          if (widget.weapon != null)
            CheckboxListTile(
              key: const ValueKey('skins-catalog-all-weapons'),
              title: Text(context.l10n.communityAllWeapons),
              value: _allWeapons,
              onChanged: (value) =>
                  setState(() => _allWeapons = value ?? false),
            ),
          Expanded(
            child: ListView.builder(
              controller: widget.controller,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              itemCount: items.isEmpty ? 1 : items.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      db == null || db.weapons.isEmpty
                          ? content.isLoading
                                ? context.l10n.commonLoading
                                : context
                                      .l10n
                                      .communityRankingCatalogUnavailable
                          : items.isEmpty
                          ? context.l10n.communityRankingNoSearch
                          : context.l10n.communityRankingExploreHint,
                    ),
                  );
                }
                final item = items[index - 1];
                return ListTile(
                  key: ValueKey('catalog-${item.skin.uuid}'),
                  leading: SizedBox(
                    width: 56,
                    height: 40,
                    child: NetImage(item.skin.image, fit: BoxFit.contain),
                  ),
                  title: Text(item.skin.displayName),
                  subtitle: Text(item.weaponName),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.pop(context, item.skin.uuid),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
