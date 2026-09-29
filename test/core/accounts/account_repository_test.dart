import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_async_platform_interface.dart';
import 'package:shared_preferences_platform_interface/types.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_repository.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';

import '../../helpers/test_prefs.dart';

Account _a(int i, {bool needsLogin = false}) => Account(
  puuid: 'p$i',
  gameName: 'P$i',
  tagLine: 'VN',
  region: 'ap',
  shard: 'ap',
  needsLogin: needsLogin,
);

Future<void> _writeFromOtherIsolate(List<Account> accounts) =>
    SharedPreferencesAsyncPlatform.instance!.setString(
      PrefKeys.accounts,
      jsonEncode([for (final a in accounts) a.toJson()]),
      const SharedPreferencesOptions(),
    );

void main() {
  late AccountRepository repo;

  setUp(() async {
    final prefs = await createTestPrefs();
    repo = AccountRepository(prefs: prefs, secureStore: MemorySecureStore());
    await repo.saveAll([_a(1), _a(2)]);
  });

  test(
    'patch does not resurrect an account removed by another isolate',
    () async {
      await _writeFromOtherIsolate([_a(2)]); // UI removed p1
      await repo.patch('p2', (a) => a.copyWith(needsLogin: true));
      expect(repo.loadAll().map((a) => a.puuid), ['p2']);
      expect(repo.loadAll().single.needsLogin, isTrue);
    },
  );

  test('patch keeps needsLogin written by another isolate', () async {
    await _writeFromOtherIsolate([_a(1, needsLogin: true), _a(2)]);
    await repo.patch('p2', (a) => a.copyWith(gameName: 'New'));
    expect(repo.find('p1')!.needsLogin, isTrue);
    expect(repo.find('p2')!.gameName, 'New');
  });

  test('findFresh sees removals made by another isolate', () async {
    await _writeFromOtherIsolate([_a(2)]);
    expect(repo.find('p1'), isNotNull); // stale cache
    expect(await repo.findFresh('p1'), isNull);
  });
}
