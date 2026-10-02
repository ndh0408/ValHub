import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/locale_boot.dart';
import 'package:valvn/core/l10n/locale_controller.dart';
import 'package:valvn/core/storage/prefs.dart';

import '../helpers/test_prefs.dart';

class _ControlledPrefs extends Prefs {
  _ControlledPrefs(super.prefs, {this.failFirst = false});
  final bool failFirst;
  final gate = Completer<void>();
  final choices = <String>[];
  @override
  Future<void> setString(String key, String value) async {
    if (key == PrefKeys.appLocale) {
      choices.add(value);
      if (choices.length == 1) {
        await gate.future;
        if (failFirst) throw StateError('synthetic write failure');
      }
    }
    await super.setString(key, value);
  }
}

void main() {
  Future<_ControlledPrefs> make({bool fail = false}) async {
    await createTestPrefs();
    final prefs = _ControlledPrefs(
      await SharedPreferencesWithCache.create(
        cacheOptions: const SharedPreferencesWithCacheOptions(),
      ),
      failFirst: fail,
    );
    addTearDown(() {
      if (!prefs.gate.isCompleted) prefs.gate.complete();
    });
    return prefs;
  }

  test('rapid language choices persist in selection order', () async {
    final prefs = await make();
    final container = ProviderContainer(
      overrides: [prefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final controller = container.read(localeControllerProvider.notifier);
    final first = controller.set(const LocaleChoice.fixed(AppLocale.vi));
    final last = controller.set(const LocaleChoice.system());
    await Future<void>.delayed(Duration.zero);
    expect(prefs.choices, ['vi-VN']);
    prefs.gate.complete();
    await Future.wait([first, last]);
    expect(prefs.choices, ['vi-VN', 'system']);
    expect(prefs.getString(PrefKeys.appLocale), 'system');
    expect(
      container.read(localeControllerProvider),
      const LocaleChoice.system(),
    );
  });

  test(
    'failed choice restores the committed state and permits a retry',
    () async {
      final prefs = await make(fail: true);
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final controller = container.read(localeControllerProvider.notifier);
      prefs.gate.complete();
      await expectLater(
        controller.set(const LocaleChoice.fixed(AppLocale.vi)),
        throwsStateError,
      );
      expect(
        container.read(localeControllerProvider),
        const LocaleChoice.system(),
      );
      await controller.set(const LocaleChoice.fixed(AppLocale.vi));
      expect(
        container.read(localeControllerProvider),
        const LocaleChoice.fixed(AppLocale.vi),
      );
      expect(prefs.getString(PrefKeys.appLocale), 'vi-VN');
    },
  );

  for (final fail in [false, true]) {
    test(
      'pending choice after disposal does not access widget/provider state: $fail',
      () async {
        final prefs = await make(fail: fail);
        final container = ProviderContainer(
          overrides: [prefsProvider.overrideWithValue(prefs)],
        );
        final controller = container.read(localeControllerProvider.notifier);
        final done = controller.set(const LocaleChoice.fixed(AppLocale.vi));
        final result = fail ? expectLater(done, throwsStateError) : done;
        container.dispose();
        prefs.gate.complete();
        await result;
        if (!fail) expect(prefs.getString(PrefKeys.appLocale), 'vi-VN');
      },
    );
  }
}
