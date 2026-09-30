import 'dart:async';

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
/// Best effort and bounded by [timeout]: a slow keystore never delays the
/// first frame for long, and any failure is only logged.
Future<SweepReport> runAccountStartupMaintenance({
  required Prefs prefs,
  required SecureStore secureStore,
  NotificationService? notifications,
  JsonFileCache? cache,
  RrHistoryStore? history,
  SessionLog? log,
  Duration timeout = const Duration(seconds: 3),
}) async {
  try {
    final files = cache ?? JsonFileCache.appSupport('cache');
    final rr = history ?? RrHistoryStore(JsonFileCache.appSupport('history'));
    final repo = AccountRepository(
      prefs: prefs,
      secureStore: secureStore,
      fileCache: files,
    );
    final eraser = LocalDataEraser(prefs: prefs, cache: files, history: rr);
    Future<void> cancelNotifications(String puuid) async {
      try {
        await notifications?.cancelForAccount(puuid);
      } on Object {
        // Notifications are best effort.
      }
    }

    final pending = repo.pendingWipes;
    final finished = await repo
        .finishPendingWipes(
          beforeWipe: cancelNotifications,
          afterWipe: (puuid) async {
            if (pending[puuid] == false) await eraser.eraseAccount(puuid);
          },
        )
        .timeout(timeout);
    final swept = await repo
        .sweepOrphans(beforeWipe: cancelNotifications)
        .timeout(timeout);
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
