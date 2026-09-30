import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/app/app.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/features/settings/ui/welcome_screen.dart';

import '../helpers/test_prefs.dart';

/// The real `ValVnApp` (wave W0): the i18n foundation is wired next to the old
/// `appLocale`, and the app still resolves to Vietnamese.
void main() {
  Future<BuildContext> pumpApp(WidgetTester tester) async {
    final prefs = await createTestPrefs();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          secureStoreProvider.overrideWithValue(MemorySecureStore()),
          sessionLogProvider.overrideWithValue(SessionLog()),
          notificationServiceProvider.overrideWithValue(
            NotificationService(prefs: prefs),
          ),
        ],
        child: const ValVnApp(),
      ),
    );
    await tester.pumpAndSettle();
    return tester.element(find.byType(WelcomeScreen));
  }

  testWidgets('MaterialApp uses appLocalizationsDelegates and stays vi', (
    tester,
  ) async {
    await pumpApp(tester);
    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.localizationsDelegates, same(appLocalizationsDelegates));
    expect(app.locale, const Locale('vi'));
    expect(app.supportedLocales, [const Locale('vi')]);
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

  testWidgets('context.fmt formats in Vietnamese without a scope', (
    tester,
  ) async {
    final context = await pumpApp(tester);
    final fmt = context.fmt;
    expect(fmt.locale, AppLocale.vi);
    expect(fmt.time(DateTime(2026, 1, 1, 7)), '07:00');
    expect(fmt.date(DateTime(2026, 9, 22)), '22/09/2026');
    expect(fmt.number(1162500), '1.162.500');
  });
}
