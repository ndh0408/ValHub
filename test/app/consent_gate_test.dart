import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/app/router.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/geo/country_preference.dart';
import 'package:valvn/features/community/providers/consent_providers.dart';
import 'package:valvn/features/community/providers/scope_providers.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/ui/consent/account_consent_screen.dart';

import '../features/community/community_test_env.dart';

void main() {
  test('withdrawal wins over an in-flight approval and removes its policy metadata', () async {
    final env = await CommunityTestEnv.create(consent: false);
    final container = env.container();
    addTearDown(container.dispose);
    final consent = container.read(communityConsentProvider(mePuuid).notifier);
    final grant = consent.grant();
    final revoke = consent.revoke();
    await Future.wait([grant, revoke]);
    expect(
      container.read(communityConsentProvider(mePuuid)),
      CommunityConsent.unknown,
    );
    expect(env.prefs.getString(communityConsentKey(mePuuid)), isNull);
    expect(env.prefs.getString(communityConsentVersionKey(mePuuid)), isNull);
    expect(env.prefs.getString(communityConsentAtKey(mePuuid)), isNull);
  });

  test('an older accepted policy requires explicit approval again', () async {
    final env = await CommunityTestEnv.create();
    await env.prefs.setString(
      communityConsentVersionKey(mePuuid),
      '2026-10-01',
    );
    final container = env.container();
    addTearDown(container.dispose);
    expect(container.read(accountRequiresConsentProvider), isTrue);
    expect(
      container.read(communityConsentProvider(mePuuid)),
      CommunityConsent.unknown,
    );
    expect(env.server.requests, isEmpty);
  });
  test('gate preserves deep links, permits legal/management and rejects external resume', () {
    String? redirect(String path, bool required) => appRedirect(
      hasAccounts: true,
      location: Uri.parse(path),
      requiresConsent: required,
    );
    final gate = redirect('/profile/match/id?round=4', true)!;
    expect(Uri.parse(gate).path, '/consent');
    expect(redirect(gate, false), '/profile/match/id?round=4');
    expect(redirect('/settings/about/privacy', true), isNull);
    expect(redirect('/settings', true), isNull);
    expect(redirect('/login', true), isNull);
    for (final from in [
      'https://evil.test',
      '//evil.test',
      '/consent',
      '/login',
    ]) {
      expect(
        redirect(
          Uri(path: '/consent', queryParameters: {'from': from}).toString(),
          false,
        ),
        '/home',
      );
    }
    expect(
      appRedirect(hasAccounts: false, location: Uri.parse('/consent')),
      '/welcome',
    );
  });

  test('country falls back to authenticated login country during Community outage, never manual/device hints', () async {
    final env = await CommunityTestEnv.create(
      account: meAccount.copyWith(country: 'JP'),
    );
    env.server.on('POST /v1/auth/riot', (_) => const FakeResponse(503, {}));
    env.extraOverrides = [deviceCountryProvider.overrideWithValue('VN')];
    await env.prefs.setString(CountryPreference.key, 'US');
    final container = env.container();
    addTearDown(container.dispose);
    final scope = await container.read(
      resolvedScopeProvider((puuid: mePuuid, section: ScopedSection.feed))
          .future,
    );
    expect((scope.scope, scope.country), (CommunityScope.country, 'JP'));
    expect(await container.read(myCountryProvider(mePuuid).future), 'JP');
    expect(container.read(selectedCountryProvider), 'US');
  });

  for (final width in [320.0, 360.0, 393.0, 600.0]) {
    testWidgets(
      'explicit gate at $width dp / 200%, persists only after approval and isolates accounts',
      (tester) async {
        final env = await CommunityTestEnv.create(consent: false);
        await tester.binding.setSurfaceSize(Size(width, 1600));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.pumpWidget(
          ProviderScope(
            overrides: env.overrides,
            child: MaterialApp(
              localizationsDelegates: appLocalizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context)
                    .copyWith(textScaler: TextScaler.linear(2)),
                child: child!,
              ),
              home: const AccountConsentScreen(),
            ),
          ),
        );
        await settle(tester);
        final container = ProviderScope.containerOf(
          tester.element(find.byType(AccountConsentScreen)),
        );
        expect(container.read(accountRequiresConsentProvider), isTrue);
        expect(env.prefs.getString(communityConsentKey(mePuuid)), isNull);
        expect(env.server.requests, isEmpty);
        expect(find.byKey(const ValueKey('consent-terms')), findsOneWidget);
        final agree = find.byKey(const ValueKey('consent-agree'));
        await tester.ensureVisible(agree);
        await tester.tap(agree);
        await settle(tester);
        expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
        expect(
          env.prefs.getString(communityConsentVersionKey(mePuuid)),
          communityConsentVersion,
        );
        expect(container.read(accountRequiresConsentProvider), isFalse);
        expect(
          env.server.requests,
          isEmpty,
          reason: 'Consent itself never uploads a Riot token',
        );
        await container
            .read(communityConsentProvider(mePuuid).notifier)
            .revoke();
        await settle(tester);
        expect(container.read(accountRequiresConsentProvider), isTrue);
        expect(tester.takeException(), isNull);
        await unmount(tester);
      },
    );
  }
}
