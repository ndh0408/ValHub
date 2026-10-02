import 'package:valvn/core/l10n/l10n.dart';

import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/community/community_routes.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/providers/community_providers.dart';
import 'package:valvn/features/community/providers/consent_providers.dart';
import 'package:valvn/features/community/ui/data_rights/community_data_section.dart';

import '../community_test_env.dart';

const _settings = '/test-settings';

/// The community tab plus a stand-in "Cài đặt" page holding the group, so
/// the flow can go Settings → Community like the app does.
Future<GoRouter> _open(
  WidgetTester tester,
  CommunityTestEnv env, {
  String location = _settings,
  Size size = const Size(360, 1600),
  double textScale = 1,
  ThemeData? theme,
}) async {
  final router = await pumpCommunityRouter(
    tester,
    env,
    routes: [
      ...communityBranchRoutes,
      ...communityTopLevelRoutes,
      GoRoute(
        path: _settings,
        builder: (context, state) => const Scaffold(
          body: SingleChildScrollView(child: CommunityDataSection()),
        ),
      ),
    ],
    initialLocation: location,
    size: size,
    textScale: textScale,
    theme: theme,
  );
  await settle(tester);
  return router;
}

void _serve(CommunityTestEnv env) {
  env.server
    ..json('POST /v1/auth/riot', sessionJson(country: 'VN'))
    ..json('GET /v1/posts', page([postJson('p1', body: 'Bài công khai')]))
    ..json('GET /v1/me', authorJson(id: meId, name: 'Tôi Là Ai', tag: 'VN1'))
    ..json('GET /v1/me/export', {
      'format': 'valvn-community-export/1',
      'posts': [
        {'id': 'p1', 'body': 'Bài của tôi'},
      ],
    })
    ..on('DELETE /v1/me', (_) => const FakeResponse(204));
}

Finder get _exportRow => find.byKey(const ValueKey('community-data-export'));
Finder get _deleteRow => find.byKey(const ValueKey('community-data-delete'));
Finder get _withdrawRow =>
    find.byKey(const ValueKey('community-data-withdraw'));

