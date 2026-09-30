import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// The start-up order of docs/design/I18N.md 6.4 in `lib/main.dart`.
///
/// It is a source-order check because the failure is silent: if the install
/// marker were written BEFORE `L10nBootstrap.load`, every fresh install would
/// look like an upgrade and be pinned to Vietnamese, defeating "follow the
/// device" as soon as a second language ships.
void main() {
  final main = File('lib/main.dart').readAsStringSync();

  int at(String needle) {
    final i = main.indexOf(needle);
    expect(
      i,
      isNonNegative,
      reason: 'lib/main.dart no longer contains $needle',
    );
    return i;
  }

  test('preferences, language, intl, time zone, then the secrets wipe', () {
    final order = [
      at('Prefs.create()'),
      at('L10nBootstrap.load('),
      at('initIntl(boot.formatTag)'),
      at('initTimeZone()'),
      // The call, not the declaration further down.
      at('_wipeSecretsAfterReinstall(prefs, secureStore)'),
    ];
    expect(order, [...order]..sort(), reason: 'start-up order changed');
  });

  test('the boot value reaches the providers', () {
    at('l10nBootProvider.overrideWithValue(boot)');
  });

  test(
    'the install marker is only written by the wipe, after the language',
    () {
      final marker = 'PrefKeys.installMarker';
      final writes = marker.allMatches(main).length;
      // One read and one write inside _wipeSecretsAfterReinstall.
      expect(writes, 2);
      expect(at(marker), greaterThan(at('L10nBootstrap.load(')));
    },
  );
}
