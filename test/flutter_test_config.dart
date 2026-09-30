import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'helpers/l10n.dart';

/// Runs around every test file (docs/design/I18N.md 12.1).
///
/// - `intl` data for all locales, once per isolate;
/// - pins the DEVICE locale to `vi` (or `--dart-define=TEST_LOCALE=<x>`). The
///   default test platform locale is `en_US`, which would silently flip every
///   widget test that follows the device to English once more languages ship.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();
  setUpL10nTests();
  await testMain();
}
