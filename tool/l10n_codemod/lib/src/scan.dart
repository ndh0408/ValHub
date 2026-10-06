/// `l10n scan`: the resolved-AST inventory of how the `*Strings` classes are
/// used (docs/design/I18N.md 5.1, section 2). Read-only.
///
/// Run at every wave start: the tree moves fast, so every number in the design
/// is a snapshot and this is the authoritative one. Per work package use
/// `--only '<glob>'`.
///
/// It reports, for `lib/` and `test/`:
/// - every member of the strings classes (kind, parameters, body shape);
/// - every reference to a member: usage (read / call / tear-off), whether a
///   `BuildContext` or a Riverpod `Ref` is in scope, the enclosing `const`
///   context, whether it follows an `await`, the widget and argument it feeds,
///   case transforms and concatenations (hazards);
/// - Vietnamese literals outside the strings files;
/// - the `MaterialApp` constructions of `test/` (rule R8).
library;

import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:path/path.dart' as p;

import 'ast_context.dart';
import 'known_classes.dart';
import 'project.dart';

/// `// l10n-allow: <reason>`: a literal that must never be translated.
final RegExp _allowMarker = RegExp(r'//\s*l10n-allow:\s*\S');

/// Vietnamese-only letters: a literal containing one is user-visible text.
final RegExp _viChars = RegExp(
  r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
  r'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ]',
);

/// Coarse layer of a file, to group the numbers like the design does.
String categoryOf(String rel) {
  if (rel.startsWith('test/')) return 'test';
  if (rel.endsWith('_strings.dart')) return 'strings';
  if (rel.startsWith('lib/app/')) return 'app';
  if (rel.startsWith('lib/core/ui/')) return 'core-ui';
  if (rel.contains('/background/')) return 'background';
  if (rel.contains('/ui/')) return 'feature-ui';
  if (rel.contains('/providers/')) return 'providers';
  if (rel.contains('/data/')) return 'data';
  if (rel.startsWith('lib/core/')) return 'core-other';
  return 'feature-other';
}

class ScanMember {
  ScanMember(this.cls, this.name, this.kind);

  final String cls;
  final String name;

  /// const-string, const-interp, const-list, const-map, alias, fn, private,
  /// other.
  String kind;
  String file = '';
  int line = 0;
  String detail = '';

  /// For functions: literal, interp, interp+expr, conditional, switch, logic,
  /// block.
  String bodyKind = '';
  int placeholders = 0;
  List<String> params = [];
  String returnType = '';

  String get id => '$cls.$name';

  Map<String, Object?> toJson() => {
    'cls': cls,
    'name': name,
    'kind': kind,
    'file': file,
    'line': line,
    'detail': detail,
    'bodyKind': bodyKind,
    'placeholders': placeholders,
    'params': params,
    'returnType': returnType,
  };
}

class ScanRef {
  late String file;
  late int line;
  late int col;
  late int offset;
  late String cls;
  late String member;

  /// read | call | tearoff | bare-read | bare-call
  late String usage;
  String? constKind;
  String? constOwner;

  /// `const Text(X.y)` directly.
  bool constTextDirect = false;

  /// `param:<name>` | `State.context` | `none`
  late String contextSource;
  late String enclosing;
  late String enclosingKind;
  late String cat;

  /// A Riverpod `Ref`/`WidgetRef` is in scope.
  bool hasRef = false;
  String snippet = '';

  /// Nearest named argument (`label`, `tooltip`, `title`, ...).
  String? argName;

  /// Nearest enclosing constructor / invocation.
  String? widget;

  /// Inside a string interpolation or a `+` concatenation.
  bool concat = false;

  /// `.toUpperCase()` / `.toLowerCase()` applied.
  bool caseMap = false;

  /// Inside an async function body.
  bool inAsync = false;

  /// After an `await` of the same function body (approximate: source order).
  bool afterAwait = false;
  bool inInitState = false;

  String get memberId => '$cls.$member';

