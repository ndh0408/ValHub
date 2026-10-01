import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';

import 'ast_context.dart';
import 'catalog.dart';
import 'project.dart';

class TextEdit {
  const TextEdit(this.offset, this.length, this.text);
  final int offset;
  final int length;
  final String text;
}

class RewritePlan {
  RewritePlan(this.source, this.edits, this.skipped);
  final String source;
  final List<TextEdit> edits;
  final List<Map<String, Object?>> skipped;
  String apply() {
    final descending = [...edits]..sort((a, b) => b.offset.compareTo(a.offset));
    var result = source;
    var boundary = source.length;
    for (final edit in descending) {
      if (edit.offset < 0 || edit.offset + edit.length > boundary) {
        throw ProjectException('overlapping or invalid rewrite edits');
      }
      result = result.replaceRange(
        edit.offset,
        edit.offset + edit.length,
        edit.text,
      );
      boundary = edit.offset;
    }
    return result;
  }
}

/// Mechanical view-boundary rules only. Defaults, enums, collection lookups, captured fields,
/// no-context/domain references and reads after await require structural work and are reported.
RewritePlan planUnit(ResolvedUnitResult unit, Map<String, String> keys) {
  final visitor = _RewriteVisitor(unit, keys);
  unit.unit.accept(visitor);
  if (unit.unit.directives.any((d) => d is PartOfDirective)) {
    return RewritePlan(unit.content, const [], [
      {
        'reason': 'part files need imports in the owning library; migrate structurally',
      },
    ]);
  }
  if (visitor.edits.isNotEmpty &&
      !unit.unit.directives.whereType<ImportDirective>().any(
        (d) => d.uri.stringValue?.endsWith('/l10n/l10n.dart') ?? false,
      )) {
    final imports = unit.unit.directives.whereType<ImportDirective>().toList();
    final offset = imports.isNotEmpty
        ? imports.last.end
        : unit.unit.directives.isEmpty
        ? 0
        : unit.unit.directives.last.end;
    visitor.edits[offset] = TextEdit(
      offset,
      0,
      "\nimport 'package:valvn/core/l10n/l10n.dart';\n",
    );
  }
  return RewritePlan(
    unit.content,
    visitor.edits.values.toList(),
    visitor.skipped,
  );
}

class _RewriteVisitor extends RecursiveAstVisitor<void> {
  _RewriteVisitor(this.unit, this.keys);
  final ResolvedUnitResult unit;
  final Map<String, String> keys;
  final edits = <int, TextEdit>{};
  final skipped = <Map<String, Object?>>[];

  bool replace(AstNode node, Element? element, int end) {
    final cls = element?.enclosingElement;
    if (cls is! ClassElement || !cls.name!.endsWith('Strings')) return false;
    final name = element is GetterElement
        ? element.variable.name
        : element?.name;
    final symbol = '${cls.name}.$name';
    final key = keys[symbol];
    String? reason;
    String? context;
    final shadowedParameters = <String>{};
    final consts = <TextEdit>[];
    for (
      AstNode? parent = node.parent;
      parent != null;
      parent = parent.parent
    ) {
      if (parent is DefaultFormalParameter ||
          parent is Annotation ||
          parent is ConstantPattern ||
          parent is SwitchCase ||
          parent is EnumConstantArguments ||
          parent is FieldDeclaration ||
          parent is TopLevelVariableDeclaration) {
        reason =
            'constant/default/captured field requires structural migration';
        break;
      }
      if (parent is VariableDeclarationList &&
          parent.keyword?.keyword == Keyword.CONST) {
        consts.add(
          TextEdit(parent.keyword!.offset, parent.keyword!.length, 'final'),
        );
      }
      Token? token;
      if (parent is InstanceCreationExpression &&
          parent.keyword?.keyword == Keyword.CONST) {
        token = parent.keyword;
      }
      if (parent is TypedLiteral) token = parent.constKeyword;
      if (parent is RecordLiteral) token = parent.constKeyword;
      if (parent is DotShorthandConstructorInvocation) {
        token = parent.constKeyword;
      }
      if (token != null) consts.add(TextEdit(token.offset, token.length, ''));
      if (parent is FunctionBody && parent.isAsynchronous) {
        // An inherited-widget lookup after an await must be captured before suspension by a human.
        final awaits = _AwaitDetector(node.offset);
        parent.accept(awaits);
        if (awaits.found) {
          reason = 'localization read after await';
          break;
        }
      }
      if (parent is FunctionExpression ||
          parent is MethodDeclaration ||
          parent is ConstructorDeclaration) {
        if (parent is MethodDeclaration &&
            ['initState', 'dispose'].contains(parent.name.lexeme)) {
          reason = 'lifecycle text capture requires structural migration';
          break;
        }
        for (final parameter in paramsOf(parent)) {
          if (isBuildContext(paramType(parameter)) &&
              !shadowedParameters.contains(parameter.name?.lexeme)) {
            context ??= parameter.name?.lexeme;
          }
        }
        shadowedParameters.addAll(
          paramsOf(parent).map((p) => p.name?.lexeme).whereType<String>(),
        );
      }
      if (parent is ClassDeclaration) {
        if (context == null &&
            !shadowedParameters.contains('context') &&
            isStateClass(parent.declaredFragment?.element)) {
          context = 'context';
        }
        break;
      }
    }
    if (key == null) reason ??= 'structural or collection member';
    if (context == null) reason ??= 'no BuildContext in scope';
    if (element is MethodElement &&
        element.formalParameters.any((p) => p.isNamed || p.isOptional)) {
      reason ??= 'optional/named arguments require explicit adapter';
    }
    if (reason != null) {
      skipped.add({
        'symbol': symbol,
        'line': unit.lineInfo.getLocation(node.offset).lineNumber,
        'reason': reason,
      });
      return true;
    }
    edits[node.offset] = TextEdit(
      node.offset,
      end - node.offset,
      '$context.l10n.$key',
    );
    for (final edit in consts) {
      edits[edit.offset] = edit;
    }
    return true;
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    if (!replace(node, node.identifier.element, node.end)) {
      super.visitPrefixedIdentifier(node);
    }
  }

