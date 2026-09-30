/// Resolved-AST helpers shared by the commands: what surrounds an expression
/// (a `BuildContext` in scope? a Riverpod `Ref`? a `const` context?), i.e. the
/// facts the rewrite rules R1-R4 decide on (docs/design/I18N.md 5.3).
library;

import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/token.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';

bool isBuildContext(DartType? t) =>
    t != null && t.element?.name == 'BuildContext';

bool isRiverpodRef(DartType? t) {
  final n = t?.element?.name;
  return n == 'Ref' || n == 'WidgetRef';
}

bool isStateClass(InterfaceElement? e) {
  if (e == null) return false;
  for (final s in e.allSupertypes) {
    if (s.element.name == 'State' &&
        s.element.library.uri.toString().startsWith('package:flutter/')) {
      return true;
    }
  }
  return false;
}

/// `enum`, `State`, `Widget`, `Notifier`, `Exception` or plain `class`.
String classKind(InterfaceElement? e) {
  if (e == null) return 'unknown';
  if (e is EnumElement) return 'enum';
  final names = e.allSupertypes.map((s) => s.element.name).toSet();
  if (isStateClass(e)) return 'State';
  if (names.contains('Widget')) return 'Widget';
  if (names.any((n) => n != null && n.endsWith('Notifier'))) return 'Notifier';
  if (names.contains('Exception') || names.contains('Error')) {
    return 'Exception';
  }
  return 'class';
}

/// The parameter list of a function-like node.
List<FormalParameter> paramsOf(AstNode n) {
  FormalParameterList? l;
  if (n is FunctionExpression) l = n.parameters;
  if (n is MethodDeclaration) l = n.parameters;
  if (n is ConstructorDeclaration) l = n.parameters;
  return l?.parameters ?? const [];
}

DartType? paramType(FormalParameter fp) {
  final inner = fp is DefaultFormalParameter ? fp.parameter : fp;
  return inner.declaredFragment?.element.type;
}

/// The outermost `const` context [start] sits in, as `(kind, owner)`, or
/// `(null, null)` when it is evaluated at run time. Removing the `const`
/// keyword of that root (rule R2) is what lets `context.l10n.x` replace a
/// constant string there.
///
/// Kinds: `const-ctor`, `const-literal`, `const-record`, `const-var`,
/// `enum-args`, `default-value`, `annotation`, `switch-case`,
/// `const-pattern`.
(String?, String?) constContextOf(AstNode start) {
  AstNode? cur = start.parent;
  AstNode child = start;
  while (cur != null) {
    switch (cur) {
      case Annotation():
        return ('annotation', cur.name.name);
      case EnumConstantArguments():
        final ec = cur.parent as EnumConstantDeclaration;
        final en = ec.thisOrAncestorOfType<EnumDeclaration>()!;
        return (
          'enum-args',
          '${en.namePart.typeName.lexeme}.${ec.name.lexeme}',
        );
      case InstanceCreationExpression():
        if (cur.keyword?.keyword == Keyword.CONST) {
          return ('const-ctor', cur.constructorName.type.name.lexeme);
        }
      case DotShorthandConstructorInvocation():
        if (cur.constKeyword != null) return ('const-ctor', '.shorthand');
      case RecordLiteral():
        if (cur.constKeyword != null) return ('const-record', null);
      case SwitchCase():
        return ('switch-case', null);
      case ConstantPattern():
        return ('const-pattern', null);
      case TypedLiteral():
        if (cur.constKeyword != null) {
          return ('const-literal', cur is ListLiteral ? 'List' : 'Set/Map');
        }
      case VariableDeclarationList():
        if (cur.keyword?.keyword == Keyword.CONST) {
          final decl = cur.parent;
          var owner = 'local const';
          if (decl is FieldDeclaration) {
            owner = decl.isStatic ? 'static const field' : 'const field';
          }
          if (decl is TopLevelVariableDeclaration) owner = 'top-level const';
          return ('const-var', owner);
        }
        return (null, null);
      case DefaultFormalParameter():
        if (identical(cur.defaultValue, child)) {
          return ('default-value', cur.name?.lexeme);
        }
        return (null, null);
      case ArgumentList() ||
          Expression() ||
          ForElement() ||
          IfElement() ||
          InterpolationExpression() ||
          MapLiteralEntry() ||
          NullAwareElement() ||
          SpreadElement() ||
          VariableDeclaration() ||
          Label() ||
          InterpolationString():
        break;
      default:
        return (null, null);
    }
    child = cur;
    cur = cur.parent;
  }
  return (null, null);
}
