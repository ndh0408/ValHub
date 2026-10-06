// Deterministic validation of the ARB files (docs/design/I18N.md 14.6).
//
//   dart run tool/l10n_check.dart              report problems
//   dart run tool/l10n_check.dart --ci         same, as GitHub annotations
//   dart run tool/l10n_check.dart --root <d>   another project root (tests)
//
// Exit code 1 when there is at least one error; warnings never fail.
// `flutter gen-l10n` remains the final syntax check.
//
// Dependency-free (dart:io / dart:convert only): `dart:ui` is unavailable to
// `dart run`, so `AppLocale` is read from lib/core/l10n/app_locale.dart as
// text (check 11 below).
//
// Implemented in W0 (skeleton):
//   1  template exists, is valid JSON and is `vi`
//   2  file names match a known locale; `@@locale` matches the file name
//   3  key sets: extras are errors; a missing key is an error for a SHIPPED
//      locale, a warning otherwise (`es_MX` is a delta and may omit keys)
//   4  messages are strings; every `@key` has a message; template messages
//      have a description and typed placeholders; key names are lowerCamelCase
//      identifiers in a known namespace, not clashing with AppLocalizations
//   5  ICU syntax (own recursive parser), no literal `{` or `}`
//   6  placeholders: same set as the template, all declared in the template
//   7  plural/select have `other`; plural categories required by the locale;
//      every plural category branch keeps the count `{n}` (allowlist otherwise)
//   8  `x-locked` messages are identical in every locale
//   9  whitespace parity (leading/trailing space, newlines, trailing ellipsis)
//   11 every ARB file is an AppLocale, every shipped locale has one
// Left to lane LT (14.6): not-copied/script check (5), length budgets (6),
// bidi marks (8), term consistency (9), profanity (10), `en-fallback` gates
// (12, needs lib/l10n/status/*.json).
import 'dart:convert';
import 'dart:io';

import 'l10n_fmt.dart' show kKeyPrefixOrder, kTemplateFile, prefixIndex;

/// Locale of the template file.
const String kTemplateLocale = 'vi';

/// Plural categories each locale REQUIRES (I18N.md 4.4); `other` always.
/// fr/es/it/pt may also use `many` (exact millions in intl).
const Map<String, Set<String>> kPluralCategories = {
  'ar': {'zero', 'one', 'two', 'few', 'many', 'other'},
  'ru': {'one', 'few', 'many', 'other'},
  'pl': {'one', 'few', 'many', 'other'},
  'en': {'one', 'other'},
  'de': {'one', 'other'},
  'tr': {'one', 'other'},
  'fr': {'one', 'other'},
  'es': {'one', 'other'},
  'es_MX': {'one', 'other'},
  'it': {'one', 'other'},
  'pt': {'one', 'other'},
  'id': {'other'},
  'ja': {'other'},
  'ko': {'other'},
  'th': {'other'},
  'vi': {'other'},
  'zh': {'other'},
  'zh_Hant': {'other'},
};

const Set<String> _allCategories = {
  'zero',
  'one',
  'two',
  'few',
  'many',
  'other',
};

/// Categories a locale may add on top of the required ones without a warning.
const Map<String, Set<String>> _optionalCategories = {
  'fr': {'many'},
  'es': {'many'},
  'es_MX': {'many'},
  'it': {'many'},
  'pt': {'many'},
};

/// Namespaces that exist only for tests and are exempt from the namespace
/// rule. W1 deletes the `smoke*` keys together with this entry.
const Set<String> _testNamespaces = {'smoke'};

/// Member names of `AppLocalizations` a message key must not shadow.
const Set<String> _reservedKeys = {
  'localeName',
  'delegate',
  'of',
  'localizationsDelegates',
  'supportedLocales',
  'hashCode',
  'runtimeType',
  'toString',
  'noSuchMethod',
};

enum Severity { error, warning }

class Finding {
  Finding(this.severity, this.file, this.code, this.message, {this.key});

  final Severity severity;
  final String file;
  final String code;
  final String message;
  final String? key;

