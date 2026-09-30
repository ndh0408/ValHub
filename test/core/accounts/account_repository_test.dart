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

  group('serialised read-modify-write (AR-020)', () {
    test('concurrent patches of different accounts all land', () async {
      await Future.wait([
        for (var i = 0; i < 20; i++)
          repo.patch(
            i.isEven ? 'p1' : 'p2',
            (a) => a.copyWith(level: (a.level ?? 0) + 1),
          ),
      ]);
      expect(repo.find('p1')!.level, 10);
      expect(repo.find('p2')!.level, 10);
    });

    test(
      'patch, upsert and remove interleave without losing anything',
      () async {
        await Future.wait([
          repo.patch('p1', (a) => a.copyWith(needsLogin: true)),
          repo.upsert(_a(3)),
          repo.patch('p2', (a) => a.copyWith(gameName: 'Two')),
          repo.removeMetadata('p1'),
          repo.upsert(_a(4)),
        ]);
        expect(repo.loadAll().map((a) => a.puuid), ['p2', 'p3', 'p4']);
        expect(repo.find('p2')!.gameName, 'Two');
      },
    );

    test('a failing operation does not block the queue', () async {
      await expectLater(
        repo.patch('p1', (a) => throw StateError('boom')),
        throwsStateError,
      );
      await repo.patch('p2', (a) => a.copyWith(level: 5));
      expect(repo.find('p2')!.level, 5);
    });

    test('every write bumps the version key', () async {
      final before = repo.accountsVersion;
      await repo.patch('p1', (a) => a.copyWith(level: 9));
      await repo.upsert(_a(7));
      await repo.removeMetadata('p7');
      expect(repo.accountsVersion, before + 3);
      expect(await repo.accountsVersionOnDisk(), before + 3);
    });

    test('a background write is visible through the disk version', () async {
      final cached = repo.accountsVersion;
      await SharedPreferencesAsyncPlatform.instance!.setInt(
        PrefKeys.accountsVersion,
        cached + 5,
        const SharedPreferencesOptions(),
      );
      expect(repo.accountsVersion, cached);
      expect(await repo.accountsVersionOnDisk(), cached + 5);
    });
  });
}
