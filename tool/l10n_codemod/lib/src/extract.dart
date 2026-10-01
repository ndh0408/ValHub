// Deterministic resolved-AST extraction. Unsupported expressions are listed
// for structural migration and never silently treated as translated messages.

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:l10n_codemod/src/known_classes.dart';
import 'package:l10n_codemod/src/project.dart';
import 'package:path/path.dart' as p;

// The prototype's own map had `battlepass` and no HomeStrings: use the package's.
const prefixes = kStringsClassPrefixes;

String keyOf(String cls, String member) {
  final pre = prefixes[cls]!;
  return '$pre${member[0].toUpperCase()}${member.substring(1)}';
}

String icuEscape(String s) =>
    s; // no '{' '}' in current values (verified separately)

/// Converts a string expression into an ICU message when it only interpolates
/// parameters. Returns null when it needs hand work.
String? toIcu(Expression e, Set<String> params, Map<String, String> constVals) {
  if (e is SimpleStringLiteral) return icuEscape(e.value);
  if (e is AdjacentStrings) {
    final parts = e.strings.map((s) => toIcu(s, params, constVals)).toList();
    if (parts.any((x) => x == null)) return null;
    return parts.join();
  }
  if (e is StringInterpolation) {
    final sb = StringBuffer();
    for (final el in e.elements) {
      if (el is InterpolationString) {
        sb.write(icuEscape(el.value));
      } else if (el is InterpolationExpression) {
        final x = el.expression;
        if (x is SimpleIdentifier && params.contains(x.name)) {
          sb.write('{${x.name}}');
        } else if (x is SimpleIdentifier && constVals.containsKey(x.name)) {
          // inline a sibling const (e.g. '$peakRank · $actTitle')
          sb.write(constVals[x.name]);
        } else {
          return null;
        }
      }
    }
    return sb.toString();
  }
  return null;
}

