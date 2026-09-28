import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/wishlist/wishlist_store.dart';

import '../../helpers/test_prefs.dart';

void main() {
  test('per-account wishlist toggles and survives in keep.* keys', () async {
    final prefs = await createTestPrefs();
    final c = ProviderContainer.test(
      overrides: [prefsProvider.overrideWithValue(prefs)],
    );
    final notifier = c.read(wishlistProvider('PUUID-A').notifier);
    expect(await notifier.toggle('SKIN-1'), isTrue);
    expect(c.read(wishlistProvider('PUUID-A')), {'skin-1'});
    expect(c.read(wishlistProvider('PUUID-B')), isEmpty);
    expect(await notifier.toggle('skin-1'), isFalse);
    await notifier.add('skin-2');
    expect(WishlistRepository(prefs).read('puuid-a'), {'skin-2'});
    expect(WishlistRepository.key('PUUID-A'), startsWith('keep.'));
  });
}
