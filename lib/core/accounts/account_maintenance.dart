import '../domain/competitive/rr_history.dart';
import '../logging/session_log.dart';
import '../notifications/notification_service.dart';
import '../storage/json_file_cache.dart';
import '../storage/prefs.dart';
import '../storage/secure_store.dart';
import 'account_repository.dart';
import 'local_data.dart';

/// Start-up housekeeping of per-account data (AR-003), run once by `main()`
/// before the UI:
///
/// 1. finishes the sign-outs a kill interrupted (`app.pendingWipe`), with the
///    "keep local data" choice the user made;
/// 2. sweeps the orphans: secure keys, `acct.<puuid>.*` prefs and
///    `acct/<puuid>/` files of accounts that are not in the list (an in-flight
///    fetch that finished after a sign-out, a crash). It never touches
///    `keep.*`.
///
/// Destructive work finishes before the UI may start another login.
/// Failures are logged and unfinished markers remain for the next launch.
Future<SweepReport> runAccountStartupMaintenance({
  required Prefs prefs,
  required SecureStore secureStore,
  NotificationService? notifications,
  JsonFileCache? cache,
  RrHistoryStore? history,
  JsonFileCache? historyFiles,
  SessionLog? log,
}) async {
  try {
    final files = cache ?? JsonFileCache.appSupport('cache');
    final keptFiles = historyFiles ?? JsonFileCache.appSupport('history');
    final rr = history ?? RrHistoryStore(keptFiles);
    final repo = AccountRepository(
      prefs: prefs,
      secureStore: secureStore,
      fileCache: files,
    );
    final eraser = LocalDataEraser(
      prefs: prefs,
      cache: files,
      history: rr,
      historyFiles: keptFiles,
    );
    Future<void> cancelNotifications(String puuid) async {
      try {
        await notifications?.cancelForAccount(puuid);
      } on Object {
        // Notifications are best effort.
      }
    }

    final pending = repo.pendingWipes;
    final finished = await repo.finishPendingWipes(
      beforeWipe: cancelNotifications,
      afterWipe: (puuid) async {
        if (pending[puuid] == false) {
          await eraser.eraseAccount(puuid);
        } else {
          await prefs.setBool(
            PrefKeys.accountKept(puuid, 'retainedHistory'),
            true,
          );
        }
        if (repo.loadAll().isEmpty) await eraser.eraseSharedCaches();
      },
    );
    final swept = await repo.sweepOrphans(beforeWipe: cancelNotifications);
    await eraser.sweepHistory({for (final a in repo.loadAll()) a.puuid});
    final active = repo.activePuuid;
    if (active != null && repo.find(active) == null) {
      await repo.setActivePuuid(repo.loadAll().firstOrNull?.puuid);
    }
    if (history == null) rr.dispose();
    final report = SweepReport(
      accounts: swept.accounts,
      finishedSignOuts: finished.length,
    );
    if (!report.isEmpty) {
      log?.add(
        'accounts.sweep',
        detail:
            'orphans=${report.accounts.length} '
            'finished=${report.finishedSignOuts}',
      );
    }
    return report;
  } on Object catch (e) {
    log?.add('accounts.sweep.error', detail: e.runtimeType.toString());
    return const SweepReport();
  }
}