  Map<String, Object?> toJson() => {
    'file': file,
    'line': line,
    'col': col,
    'cls': cls,
    'member': member,
    'usage': usage,
    'constKind': constKind,
    'constOwner': constOwner,
    'constTextDirect': constTextDirect,
    'contextSource': contextSource,
    'enclosing': enclosing,
    'enclosingKind': enclosingKind,
    'cat': cat,
    'hasRef': hasRef,
    'snippet': snippet,
    'argName': argName,
    'widget': widget,
    'concat': concat,
    'caseMap': caseMap,
    'inAsync': inAsync,
    'afterAwait': afterAwait,
    'inInitState': inInitState,
  };
}

/// One `MaterialApp(` / `MaterialApp.router(` construction (rule R8).
class ScanMaterialApp {
  ScanMaterialApp(
    this.file,
    this.line,
    this.constructor,
    this.hasDelegates,
    this.hasLocale,
  );

  final String file;
  final int line;
  final String constructor;
  final bool hasDelegates;
  final bool hasLocale;

  Map<String, Object?> toJson() => {
    'file': file,
    'line': line,
    'constructor': constructor,
    'hasLocalizationsDelegates': hasDelegates,
    'hasLocale': hasLocale,
  };
}

class _Collected {
  final members = <String, ScanMember>{};
  final refs = <ScanRef>[];
  final viLiterals = <Map<String, Object?>>[];
  final materialApps = <ScanMaterialApp>[];
  final diagnostics = <Map<String, Object?>>[];
  final unknownClasses = <String, String>{};
  int files = 0;
}

/// The outcome of [scan].
class ScanResult {
  ScanResult(this.json, this.summary, this.elapsed);

  /// The report written to `reports/scan.json`. Byte-stable: same tree and
  /// tool version give the same text (no timestamps, sorted lists).
  final Map<String, Object?> json;

  /// Human-readable summary.
  final String summary;

  /// How long the analysis took (not part of the report).
  final Duration elapsed;
}

/// Scans `lib/` and `test/` of [project]; [only] limits the reported files to
/// the given globs (repository-relative paths).
Future<ScanResult> scan(Project project, {List<String> only = const []}) async {
  final globs = [for (final g in only) Glob(g)];
  final started = DateTime.now();
  final c = _Collected();

  final collection = AnalysisContextCollection(
    includedPaths: [project.libDir, project.testDir],
    sdkPath: project.sdkPath,
  );
  final paths = <String>[
    for (final ctx in collection.contexts)
      for (final path in ctx.contextRoot.analyzedFiles())
        if (path.endsWith('.dart')) path,
  ]..sort();

  try {
    for (final path in paths) {
      final rel = project.rel(path);
      if (!rel.startsWith('lib/') && !rel.startsWith('test/')) continue;
      if (rel.startsWith('lib/l10n/gen/') ||
          rel == 'test/l10n/vi_parity_test.dart') {
        continue;
      }
      if (!matchesAny(globs, rel)) continue;
      final ctx = collection.contextFor(path);
      final res = await ctx.currentSession.getResolvedUnit(path);
      if (res is! ResolvedUnitResult) continue;
      c.files++;
      for (final d in res.diagnostics) {
        if (d.severity.name == 'ERROR') {
          c.diagnostics.add({'file': rel, 'message': d.message});
          break;
        }
      }
      if (rel.endsWith('_strings.dart')) {
        _collectMembers(project, c, path, res.unit);
      }
      res.unit.accept(_RefVisitor(project, c, path, res.unit, res.content));
    }

    final json = _report(project, c, globs);
    final elapsed = DateTime.now().difference(started);
    return ScanResult(json, _summary(json, elapsed), elapsed);
  } finally {
    await collection.dispose();
  }
}

/// Writes [result] to [outFile] (parents created).
void writeReport(ScanResult result, String outFile) {
  final f = File(outFile)..parent.createSync(recursive: true);
  f.writeAsStringSync(const JsonEncoder.withIndent(' ').convert(result.json));
}

// --- members -----------------------------------------------------------------

