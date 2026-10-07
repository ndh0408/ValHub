import '../../../helpers/l10n.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/features/profile/ui/widgets/play_session_card.dart';

import '../profile_test_env.dart';

const _ids = [
  'f1000000-0000-4000-8000-000000000001',
  'f2000000-0000-4000-8000-000000000002',
  'f3000000-0000-4000-8000-000000000003',
];

/// The competitive fixture as match [id], started at [start].
JsonMap _matchAt(String id, DateTime start) {
  final json = competitiveMatchWithId(id);
  (json['matchInfo'] as Map<String, dynamic>)['gameStartMillis'] =
      start.millisecondsSinceEpoch;
  return json;
}

/// Three ranked matches 50 minutes apart, the newest [agoMinutes] ago.
void _serveSession(ProfileTestEnv env, {int agoMinutes = 60}) {
  final now = env.clock.now();
  final starts = [
    for (var i = 0; i < _ids.length; i++)
      now.subtract(Duration(minutes: agoMinutes + 50 * i)),
  ];
  for (var i = 0; i < _ids.length; i++) {
    env.matches[_ids[i]] = _matchAt(_ids[i], starts[i]);
  }
  env.historyByQueue[null] = {
    'Subject': me,
    'Total': _ids.length,
    'History': [
      for (var i = 0; i < _ids.length; i++)
        {
          'MatchID': _ids[i],
          'GameStartTime': starts[i].millisecondsSinceEpoch,
          'QueueID': 'competitive',
        },
    ],
  };
  env.updates = {
    'Subject': me,
    'Matches': [
      for (var i = 0; i < _ids.length; i++)
        updateRow(_ids[i], start: starts[i], earned: [21, -15, 18][i]),
    ],
  };
}

void main() {
  setUpAll(registerProfileFallbacks);

  testWidgets('a fresh session: record, net RR, stats and its matches', (
    tester,
  ) async {
    final env = await ProfileTestEnv.create();
    _serveSession(env);
    await pumpProfile(
      tester,
      env,
      const Scaffold(body: PlaySessionCard(puuid: me)),
    );
    await settle(tester);

    expect(find.text(tl.profileSessionTitle.toUpperCase()), findsOneWidget);
    expect(find.text('+24 RR'), findsOneWidget);
    expect(find.text(tl.profileKd), findsOneWidget);
    // One tile per match, each naming its result for screen readers.
    expect(find.byType(Tooltip), findsNWidgets(_ids.length + 1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('hidden the day after', (tester) async {
    final env = await ProfileTestEnv.create();
    _serveSession(env, agoMinutes: 16 * 60);
    await pumpProfile(
      tester,
      env,
      const Scaffold(body: PlaySessionCard(puuid: me)),
    );
    await settle(tester);
    expect(find.text(tl.profileSessionTitle.toUpperCase()), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}
