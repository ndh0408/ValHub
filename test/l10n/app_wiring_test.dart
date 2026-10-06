import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:valvn/app/app.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/formats.dart';
import 'package:valvn/core/l10n/locale_controller.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/features/settings/ui/welcome_screen.dart';

import '../helpers/test_prefs.dart';

class _ControlledLocalePrefs extends Prefs {
  _ControlledLocalePrefs(super.prefs, {this.failFirst = false});
  final bool failFirst;
  final releaseFirst = Completer<void>();
  final snapshots = <Map<String, Object?>>[];

  @override
  Future<void> setJson(String key, Object? value) async {
    if (key == PrefKeys.effectiveLocale) {
      snapshots.add(Map<String, Object?>.from(value! as Map));
      if (snapshots.length == 1) {
        await releaseFirst.future;
        if (failFirst) throw StateError('simulated preferences failure');
      }
    }
    await super.setJson(key, value);
  }
}

/// The real root app: reactive locale/format wiring keeps the shipped filter.
void main() {
  Future<BuildContext> pumpApp(
    WidgetTester tester, {
    Prefs? prefs,
    SessionLog? log,
    List<Override> overrides = const [],
  }) async {
    prefs ??= await createTestPrefs();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          secureStoreProvider.overrideWithValue(MemorySecureStore()),
          sessionLogProvider.overrideWithValue(log ?? SessionLog()),
          notificationServiceProvider.overrideWithValue(
            NotificationService(prefs: prefs),
          ),
          ...overrides,
        ],
        child: const ValVnApp(),
      ),
    );
    await tester.pumpAndSettle();
    return tester.element(find.byType(WelcomeScreen));
  }

  testWidgets('MaterialApp uses appLocalizationsDelegates, all 18 languages', (
    tester,
  ) async {
    await pumpApp(tester);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.localizationsDelegates, same(appLocalizationsDelegates));
    // The tests pin a Vietnamese device.
    expect(app.locale, const Locale('vi'));
    expect(app.supportedLocales.toSet(), {
      for (final l in AppLocale.values) l.flutter,
    });
  });

  testWidgets('AppLocalizations and material_ui resolve in the app tree', (
    tester,
  ) async {
    final context = await pumpApp(tester);
    expect(Localizations.localeOf(context), const Locale('vi'));
    expect(context.l10n.localeName, 'vi');
    // material_ui's Vietnamese, not its English default.
    expect(MaterialLocalizations.of(context).backButtonTooltip, isNot('Back'));
  });

  testWidgets('context.fmt formats in Vietnamese through the root scope', (
    tester,
  ) async {
    final context = await pumpApp(tester);
    final fmt = context.fmt;
    expect(fmt.locale, AppLocale.vi);
    expect(fmt.time(DateTime(2026, 1, 1, 7)), '07:00');
    expect(fmt.date(DateTime(2026, 9, 22)), '22/09/2026');
    expect(fmt.number(1162500), '1.162.500');
    expect(AppFormatsScope.maybeOf(context), isNotNull);
  });

  testWidgets('initial handoff preserves English item names with vi UI', (
    tester,
  ) async {
    final prefs = await createTestPrefs();
    await prefs.setJson(
      PrefKeys.appSettings,
      const AppSettings(itemLanguage: ItemLanguage.en).toJson(),
    );
    final context = await pumpApp(tester, prefs: prefs);
    final snapshot = EffectiveLocale.read(prefs)!;
    expect(snapshot.app, AppLocale.vi);
    expect(snapshot.content, 'en-US');
    expect(Localizations.localeOf(context), const Locale('vi'));
    // Root wiring does not override the user's persisted language choice.
    expect(prefs.getString(PrefKeys.appLocale), isNull);
  });

  testWidgets('root formats also reach dialogs above feature pages', (
    tester,
  ) async {
    final formats = AppFormats.create(AppLocale.de, 'de_AT', h24: true);
    final context = await pumpApp(
      tester,
      overrides: [formatsProvider.overrideWithValue(formats)],
    );
    AppFormats? dialogFormats;
    unawaited(
      showDialog<void>(
        context: context,
        builder: (context) {
          dialogFormats = context.fmt;
          return AlertDialog(content: Text(context.fmt.number(1234.5)));
        },
      ),
    );
    await tester.pumpAndSettle();
    expect(dialogFormats, same(formats));
    // CLDR de_AT uses a nonbreaking space as its grouping separator.
    expect(find.text('1\u00a0234,5'), findsOneWidget);
    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pumpAndSettle();
  });

  for (final failFirst in [false, true]) {
    testWidgets(
      failFirst
          ? 'a failed snapshot does not prevent persisting the latest choice'
          : 'slow initial write cannot overwrite a newer content/clock choice',
      (tester) async {
        await createTestPrefs();
        final prefs = _ControlledLocalePrefs(
          await SharedPreferencesWithCache.create(
            cacheOptions: const SharedPreferencesWithCacheOptions(),
          ),
          failFirst: failFirst,
        );
        addTearDown(() {
          if (!prefs.releaseFirst.isCompleted) prefs.releaseFirst.complete();
        });
        final log = SessionLog();
        final dispatcher = tester.binding.platformDispatcher;
        dispatcher.alwaysUse24HourFormatTestValue = false;
        addTearDown(dispatcher.clearAlwaysUse24HourTestValue);
        final context = await pumpApp(tester, prefs: prefs, log: log);
        final container = ProviderScope.containerOf(context);
        await container
            .read(appSettingsProvider.notifier)
            .setItemLanguage(ItemLanguage.en);
        dispatcher.alwaysUse24HourFormatTestValue = true;
        dispatcher.onMetricsChanged?.call();
        await tester.pumpAndSettle();
        expect(prefs.snapshots, hasLength(1));
        expect(EffectiveLocale.read(prefs), isNull);
        prefs.releaseFirst.complete();
        await tester.pumpAndSettle();
        final stored = EffectiveLocale.read(prefs)!;
        expect(stored.app, AppLocale.vi);
        expect(stored.content, 'en-US');
        expect(stored.h24, isTrue);
        expect(context.fmt.h24, isTrue);
        expect(tester.takeException(), isNull);
        final failures = log.entries.where(
          (e) => e.event == 'l10n.persist.failed',
        );
        expect(failures, hasLength(failFirst ? 1 : 0));
        if (failFirst) expect(failures.single.detail, 'StateError');
      },
    );
  }
}
