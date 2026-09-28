import 'dart:convert';
import 'dart:io';

import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/util/json.dart';

import '../../../helpers/fixtures.dart';

/// PUUIDs used by `test/fixtures/competitive/*.json`.
const me = 'aaaaaaaa-0000-4000-8000-000000000001';
const mate = 'aaaaaaaa-0000-4000-8000-000000000002';
const enemy1 = 'bbbbbbbb-0000-4000-8000-000000000003';
const enemy2 = 'bbbbbbbb-0000-4000-8000-000000000004';
const observer = 'cccccccc-0000-4000-8000-000000000005';
const friend = 'ffffffff-0000-4000-8000-00000000000f';

/// Acts of the content fixtures.
const actV =
    '8102cd81-43a0-d0d7-bd59-47b8fe9bed1b'; // V26 // PHẦN V, Episode5 table
const e1a1 =
    '3f61c772-4560-cd3f-5d3f-a7ab5abda6b3'; // HỒI 1 // PHẦN I, Episode1 table
const unknownAct = '9999aaaa-0000-4000-8000-00000000abcd';

/// Match ids of the fixtures.
const compMatch = 'd1000000-0000-4000-8000-000000000001';
const dmMatch = 'd2000000-0000-4000-8000-000000000002';
const customMatch = 'd3000000-0000-4000-8000-000000000003';
const tdmMatch = 'd4000000-0000-4000-8000-000000000004';

String updateId(int i) => 'e${i}000000-0000-4000-8000-00000000000$i';

Object? competitiveFixture(String name) =>
    jsonDecode(File('test/fixtures/competitive/$name.json').readAsStringSync());

JsonMap competitiveFixtureMap(String name) => asMap(competitiveFixture(name))!;

ContentDb testContent() => ContentDb.parse(loadContentFixtures());

class MockPvpApi extends Mock implements PvpApi {}
