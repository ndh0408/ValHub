import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateProvider;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/background_locale.dart';
import 'package:valvn/core/l10n/locale_controller.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';

import '../helpers/test_prefs.dart';

class _Repository extends Mock implements ContentRepository {}

class _DelayedPrefs implements Prefs {
  Object? json;
  final writes = <({Object? value, Completer<void> done})>[];
  @override
  Object? getJson(String key) => json;
  @override
  Future<void> setJson(String key, Object? value) async {
    final done = Completer<void>();
    writes.add((value: value, done: done));
    await done.future;
    json = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'legacy choices migrate without changing English preference or upgrade pin',
    () {
      final vi = AppSettings.fromJson({'itemLanguage': 'vi'});
      final en = AppSettings.fromJson({'itemLanguage': 'en'});
      expect(vi.contentLocale, 'app');
      expect(vi.contentLanguage(AppLocale.vi), AppLocale.vi);
      expect(en.contentLocale, 'en-US');
      expect(en.contentLanguage(AppLocale.ja), AppLocale.en);
      expect(AppSettings.fromJson(en.toJson()), en);
      expect(vi.copyWith(themeMode: ThemeMode.light).contentLocale, 'app');
    },
  );

  test(
    'all 18 content tags survive settings round-trip, independent of UI',
    () {
      for (final locale in AppLocale.values) {
        final settings = AppSettings(contentLocale: locale.tag);
        final restored = AppSettings.fromJson(settings.toJson());
        expect(restored.contentLanguage(AppLocale.vi), locale);
        expect(restored.contentLocale, locale.tag);
        expect(
          settings.copyWith(showLiveScore: false).contentLocale,
          locale.tag,
        );
      }
      expect(
        AppSettings.fromJson({
          'contentLocale': '../../en-US',
          'itemLanguage': 'en',
        }).contentLocale,
        'app',
      );
      expect(
        AppSettings.fromJson({'contentLocale': null}).contentLocale,
        'app',
      );
      expect(
        AppSettings(contentLocale: 'ja-JP')
            .copyWith(contentLocale: 'app')
            .contentLanguage(AppLocale.en),
        AppLocale.en,
      );
    },
  );

  test('content provider reloads only the selected content language', () async {
    final prefs = await createTestPrefs();
    final repo = _Repository();
    when(() => repo.updates).thenAnswer((_) => const Stream.empty());
    for (final language in ['vi-VN', 'ja-JP', 'en-US']) {
      when(() => repo.load(language: language))
          .thenAnswer((_) async => ContentDb.empty(language: language));
    }
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        contentRepositoryProvider.overrideWithValue(repo),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(contentProvider, (_, _) {});
    addTearDown(subscription.close);
    expect((await container.read(contentProvider.future)).language, 'vi-VN');
    await container
        .read(appSettingsProvider.notifier)
        .setContentLocale('ja-JP');
    expect(container.read(appLocaleProvider), AppLocale.vi);
    expect((await container.read(contentProvider.future)).language, 'ja-JP');
    expect(container.read(effectiveLocaleProvider).content, 'ja-JP');
    await container
        .read(appSettingsProvider.notifier)
        .setThemeMode(ThemeMode.light);
    expect((await container.read(contentProvider.future)).language, 'ja-JP');
    verify(() => repo.load(language: 'ja-JP')).called(1);
    await container.read(appSettingsProvider.notifier).setContentLocale('app');
    expect((await container.read(contentProvider.future)).language, 'vi-VN');
    expect(readAppSettings(prefs).contentLocale, 'app');
  });

  test('follow-app content tracks UI, explicit content stays pinned', () async {
    final prefs = await createTestPrefs();
    final app = StateProvider<AppLocale>((ref) => AppLocale.vi);
    final container = ProviderContainer(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        appLocaleProvider.overrideWith((ref) => ref.watch(app)),
      ],
    );
    addTearDown(container.dispose);
    expect(container.read(contentLocaleProvider), AppLocale.vi);
    container.read(app.notifier).state = AppLocale.en;
    expect(container.read(contentLocaleProvider), AppLocale.en);
    await container
        .read(appSettingsProvider.notifier)
        .setContentLocale('zh-TW');
    container.read(app.notifier).state = AppLocale.ja;
    expect(container.read(contentLocaleProvider), AppLocale.zhHant);
    expect(container.read(effectiveLocaleProvider).content, 'zh-TW');
  });

  test(
    'headless work reads fresh content choice when locale handoff is stale',
    () async {
      final prefs = await createTestPrefs();
      await const EffectiveLocale(
        app: AppLocale.vi,
        formatTag: 'vi',
        h24: true,
        content: 'en-US',
      ).write(prefs);
      await prefs.setJson(
        PrefKeys.appSettings,
        AppSettings(contentLocale: 'th-TH').toJson(),
      );
      final background = BackgroundLocale.fromPrefs(prefs);
      expect(background.effective.app, AppLocale.vi);
      expect(background.effective.content, 'th-TH');
      expect(EffectiveLocale.read(prefs)!.content, 'en-US');
    },
  );

  test(
    'rapid settings writes are ordered and retain unrelated preferences',
    () async {
      final prefs = _DelayedPrefs();
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(appSettingsProvider.notifier);
      final first = notifier.setContentLocale('ja-JP');
      final second = notifier.setThemeMode(ThemeMode.light);
      await Future<void>.delayed(Duration.zero);
      expect(prefs.writes, hasLength(1));
      prefs.writes[0].done.complete();
      await first;
      await Future<void>.delayed(Duration.zero);
      expect(prefs.writes, hasLength(2));
      prefs.writes[1].done.complete();
      await second;
      final saved = AppSettings.fromJson(prefs.json);
      expect(saved.contentLocale, 'ja-JP');
      expect(saved.themeMode, ThemeMode.light);
    },
  );

  test(
    'failed content setting rolls back and does not block the next write',
    () async {
      final prefs = _DelayedPrefs();
      final container = ProviderContainer(
        overrides: [prefsProvider.overrideWithValue(prefs)],
      );
      addTearDown(container.dispose);
      final notifier = container.read(appSettingsProvider.notifier);
      final first = notifier.setContentLocale('ja-JP');
      final failure = expectLater(first, throwsStateError);
      await Future<void>.delayed(Duration.zero);
      prefs.writes[0].done.completeError(StateError('disk failure'));
      await failure;
      expect(container.read(appSettingsProvider).contentLocale, 'app');
      final second = notifier.setContentLocale('th-TH');
      await Future<void>.delayed(Duration.zero);
      prefs.writes[1].done.complete();
      await second;
      expect(AppSettings.fromJson(prefs.json).contentLocale, 'th-TH');
    },
  );
}
