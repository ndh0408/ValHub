import 'package:flutter_test/flutter_test.dart';

import '../../tool/l10n_check.dart';
import '../../tool/l10n_fmt.dart';

/// The real ARB files of the repository, judged by the tools
/// (docs/design/I18N.md 12.2 `arb_structure_test`). The tools themselves are
/// unit-tested in `l10n_check_test.dart` and `l10n_fmt_test.dart`.
void main() {
  test('every ARB file is canonical', () {
    final report = formatDirectory('lib/l10n/arb', write: false);
    expect(report.errors, isEmpty);
    expect(
      report.changed,
      isEmpty,
      reason: 'run `dart run tool/l10n_fmt.dart` and commit the result',
    );
  });

  test('l10n_check finds no error and no warning', () {
    final result = checkProject();
    expect(result.findings.map((f) => f.format()).toList(), isEmpty);
  });
}
