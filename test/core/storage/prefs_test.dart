import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';

import '../../helpers/test_prefs.dart';

void main() {
  test(
    'reload keeps serving the old cache until the new one is ready',
    () async {
      final prefs = await createTestPrefs({'a': 'old'});
      // Another isolate writes to disk.
      await SharedPreferencesAsyncPlatform.instance!.setString(
        'a',
        'new',
        const SharedPreferencesOptions(),
      );
      final reloading = prefs.reload();
      expect(prefs.getString('a'), 'old'); // never an empty window
      await reloading;
      expect(prefs.getString('a'), 'new');
    },
  );

  test('a write made during reload survives the swap', () async {
    final prefs = await createTestPrefs({'a': '1'});
    final reloading = prefs.reload();
    await prefs.setString('b', 'written');
    await reloading;
    expect(prefs.getString('b'), 'written');
    expect(prefs.getString('a'), '1');
  });

  test('removePrefix also removes keys written by another isolate', () async {
    final prefs = await createTestPrefs({'acct.x.a': 1});
    await SharedPreferencesAsyncPlatform.instance!.setString(
      'acct.x.b',
      'bg',
      const SharedPreferencesOptions(),
    );
    await prefs.removePrefix('acct.x.');
    await prefs.reload();
    expect(prefs.keys.where((k) => k.startsWith('acct.x.')), isEmpty);
  });

  group('blocked prefixes (sign-out tombstones)', () {
    test('writes under a blocked prefix are dropped, others are not', () async {
      final prefs = await createTestPrefs();
      prefs.blockWrites('acct.p1.');
      await prefs.setString('acct.p1.a', 'x');
      await prefs.setInt('acct.p1.b', 1);
      await prefs.setBool('acct.p1.c', true);
      await prefs.setDouble('acct.p1.d', 1.5);
      await prefs.setStringList('acct.p1.e', ['x']);
      await prefs.setJson('acct.p1.f', {'x': 1});
      await prefs.setDateTime('acct.p1.g', DateTime(2026));
      await prefs.setString('acct.p2.a', 'kept');
      await prefs.setString('keep.p1.wishlist', 'kept too');
      expect(prefs.keys.where((k) => k.startsWith('acct.p1.')), isEmpty);
      expect(prefs.getString('acct.p2.a'), 'kept');
      expect(prefs.getString('keep.p1.wishlist'), 'kept too');
    });

    test('nothing reached the disk either', () async {
      final prefs = await createTestPrefs();
      prefs.blockWrites('acct.p1.');
      await prefs.setString('acct.p1.a', 'x');
      expect(await prefs.keysOnDisk(), isNot(contains('acct.p1.a')));
    });

    test('removals are never blocked, allowWrites lifts the block', () async {
      final prefs = await createTestPrefs({'acct.p1.a': 'old'});
      prefs.blockWrites('acct.p1.');
      await prefs.remove('acct.p1.a');
      expect(prefs.getString('acct.p1.a'), isNull);
      await prefs.setString('acct.p1.a', 'blocked');
      expect(prefs.getString('acct.p1.a'), isNull);
      prefs.allowWrites('acct.p1.');
      await prefs.setString('acct.p1.a', 'back');
      expect(prefs.getString('acct.p1.a'), 'back');
    });

    test('getIntFromDisk reads what another isolate wrote', () async {
      final prefs = await createTestPrefs();
      await SharedPreferencesAsyncPlatform.instance!.setInt(
        'n',
        7,
        const SharedPreferencesOptions(),
      );
      expect(prefs.getInt('n'), isNull);
      expect(await prefs.getIntFromDisk('n'), 7);
    });
  });
}
