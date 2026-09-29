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
}
