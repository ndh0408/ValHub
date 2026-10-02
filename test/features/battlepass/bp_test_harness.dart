import 'package:valvn/core/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/prices.dart'
    show priceAssetLoaderProvider;
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/core/util/json.dart';
import 'package:valvn/features/battlepass/battlepass_routes.dart';

import 'bp_fixtures.dart';

class MockPvpApi extends Mock implements PvpApi {}

/// In-memory [JsonFileCache] (no path_provider in tests).
class MemoryJsonCache extends JsonFileCache {
  MemoryJsonCache() : super(() => throw UnimplementedError());

  final entries = <String, CachedJson>{};

  @override
  Future<CachedJson?> read(String key) async => entries[key];

  @override
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async =>
      entries[key] = CachedJson(data, savedAt ?? DateTime.now());
}

/// Counts content-miss reports (no re-download in tests).
class CountingMissReporter extends ContentMissReporter {
  CountingMissReporter(super.ref, this.counter);

  final List<int> counter;

  @override
  Future<void> report() async => counter[0]++;
}

const testAccount = Account(
  puuid: Bp.puuid,
  gameName: 'Người Chơi Rất Dài Tên',
  tagLine: 'VN2',
  region: 'ap',
  shard: 'ap',
);

/// A [PvpApi] answering P-15, P-16 and the premium-contract P-3.
MockPvpApi bpApi({
  JsonMap? contracts,
  Object? contractsError,
  JsonMap? ticket,
  Object? ticketError,
  List<String>? premium = const [Bp.bpId],
  Object? premiumError,
}) {
  final api = MockPvpApi();
  if (contractsError != null) {
    when(() => api.contracts(any())).thenThrow(contractsError);
  } else {
    when(() => api.contracts(any()))
        .thenAnswer((_) async => contracts ?? contractsJson());
  }
  if (ticketError != null) {
    when(() => api.dailyTicket(any())).thenThrow(ticketError);
  } else {
    when(() => api.dailyTicket(any()))
        .thenAnswer((_) async => ticket ?? dailyTicketJson());
  }
  when(() => api.entitlements(any(), any())).thenAnswer((inv) async {
    final type = inv.positionalArguments[1] as String;
    if (type != ItemTypeIds.premiumContract) throw const NotFoundException();
    if (premiumError != null) throw premiumError;
    if (premium == null) throw const NotFoundException();
    return premiumJson(premium);
  });
  when(() => api.renewDailyTicket(any()))
      .thenAnswer((_) async => <String, dynamic>{});
  when(() => api.platformStatus(any())).thenAnswer((_) async => {});
  return api;
}

/// Provider overrides for a signed-in [account].
List<Override> bpOverrides({
  required PvpApi api,
  required Prefs prefs,
  JsonFileCache? cache,
  Account? account = testAccount,
  ContentDb? content,
  Future<ContentDb> Function()? loadContent,
  List<int>? misses,
  DateTime? now,
}) => [
  pvpApiProvider.overrideWithValue(api),
  prefsProvider.overrideWithValue(prefs),
  jsonFileCacheProvider.overrideWithValue(cache ?? MemoryJsonCache()),
  clockProvider.overrideWithValue(FixedClock(now ?? t0)),
  accountProvider.overrideWith((ref, puuid) => null),
  activeAccountProvider.overrideWithValue(account),
  contentProvider.overrideWith(
    (ref) async =>
        loadContent != null ? await loadContent() : (content ?? bpContent()),
  ),
  contentMissReporterProvider.overrideWith(
    (ref) => CountingMissReporter(ref, misses ?? [0]),
  ),
  // The skin detail sheet (S15) prices skins; no bundled table in tests.
  priceAssetLoaderProvider.overrideWithValue(() async => '{}'),
];

/// App with the real dark theme, no provider retries, and the Battle Pass
/// branch routes (so `context.push` works).
Widget bpApp({
  required List<Override> overrides,
  String initialLocation = BattlePassRoutes.root,
  ThemeData? theme,
}) => ProviderScope(
  overrides: overrides,
  retry: (_, _) => null,
  child: MaterialApp.router(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme ?? buildDarkTheme(),
    routerConfig: GoRouter(
      initialLocation: initialLocation,
      routes: battlepassBranchRoutes,
    ),
  ),
);

/// Small-phone viewport (360×740 dp).
void usePhoneViewport(WidgetTester tester, {Size size = const Size(360, 740)}) {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

/// Lets pending futures settle without `pumpAndSettle` (countdowns and
/// shimmers tick forever).
Future<void> settle(WidgetTester tester, [int frames = 10]) async {
  for (var i = 0; i < frames; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

/// Unmounts the tree so countdown and cache timers are cancelled.
Future<void> unmount(WidgetTester tester) async {
  await tester.pumpWidget(const SizedBox());
  await tester.pump(const Duration(minutes: 6));
}
