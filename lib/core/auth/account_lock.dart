import 'dart:async';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

/// Serialises re-auth for one account across isolates (UI + background),
/// because two parallel re-auths can invalidate each other's rotated cookies
/// (SUMMARY §3.4 "Concurrency").
abstract interface class AccountLock {
  Future<T> run<T>(String puuid, Future<T> Function() body);
}

/// In-process only (tests, or when a single isolate is guaranteed).
class LocalAccountLock implements AccountLock {
  final Map<String, Future<void>> _tails = {};

  @override
  Future<T> run<T>(String puuid, Future<T> Function() body) async {
    final previous = _tails[puuid] ?? Future<void>.value();
    final done = Completer<void>();
    _tails[puuid] = done.future;
    try {
      await previous;
      return await body();
    } finally {
      done.complete();
      _tails.removeWhere(
        (key, tail) => key == puuid && identical(tail, done.future),
      );
    }
  }
}

/// Advisory cross-isolate lock: a `{owner}|{epochMs}` timestamp in prefs
/// (read straight from disk with [SharedPreferencesAsync]). Stale locks
/// (older than [staleAfter]) are taken over; waiting gives up after
/// [maxWait] and proceeds anyway (never deadlock the app).
class PrefsAccountLock implements AccountLock {
  PrefsAccountLock({
    SharedPreferencesAsync? prefs,
    this.staleAfter = const Duration(seconds: 60),
    this.maxWait = const Duration(seconds: 45),
  }) : _prefs = prefs ?? SharedPreferencesAsync(),
       _owner = _randomOwner();

  final SharedPreferencesAsync _prefs;
  final Duration staleAfter;
  final Duration maxWait;
  final String _owner;
  final LocalAccountLock _local = LocalAccountLock();

  static String _randomOwner() {
    final r = Random();
    return List.generate(8, (_) => r.nextInt(16).toRadixString(16)).join();
  }

  static String _key(String puuid) => 'lock.reauth.$puuid';

  @override
  Future<T> run<T>(String puuid, Future<T> Function() body) =>
      _local.run(puuid, () async {
        await _acquire(puuid);
        try {
          return await body();
        } finally {
          await _release(puuid);
        }
      });

  Future<void> _acquire(String puuid) async {
    final key = _key(puuid);
    final deadline = DateTime.now().add(maxWait);
    while (true) {
      String? value;
      try {
        value = await _prefs.getString(key);
      } on Object {
        return; // Storage unavailable: proceed without the lock.
      }
      if (_isFree(value)) {
        try {
          await _prefs.setString(
            key,
            '$_owner|${DateTime.now().millisecondsSinceEpoch}',
          );
          await Future<void>.delayed(const Duration(milliseconds: 30));
          final confirm = await _prefs.getString(key);
          if (confirm != null && confirm.startsWith('$_owner|')) return;
        } on Object {
          return;
        }
      }
      if (DateTime.now().isAfter(deadline)) return;
      await Future<void>.delayed(const Duration(milliseconds: 400));
    }
  }

  bool _isFree(String? value) {
    if (value == null) return true;
    final parts = value.split('|');
    if (parts.length != 2) return true;
    if (parts[0] == _owner) return true;
    final ms = int.tryParse(parts[1]);
    if (ms == null) return true;
    final age = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(ms),
    );
    return age > staleAfter || age.isNegative;
  }

  Future<void> _release(String puuid) async {
    try {
      final key = _key(puuid);
      final value = await _prefs.getString(key);
      if (value != null && value.startsWith('$_owner|')) {
        await _prefs.remove(key);
      }
    } on Object {
      // Stale locks expire on their own.
    }
  }
}