void main() {
  late CommunityTestEnv env;

  group('who sees the group', () {
    testWidgets('an account that joined sees all three actions', (
      tester,
    ) async {
      env = await CommunityTestEnv.create();
      _serve(env);
      await _open(tester, env);

      expect(
        find.text(CommunityStrings.dataTitle.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text(CommunityStrings.exportTitle), findsOneWidget);
      expect(find.text(CommunityStrings.deleteDataTitle), findsOneWidget);
      expect(find.text(CommunityStrings.withdrawTitle), findsOneWidget);
      // Names the account it applies to.
      expect(
        find.text(CommunityStrings.dataFooter(meAccount.riotId)),
        findsOneWidget,
      );
      // Opening Settings talks to nobody.
      expect(env.server.requests, isEmpty);
      await unmount(tester);
    });

    testWidgets('an account that never joined sees nothing', (tester) async {
      env = await CommunityTestEnv.create(consent: false);
      await _open(tester, env);
      expect(find.text(CommunityStrings.dataTitle.toUpperCase()), findsNothing);
      expect(find.byType(ListTile), findsNothing);
      await unmount(tester);
    });

    testWidgets('a declined account sees nothing', (tester) async {
      env = await CommunityTestEnv.create(consent: false);
      await env.prefs.setString(communityConsentKey(mePuuid), 'declined');
      await _open(tester, env);
      expect(find.text(CommunityStrings.dataTitle.toUpperCase()), findsNothing);
      await unmount(tester);
    });

    testWidgets('no account: nothing', (tester) async {
      env = await CommunityTestEnv.create(account: null);
      await _open(tester, env);
      expect(find.text(CommunityStrings.dataTitle.toUpperCase()), findsNothing);
      await unmount(tester);
    });

    testWidgets('Community switched off: nothing', (tester) async {
      env = await CommunityTestEnv.create();
      tester.view.physicalSize = const Size(360, 1600);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            ...env.overrides,
            communityEnabledProvider.overrideWithValue(false),
          ],
          child: MaterialApp(
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            theme: buildDarkTheme(),
            home: const Scaffold(body: CommunityDataSection()),
          ),
        ),
      );
      await settle(tester);
      expect(find.text(CommunityStrings.exportTitle), findsNothing);
      await unmount(tester);
    });
  });

  group('Tải dữ liệu của tôi', () {
    testWidgets('downloads and shares valvn-community-<date>.json', (
      tester,
    ) async {
      env = await CommunityTestEnv.create();
      env.clock.time = DateTime(2026, 9, 28, 12);
      _serve(env);
      final gate = Completer<void>();
      env.server.hold('GET /v1/me/export', gate);
      await _open(tester, env);

      await tester.tap(_exportRow);
      await settle(tester);

      // In flight: the row says so and every row is locked.
      expect(find.text(CommunityStrings.exportPreparing), findsOneWidget);
      expect(
        find.descendant(
          of: _exportRow,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      await tester.tap(_deleteRow);
      await tester.pump();
      expect(find.text(CommunityStrings.deleteDataConfirmTitle), findsNothing);
      expect(env.sharedExports, isEmpty);

      gate.complete();
      await settle(tester, frames: 20);

      expect(env.server.calls('GET /v1/me/export'), hasLength(1));
      expect(
        env.server.calls('GET /v1/me/export').single.authorization,
        'Bearer community-1',
      );
      final file = env.sharedExports.single;
      expect(file.fileName, 'valvn-community-2026-09-28.json');
      expect(
        jsonDecode(file.text),
        containsPair('format', startsWith('valvn')),
      );
      expect(file.text, contains('Bài của tôi'));
      // Back to normal, nothing else changed.
      expect(find.text(CommunityStrings.exportSubtitle), findsOneWidget);
      expect(env.server.calls('DELETE /v1/me'), isEmpty);
      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
      await unmount(tester);
    });

    testWidgets('rate limited: says when to retry, shares nothing', (
      tester,
    ) async {
      env = await CommunityTestEnv.create();
      _serve(env);
      env.server.json('GET /v1/me/export', {
        'error': {'code': 'rate_limited', 'retryAfter': 1200},
      }, status: 429);
      await _open(tester, env);

      await tester.tap(_exportRow);
      await settle(tester, frames: 20);

      expect(
        find.text(CommunityStrings.errorRateLimitedIn('20 phút')),
        findsOneWidget,
      );
      expect(env.sharedExports, isEmpty);
      expect(find.text(CommunityStrings.exportSubtitle), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('Riot outage while signing in: try again later', (
      tester,
    ) async {
      env = await CommunityTestEnv.create();
      _serve(env);
      env.server.on(
        'POST /v1/auth/riot',
        (_) => const FakeResponse(
          503,
          {
            'error': {'code': 'riot_unavailable'},
          },
          {
            'retry-after': ['45'],
          },
        ),
      );
      await _open(tester, env);

      await tester.tap(_exportRow);
      await settle(tester, frames: 20);

      expect(
        find.text(CommunityStrings.errorRiotUnavailableIn('45 giây')),
        findsOneWidget,
      );
      // The group and the consent stay: it is not a refusal.
      expect(find.text(CommunityStrings.exportTitle), findsOneWidget);
      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
      await unmount(tester);
    });
  });

  group('Xóa dữ liệu Cộng đồng của tôi', () {
    testWidgets('the dialog says what is deleted; cancel sends nothing', (
      tester,
    ) async {
      env = await CommunityTestEnv.create();
      _serve(env);
      await _open(tester, env);

      await tester.tap(_deleteRow);
      await settle(tester);

      expect(
        find.text(CommunityStrings.deleteDataConfirmTitle),
        findsOneWidget,
      );
      final body = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .firstWhere((t) => t.contains('không thể khôi phục'));
      for (final what in [
        'bài viết',
        'bình luận',
        'đánh giá',
        'lượt thích',
        'bình chọn',
        'tin tìm đồng đội',
        'ảnh',
        'không thể khôi phục',
      ]) {
        expect(body, contains(what), reason: what);
      }
      expect(body, contains(meAccount.riotId));
      expect(find.text(CommunityStrings.deleteDataConfirm), findsOneWidget);

      await tester.tap(find.text(CommonStrings.cancel));
      await settle(tester);

      expect(env.server.requests, isEmpty);
      expect(find.text(CommunityStrings.deleteDataTitle), findsOneWidget);
      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
      await unmount(tester);
    });

    testWidgets(
      'confirm: server erases, device forgets, the tab is anonymous again',
      (tester) async {
        env = await CommunityTestEnv.create();
        _serve(env);
        // The account already has a session on the device (used the tab).
        env.secure.values[SecureKeys.community(mePuuid)] = jsonEncode(
          sessionJson(token: 'stored-1'),
        );
        final router = await _open(tester, env, location: CommunityRoutes.root);
        // Joined: no banner, requests carry the token.
        expect(find.text(CommunityStrings.anonymousBanner), findsNothing);
        expect(
          env.server.calls('GET /v1/posts').last.authorization,
          'Bearer stored-1',
        );

        unawaited(router.push<void>(_settings));
        await settle(tester, frames: 20);
        await tester.tap(_deleteRow);
        await settle(tester);
        await tester.tap(find.text(CommunityStrings.deleteDataConfirm));
        await settle(tester, frames: 30);

        // Server side: one DELETE with the session token.
        final deletes = env.server.calls('DELETE /v1/me');
        expect(deletes, hasLength(1));
        expect(deletes.single.authorization, 'Bearer stored-1');
        // Device side: session and consent are gone.
        expect(env.secure.values[SecureKeys.community(mePuuid)], isNull);
        expect(env.prefs.getString(communityConsentKey(mePuuid)), isNull);
        expect(
          ProviderScope.containerOf(tester.element(find.byType(Scaffold).last))
              .read(communityConsentProvider(mePuuid)),
          CommunityConsent.unknown,
        );
        // The group is gone and the user is told.
        expect(find.text(CommunityStrings.exportTitle), findsNothing);
        expect(find.text(CommunityStrings.dataDeleted), findsOneWidget);

        // Back on the Community tab: anonymous browsing with the banner.
        router.pop();
        await settle(tester, frames: 30);
        expect(find.text(CommunityStrings.anonymousBanner), findsOneWidget);
        expect(find.text(CommunityStrings.consentGateAction), findsOneWidget);
        expect(find.text('Bài công khai'), findsOneWidget);
        final feed = env.server.calls('GET /v1/posts').last;
        expect(feed.authorization, isNull);
        expect(feed.query['scope'], 'global');
        await unmount(tester);
      },
    );

    testWidgets('a server failure changes nothing and explains', (
      tester,
    ) async {
      env = await CommunityTestEnv.create();
      _serve(env);
      env.secure.values[SecureKeys.community(mePuuid)] = jsonEncode(
        sessionJson(token: 'stored-1'),
      );
      env.server.json('DELETE /v1/me', {
        'error': {'code': 'server_error'},
      }, status: 500);
      await _open(tester, env);

      await tester.tap(_deleteRow);
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.deleteDataConfirm));
      await settle(tester, frames: 30);

      expect(find.text(CommunityStrings.errorServer), findsOneWidget);
      expect(find.text(CommunityStrings.dataDeleted), findsNothing);
      expect(env.secure.values[SecureKeys.community(mePuuid)], isNotNull);
      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
      // Still there to try again.
      expect(find.text(CommunityStrings.deleteDataTitle), findsOneWidget);
      await unmount(tester);
    });
  });

  group('Rút lại đồng ý', () {
    testWidgets(
      'explains what remains; confirm wipes locally and revokes the server session',
      (tester) async {
        env = await CommunityTestEnv.create();
        _serve(env);
        env.secure.values[SecureKeys.community(mePuuid)] = jsonEncode(
          sessionJson(token: 'stored-1'),
        );
        await _open(tester, env);

        await tester.tap(_withdrawRow);
        await settle(tester);

        expect(
          find.text(CommunityStrings.withdrawConfirmTitle),
          findsOneWidget,
        );
        final body = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .firstWhere((t) => t.contains('vẫn còn'));
        expect(body, contains('Bài viết'));
        expect(body, contains('vẫn hiện Riot ID'));
        expect(body, contains(CommunityStrings.deleteDataTitle));

        await tester.tap(find.text(CommunityStrings.withdrawConfirm));
        await settle(tester, frames: 30);

        // Revokes the session only; published content is kept.
        expect(env.server.calls('POST /v1/auth/logout'), hasLength(1));
        expect(env.secure.values[SecureKeys.community(mePuuid)], isNull);
        expect(env.prefs.getString(communityConsentKey(mePuuid)), isNull);
        expect(find.text(CommunityStrings.exportTitle), findsNothing);
        expect(find.text(CommunityStrings.consentWithdrawn), findsOneWidget);
        await unmount(tester);
      },
    );

    testWidgets('cancel keeps everything', (tester) async {
      env = await CommunityTestEnv.create();
      _serve(env);
      await _open(tester, env);
      await tester.tap(_withdrawRow);
      await settle(tester);
      await tester.tap(find.text(CommonStrings.cancel));
      await settle(tester);
      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
      expect(find.text(CommunityStrings.withdrawTitle), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('after withdrawing, joining again works', (tester) async {
      env = await CommunityTestEnv.create();
      _serve(env);
      final router = await _open(tester, env, location: CommunityRoutes.root);
      unawaited(router.push<void>(_settings));
      await settle(tester, frames: 20);
      await tester.tap(_withdrawRow);
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.withdrawConfirm));
      await settle(tester, frames: 30);
      router.pop();
      await settle(tester, frames: 30);
      expect(find.text(CommunityStrings.anonymousBanner), findsOneWidget);

      await tester.tap(find.text(CommunityStrings.consentGateAction));
      await settle(tester, frames: 20);
      await tester.tap(find.byKey(const ValueKey('consent-agree')));
      await settle(tester, frames: 30);

      expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
      expect(find.text(CommunityStrings.anonymousBanner), findsNothing);
      await unmount(tester);
    });
  });

  for (final (name, theme) in [
    ('dark', buildDarkTheme()),
    ('light', buildLightTheme()),
  ]) {
    testWidgets('no overflow at 360 dp × 2.0 ($name, group and dialogs)', (
      tester,
    ) async {
      env = await CommunityTestEnv.create();
      _serve(env);
      await _open(
        tester,
        env,
        size: const Size(360, 900),
        textScale: 2,
        theme: theme,
      );
      expect(tester.takeException(), isNull);

      for (final row in [_deleteRow, _withdrawRow]) {
        await tester.ensureVisible(row);
        await tester.pump();
        await tester.tap(row);
        await settle(tester);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text(CommonStrings.cancel));
        await settle(tester);
      }
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  }
}
