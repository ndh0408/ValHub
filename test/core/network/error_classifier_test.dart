import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/network/error_classifier.dart';
import 'package:valvn/core/network/retry_policy.dart';
import 'package:valvn/core/network/riot_exception.dart';

void main() {
  group('classifyHttpError', () {
    test('BAD_CLAIMS and 401 are auth failures', () {
      expect(
        isAuthFailure(400, {'httpStatus': 400, 'errorCode': 'BAD_CLAIMS'}),
        isTrue,
      );
      expect(isAuthFailure(400, '{"errorCode":"BAD_CLAIMS"}'), isTrue);
      expect(isAuthFailure(401, null), isTrue);
      expect(isAuthFailure(400, {'errorCode': 'BAD_PARAMETER'}), isFalse);
      expect(classifyHttpError(status: 401), isA<NeedsLoginException>());
    });

    test('maintenance', () {
      expect(
        classifyHttpError(
          status: 403,
          body: {'errorCode': 'SCHEDULED_DOWNTIME'},
        ),
        isA<MaintenanceException>(),
      );
    });

    test('Cloudflare HTML 403 is transient, not logged out', () {
      final e = classifyHttpError(
        status: 403,
        body: '<!DOCTYPE html><html><head><title>Just a moment...</title>',
        contentType: 'text/html; charset=UTF-8',
      );
      expect(e, isA<TransientException>());
      expect((e as TransientException).reason, 'cloudflare');
    });

    test('429 and 5xx are transient with Retry-After', () {
      final e = classifyHttpError(
        status: 429,
        retryAfterHeader: '30',
      ) as TransientException;
      expect(e.retryAfter, const Duration(seconds: 30));
      expect(classifyHttpError(status: 503), isA<TransientException>());
    });

    test('404 → NotFoundException, other 4xx → RiotApiException', () {
      final nf = classifyHttpError(
        status: 404,
        body: {'errorCode': 'RESOURCE_NOT_FOUND'},
      );
      expect((nf as NotFoundException).errorCode, 'RESOURCE_NOT_FOUND');
      final api = classifyHttpError(
        status: 400,
        body: {'errorCode': 'MATCH_HISTORY_INVALID_INDICES', 'message': 'x'},
      );
      expect(api, isA<RiotApiException>());
      expect(
        (api as RiotApiException).errorCode,
        'MATCH_HISTORY_INVALID_INDICES',
      );
    });
  });

  test('classifyError maps dio failures', () {
    final o = RequestOptions(path: '/');
    expect(
      classifyError(
        DioException(requestOptions: o, type: DioExceptionType.receiveTimeout),
      ),
      isA<TransientException>().having((e) => e.isTimeout, 'timeout', isTrue),
    );
    expect(
      classifyError(
        DioException(requestOptions: o, type: DioExceptionType.connectionError),
      ),
      isA<TransientException>(),
    );
    expect(
      classifyError(
        DioException(
          requestOptions: o,
          error: const NeedsLoginException(puuid: 'p'),
        ),
      ),
      isA<NeedsLoginException>(),
    );
    expect(
      classifyError(
        DioException(
          requestOptions: o,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: o, statusCode: 404),
        ),
      ),
      isA<NotFoundException>(),
    );
    expect(
      classifyError(const MaintenanceException()),
      isA<MaintenanceException>(),
    );
  });

  test('Retry-After parsing', () {
    expect(parseRetryAfter('120'), const Duration(seconds: 120));
    expect(parseRetryAfter('-5'), Duration.zero);
    expect(
      parseRetryAfter(
        'Wed, 21 Oct 2026 07:28:00 GMT',
        now: DateTime.utc(2026, 10, 21, 7, 27),
      ),
      const Duration(minutes: 1),
    );
    expect(parseRetryAfter('soon'), isNull);
    expect(parseRetryAfter(null), isNull);
  });

  test('backoff doubles and caps at 10 minutes', () {
    expect(backoffDelay(0), const Duration(seconds: 10));
    expect(backoffDelay(1), const Duration(seconds: 20));
    expect(backoffDelay(3), const Duration(seconds: 80));
    expect(backoffDelay(10), const Duration(minutes: 10));
    expect(backoffDelay(99), const Duration(minutes: 10));
  });

  test('Riverpod retry policy never retries logins, 4xx or bugs', () {
    expect(riotRetry(0, const NeedsLoginException()), isNull);
    expect(riotRetry(0, const MaintenanceException()), isNull);
    expect(riotRetry(0, const RiotApiException(400)), isNull);
    expect(riotRetry(0, const NotFoundException()), isNull);
    expect(riotRetry(0, StateError('bug')), isNull);
    expect(
      riotRetry(0, const TransientException()),
      const Duration(seconds: 2),
    );
    expect(
      riotRetry(1, const TransientException(retryAfter: Duration(seconds: 5))),
      const Duration(seconds: 5),
    );
    expect(
      riotRetry(0, const TransientException(retryAfter: Duration(minutes: 5))),
      isNull,
    );
    expect(riotRetry(3, const TransientException()), isNull);
  });

  test('orNullIfNotFound', () async {
    expect(
      await Future<int>.error(const NotFoundException()).orNullIfNotFound(),
      isNull,
    );
    expect(await Future.value(1).orNullIfNotFound(), 1);
    expect(
      () => Future<int>.error(const TransientException()).orNullIfNotFound(),
      throwsA(isA<TransientException>()),
    );
  });
}
