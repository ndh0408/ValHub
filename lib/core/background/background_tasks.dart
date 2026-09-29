import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:workmanager/workmanager.dart';

import '../../features/wishlist/background/wishlist_check.dart';
import 'session_keep_alive.dart';

/// Periodic task id. MUST equal Info.plist `BGTaskSchedulerPermittedIdentifiers`
/// and the identifier registered in `ios/Runner/AppDelegate.swift`.
const kWishlistCheckTask = 'vn.valvn.app.wishlistCheck';

/// Handler for one background task (runs in a fresh isolate; no Riverpod).
/// Return `true` on success; `false` lets Android retry with backoff.
typedef BackgroundTaskHandler = Future<bool> Function(
  Map<String, dynamic>? input,
);

/// Whole-job budget: iOS BGAppRefresh gives ~30 s in total.
const kBackgroundJobBudget = Duration(seconds: 25);

/// The periodic job: keep dormant sessions alive, then check wishlists.
Future<bool> _periodic(Map<String, dynamic>? input) => runPeriodicJob(
  keepAlive: () => runSessionKeepAlive(budget: const Duration(seconds: 12)),
  wishlist: (budget) => runWishlistCheck(budget: budget),
);

/// One deadline ([kBackgroundJobBudget]) covers both steps, the wishlist
/// step gets whatever time is left, and a failure in one never skips the
/// other.
@visibleForTesting
Future<bool> runPeriodicJob({
  required Future<bool> Function() keepAlive,
  required Future<bool> Function(Duration budget) wishlist,
  DateTime Function() now = DateTime.now,
}) async {
  final deadline = now().add(kBackgroundJobBudget);
  var keepAliveOk = false;
  try {
    keepAliveOk = await keepAlive();
  } on Object catch (e) {
    debugPrint('Keep-alive failed: ${e.runtimeType}');
  }
  final rest = deadline.difference(now());
  var wishlistOk = false;
  try {
    wishlistOk = await wishlist(rest.isNegative ? Duration.zero : rest);
  } on Object catch (e) {
    debugPrint('Wishlist check failed: ${e.runtimeType}');
  }
  return keepAliveOk && wishlistOk;
}

/// Task name → handler. iOS background fetch arrives as
/// [Workmanager.iOSBackgroundTask].
final Map<String, BackgroundTaskHandler> backgroundTaskHandlers = {
  kWishlistCheckTask: _periodic,
  Workmanager.iOSBackgroundTask: _periodic,
};

/// Entry point of the workmanager isolate.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, input) async {
    final handler = backgroundTaskHandlers[task];
    if (handler == null) return true;
    try {
      return await handler(input);
    } on Object catch (e) {
      debugPrint('Background task failed: ${e.runtimeType}');
      return false;
    }
  });
}

/// Initialises workmanager and (re-)registers the periodic task
/// (≥ 6 h, network required). Safe to call on every launch.
Future<void> initBackgroundWork() async {
  if (kIsWeb) return;
  try {
    await Workmanager().initialize(callbackDispatcher);
    await Workmanager().registerPeriodicTask(
      kWishlistCheckTask,
      kWishlistCheckTask,
      frequency: const Duration(hours: 6),
      initialDelay: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
    );
  } on Object catch (e) {
    debugPrint('initBackgroundWork failed: ${e.runtimeType}');
  }
}
