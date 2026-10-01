import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/geo/region_picker.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';

import '../../helpers/l10n.dart';
import '../../helpers/test_prefs.dart';

class _Sessions extends Mock implements SessionManager {}

class _PvpApi extends Mock implements PvpApi {}

const _account = Account(
  puuid: '00000000-0000-0000-0000-000000000001',
  gameName: 'Test',
  tagLine: 'VN',
  region: 'eu',
  shard: 'eu',
  regionMode: RegionMode.manual,
  manualRegion: 'eu',
  detectedRegion: 'ap',
);

void main() {
  setUpAll(() => registerFallbackValue(CancelToken()));
  late _PvpApi api;
  late ProviderContainer container;

  Future<void> pump(
    WidgetTester tester,
    RegionValidation result, {
    double scale = 1,
  }) async {
    final prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [_account.toJson()]);
    final sessions = _Sessions();
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
    api = _PvpApi();
    when(
      () => api.validateRegion(
        any(),
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    ).thenAnswer((_) async => result);
    container = ProviderContainer.test(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(MemorySecureStore()),
        sessionManagerProvider.overrideWithValue(sessions),
        pvpApiProvider.overrideWithValue(api),
      ],
    );
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: testL10nApp(
          Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showRegionPicker(context, _account),
                child: const Text('Open'),
              ),
            ),
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tester.ensureVisible(find.text(tl.settingsGeoSave));
    await tester.tap(find.text(tl.settingsGeoSave));
    await tester.pumpAndSettle();
  }

  testWidgets('manual mismatch requires consent before any candidate request', (
    tester,
  ) async {
    await pump(tester, RegionValidation.verified);
    await save(tester);
    verifyNever(
      () => api.validateRegion(
        any(),
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
    await tester.tap(
      find.widgetWithText(TextButton, tl.settingsGeoCancel).last,
    );
    await tester.pumpAndSettle();
    verifyNever(
      () => api.validateRegion(
        any(),
        any(),
        cancelToken: any(named: 'cancelToken'),
      ),
    );
    expect(
      container.read(accountProvider(_account.puuid))!.dismissedRegionMismatch,
      isNull,
    );
  });

  testWidgets(
    'verified manual choice is saved and exact mismatch acknowledged',
    (tester) async {
      await pump(tester, RegionValidation.verified);
      await save(tester);
      await tester.tap(
        find.widgetWithText(FilledButton, tl.settingsGeoContinue),
      );
      await tester.pumpAndSettle();
      verify(
        () => api.validateRegion(
          _account.puuid,
          'eu',
          cancelToken: any(named: 'cancelToken'),
        ),
      ).called(1);
      final account = container.read(accountProvider(_account.puuid))!;
      expect(account.region, 'eu');
      expect(account.dismissedRegionMismatch, 'eu/ap');
      expect(find.byType(RegionPicker), findsNothing);
    },
  );

  testWidgets('wrong shard never saves even after manual confirmation', (
    tester,
  ) async {
    await pump(tester, RegionValidation.rejected);
    await save(tester);
    await tester.tap(find.widgetWithText(FilledButton, tl.settingsGeoContinue));
    await tester.pumpAndSettle();
    expect(find.text(tl.settingsGeoValidationFailed), findsOneWidget);
    expect(
      container.read(accountProvider(_account.puuid))!.dismissedRegionMismatch,
      isNull,
    );
    expect(find.byType(RegionPicker), findsOneWidget);
  });

  testWidgets('unverified connection needs a separate explicit confirmation', (
    tester,
  ) async {
    await pump(tester, RegionValidation.unverified);
    await save(tester);
    await tester.tap(find.widgetWithText(FilledButton, tl.settingsGeoContinue));
    await tester.pumpAndSettle();
    expect(find.text(tl.settingsGeoUnverified), findsOneWidget);
    expect(
      container.read(accountProvider(_account.puuid))!.dismissedRegionMismatch,
      isNull,
    );
    await tester.tap(
      find.widgetWithText(TextButton, tl.settingsGeoCancel).last,
    );
    await tester.pumpAndSettle();
    expect(find.byType(RegionPicker), findsOneWidget);
    expect(
      container.read(accountProvider(_account.puuid))!.dismissedRegionMismatch,
      isNull,
    );
  });

  testWidgets('connection sheet scrolls at 200 percent text on a small phone', (
    tester,
  ) async {
    await pump(tester, RegionValidation.verified, scale: 2);
    await tester.ensureVisible(find.text(tl.settingsGeoSave));
    expect(tester.takeException(), isNull);
  });
}
