import '../../../helpers/l10n.dart';

import 'package:valvn/features/community/ui/community_error.dart';
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
        describeCommunityError(tl, error).message,
        CommunityStrings.errorInvalid,
      );
      expect(describeCommunityError(tl, error).canRetry, isFalse);
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
      final description = describeCommunityError(tl, error);
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
    expect(describeCommunityError(tl, error).canRetry, isTrue);
    expect(
      describeCommunityError(tl, error).message,
      CommunityStrings.errorRateLimitedIn('2 phút'),
    );
  });

  test('a known reason wins over the code that carries it', () {
    final notOwned = CommunityException.fromResponse(403, {
      'error': {
        'code': 'forbidden',
        'reason': 'skin_not_owned',
        'message': 'x',
      },
    });
    expect(
      describeCommunityError(tl, notOwned).message,
      tl.communityReviewOwnershipRequired,
      reason: 'not the Community Guidelines refusal',
    );
    final quota = CommunityException.fromResponse(400, {
      'error': {
        'code': 'invalid_input',
        'reason': 'quota_exceeded',
        'params': {'maxMb': 50},
      },
    });
    expect(
      describeCommunityError(tl, quota).message,
      tl.communityErrorImageQuota,
    );
    expect(describeCommunityError(tl, quota).canRetry, isFalse);
    final forbidden = CommunityException.fromResponse(403, {
      'error': {'code': 'forbidden'},
    });
    expect(
      describeCommunityError(tl, forbidden).message,
      tl.communityErrorForbidden,
    );
  });
}
