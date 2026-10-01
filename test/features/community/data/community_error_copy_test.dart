import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/l10n/community_error_strings.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_exception.dart';

void main() {
  test('legacy, unknown and malformed reasons never expose response text', () {
    for (final reason in [
      null,
      'unknown_reason',
      {'reason': 'content_scam'},
    ]) {
      final error = CommunityException.fromResponse(400, {
        'error': {
          'code': 'invalid_input',
          'reason': reason,
          'message': 'HTTP 400 body must be JSON token=secret /v1/posts',
          'params': {'field': 'accessToken', 'max': '<script>'},
        },
      });
      expect(
        describeCommunityError(error).message,
        CommunityStrings.errorInvalid,
      );
      expect(describeCommunityError(error).canRetry, isFalse);
    }
  });

  test('moderation and sanctions use local copy without unsafe parameters', () {
    for (final reason in [
      'content_inappropriate',
      'content_scam',
      'content_too_complex',
      'account_banned',
      'account_restricted',
    ]) {
      final sanction = reason.startsWith('account_');
      final error = CommunityException.fromResponse(sanction ? 403 : 400, {
        'error': {
          'code': sanction ? 'suspended' : 'invalid_input',
          'reason': reason,
          'message': 'secret',
          'params': {'field': 'secret'},
        },
      });
      final description = describeCommunityError(error);
      expect(description.message, CommunityErrorStrings.forReason(reason));
      expect(description.message, isNot(contains('secret')));
      expect(description.canRetry, isFalse);
    }
  });

  test('busy server preserves retry action and friendly waiting time', () {
    final error = CommunityException.fromResponse(503, {
      'error': {
        'code': 'server_busy',
        'reason': 'server_busy',
        'retryAfter': 120,
      },
    });
    expect(error.isRetryable, isTrue);
    expect(describeCommunityError(error).canRetry, isTrue);
    expect(
      describeCommunityError(error).message,
      CommunityStrings.errorRateLimitedIn('2 phút'),
    );
  });
}
