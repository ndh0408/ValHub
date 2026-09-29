import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/features/community/community_routes.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/data/community_translator.dart';
import 'package:valvn/features/community/providers/translation_providers.dart';
import 'package:valvn/features/community/ui/skins/skin_review_screen.dart';

import '../community_test_env.dart';
import '../data/skin_review_test.dart' show reviewJson, summaryJson;

Future<void> _openFeed(WidgetTester tester, CommunityTestEnv env) async {
  await pumpCommunityRouter(
    tester,
    env,
    routes: [...communityBranchRoutes, ...communityTopLevelRoutes],
    initialLocation: CommunityRoutes.root,
  );
  await settle(tester);
}

void _servePosts(CommunityTestEnv env, {String? language = 'ja'}) {
  env.server.json(
    'GET /v1/posts',
    page([
      {...postJson('p1', body: 'こんにちは、みなさん'), 'language': language},
    ]),
  );
}

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create());

  group('pure helpers', () {
    test('shouldOfferTranslation', () {
      expect(shouldOfferTranslation('hello', 'en', 'vi'), isTrue);
      expect(shouldOfferTranslation('hello', 'vi', 'vi'), isFalse);
      expect(shouldOfferTranslation('hello', null, 'vi'), isFalse);
      expect(shouldOfferTranslation('hello', kLfgAnyLanguage, 'vi'), isFalse);
      expect(shouldOfferTranslation('   ', 'en', 'vi'), isFalse);
      // zh-CN and zh-TW are one ML Kit language.
      expect(shouldOfferTranslation('你好', 'zh-TW', 'zh-CN'), isFalse);
      expect(shouldOfferTranslation('你好', 'zh-TW', 'vi'), isTrue);
    });

    test('every community language maps to an ML Kit language', () {
      for (final code in kLfgLanguages) {
        expect(mlKitLanguage(code), isNotNull, reason: code);
      }
      expect(mlKitLanguage('any'), isNull);
      expect(mlKitLanguage('zh-CN'), mlKitLanguage('zh-TW'));
    });

    test('the translation cache is a small LRU', () {
      final container = ProviderContainer.test();
      final cache = container.read(translationCacheProvider.notifier);
      for (var i = 0; i < TranslationCache.capacity + 5; i++) {
        cache.put('k$i', 'v$i');
      }
      final state = container.read(translationCacheProvider);
      expect(state.length, TranslationCache.capacity);
      expect(state.containsKey('k0'), isFalse);
      expect(state['k${TranslationCache.capacity + 4}'], isNotNull);
      expect(translationKey('ja', 'vi', 'x'), 'ja>vi|x');
    });
  });

  group('on-device translation of a post', () {
    testWidgets('models missing: asks (with size), downloads, translates', (
      tester,
    ) async {
      _servePosts(env);
      await _openFeed(tester, env);
      expect(find.text('こんにちは、みなさん'), findsOneWidget);
      final requests = env.server.requests.length;

      await tester.tap(find.byKey(const ValueKey('translate-button')));
      await settle(tester);
      expect(
        find.text(CommunityStrings.translateDownloadTitle),
        findsOneWidget,
      );
      expect(find.textContaining('30 MB'), findsOneWidget);
      expect(find.textContaining('không gửi tới máy chủ nào'), findsOneWidget);
      expect(env.translator.downloads, isEmpty);

      // "Hủy": nothing is downloaded or translated.
      await tester.tap(find.text('Hủy'));
      await settle(tester);
      expect(env.translator.downloads, isEmpty);
      expect(env.translator.translations, isEmpty);

      await tester.tap(find.byKey(const ValueKey('translate-button')));
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.download));
      await settle(tester, frames: 20);

      expect(env.translator.downloads, ['ja']);
      expect(env.translator.translations.single, ('こんにちは、みなさん', 'ja', 'vi'));
      expect(find.text('[ja>vi] こんにちは、みなさん'), findsOneWidget);
      expect(find.text(CommunityStrings.translatedByGoogle), findsOneWidget);
      // On-device: no request to any server.
      expect(env.server.requests.length, requests);
      await unmount(tester);
    });

    testWidgets('models present: translates straight away, toggles original', (
      tester,
    ) async {
      env.translator.downloaded.add('ja');
      _servePosts(env);
      await _openFeed(tester, env);

      await tester.tap(find.byKey(const ValueKey('translate-button')));
      await settle(tester, frames: 20);

      expect(find.text(CommunityStrings.translateDownloadTitle), findsNothing);
      expect(env.translator.downloads, isEmpty);
      expect(find.text('[ja>vi] こんにちは、みなさん'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('translate-toggle')));
      await settle(tester);
      expect(find.text('こんにちは、みなさん'), findsOneWidget);
      expect(find.text(CommunityStrings.showTranslation), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('translate-toggle')));
      await settle(tester);
      expect(find.text('[ja>vi] こんにちは、みなさん'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('Google\'s attribution opens the required disclaimer', (
      tester,
    ) async {
      env.translator.downloaded.add('ja');
      _servePosts(env);
      await _openFeed(tester, env);
      await tester.tap(find.byKey(const ValueKey('translate-button')));
      await settle(tester, frames: 20);

      await tester.tap(find.byKey(const ValueKey('translate-attribution')));
      await settle(tester);

      expect(find.text(CommunityStrings.googleDisclaimerTitle), findsOneWidget);
      expect(find.textContaining('POWERED BY GOOGLE'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('the button is labelled "Dịch bằng Google"', (tester) async {
      _servePosts(env);
      await _openFeed(tester, env);
      expect(find.text('Dịch bằng Google'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('same language, unknown language or no support: no button', (
      tester,
    ) async {
      _servePosts(env, language: 'vi');
      await _openFeed(tester, env);
      expect(find.byKey(const ValueKey('translate-button')), findsNothing);
      await unmount(tester);

      _servePosts(env, language: null);
      await _openFeed(tester, env);
      expect(find.byKey(const ValueKey('translate-button')), findsNothing);
      await unmount(tester);

      env.translator.supported = false;
      _servePosts(env);
      await _openFeed(tester, env);
      expect(find.byKey(const ValueKey('translate-button')), findsNothing);
      await unmount(tester);
    });

    testWidgets('falls back to the author language', (tester) async {
      env.server.json(
        'GET /v1/posts',
        page([
          postJson(
            'p1',
            body: 'Hello there',
            author: authorJson(language: 'en'),
          ),
        ]),
      );
      await _openFeed(tester, env);
      expect(find.byKey(const ValueKey('translate-button')), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a failure is explained and can be retried', (tester) async {
      env.translator
        ..downloaded.add('ja')
        ..failTranslate = true;
      _servePosts(env);
      await _openFeed(tester, env);

      await tester.tap(find.byKey(const ValueKey('translate-button')));
      await settle(tester, frames: 20);
      expect(find.text(CommunityStrings.translateFailed), findsOneWidget);
      expect(find.byKey(const ValueKey('translate-button')), findsOneWidget);

      env.translator.failTranslate = false;
      await tester.tap(find.byKey(const ValueKey('translate-button')));
      await settle(tester, frames: 20);
      expect(find.text('[ja>vi] こんにちは、みなさん'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('a translation is kept when the post scrolls back', (
      tester,
    ) async {
      env.translator.downloaded.add('ja');
      _servePosts(env);
      await _openFeed(tester, env);
      await tester.tap(find.byKey(const ValueKey('translate-button')));
      await settle(tester, frames: 20);
      final calls = env.translator.translations.length;

      // Rebuild the tree (the cache lives in the container, per run).
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('[ja>vi] こんにちは、みなさん'), findsOneWidget);
      expect(env.translator.translations.length, calls);
      await unmount(tester);
    });
  });

  group('comments, reviews and LFG notes', () {
    testWidgets('comments', (tester) async {
      env.translator.downloaded.add('en');
      env.server
        ..json('GET /v1/posts/p1', postJson('p1'))
        ..json(
          'GET /v1/posts/p1/comments',
          page([
            {...commentJson('c1', body: 'Nice skin!'), 'language': 'en'},
          ]),
        );
      await pumpCommunityRouter(
        tester,
        env,
        routes: [...communityBranchRoutes, ...communityTopLevelRoutes],
        initialLocation: '/post/p1',
      );
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('translate-button')));
      await settle(tester, frames: 20);
      expect(find.text('[en>vi] Nice skin!'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('reviews', (tester) async {
      env.translator.downloaded.add('de');
      env.server
        ..json('GET /v1/skins/*/summary', summaryJson())
        ..json(
          'GET /v1/skins/*/reviews',
          page([
            {...reviewJson('r1', body: 'Sehr schön'), 'language': 'de'},
          ]),
        );
      await pumpCommunity(
        tester,
        env,
        const SkinReviewScreen(skinUuid: reaverSkin),
        size: const Size(360, 2200),
      );
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('translate-button')));
      await settle(tester, frames: 20);
      expect(find.text('[de>vi] Sehr schön'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('LFG notes', (tester) async {
      env.translator.downloaded.add('ko');
      env.server.json(
        'GET /v1/lfg',
        page([
          {...lfgJson('l1', note: '같이 해요'), 'language': 'ko'},
        ]),
      );
      await pumpCommunityRouter(
        tester,
        env,
        routes: [...communityBranchRoutes, ...communityTopLevelRoutes],
        initialLocation: '/community?section=lfg',
      );
      await settle(tester);
      await tester.tap(find.byKey(const ValueKey('translate-button')));
      await settle(tester, frames: 20);
      expect(find.text('[ko>vi] 같이 해요'), findsOneWidget);
      await unmount(tester);
    });
  });

  testWidgets('no overflow at 360 dp × 2.0 while translated', (tester) async {
    env.translator.downloaded.add('ja');
    _servePosts(env);
    await pumpCommunityRouter(
      tester,
      env,
      routes: [...communityBranchRoutes, ...communityTopLevelRoutes],
      initialLocation: CommunityRoutes.root,
      size: const Size(360, 2400),
      textScale: 2,
    );
    await settle(tester);
    await tester.tap(find.byKey(const ValueKey('translate-button')));
    await settle(tester, frames: 20);
    expect(tester.takeException(), isNull);
    expect(find.text('[ja>vi] こんにちは、みなさん'), findsOneWidget);
    await unmount(tester);
  });
}
