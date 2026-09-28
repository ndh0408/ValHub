import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/util/json.dart';

/// Raw text of `test/fixtures/economy/<name>`.
String economyFixtureText(String name) =>
    File('test/fixtures/economy/$name').readAsStringSync();

/// Decoded `test/fixtures/economy/<name>`.
JsonMap economyFixture(String name) =>
    asMap(jsonDecode(economyFixtureText(name)))!;

/// Trimmed real vi-VN valorant-api content for the economy tests.
ContentDb economyContent() =>
    ContentDb.parse(Map<String, Object?>.from(economyFixture('content.json')));

/// Reads an auto-dispose provider's future while keeping it listened (an
/// unlistened auto-dispose provider is disposed while loading).
Future<T> readListened<T>(
  ProviderContainer container,
  ProviderListenable<Future<T>> provider,
) {
  container.listen(provider, (_, _) {});
  return container.read(provider);
}

/// Well-known uuids of the economy fixtures.
abstract final class Fx {
  static const puuid = 'c5a5af97-d9b8-5217-9d26-1b35f93ca3d0';

  // Vandal
  static const vandal = '9c82e19d-4575-0200-1a81-3eacf00cf872';
  static const vandalStandard = '27f21d97-4c4b-bd1c-1f08-31830ab0be84';
  static const randomFavorite = '9c808029-48f5-ce89-21c5-88bf4228d2ed';
  static const reaverVandal = '30388628-42f0-606c-82c0-73ad43de997f';
  static const reaverL1 = 'ba42fe63-457a-78ce-4499-47950a698129';
  static const reaverL2 = '6f9ba692-4618-d0e6-3099-42b4dc5fce89';
  static const reaverL3 = '98597b95-451c-70cf-46fb-31b4c5a54394';
  static const reaverL4 = '8c282914-446a-3e99-095a-cd97df201c8b';
  static const reaverBaseChroma = '2bd28382-48c6-8579-83e8-e9b64b783de3';
  static const reaverChroma2 = 'b2a065c0-4632-ccaa-f496-7681dc2a6185';
  static const reaverChroma3 = 'db4461e5-40dd-1173-3b64-e5836f92f4dd';
  static const vandalCafe = '7f26d04c-44fb-1d65-16f0-4f827686d72b';
  static const vandalCafeL1 = 'bc465bdb-4a85-7981-3e31-409d093e9c12';

  // Daily shop
  static const aresSentinels = '9f3e2ba6-428f-c635-67e0-b8b7d9e3c2fc';
  static const aresSentinelsL1 = '0ddbdf8c-43b0-e2f1-94f8-d6be9d2a2110';
  static const aresPrism = '841c9aab-4005-f7fd-3b67-24b335100fb4';
  static const aresPrismL1 = '29be6d9e-48b2-1229-4f7d-4da1c20deda9';
  static const magepunkL1 = '003e0991-4370-8837-f8fc-6ab3acec2dbf';
  static const operatorL1 = '49b00063-4a7e-6c73-b8c9-68a8d5727757';

  // Bundles
  static const bundleId = '4ac0cf99-0a6f-41a7-bd94-9a58fe7ec106';
  static const neoFrontierAsset = '550d9d34-4942-a605-ba3c-b09452e52f83';
  static const odinNeoFrontier = 'bd647d56-4542-19cd-e1ed-4fb429c78cf9';
  static const odinNeoFrontierL1 = '6f60b3ce-4cbf-91ea-2ca7-59bbf1923751';
  static const bundle2Id = 'b7e1c0de-1111-4a2b-9c3d-000000000002';
  static const phantomTocChien = '8db507b5-4d57-96e0-000e-2d8c8af79550';
  static const phantomTocChienL1 = 'd39a4263-49d3-f2e0-2c13-c299f8644518';
  static const phantomTocChienChroma = '2e3b98b6-46e9-e233-1e1b-269ebd84598a';

  // Night market / owned
  static const bulldogVoCuc = 'decd0962-453a-1551-47e1-1287aafb5a27';
  static const bulldogVoCucL1 = '5fc3c5e8-470e-7683-b594-6580d5e3d624';
  static const daoReaver = '0aecb2b8-49cc-560e-42c7-6cbce44f05cf';
  static const daoReaverL1 = 'd7a02a43-47a5-556c-a69f-ec9cf6ede66d';
  static const knifeCafe = '25f7a66f-41a3-13da-53d9-ff94be3ace42';
  static const knifeCafeL1 = 'c92dedcb-4461-5a6e-8740-bcba900a19a2';
  static const ghostThinhLang = 'a1d3a9e2-4f61-b1f7-3a01-cf867264d1cb';
  static const ghostThinhLangL1 = 'afcb2528-4415-0178-98b1-c0a751092762';
  static const unknownLevel = 'ffffffff-0000-4000-8000-00000000abcd';

  // Buddies
  static const neoFrontierBuddy = '0e5aac9d-419a-3767-a154-4c9abfe8c72f';
  static const neoFrontierBuddyL1 = 'fc35c2a0-4028-f217-faac-79a02aeeef90';
  static const gourmandBuddyL1 = '86cc0f4b-4549-22b0-cce8-1cb5ec9c6845';

  // Cosmetics
  static const sprayTinhNguyen = 'b4b684bd-40bd-15b2-86b5-3b827a636090';
  static const sprayCypher = 'e8754a6e-4ec5-3d1c-2ed9-e0a5ff9f1271';
  static const cardNgoiSang = '1711d20d-4b1c-c64a-14be-d4ae58a457c6';
  static const titleTaiLoc = '48d870a2-4493-ebf8-7d6f-979be914dc43';
  static const flexOra = 'fc33f376-4a58-687c-6961-bd8a7e529346';
  static const eventCard = '7b0f9b3f-4ebf-c3b2-8cbe-e2afb79fc5be';
  static const bpFreeClassicL1 = 'cad66677-4340-742c-b737-99b706b5af93';

  // Agents / contracts
  static const jett = 'add6443a-41bd-e414-f6ad-e58d267f4e95';
  static const gekko = 'e370fa57-4757-3604-3648-499e1f642d3f';
  static const cypher = '117ed9e3-49f3-6512-3ccf-0cada7e3823b';
  static const battlePass = '3f04583c-4c7a-6bdf-65ce-d4b6ff53c5e9';
  static const cypherContract = '2195e89f-20ad-4e37-b46c-cf46a6715dfd';
  static const eventPass = 'd70f2a95-4682-5216-984f-ddaaa14436a7';
}