  String get where => key == null ? file : '$file:$key';

  String format({bool github = false}) {
    final level = severity == Severity.error ? 'error' : 'warning';
    if (github) {
      return '::$level file=$file,title=l10n_check $code::'
          '${key == null ? '' : '$key: '}$message';
    }
    return '$level [$code] $where: $message';
  }
}

class CheckResult {
  CheckResult(this.findings);

  final List<Finding> findings;

  List<Finding> get errors =>
      findings.where((f) => f.severity == Severity.error).toList();

  List<Finding> get warnings =>
      findings.where((f) => f.severity == Severity.warning).toList();
}

// --- ICU ---------------------------------------------------------------------

sealed class IcuNode {}

class IcuText extends IcuNode {
  IcuText(this.text);
  final String text;
}

class IcuArg extends IcuNode {
  IcuArg(this.name);
  final String name;
}

class IcuPlural extends IcuNode {
  IcuPlural(this.name, this.cases, {this.ordinal = false});
  final String name;
  final Map<String, List<IcuNode>> cases;
  final bool ordinal;
}

class IcuSelect extends IcuNode {
  IcuSelect(this.name, this.cases);
  final String name;
  final Map<String, List<IcuNode>> cases;
}

class IcuException implements Exception {
  IcuException(this.message, this.offset);
  final String message;
  final int offset;

  @override
  String toString() => '$message (at character $offset)';
}

/// Parses the gen-l10n ICU dialect: `{name}`, `{n, plural, =0{..} one{..}
/// other{..}}`, `{g, select, a{..} other{..}}`. Apostrophes are literal
/// (`use-escaping: false`), so a `{` always opens an argument and a `}` always
/// closes one: literal braces are errors.
List<IcuNode> parseIcu(String message) {
  final p = _IcuParser(message);
  final nodes = p.parseMessage(nested: false);
  return nodes;
}

class _IcuParser {
  _IcuParser(this.s);

  final String s;
  int i = 0;

  static final RegExp _identifier = RegExp(r'[A-Za-z_][A-Za-z0-9_]*');

  List<IcuNode> parseMessage({required bool nested}) {
    final nodes = <IcuNode>[];
    final text = StringBuffer();
    void flush() {
      if (text.isNotEmpty) {
        nodes.add(IcuText(text.toString()));
        text.clear();
      }
    }

    while (i < s.length) {
      final c = s[i];
      if (c == '{') {
        flush();
        nodes.add(_argument());
      } else if (c == '}') {
        if (nested) break;
        throw IcuException('unmatched "}" (literal braces are forbidden)', i);
      } else {
        text.write(c);
        i++;
      }
    }
    flush();
    return nodes;
  }

  IcuNode _argument() {
    final start = i;
    i++; // {
    _ws();
    final name = _read(_identifier, 'an argument name');
    _ws();
    if (_peek == '}') {
      i++;
      return IcuArg(name);
    }
    _expect(',');
    _ws();
    final type = _read(_identifier, 'plural or select');
    if (type != 'plural' && type != 'select' && type != 'selectordinal') {
      throw IcuException('unsupported argument type "$type"', start);
    }
    _ws();
    _expect(',');
    final cases = <String, List<IcuNode>>{};
    while (true) {
      _ws();
      if (_peek == '}') {
        i++;
        break;
      }
      final selector = _selector();
      if (cases.containsKey(selector)) {
        throw IcuException('duplicate case "$selector"', i);
      }
      _ws();
      _expect('{');
      final body = parseMessage(nested: true);
      _expect('}');
      cases[selector] = body;
    }
    if (cases.isEmpty) throw IcuException('"$type" without cases', start);
    return type == 'select'
        ? IcuSelect(name, cases)
        : IcuPlural(name, cases, ordinal: type == 'selectordinal');
  }

  String _selector() {
    if (_peek == '=') {
      final m = RegExp(r'=[0-9]+').matchAsPrefix(s, i);
      if (m == null) throw IcuException('expected digits after "="', i);
      i = m.end;
      return m.group(0)!;
    }
    return _read(_identifier, 'a case name');
  }

