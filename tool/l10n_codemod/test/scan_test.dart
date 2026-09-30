import 'dart:convert';
import 'dart:io';

import 'package:l10n_codemod/src/project.dart';
import 'package:l10n_codemod/src/scan.dart';
import 'package:test/test.dart';

/// A one-package project that exercises every fact `scan` reports. It needs no
/// Flutter: `scan` recognises a context parameter by the type NAME
/// `BuildContext`, so the fixture declares its own.
const _commonStrings = r'''
abstract final class CommonStrings {
  static const retry = 'Thử lại';
  static String minutesAgo(int n) => '$n phút trước';
  static String greet(String name) => 'Chào $name';
  static const weekdays = <String>['a', 'b'];
  static const names = <String, String>{'k': 'v'};
  static const alias = retry;
}

abstract final class FooStrings {
  static const x = 'x';
}
''';

const _storeScreen = r'''
import 'package:valvn/core/l10n/common_strings.dart';

class BuildContext {}

class Text {
  const Text(this.data);
  final String data;
}

class Wrapper {
  const Wrapper({this.label = CommonStrings.retry});
  final String label;
}

enum Tab {
  home(CommonStrings.retry);

  const Tab(this.label);
  final String label;
}

String noContext() => CommonStrings.retry;

Object plain(BuildContext context) => Text(CommonStrings.retry);

Object constText(BuildContext context) => const Text(CommonStrings.retry);

String called(BuildContext context) => CommonStrings.minutesAgo(5);

String Function(int) tornOff(BuildContext context) => CommonStrings.minutesAgo;

String upper(BuildContext context) => CommonStrings.retry.toUpperCase();

String concat(BuildContext context) => 'a ${CommonStrings.retry} b';

Future<String> late_(BuildContext context) async {
  await Future<void>.delayed(Duration.zero);
  return CommonStrings.retry;
}

Future<String> early(BuildContext context) async {
  final s = CommonStrings.retry;
  await Future<void>.delayed(Duration.zero);
  return s;
}

String literal() => 'Xin chào';

String mapUse(BuildContext context) => CommonStrings.names['k']!;
''';

const _storeTest = r'''
import 'package:valvn/core/l10n/common_strings.dart';

class MaterialApp {
  const MaterialApp({this.localizationsDelegates, this.locale});
  const MaterialApp.router({this.localizationsDelegates, this.locale});
  final List<Object>? localizationsDelegates;
  final Object? locale;
}

void main() {
  MaterialApp();
  MaterialApp(localizationsDelegates: []);
  MaterialApp.router(locale: null);
  CommonStrings.retry;
}
''';

class _Fixture {
  _Fixture() : root = Directory.systemTemp.createTempSync('l10n_scan_test') {
    File('${root.path}/pubspec.yaml').writeAsStringSync('name: valvn\n');
    Directory('${root.path}/.dart_tool').createSync();
    File('${root.path}/.dart_tool/package_config.json').writeAsStringSync(
      jsonEncode({
        'configVersion': 2,
        'packages': [
          {
            'name': 'valvn',
            'rootUri': '../',
            'packageUri': 'lib/',
            'languageVersion': '3.13',
          },
        ],
      }),
    );
    _put('lib/core/l10n/common_strings.dart', _commonStrings);
    _put('lib/features/store/ui/store_screen.dart', _storeScreen);
    _put('test/features/store/store_test.dart', _storeTest);
  }

  final Directory root;

  void _put(String rel, String text) {
    final f = File('${root.path}/$rel')..parent.createSync(recursive: true);
    f.writeAsStringSync(text);
  }

  Project project() => Project.discover(root: root.path);