void _collectMembers(
  Project project,
  _Collected c,
  String path,
  CompilationUnit unit,
) {
  for (final d in unit.declarations.whereType<ClassDeclaration>()) {
    final cls = d.namePart.typeName.lexeme;
    if (!cls.endsWith('Strings')) continue;
    if (!kStringsClassPrefixes.containsKey(cls)) {
      c.unknownClasses[cls] = project.rel(path);
    }
    final body = d.body;
    if (body is! BlockClassBody) continue;
    for (final m in body.members) {
      if (m is FieldDeclaration) {
        for (final v in m.fields.variables) {
          final name = v.name.lexeme;
          final init = v.initializer;
          String kind;
          var detail = '';
          if (name.startsWith('_')) {
            kind = 'private';
          } else if (init is SimpleStringLiteral || init is AdjacentStrings) {
            kind = 'const-string';
          } else if (init is StringInterpolation) {
            kind = 'const-interp';
            detail = init.toSource();
          } else if (init is ListLiteral) {
            kind = 'const-list';
            detail = '${init.elements.length} items';
          } else if (init is SetOrMapLiteral) {
            kind = 'const-map';
            detail = '${init.elements.length} entries';
          } else if (init is PrefixedIdentifier || init is SimpleIdentifier) {
            kind = 'alias';
            detail = init!.toSource();
          } else {
            kind = 'other';
            detail = init?.toSource() ?? '';
          }
          c.members['$cls.$name'] = ScanMember(cls, name, kind)
            ..file = project.rel(path)
            ..line = unit.lineInfo.getLocation(v.offset).lineNumber
            ..detail = detail;
        }
      } else if (m is MethodDeclaration) {
        final name = m.name.lexeme;
        final mem = ScanMember(cls, name, 'fn')
          ..file = project.rel(path)
          ..line = unit.lineInfo.getLocation(m.offset).lineNumber
          ..returnType = m.returnType?.toSource() ?? '?'
          ..params = [
            for (final fp
                in m.parameters?.parameters ?? const <FormalParameter>[])
              '${paramType(fp)} ${fp.name?.lexeme}${fp.isNamed ? ' (named)' : ''}',
          ];
        final b = m.body;
        if (b is ExpressionFunctionBody) {
          final e = b.expression;
          if (e is SimpleStringLiteral || e is AdjacentStrings) {
            mem.bodyKind = 'literal';
          } else if (e is StringInterpolation) {
            final exprs = e.elements
                .whereType<InterpolationExpression>()
                .map((ie) => ie.expression)
                .toList();
            mem.placeholders = exprs.length;
            final paramNames = {
              for (final fp
                  in m.parameters?.parameters ?? const <FormalParameter>[])
                fp.name?.lexeme,
            };
            bool isParam(Expression x) =>
                x is SimpleIdentifier && paramNames.contains(x.name);
            mem.bodyKind = exprs.every(isParam) ? 'interp' : 'interp+expr';
            if (!exprs.every(isParam)) {
              mem.detail = exprs
                  .where((x) => !isParam(x))
                  .map((x) => x.toSource())
                  .join(' | ');
            }
          } else if (e is ConditionalExpression) {
            mem.bodyKind = 'conditional';
            mem.detail = e.condition.toSource();
          } else if (e is SwitchExpression) {
            mem.bodyKind = 'switch';
            mem.detail = '${e.cases.length} cases';
          } else {
            mem.bodyKind = 'logic';
            mem.detail = e.toSource();
          }
        } else {
          mem.bodyKind = 'block';
        }
        if (name.startsWith('_')) mem.kind = 'private';
        c.members['$cls.$name'] = mem;
      }
    }
  }
}

// --- references --------------------------------------------------------------

class _RefVisitor extends RecursiveAstVisitor<void> {
  _RefVisitor(this.project, this.c, this.path, this.unit, this.content)
    : rel = project.rel(path);

  final Project project;
  final _Collected c;
  final String path;
  final String rel;
  final CompilationUnit unit;
  final String content;

