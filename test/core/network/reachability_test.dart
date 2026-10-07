import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/network/reachability.dart';
import 'package:valvn/core/network/riot_exception.dart';

class _Adapter implements HttpClientAdapter {
  DioExceptionType? fail;
  int status = 200;

  @override
  Future<ResponseBody> fetch(
    RequestOptions o,
    Stream<List<int>>? s,
    Future<void>? c,
  ) async {
    final type = fail;
    if (type != null) throw DioException(requestOptions: o, type: type);
    return ResponseBody.fromString('{}', status);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  var now = DateTime.utc(2026, 10, 7, 12);
  late NetworkReachability reach;
  late _Adapter adapter;
  late Dio dio;

  setUp(() {
    now = DateTime.utc(2026, 10, 7, 12);
    reach = NetworkReachability(now: () => now);
    adapter = _Adapter();
    dio = Dio()
      ..httpClientAdapter = adapter
      ..interceptors.add(ReachabilityInterceptor(reach));
  });

  Future<void> get() => dio
      .get<String>('https://pd.ap.a.pvp.net/x')
      .then((_) {}, onError: (_) {});

  test('no answer at all means offline; any answer means online', () async {
    adapter.fail = DioExceptionType.connectionError;
    await get();
    expect(reach.value, isFalse);

    // An error status is still an answer.
    adapter
      ..fail = null
      ..status = 503;
    await get();
    expect(reach.value, isTrue);
  });

  test('one host failing right after an answer is not "offline"', () async {
    await get();
    now = now.add(const Duration(seconds: 3));
    adapter.fail = DioExceptionType.connectionError;
    await get();
    expect(reach.value, isTrue);
    now = now.add(NetworkReachability.answerGrace);
    await get();
    expect(reach.value, isFalse);
  });

  test('a slow answer or a cancel says nothing about the network', () async {
    adapter.fail = DioExceptionType.receiveTimeout;
    await get();
    adapter.fail = DioExceptionType.cancel;
    await get();
    expect(reach.value, isTrue);
  });

  test('network errors are told apart from the others', () {
    expect(isNetworkError(const TransientException(reason: 'network')), isTrue);
    expect(isNetworkError(const TransientException(reason: 'timeout')), isTrue);
    expect(isNetworkError(const MaintenanceException()), isFalse);
    expect(isNetworkError(StateError('x')), isFalse);
  });
}
