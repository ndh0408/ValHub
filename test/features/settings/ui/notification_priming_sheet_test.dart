import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/features/settings/settings_strings.dart';
import 'package:valvn/features/settings/ui/notification_priming_sheet.dart';

import '../settings_fakes.dart';

void main() {
  late FakeNotificationService service;

  setUp(() => service = FakeNotificationService());

  /// Pumps a button that runs the priming flow; the outcome lands in
  /// [results].
  Future<List<Object?>> pumpLauncher(
    WidgetTester tester, {
    bool detailed = false,
  }) async {
    final results = <Object?>[];
    await tester.pumpWidget(
      ProviderScope(
        overrides: [notificationServiceProvider.overrideWithValue(service)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => unawaited(
                  (detailed
                          ? runNotificationPriming(context)
                          : showNotificationPrimingSheet(context))
                      .then(results.add),
                ),
                child: const Text('OPEN'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('OPEN'));
    await tester.pumpAndSettle();
    return results;
  }

  testWidgets('explains, then requests the permission on "Bật thông báo"', (
    tester,
  ) async {
    final results = await pumpLauncher(tester);

    expect(find.text(SettingsStrings.primingBody), findsOneWidget);
    expect(find.text(SettingsStrings.primingPointWishlist), findsOneWidget);
    await tester.tap(
      find.widgetWithText(FilledButton, SettingsStrings.primingEnable),
    );
    await tester.pumpAndSettle();

    expect(service.permissionRequests, 1);
    expect(results, [true]);
    expect(find.text(SettingsStrings.primingBody), findsNothing);
  });

  testWidgets('"Để sau" never prompts the OS', (tester) async {
    final results = await pumpLauncher(tester, detailed: true);

    await tester.tap(find.text(SettingsStrings.primingLater));
    await tester.pumpAndSettle();

    expect(service.permissionRequests, 0);
    expect(results, [NotificationPrimingResult.dismissed]);
  });

  testWidgets('an OS refusal is reported as denied', (tester) async {
    service.grantOnRequest = false;
    final results = await pumpLauncher(tester, detailed: true);

    await tester.tap(
      find.widgetWithText(FilledButton, SettingsStrings.primingEnable),
    );
    await tester.pumpAndSettle();

    expect(results, [NotificationPrimingResult.denied]);
  });

  testWidgets('skips the sheet when notifications are already allowed', (
    tester,
  ) async {
    service.enabled = true;
    final results = await pumpLauncher(tester);

    expect(find.text(SettingsStrings.primingBody), findsNothing);
    expect(service.permissionRequests, 0);
    expect(results, [true]);
  });
}
