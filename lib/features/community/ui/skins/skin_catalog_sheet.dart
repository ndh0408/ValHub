import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/sub_page.dart';
import '../../../../core/util/search_text.dart';
import '../../community_routes.dart';

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
