import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/riot/riot_ids.dart';

import '../../helpers/fixtures.dart';

const _vandal = '9c82e19d-4575-0200-1a81-3eacf00cf872';
const _reaver = '30388628-42f0-606c-82c0-73ad43de997f';
const _reaverLevel1 = 'ba42fe63-457a-78ce-4499-47950a698129';
const _reaverLevel4 = '8c282914-446a-3e99-095a-cd97df201c8b';
const _reaverChroma2 = 'b2a065c0-4632-ccaa-f496-7681dc2a6185';
const _actV = '8102cd81-43a0-d0d7-bd59-47b8fe9bed1b';
const _e1a1 = '3f61c772-4560-cd3f-5d3f-a7ab5abda6b3';
const _bp = '3f04583c-4c7a-6bdf-65ce-d4b6ff53c5e9';

void main() {
  late ContentDb db;

  setUpAll(() {
    db = ContentDb.parse(loadContentFixtures(), manifestId: '67AF51413C6922AE');
  });

  group('weapons and skins', () {
    test('weapons sorted by category with vi labels', () {
      expect(db.weapons.map((w) => w.category), [
        WeaponCategory.rifle,
        WeaponCategory.melee,
      ]);
      expect(db.weapon(_vandal.toUpperCase())!.displayName, 'Vandal');
      expect(db.weapon(SpecialIds.melee)!.displayName, 'Cận Chiến');
      expect(WeaponCategory.melee.label, 'Cận chiến');
      expect(db.weapon(_vandal)!.shopCost, 2900);
    });

    test('lookup by level, chroma and any uuid (uppercase tolerated)', () {
      expect(db.skinByLevelUuid(_reaverLevel1)!.uuid, _reaver);
      expect(db.skinByLevelUuid(_reaverLevel4.toUpperCase())!.uuid, _reaver);
      expect(db.skinByChromaUuid(_reaverChroma2)!.uuid, _reaver);
      expect(db.skinByAnyUuid(_reaver)!.displayName, 'Vandal Reaver');
      expect(db.skinByAnyUuid(_reaverChroma2)!.uuid, _reaver);
      expect(db.weaponBySkin(_reaverLevel1)!.uuid, _vandal);
      expect(db.skinByAnyUuid('00000000-0000-0000-0000-000000000001'), isNull);
    });

    test('levels: first line name, level item enum, vi caption', () {
      final skin = db.skin(_reaver)!;
      expect(skin.level1Uuid, _reaverLevel1);
      expect(skin.levels[1].displayName, 'Vandal Reaver Cấp 2');
      expect(skin.levels[1].levelItem, 'VFX');
      expect(skin.levels[1].levelItemLabel, 'Hiệu ứng hình ảnh');
      expect(skin.levels[3].levelItemLabel, 'Đòn kết liễu');
      expect(skin.levels[0].levelItemLabel, 'Cơ bản');
      expect(db.skinLevel(_reaverLevel4)!.levelNumber, 4);
    });

    test('chromas: variant label from the last line without parentheses', () {
      final skin = db.skin(_reaver)!;
      expect(skin.chromas.first.isBase, isTrue);
      expect(skin.chromas[1].label, 'Dạng 1 Ánh Đỏ');
      expect(skin.chromas[1].displayName, 'Vandal Reaver Cấp 4');
      expect(skin.chromas[1].swatch, isNotNull);
    });

    test('standard and random-favorite skins are not collectible', () {
      final vandal = db.weapon(_vandal)!;
      expect(vandal.skins.where((s) => s.isStandard), hasLength(1));
      expect(vandal.skins.where((s) => s.isRandomFavorite), hasLength(1));
      expect(db.collectibleSkins.map((s) => s.uuid), contains(_reaver));
      expect(
        db.collectibleSkins.any((s) => s.isStandard || s.isRandomFavorite),
        isFalse,
      );
    });

    test('content tier of a skin', () {
      final tier = db.contentTier(db.skin(_reaver)!.contentTierUuid)!;
      expect(tier.devName, 'Premium');
      expect(tier.shortName, 'Cao Cấp');
      expect(tier.fallbackPrice, 1775);
      expect(db.contentTiers.map((t) => t.rank), [0, 1, 2, 3, 4]);
    });
  });

  group('items and cosmetics', () {
    test('item() resolves Riot ItemTypeID pairs', () {
      final skin = db.item(ItemTypeIds.skinLevel, _reaverLevel1)!;
      expect(skin.name, 'Vandal Reaver');
      expect(skin.typeLabel, 'Skin');
      final buddy = db.item(
        ItemTypeIds.buddyLevel,
        '6c3b1a9e-4067-7ed6-fc6c-fea61e0a057c',
      )!;
      expect(buddy.typeLabel, 'Phụ kiện súng');
      expect(db.item(ItemTypeIds.currency, CurrencyIds.vp)!.name, 'VP');
      expect(
        db.item(ItemTypeIds.playerTitle, SpecialIds.noTitle)!.name,
        'Không có danh hiệu',
      );
      expect(db.item('bogus', _reaverLevel1), isNull);
    });

    test('titles, bundles, level borders', () {
      expect(db.title('48d870a2-4493-ebf8-7d6f-979be914dc43')!.text, 'Tài Lộc');
      expect(
        db.bundleByUuid('2116A38E-4B71-F169-0D16-CE9289AF4BFA'),
        isNotNull,
      );
      expect(db.levelBorderFor(1)!.startingLevel, 1);
      expect(db.levelBorderFor(45)!.startingLevel, 40);
      expect(db.levelBorderFor(25)!.startingLevel, 20);
      expect(
        db
            .levelBorderFor(
              45,
              preferredId: 'ebc736cd-4b6a-137b-e2b0-1486e31312c9',
            )!
            .startingLevel,
        1,
      );
      expect(
        db
            .levelBorderFor(45, preferredId: SpecialIds.autoLevelBorder)!
            .startingLevel,
        40,
      );
    });

    test('currencies use app labels', () {
      expect(db.currency(CurrencyIds.kc)!.label, 'KC');
      expect(db.currency(CurrencyIds.rp)!.fullLabel, 'Radianite');
      expect(db.currency(CurrencyIds.vp)!.displayIcon, isNotNull);
    });

    test('ceremonies by Riot key', () {
      expect(db.ceremony('CeremonyAce')!.displayName, 'QUÉT SẠCH');
      expect(db.ceremony('CeremonyDefault'), isNull);
      expect(db.ceremony(''), isNull);
    });
  });

  group('agents, maps, queues, modes', () {
    test('agent lookup and roles', () {
      final jett = db.agent('ADD6443A-41BD-E414-F6AD-E58D267F4E95')!;
      expect(jett.displayName, 'Jett');
      expect(jett.isStarter, isTrue);
      expect(jett.role!.label, 'Đối đầu');
    });

    test('mapByUrl is exact and case-insensitive', () {
      expect(db.mapByUrl('/Game/Maps/Ascent/Ascent')!.displayName, 'Ascent');
      expect(db.mapByUrl('/game/maps/ascent/ascent'), isNotNull);
      expect(db.mapByUrl('/Game/Maps/HURM/HURM_Alley/HURM_Alley'), isNotNull);
      expect(db.mapByUrl('/Game/Maps/HURM'), isNull);
      expect(db.mapByUrl(null), isNull);
    });

    test('queueName: API label, console prefix, fallback table, raw id', () {
      expect(db.queueName('competitive'), 'Thi đấu xếp hạng');
      expect(db.queueName('console_unrated'), 'Đấu thường');
      expect(db.queueName('hurm'), 'Sinh Tử Đội');
      expect(db.queueName(''), 'Chơi tự do');
      expect(db.queueName('custom'), 'Chơi tự do');
      expect(db.queueName('brandnewqueue'), 'brandnewqueue');
      expect(db.queueShortName('competitive'), 'Xếp hạng');
      expect(ContentDb.empty().queueName('swiftplay'), 'Siêu Tốc');
    });

    test('game mode by Riot path directory key', () {
      expect(
        gameModeKey('/Game/GameModes/Bomb/BombGameMode.BombGameMode_C'),
        'bomb',
      );
      expect(
        gameModeKey(
          'ShooterGame/Content/GameModes/Bomb/BombGameMode_PrimaryAsset',
        ),
        'bomb',
      );
      expect(
        db.gameModeByPath('/Game/GameModes/Bomb/BombGameMode.BombGameMode_C'),
        isNotNull,
      );
      expect(db.gameModeByPath('/Game/GameModes/Unknown/X.X_C'), isNull);
    });
  });

  group('ranks and seasons', () {
    test('tier table selection by act (SUMMARY §7.4)', () {
      expect(db.tierTableForSeason(_actV)!.uuid, SpecialIds.currentTierTable);
      expect(
        db.tierTableForSeason(_e1a1)!.uuid,
        '564d8e28-c226-3180-6285-e48a390db8b1',
      );
      expect(
        db.tierTableForSeason('ffffffff-0000-0000-0000-000000000000')!.uuid,
        SpecialIds.currentTierTable,
      );
      expect(db.tierTableForSeason(null)!.uuid, SpecialIds.currentTierTable);
    });

    test('same tier number means different ranks across episodes', () {
      expect(db.tier(21, seasonUuid: _actV)!.displayName, 'Thượng Nhân 1');
      expect(db.tier(21, seasonUuid: _e1a1)!.displayName, 'Bất Tử 1');
      expect(db.tier(24, seasonUuid: _actV)!.displayName, 'Bất Tử 1');
      expect(db.tier(24, seasonUuid: _e1a1)!.displayName, 'Radiant');
      expect(db.tier(27)!.displayName, 'Radiant');
    });

    test('unused tiers 1–2 read as unranked', () {
      expect(db.tier(0)!.displayName, 'Chưa xếp hạng');
      expect(db.tier(1)!.isUnranked, isTrue);
      expect(db.tier(1)!.displayName, 'Chưa xếp hạng');
      expect(db.tier(3)!.displayName, 'Sắt 1');
    });

    test('current act is computed from dates', () {
      expect(db.currentAct(DateTime.utc(2026, 9, 28))!.uuid, _actV);
      expect(
        db.currentAct(DateTime.utc(2026, 10, 20))!.uuid,
        'd816f426-48ea-f052-117f-9697a155b319',
      );
      expect(db.currentAct(DateTime.utc(2019)), isNull);
      final act = db.currentAct(DateTime.utc(2026, 9, 28))!;
      expect(db.actTitle(act), 'V26 // PHẦN V');
      expect(db.actTitle(db.season(_e1a1)!), 'HỒI 1 // PHẦN I');
    });
  });

  group('contracts', () {
    test('current battle pass for the current act', () {
      expect(db.currentBattlePass(DateTime.utc(2026, 9, 28))!.uuid, _bp);
      // Act VI has no contract in the fixture → falls back to the latest.
      expect(db.currentBattlePass(DateTime.utc(2026, 11, 1))!.uuid, _bp);
    });

    test('flat levels and XP math (SUMMARY §9.4)', () {
      final bp = db.contract(_bp)!;
      expect(bp.flatLevels.map((l) => l.xp), [
        0,
        2000,
        2750,
        5000,
        5750,
        36500,
      ]);
      expect(bp.totalXp, 52000);
      expect(bp.xpForNextLevel(1), 2000);
      expect(bp.xpForNextLevel(6), isNull);
      expect(bp.chapters.last.isEpilogue, isTrue);
      expect(bp.chapters.first.freeRewards, isNotEmpty);
    });

    test('reward source labels (C9)', () {
      final source = db.rewardSource('d538eac0-4990-f84d-93bf-4d9ce09bf75a')!;
      expect(source.relation, ContractRelation.season);
      expect(source.label, 'Phần thưởng Battle Pass');
      expect(db.rewardSource(_reaverLevel1), isNull);
    });
  });

  test('gear, events and game-mode equippables', () {
    expect(
      db.gearItem('822BCAB2-40A2-324E-C137-E09195AD7692')!.displayName,
      'Giáp Hạng Nặng',
    );
    expect(db.gearItem('822bcab2-40a2-324e-c137-e09195ad7692')!.cost, 1000);
    expect(db.events, hasLength(3));
    expect(
      db
          .weaponOrEquippable('C5DE005C-4BDC-26A7-A47D-C295EAAAE9D8')!
          .displayName,
      'Classic',
    );
    expect(db.weaponOrEquippable(_vandal)!.displayName, 'Vandal');
  });

  test('missions', () {
    final m = db.missions.first;
    expect(m.isWeekly, isTrue);
    expect(m.title, isNotEmpty);
    expect(m.xpGrant, greaterThan(0));
    expect(db.mission(m.uuid.toUpperCase()), same(m));
  });

  test('corrupt or missing endpoints never throw', () {
    final bad = ContentDb.parse({
      'weapons': '<!DOCTYPE html>',
      'maps': '{"status":200,"data":null}',
      'agents': '{"status":200,"data":[{"uuid":null},{"displayName":"x"},42]}',
      'seasons': '[{"uuid":"ABC","type":"EAresSeasonType::Act"}]',
    });
    expect(bad.weapons, isEmpty);
    expect(bad.agents, isEmpty);
    expect(bad.season('abc')!.isAct, isTrue);
    expect(bad.currencies, hasLength(4), reason: 'fallback table');
    expect(bad.contentTiers, hasLength(5), reason: 'fallback table');
    expect(bad.tierTableForSeason('x'), isNull);
  });
}
