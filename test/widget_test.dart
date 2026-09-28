import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/app/app.dart';
import 'package:valvn/core/l10n/auth_strings.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/features/settings/ui/welcome_screen.dart';

import 'helpers/test_prefs.dart';

/// Smoke test: the whole app boots signed-out on the Vietnamese welcome
/// screen.
void main() {
  testWidgets('app boots to the welcome screen when signed out', (
    tester,
  ) async {
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
    expect(find.byType(WelcomeScreen), findsOneWidget);
    expect(find.text(AuthStrings.signInCta), findsOneWidget);
  });
}
