import 'package:valvn/core/l10n/labels/economy_labels.dart';

import '../../../helpers/l10n.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/reward_sources.dart';
import 'package:valvn/core/l10n/content_strings.dart';
import 'package:valvn/core/riot/riot_ids.dart';

import 'economy_fixtures.dart';

Contract _contract(String uuid, String? relation, List<String> rewards) =>
    Contract.fromJson({
      'uuid': uuid,
      'displayName': 'C $uuid',
      'content': {
        'relationType': relation,
        'chapters': [
          {
            'isEpilogue': false,
            'levels': [
              for (final r in rewards)
                {
                  'reward': {'type': 'Spray', 'uuid': r},
                  'xp': 100,
                },
            ],
            'freeRewards': null,
          },
        ],
      },
    })!;

void main() {
  late ContentDb db;
  late RewardSourceIndex index;
  setUp(() {
    db = economyContent();
    index = RewardSourceIndex.fromContent(db);
  });

  test('battle pass skin: Season relation, contract name, premium level', () {
    final e = index.forItem(Fx.vandalCafeL1)!;
    expect(e.relation, ContractRelation.season);
    expect(e.contract.uuid, Fx.battlePass);
    expect(e.contractName, 'Mùa 2026 // Phần V');
    expect(e.label(tl), ContentStrings.rewardSourceBattlePass);
    expect(e.rewardType, ContractRewardType.skinLevel);
    expect(e.level, 25);
    expect(e.isFreeReward, isFalse);
    expect(index.forItem(Fx.knifeCafeL1)?.level, 50);
  });

  test('free-track rewards have no level', () {
    final e = index.forItem(Fx.bpFreeClassicL1)!;
    expect(e.isFreeReward, isTrue);
    expect(e.level, isNull);
    expect(e.label(tl), ContentStrings.rewardSourceBattlePass);
  });

  test('agent contract and event pass labels', () {
    final agent = index.forItem(Fx.ghostThinhLangL1.toUpperCase())!;
    expect(agent.relation, ContractRelation.agent);
    expect(agent.label(tl), ContentStrings.rewardSourceAgent);
    expect(agent.contractName, 'Trang Bị Cypher');
    expect(agent.level, 10);

    final event = index.forItem(Fx.eventCard)!;
    expect(event.relation, ContractRelation.event);
    expect(event.label(tl), ContentStrings.rewardSourceEvent);
    expect(event.rewardType, ContractRewardType.playerCard);
  });

  test('skins resolve by skin, level or chroma uuid', () {
    final skin = db.skin(Fx.vandalCafe)!;
    expect(index.forSkin(skin)?.contract.uuid, Fx.battlePass);
    expect(index.isRewardSkin(skin), isTrue);
    expect(index.forSkinUuid(Fx.vandalCafe)?.level, 25);
    expect(index.forSkinUuid(skin.chromas.last.uuid)?.level, 25);
    expect(index.isRewardSkin(db.skin(Fx.reaverVandal)!), isFalse);
    expect(index.forSkinUuid(Fx.reaverL1), isNull);
  });

  test('buddies resolve by level or buddy uuid', () {
    expect(index.forBuddy(Fx.gourmandBuddyL1)?.level, 2);
    final buddy = db.buddyByLevelUuid(Fx.gourmandBuddyL1)!;
    expect(index.forBuddy(buddy.uuid)?.contract.uuid, Fx.battlePass);
    expect(index.forBuddy(Fx.neoFrontierBuddy), isNull);
  });

  test('currency rewards are not indexed', () {
    expect(index.forItem(CurrencyIds.rp), isNull);
    expect(index.forItem(CurrencyIds.kc), isNull);
    expect(index.length, greaterThan(50));
  });

  test('prefers a contract with a known relation; allFor keeps all', () {
    final idx = RewardSourceIndex.fromContracts([
      _contract('a', null, ['x']),
      _contract('b', 'Event', ['x', 'y']),
      _contract('c', 'Season', ['x']),
    ]);
    expect(idx.forItem('X')?.contract.uuid, 'b');
    expect(idx.allFor('x').map((e) => e.contract.uuid), ['a', 'b', 'c']);
    expect(idx.forItem('y')?.level, 2);
    final onlyOther = RewardSourceIndex.fromContracts([
      _contract('a', null, ['z']),
    ]);
    expect(onlyOther.forItem('z')?.label(tl), isNull);
    expect(onlyOther.forSkinUuid('z')?.contract.uuid, 'a');
  });

  test('empty index', () {
    expect(RewardSourceIndex.empty.forItem(Fx.vandalCafeL1), isNull);
    expect(RewardSourceIndex.empty.forSkinUuid(Fx.vandalCafe), isNull);
    expect(RewardSourceIndex.empty.length, 0);
  });

  test('provider follows content', () async {
    final c = ProviderContainer.test(
      overrides: [contentProvider.overrideWith((ref) async => db)],
    );
    expect(c.read(rewardSourceIndexProvider).length, 0);
    await c.read(contentProvider.future);
    expect(
      c.read(rewardSourceIndexProvider).forItem(Fx.vandalCafeL1),
      isNotNull,
    );
  });
}