  int lineOf(int offset) => unit.lineInfo.getLocation(offset).lineNumber;

  late final List<String> _lines = content.split('\n');

  /// Data that must never be translated (language endonyms, proper names)
  /// carries `// l10n-allow: <reason>` on its own line, the previous line or
  /// the line above the declaration / argument that holds it.
  bool _allowed(AstNode node) {
    bool marked(int l) =>
        l >= 1 && l <= _lines.length && _allowMarker.hasMatch(_lines[l - 1]);
    final line = lineOf(node.offset);
    if (marked(line) || marked(line - 1)) return true;
    final holder = node.thisOrAncestorMatching(
      (n) =>
          n is VariableDeclaration ||
          n is FieldDeclaration ||
          n is TopLevelVariableDeclaration ||
          n is NamedExpression ||
          n is Statement,
    );
    return holder != null && marked(lineOf(holder.offset) - 1);
  }

  int colOf(int offset) => unit.lineInfo.getLocation(offset).columnNumber;

  bool _isStringsClass(String? name) =>
      name != null && kStringsClassPrefixes.containsKey(name);

  void record(AstNode refNode, Element el, String usage) {
    final encl = el.enclosingElement;
    if (encl is! ClassElement) return;
    final cls = encl.name;
    if (!_isStringsClass(cls)) return;
    final memberName = el is GetterElement ? el.variable.name : el.name;
    final r = ScanRef()
      ..file = rel
      ..line = lineOf(refNode.offset)
      ..col = colOf(refNode.offset)
      ..offset = refNode.offset
      ..cls = cls!
      ..member = memberName ?? '?'
      ..usage = usage
      ..cat = categoryOf(rel);
    final (ck, co) = constContextOf(refNode);
    r.constKind = ck;
    r.constOwner = co;

    // `const Text(X.y)` directly.
    final par = refNode.parent;
    if (par is ArgumentList) {
      final ice = par.parent;
      if (ice is InstanceCreationExpression &&
          ice.keyword?.keyword == Keyword.CONST &&
          ice.constructorName.type.name.lexeme == 'Text' &&
          identical(par.arguments.first, refNode)) {
        r.constTextDirect = true;
      }
    }

    // Context availability and the enclosing declaration.
    var ctx = 'none';
    var hasRef = false;
    var enclosing = '<top>';
    var enclosingKind = 'top-level';
    AstNode? n = refNode.parent;
    var inStaticOrInit = false;
    while (n != null) {
      if (n is FunctionExpression ||
          n is MethodDeclaration ||
          n is ConstructorDeclaration) {
        for (final fp in paramsOf(n)) {
          final t = paramType(fp);
          if (ctx == 'none' && isBuildContext(t)) {
            ctx = 'param:${fp.name?.lexeme}';
          }
          if (isRiverpodRef(t)) hasRef = true;
        }
      }
      if (n is FunctionDeclaration) {
        for (final fp
            in n.functionExpression.parameters?.parameters ??
                const <FormalParameter>[]) {
          final t = paramType(fp);
          if (ctx == 'none' && isBuildContext(t)) {
            ctx = 'param:${fp.name?.lexeme}';
          }
          if (isRiverpodRef(t)) hasRef = true;
        }
        if (n.parent is CompilationUnit) {
          enclosing = n.name.lexeme;
          enclosingKind = 'top-level-fn';
        }
      }
      if (n is MethodDeclaration) {
        if (n.isStatic) inStaticOrInit = true;
        enclosing = n.name.lexeme;
      }
      if (n is FieldDeclaration) {
        inStaticOrInit = true;
        enclosing = n.fields.variables.map((v) => v.name.lexeme).join(',');
        enclosingKind = 'field-init';
      }
      if (n is ConstructorDeclaration) {
        enclosing = 'ctor ${n.name?.lexeme ?? ''}';
      }
      if (n is TopLevelVariableDeclaration) {
        enclosing = n.variables.variables.map((v) => v.name.lexeme).join(',');
        enclosingKind = 'top-level-var';
      }
      if (n is ClassDeclaration ||
          n is EnumDeclaration ||
          n is MixinDeclaration) {
        final InterfaceElement? ce = switch (n) {
          ClassDeclaration() => n.declaredFragment?.element,
          EnumDeclaration() => n.declaredFragment?.element,
          MixinDeclaration() => n.declaredFragment?.element,
          _ => null,
        };
        final name = switch (n) {
          ClassDeclaration() => n.namePart.typeName.lexeme,
          EnumDeclaration() => n.namePart.typeName.lexeme,
          MixinDeclaration() => n.name.lexeme,
          _ => '?',
        };
        final k = classKind(ce);
        enclosingKind = enclosingKind == 'field-init' ? '$k field-init' : k;
        enclosing = '$name.$enclosing';
        if (ctx == 'none' && k == 'State' && !inStaticOrInit) {
          ctx = 'State.context';
        }
        break;
      }
      if (n is ExtensionDeclaration) {
        enclosingKind = 'extension';
        enclosing = '${n.name?.lexeme ?? 'ext'}.$enclosing';
        break;
      }
      n = n.parent;
    }

    // What the reference feeds: hazards and the widget it belongs to.
    {
      AstNode child = refNode;
      AstNode? q = refNode.parent;
      if (q is MethodInvocation &&
          identical(q.target, refNode) &&
          (q.methodName.name == 'toUpperCase' ||
              q.methodName.name == 'toLowerCase')) {
        r.caseMap = true;
      }
      while (q != null &&
          q is! Statement &&
          q is! FunctionBody &&
          q is! ClassMember) {
        if (q is InterpolationExpression) r.concat = true;
        if (q is BinaryExpression &&
            q.operator.lexeme == '+' &&
            (q.leftOperand is StringLiteral ||
                q.rightOperand is StringLiteral)) {
          r.concat = true;
        }
        if (r.argName == null &&
            q is NamedExpression &&
            identical(q.expression, child)) {
          r.argName = q.name.label.name;
        }
        if (r.widget == null) {
          if (q is InstanceCreationExpression) {
            r.widget = q.constructorName.type.name.lexeme;
          } else if (q is MethodInvocation &&
              q.methodName.name != 'toUpperCase' &&
              q.methodName.name != 'toLowerCase' &&
              !identical(q, refNode)) {
            final t = q.target;
            final m = q.methodName.name;
            if (t == null && m.isNotEmpty && m[0] == m[0].toUpperCase()) {
              r.widget = m; // unresolved-looking constructor call
            } else if (t == null) {
              r.widget = '$m()';
            }
          }
        }
        child = q;
        q = q.parent;
      }
      AstNode? f = refNode.parent;
      while (f != null) {
        if (f is FunctionBody && f.isAsynchronous) r.inAsync = true;
        if (f is MethodDeclaration) {
          if (f.name.lexeme == 'initState') r.inInitState = true;
          break;
        }
        f = f.parent;
      }
      r.afterAwait = _afterAwait(refNode);
    }

    r.contextSource = ctx;
    r.hasRef = hasRef;
    r.enclosing = enclosing;
    r.enclosingKind = enclosingKind;
    final s = refNode.offset;
    final e = (refNode.end - s) > 120 ? s + 120 : refNode.end;
    r.snippet = content.substring(s, e).replaceAll(RegExp(r'\s+'), ' ');
    c.refs.add(r);
  }

