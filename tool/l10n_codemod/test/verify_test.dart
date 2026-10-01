import 'package:l10n_codemod/src/verify.dart';
import 'package:test/test.dart';

void main() {
  test('test parity and member aliases do not prevent production cutover', () {
    final result = verificationReport({
      'refs': [
        {'file': 'test/l10n/vi_parity_test.dart', 'cat': 'test'},
        {'file': 'lib/core/l10n/common_strings.dart', 'cat': 'strings'},
      ],
    });
    expect(result['readyForCutover'], true);
    expect(result['remainingReferences'], 0);
  });
  test('reports real remaining work by layer, and cannot label it ready', () {
    final result = verificationReport({
      'refs': [
        {'file': 'lib/core/domain/model.dart', 'cat': 'core-other'},
        {'file': 'lib/features/store/ui/store.dart', 'cat': 'feature-ui'},
      ],
      'viLiterals': [
        {'file': 'lib/core/notifications/service.dart', 'value': 'Xin chào'},
      ],
    });
    expect(result['remainingReferences'], 2);
    expect(result['remainingVietnameseLiterals'], 1);
    expect(result['byLayer'], {'core-other': 1, 'feature-ui': 1});
    expect(result['readyForCutover'], false);
  });
  test(
    'unresolved code or an unknown facade fails even with no known refs',
    () {
      expect(
        verificationReport({
          'analysisErrors': [
            {'message': 'unresolved'},
          ],
        })['readyForCutover'],
        false,
      );
      expect(
        verificationReport({
          'unknownStringsClasses': {'UnexpectedStrings': 'some.dart'},
        })['readyForCutover'],
        false,
      );
    },
  );
}
