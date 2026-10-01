import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:l10n_codemod/src/catalog.dart';
import 'package:l10n_codemod/src/extract.dart';
import 'package:l10n_codemod/src/project.dart';
import 'package:test/test.dart';

Entry member(String name, String kind, Object value) => {
  'file': 'lib/core/l10n/common_strings.dart',
  'cls': 'CommonStrings',
  'member': name,
  'key': 'common${name[0].toUpperCase()}${name.substring(1)}',
  'kind': kind,
  'value': value,
  'section': 'fixture',
};

void main() {
  test('formatter subprocess preserves Unicode on Windows', () {
    const value = 'Nguyễn Văn A · 日本語 · العربية · 🇻🇳';
    final formatted = formatDartSource(
      Project.discover(),
      "// Generated Unicode fixture\nconst name = '$value';\n",
    );
    expect(formatted, contains(value));
    expect(formatted, isNot(contains('Nguyá')));
  });
  test('expands collections into deterministic individual keys', () {
    final catalog = Catalog.fromMembers(
      [
        member('days', 'list', ['Thứ hai', 'Thứ ba']),
        member('queues', 'map', {
          'team-deathmatch': 'Đấu đội',
          'competitive': 'Xếp hạng',
        }),
      ],
      {'@@locale': 'vi', 'existingMessage': 'Giữ lại'},
    );
    expect(catalog.arb['commonDaysItem0'], 'Thứ hai');
    expect(catalog.arb['commonQueuesTeamDeathmatch'], 'Đấu đội');
    expect(catalog.arb['existingMessage'], 'Giữ lại');
    expect(catalog.messages[2]['index'], 'team-deathmatch');
    expect(catalog.manual, isEmpty);
  });
  test(
    'unused and nullable arguments are reported instead of silently lost',
    () {
      final catalog = Catalog.fromMembers(
        [
          {
            ...member('greet', 'fn-icu', ''),
            'params': <String, String>{'name': 'String'},
            'icu': 'Chào {name}',
          },
          {
            ...member('unused', 'fn-icu', ''),
            'params': <String, String>{'name': 'String'},
            'icu': 'Chào',
          },
          {
            ...member('nullable', 'fn-hand-nullable', ''),
            'params': <String, String>{'name': 'String?'},
            'icu': null,
          },
        ],
        {'@@locale': 'vi'},
      );
      expect(catalog.messages.length, 1);
      expect(catalog.manual.length, 2);
      expect(catalog.arb.containsKey('commonUnused'), false);
      expect(catalog.arb.containsKey('commonNullable'), false);
    },
  );
  test('parity escapes Dart interpolation and exercises branch boundaries', () {
    expect(dartLiteral(r'$x'), r"'\$x'");
    final catalog = Catalog.fromMembers(
      [
        {
          ...member('count', 'fn-plural', ''),
          'params': <String, String>{'n': 'int'},
          'icu': '{n, plural, =0{Không} other{{n} mục}}',
        },
      ],
      {'@@locale': 'vi'},
    );
    final source = paritySource(catalog);
    expect(source, contains('l10n.commonCount(0)'));
    expect(source, contains('l10n.commonCount(99)'));
    expect(source, contains('CommonStrings.count(2)'));
  });
  test('ICU extraction accepts parameter interpolation and inlines constant siblings', () {
    final unit = parseString(
      content: r"String f(String name) => 'Chào $name · $label';",
    ).unit;
    final declaration = unit.declarations.single as FunctionDeclaration;
    final body = declaration.functionExpression.body as ExpressionFunctionBody;
    expect(
      toIcu(body.expression, {'name'}, {'label': 'VALVN'}),
      'Chào {name} · VALVN',
    );
    expect(toIcu(body.expression, {'name'}, {}), isNull);
  });
}
