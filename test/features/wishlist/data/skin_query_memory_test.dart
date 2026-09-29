import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/storage/ui_memory.dart';
import 'package:valvn/features/wishlist/data/skin_query.dart';
import 'package:valvn/features/wishlist/data/skin_query_memory.dart';

import '../../../helpers/test_prefs.dart';

void main() {
  test('defaults to rarity first without filters', () async {
    final memory = SkinQueryMemory(
      UiMemory(await createTestPrefs()),
      SkinQueryMemory.catalog,
    );
    expect(memory.load(), const SkinQuery());
  });

  test('round-trips sort, tiers and weapon, never the search text', () async {
    final prefs = await createTestPrefs();
    final memory = SkinQueryMemory(UiMemory(prefs), SkinQueryMemory.catalog);
    memory.save(
      const SkinQuery(
        text: 'reaver',
        sort: SkinSort.price,
        tiers: {'b', 'a'},
        weaponUuid: 'w1',
      ),
    );
    await pumpEventQueue();
    expect(prefs.getString('ui.catalog.tiers'), 'a,b');
    expect(
      memory.load(),
      const SkinQuery(
        sort: SkinSort.price,
        tiers: {'a', 'b'},
        weaponUuid: 'w1',
      ),
    );
    // Screens without a weapon filter ignore a stored weapon.
    expect(memory.load(rememberWeapon: false).weaponUuid, isNull);

    // Clearing removes the keys again.
    memory.save(const SkinQuery(sort: SkinSort.price), previous: memory.load());
    await pumpEventQueue();
    expect(prefs.getString('ui.catalog.tiers'), isNull);
    expect(prefs.getString('ui.catalog.weapon'), isNull);
    expect(memory.load(), const SkinQuery(sort: SkinSort.price));
  });

  test('screens are independent and bad values fall back', () async {
    final prefs = await createTestPrefs({'ui.wishlist.sort': 'bogus'});
    final ui = UiMemory(prefs);
    SkinQueryMemory(
      ui,
      SkinQueryMemory.catalog,
    ).save(const SkinQuery(sort: SkinSort.name));
    await pumpEventQueue();
    expect(
      SkinQueryMemory(ui, SkinQueryMemory.wishlist).load().sort,
      SkinSort.rarity,
    );
  });
}
