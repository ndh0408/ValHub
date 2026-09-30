// Canonical formatting of the ARB files (docs/design/I18N.md 4.1, 5.6).
//
//   dart run tool/l10n_fmt.dart            rewrite lib/l10n/arb/*.arb
//   dart run tool/l10n_fmt.dart --check    exit 1 when any file is not canonical
//   dart run tool/l10n_fmt.dart --dir <d>  another directory (tests)
//
// Idempotent and dependency-free (dart:io / dart:convert only), so agents
// working in parallel produce byte-identical files and git merges stay clean:
//
// - `@@locale` first, then the other `@@` keys in their original order;
// - every message is immediately followed by its `@key` metadata; metadata of
//   a message that does not exist is kept at the end (l10n_check reports it);
// - the TEMPLATE (app_vi.arb) is grouped by key namespace ([kKeyPrefixOrder]),
//   keeping the existing order inside a group (the extraction order), so an
//   agent's additions stay where they were put; every other locale follows
//   the template's key order, unknown keys last;
// - metadata: `description`, `placeholders`, then the remaining keys sorted
//   (`x-context`, `x-example`, ...); the ORDER OF PLACEHOLDERS is never
//   touched (gen-l10n emits positional arguments in that order), only the
//   attributes inside one placeholder are sorted;
// - two-space JSON, `\n` line endings, one trailing newline.
import 'dart:convert';
import 'dart:io';

/// Key namespaces in their canonical order: `<prefix><Name>` in lowerCamelCase
/// (`battlePassLevelOf`). The first 19 are fixed by the design; `home` was
/// added with the Home tab (`HomeStrings`, which appeared after the design's
/// measurement) and is appended so the others keep their order.
const List<String> kKeyPrefixOrder = [
  'common',
  'content',
  'account',
  'auth',
  'notification',
  'competitive',
  'economy',
  'loadout',
  'battlePass',
  'collection',
  'community',
  'liveGame',
  'profile',
  'legal',
  'settings',
  'skinDetail',
  'social',
  'store',
  'wishlist',
  'home',
];

/// The template locale's file.
const String kTemplateFile = 'app_vi.arb';

/// Index of [key]'s namespace in [kKeyPrefixOrder]; keys of an unknown
/// namespace sort after every known one.
///
/// The prefix must be followed by an upper-case letter (`communityX` is not
/// in `common`), and the longest match wins.
int prefixIndex(String key) {
  var best = -1;
  var bestLength = -1;
  for (var i = 0; i < kKeyPrefixOrder.length; i++) {
    final p = kKeyPrefixOrder[i];
    if (key.length > p.length && key.startsWith(p)) {
      final next = key.codeUnitAt(p.length);
      final upper = next >= 0x41 && next <= 0x5a;
      if (upper && p.length > bestLength) {
        best = i;
        bestLength = p.length;
      }
    }
  }
  return best < 0 ? kKeyPrefixOrder.length : best;
}

/// The message keys of [source] in file order (no `@` keys). Used to give the
/// other locales the template's order.
List<String> messageKeys(String source) {
  final decoded = _decodeObject(source);
  return [
    for (final k in decoded.keys)
      if (!k.startsWith('@')) k,
  ];
}

/// The canonical text of the ARB [source].
///
/// [templateKeyOrder] is null for the template itself (grouped by namespace)
/// and the template's [messageKeys] for every other locale.
///
/// Throws [FormatException] when [source] is not a JSON object.
String formatArb(String source, {List<String>? templateKeyOrder}) {
  final decoded = _decodeObject(source);
  final globals = <String, Object?>{};
  final messages = <String, Object?>{};
  final metadata = <String, Object?>{};
  for (final e in decoded.entries) {
    if (e.key.startsWith('@@')) {
      globals[e.key] = e.value;
    } else if (e.key.startsWith('@')) {
      metadata[e.key.substring(1)] = e.value;
    } else {
      messages[e.key] = e.value;
    }
  }

  final Map<String, int> rank;
  if (templateKeyOrder == null) {
    rank = {for (final k in messages.keys) k: prefixIndex(k)};
  } else {
    final index = {
      for (var i = 0; i < templateKeyOrder.length; i++) templateKeyOrder[i]: i,
    };
    rank = {
      for (final k in messages.keys) k: index[k] ?? templateKeyOrder.length,
    };
  }
  // Decorate-sort-undecorate: List.sort is not guaranteed stable.
  final original = messages.keys.toList();
  final ordered = [for (var i = 0; i < original.length; i++) (i, original[i])]
    ..sort((a, b) {
      final byRank = rank[a.$2]!.compareTo(rank[b.$2]!);
      return byRank != 0 ? byRank : a.$1.compareTo(b.$1);
    });

  final out = <String, Object?>{};
  if (globals.containsKey('@@locale')) out['@@locale'] = globals['@@locale'];
  for (final e in globals.entries) {
    if (e.key != '@@locale') out[e.key] = e.value;
  }
  for (final (_, key) in ordered) {
    out[key] = messages[key];
    if (metadata.containsKey(key)) {
      out['@$key'] = _canonicalMetadata(metadata[key]);
    }
  }
  for (final e in metadata.entries) {
    if (!messages.containsKey(e.key)) {
      out['@${e.key}'] = _canonicalMetadata(e.value);
    }
  }
  return '${const JsonEncoder.withIndent('  ').convert(out)}\n';
}

