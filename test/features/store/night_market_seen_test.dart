import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/store/providers/night_market_seen.dart';

import '../../helpers/test_prefs.dart';

const _puuid = 'c5a5af97-d9b8-5217-9d26-1b35f93ca3d0';

void main() {
  test('normalizeOfferIds trims, lowercases and drops blanks', () {
    expect(normalizeOfferIds([' AbC ', '', '  ', 'abc', 'DEF']), {
      'abc',
      'def',
    });
  });

  test('hasUnseenOffers compares case-insensitively', () {
    expect(hasUnseenOffers(['A', 'b'], {'a', 'b'}), isFalse);
    expect(hasUnseenOffers(['A', 'c'], {'a', 'b'}), isTrue);
    expect(hasUnseenOffers(const [], const {}), isFalse);
  });

  test('store round-trips per account under acct.<puuid>.*', () async {
    final prefs = await createTestPrefs();
    final store = NightMarketSeenStore(prefs);
    await store.write(_puuid, {'b', 'a'});
    expect(store.read(_puuid), {'a', 'b'});
    expect(store.read('someone-else'), isEmpty);
    expect(NightMarketSeenStore.key(_puuid.toUpperCase()), startsWith('acct.'));
    expect(prefs.getStringList(NightMarketSeenStore.key(_puuid)), ['a', 'b']);
  });

  test('markSeen keeps only the current rotation and persists it', () async {
    final prefs = await createTestPrefs();
    final c = ProviderContainer.test(
      overrides: [prefsProvider.overrideWithValue(prefs)],
    );
    final notifier = c.read(nightMarketSeenProvider(_puuid).notifier);

    await notifier.markSeen(['OLD-1', 'old-2']);
    expect(c.read(nightMarketSeenProvider(_puuid)), {'old-1', 'old-2'});

    // A subset of what was seen changes nothing.
    await notifier.markSeen(['old-1']);
    expect(c.read(nightMarketSeenProvider(_puuid)), {'old-1', 'old-2'});

    // A new rotation replaces the stored ids (the list never grows).
    await notifier.markSeen(['new-1', 'new-2', 'new-3']);
    expect(c.read(nightMarketSeenProvider(_puuid)), {
      'new-1',
      'new-2',
      'new-3',
    });
    expect(NightMarketSeenStore(prefs).read(_puuid), {
      'new-1',
      'new-2',
      'new-3',
    });

    // Empty input is ignored.
    await notifier.markSeen(const []);
    expect(c.read(nightMarketSeenProvider(_puuid)), hasLength(3));
  });
}
