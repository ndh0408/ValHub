import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/competitive.dart';
import 'package:valvn/core/storage/prefs.dart';

import '../../../helpers/test_prefs.dart';

void main() {
  const viewer = 'v';
  late Prefs prefs;

  setUp(() async => prefs = await createTestPrefs());

  MatchDetails details() => MatchDetails.fromJson({
    'matchInfo': {'matchId': 'm1'},
    'players': [
      {'subject': 'v', 'partyId': 'party-1', 'teamId': 'Blue'},
      {'subject': 'mate', 'partyId': 'party-1', 'teamId': 'Blue'},
      {'subject': 'enemy', 'partyId': 'party-2', 'teamId': 'Red'},
    ],
  }, matchId: 'm1');

  test(
    'record/read round trip, lowercase, per account, wiped prefix',
    () async {
      final store = MatchPrivacyStore(prefs);
      await store.record(
        viewer,
        'M1',
        const MatchPrivacy(incognito: {'enemy'}, hiddenLevel: {'mate'}),
      );
      final p = store.read(viewer, 'm1');
      expect(p.incognito, {'enemy'});
      expect(p.hiddenLevel, {'mate'});
      expect(store.read('other', 'm1').isEmpty, isTrue);
      expect(
        prefs.keys.where((k) => k.startsWith(PrefKeys.accountPrefix(viewer))),
        isNotEmpty,
      );
    },
  );

  test('hiddenIn: incognito enemies only, never self or party', () {
    const privacy = MatchPrivacy(incognito: {'v', 'mate', 'enemy'});
    expect(privacy.hiddenIn(details(), viewer), {'enemy'});
    expect(MatchPrivacy.none.hiddenIn(details(), viewer), isEmpty);
  });

  test('bounded: keeps the newest matches and drops old ones', () async {
    var now = DateTime(2026, 1, 1);
    final store = MatchPrivacyStore(prefs, now: () => now);
    await store.record(viewer, 'old', const MatchPrivacy(incognito: {'x'}));
    now = now.add(MatchPrivacyStore.maxAge + const Duration(days: 1));
    for (var i = 0; i < MatchPrivacyStore.maxMatches + 5; i++) {
      await store.record(viewer, 'm$i', const MatchPrivacy(incognito: {'x'}));
      now = now.add(const Duration(minutes: 1));
    }
    expect(store.read(viewer, 'old').isEmpty, isTrue);
    expect(store.read(viewer, 'm0').isEmpty, isTrue);
    expect(
      store.read(viewer, 'm${MatchPrivacyStore.maxMatches + 4}').incognito,
      {'x'},
    );
  });
}