Map<String, Object?> _decodeObject(String source) {
  final Object? decoded;
  try {
    decoded = jsonDecode(source);
  } on FormatException catch (e) {
    throw FormatException('not valid JSON: ${e.message}');
  }
  if (decoded is! Map<String, Object?>) {
    throw const FormatException('an ARB file must be a JSON object');
  }
  return decoded;
}

Object? _canonicalMetadata(Object? value) {
  if (value is! Map<String, Object?>) return value;
  final out = <String, Object?>{};
  if (value.containsKey('description')) {
    out['description'] = value['description'];
  }
  if (value.containsKey('placeholders')) {
    out['placeholders'] = _canonicalPlaceholders(value['placeholders']);
  }
  final rest =
      value.keys
          .where((k) => k != 'description' && k != 'placeholders')
          .toList()
        ..sort();
  for (final k in rest) {
    out[k] = value[k];
  }
  return out;
}

/// Placeholders keep their ORDER (positional arguments); the attributes of
/// each are sorted.
Object? _canonicalPlaceholders(Object? value) {
  if (value is! Map<String, Object?>) return value;
  return {
    for (final e in value.entries)
      e.key: e.value is Map<String, Object?>
          ? {
              for (final k
                  in (e.value! as Map<String, Object?>).keys.toList()..sort())
                k: (e.value! as Map<String, Object?>)[k],
            }
          : e.value,
  };
}

/// Result of [formatDirectory].
class FormatReport {
  FormatReport(this.changed, this.errors);

  /// Files that were (or, with `write: false`, would be) rewritten.
  final List<String> changed;

  /// `file: problem` lines for files that could not be read or parsed.
  final List<String> errors;
}

/// Formats every `app_*.arb` in [dir]; with [write] false only reports.
FormatReport formatDirectory(String dir, {required bool write}) {
  final changed = <String>[];
  final errors = <String>[];
  final directory = Directory(dir);
  if (!directory.existsSync()) {
    return FormatReport(changed, ['$dir: directory not found']);
  }
  final files =
      directory
          .listSync()
          .whereType<File>()
          .where(
            (f) => _name(f).startsWith('app_') && _name(f).endsWith('.arb'),
          )
          .toList()
        ..sort((a, b) => _name(a).compareTo(_name(b)));

  List<String>? templateOrder;
  final template = files.where((f) => _name(f) == kTemplateFile).firstOrNull;
  if (template != null) {
    try {
      // The other locales follow the template's CANONICAL order.
      templateOrder = messageKeys(formatArb(_read(template)));
    } on FormatException {
      // Reported once, by the loop below; the others keep their own order.
    }
  }

  for (final file in files) {
    final name = _name(file);
    final source = _read(file);
    try {
      final canonical = formatArb(
        source,
        templateKeyOrder: name == kTemplateFile ? null : templateOrder,
      );
      if (canonical != source) {
        changed.add(name);
        if (write) file.writeAsStringSync(canonical);
      }
    } on FormatException catch (e) {
      errors.add('$name: ${e.message}');
    }
  }
  return FormatReport(changed, errors);
}

String _name(File f) => f.uri.pathSegments.last;

/// Line endings are normalised so a CRLF working copy (Windows autocrlf) is
/// judged by its content, as git will store it.
String _read(File f) => f.readAsStringSync().replaceAll('\r\n', '\n');

int run(List<String> args, {IOSink? out, IOSink? err}) {
  final stdoutSink = out ?? stdout;
  final stderrSink = err ?? stderr;
  final check = args.contains('--check');
  var dir = 'lib/l10n/arb';
  final i = args.indexOf('--dir');
  if (i >= 0) {
    if (i + 1 >= args.length) {
      stderrSink.writeln('--dir needs a directory');
      return 2;
    }
    dir = args[i + 1];
  }
  final unknown = args.where((a) => a != '--check' && a != '--dir' && a != dir);
  if (unknown.isNotEmpty) {
    stderrSink.writeln('unknown argument(s): ${unknown.join(' ')}');
    stderrSink.writeln(
      'usage: dart run tool/l10n_fmt.dart [--check] [--dir <dir>]',
    );
    return 2;
  }

  final report = formatDirectory(dir, write: !check);
  for (final e in report.errors) {
    stderrSink.writeln('error: $e');
  }
  if (report.errors.isNotEmpty) return 2;
  if (report.changed.isEmpty) {
    stdoutSink.writeln('ARB files in $dir are canonical.');
    return 0;
  }
  if (check) {
    stderrSink.writeln(
      'Not canonical (run `dart run tool/l10n_fmt.dart`): '
      '${report.changed.join(', ')}',
    );
    return 1;
  }
  stdoutSink.writeln('Formatted: ${report.changed.join(', ')}');
  return 0;
}

void main(List<String> args) => exit(run(args));