  Future<void> dispose() async {
    for (var attempt = 0; attempt < 5; attempt++) {
      try {
        if (root.existsSync()) root.deleteSync(recursive: true);
        return;
      } on FileSystemException {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    }
  }
}

void main() {
  late _Fixture fixture;
  late Map<String, Object?> report;
  late List<Map<String, Object?>> refs;

  setUpAll(() async {
    fixture = _Fixture();
    report = (await scan(fixture.project())).json;
    refs = (report['refs']! as List<Object?>).cast<Map<String, Object?>>();
  });

  tearDownAll(() => fixture.dispose());

  /// The references made inside the declaration [enclosing].
  Map<String, Object?> refIn(String enclosing) => refs.singleWhere(
    (r) =>
        r['enclosing'] == enclosing &&
        r['file'] != 'lib/core/l10n/common_strings.dart',
    orElse: () => fail(
      'no single reference in $enclosing: '
      '${refs.where((r) => r['enclosing'] == enclosing).toList()}',
    ),
  );

  group('members', () {
    late Map<String, Map<String, Object?>> members;
    setUpAll(() {
      members = {
        for (final m
            in (report['members']! as List<Object?>)
                .cast<Map<String, Object?>>())
          '${m['cls']}.${m['name']}': m,
      };
    });

    test('kinds and function shapes', () {
      expect(members['CommonStrings.retry']!['kind'], 'const-string');
      expect(members['CommonStrings.weekdays']!['kind'], 'const-list');
      expect(members['CommonStrings.names']!['kind'], 'const-map');
      expect(members['CommonStrings.alias']!['kind'], 'alias');
      final fn = members['CommonStrings.minutesAgo']!;
      expect(fn['kind'], 'fn');
      expect(fn['bodyKind'], 'interp');
      expect(fn['placeholders'], 1);
      expect(fn['params'], ['int n']);
    });

    test('a class outside the known table is reported as drift', () {
      expect(report['unknownStringsClasses'], {
        'FooStrings': 'lib/core/l10n/common_strings.dart',
      });
      final missing = report['missingKnownClasses']! as List<Object?>;
      expect(missing, isNot(contains('CommonStrings')));
      expect(missing, contains('StoreStrings'));
      expect(report['knownClasses'], hasLength(20));
    });

    test('unreferenced members are listed', () {
      final summary = report['summary']! as Map<String, Object?>;
      final unreferenced =
          (summary['members']! as Map<String, Object?>)['unreferenced']!
              as List<Object?>;
      expect(
        unreferenced,
        containsAll([
          'CommonStrings.greet',
          'CommonStrings.weekdays',
          'FooStrings.x',
        ]),
      );
      expect(unreferenced, isNot(contains('CommonStrings.retry')));
    });
  });

  group('references', () {
    test('a read with a BuildContext parameter, not in a const context', () {
      final r = refIn('plain');
      expect(r['usage'], 'read');
      expect(r['contextSource'], 'param:context');
      expect(r['constKind'], isNull);
      expect(r['widget'], 'Text');
      expect(r['cat'], 'feature-ui');
    });

    test('no context in a top-level function', () {
      final r = refIn('noContext');
      expect(r['contextSource'], 'none');
      expect(r['enclosingKind'], 'top-level-fn');
    });

    test('const Text(X.y) is recognised', () {
      final r = refIn('constText');
      expect(r['constKind'], 'const-ctor');
      expect(r['constOwner'], 'Text');
      expect(r['constTextDirect'], isTrue);
      expect(r['contextSource'], 'param:context');
    });

    test('default value and enum constructor argument are const contexts', () {
      final def = refs.singleWhere((r) => r['constKind'] == 'default-value');
      expect(def['constOwner'], 'label');
      expect(def['contextSource'], 'none');
      final en = refs.singleWhere((r) => r['constKind'] == 'enum-args');
      expect(en['constOwner'], 'Tab.home');
    });

    test('calls and tear-offs', () {
      expect(refIn('called')['usage'], 'call');
      expect(refIn('tornOff')['usage'], 'tearoff');
      final summary = report['summary']! as Map<String, Object?>;
      final tearOffs =
          (summary['hazards']! as Map<String, Object?>)['tearOffs']!
              as List<Object?>;
      expect(
        tearOffs.single,
        startsWith(
          'CommonStrings.minutesAgo lib/features/store/ui/store_screen.dart:',
        ),
      );
    });

    test('hazards: case transform, concatenation, list/map use', () {
      expect(refIn('upper')['caseMap'], isTrue);
      expect(refIn('concat')['concat'], isTrue);
      expect(refIn('plain')['caseMap'], isFalse);
      final haz =
          (report['summary']! as Map<String, Object?>)['hazards']!
              as Map<String, Object?>;
      expect(
        (haz['listMapUses']! as List<Object?>).single,
        startsWith(
          'CommonStrings.names lib/features/store/ui/store_screen.dart:',
        ),
      );
      expect(haz['caseTransforms'], hasLength(1));
    });

    test('after an await versus before it', () {
      final late = refIn('late_');
      expect(late['inAsync'], isTrue);
      expect(late['afterAwait'], isTrue);
      final early = refIn('early');
      expect(early['inAsync'], isTrue);
      expect(early['afterAwait'], isFalse);
      expect(refIn('plain')['inAsync'], isFalse);
    });

    test('bare references inside the strings class itself', () {
      final bare = refs.singleWhere((r) => r['usage'] == 'bare-read');
      expect(bare['member'], 'retry');
      expect(bare['cat'], 'strings');
    });

    test('references are sorted by file and position', () {
      final keys = [
        for (final r in refs)
          '${r['file']}:${(r['line']! as int).toString().padLeft(6, '0')}',
      ];
      expect(keys, [...keys]..sort());
    });
  });

  group('summary and other findings', () {
    test('counts', () {
      final s = report['summary']! as Map<String, Object?>;
      final refsSummary = s['refs']! as Map<String, Object?>;
      expect(refsSummary['test'], 1);
      expect(refsSummary['testFiles'], 1);
      final ctx = s['context']! as Map<String, Object?>;
      // noContext (fn), default value, enum argument.
      expect(ctx['noContext'], 3);
      expect(ctx['afterAwaitWithContext'], 1);
    });

    test('Vietnamese literals outside the strings files', () {
      final vi = (report['viLiterals']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(vi.single['file'], 'lib/features/store/ui/store_screen.dart');
      expect(vi.single['value'], 'Xin chào');
    });

    test('the MaterialApp census of the test harness (R8)', () {
      final apps = (report['materialApps']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(apps.map((a) => a['constructor']), [
        'MaterialApp',
        'MaterialApp',
        'MaterialApp.router',
      ]);
      expect(apps.map((a) => a['hasLocalizationsDelegates']), [
        false,
        true,
        false,
      ]);
      expect(apps.map((a) => a['hasLocale']), [false, false, true]);
    });

    test('no analysis errors in the fixture', () {
      expect(report['analysisErrors'], isEmpty);
    });
  });

  group('determinism and filters', () {
    test('the same tree gives byte-identical reports', () async {
      final again = (await scan(fixture.project())).json;
      expect(jsonEncode(again), jsonEncode(report));
      expect(jsonEncode(report), isNot(contains('elapsed')));
    });

    test('--only limits the reported files', () async {
      final only = (await scan(fixture.project(), only: ['test/**'])).json;
      final onlyRefs = (only['refs']! as List<Object?>)
          .cast<Map<String, Object?>>();
      expect(onlyRefs.map((r) => r['file']).toSet(), {
        'test/features/store/store_test.dart',
      });
      expect(only['only'], ['test/**']);
      // No strings file was scanned: members and the drift report stay empty.
      expect(only['members'], isEmpty);
      expect(only['missingKnownClasses'], isEmpty);
    });

    test('the report can be written and read back', () async {
      final result = await scan(fixture.project());
      final out = '${fixture.root.path}/reports/scan.json';
      writeReport(result, out);
      expect(
        jsonDecode(File(out).readAsStringSync()),
        jsonDecode(jsonEncode(result.json)),
      );
      expect(result.summary, contains('refs: '));
    });
  });

  group('Project.discover', () {
    test('finds the root from a subdirectory', () {
      final p = Project.discover(root: '${fixture.root.path}/lib/features');
      expect(p.root, fixture.root.path.replaceAll('/', Platform.pathSeparator));
      expect(p.rel('${fixture.root.path}/lib/a.dart'), 'lib/a.dart');
    });

    test('needs a ValVN checkout and pub get', () {
      final other = Directory.systemTemp.createTempSync('l10n_scan_other');
      addTearDown(() => other.deleteSync(recursive: true));
      expect(
        () => Project.discover(root: other.path),
        throwsA(isA<ProjectException>()),
      );
      File('${other.path}/pubspec.yaml').writeAsStringSync('name: valvn\n');
      expect(
        () => Project.discover(root: other.path),
        throwsA(
          isA<ProjectException>().having(
            (e) => e.message,
            'message',
            contains('flutter pub get'),
          ),
        ),
      );
    });
  });

  group('Glob', () {
    test('star and double star', () {
      final store = Glob('lib/features/store/**');
      expect(store.matches('lib/features/store/ui/a.dart'), isTrue);
      expect(store.matches('lib/features/store/a.dart'), isTrue);
      expect(store.matches('lib/features/storefront/a.dart'), isFalse);
      final tests = Glob('test/**/*_test.dart');
      expect(tests.matches('test/a_test.dart'), isTrue);
      expect(tests.matches('test/features/store/a_test.dart'), isTrue);
      expect(tests.matches('test/features/store/a.dart'), isFalse);
      final one = Glob('lib/*.dart');
      expect(one.matches('lib/main.dart'), isTrue);
      expect(one.matches('lib/app/app.dart'), isFalse);
    });

    test('an empty list matches everything', () {
      expect(matchesAny(const [], 'anything'), isTrue);
      expect(matchesAny([Glob('lib/**')], 'test/a.dart'), isFalse);
    });
  });
}
