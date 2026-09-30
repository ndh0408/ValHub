import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/l10n/app_locale.dart';

import '../../tool/l10n_check.dart';
import '../helpers/temp_dir.dart';

/// A message with metadata, the way the template declares it.
Map<String, Object?> msg(
  String text, {
  Map<String, String>? placeholders,
  bool locked = false,
}) => {
  'text': text,
  'meta': {
    'description': 'd',
    if (placeholders != null)
      'placeholders': {
        for (final e in placeholders.entries) e.key: {'type': e.value},
      },
    if (locked) 'x-locked': true,
  },
};

/// A throw-away project with lib/l10n/arb, the AppLocale source and (optional)
/// tool/l10n/allowlist.yaml.
class Project {
  Project() : dir = Directory.systemTemp.createTempSync('l10n_check_test') {
    addTearDown(() => deleteTempDir(dir));
    Directory('${dir.path}/lib/l10n/arb').createSync(recursive: true);
    Directory('${dir.path}/lib/core/l10n').createSync(recursive: true);
  }

  final Directory dir;

  /// Writes app_<code>.arb; [messages] are `key -> msg(...)` or a plain String
  /// (a bare message without metadata, as non-template locales have).
  void arb(
    String code,
    Map<String, Object?> messages, {
    Object? locale = _sameAsCode,
  }) {
    final out = <String, Object?>{
      '@@locale': locale == _sameAsCode ? code : locale,
    };
    for (final e in messages.entries) {
      final v = e.value;
      if (v is Map<String, Object?>) {
        out[e.key] = v['text'];
        out['@${e.key}'] = v['meta'];
      } else {
        out[e.key] = v;
      }
    }
    if (locale == null) out.remove('@@locale');
    File('${dir.path}/lib/l10n/arb/app_$code.arb')
        .writeAsStringSync(jsonEncode(out));
  }

  void raw(String name, String text) =>
      File('${dir.path}/lib/l10n/arb/$name').writeAsStringSync(text);

  /// The AppLocale source: one entry per [codes], [shipped] in the set.
  void appLocale(List<String> codes, List<String> shipped) {
    String name(String c) => c.replaceAll('_', '');
    final entries = codes
        .map(
          (c) =>
              "  ${name(c)}(\n    flutter: Locale('$c'),\n    arbCode: '$c',\n  ),",
        )
        .join('\n');
    File('${dir.path}/lib/core/l10n/app_locale.dart').writeAsStringSync(
      'enum AppLocale {\n$entries;\n}\n'
      'const Set<AppLocale> kShippedLocales = '
      '{${shipped.map((c) => 'AppLocale.${name(c)}').join(', ')}};\n',
    );
  }

  void allowlist(String text) {
    Directory('${dir.path}/tool/l10n').createSync(recursive: true);
    File('${dir.path}/tool/l10n/allowlist.yaml').writeAsStringSync(text);
  }

  CheckResult check() => checkProject(root: dir.path);
}

const Object _sameAsCode = Object();

extension on CheckResult {
  List<String> codes(Severity s) => [
    for (final f in findings)
      if (f.severity == s) f.code,
  ];

  Iterable<Finding> withCode(String code) =>
      findings.where((f) => f.code == code);
}

/// A minimal valid project: template + AppLocale with vi (shipped) and [more].
Project valid({
  Map<String, Object?>? template,
  List<String> more = const [],
  List<String> shipped = const ['vi'],
}) {
  final p = Project();
  p.appLocale(['vi', ...more], shipped);
  p.arb(
    'vi',
    template ??
        {
          'commonRetry': msg('Thử lại'),
          'commonMinutesAgo': msg(
            '{n, plural, other{{n} phút trước}}',
            placeholders: {'n': 'int'},
          ),
        },
  );
  return p;
}

