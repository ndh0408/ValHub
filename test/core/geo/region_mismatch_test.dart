import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/geo/region_mismatch_banner.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';

import '../../helpers/l10n.dart';
import '../../helpers/test_prefs.dart';

class _Sessions extends Mock implements SessionManager {}

const _account = Account(
  puuid: '00000000-0000-0000-0000-000000000001',
  gameName: 'Example',
  tagLine: 'VN',
  region: 'eu',
  shard: 'eu',
  regionMode: RegionMode.manual,
  manualRegion: 'eu',
  detectedRegion: 'ap',
);

void main() {
  test('migration preserves an absent discovery time', () {
    final migrated = Account.fromJson({
      'puuid': _account.puuid,
      'region': 'ap',
    })!;
    expect(migrated.autoRegion, 'ap');
    expect(migrated.detectedAt, isNull);
    expect(migrated.showRegionMismatch, false);
  });

  test(
    'mismatch acknowledgement is specific to both regions and survives disk',
    () {
      final kept = _account.copyWith(
        dismissedRegionMismatch: _account.regionMismatchKey,
      );
      expect(Account.fromJson(kept.toJson())!.showRegionMismatch, false);
      expect(kept.copyWith(detectedRegion: 'kr').showRegionMismatch, true);
      expect(kept.copyWith(manualRegion: 'br').showRegionMismatch, true);
      expect(
        kept.copyWith(regionMode: RegionMode.auto).hasRegionMismatch,
        false,
      );
    },
  );

  test(
    'successful discovery time round-trips in UTC and invalid dates migrate',
    () {
      final discovered = _account.copyWith(
        detectedAt: DateTime.utc(2026, 10, 1),
      );
      expect(Account.fromJson(discovered.toJson()), discovered);
      expect(
        Account.fromJson({...discovered.toJson(), 'detectedAt': 'broken'})!
            .detectedAt,
        isNull,
      );
    },
  );

  Future<ProviderContainer> pump(
    WidgetTester tester, {
    bool large = false,
  }) async {
    final prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [_account.toJson()]);
    final sessions = _Sessions();
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
    final container = ProviderContainer.test(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        secureStoreProvider.overrideWithValue(MemorySecureStore()),
        sessionManagerProvider.overrideWithValue(sessions),
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
            body: SingleChildScrollView(
              child: RegionMismatchBanner(puuid: _account.puuid),
            ),
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(large ? 2 : 1)),
            child: child!,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return container;
  }

  testWidgets(
    'keep choice persists; a new detected region shows the banner again',
    (tester) async {
      final container = await pump(tester, large: true);
      expect(tester.takeException(), isNull);
      await tester.tap(find.byKey(const ValueKey('region-mismatch-keep')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('region-mismatch-keep')), findsNothing);
      final account = container.read(accountProvider(_account.puuid))!;
      expect(account.region, 'eu');
      expect(account.showRegionMismatch, false);
      await container
          .read(accountsProvider.notifier)
          .updateAccount(
            _account.puuid,
            (a) => a.copyWith(detectedRegion: 'kr'),
          );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('region-mismatch-keep')),
        findsOneWidget,
      );
    },
  );

  testWidgets('automatic choice uses Riot discovery and recomputes shard', (
    tester,
  ) async {
    final container = await pump(tester);
    await tester.tap(find.byKey(const ValueKey('region-mismatch-auto')));
    await tester.pumpAndSettle();
    final account = container.read(accountProvider(_account.puuid))!;
    expect(account.regionMode, RegionMode.auto);
    expect(account.region, 'ap');
    expect(account.shard, 'ap');
    expect(account.hasRegionMismatch, false);
  });
}