  /// An `await` earlier in the same function body (nested closures count as
  /// their own body).
  bool _afterAwait(AstNode ref) {
    final body = ref.thisOrAncestorOfType<FunctionBody>();
    if (body == null || !body.isAsynchronous) return false;
    var found = false;
    body.accept(_AwaitBefore(ref.offset, () => found = true));
    return found;
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    final el = node.identifier.element;
    if (el != null) {
      final before = c.refs.length;
      record(node, el, el is MethodElement ? 'tearoff' : 'read');
      if (c.refs.length > before) return; // children already covered
    }
    super.visitPrefixedIdentifier(node);
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    final el = node.propertyName.element;
    if (el != null) {
      final before = c.refs.length;
      record(node, el, el is MethodElement ? 'tearoff' : 'read');
      if (c.refs.length > before) return;
    }
    super.visitPropertyAccess(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final el = node.methodName.element;
    if (el != null && node.target != null) {
      final before = c.refs.length;
      record(node, el, 'call');
      if (c.refs.length > before) {
        node.argumentList.accept(this);
        return;
      }
    } else if (el != null && node.target == null) {
      final before = c.refs.length;
      record(node, el, 'bare-call');
      if (c.refs.length > before) {
        node.argumentList.accept(this);
        return;
      }
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    // Bare references inside the strings classes themselves.
    final par = node.parent;
    if (par is PrefixedIdentifier ||
        par is PropertyAccess ||
        par is MethodInvocation) {
      return;
    }
    final el = node.element;
    if (el != null && !node.inDeclarationContext()) {
      record(node, el, 'bare-read');
    }
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (rel.startsWith('test/') &&
        node.constructorName.type.name.lexeme == 'MaterialApp') {
      final names = {
        for (final a in node.argumentList.arguments)
          if (a is NamedExpression) a.name.label.name,
      };
      final ctor = node.constructorName.name?.name;
      c.materialApps.add(
        ScanMaterialApp(
          rel,
          lineOf(node.offset),
          ctor == null ? 'MaterialApp' : 'MaterialApp.$ctor',
          names.contains('localizationsDelegates'),
          names.contains('locale'),
        ),
      );
    }
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    _checkVi(node, node.value);
  }

  @override
  void visitStringInterpolation(StringInterpolation node) {
    final text = node.elements
        .whereType<InterpolationString>()
        .map((e) => e.value)
        .join();
    _checkVi(node, text);
    super.visitStringInterpolation(node);
  }

  void _checkVi(AstNode node, String value) {
    if (rel.endsWith('_strings.dart') || !rel.startsWith('lib/')) return;
    if (node.thisOrAncestorOfType<Directive>() != null) return;
    if (!_viChars.hasMatch(value)) return;
    if (_allowed(node)) return;
    c.viLiterals.add({
      'file': rel,
      'line': lineOf(node.offset),
      'value': value.length > 80 ? '${value.substring(0, 80)}…' : value,
    });
  }
}

class _AwaitBefore extends RecursiveAstVisitor<void> {
  _AwaitBefore(this.limit, this.hit);

  final int limit;
  final void Function() hit;

  @override
  void visitAwaitExpression(AwaitExpression node) {
    if (node.end <= limit) hit();
    super.visitAwaitExpression(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {
    // A nested closure has its own body: its awaits do not precede us.
  }
}

// --- report ------------------------------------------------------------------

Map<String, int> _count(Iterable<String?> values) {
  final m = <String, int>{};
  for (final v in values) {
    m.update(v ?? 'none', (n) => n + 1, ifAbsent: () => 1);
  }
  return Map.fromEntries(
    m.entries.toList()..sort((a, b) {
      final byCount = b.value.compareTo(a.value);
      return byCount != 0 ? byCount : a.key.compareTo(b.key);
    }),
  );
}

Map<String, Object?> _report(Project project, _Collected c, List<Glob> only) {
  int byPos(ScanRef a, ScanRef b) {
    final f = a.file.compareTo(b.file);
    return f != 0 ? f : a.offset.compareTo(b.offset);
  }

  final refs = [...c.refs]..sort(byPos);
  final members = c.members.values.toList()
    ..sort((a, b) {
      final f = a.file.compareTo(b.file);
      return f != 0 ? f : a.line.compareTo(b.line);
    });
  final apps = [...c.materialApps]
    ..sort((a, b) {
      final f = a.file.compareTo(b.file);
      return f != 0 ? f : a.line.compareTo(b.line);
    });
  final vi = [...c.viLiterals]
    ..sort((a, b) {
      final f = (a['file']! as String).compareTo(b['file']! as String);
      return f != 0 ? f : (a['line']! as int).compareTo(b['line']! as int);
    });

  final lib = refs.where((r) => !r.file.startsWith('test/')).toList();
  final test = refs.where((r) => r.file.startsWith('test/')).toList();
  final libUse = lib.where((r) => r.cat != 'strings').toList();
  final noCtx = libUse.where((r) => r.contextSource == 'none').toList();
  final constRefs = libUse.where((r) => r.constKind != null).toList();
  final referenced = {for (final r in refs) r.memberId};
  final listMapKinds = {'const-list', 'const-map'};
  final listMapIds = {
    for (final m in members)
      if (listMapKinds.contains(m.kind)) m.id,
  };

  final summary = <String, Object?>{
    'refs': {
      'total': refs.length,
      'lib': lib.length,
      'libOutsideStringsFiles': libUse.length,
      'libFiles': libUse.map((r) => r.file).toSet().length,
      'test': test.length,
      'testFiles': test.map((r) => r.file).toSet().length,
      'usage': _count(libUse.map((r) => r.usage)),
      'perClass': _count(libUse.map((r) => r.cls)),
      'perLayer': _count(libUse.map((r) => r.cat)),
    },
    'context': {
      'withContext': libUse.length - noCtx.length,
      'afterAwaitWithContext': libUse
          .where((r) => r.contextSource != 'none' && r.afterAwait)
          .length,
      'inAsyncWithContext': libUse
          .where((r) => r.contextSource != 'none' && r.inAsync)
          .length,
      'noContext': noCtx.length,
      'noContextSymbols': noCtx.map((r) => r.memberId).toSet().length,
      'noContextEnclosingDeclarations': noCtx
          .map((r) => '${r.file} ${r.enclosing}')
          .toSet()
          .length,
      'noContextFiles': noCtx.map((r) => r.file).toSet().length,
      'noContextByEnclosingKind': _count(noCtx.map((r) => r.enclosingKind)),
      'noContextByLayer': _count(noCtx.map((r) => r.cat)),
      'namedContextParams': _count(
        libUse
            .where((r) => r.contextSource.startsWith('param:'))
            .map((r) => r.contextSource),
      ),
    },
    'const': {
      'refs': constRefs.length,
      'files': constRefs.map((r) => r.file).toSet().length,
      'byKind': _count(constRefs.map((r) => r.constKind)),
      'constTextDirect': libUse.where((r) => r.constTextDirect).length,
      'withContextToo': constRefs
          .where((r) => r.contextSource != 'none')
          .length,
    },
    'hazards': {
      'tearOffs': [
        for (final r in libUse.where((r) => r.usage == 'tearoff'))
          '${r.memberId} ${r.file}:${r.line}',
      ],
      'listMapUses': [
        for (final r in libUse.where((r) => listMapIds.contains(r.memberId)))
          '${r.memberId} ${r.file}:${r.line}',
      ],
      'caseTransforms': [
        for (final r in libUse.where((r) => r.caseMap))
          '${r.memberId} ${r.file}:${r.line}',
      ],
      'concatenations': libUse.where((r) => r.concat).length,
    },
    'members': {
      'total': members.length,
      'byKind': _count(members.map((m) => m.kind)),
      'functionBodies': _count(
        members.where((m) => m.kind == 'fn').map((m) => m.bodyKind),
      ),
      'unreferenced': [
        for (final m in members)
          if (!referenced.contains(m.id) && m.kind != 'private') m.id,
      ],
    },
    'viLiteralsOutsideStringsFiles': vi.length,
    'testHarness': {
      'materialApps': apps.length,
      'withLocalizationsDelegates': apps.where((a) => a.hasDelegates).length,
      'withLocale': apps.where((a) => a.hasLocale).length,
      'files': apps.map((a) => a.file).toSet().length,
    },
  };

  return {
    'tool': 'l10n_codemod scan',
    'schema': 1,
    'inputGitSha': project.gitSha(),
    'only': [for (final g in only) g.pattern],
    'filesAnalyzed': c.files,
    'knownClasses': kStringsClassPrefixes.keys.toList(),
    'unknownStringsClasses': {
      for (final e in c.unknownClasses.entries) e.key: e.value,
    },
    'missingKnownClasses': [
      for (final k in kStringsClassPrefixes.keys)
        if (!members.any((m) => m.cls == k) && only.isEmpty) k,
    ],
    'summary': summary,
    'analysisErrors': c.diagnostics,
    'members': [for (final m in members) m.toJson()],
    'refs': [for (final r in refs) r.toJson()],
    'viLiterals': vi,
    'materialApps': [for (final a in apps) a.toJson()],
  };
}

String _summary(Map<String, Object?> json, Duration elapsed) {
  final s = json['summary']! as Map<String, Object?>;
  final refs = s['refs']! as Map<String, Object?>;
  final ctx = s['context']! as Map<String, Object?>;
  final cst = s['const']! as Map<String, Object?>;
  final haz = s['hazards']! as Map<String, Object?>;
  final mem = s['members']! as Map<String, Object?>;
  final app = s['testHarness']! as Map<String, Object?>;
  final unknown = json['unknownStringsClasses']! as Map<String, Object?>;
  final missing = json['missingKnownClasses']! as List<Object?>;
  final errors = json['analysisErrors']! as List<Object?>;
  final b = StringBuffer()
    ..writeln(
      'l10n scan @ ${json['inputGitSha'] ?? 'no git'}: '
      '${json['filesAnalyzed']} files in ${elapsed.inSeconds} s',
    )
    ..writeln(
      'members: ${mem['total']} ${mem['byKind']}; '
      '${(mem['unreferenced']! as List<Object?>).length} unreferenced',
    )
    ..writeln(
      'refs: ${refs['total']} = ${refs['libOutsideStringsFiles']} in '
      '${refs['libFiles']} lib files (outside the strings files) + '
      '${refs['test']} in ${refs['testFiles']} test files',
    )
    ..writeln('usage (lib): ${refs['usage']}')
    ..writeln(
      'context: ${ctx['withContext']} with a BuildContext in scope '
      '(${ctx['afterAwaitWithContext']} after an await, '
      '${ctx['inAsyncWithContext']} inside an async body), '
      '${ctx['noContext']} without = ${ctx['noContextSymbols']} members in '
      '${ctx['noContextEnclosingDeclarations']} declarations in '
      '${ctx['noContextFiles']} files',
    )
    ..writeln(
      '  no-context by enclosing kind: ${ctx['noContextByEnclosingKind']}',
    )
    ..writeln(
      'const contexts: ${cst['refs']} refs in ${cst['files']} files '
      '(${cst['constTextDirect']} are `const Text(X.y)`) ${cst['byKind']}',
    )
    ..writeln(
      'hazards: ${(haz['tearOffs']! as List<Object?>).length} tear-offs, '
      '${(haz['listMapUses']! as List<Object?>).length} list/map uses, '
      '${(haz['caseTransforms']! as List<Object?>).length} case transforms, '
      '${haz['concatenations']} concatenations',
    )
    ..writeln(
      'Vietnamese literals outside the strings files: '
      '${s['viLiteralsOutsideStringsFiles']}',
    )
    ..writeln(
      'test MaterialApp: ${app['materialApps']} in ${app['files']} files, '
      '${app['withLocalizationsDelegates']} with localizationsDelegates',
    );
  if (unknown.isNotEmpty) {
    b.writeln('DRIFT: *Strings classes not in known_classes.dart: $unknown');
  }
  if (missing.isNotEmpty) {
    b.writeln('DRIFT: known classes not found: $missing');
  }
  if (errors.isNotEmpty) {
    b.writeln('WARNING: ${errors.length} file(s) have analysis errors');
  }
  return b.toString();
}

/// The default report location under [project].
String defaultReportPath(Project project) =>
    p.join(project.reportsDir, 'scan.json');
