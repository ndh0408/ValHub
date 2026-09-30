// PROTOTYPE `callgraph`: copied from the design-time analysis session behind
// docs/design/I18N.md (section 5.1) so it survives outside the ephemeral
// scratchpad. NOT maintained and not analysed for style: it only has to
// compile.
//
// Reference index behind the "pass AppLocalizations as a parameter" propagation measure (I18N.md 2.2: 113 seeds -> 784 sites).
//
//   dart run tool/l10n_codemod/prototypes/callgraph.dart <out.json>
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:l10n_codemod/src/project.dart';
import 'package:path/path.dart' as p;

final Project _project = Project.discover();
final String root = _project.root;
final String sdk = _project.sdkPath;

String rel(String path) => p.relative(path, from: root).replaceAll(r'\', '/');

bool isBuildContext(DartType? t) =>
    t != null && t.element?.name == 'BuildContext';

bool isStateClass(InterfaceElement? e) {
  if (e == null) return false;
  return e.allSupertypes.any(
    (s) =>
        s.element.name == 'State' &&
        s.element.library.uri.toString().startsWith('package:flutter/'),
  );
}

String? keyOfElement(Element? e) {
  if (e == null) return null;
  var el = e;
  if (el is GetterElement && el.isOriginVariable) el = el.variable;
  if (el is SetterElement) return null;
  final lib = el.library?.uri.toString();
  if (lib == null || !lib.startsWith('package:valvn/')) return null;
  if (el is LocalElement ||
      el is FormalParameterElement ||
      el is LocalVariableElement)
    return null;
  final encl = el.enclosingElement;
  final name = el.name ?? (el is ConstructorElement ? '' : null);
  if (name == null) return null;
  if (encl is InstanceElement) {
    final cn = encl.name ?? (encl is ExtensionElement ? '<ext>' : '?');
    if (el is ConstructorElement)
      return '$lib#$cn.new${name.isEmpty ? '' : '.$name'}';
    return '$lib#$cn.$name';
  }
  if (encl is LibraryElement) return '$lib#$name';
  return null;
}

class Entry {
  Entry(
    this.target,
    this.file,
    this.line,
    this.ctx,
    this.encl,
    this.enclKind,
    this.isProviderInit,
  );
  final String target;
  final String file;
  final int line;
  final String ctx;
  final String? encl;
  final String enclKind;
  final bool isProviderInit;
  Map<String, Object?> toJson() => {
    't': target,
    'f': file,
    'l': line,
    'c': ctx,
    'e': encl,
    'k': enclKind,
    'p': isProviderInit,
  };
}

final entries = <Entry>[];
final decls = <String, Map<String, Object?>>{};

class V extends RecursiveAstVisitor<void> {
  V(this.path, this.unit);
  final String path;
  final CompilationUnit unit;

  (String ctx, String? encl, String kind, bool providerInit) scope(
    AstNode node,
  ) {
    var ctx = 'none';
    String? encl;
    var kind = 'top';
    var providerInit = false;
    var inStatic = false;
    AstNode? n = node.parent;
    while (n != null) {
      FormalParameterList? params;
      if (n is FunctionExpression) params = n.parameters;
      if (n is MethodDeclaration) params = n.parameters;
      if (n is ConstructorDeclaration) params = n.parameters;
      for (final fp in params?.parameters ?? const <FormalParameter>[]) {
        final inner = fp is DefaultFormalParameter ? fp.parameter : fp;
        final t = inner.declaredFragment?.element.type;
        if (ctx == 'none' && isBuildContext(t)) ctx = 'param';
      }
      if (encl == null) {
        if (n is FunctionDeclaration && n.parent is CompilationUnit) {
          encl = keyOfElement(n.declaredFragment?.element);
          kind = 'function';
        } else if (n is MethodDeclaration) {
          encl = keyOfElement(n.declaredFragment?.element);
          kind = n.isGetter ? 'getter' : 'method';
          if (n.isStatic) inStatic = true;
        } else if (n is ConstructorDeclaration) {
          encl = keyOfElement(n.declaredFragment?.element);
          kind = 'ctor';
        } else if (n is VariableDeclaration &&
            (n.parent?.parent is FieldDeclaration ||
                n.parent?.parent is TopLevelVariableDeclaration)) {
          final el = n.declaredFragment?.element;
          encl = keyOfElement(el);
          kind = n.parent?.parent is FieldDeclaration ? 'field' : 'topvar';
          inStatic = true;
          final init = n.initializer;
          if (init != null) {
            final src = init.toSource();
            if (RegExp(
              r'^(Provider|FutureProvider|StreamProvider|NotifierProvider|AsyncNotifierProvider|StateProvider)\b',
            ).hasMatch(src)) {
              providerInit = true;
            }
          }
        } else if (n is EnumConstantDeclaration) {
          final en = n.thisOrAncestorOfType<EnumDeclaration>();
          encl =
              keyOfElement(n.declaredFragment?.element) ??
              'enum-const ${en?.namePart.typeName.lexeme}.${n.name.lexeme}';
          kind = 'enum-const';
          inStatic = true;
        }
      }
      if (n is ClassDeclaration) {
        if (ctx == 'none' &&
            !inStatic &&
            isStateClass(n.declaredFragment?.element) &&
            kind != 'ctor')
          ctx = 'State';
        break;
      }
      n = n.parent;
    }
    return (ctx, encl, kind, providerInit);
  }

  void add(AstNode node, Element? el) {
    final k = keyOfElement(el);
    if (k == null) return;
    final (ctx, encl, kind, prov) = scope(node);
    entries.add(
      Entry(
        k,
        rel(path),
        unit.lineInfo.getLocation(node.offset).lineNumber,
        ctx,
        encl,
        kind,
        prov,
      ),
    );
  }

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (!node.inDeclarationContext()) add(node, node.element);
    super.visitSimpleIdentifier(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    add(node, node.constructorName.element);
    super.visitInstanceCreationExpression(node);
  }

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    if (node.parent is CompilationUnit) {
      final k = keyOfElement(node.declaredFragment?.element);
      if (k != null) decls[k] = {'file': rel(path), 'kind': 'function'};
    }
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final k = keyOfElement(node.declaredFragment?.element);
    if (k != null) {
      final cls = node.thisOrAncestorOfType<CompilationUnitMember>();
      decls[k] = {
        'file': rel(path),
        'kind': node.isGetter ? 'getter' : 'method',
        'static': node.isStatic,
        'container': cls is EnumDeclaration
            ? 'enum'
            : cls is ExtensionDeclaration
            ? 'extension'
            : 'class',
        'override': node.metadata.any((m) => m.name.name == 'override'),
      };
    }
    super.visitMethodDeclaration(node);
  }
}

Future<void> main(List<String> args) async {
  final coll = AnalysisContextCollection(
    includedPaths: [p.join(root, 'lib'), p.join(root, 'test')],
    sdkPath: sdk,
  );
  for (final ctx in coll.contexts) {
    for (final path in ctx.contextRoot.analyzedFiles()) {
      if (!path.endsWith('.dart')) continue;
      final res = await ctx.currentSession.getResolvedUnit(path);
      if (res is! ResolvedUnitResult) continue;
      res.unit.accept(V(path, res.unit));
    }
  }
  File(args.first).writeAsStringSync(
    jsonEncode({
      'entries': entries.map((e) => e.toJson()).toList(),
      'decls': decls,
    }),
  );
  stdout.writeln('entries=${entries.length} decls=${decls.length}');
}
