import 'dart:convert';

import 'legal_document.dart';

/// Null means an asset is absent; read errors and invalid documents must throw.
typedef ReadLegalAsset = Future<String?> Function(String path);

/// Bundled, versioned legal content, independent of Flutter and the UI locale.
/// Missing translations fall back locale -> English -> Vietnamese. A corrupt
/// translation is an error, never silently replaced with different legal text.
final class LegalRepository {
  LegalRepository(this.read);

  final ReadLegalAsset read;
  final _cache = <String, Future<LegalDocument?>>{};

  Future<LegalDocument?> _asset(String locale, String id) {
    final path = 'assets/legal/$locale/$id.json';
    return _cache.putIfAbsent(path, () async {
      try {
        final text = await read(path);
        if (text == null) return null;
        if (text.length > 256 * 1024) {
          throw const FormatException('Legal asset exceeds size limit');
        }
        final doc = LegalDocument.fromJson(jsonDecode(text));
        if (doc.id != id || doc.locale != locale) {
          throw const FormatException('Legal asset identity mismatch');
        }
        if (!doc.exportMetadata.contains(doc.version) ||
            !doc.exportMetadata.contains(doc.effectiveDate)) {
          throw const FormatException('Legal export metadata mismatch');
        }
        return doc;
      } on Object {
        // A failed read must not poison retries for the lifetime of the app.
        _cache.removeWhere((key, _) => key == path);
        rethrow;
      }
    });
  }

  Future<LegalDocument> load(String id, {required String locale}) async {
    if (!const {'privacy', 'terms', 'community', 'notice'}.contains(id) ||
        !RegExp(r'^[a-z]{2}(?:_[A-Za-z]{2,4})?$').hasMatch(locale)) {
      throw const FormatException('Invalid legal asset request');
    }
    final source = await _asset('vi', id);
    if (source == null) throw StateError('Missing authoritative legal asset');
    for (final candidate in {locale, 'en', 'vi'}) {
      final doc = candidate == 'vi' ? source : await _asset(candidate, id);
      if (doc == null) continue;
      if (!doc.hasSameStructureAs(source)) {
        throw const FormatException('Legal translation structure mismatch');
      }
      return doc;
    }
    return source;
  }
}
