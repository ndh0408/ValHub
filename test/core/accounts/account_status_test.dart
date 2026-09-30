import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_status.dart';
import 'package:valvn/core/accounts/account_widgets.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/l10n/account_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/riot/pvp_api.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';

import '../../helpers/test_prefs.dart';

class MockPvpApi extends Mock implements PvpApi {}

class MockSessions extends Mock implements SessionManager {}

String _puuid(int i) =>
    '00000000-0000-0000-0000-${i.toString().padLeft(12, '0')}';

Account _account(int i, {bool needsLogin = false}) => Account(
  puuid: _puuid(i),
  gameName: 'P$i',
  tagLine: 'VN',
  region: 'ap',
  shard: 'ap',
  needsLogin: needsLogin,
);

void main() {
  group('AccountActivity.fromSession', () {
    test('404 (null) = offline', () {
      expect(AccountActivity.fromSession(null), AccountActivity.offline);
    });

    test('loop states', () {
      expect(
        AccountActivity.fromSession({'loopState': 'MENUS'}),
        AccountActivity.online,
      );
      expect(
        AccountActivity.fromSession({'loopState': 'PREGAME'}),
        AccountActivity.agentSelect,
      );
      expect(
        AccountActivity.fromSession({'loopState': 'INGAME'}),
        AccountActivity.inMatch,
      );
    });

    test('malformed and incomplete sessions do not claim online', () {
      expect(AccountActivity.fromSession({}), AccountActivity.unknown);
      expect(AccountActivity.fromSession('<html>'), AccountActivity.unknown);
      expect(
        AccountActivity.fromSession({'loopState': 42}),
        AccountActivity.unknown,
      );
    });

    test('expired or disconnected sessions are offline', () {
      final now = DateTime.utc(2026, 9, 29, 12);
      expect(
        AccountActivity.fromSession({
          'loopState': 'MENUS',
          'expiredTime': now
              .subtract(const Duration(seconds: 1))
              .toIso8601String(),
        }, now: now),
        AccountActivity.offline,
      );
      expect(
        AccountActivity.fromSession({
          'loopState': 'MENUS',
          'cxnState': 'DISCONNECTED',
        }, now: now),
        AccountActivity.offline,
      );
      expect(
        AccountActivity.fromSession({
          'loopState': 'MENUS',
          'shouldForceInvalidate': true,
        }, now: now),
        AccountActivity.offline,
      );
      expect(
        AccountActivity.fromSession({
          'loopState': 'MENUS',
          'expiredTime': now.add(const Duration(minutes: 1)).toIso8601String(),
        }, now: now),
        AccountActivity.online,
      );
    });

    test('an unset expiredTime on a live session never means offline', () {
      final now = DateTime.utc(2026, 9, 29, 12);
      for (final unset in <Object?>[
        '0',
        0,
        '0001-01-01T00:00:00Z',
        '1970-01-01T00:00:00Z',
        '',
        null,
      ]) {
        expect(
          AccountActivity.fromSession({
            'loopState': 'MENUS',
            'cxnState': 'CONNECTED',
            'shouldForceInvalidate': false,
            'expiredTime': unset,
          }, now: now),
          AccountActivity.online,
          reason: 'expiredTime=$unset',
        );
      }
    });

    test('isOnline', () {
      expect(AccountActivity.online.isOnline, isTrue);
      expect(AccountActivity.agentSelect.isOnline, isTrue);
      expect(AccountActivity.inMatch.isOnline, isTrue);
      expect(AccountActivity.offline.isOnline, isFalse);
      expect(AccountActivity.needsLogin.isOnline, isFalse);
      expect(AccountActivity.unknown.isOnline, isFalse);
    });
  });

  late Prefs prefs;
  late MockPvpApi api;
  late MockSessions sessions;

  Future<void> seed(List<Account> accounts) async {
    prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [
      for (final a in accounts) a.toJson(),
    ]);
  }

  setUp(() {
    api = MockPvpApi();
    sessions = MockSessions();
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
  });

  List<Override> overrides() => [
    prefsProvider.overrideWithValue(prefs),
    sessionManagerProvider.overrideWithValue(sessions),
    pvpApiProvider.overrideWithValue(api),
  ];

  group('accountActivityProvider', () {
    test('maps each account with its own session', () async {
      await seed([_account(1), _account(2), _account(3)]);
      when(() => api.gameSession(_puuid(1)))
          .thenAnswer((_) async => {'loopState': 'INGAME'});
      when(() => api.gameSession(_puuid(2))).thenAnswer(
        (_) async =>
            throw const NotFoundException(errorCode: 'RESOURCE_NOT_FOUND'),
      );
      when(() => api.gameSession(_puuid(3)))
          .thenAnswer((_) async => {'loopState': 'MENUS'});
      final c = ProviderContainer.test(overrides: overrides());

      final count = c.listen(onlineAccountCountProvider, (_, _) {});
      expect(
        await c.read(accountActivityProvider(_puuid(1)).future),
        AccountActivity.inMatch,
      );
      expect(
        await c.read(accountActivityProvider(_puuid(2)).future),
        AccountActivity.offline,
      );
      expect(
        await c.read(accountActivityProvider(_puuid(3)).future),
        AccountActivity.online,
      );
      expect(count.read(), 2);
    });

    test('an expired account is not checked', () async {
      await seed([_account(1, needsLogin: true)]);
      final c = ProviderContainer.test(overrides: overrides());
      expect(
        await c.read(accountActivityProvider(_puuid(1)).future),
        AccountActivity.needsLogin,
      );
      verifyNever(() => api.gameSession(any()));
    });

    test('failures read as unknown / needs login, never throw', () async {
      await seed([_account(1), _account(2)]);
      when(() => api.gameSession(_puuid(1))).thenAnswer(
        (_) async => throw const TransientException(reason: 'network'),
      );
      when(() => api.gameSession(_puuid(2)))
          .thenAnswer((_) async => throw const NeedsLoginException());
      final c = ProviderContainer.test(overrides: overrides());
      expect(
        await c.read(accountActivityProvider(_puuid(1)).future),
        AccountActivity.unknown,
      );
      expect(
        await c.read(accountActivityProvider(_puuid(2)).future),
        AccountActivity.needsLogin,
      );
    });

    test('unknown account', () async {
      await seed([]);
      final c = ProviderContainer.test(overrides: overrides());
      expect(
        await c.read(accountActivityProvider(_puuid(9)).future),
        AccountActivity.unknown,
      );
    });
  });

  testWidgets('switcher shows every account status and the online count', (
    tester,
  ) async {
    await seed([_account(1), _account(2)]);
    when(() => api.gameSession(_puuid(1)))
        .thenAnswer((_) async => {'loopState': 'PREGAME'});
    when(() => api.gameSession(_puuid(2)))
        .thenAnswer((_) async => throw const NotFoundException());
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: const Scaffold(
            body: AccountActivityPoller(child: AccountSwitcherSheet()),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text(AccountStrings.onlineCount(1)), findsOneWidget);
    expect(
      find.textContaining(AccountStrings.statusAgentSelect, findRichText: true),
      findsOneWidget,
    );
    expect(
      find.textContaining(AccountStrings.statusOffline, findRichText: true),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    // The poller re-checks every account while the list is visible.
    await tester.pump(kAccountActivityRefresh);
    await tester.pump();
    verify(() => api.gameSession(_puuid(1))).called(2);

    // Leaving the screen stops polling.
    await tester.pumpWidget(const SizedBox());
    await tester.pump(kAccountActivityRefresh * 2);
    verifyNever(() => api.gameSession(_puuid(1)));
  });
}
