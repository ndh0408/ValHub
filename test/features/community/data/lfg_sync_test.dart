import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/data/lfg_sync.dart';
import 'package:valvn/features/social/data/party_models.dart';

import '../community_test_env.dart';

PartyMember _member(String id) => PartyMember.fromJson({'Subject': id})!;

LfgPartySnapshot _party(
  List<String> ids, {
  bool matchmaking = false,
  bool inMatch = false,
}) => LfgPartySnapshot(
  members: [for (final id in ids) _member(id)],
  matchmaking: matchmaking,
  inMatch: inMatch,
);

LfgPost _post({
  int partySize = 2,
  int slots = 3,
  LfgStatus status = LfgStatus.open,
}) => LfgPost.fromJson({
  ...lfgJson('l1', slots: slots),
  'partySize': partySize,
  'status': status.query,
})!;

const a = 'aaaaaaaa-0000-0000-0000-00000000000a';
const b = 'bbbbbbbb-0000-0000-0000-00000000000b';
const c = 'cccccccc-0000-0000-0000-00000000000c';

void main() {
  group('LfgPost v2 parsing', () {
    test('rank range, roles, mic, language, status, joins', () {
      final p = LfgPost.fromJson({
        ...lfgJson('x'),
        'rankMin': 15,
        'rankMax': 9,
        'roles': ['Controller', 'duelist', 'healer', 'duelist'],
        'mic': 1,
        'language': 'EN',
        'partySize': 9,
        'agents': ['AAAA', null, 3],
        'status': 'in_game',
        'joins': '4',
      })!;
      expect((p.rankMin, p.rankMax), (9, 15));
      expect(p.roles, ['controller', 'duelist']);
      expect(p.mic, isTrue);
      expect(p.language, 'en');
      expect(p.partySize, 5);
      expect(p.agents, ['aaaa']);
      expect(p.status, LfgStatus.inGame);
      expect(p.joins, 4);
    });

    test('rank 0 means any; unknown language falls back to vi', () {
      final p = LfgPost.fromJson({
        ...lfgJson('y', slots: 2),
        'rankMin': 0,
        'language': 'fr',
      })!;
      expect(p.hasRankRange, isFalse);
      expect(p.language, 'vi');
      expect(p.currentPartySize, 3);
      expect(p.status, LfgStatus.open);
    });

    test('acceptsRank', () {
      final p = LfgPost.fromJson({
        ...lfgJson('z'),
        'rankMin': 12,
        'rankMax': 15,
      })!;
      expect(p.acceptsRank(12), isTrue);
      expect(p.acceptsRank(15), isTrue);
      expect(p.acceptsRank(18), isFalse);
      expect(p.acceptsRank(null), isTrue, reason: 'unknown rank fits');
      expect(p.acceptsRank(0), isTrue, reason: 'unranked fits');
    });
  });

  group('decideLfgSync', () {
    test('game not running: nothing', () {
      final d = decideLfgSync(
        post: _post(),
        party: null,
        selfPuuid: a,
        now: now,
      );
      expect(d.shouldPatch, isFalse);
    });

    test('unchanged party: heartbeat only when due', () {
      final fresh = decideLfgSync(
        post: _post(),
        party: _party([a, b]),
        selfPuuid: a,
        now: now,
        knownMembers: {a, b},
        lastPatchAt: now.subtract(const Duration(minutes: 3)),
      );
      expect(fresh.shouldPatch, isFalse);
      final due = decideLfgSync(
        post: _post(),
        party: _party([a, b]),
        selfPuuid: a,
        now: now,
        knownMembers: {a, b},
        lastPatchAt: now.subtract(const Duration(minutes: 11)),
      );
      expect(due.heartbeat, isTrue);
      expect(due.partySize, isNull);
    });

    test('a new member: size / slots PATCH and a join notification', () {
      final d = decideLfgSync(
        post: _post(),
        party: _party([a, b, c]),
        selfPuuid: a,
        now: now,
        knownMembers: {a, b},
        lastPatchAt: now,
      );
      expect(d.partySize, 3);
      expect(d.slots, 2);
      expect(d.status, isNull);
      expect(d.newMembers, [c]);
    });

    test('first read never notifies', () {
      final d = decideLfgSync(
        post: _post(),
        party: _party([a, b, c]),
        selfPuuid: a,
        now: now,
      );
      expect(d.newMembers, isEmpty);
    });

    test('5 members → full; matchmaking or in match → in_game', () {
      final full = decideLfgSync(
        post: _post(partySize: 4, slots: 1),
        party: _party([a, b, c, 'd', 'e']),
        selfPuuid: a,
        now: now,
        lastPatchAt: now,
      );
      expect(full.status, LfgStatus.full);
      expect(full.partySize, 5);
      final queue = decideLfgSync(
        post: _post(),
        party: _party([a, b], matchmaking: true),
        selfPuuid: a,
        now: now,
        lastPatchAt: now,
      );
      expect(queue.status, LfgStatus.inGame);
      expect(queue.heartbeat, isFalse);
      final back = decideLfgSync(
        post: _post(status: LfgStatus.inGame),
        party: _party([a, b]),
        selfPuuid: a,
        now: now,
        lastPatchAt: now,
      );
      expect(back.status, LfgStatus.open);
    });
  });

  group('validateLfgForm', () {
    test('rank range, slots vs party size, code', () {
      expect(
        validateLfgForm(
          rankMin: 15,
          rankMax: 9,
          partySize: 1,
          slots: 1,
          code: '',
        ),
        LfgProblem.rankRange,
      );
      expect(
        validateLfgForm(
          rankMin: null,
          rankMax: null,
          partySize: 3,
          slots: 3,
          code: '',
        ),
        LfgProblem.tooManyPlayers,
      );
      expect(
        validateLfgForm(
          rankMin: 9,
          rankMax: 15,
          partySize: 2,
          slots: 3,
          code: 'abc',
        ),
        LfgProblem.codeInvalid,
      );
      expect(
        validateLfgForm(
          rankMin: 9,
          rankMax: 15,
          partySize: 2,
          slots: 3,
          code: '',
        ),
        isNull,
        reason: 'an empty code is generated on submit',
      );
    });

    test('suggested range is ± 3 divisions, clamped', () {
      expect(suggestedRankRange(18), (min: 15, max: 21));
      expect(suggestedRankRange(26), (min: 23, max: 27));
      expect(suggestedRankRange(4), (min: 3, max: 7));
      expect(suggestedRankRange(0), isNull);
      expect(suggestedRankRange(null), isNull);
    });
  });
}
