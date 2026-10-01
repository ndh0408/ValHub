import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/l10n_fmt.dart';
import '../helpers/temp_dir.dart';

/// Builds ARB text from an ordered list of entries.
String arb(List<(String, Object?)> entries) =>
    const JsonEncoder.withIndent('  ')
        .convert({for (final (k, v) in entries) k: v});

List<String> keysOf(String arbText) =>
    (jsonDecode(arbText) as Map<String, Object?>).keys.toList();

void main() {
  group('prefixIndex', () {
    test('known namespaces map to their canonical position', () {
      expect(prefixIndex('commonRetry'), 0);
      expect(prefixIndex('contentQueueNamesCompetitive'), 1);
      expect(
        prefixIndex('battlePassLevelOf'),
        kKeyPrefixOrder.indexOf('battlePass'),
      );
      expect(
        prefixIndex('skinDetailTitle'),
        kKeyPrefixOrder.indexOf('skinDetail'),
      );
      expect(
        prefixIndex('liveGameHeader'),
        kKeyPrefixOrder.indexOf('liveGame'),
      );
      expect(prefixIndex('homeGreeting'), kKeyPrefixOrder.indexOf('home'));
    });

    test('community is not common, and the prefix must end at a word', () {
      expect(
        prefixIndex('communityPosts'),
        kKeyPrefixOrder.indexOf('community'),
      );
      expect(prefixIndex('commonality'), kKeyPrefixOrder.length);
      expect(prefixIndex('common'), kKeyPrefixOrder.length);
      expect(prefixIndex('storefront'), kKeyPrefixOrder.length);
    });

    test('unknown namespaces sort after every known one', () {
      expect(prefixIndex('smokePlain'), kKeyPrefixOrder.length);
      expect(prefixIndex('zzz'), kKeyPrefixOrder.length);
    });

    test('the fixed order of the design is intact (home appended)', () {
      expect(kKeyPrefixOrder.take(19), [
        'common',
        'content',
        'account',
        'auth',
        'notification',
        'competitive',
        'economy',
        'loadout',
        'battlePass',
        'collection',
        'community',
        'liveGame',
        'profile',
        'legal',
        'settings',
        'skinDetail',
        'social',
        'store',
        'wishlist',
      ]);
      expect(kKeyPrefixOrder.skip(19), ['home', 'communityError']);
    });
  });

  group('the strings classes and their namespaces', () {
    // (class, prefix) pairs of the codemod's table, in its order.
    List<(String, String)> table() {
      final source = File('tool/l10n_codemod/lib/src/known_classes.dart')
          .readAsStringSync();
      return [
        for (final m in RegExp(
          r"'([A-Za-z]+Strings)':\s*'([A-Za-z]+)'",
        ).allMatches(source))
          (m.group(1)!, m.group(2)!),
      ];
    }

    test("the codemod's class table follows the namespace order", () {
      expect(table().map((e) => e.$2).toList(), kKeyPrefixOrder);
      for (final (cls, prefix) in table()) {
        expect(
          cls,
          '${prefix[0].toUpperCase()}${prefix.substring(1)}Strings',
          reason: 'class names derive from the prefix',
        );
      }
    });

    test('every *Strings class of lib/ is in that table', () {
      final found = <String>{};
      for (final f in Directory('lib').listSync(recursive: true)) {
        if (f is! File || !f.path.endsWith('_strings.dart')) continue;
        for (final m in RegExp(
          r'class\s+(\w+Strings)',
        ).allMatches(f.readAsStringSync())) {
          found.add(m.group(1)!);
        }
      }
      expect(
        found,
        table().map((e) => e.$1).toSet(),
        reason:
            'a new *Strings class needs an entry in '
            'tool/l10n_codemod/lib/src/known_classes.dart and its prefix in '
            'kKeyPrefixOrder (tool/l10n_fmt.dart): the migration extracts '
            'exactly these classes',
      );
    });
  });

  group('formatArb (template)', () {
    final messy = arb([
      ('storeBuy', 'Mua'),
      ('@@locale', 'vi'),
      ('commonRetry', 'Thử lại'),
      (
        '@commonRetry',
        {
          'x-example': 'Thử lại',
          'x-context': 'common',
          'description': 'Retry button',
        },
      ),
      ('storeSell', 'Bán'),
      ('commonOk', 'OK'),
      ('mystery', 'lạ'),
      ('@orphan', {'description': 'no message'}),
    ]);

    test('starts with @@locale, then groups messages by namespace', () {
      final out = formatArb(messy);
      expect(keysOf(out), [
        '@@locale',
        'commonRetry',
        '@commonRetry',
        'commonOk',
        'storeBuy',
        'storeSell',
        'mystery',
        '@orphan',
      ]);
    });

    test('keeps the existing order inside a namespace (stable)', () {
      final out = formatArb(
        arb([
          ('@@locale', 'vi'),
          ('commonZ', 'z'),
          ('commonA', 'a'),
          ('commonM', 'm'),
        ]),
      );
      expect(keysOf(out), ['@@locale', 'commonZ', 'commonA', 'commonM']);
    });

    test('metadata: description, placeholders, then sorted extras', () {
      final out = formatArb(messy);
      final meta =
          (jsonDecode(out) as Map<String, Object?>)['@commonRetry']!
              as Map<String, Object?>;
      expect(meta.keys.toList(), ['description', 'x-context', 'x-example']);
    });

    test('placeholder ORDER is kept, attributes inside one are sorted', () {
      final out = formatArb(
        arb([
          ('@@locale', 'vi'),
          ('socialScore', '{ally} - {enemy} on {map}'),
          (
            '@socialScore',
            {
              'placeholders': {
                'map': {'type': 'String'},
                'ally': {'type': 'int', 'format': 'decimalPattern'},
                'enemy': {'type': 'int'},
              },
              'description': 'd',
            },
          ),
        ]),
      );
      final meta =
          (jsonDecode(out) as Map<String, Object?>)['@socialScore']!
              as Map<String, Object?>;
      final placeholders = meta['placeholders']! as Map<String, Object?>;
      expect(placeholders.keys.toList(), ['map', 'ally', 'enemy']);
      expect((placeholders['ally']! as Map<String, Object?>).keys.toList(), [
        'format',
        'type',
      ]);
    });

    test('is two-space JSON with LF and one trailing newline', () {
      final out = formatArb(messy);
      expect(out.endsWith('}\n'), isTrue);
      expect(out.endsWith('\n\n'), isFalse);
      expect(out, isNot(contains('\r')));
      expect(out, contains('\n  "@@locale": "vi",\n'));
    });

    test('is idempotent', () {
      final once = formatArb(messy);
      expect(formatArb(once), once);
    });

    test('never changes a message value (diacritics, braces, escapes)', () {
      const value = 'Trận đấu {n, plural, other{{n} thắng}} \n "tab"\t';
      final out = formatArb(arb([('@@locale', 'vi'), ('commonX', value)]));
      expect((jsonDecode(out) as Map<String, Object?>)['commonX'], value);
      // Non-ASCII stays literal, not \u escaped.
      expect(out, contains('Trận đấu'));
    });

    test('rejects invalid JSON and non-objects', () {
      expect(() => formatArb('{oops'), throwsFormatException);
      expect(() => formatArb('[1, 2]'), throwsFormatException);
      expect(() => formatArb('"text"'), throwsFormatException);
    });
  });

  group('formatArb (other locale)', () {
    test('follows the template order, unknown keys last', () {
      final out = formatArb(
        arb([
          ('@@locale', 'de'),
          ('storeBuy', 'Kaufen'),
          ('brandNew', 'Neu'),
          ('commonRetry', 'Wiederholen'),
        ]),
        templateKeyOrder: ['commonRetry', 'storeBuy'],
      );
      expect(keysOf(out), ['@@locale', 'commonRetry', 'storeBuy', 'brandNew']);
    });
  });

  group('formatDirectory', () {
    late Directory dir;
    setUp(() {
      dir = Directory.systemTemp.createTempSync('l10n_fmt_test');
      addTearDown(() => deleteTempDir(dir));
    });

    void put(String name, String text) =>
        File('${dir.path}/$name').writeAsStringSync(text);
    String read(String name) => File('${dir.path}/$name').readAsStringSync();

    test('reports without writing, then fixes, then reports clean', () {
      final messy = arb([
        ('storeBuy', 'Mua'),
        ('@@locale', 'vi'),
        ('commonRetry', 'Thử lại'),
      ]);
      put('app_vi.arb', messy);

      final check = formatDirectory(dir.path, write: false);
      expect(check.changed, ['app_vi.arb']);
      expect(read('app_vi.arb'), messy);

      final write = formatDirectory(dir.path, write: true);
      expect(write.changed, ['app_vi.arb']);
      expect(keysOf(read('app_vi.arb')), [
        '@@locale',
        'commonRetry',
        'storeBuy',
      ]);

      final clean = formatDirectory(dir.path, write: false);
      expect(clean.changed, isEmpty);
      expect(clean.errors, isEmpty);
    });

    test('other locales are ordered like the canonical template', () {
      put(
        'app_vi.arb',
        arb([
          ('@@locale', 'vi'),
          ('storeBuy', 'Mua'),
          ('commonRetry', 'Thử lại'),
        ]),
      );
      put(
        'app_de.arb',
        arb([
          ('@@locale', 'de'),
          ('storeBuy', 'Kaufen'),
          ('commonRetry', 'Wiederholen'),
        ]),
      );
      formatDirectory(dir.path, write: true);
      expect(keysOf(read('app_de.arb')), [
        '@@locale',
        'commonRetry',
        'storeBuy',
      ]);
    });

    test('a CRLF working copy of canonical text counts as canonical', () {
      final canonical = formatArb(
        arb([('@@locale', 'vi'), ('commonRetry', 'x')]),
      );
      put('app_vi.arb', canonical.replaceAll('\n', '\r\n'));
      expect(formatDirectory(dir.path, write: false).changed, isEmpty);
    });

    test('a broken file is an error, the others are still formatted', () {
      put('app_vi.arb', '{nope');
      put('app_de.arb', arb([('@@locale', 'de'), ('b', '1'), ('a', '2')]));
      final report = formatDirectory(dir.path, write: false);
      expect(report.errors.single, startsWith('app_vi.arb: not valid JSON'));
    });

    test('ignores files that are not app_*.arb', () {
      put('notes.txt', 'hello');
      put('other.arb', '{oops');
      put('app_vi.arb', formatArb(arb([('@@locale', 'vi')])));
      final report = formatDirectory(dir.path, write: false);
      expect(report.changed, isEmpty);
      expect(report.errors, isEmpty);
    });

    test('a missing directory is an error', () {
      final report = formatDirectory('${dir.path}/nope', write: false);
      expect(report.errors.single, contains('directory not found'));
    });
  });
}
