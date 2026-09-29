import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/social/data/party_models.dart';

import '../social_test_data.dart';

void main() {
  test('parses a party defensively', () {
    final p = Party.fromJson(
      partyJson(
        members: [
          memberJson(me, owner: true, ready: true, tier: 18),
          memberJson(mate, tier: 12, level: 45, incognito: true),
        ],
        state: 'MATCHMAKING',
        queue: 'Competitive',
        entry: '2026-09-28T11:58:30.1234567Z',
        code: 'ABC123',
        requests: [
          {'ID': 'req-1', 'RequestedBySubject': stranger.toUpperCase()},
        ],
        invites: [
          {'Subject': friendOnline},
        ],
      ),
    )!;
    expect(p.id, partyId);
    expect(p.size, 2);
    expect(p.isMatchmaking, isTrue);
    expect(p.queueId, 'competitive');
    expect(p.queueEntryTime, DateTime.utc(2026, 9, 28, 11, 58, 30, 123, 456));
    expect(p.inviteCode, 'ABC123');
    expect(p.isOwner(me), isTrue);
    expect(p.owner?.puuid, me);
    expect(p.member(mate)!.accountLevel, 45);
    expect(p.member(mate)!.incognito, isTrue);
    expect(p.member(mate)!.playerCardId, cardId);
    expect(p.member(me)!.ping, 24);
    expect(p.requests.single.requestedBy, stranger);
    expect(p.invitedPuuids, {friendOnline});
    expect(p.isOpen, isFalse);
  });

  test('garbage in, nulls out', () {
    expect(Party.fromJson(null), isNull);
    expect(Party.fromJson('<html>'), isNull);
    final p = Party.fromJson({
      'ID': partyId,
      'Members': [
        null,
        3,
        {'x': 1},
      ],
      'EligibleQueues': null,
      'QueueEntryTime': '0001-01-01T00:00:00Z',
      'InviteCode': '',
    })!;
    expect(p.members, isEmpty);
    expect(p.eligibleQueues, isNull);
    expect(p.queueEntryTime, isNull);
    expect(p.inviteCode, isNull);
    expect(
      PartyInvite.fromJson({'PartyID': 'P1', 'InvitedBySubject': 'A'})!
          .invitedBy,
      'a',
    );
    expect(PartyInvite.fromJson({'x': 1}), isNull);
  });

  group('queueChoices', () {
    test('eligible queues in the preferred order, competitive first', () {
      final p = Party.fromJson(
        partyJson(eligible: ['deathmatch', 'unrated', 'competitive', 'zzz']),
      )!;
      final choices = queueChoices(p);
      expect(choices.map((c) => c.queueId), [
        'competitive',
        'unrated',
        'deathmatch',
        'zzz',
      ]);
      expect(choices.every((c) => c.eligible), isTrue);
    });

    test('competitive stays selectable with a rank-disparity reason', () {
      final p = Party.fromJson(
        partyJson(
          members: [
            memberJson(me, owner: true, tier: 24),
            memberJson(mate, tier: 8),
          ],
          eligible: ['unrated'],
          queue: 'unrated',
        ),
      )!;
      final comp = queueChoices(p)
          .firstWhere((c) => c.queueId == 'competitive');
      expect(comp.eligible, isFalse);
      expect(comp.selectable, isTrue);
      expect(comp.block, QueueBlock.rankDisparity);
    });

    test('party too large, account level, restriction', () {
      final five = Party.fromJson(
        partyJson(
          members: [
            for (var i = 0; i < 3; i++) memberJson('m$i', owner: i == 0),
          ],
          eligible: ['unrated'],
          ineligible: ['deathmatch'],
        ),
      )!;
      final dm = queueChoices(five)
          .firstWhere((c) => c.queueId == 'deathmatch');
      expect(dm.block, QueueBlock.partyTooLarge);
      expect(dm.maxPartySize, 1);
      expect(dm.selectable, isFalse);

      final lowLevel = Party.fromJson(
        partyJson(
          members: [
            memberJson(me, owner: true),
            memberJson(mate, remainingLevels: 5),
          ],
          eligible: ['unrated'],
        ),
      )!;
      expect(queueChoices(lowLevel).first.block, QueueBlock.accountLevel);

      final restricted = Party.fromJson(
        partyJson(eligible: <String>[], restricted: 600),
      )!;
      expect(queueChoices(restricted).first.block, QueueBlock.restricted);
    });

    test('without EligibleQueues every default queue is offered', () {
      final p = Party.fromJson(partyJson(eligible: null, queue: 'hurm'))!;
      final ids = queueChoices(p).map((c) => c.queueId).toList();
      expect(ids.first, 'competitive');
      expect(ids, containsAll(['unrated', 'swiftplay', 'hurm']));
      expect(ids, isNot(contains('premier')));
      expect(queueChoices(p).every((c) => c.eligible), isTrue);
    });

    test('console parties get console competitive', () {
      final p = Party.fromJson(
        partyJson(eligible: ['console_unrated'], queue: 'console_unrated'),
      )!;
      final ids = queueChoices(p).map((c) => c.queueId).toList();
      expect(ids, ['console_competitive', 'console_unrated']);
    });
  });
}