  String? get _peek => i < s.length ? s[i] : null;

  void _ws() {
    while (i < s.length && (s[i] == ' ' || s[i] == '\n' || s[i] == '\t')) {
      i++;
    }
  }

  void _expect(String c) {
    if (_peek != c) {
      throw IcuException(
        'expected "$c" but found ${_peek == null ? 'the end' : '"$_peek"'}',
        i,
      );
    }
    i++;
  }

  String _read(RegExp pattern, String what) {
    final m = pattern.matchAsPrefix(s, i);
    if (m == null) throw IcuException('expected $what', i);
    i = m.end;
    return m.group(0)!;
  }
}

/// Every argument name a message uses (plural/select selectors included).
Set<String> icuArguments(List<IcuNode> nodes) {
  final out = <String>{};
  void walk(List<IcuNode> ns) {
    for (final n in ns) {
      switch (n) {
        case IcuText():
          break;
        case IcuArg():
          out.add(n.name);
        case IcuPlural():
          out.add(n.name);
          n.cases.values.forEach(walk);
        case IcuSelect():
          out.add(n.name);
          n.cases.values.forEach(walk);
      }
    }
  }

  walk(nodes);
  return out;
}

/// Every plural node of a message, nested ones included.
List<IcuPlural> icuPlurals(List<IcuNode> nodes) {
  final out = <IcuPlural>[];
  void walk(List<IcuNode> ns) {
    for (final n in ns) {
      switch (n) {
        case IcuText() || IcuArg():
          break;
        case IcuPlural():
          out.add(n);
          n.cases.values.forEach(walk);
        case IcuSelect():
          n.cases.values.forEach(walk);
      }
    }
  }

  walk(nodes);
  return out;
}

List<IcuSelect> _icuSelects(List<IcuNode> nodes) {
  final out = <IcuSelect>[];
  void walk(List<IcuNode> ns) {
    for (final n in ns) {
      switch (n) {
        case IcuText() || IcuArg():
          break;
        case IcuPlural():
          n.cases.values.forEach(walk);
        case IcuSelect():
          out.add(n);
          n.cases.values.forEach(walk);
      }
    }
  }

  walk(nodes);
  return out;
}

// --- AppLocale (read as text) --------------------------------------------------

/// What check 11 needs from `lib/core/l10n/app_locale.dart`.
class AppLocaleInfo {
  AppLocaleInfo(this.arbCodes, this.shipped);

  /// ARB codes of every enum value (`vi`, `es_MX`, `zh_Hant`).
  final Set<String> arbCodes;

  /// ARB codes of `kShippedLocales`.
  final Set<String> shipped;
}

/// Reads the enum entries (`name(flutter: ..., arbCode: '..', ...)`) and the
/// `kShippedLocales` set out of the Dart source; `null` when the shape is not
/// recognised.
AppLocaleInfo? parseAppLocaleSource(String source) {
  final entry = RegExp(
    r"^  (\w+)\(\s*flutter:[\s\S]*?arbCode:\s*'([A-Za-z_]+)'",
    multiLine: true,
  );
  final byName = {
    for (final m in entry.allMatches(source)) m.group(1)!: m.group(2)!,
  };
  if (byName.isEmpty) return null;
  final set = RegExp(r'kShippedLocales\s*=\s*\{([^}]*)\}').firstMatch(source);
  if (set == null) return null;
  final shipped = <String>{};
  for (final m in RegExp(r'AppLocale\.(\w+)').allMatches(set.group(1)!)) {
    final code = byName[m.group(1)];
    if (code == null) return null;
    shipped.add(code);
  }
  return AppLocaleInfo(byName.values.toSet(), shipped);
}

// --- allowlist -----------------------------------------------------------------

