import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'error_classifier.dart';
import 'riot_exception.dart';

/// Whether the device reached the network on its last try. Every dio of the
/// app reports here ([ReachabilityInterceptor]): any answer, even an error
/// status, means the network works; only a request that got no answer at
/// all (no connection, no DNS, the connection never opened) means it does
/// not. Starts optimistic: nothing is claimed before a request failed, and
/// one host being down is not "no network" while others answered within
/// [answerGrace].
class NetworkReachability extends ValueNotifier<bool> {
  NetworkReachability({DateTime Function()? now})
    : _now = now ?? DateTime.now,
      super(true);

  /// The app-wide instance (each isolate has its own).
  static final instance = NetworkReachability();

  static const answerGrace = Duration(seconds: 10);

  final DateTime Function() _now;
  DateTime? _lastAnswer;

  void reached() {
    _lastAnswer = _now();
    value = true;
  }

  void unreachable() {
    final last = _lastAnswer;
    if (last != null && _now().difference(last) < answerGrace) return;
    value = false;
  }
}

/// Feeds [NetworkReachability] from the requests of one dio.
class ReachabilityInterceptor extends Interceptor {
  ReachabilityInterceptor([NetworkReachability? reachability])
    : _reachability = reachability ?? NetworkReachability.instance;

  final NetworkReachability _reachability;

  @override
  void onResponse(
    Response<dynamic> response,
    ResponseInterceptorHandler handler,
  ) {
    _reachability.reached();
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      _reachability.reached();
    } else if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      _reachability.unreachable();
    }
    handler.next(err);
  }
}

/// Whether [error] is a request that found no network or timed out.
bool isNetworkError(Object error) {
  final e = classifyError(error);
  return e is TransientException &&
      (e.reason == 'network' || e.reason == 'timeout');
}

/// The [NetworkReachability] the UI listens to (overridable in tests).
final networkReachabilityProvider = Provider<NetworkReachability>(
  (ref) => NetworkReachability.instance,
);

/// `false` while the last request found no network.
final networkOnlineProvider = NotifierProvider<NetworkOnlineNotifier, bool>(
  NetworkOnlineNotifier.new,
);

class NetworkOnlineNotifier extends Notifier<bool> {
  @override
  bool build() {
    final source = ref.watch(networkReachabilityProvider);
    void sync() {
      if (ref.mounted) state = source.value;
    }

    source.addListener(sync);
    ref.onDispose(() => source.removeListener(sync));
    return source.value;
  }
}
