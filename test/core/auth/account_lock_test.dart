import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valvn/core/auth/account_lock.dart';
import 'package:valvn/core/network/riot_exception.dart';

import '../../helpers/test_prefs.dart';

void main() {
  setUp(() async => createTestPrefs());

  PrefsAccountLock lock({Duration maxWait = const Duration(seconds: 2)}) =>
      PrefsAccountLock(
        prefs: SharedPreferencesAsync(),
        heartbeat: const Duration(milliseconds: 100),
        staleAfter: const Duration(milliseconds: 400),
        maxWait: maxWait,
      );

  test('a waiter never runs in parallel: heartbeat beats staleAfter', () async {
    final a = lock();
    final b = lock();
    final release = Completer<void>();
    var running = 0;
    var maxRunning = 0;
    Future<void> body() async {
      running++;
      maxRunning = running > maxRunning ? running : maxRunning;
      await release.future;
      running--;
    }

    final first = a.run('p', body);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    final second = b.run('p', () async {
      running++;
      maxRunning = running > maxRunning ? running : maxRunning;
      running--;
    });
    // Holder runs well past staleAfter.
    await Future<void>.delayed(const Duration(milliseconds: 1000));
    expect(maxRunning, 1);
    release.complete();
    await Future.wait([first, second]);
    expect(maxRunning, 1);
  });

  test('maxWait expiry throws lock_timeout instead of running', () async {
    final a = lock();
    final b = lock(maxWait: const Duration(milliseconds: 500));
    final release = Completer<void>();
    final first = a.run('p', () => release.future);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    var ran = false;
    await expectLater(
      b.run('p', () async => ran = true),
      throwsA(
        isA<TransientException>().having(
          (e) => e.reason,
          'reason',
          'lock_timeout',
        ),
      ),
    );
    expect(ran, isFalse);
    release.complete();
    await first;
  });
}