/// `tool/l10n/allowlist.yaml`: a tiny YAML subset (sections with `- item`
/// lists, `#` comments), parsed by hand to stay dependency-free:
///
/// ```yaml
/// number-word:            # plural branches that may omit the count
///   - ar.commonMinutesAgo.two
/// ```
Map<String, Set<String>> parseAllowlist(String text) {
  final out = <String, Set<String>>{};
  String? section;
  for (var line in const LineSplitter().convert(text)) {
    final hash = line.indexOf('#');
    if (hash >= 0) line = line.substring(0, hash);
    if (line.trim().isEmpty) continue;
    final header = RegExp(r'^([A-Za-z][A-Za-z0-9_-]*):\s*$').firstMatch(line);
    if (header != null) {
      section = header.group(1);
      out.putIfAbsent(section!, () => {});
      continue;
    }
    final item = RegExp(r'^\s*-\s*(\S+)\s*$').firstMatch(line);
    if (item != null && section != null) out[section]!.add(item.group(1)!);
  }
  return out;
}

// --- the checks ----------------------------------------------------------------

/// Checks the ARB files of the project at [root].
CheckResult checkProject({String root = '.'}) {
  final findings = <Finding>[];
  void add(
    Severity severity,
    String file,
    String code,
    String message, {
    String? key,
  }) => findings.add(Finding(severity, file, code, message, key: key));
  void error(String file, String code, String message, {String? key}) =>
      add(Severity.error, file, code, message, key: key);
  void warn(String file, String code, String message, {String? key}) =>
      add(Severity.warning, file, code, message, key: key);

  final arbDir = '$root/lib/l10n/arb';
  final dir = Directory(arbDir);
  if (!dir.existsSync()) {
    error(arbDir, 'missing-template', 'directory not found');
    return CheckResult(findings);
  }

  AppLocaleInfo? info;
  final appLocaleFile = File('$root/lib/core/l10n/app_locale.dart');
  const appLocalePath = 'lib/core/l10n/app_locale.dart';
  if (appLocaleFile.existsSync()) {
    info = parseAppLocaleSource(appLocaleFile.readAsStringSync());
  }
  if (info == null) {
    error(
      appLocalePath,
      'app-locale-unreadable',
      'cannot read the AppLocale table / kShippedLocales (check 11 skipped)',
    );
  }

  final allowlistFile = File('$root/tool/l10n/allowlist.yaml');
  final allow = allowlistFile.existsSync()
      ? parseAllowlist(allowlistFile.readAsStringSync())
      : const <String, Set<String>>{};

  // Files -> decoded objects.
  final files = <String, Map<String, Object?>>{};
  final names =
      dir
          .listSync()
          .whereType<File>()
          .map((f) => f.uri.pathSegments.last)
          .where((n) => n.startsWith('app_') && n.endsWith('.arb'))
          .toList()
        ..sort();
  for (final name in names) {
    final code = name.substring(4, name.length - 4);
    final text = File('$arbDir/$name').readAsStringSync();
    try {
      final decoded = jsonDecode(text);
      if (decoded is! Map<String, Object?>) {
        error(name, 'bad-json', 'an ARB file must be a JSON object');
        continue;
      }
      files[code] = decoded;
    } on FormatException catch (e) {
      error(name, 'bad-json', 'not valid JSON: ${e.message}');
    }
  }

  // 1. template.
  final template = files[kTemplateLocale];
  if (!names.contains(kTemplateFile)) {
    error(kTemplateFile, 'missing-template', 'the template ARB does not exist');
  }

  // 2 + 11. known locales, @@locale, shipped locales.
  for (final entry in files.entries) {
    final name = 'app_${entry.key}.arb';
    final declared = entry.value['@@locale'];
    if (declared != entry.key) {
      error(
        name,
        'locale-mismatch',
        '"@@locale" is ${declared == null ? 'missing' : '"$declared"'}, '
            'expected "${entry.key}"',
      );
    }
    if (info != null && !info.arbCodes.contains(entry.key)) {
      error(
        name,
        'unknown-locale',
        '"${entry.key}" is not an AppLocale (known: '
            '${(info.arbCodes.toList()..sort()).join(', ')})',
      );
    }
  }
  if (info != null) {
    if (!info.arbCodes.contains(kTemplateLocale)) {
      error(
        appLocalePath,
        'template-not-a-locale',
        'AppLocale has no $kTemplateLocale',
      );
    }
    for (final code in info.shipped) {
      if (!files.containsKey(code)) {
        error(
          'app_$code.arb',
          'shipped-no-file',
          '$code is in kShippedLocales but has no ARB file',
        );
      }
    }
    if (!info.shipped.contains('en') &&
        !info.shipped.contains(kTemplateLocale)) {
      error(
        appLocalePath,
        'shipped-fallback',
        'kShippedLocales must contain en or $kTemplateLocale (the resolve() fallback)',
      );
    }
  }

  if (template == null) return CheckResult(findings);

  // Template messages: name -> (text, metadata).
  final templateMessages = <String, String>{};
  final templateMeta = <String, Map<String, Object?>>{};
  final templateNodes = <String, List<IcuNode>>{};
  final templateArgs = <String, Set<String>>{};
  final templateName = kTemplateFile;
  for (final e in template.entries) {
    final k = e.key;
    if (k.startsWith('@@')) continue;
    if (k.startsWith('@')) {
      final message = k.substring(1);
      if (!template.containsKey(message)) {
        error(
          templateName,
          'orphan-meta',
          '"@$message" has no message',
          key: message,
        );
      }
      final v = e.value;
      if (v is Map<String, Object?>) {
        templateMeta[message] = v;
      } else {
        error(
          templateName,
          'bad-meta',
          '"@$message" must be an object',
          key: message,
        );
      }
      continue;
    }
    // 4. key shape.
    if (!RegExp(r'^[a-z][A-Za-z0-9]*$').hasMatch(k)) {
      error(templateName, 'bad-key', 'not a lowerCamelCase identifier', key: k);
    } else if (_reservedKeys.contains(k)) {
      error(
        templateName,
        'reserved-key',
        'clashes with an AppLocalizations member',
        key: k,
      );
    } else if (prefixIndex(k) == kKeyPrefixOrder.length &&
        !_testNamespaces.any((p) => k.startsWith(p))) {
      warn(
        templateName,
        'unknown-namespace',
        'starts with none of ${kKeyPrefixOrder.join(' ')}',
        key: k,
      );
    }
    final v = e.value;
    if (v is! String) {
      error(
        templateName,
        'not-a-string',
        'the message must be a string',
        key: k,
      );
      continue;
    }
    templateMessages[k] = v;
  }

  for (final e in templateMessages.entries) {
    final k = e.key;
    final meta = templateMeta[k];
    final description = meta?['description'];
    if (description is! String || description.trim().isEmpty) {
      error(
        templateName,
        'no-description',
        'needs a non-empty "description" in @$k',
        key: k,
      );
    }
    // 5. ICU.
    final List<IcuNode> nodes;
    try {
      nodes = parseIcu(e.value);
    } on IcuException catch (ex) {
      error(templateName, 'icu-syntax', ex.toString(), key: k);
      continue;
    }
    templateNodes[k] = nodes;
    final used = icuArguments(nodes);
    templateArgs[k] = used;
    // 4/6. placeholders declared with a type.
    final declaredRaw = meta?['placeholders'];
    final declared = declaredRaw is Map<String, Object?>
        ? declaredRaw
        : const <String, Object?>{};
    for (final name in used) {
      if (!declared.containsKey(name)) {
        error(
          templateName,
          'placeholder-undeclared',
          '{$name} is used but not declared in @$k.placeholders',
          key: k,
        );
      }
    }
    for (final p in declared.entries) {
      if (!used.contains(p.key)) {
        error(
          templateName,
          'placeholder-unused',
          'placeholder "${p.key}" is declared but never used',
          key: k,
        );
      }
      final type = p.value is Map<String, Object?>
          ? (p.value! as Map<String, Object?>)['type']
          : null;
      if (type is! String || type.isEmpty) {
        error(
          templateName,
          'placeholder-type',
          'placeholder "${p.key}" needs a "type"',
          key: k,
        );
      }
    }
    // 7 (template): plural/select need `other`.
    _checkBranches(
      nodes,
      kTemplateLocale,
      templateName,
      k,
      allow,
      error,
      warn,
      isTemplate: true,
    );
  }

  // Other locales.
  for (final entry in files.entries) {
    final code = entry.key;
    if (code == kTemplateLocale) continue;
    final name = 'app_$code.arb';
    final shipped = info?.shipped.contains(code) ?? false;
    final subset = code == 'es_MX'; // a delta over `es`
    final present = <String>{};
    for (final e in entry.value.entries) {
      final k = e.key;
      if (k.startsWith('@')) continue;
      present.add(k);
      if (!templateMessages.containsKey(k)) {
        error(name, 'extra-key', 'not in the template', key: k);
        continue;
      }
      final v = e.value;
      if (v is! String) {
        error(name, 'not-a-string', 'the message must be a string', key: k);
        continue;
      }
      final source = templateMessages[k]!;
      final locked = templateMeta[k]?['x-locked'] == true;
      if (locked) {
        if (v != source) {
          error(
            name,
            'locked-differs',
            'is locked: must equal "$source"',
            key: k,
          );
        }
        continue;
      }
      // 9. whitespace parity.
      _checkWhitespace(source, v, name, k, error, spaceless: _spaceless(code));
      // 5. ICU.
      final List<IcuNode> nodes;
      try {
        nodes = parseIcu(v);
      } on IcuException catch (ex) {
        error(name, 'icu-syntax', ex.toString(), key: k);
        continue;
      }
      // 6. placeholders.
      final expected = templateArgs[k];
      if (expected != null) {
        final used = icuArguments(nodes);
        final missing = expected.difference(used);
        final extra = used.difference(expected);
        if (missing.isNotEmpty || extra.isNotEmpty) {
          error(
            name,
            'placeholder-mismatch',
            '${missing.isEmpty ? '' : 'missing {${missing.join('}, {')}}'}'
                '${missing.isNotEmpty && extra.isNotEmpty ? '; ' : ''}'
                '${extra.isEmpty ? '' : 'unknown {${extra.join('}, {')}}'}',
            key: k,
          );
        }
      }
      // 7.
      _checkBranches(
        nodes,
        code,
        name,
        k,
        allow,
        error,
        warn,
        isTemplate: false,
      );
    }
    // 3. missing keys.
    if (!subset) {
      final missing = templateMessages.keys
          .where((k) => !present.contains(k))
          .toList();
      if (missing.isNotEmpty) {
        final message =
            '${missing.length} of ${templateMessages.length} keys missing '
            '(gen-l10n would fill them from the template, i.e. Vietnamese): '
            '${missing.take(5).join(', ')}${missing.length > 5 ? ', ...' : ''}';
        if (shipped) {
          error(name, 'missing-key', message);
        } else {
          warn(name, 'missing-key', message);
        }
      }
    }
  }

  return CheckResult(findings);
}