Future<List<Map<String, Object?>>> extractMembers(Project project) async {
  final root = project.root;
  final sdk = project.sdkPath;
  final coll = AnalysisContextCollection(
    includedPaths: [p.join(root, 'lib')],
    sdkPath: sdk,
  );
  final out = <Map<String, Object?>>[];
  for (final ctx in coll.contexts) {
    for (final path in ctx.contextRoot.analyzedFiles()) {
      if (!path.endsWith('_strings.dart')) continue;
      final res = await ctx.currentSession.getResolvedUnit(path);
      if (res is! ResolvedUnitResult) continue;
      final rel = p.relative(path, from: root).replaceAll(r'\', '/');
      for (final d in res.unit.declarations.whereType<ClassDeclaration>()) {
        final cls = d.namePart.typeName.lexeme;
        if (!prefixes.containsKey(cls)) continue;
        final body = d.body as BlockClassBody;
        // sibling const values for inlining
        final constVals = <String, String>{};
        String section = '';
        for (final m in body.members) {
          if (m is FieldDeclaration) {
            for (final v in m.fields.variables) {
              final el = v.declaredFragment?.element;
              final val = (el as FieldElement?)
                  ?.computeConstantValue()
                  ?.toStringValue();
              if (val != null) constVals[v.name.lexeme] = val;
            }
          }
        }
        for (final m in body.members) {
          // nearest preceding line comment = section header
          final pre = res.content.substring(0, m.offset);
          final lastLines = pre.split('\n');
          for (
            var i = lastLines.length - 1;
            i >= 0 && i > lastLines.length - 6;
            i--
          ) {
            final t = lastLines[i].trim();
            if (t.startsWith('//') && !t.startsWith('///')) {
              section = t
                  .replaceFirst(RegExp(r'^//\s*-*\s*'), '')
                  .replaceAll(RegExp(r'-+$'), '')
                  .trim();
              break;
            }
          }
          final doc = m.documentationComment?.tokens
              .map((t) => t.lexeme.replaceFirst(RegExp(r'^///\s?'), ''))
              .join(' ');
          if (m is FieldDeclaration) {
            for (final v in m.fields.variables) {
              final name = v.name.lexeme;
              final el = v.declaredFragment?.element as FieldElement?;
              final obj = el?.computeConstantValue();
              final init = v.initializer;
              Object? value = obj?.toStringValue();
              var kind = 'string';
              if (value == null && obj?.toListValue() != null) {
                kind = 'list';
                value = obj!
                    .toListValue()!
                    .map((x) => x.toStringValue())
                    .toList();
              } else if (value == null && obj?.toMapValue() != null) {
                kind = 'map';
                value = {
                  for (final e in obj!.toMapValue()!.entries)
                    e.key!.toStringValue(): e.value!.toStringValue(),
                };
              } else if (value == null) {
                kind = 'nonconst';
                value = init?.toSource();
              }
              if (init is PrefixedIdentifier || init is SimpleIdentifier) {
                kind = 'alias';
              }
              if (name.startsWith('_')) kind = 'private-$kind';
              out.add({
                'file': rel,
                'cls': cls,
                'member': name,
                'key': keyOf(cls, name),
                'kind': kind,
                'value': value,
                'doc': doc,
                'section': section,
                'aliasOf':
                    (init is PrefixedIdentifier || init is SimpleIdentifier)
                    ? init!.toSource()
                    : null,
              });
            }
          } else if (m is MethodDeclaration) {
            final name = m.name.lexeme;
            final params = <String, String>{};
            for (final fp
                in m.parameters?.parameters ?? const <FormalParameter>[]) {
              final inner = fp is DefaultFormalParameter ? fp.parameter : fp;
              params[fp.name!.lexeme] = inner.declaredFragment!.element.type
                  .getDisplayString();
            }
            String? icu;
            var kind = 'fn-hand';
            final b = m.body;
            final hasNullable = params.values.any((t) => t.endsWith('?'));
            final hasCollection = params.values.any(
              (t) => t.startsWith('Iterable') || t.startsWith('List'),
            );
            if (b is ExpressionFunctionBody) {
              final e = b.expression;
              icu = toIcu(e, params.keys.toSet(), constVals);
              if (icu != null && !hasNullable && !hasCollection) {
                kind = 'fn-icu';
              } else if (e is ConditionalExpression && !hasNullable) {
                final c = e.condition;
                // plural candidates: int param compared with a literal
                if (c is BinaryExpression &&
                    c.leftOperand is SimpleIdentifier &&
                    params[(c.leftOperand as SimpleIdentifier).name] == 'int' &&
                    c.rightOperand is IntegerLiteral) {
                  final t = toIcu(
                    e.thenExpression,
                    params.keys.toSet(),
                    constVals,
                  );
                  final f = toIcu(
                    e.elseExpression,
                    params.keys.toSet(),
                    constVals,
                  );
                  final v = (c.leftOperand as SimpleIdentifier).name;
                  final n = (c.rightOperand as IntegerLiteral).value;
                  final op = c.operator.lexeme;
                  if (t != null &&
                      f != null &&
                      (op == '==' || (op == '>' && n == 0))) {
                    kind = 'fn-plural';
                    icu = op == '=='
                        ? '{$v, plural, =$n{${t.replaceAll('{$v}', '{$v}')}} other{$f}}'
                        : '{$v, plural, =0{$f} other{$t}}';
                  } else {
                    kind = 'fn-hand';
                    icu = null;
                  }
                } else {
                  kind = 'fn-hand';
                }
              } else if (e is SwitchExpression) {
                kind = hasNullable ? 'fn-hand' : 'fn-select';
              }
            }
            if (hasNullable && kind != 'fn-icu') kind = 'fn-hand-nullable';
            if (hasCollection) kind = 'fn-hand-collection';
            out.add({
              'file': rel,
              'cls': cls,
              'member': name,
              'key': keyOf(cls, name),
              'kind': kind,
              'params': params,
              'icu': icu,
              'doc': doc,
              'section': section,
              'source': m.toSource(),
            });
          }
        }
      }
    }
  }
  out.sort((a, b) {
    final classes = prefixes.keys.toList();
    final ac = classes.indexOf(a['cls'] as String);
    final bc = classes.indexOf(b['cls'] as String);
    return ac != bc
        ? ac.compareTo(bc)
        : (a['key'] as String).compareTo(b['key'] as String);
  });
  await coll.dispose();
  return out;
}
