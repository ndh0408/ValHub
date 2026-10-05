import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/ui/error_view.dart';
import 'package:valvn/features/settings/providers/server_status_provider.dart';
import 'package:valvn/features/settings/ui/server_status_screen.dart';

import '../../../helpers/l10n.dart';
import '../../../helpers/test_prefs.dart';
import '../settings_fakes.dart';

void main() {
  testWidgets('initial unavailable status cannot display a healthy summary', (
    tester,
  ) async {
    final env = SettingsTestEnv(await createTestPrefs());
    await seedAccounts(env.prefs, [testAccount(1)]);
    var failed = true;
    when(() => env.api.platformStatus('ap')).thenAnswer((_) async {
      if (failed) throw const TransientException(reason: 'content_unavailable');
      return {'maintenances': <Object?>[], 'incidents': <Object?>[]};
    });
    final container = ProviderContainer(overrides: env.overrides);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testL10nApp(const ServerStatusScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(tl.settingsStatusAllGood), findsNothing);
    expect(find.text(tl.commonErrorContentUnavailable), findsOneWidget);
    expect(find.byType(ErrorView), findsOneWidget);

    failed = false;
    await tester.tap(find.text(tl.commonRetry));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorView), findsNothing);
    expect(find.text(tl.settingsStatusAllGood), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed refresh preserves cached status and exposes retry', (
    tester,
  ) async {
    final env = SettingsTestEnv(await createTestPrefs());
    await seedAccounts(env.prefs, [testAccount(1)]);
    var failed = false;
    when(() => env.api.platformStatus('ap')).thenAnswer((_) async {
      if (failed) throw const TransientException(reason: 'network');
      return {'maintenances': <Object?>[], 'incidents': <Object?>[]};
    });
    final container = ProviderContainer(overrides: env.overrides);
    addTearDown(container.dispose);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testL10nApp(const ServerStatusScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text(tl.settingsStatusAllGood), findsOneWidget);

    failed = true;
    container.invalidate(serverStatusProvider('ap'));
    await tester.pumpAndSettle();
    expect(find.text(tl.settingsStatusAllGood), findsOneWidget);
    expect(find.byType(ErrorView), findsOneWidget);
    expect(find.text(tl.commonRetry), findsOneWidget);

    failed = false;
    await tester.tap(find.text(tl.commonRetry));
    await tester.pumpAndSettle();
    expect(find.byType(ErrorView), findsNothing);
    expect(find.text(tl.settingsStatusAllGood), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