void _checkBranches(
  List<IcuNode> nodes,
  String code,
  String file,
  String key,
  Map<String, Set<String>> allow,
  void Function(String, String, String, {String? key}) error,
  void Function(String, String, String, {String? key}) warn, {
  required bool isTemplate,
}) {
  final required = kPluralCategories[code] ?? const {'other'};
  final optional = _optionalCategories[code] ?? const <String>{};
  final numberWord = allow['number-word'] ?? const <String>{};
  for (final plural in icuPlurals(nodes)) {
    final categories = plural.cases.keys
        .where((c) => !c.startsWith('='))
        .toSet();
    for (final c in categories.difference(_allCategories)) {
      error(file, 'plural-category', 'unknown plural category "$c"', key: key);
    }
    if (!categories.contains('other')) {
      error(
        file,
        'plural-other',
        '{${plural.name}, plural} needs an "other" case',
        key: key,
      );
    }
    if (!isTemplate) {
      final missing = required.difference(categories);
      if (missing.isNotEmpty) {
        error(
          file,
          'plural-category',
          '{${plural.name}, plural} lacks ${missing.join(', ')} required for $code',
          key: key,
        );
      }
      final unused = categories
          .difference(required)
          .difference(optional)
          .intersection(_allCategories);
      if (unused.isNotEmpty) {
        warn(
          file,
          'plural-category',
          '${unused.join(', ')} is not used by $code and never selected',
          key: key,
        );
      }
      for (final e in plural.cases.entries) {
        if (e.key.startsWith('=')) continue;
        final allowed =
            numberWord.contains('$code.$key.${e.key}') ||
            numberWord.contains('$code.$key');
        if (!allowed && !icuArguments(e.value).contains(plural.name)) {
          error(
            file,
            'plural-number',
            'the "${e.key}" case drops the count {${plural.name}} '
                '(allowlist "$code.$key.${e.key}" under number-word if intended)',
            key: key,
          );
        }
      }
    }
  }
  for (final select in _icuSelects(nodes)) {
    if (!select.cases.containsKey('other')) {
      error(
        file,
        'select-other',
        '{${select.name}, select} needs an "other" case',
        key: key,
      );
    }
  }
}