void main() {
  group('ICU parser', () {
    test('plain text and arguments', () {
      final nodes = parseIcu('Xin chào, {name}! Bạn có {n} mục.');
      expect(icuArguments(nodes), {'name', 'n'});
      expect(nodes.whereType<IcuText>().map((t) => t.text), [
        'Xin chào, ',
        '! Bạn có ',
        ' mục.',
      ]);
    });

    test('plural with exact and category cases, nested arguments', () {
      final nodes = parseIcu(
        '{n, plural, =0{Không có} one{{n} mục} other{{n} mục ({who})}}',
      );
      final plural = icuPlurals(nodes).single;
      expect(plural.name, 'n');
      expect(plural.cases.keys, ['=0', 'one', 'other']);
      expect(icuArguments(nodes), {'n', 'who'});
    });

    test('select and plural inside a select', () {
      final nodes = parseIcu(
        '{region, select, ap{Châu Á} eu{Châu Âu} other{{region}}} '
        '{g, select, a{{n, plural, other{{n}}}} other{x}}',
      );
      expect(icuArguments(nodes), {'region', 'g', 'n'});
      expect(icuPlurals(nodes), hasLength(1));
    });

    test('whitespace around names, types and cases is fine', () {
      final nodes = parseIcu('{ n , plural , other { {n} } }');
      expect(icuArguments(nodes), {'n'});
    });

    test('an apostrophe is a literal (use-escaping: false)', () {
      final nodes = parseIcu("L'utilisateur d'{name}");
      expect(icuArguments(nodes), {'name'});
    });

    for (final bad in [
      'oops }',
      'oops {',
      '{}',
      '{1a}',
      '{n, plural}',
      '{n, plural, }',
      '{n, plural, other{x}',
      '{n, plural, other{x} other{y}}',
      '{n, number}',
      '{n plural, other{x}}',
      '{n, plural, =x{a} other{b}}',
      'literal { not an arg }',
    ]) {
      test('rejects "$bad"', () {
        expect(() => parseIcu(bad), throwsA(isA<IcuException>()));
      });
    }
  });

  group('AppLocale source reader', () {
    test('agrees with the real AppLocale enum', () {
      final info = parseAppLocaleSource(
        File('lib/core/l10n/app_locale.dart').readAsStringSync(),
      )!;
      expect(info.arbCodes, AppLocale.values.map((l) => l.arbCode).toSet());
      expect(info.shipped, kShippedLocales.map((l) => l.arbCode).toSet());
    });

    test('is null for a shape it does not know', () {
      expect(parseAppLocaleSource('class Nothing {}'), isNull);
    });
  });

  group('allowlist parser', () {
    test('sections, items and comments', () {
      final a = parseAllowlist('''
# top comment
number-word:   # trailing
  - ar.commonMinutesAgo.two
  - ru.commonDays   # inline

identical:
  - ja.commonOk
''');
      expect(a['number-word'], {'ar.commonMinutesAgo.two', 'ru.commonDays'});
      expect(a['identical'], {'ja.commonOk'});
    });
  });

  group('template and locales', () {
    test('a valid project passes', () {
      final p = valid(more: ['en', 'de']);
      p.arb('en', {
        'commonRetry': 'Retry',
        'commonMinutesAgo':
            '{n, plural, one{{n} minute ago} other{{n} minutes ago}}',
      });
      p.arb('de', {
        'commonRetry': 'Wiederholen',
        'commonMinutesAgo':
            '{n, plural, one{vor {n} Minute} other{vor {n} Minuten}}',
      });
      final result = p.check();
      expect(result.errors, isEmpty);
      // en and de are not shipped and complete: no warnings either.
      expect(result.warnings, isEmpty);
    });

    test('missing template', () {
      final p = Project()..appLocale(['vi'], ['vi']);
      p.arb('de', {'commonRetry': 'x'});
      expect(p.check().codes(Severity.error), contains('missing-template'));
    });

    test('missing arb directory', () {
      final p = Project();
      Directory('${p.dir.path}/lib/l10n/arb').deleteSync(recursive: true);
      expect(p.check().codes(Severity.error), ['missing-template']);
    });

    test('invalid JSON and non-object files', () {
      final p = valid(more: ['en', 'de']);
      p.raw('app_en.arb', '{oops');
      p.raw('app_de.arb', '[1]');
      expect(
        p.check().codes(Severity.error),
        containsAll(['bad-json', 'bad-json']),
      );
    });

    test('@@locale must match the file name', () {
      final p = valid(more: ['en']);
      p.arb('en', {'commonRetry': 'x'}, locale: 'de');
      expect(p.check().withCode('locale-mismatch'), hasLength(1));
      p.arb('en', {'commonRetry': 'x'}, locale: null);
      expect(p.check().withCode('locale-mismatch'), hasLength(1));
    });

    test('a file that is not an AppLocale is an error', () {
      final p = valid();
      p.arb('xx', {'commonRetry': 'x'});
      final f = p.check().withCode('unknown-locale').single;
      expect(f.file, 'app_xx.arb');
    });

    test('extra keys are always errors', () {
      final p = valid(more: ['en']);
      p.arb('en', {'commonRetry': 'x', 'commonNew': 'y'});
      final f = p.check().withCode('extra-key').single;
      expect(f.severity, Severity.error);
      expect(f.key, 'commonNew');
    });

    test('missing keys: warning while not shipped, error once shipped', () {
      final notShipped = valid(more: ['en']);
      notShipped.arb('en', {'commonRetry': 'x'});
      var f = notShipped.check().withCode('missing-key').single;
      expect(f.severity, Severity.warning);
      expect(f.message, contains('1 of 2 keys missing'));

      final shipped = valid(more: ['en'], shipped: ['vi', 'en']);
      shipped.arb('en', {'commonRetry': 'x'});
      f = shipped.check().withCode('missing-key').single;
      expect(f.severity, Severity.error);
    });

    test('es_MX is a delta and may omit keys', () {
      final p = valid(more: ['es_MX'], shipped: ['vi', 'es_MX']);
      p.arb('es_MX', {'commonRetry': 'x'});
      expect(p.check().withCode('missing-key'), isEmpty);
    });

    test('a shipped locale without a file', () {
      final p = valid(more: ['de'], shipped: ['vi', 'de']);
      final f = p.check().withCode('shipped-no-file').single;
      expect(f.file, 'app_de.arb');
    });

    test('kShippedLocales must keep a resolve() fallback', () {
      final p = Project()..appLocale(['vi', 'de'], ['de']);
      p.arb('vi', {'commonRetry': msg('x')});
      p.arb('de', {'commonRetry': 'y'});
      expect(p.check().withCode('shipped-fallback'), hasLength(1));
    });

    test('an unreadable AppLocale source is reported', () {
      final p = valid();
      File('${p.dir.path}/lib/core/l10n/app_locale.dart')
          .writeAsStringSync('class X {}');
      expect(p.check().withCode('app-locale-unreadable'), hasLength(1));
    });
  });

  group('template messages', () {
    test('metadata: orphan, description, bad meta', () {
      final p = Project()..appLocale(['vi'], ['vi']);
      p.raw(
        'app_vi.arb',
        jsonEncode({
          '@@locale': 'vi',
          'commonA': 'a',
          'commonB': 'b',
          '@commonB': {'description': '  '},
          '@ghost': {'description': 'x'},
          'commonC': 'c',
          '@commonC': 'not an object',
        }),
      );
      final r = p.check();
      expect(
        r.withCode('no-description').map((f) => f.key),
        containsAll(['commonA', 'commonB', 'commonC']),
      );
      expect(r.withCode('orphan-meta').single.key, 'ghost');
      expect(r.withCode('bad-meta').single.key, 'commonC');
    });

    test('key names', () {
      final p = valid(
        template: {
          'Common': msg('x'),
          'common_retry': msg('x'),
          'localeName': msg('x'),
          'of': msg('x'),
          'commonFine': msg('x'),
        },
      );
      final r = p.check();
      expect(
        r.withCode('bad-key').map((f) => f.key),
        containsAll(['Common', 'common_retry']),
      );
      expect(
        r.withCode('reserved-key').map((f) => f.key),
        containsAll(['localeName', 'of']),
      );
      expect(
        r.withCode('bad-key').map((f) => f.key),
        isNot(contains('commonFine')),
      );
    });

    test('namespaces: unknown ones warn, smoke is exempt', () {
      final p = valid(
        template: {
          'mysteryKey': msg('x'),
          'smokePlain': msg('x'),
          'storeBuy': msg('x'),
        },
      );
      final r = p.check();
      expect(r.withCode('unknown-namespace').map((f) => f.key), ['mysteryKey']);
      expect(r.withCode('unknown-namespace').single.severity, Severity.warning);
    });

    test('a message must be a string', () {
      final p = Project()..appLocale(['vi'], ['vi']);
      p.raw('app_vi.arb', jsonEncode({'@@locale': 'vi', 'commonA': 5}));
      expect(p.check().withCode('not-a-string').single.key, 'commonA');
    });

    test('placeholders: undeclared, unused, untyped', () {
      final p = valid(
        template: {
          'commonUndeclared': msg('Xin chào {name}'),
          'commonUnused': msg('Xin chào', placeholders: {'name': 'String'}),
          'commonUntyped': {
            'text': 'Xin chào {name}',
            'meta': {
              'description': 'd',
              'placeholders': {'name': <String, Object?>{}},
            },
          },
          'commonOk': msg('Xin chào {name}', placeholders: {'name': 'String'}),
        },
      );
      final r = p.check();
      expect(
        r.withCode('placeholder-undeclared').single.key,
        'commonUndeclared',
      );
      expect(r.withCode('placeholder-unused').single.key, 'commonUnused');
      expect(r.withCode('placeholder-type').single.key, 'commonUntyped');
    });

    test('a plural selector counts as a used placeholder', () {
      final p = valid(
        template: {
          'commonA': msg(
            '{n, plural, other{Nhiều}}',
            placeholders: {'n': 'int'},
          ),
        },
      );
      expect(p.check().errors, isEmpty);
    });

    test('ICU syntax errors and missing other', () {
      final p = valid(
        template: {
          'commonBrace': msg('sai {'),
          'commonNoOther': msg(
            '{n, plural, one{x}}',
            placeholders: {'n': 'int'},
          ),
          'commonSelect': msg(
            '{r, select, a{x}}',
            placeholders: {'r': 'String'},
          ),
        },
      );
      final r = p.check();
      expect(r.withCode('icu-syntax').single.key, 'commonBrace');
      expect(r.withCode('plural-other').single.key, 'commonNoOther');
      expect(r.withCode('select-other').single.key, 'commonSelect');
    });

    test('exact cases may omit the count, unknown categories are errors', () {
      final ok = valid(
        template: {
          'commonA': msg(
            '{n, plural, =0{Không có} other{{n} mục}}',
            placeholders: {'n': 'int'},
          ),
        },
      );
      expect(ok.check().errors, isEmpty);
      final bad = valid(
        template: {
          'commonA': msg(
            '{n, plural, several{x} other{y}}',
            placeholders: {'n': 'int'},
          ),
        },
      );
      expect(bad.check().withCode('plural-category'), hasLength(1));
    });
  });

  group('other locales', () {
    Project two(
      Map<String, Object?> template,
      Map<String, Object?> en, {
      List<String> more = const [],
    }) {
      final p = valid(template: template, more: ['en', ...more]);
      p.arb('en', en);
      return p;
    }

    test('placeholders must match the template', () {
      final p = two(
        {
          'commonA': msg(
            'Chào {a} và {b}',
            placeholders: {'a': 'String', 'b': 'String'},
          ),
        },
        {'commonA': 'Hi {a} and {c}'},
      );
      final f = p.check().withCode('placeholder-mismatch').single;
      expect(
        f.message,
        allOf(contains('missing {b}'), contains('unknown {c}')),
      );
    });

    test('ICU syntax errors in a translation', () {
      final p = two({'commonA': msg('x')}, {'commonA': 'broken {'});
      expect(p.check().withCode('icu-syntax').single.file, 'app_en.arb');
    });

    test('a translation must be a string', () {
      final p = valid(more: ['en']);
      p.raw('app_en.arb', jsonEncode({'@@locale': 'en', 'commonRetry': 5}));
      expect(p.check().withCode('not-a-string'), hasLength(1));
    });

    test('locked messages must be identical', () {
      final p = two(
        {
          'commonVp': msg('VP', locked: true),
          'commonKc': msg('KC', locked: true),
        },
        {'commonVp': 'VP', 'commonKc': 'Kc'},
      );
      expect(p.check().withCode('locked-differs').single.key, 'commonKc');
    });

    test('plural categories required by the locale', () {
      final template = {
        'commonA': msg(
          '{n, plural, other{{n} phút}}',
          placeholders: {'n': 'int'},
        ),
      };
      // en needs one + other.
      var p = two(template, {'commonA': '{n, plural, other{{n} minutes}}'});
      expect(
        p.check().withCode('plural-category').single.message,
        contains('one'),
      );
      // ru needs one few many other.
      p = valid(template: template, more: ['ru']);
      p.arb('ru', {
        'commonA': '{n, plural, one{{n} минуту} other{{n} минуты}}',
      });
      expect(
        p.check().withCode('plural-category').single.message,
        allOf(contains('few'), contains('many')),
      );
      // ar needs all six.
      p = valid(template: template, more: ['ar']);
      p.arb('ar', {'commonA': '{n, plural, other{{n}}}'});
      expect(
        p.check().withCode('plural-category').single.message,
        allOf(contains('zero'), contains('two')),
      );
      // ja only needs other; an unneeded category is just a warning.
      p = valid(template: template, more: ['ja']);
      p.arb('ja', {'commonA': '{n, plural, one{{n}分} other{{n}分}}'});
      final r = p.check();
      expect(r.errors, isEmpty);
      expect(r.withCode('plural-category').single.severity, Severity.warning);
    });

    test('many is optional for fr, es, it, pt', () {
      final p = valid(
        template: {
          'commonA': msg(
            '{n, plural, other{{n} phút}}',
            placeholders: {'n': 'int'},
          ),
        },
        more: ['fr'],
      );
      p.arb('fr', {
        'commonA': '{n, plural, one{{n} minute} many{{n} de minutes} other{{n} minutes}}',
      });
      expect(p.check().findings, isEmpty);
    });

    test('a plural case that drops the count needs the allowlist', () {
      final template = {
        'commonA': msg(
          '{n, plural, other{{n} phút}}',
          placeholders: {'n': 'int'},
        ),
      };
      final translation = {
        'commonA': '{n, plural, one{one minute} other{{n} minutes}}',
      };
      var p = two(template, translation);
      final f = p.check().withCode('plural-number').single;
      expect(f.message, contains('en.commonA.one'));

      p = two(template, translation);
      p.allowlist('number-word:\n  - en.commonA.one\n');
      expect(p.check().withCode('plural-number'), isEmpty);

      p = two(template, translation);
      p.allowlist('number-word:\n  - en.commonA\n');
      expect(p.check().withCode('plural-number'), isEmpty);

      // Exact cases (=0) may omit it without an allowlist.
      p = two(template, {
        'commonA': '{n, plural, =0{none} one{{n} minute} other{{n} minutes}}',
      });
      expect(p.check().withCode('plural-number'), isEmpty);
    });

    test('select needs other in a translation too', () {
      final p = two(
        {
          'commonA': msg(
            '{r, select, a{x} other{y}}',
            placeholders: {'r': 'String'},
          ),
        },
        {'commonA': '{r, select, a{x}}'},
      );
      expect(p.check().withCode('select-other').single.file, 'app_en.arb');
    });

    test('whitespace parity', () {
      final p = two(
        {
          'commonLead': msg(' x'),
          'commonTrail': msg('x '),
          'commonNl': msg('a\nb'),
          'commonDots': msg('Tìm…'),
          'commonOk': msg('Ok…'),
        },
        {
          'commonLead': 'x',
          'commonTrail': 'x',
          'commonNl': 'a b',
          'commonDots': 'Search...',
          'commonOk': 'Ok…',
        },
      );
      final keys = p.check().withCode('whitespace').map((f) => f.key).toList();
      expect(
        keys,
        containsAll(['commonLead', 'commonTrail', 'commonNl', 'commonDots']),
      );
      expect(keys, isNot(contains('commonOk')));
    });
  });

  group('output', () {
    test('plain and GitHub annotation formats', () {
      final f = Finding(
        Severity.error,
        'app_en.arb',
        'extra-key',
        'not in the template',
        key: 'commonNew',
      );
      expect(
        f.format(),
        'error [extra-key] app_en.arb:commonNew: not in the template',
      );
      expect(
        f.format(github: true),
        '::error file=app_en.arb,title=l10n_check extra-key::commonNew: not in the template',
      );
      final w = Finding(Severity.warning, 'app_en.arb', 'missing-key', 'm');
      expect(w.format(), 'warning [missing-key] app_en.arb: m');
      expect(w.format(github: true), startsWith('::warning file=app_en.arb'));
    });
  });
}
