import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/community_translator.dart';

/// On-device translator (ML Kit on Android / iOS; overridden in tests).
final communityTranslatorProvider = Provider<CommunityTranslator>(
  (ref) =>
      defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS
      ? MlKitCommunityTranslator()
      : const UnsupportedCommunityTranslator(),
);

/// Cache key of one translation.
String translationKey(String from, String to, String text) => '$from>$to|$text';

/// Translations made in this run (a small LRU), so scrolling a translated
/// post back into view keeps its translation.
final translationCacheProvider =
    NotifierProvider<TranslationCache, Map<String, String>>(
      TranslationCache.new,
    );

class TranslationCache extends Notifier<Map<String, String>> {
  static const capacity = 200;

  @override
  Map<String, String> build() => const {};

  void put(String key, String value) {
    final next = {...state}..remove(key);
    next[key] = value;
    while (next.length > capacity) {
      next.remove(next.keys.first);
    }
    state = next;
  }
}
