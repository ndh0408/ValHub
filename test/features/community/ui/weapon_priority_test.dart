import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/features/community/ui/skins/top_skins_section.dart';

void main() {
  for (final meleeName in ['Melee', 'Cận Chiến', '近接武器', 'سلاح قريب']) {
    test('weapon priority survives translated names: $meleeName', () {
      final db = ContentDb.parse({
        'weapons': [
          {
            'uuid': SpecialIds.warden,
            'displayName': 'Warden',
            'category': 'EEquippableCategory::Rifle',
          },
          {
            'uuid': SpecialIds.melee,
            'displayName': meleeName,
            'category': 'EEquippableCategory::Melee',
          },
          {
            'uuid': SpecialIds.phantom,
            'displayName': 'Phantom',
            'category': 'EEquippableCategory::Rifle',
          },
          {
            'uuid': SpecialIds.vandal,
            'displayName': 'Vandal',
            'category': 'EEquippableCategory::Rifle',
          },
        ],
      });
      expect(leaderboardWeapons(db).map((w) => w.uuid), [
        SpecialIds.vandal,
        SpecialIds.phantom,
        SpecialIds.melee,
        SpecialIds.warden,
      ]);
    });
  }
}
