import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/net_image.dart';
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

/// "Tất cả skin" under the ranking, the page's one skin list: every
/// collectible skin, searchable, with ★ where known. It follows the
/// ranking's weapon filter. Tap → review page; never votes or joins.
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
                // The list follows the page's weapon filter: say so, and
                // offer every weapon right here.
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      weapon == null
                          ? context.l10n.communityRankingCatalogTitle
                          : context.l10n.communityRankingCatalogWeaponTitle(
                              db?.weapon(weapon)?.displayName ??
                                  context.l10n.commonUnknownItem,
                            ),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (weapon != null)
                      TextButton(
                        key: const ValueKey('skins-catalog-all-weapons'),
                        style: TextButton.styleFrom(
                          minimumSize: const Size(48, 48),
                        ),
                        onPressed: () => ref
                            .read(topSkinsFilterProvider.notifier)
                            .setWeapon(null),
                        child: Text(context.l10n.communityAllWeapons),
                      ),
                  ],
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
