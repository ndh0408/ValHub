import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_maintenance.dart';
import 'package:valvn/core/accounts/account_repository.dart';
import 'package:valvn/core/domain/competitive/rr_history.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';

import '../../helpers/temp_dir.dart';
import '../../helpers/test_prefs.dart';

const _id = '11111111-1111-1111-1111-111111111111';

class _HistoryFiles extends JsonFileCache {
  _HistoryFiles(super.root);
  bool failDelete = false;

  @override
  Future<void> delete(String key) async {
    if (failDelete) throw const FileSystemException('disk unavailable');
    await super.delete(key);
  }

  @override
  Future<void> deletePrefix(String prefix) async {
    if (failDelete) throw const FileSystemException('disk unavailable');
    await super.deletePrefix(prefix);
  }
}

void main() {
  late Directory tmp;
  late Prefs prefs;
  late MemorySecureStore secure;
  late JsonFileCache cache;
  late _HistoryFiles historyFiles;
  late RrHistoryStore history;
  late AccountRepository repo;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('valvn_maintenance');
    prefs = await createTestPrefs();
    secure = MemorySecureStore();
    cache = JsonFileCache(() async => Directory('${tmp.path}/cache'));
    historyFiles = _HistoryFiles(() async => Directory('${tmp.path}/history'));
    history = RrHistoryStore(historyFiles);
    repo = AccountRepository(
      prefs: prefs,
      secureStore: secure,
      fileCache: cache,
    );
    await repo.upsert(
      const Account(
        puuid: _id,
        gameName: 'Player',
        tagLine: 'TAG',
        region: 'ap',
        shard: 'ap',
      ),
    );
    await repo.setActivePuuid(_id);
    secure.values[SecureKeys.cookies(_id)] = 'secret';
    secure.values['acct.$_id.futureSecret'] = 'secret';
    await prefs.setString(PrefKeys.accountKept(_id, 'wishlist'), 'skin');
    await cache.write('names/map', {'name': 'Player#TAG'});
    await historyFiles.write('acct/$_id/store_history', {'seen': true});
    await historyFiles.write(RrHistoryStore.key(_id), {
      'v': 1,
      'rows': <Object?>[],
    });
  });

  tearDown(() async {
    history.dispose();
    await deleteTempDir(tmp);
  });

  Future<SweepReport> run() => runAccountStartupMaintenance(
    prefs: prefs,
    secureStore: secure,
    cache: cache,
    history: history,
    historyFiles: historyFiles,
  );

  test(
    'startup finishes an interrupted wipe and clears shared names',
    () async {
      await repo.markPendingWipe(_id, keepLocalData: false);
      expect((await run()).finishedSignOuts, 1);
      expect(repo.loadAll(), isEmpty);
      expect(repo.pendingWipes, isEmpty);
      expect(repo.activePuuid, isNull);
      expect(secure.values, isEmpty);
      expect(prefs.getString(PrefKeys.accountKept(_id, 'wishlist')), isNull);
      expect(await historyFiles.exists(RrHistoryStore.key(_id)), isFalse);
      expect(await cache.exists('names/map'), isFalse);
      expect(await historyFiles.exists('acct/$_id/store_history'), isFalse);
    },
  );

  test('the keep choice survives an interrupted sign-out', () async {
    await repo.markPendingWipe(_id, keepLocalData: true);
    expect((await run()).finishedSignOuts, 1);
    expect(secure.values, isEmpty);
    expect(prefs.getString(PrefKeys.accountKept(_id, 'wishlist')), 'skin');
    expect(await historyFiles.exists(RrHistoryStore.key(_id)), isTrue);
    expect(await historyFiles.exists('acct/$_id/store_history'), isTrue);
  });

  test(
    'a history disk failure retains the marker until a later launch',
    () async {
      await repo.markPendingWipe(_id, keepLocalData: false);
      historyFiles.failDelete = true;
      expect((await run()).finishedSignOuts, 0);
      expect(repo.pendingWipes, {_id: false});
      expect(await historyFiles.exists(RrHistoryStore.key(_id)), isTrue);
      historyFiles.failDelete = false;
      expect((await run()).finishedSignOuts, 1);
      expect(repo.pendingWipes, isEmpty);
      expect(await historyFiles.exists(RrHistoryStore.key(_id)), isFalse);
    },
  );
}
