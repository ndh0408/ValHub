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

/// The periodic job: keep dormant sessions alive, then check wishlists.
Future<bool> _periodic(Map<String, dynamic>? input) async {
  final keepAlive = await runSessionKeepAlive();
  final wishlist = await runWishlistCheck();
  return keepAlive && wishlist;
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