/// Scripts written without spaces between words: a fragment joined to a
/// link or placeholder ("、", "に同意") must not carry the template's space.
const Set<String> _spacelessLocales = {'ja', 'zh', 'zh_Hant', 'th'};

bool _spaceless(String code) => _spacelessLocales.contains(code);

void _checkWhitespace(
  String source,
  String value,
  String file,
  String key,
  void Function(String, String, String, {String? key}) error, {
  bool spaceless = false,
}) {
  String leading(String s) => s.substring(0, s.length - s.trimLeft().length);
  String trailing(String s) => s.substring(s.trimRight().length);
  // Spaceless scripts may drop a template space, never add or change one.
  bool same(String a, String b) =>
      a == b ||
      (spaceless && b.isEmpty && a.trim().isEmpty && !a.contains('\n'));
  if (!same(leading(source), leading(value))) {
    error(
      file,
      'whitespace',
      'leading whitespace differs from the template',
      key: key,
    );
  }
  if (!same(trailing(source), trailing(value))) {
    error(
      file,
      'whitespace',
      'trailing whitespace differs from the template',
      key: key,
    );
  }
  if ('\n'.allMatches(source).length != '\n'.allMatches(value).length) {
    error(
      file,
      'whitespace',
      'number of line breaks differs from the template',
      key: key,
    );
  }
  if (source.trimRight().endsWith('…') != value.trimRight().endsWith('…')) {
    error(
      file,
      'whitespace',
      'trailing "…" differs from the template',
      key: key,
    );
  }
}

int run(List<String> args, {IOSink? out, IOSink? err}) {
  final stdoutSink = out ?? stdout;
  final stderrSink = err ?? stderr;
  final ci = args.contains('--ci');
  var root = '.';
  final i = args.indexOf('--root');
  if (i >= 0) {
    if (i + 1 >= args.length) {
      stderrSink.writeln('--root needs a directory');
      return 2;
    }
    root = args[i + 1];
  }
  final unknown = args.where((a) => a != '--ci' && a != '--root' && a != root);
  if (unknown.isNotEmpty) {
    stderrSink.writeln('unknown argument(s): ${unknown.join(' ')}');
    stderrSink.writeln(
      'usage: dart run tool/l10n_check.dart [--ci] [--root <dir>]',
    );
    return 2;
  }

  final result = checkProject(root: root);
  for (final f in result.findings) {
    (f.severity == Severity.error ? stderrSink : stdoutSink).writeln(
      f.format(github: ci),
    );
  }
  stdoutSink.writeln(
    'l10n_check: ${result.errors.length} error(s), ${result.warnings.length} warning(s).',
  );
  return result.errors.isEmpty ? 0 : 1;
}

void main(List<String> args) => exit(run(args));
