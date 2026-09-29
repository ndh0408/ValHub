import 'package:flutter/services.dart' show MethodCall, SystemChannels;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/features/settings/settings_strings.dart';
import 'package:valvn/features/settings/ui/session_log_screen.dart';

import '../../../helpers/test_prefs.dart';
import '../settings_fakes.dart';

void main() {
  late SettingsTestEnv env;

  setUp(() async {
    env = SettingsTestEnv(await createTestPrefs());
  });

  Widget harness(SessionLog log) => ProviderScope(
    overrides: [
      ...(env..log = log).overrides,
      clockProvider.overrideWithValue(FixedClock(DateTime(2026, 9, 28, 15))),
    ],
    child: const MaterialApp(home: SessionLogScreen()),
  );

  SessionLog logWithEntries() {
    final log = SessionLog(clock: FixedClock(DateTime(2026, 9, 28, 14, 5, 9)));
    log.add(
      'http',
      uri: Uri.parse(
        'https://pd.ap.a.pvp.net/store/v3/storefront/11111111-1111-1111-1111-111111111111',
      ),
      status: 200,
      elapsed: const Duration(milliseconds: 120),
    );
    log.add('reauth.ok', status: 503);
    return log;
  }

  testWidgets('an empty log shows the empty state and disables actions', (
    tester,
  ) async {
    await tester.pumpWidget(harness(SessionLog()));
    await tester.pumpAndSettle();

    expect(find.text(SettingsStrings.exportLogEmpty), findsOneWidget);
    expect(find.text(CommonStrings.share), findsNothing);
    expect(find.text(CommonStrings.copy), findsNothing);
    expect(find.byTooltip(SettingsStrings.clearLog), findsNothing);
  });

  testWidgets('entries render newest first, scrubbed, under a day header', (
    tester,
  ) async {
    await tester.pumpWidget(harness(logWithEntries()));
    await tester.pumpAndSettle();

    expect(find.text(SettingsStrings.exportLogNote), findsOneWidget);
    expect(find.text(SettingsStrings.logEntryCount(2)), findsOneWidget);
    expect(find.text(CommonStrings.today.toUpperCase()), findsOneWidget);
    expect(find.text('reauth.ok'), findsOneWidget);
    expect(find.text('503'), findsOneWidget);
    expect(find.text('120 ms'), findsOneWidget);
    expect(
      find.text('pd.ap.a.pvp.net/store/v3/storefront/{id}'),
      findsOneWidget,
    );
    // No raw PUUID/UUID ever reaches the screen.
    expect(
      find.textContaining('11111111-1111-1111-1111-111111111111'),
      findsNothing,
    );

    final newest = tester.getTopLeft(find.text('reauth.ok')).dy;
    final older = tester.getTopLeft(find.text('http')).dy;
    expect(newest, lessThan(older), reason: 'newest entry listed first');
  });

  testWidgets('copy puts the export (with header) on the clipboard', (
    tester,
  ) async {
    String? clip;
    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'Clipboard.setData') {
          final args = call.arguments as Map<Object?, Object?>;
          clip = args['text'] as String?;
        }
        return null;
      },
    );
    addTearDown(
      () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        null,
      ),
    );
    await tester.pumpWidget(harness(logWithEntries()));
    await tester.pumpAndSettle();

    await tester.tap(find.text(CommonStrings.copy));
    await tester.pumpAndSettle();

    expect(find.text(CommonStrings.copied), findsOneWidget);
    expect(clip, contains('reauth.ok'));
    expect(
      clip,
      startsWith(SettingsStrings.logFileHeader(CommonStrings.appName, '1.2.3')),
    );
    await tester.pump(const Duration(seconds: 5));
  });

  testWidgets('share hands the export to the share sheet', (tester) async {
    await tester.pumpWidget(harness(logWithEntries()));
    await tester.pumpAndSettle();

    await tester.tap(find.text(CommonStrings.share));
    await tester.pumpAndSettle();

    expect(env.shared, hasLength(1));
    expect(env.shared.single, contains('storefront/{id}'));
    expect(env.shared.single, isNot(contains('11111111-1111')));
    expect(env.lastShareOrigin, isNotNull);
  });

  testWidgets('clearing asks for confirmation, then empties the log', (
    tester,
  ) async {
    final log = logWithEntries();
    await tester.pumpWidget(harness(log));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip(SettingsStrings.clearLog));
    await tester.pumpAndSettle();
    expect(find.text(SettingsStrings.clearLogConfirm), findsOneWidget);
    await tester.tap(find.text(CommonStrings.cancel));
    await tester.pumpAndSettle();
    expect(log.entries, hasLength(2));

    await tester.tap(find.byTooltip(SettingsStrings.clearLog));
    await tester.pumpAndSettle();
    await tester.tap(find.text(CommonStrings.delete));
    await tester.pumpAndSettle();

    expect(log.entries, isEmpty);
    expect(find.text(SettingsStrings.exportLogEmpty), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
  });
}