  @override
  void visitPropertyAccess(PropertyAccess node) {
    if (!replace(node, node.propertyName.element, node.end)) {
      super.visitPropertyAccess(node);
    }
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.target != null &&
        replace(node, node.methodName.element, node.methodName.end)) {
      node.argumentList.accept(
        this,
      ); // Nested string calls remain independent edits.
    } else {
      super.visitMethodInvocation(node);
    }
  }
}

class _AwaitDetector extends RecursiveAstVisitor<void> {
  _AwaitDetector(this.before);
  final int before;
  bool found = false;
  @override
  void visitAwaitExpression(AwaitExpression node) {
    if (node.offset < before) found = true;
    super.visitAwaitExpression(node);
  }

  @override
  void visitFunctionExpression(FunctionExpression node) {} // Do not confuse an unrelated nested async closure.
}

Future<Map<String, Object?>> rewrite(
  Project project,
  Catalog catalog, {
  required List<String> only,
  bool apply = false,
}) async {
  if (only.isEmpty) {
    throw ProjectException(
      'rewrite requires --only to select an explicit work package',
    );
  }
  final globs = only.map(Glob.new).toList();
  final keys = {
    for (final member in catalog.messages)
      if (member['index'] == null)
        '${member['cls']}.${member['member']}': member['key'] as String,
  };
  final collection = AnalysisContextCollection(
    includedPaths: [project.libDir],
    sdkPath: project.sdkPath,
  );
  try {
    final paths = [
      for (final context in collection.contexts)
        for (final path in context.contextRoot.analyzedFiles())
          if (path.endsWith('.dart') && matchesAny(globs, project.rel(path)))
            path,
    ]..sort();
    final files = <Map<String, Object?>>[];
    // Resolve and plan every selected file before mutating any source.
    final planned = <String, RewritePlan>{};
    for (final path in paths) {
      final rel = project.rel(path);
      if (rel.endsWith('_strings.dart') || rel.startsWith('lib/l10n/gen/')) {
        continue;
      }
      final unit = await collection
          .contextFor(path)
          .currentSession
          .getResolvedUnit(path);
      if (unit is! ResolvedUnitResult ||
          unit.diagnostics.any((d) => d.severity.name == 'ERROR')) {
        throw ProjectException('resolve selected file before rewriting: $rel');
      }
      final plan = planUnit(unit, keys);
      // Validate ranges/overlaps even during a dry run.
      plan.apply();
      planned[path] = plan;
      files.add({
        'file': rel,
        'edits': plan.edits.length,
        'skipped': plan.skipped,
      });
    }
    if (paths.isEmpty) throw ProjectException('--only matched no Dart files');
    if (apply) {
      for (final entry in planned.entries) {
        final file = File(entry.key);
        if (file.readAsStringSync() != entry.value.source) {
          throw ProjectException(
            'file changed while planning: ${project.rel(entry.key)}',
          );
        }
      }
      for (final entry in planned.entries) {
        if (entry.value.edits.isNotEmpty) {
          File(entry.key).writeAsStringSync(entry.value.apply());
        }
      }
    }
    return {
      'schema': 1,
      'applied': apply,
      'files': files,
      'edits': planned.values.fold<int>(0, (sum, p) => sum + p.edits.length),
      'skipped': planned.values.fold<int>(
        0,
        (sum, p) => sum + p.skipped.length,
      ),
    };
  } finally {
    await collection.dispose();
  }
}
