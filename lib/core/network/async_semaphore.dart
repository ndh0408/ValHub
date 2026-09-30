import 'dart:async';
import 'dart:collection';

/// Counting semaphore for async work: at most [permits] bodies run at once,
/// the rest wait in FIFO order.
///
/// Used to cap simultaneous silent re-auths (SUMMARY §3.4: parallel rounds on
/// `auth.riotgames.com` are what Cloudflare notices), whatever the number of
/// accounts that need one.
class AsyncSemaphore {
  AsyncSemaphore(this.permits) : assert(permits > 0);

  final int permits;
  int _inUse = 0;
  final Queue<Completer<void>> _waiters = Queue();

  /// Bodies currently running.
  int get running => _inUse;

  /// Bodies waiting for a permit.
  int get waiting => _waiters.length;

  /// Runs [body] once a permit is free and releases it afterwards, whether
  /// [body] completes or throws.
  Future<T> run<T>(Future<T> Function() body) async {
    await _acquire();
    try {
      return await body();
    } finally {
      _release();
    }
  }

  Future<void> _acquire() {
    if (_inUse < permits) {
      _inUse++;
      return Future<void>.value();
    }
    final waiter = Completer<void>();
    _waiters.add(waiter);
    return waiter.future;
  }

  void _release() {
    if (_waiters.isNotEmpty) {
      // The permit passes straight to the next waiter.
      _waiters.removeFirst().complete();
    } else {
      _inUse--;
    }
  }
}
