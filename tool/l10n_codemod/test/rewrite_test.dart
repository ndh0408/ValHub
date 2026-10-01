import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:l10n_codemod/src/rewrite.dart';
import 'package:test/test.dart';
import 'package:path/path.dart' as p;

void main() {
  late Directory root;
  late AnalysisContextCollection collection;
  setUp(() {
    root = Directory.systemTemp.createTempSync('valvn-rewrite-test-');
    File('${root.path}/.dart_tool/package_config.json')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync(
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
    File('${root.path}/lib/core/l10n/l10n.dart')
      ..parent.createSync(recursive: true)
      ..writeAsStringSync('''
class BuildContext {}
class Messages { String get commonRetry => 'retry'; String commonGreet(String name) => name; }
extension Localization on BuildContext { Messages get l10n => Messages(); }
class CommonStrings { static const retry = 'retry'; static String greet(String name) => name; static String optional([String name = '']) => name; }
class Box { const Box(Object child); }
''');
    collection = AnalysisContextCollection(
      includedPaths: [p.join(root.path, 'lib')],
      sdkPath: File(Platform.resolvedExecutable).parent.parent.path,
    );
  });
  tearDown(() async {
    await collection.dispose();
    // This is the exact directory created above, never a caller-supplied cleanup target.
    await root.delete(recursive: true);
  });

  Future<RewritePlan> plan(String code) async {
    final file = File(p.join(root.path, 'lib', 'view.dart'));
    file.writeAsStringSync(
      "import 'package:valvn/core/l10n/l10n.dart';\n$code",
    );
    final context = collection.contextFor(file.path);
    context.changeFile(file.path);
    await context.applyPendingFileChanges();
    final unit = await context.currentSession.getResolvedUnit(
      file.path,
    ) as ResolvedUnitResult;
    expect(unit.diagnostics.where((d) => d.severity.name == 'ERROR'), isEmpty);
    return planUnit(unit, {
      'CommonStrings.retry': 'commonRetry',
      'CommonStrings.greet': 'commonGreet',
      'CommonStrings.optional': 'commonOptional',
    });
  }

  test('rewrites reads, nested calls, tearoffs and all enclosing const expressions', () async {
    final result = await plan('''
Object view(BuildContext context) => const Box(const [CommonStrings.retry, const Box(CommonStrings.retry)]);
String message(BuildContext c) => CommonStrings.greet(CommonStrings.retry);
String Function(String) callback(BuildContext c) => CommonStrings.greet;
Object local(BuildContext c) { const text = CommonStrings.retry; return text; }
''');
    final source = result.apply();
    expect(
      source,
      contains(
        'Box( [context.l10n.commonRetry,  Box(context.l10n.commonRetry)])',
      ),
    );
    expect(source, contains('c.l10n.commonGreet(c.l10n.commonRetry)'));
    expect(source, contains('=> c.l10n.commonGreet;'));
    expect(source, contains('final text = c.l10n.commonRetry'));
    expect(result.skipped, isEmpty);
  });
  test('never rewrites constructor defaults, no-context fields or reads after await', () async {
    final result = await plan('''
class View { View(BuildContext c, [String text = CommonStrings.retry]); static const field = CommonStrings.retry; }
String noContext() => CommonStrings.retry;
Future<String> later(BuildContext c) async { await Future<void>.value(); return CommonStrings.retry; }
String optional(BuildContext c) => CommonStrings.optional();
''');
    expect(result.edits, isEmpty);
    expect(result.skipped, hasLength(5));
    expect(
      result.skipped.map((r) => r['reason']),
      contains('localization read after await'),
    );
  });
  test('re-running on rewritten code produces no edits and preserves unrelated code', () async {
    final first = await plan(
      "String view(BuildContext c) => CommonStrings.greet('Unicode 日本語');",
    );
    final code = first.apply().split('\n').skip(1).join('\n');
    final second = await plan(code);
    expect(second.edits, isEmpty);
    expect(second.apply(), first.apply());
  });
  test(
    'a same-named nested parameter cannot impersonate the outer BuildContext',
    () async {
      final result = await plan(
        'Object view(BuildContext c) => (String c) => CommonStrings.retry;',
      );
      expect(result.edits, isEmpty);
      expect(result.skipped.single['reason'], 'no BuildContext in scope');
    },
  );
}
