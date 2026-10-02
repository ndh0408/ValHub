import 'package:valvn/core/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/notifications/notification_service.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/util/clock.dart';

import '../../core/domain/economy/economy_fixtures.dart';

/// Shared fakes for the store and skin-detail widget tests.

class MockPvpApi extends Mock implements PvpApi {}

/// In-memory [JsonFileCache] (no path_provider in widget tests).
class MemoryJsonCache extends JsonFileCache {
  MemoryJsonCache() : super(() => throw UnimplementedError());

  final entries = <String, CachedJson>{};

  @override
  Future<CachedJson?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async =>
      entries[key] = CachedJson(data, savedAt ?? DateTime.now());
}

/// A scheduled notification recorded by [RecordingNotificationService].
class ScheduledCall {
  const ScheduledCall({
    required this.id,
    required this.at,
    required this.title,
    required this.body,
    required this.channel,
    this.payload,
    this.accountPuuid,
  });

  final int id;
  final DateTime at;
  final String title;
  final String body;
  final NotificationChannel channel;
  final String? payload;
  final String? accountPuuid;
}

/// Records `scheduleAt` calls instead of touching the platform plugin.
class RecordingNotificationService extends NotificationService {
  final calls = <ScheduledCall>[];

  @override
  Future<void> scheduleAt({
    required int id,
    required DateTime at,
    required String title,
    required String body,
    required NotificationChannel channel,
    String? payload,
    String? accountPuuid,
    String? tag,
  }) async {
    calls.add(
      ScheduledCall(
        id: id,
        at: at,
        title: title,
        body: body,
        channel: channel,
        payload: payload,
        accountPuuid: accountPuuid,
      ),
    );
  }
}

final t0 = DateTime(2026, 9, 28, 12);

const testAccount = Account(
  puuid: Fx.puuid,
  gameName: 'Người Chơi',
  tagLine: 'VN2',
  region: 'ap',
  shard: 'ap',
);

/// A [PvpApi] serving the economy fixtures: storefront, wallet and the
/// skin-level entitlements (other types answer 404 = empty).
MockPvpApi fixtureApi({
  Map<String, dynamic>? storefront,
  Object? storefrontError,
  Object? walletError,
}) {
  final api = MockPvpApi();
  if (storefrontError != null) {
    when(() => api.storefront(any())).thenThrow(storefrontError);
  } else {
    when(
      () => api.storefront(any()),
    ).thenAnswer((_) async => storefront ?? economyFixture('storefront.json'));
  }
  if (walletError != null) {
    when(() => api.wallet(any())).thenThrow(walletError);
  } else {
    when(() => api.wallet(any()))
        .thenAnswer((_) async => economyFixture('wallet.json'));
  }
  when(() => api.entitlements(any(), any())).thenAnswer((inv) async {
    final type = inv.positionalArguments[1] as String;
    if (type == ItemTypeIds.skinLevel) {
      return economyFixture('entitlements_skin_levels.json');
    }
    throw const NotFoundException();
  });
  when(() => api.platformStatus(any())).thenAnswer((_) async => {});
  return api;
}

/// Provider overrides for a signed-in [account] with the economy fixtures.
List<Override> storeOverrides({
  required PvpApi api,
  required Prefs prefs,
  JsonFileCache? cache,
  Account? account = testAccount,
  NotificationService? notifications,
  ContentDb? content,
  Future<ContentDb> Function()? loadContent,
  List<Account>? accounts,
  MissCounter? misses,
}) => [
  pvpApiProvider.overrideWithValue(api),
  prefsProvider.overrideWithValue(prefs),
  jsonFileCacheProvider.overrideWithValue(cache ?? MemoryJsonCache()),
  clockProvider.overrideWithValue(FixedClock(t0)),
  accountProvider.overrideWith((ref, puuid) => null),
  activeAccountProvider.overrideWithValue(account),
  contentProvider.overrideWith(
    (ref) async => loadContent != null
        ? await loadContent()
        : (content ?? economyContent()),
  ),
  priceAssetLoaderProvider.overrideWithValue(() async => '{}'),
  notificationServiceProvider.overrideWithValue(
    notifications ?? RecordingNotificationService(),
  ),
  contentMissReporterProvider.overrideWith(
    (ref) => CountingMissReporter(ref, misses ?? MissCounter()),
  ),
  if (accounts != null)
    accountsProvider.overrideWith(() => FixedAccountsNotifier(accounts)),
];

/// Counts content-miss reports (no content re-download in tests).
class MissCounter {
  int count = 0;
}

class CountingMissReporter extends ContentMissReporter {
  CountingMissReporter(super.ref, this.counter);

  final MissCounter counter;

  @override
  Future<void> report() async => counter.count++;
}

/// Fixed account list, bypassing the repository.
class FixedAccountsNotifier extends AccountsNotifier {
  FixedAccountsNotifier(this._fixed);

  final List<Account> _fixed;

  @override
  List<Account> build() => _fixed;
}

/// App wrapper with the real dark theme and no provider retries.
Widget testApp({required List<Override> overrides, required Widget home}) =>
    ProviderScope(
      overrides: overrides,
      retry: (_, _) => null,
      child: MaterialApp(
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: buildDarkTheme(),
        home: home,
      ),
    );

/// Uses a small-phone viewport (360×740 dp) for the rest of the test.
void usePhoneViewport(WidgetTester tester, {Size size = const Size(360, 740)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Lets pending futures (storefront, wallet, content, entitlements) settle
/// without `pumpAndSettle` (countdowns and shimmers tick forever).
Future<void> settle(WidgetTester tester, [int frames = 8]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Unmounts the tree so countdown and provider-refresh timers are
/// cancelled before the test ends.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump();
}
