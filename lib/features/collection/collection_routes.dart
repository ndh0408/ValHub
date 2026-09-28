import 'package:go_router/go_router.dart';

import 'ui/browse_collection_screen.dart';
import 'ui/collection_screen.dart';
import 'ui/expressions_screen.dart';
import 'ui/loadout_presets_screen.dart';
import 'ui/player_card_picker_screen.dart';
import 'ui/player_title_picker_screen.dart';
import 'ui/skin_customize_screen.dart';
import 'ui/weapon_loadout_screen.dart';
import 'ui/weapon_skins_screen.dart';

/// Locations of the collection feature.
abstract final class CollectionRoutes {
  static const root = '/collection';
  static const card = '/collection/card';
  static const title = '/collection/title';
  static const weapons = '/collection/weapons';
  static const expressions = '/collection/expressions';
  static const presets = '/collection/presets';

  static String weapon(String weaponId) => '$weapons/$weaponId';

  static String weaponSkin(String weaponId, String skinId) =>
      '$weapons/$weaponId/skin/$skinId';

  static String browse(CollectionBrowseType type) =>
      '$root/browse/${type.path}';
}

/// Branch 2 of the tab shell. [nested] are extra relative sub-routes of
/// `/collection` owned by other features (the app router passes
/// `wishlistRoutes`).
List<RouteBase> collectionBranchRoutes({List<RouteBase> nested = const []}) => [
  GoRoute(
    path: CollectionRoutes.root,
    builder: (context, state) => const CollectionScreen(),
    routes: [
      GoRoute(
        path: 'card',
        builder: (context, state) => const PlayerCardPickerScreen(),
      ),
      GoRoute(
        path: 'title',
        builder: (context, state) => const PlayerTitlePickerScreen(),
      ),
      GoRoute(
        path: 'weapons',
        builder: (context, state) => const WeaponLoadoutScreen(),
        routes: [
          GoRoute(
            path: ':weaponId',
            builder: (context, state) => WeaponSkinsScreen(
              weaponId: state.pathParameters['weaponId'] ?? '',
            ),
            routes: [
              GoRoute(
                path: 'skin/:skinId',
                builder: (context, state) => SkinCustomizeScreen(
                  weaponId: state.pathParameters['weaponId'] ?? '',
                  skinId: state.pathParameters['skinId'] ?? '',
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: 'expressions',
        builder: (context, state) => const ExpressionsScreen(),
      ),
      GoRoute(
        path: 'presets',
        builder: (context, state) => const LoadoutPresetsScreen(),
      ),
      GoRoute(
        path: 'browse/:type',
        builder: (context, state) => BrowseCollectionScreen(
          type: CollectionBrowseType.parse(state.pathParameters['type']),
        ),
      ),
      ...nested,
    ],
  ),
];
