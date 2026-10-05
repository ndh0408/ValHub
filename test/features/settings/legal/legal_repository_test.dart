import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/settings/legal/legal_documents.dart';

Map<String, dynamic> fixture(String id, String locale) {
  final data = jsonDecode(
    File('assets/legal/vi/$id.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  data['locale'] = locale;
  if (locale == 'en') data['title'] = 'English legal fixture';
  return data;
}

Map<String, dynamic> firstSection(Map<String, dynamic> document) =>
    (document['sections'] as List).first as Map<String, dynamic>;

void main() {
  test(
    'all bundled documents retain every published clause byte for byte',
    () async {
      final repository = LegalRepository(
        (path) async =>
            File(path).existsSync() ? File(path).readAsStringSync() : null,
      );
      for (final reference in LegalDocuments.all) {
        final doc = await repository.load(reference.id, locale: 'vi');
        expect(
          legalDocumentToMarkdown(doc).replaceAll('\r\n', '\n'),
          File('docs/legal/${doc.id}.md')
              .readAsStringSync()
              .replaceAll('\r\n', '\n'),
        );
      }
    },
  );

  test(
    'uses requested language, English fallback, then authoritative Vietnamese',
    () async {
      final assets = <String, String>{
        'assets/legal/vi/terms.json': jsonEncode(fixture('terms', 'vi')),
        'assets/legal/en/terms.json': jsonEncode(fixture('terms', 'en')),
        'assets/legal/fr/terms.json': jsonEncode(fixture('terms', 'fr')),
      };
      final read = <String>[];
      final repository = LegalRepository((path) async {
        read.add(path);
        return assets[path];
      });
      expect((await repository.load('terms', locale: 'fr')).locale, 'fr');
      expect((await repository.load('terms', locale: 'de')).locale, 'en');
      expect(read.where((p) => p.endsWith('vi/terms.json')), hasLength(1));
      final viOnly = LegalRepository(
        (path) async => path.contains('/vi/') ? assets[path] : null,
      );
      expect((await viOnly.load('terms', locale: 'ar')).locale, 'vi');
    },
  );

  test(
    'concurrent reads share one asset read without sharing current language',
    () async {
      final reads = <String, int>{};
      final repository = LegalRepository((path) async {
        reads[path] = (reads[path] ?? 0) + 1;
        if (path == 'assets/legal/vi/privacy.json') {
          return jsonEncode(fixture('privacy', 'vi'));
        }
        if (path == 'assets/legal/en/privacy.json') {
          return jsonEncode(fixture('privacy', 'en'));
        }
        return null;
      });
      final results = await Future.wait([
        repository.load('privacy', locale: 'en'),
        repository.load('privacy', locale: 'en'),
        repository.load('privacy', locale: 'vi'),
      ]);
      expect(results.map((d) => d.locale), ['en', 'en', 'vi']);
      expect(reads.values.every((count) => count == 1), isTrue);
    },
  );

  test(
    'corrupt present translation fails and a repaired asset can be retried',
    () async {
      var repaired = false;
      final repository = LegalRepository((path) async {
        if (path.contains('/vi/')) return jsonEncode(fixture('terms', 'vi'));
        if (path.contains('/en/')) {
          return repaired
              ? jsonEncode(fixture('terms', 'en'))
              : '<html>bad</html>';
        }
        return null;
      });
      await expectLater(
        repository.load('terms', locale: 'en'),
        throwsFormatException,
      );
      repaired = true;
      expect((await repository.load('terms', locale: 'en')).locale, 'en');
    },
  );

  test(
    'identity, version, date and missing clauses cannot silently fall back',
    () async {
      for (final change in <void Function(Map<String, dynamic>)>[
        (d) => d['id'] = 'privacy',
        (d) => d['locale'] = 'fr',
        (d) => d['version'] = '0.0',
        (d) => d['effectiveDate'] = '01/01/2000',
        (d) => (d['sections'] as List).removeLast(),
        (d) => (firstSection(d)['blocks'] as List).removeLast(),
        (d) =>
            ((firstSection(d)['blocks'] as List).first
                    as Map<String, dynamic>)['type'] =
                'unknown',
      ]) {
        final bad = fixture('terms', 'en');
        change(bad);
        final repository = LegalRepository(
          (path) async =>
              jsonEncode(path.contains('/vi/') ? fixture('terms', 'vi') : bad),
        );
        await expectLater(
          repository.load('terms', locale: 'en'),
          throwsFormatException,
        );
      }
    },
  );

  test('missing authoritative source and oversized body fail closed', () async {
    await expectLater(
      LegalRepository((_) async => null).load('terms', locale: 'en'),
      throwsStateError,
    );
    await expectLater(
      LegalRepository((_) async => 'x' * (256 * 1024 + 1))
          .load('terms', locale: 'vi'),
      throwsFormatException,
    );
  });

  test('invalid paths never reach the reader', () async {
    final repository = LegalRepository(
      (_) async => throw StateError('Reader must not run'),
    );
    for (final id in ['../../private', 'unknown', '/terms', 'Terms']) {
      await expectLater(
        repository.load(id, locale: 'vi'),
        throwsFormatException,
      );
    }
    for (final locale in ['../en', 'en/../../', 'en\\..', '', 'EN']) {
      await expectLater(
        repository.load('terms', locale: locale),
        throwsFormatException,
      );
    }
  });
}
