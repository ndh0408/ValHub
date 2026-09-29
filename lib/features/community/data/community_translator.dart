import 'package:flutter/foundation.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';

import 'community_models.dart';

/// On-device translation of community text (posts, comments, reviews, LFG
/// notes). Nothing is sent to any server: ML Kit downloads a language model
/// once and translates locally.
abstract interface class CommunityTranslator {
  /// Whether this platform can translate on the device (Android / iOS).
  bool get isSupported;

  /// Whether [code] (a community language code) has an on-device model.
  bool supportsLanguage(String code);

  /// Whether the model of [code] is already on the device.
  Future<bool> isDownloaded(String code);

  /// Downloads the model of [code] (asked for by the user beforehand).
  Future<void> download(String code);

  /// Translates [text] from [from] to [to] (community language codes).
  Future<String> translate(
    String text, {
    required String from,
    required String to,
  });
}

/// Approximate size of one ML Kit language model (Google documents ~30 MB).
const kTranslationModelMb = 30;

/// Languages that are the same ML Kit model / script: `zh-CN` and `zh-TW`
/// both use ML Kit's single "Chinese".
String translationGroup(String code) =>
    code.toLowerCase().startsWith('zh') ? 'zh' : code.toLowerCase();

/// Whether a "Dịch" button makes sense for [text] written in [source] when
/// the reader's app language is [target]: known source language, different
/// language, some text.
bool shouldOfferTranslation(String text, String? source, String target) {
  if (text.trim().isEmpty) return false;
  if (source == null || source == kLfgAnyLanguage) return false;
  return translationGroup(source) != translationGroup(target);
}

/// The ML Kit language of a community language code.
TranslateLanguage? mlKitLanguage(String code) => switch (code) {
  'ar' => TranslateLanguage.arabic,
  'de' => TranslateLanguage.german,
  'en' => TranslateLanguage.english,
  'es' => TranslateLanguage.spanish,
  'fr' => TranslateLanguage.french,
  'id' => TranslateLanguage.indonesian,
  'it' => TranslateLanguage.italian,
  'ja' => TranslateLanguage.japanese,
  'ko' => TranslateLanguage.korean,
  'pl' => TranslateLanguage.polish,
  'pt' => TranslateLanguage.portuguese,
  'ru' => TranslateLanguage.russian,
  'th' => TranslateLanguage.thai,
  'tr' => TranslateLanguage.turkish,
  'vi' => TranslateLanguage.vietnamese,
  'zh-CN' || 'zh-TW' => TranslateLanguage.chinese,
  _ => null,
};

/// [CommunityTranslator] backed by Google ML Kit (Android / iOS).
class MlKitCommunityTranslator implements CommunityTranslator {
  MlKitCommunityTranslator();

  final OnDeviceTranslatorModelManager _models =
      OnDeviceTranslatorModelManager();

  @override
  bool get isSupported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  @override
  bool supportsLanguage(String code) => mlKitLanguage(code) != null;

  @override
  Future<bool> isDownloaded(String code) async {
    final lang = mlKitLanguage(code);
    if (lang == null) return false;
    return _models.isModelDownloaded(lang.bcpCode);
  }

  @override
  Future<void> download(String code) async {
    final lang = mlKitLanguage(code);
    if (lang == null) throw ArgumentError('unsupported language');
    final ok = await _models.downloadModel(
      lang.bcpCode,
      // The user confirmed the download (with its size) beforehand.
      isWifiRequired: false,
    );
    if (!ok) throw StateError('model download failed');
  }

  @override
  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async {
    final source = mlKitLanguage(from);
    final target = mlKitLanguage(to);
    if (source == null || target == null) {
      throw ArgumentError('unsupported language');
    }
    final translator = OnDeviceTranslator(
      sourceLanguage: source,
      targetLanguage: target,
    );
    try {
      return await translator.translateText(text);
    } finally {
      await translator.close();
    }
  }
}

/// No translation on this platform: the button never shows.
class UnsupportedCommunityTranslator implements CommunityTranslator {
  const UnsupportedCommunityTranslator();

  @override
  bool get isSupported => false;

  @override
  bool supportsLanguage(String code) => false;

  @override
  Future<bool> isDownloaded(String code) async => false;

  @override
  Future<void> download(String code) async =>
      throw UnsupportedError('translation');

  @override
  Future<String> translate(
    String text, {
    required String from,
    required String to,
  }) async => throw UnsupportedError('translation');
}
