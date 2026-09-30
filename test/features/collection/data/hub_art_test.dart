import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/features/collection/data/hub_art.dart';

WeaponSkin _skin(String id, {String? tier, String? icon}) => WeaponSkin(
  uuid: id,
  displayName: id,
  weaponUuid: 'w',
  levels: const [],
  chromas: const [],
  contentTierUuid: tier,
  displayIcon: icon,
);

void main() {
  final db = ContentDb.empty();

  group('firstImage', () {
    test('skips items without an image', () {
      expect(
        firstImage<String?>([null, '', 'a.png', 'b.png'], (x) => x),
        'a.png',
      );
    });

    test('null when nothing has an image', () {
      expect(firstImage<String?>([null, ''], (x) => x), isNull);
      expect(firstImage<String?>(const [], (x) => x), isNull);
    });
  });

  group('showcaseSkinImage', () {
    test('picks the rarest skin, not the first one', () {
      final skins = [
        _skin('a', tier: ContentTierIds.select, icon: 'select.png'),
        _skin('b', tier: ContentTierIds.ultra, icon: 'ultra.png'),
        _skin('c', tier: ContentTierIds.deluxe, icon: 'deluxe.png'),
      ];
      expect(showcaseSkinImage(skins, db), 'ultra.png');
    });

    test('ties go to the newest (last in content order)', () {
      final skins = [
        _skin('a', tier: ContentTierIds.premium, icon: 'old.png'),
        _skin('b', tier: ContentTierIds.premium, icon: 'new.png'),
      ];
      expect(showcaseSkinImage(skins, db), 'new.png');
    });

    test('ignores skins without an image; null when none', () {
      expect(
        showcaseSkinImage([
          _skin('a', tier: ContentTierIds.ultra),
          _skin('b', tier: ContentTierIds.select, icon: 'b.png'),
        ], db),
        'b.png',
      );
      expect(showcaseSkinImage([_skin('a')], db), isNull);
      expect(showcaseSkinImage(const [], db), isNull);
    });

    test('unknown tier ranks lowest-but-valid', () {
      expect(showcaseSkinImage([_skin('a', icon: 'x.png')], db), 'x.png');
    });
  });
}
