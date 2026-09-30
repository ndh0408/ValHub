import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_repository.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';

import '../../helpers/temp_dir.dart';
import '../../helpers/test_prefs.dart';

const _alive = '11111111-1111-1111-1111-111111111111';
const _gone = '22222222-2222-2222-2222-222222222222';
const _gone2 = '33333333-3333-3333-3333-333333333333';

Account _account(String puuid) => Account(
  puuid: puuid,
  gameName: 'A',
  tagLine: 'B',
  region: 'ap',
  shard: 'ap',
);

void main() {
  late Directory tmp;
  late Prefs prefs;
  late MemorySecureStore secure;
  late JsonFileCache files;
  late AccountRepository repo;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('valvn_sweep');
    prefs = await createTestPrefs();
    secure = MemorySecureStore();
    files = JsonFileCache(() async => tmp);
    repo = AccountRepository(
      prefs: prefs,
      secureStore: secure,
      fileCache: files,
    );
    await repo.upsert(_account(_alive));
  });

  tearDown(() => deleteTempDir(tmp));

  Future<void> leaveTracesOf(String id) async {
    for (final key in SecureKeys.allFor(id)) {
      secure.values[key] = 'secret';
    }
    await prefs.setString(PrefKeys.account(id, 'matchPrivacy'), 'x');
    await prefs.setStringList(PrefKeys.account(id, 'notificationIds'), ['1']);
    await files.write(JsonFileCache.accountKey(id, 'economy_wallet'), {'x': 1});
    await files.write(JsonFileCache.accountKey(id, 'loadout'), {'x': 1});
  }

  bool hasTraces(String id) =>
      secure.values.keys.any((k) => k.contains(id)) ||
      prefs.keys.any((k) => k.startsWith('acct.$id.')) ||
      Directory('${tmp.path}/acct/$id').existsSync();

  group('sweepOrphans (AR-003)', () {
    test('removes what accounts outside the list left behind', () async {
      await leaveTracesOf(_gone);
      await leaveTracesOf(_gone2);
      final report = await repo.sweepOrphans();
      expect(report.accounts, {_gone, _gone2});
      expect(hasTraces(_gone), isFalse);
      expect(hasTraces(_gone2), isFalse);
    });

    test('never touches an account that is in the list', () async {
      await leaveTracesOf(_alive);
      final report = await repo.sweepOrphans();
      expect(report.isEmpty, isTrue);
      expect(hasTraces(_alive), isTrue);
      expect(secure.values[SecureKeys.cookies(_alive)], 'secret');
    });

    test('never touches keep.* (data the user chose to keep)', () async {
      await leaveTracesOf(_gone);
      await prefs.setString(PrefKeys.accountKept(_gone, 'wishlist'), 'a,b');
      await prefs.setString(
        PrefKeys.accountKept(_gone, 'loadoutPresets'),
        '[]',
      );
      await repo.sweepOrphans();
      expect(hasTraces(_gone), isFalse);
      expect(prefs.getString(PrefKeys.accountKept(_gone, 'wishlist')), 'a,b');
      expect(
        prefs.getString(PrefKeys.accountKept(_gone, 'loadoutPresets')),
        '[]',
      );
    });

    test('ignores keys that are not shaped like acct.<uuid>', () async {
      secure.values['acct.not-a-uuid.cookies'] = 'x';
      secure.values['other.key'] = 'y';
      await prefs.setString('acct.settings.theme', 'z');
      await prefs.setString('f.home.layout', 'w');
      await files.write('acct/not-a-uuid/x', {'x': 1});
      final report = await repo.sweepOrphans();
      expect(report.isEmpty, isTrue);
      expect(
        secure.values.keys,
        containsAll(['acct.not-a-uuid.cookies', 'other.key']),
      );
      expect(prefs.getString('acct.settings.theme'), 'z');
      expect(prefs.getString('f.home.layout'), 'w');
      expect(await files.exists('acct/not-a-uuid/x'), isTrue);
    });

    test('an orphan found only in prefs or only in files is swept', () async {
      await prefs.setString(PrefKeys.account(_gone, 'matchPrivacy'), 'x');
      await files.write(JsonFileCache.accountKey(_gone2, 'loadout'), {'x': 1});
      final report = await repo.sweepOrphans();
      expect(report.accounts, {_gone, _gone2});
      expect(hasTraces(_gone), isFalse);
      expect(hasTraces(_gone2), isFalse);
    });

    test(
      'beforeWipe runs for each orphan first (notification cancel)',
      () async {
        await leaveTracesOf(_gone);
        final seen = <String>[];
        await repo.sweepOrphans(
          beforeWipe: (id) async {
            // The notification ids are still readable at this point.
            expect(
              prefs.getStringList(PrefKeys.account(id, 'notificationIds')),
              ['1'],
            );
            seen.add(id);
          },
        );
        expect(seen, [_gone]);
      },
    );

    test(
      'a failing beforeWipe leaves that orphan for the next start',
      () async {
        await leaveTracesOf(_gone);
        await repo.sweepOrphans(beforeWipe: (_) async => throw StateError('x'));
        expect(hasTraces(_gone), isTrue);
        await repo.sweepOrphans();
        expect(hasTraces(_gone), isFalse);
      },
    );

    test(
      'an unreadable keystore sweeps nothing from it (and does not crash)',
      () async {
        await leaveTracesOf(_gone);
        final blind = AccountRepository(
          prefs: prefs,
          secureStore: _BlindStore(secure),
          fileCache: files,
        );
        await blind.sweepOrphans();
        // The wipe of the orphan found in prefs / files still deletes its
        // secure keys by name; nothing else is guessed.
        expect(hasTraces(_gone), isFalse);
      },
    );

    test('uses the sign-out choice recorded for the orphan', () async {
      await leaveTracesOf(_gone);
      await prefs.setString(PrefKeys.accountKept(_gone, 'wishlist'), 'a');
      await repo.markPendingWipe(_gone, keepLocalData: false);
      await repo.sweepOrphans();
      expect(prefs.getString(PrefKeys.accountKept(_gone, 'wishlist')), isNull);
    });
  });

  group('pending sign-outs', () {
    test('the marker records the choice and clears', () async {
      expect(repo.pendingWipes, isEmpty);
      await repo.markPendingWipe(_gone, keepLocalData: true);
      await repo.markPendingWipe(_gone2, keepLocalData: false);
      expect(repo.pendingWipes, {_gone: true, _gone2: false});
      await repo.clearPendingWipe(_gone);
      expect(repo.pendingWipes, {_gone2: false});
      await repo.clearPendingWipe(_gone2);
      expect(repo.pendingWipes, isEmpty);
      expect(prefs.getString(PrefKeys.pendingWipe), isNull);
    });

    test(
      'finishPendingWipes completes a sign-out that was killed half-way',
      () async {
        // The kill hit after the marker but before the metadata was removed.
        await repo.upsert(_account(_gone));
        await leaveTracesOf(_gone);
        await prefs.setString(PrefKeys.accountKept(_gone, 'wishlist'), 'a');
        await repo.markPendingWipe(_gone, keepLocalData: true);
        final cancelled = <String>[];
        final done = await repo.finishPendingWipes(
          beforeWipe: (id) async => cancelled.add(id),
        );
        expect(done, {_gone});
        expect(cancelled, [_gone]);
        expect(repo.find(_gone), isNull);
        expect(repo.find(_alive), isNotNull);
        expect(hasTraces(_gone), isFalse);
        expect(prefs.getString(PrefKeys.accountKept(_gone, 'wishlist')), 'a');
        expect(repo.pendingWipes, isEmpty);
      },
    );

    test('a step that fails keeps the marker for the next start', () async {
      await repo.markPendingWipe(_gone, keepLocalData: true);
      final done = await repo.finishPendingWipes(
        beforeWipe: (_) async => throw StateError('x'),
      );
      expect(done, isEmpty);
      expect(repo.pendingWipes, {_gone: true});
    });
  });

  group('wipeAccountData', () {
    test('keeps keep.* by default, drops it when asked', () async {
      await leaveTracesOf(_gone);
      await prefs.setString(PrefKeys.accountKept(_gone, 'wishlist'), 'a');
      await repo.wipeAccountData(_gone);
      expect(hasTraces(_gone), isFalse);
      expect(prefs.getString(PrefKeys.accountKept(_gone, 'wishlist')), 'a');
      await repo.wipeAccountData(_gone, keepLocalData: false);
      expect(prefs.getString(PrefKeys.accountKept(_gone, 'wishlist')), isNull);
    });

    test('late writes of an in-flight fetch are dropped', () async {
      await leaveTracesOf(_gone);
      await repo.wipeAccountData(_gone);
      // The fetch that was running during the sign-out finishes now.
      await prefs.setString(PrefKeys.account(_gone, 'matchPrivacy'), 'late');
      await files.write(JsonFileCache.accountKey(_gone, 'economy_wallet'), {
        'late': 1,
      });
      expect(hasTraces(_gone), isFalse);
    });

    test('adding the account back lifts the block', () async {
      await repo.wipeAccountData(_gone);
      await repo.upsert(_account(_gone));
      await prefs.setString(PrefKeys.account(_gone, 'matchPrivacy'), 'new');
      await files.write(JsonFileCache.accountKey(_gone, 'loadout'), {'x': 1});
      expect(prefs.getString(PrefKeys.account(_gone, 'matchPrivacy')), 'new');
      expect(
        await files.exists(JsonFileCache.accountKey(_gone, 'loadout')),
        isTrue,
      );
    });

    test(
      'the kept data of a signed-out account stays writable when kept',
      () async {
        await repo.wipeAccountData(_gone);
        await prefs.setString(PrefKeys.accountKept(_gone, 'wishlist'), 'b');
        expect(prefs.getString(PrefKeys.accountKept(_gone, 'wishlist')), 'b');
      },
    );
  });
}

/// A keystore that cannot list its keys (everything else works).
class _BlindStore implements SecureStore {
  _BlindStore(this._inner);

  final SecureStore _inner;

  @override
  Future<String?> read(String key) => _inner.read(key);

  @override
  Future<void> write(String key, String value) => _inner.write(key, value);

  @override
  Future<void> delete(String key) => _inner.delete(key);

  @override
  Future<Set<String>> readAllKeys() async => const <String>{};

  @override
  Future<void> deleteAll() => _inner.deleteAll();
}
