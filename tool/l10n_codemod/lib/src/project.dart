/// The repository being migrated: where it is, which Dart SDK resolves it, and
/// a few path helpers shared by every command.
library;

import 'dart:io';

import 'package:path/path.dart' as p;

class ProjectException implements Exception {
  ProjectException(this.message);
  final String message;

  @override
  String toString() => message;
}

class Project {
  Project._(this.root, this.sdkPath);

  /// Absolute path of the repository root (the `valvn` package).
  final String root;

  /// Dart SDK the analyzer resolves `dart:` libraries from.
  final String sdkPath;

  /// [root] defaults to the nearest parent of the working directory that holds
  /// the `valvn` pubspec. [sdkPath] defaults to the SDK running this tool (the
  /// one `dart run` selected, i.e. Flutter's).
  static Project discover({String? root, String? sdkPath}) {
    final start = p.normalize(p.absolute(root ?? p.current));
    final found = _findRoot(start);
    if (found == null) {
      throw ProjectException(
        'no ValVN checkout found from $start (a parent directory must hold '
        'pubspec.yaml with `name: valvn`); pass --root',
      );
    }
    final sdk = sdkPath ?? p.dirname(p.dirname(Platform.resolvedExecutable));
    if (!File(p.join(sdk, 'lib', 'core', 'core.dart')).existsSync()) {
      throw ProjectException(
        'not a Dart SDK: $sdk (pass --sdk <dart-sdk directory>)',
      );
    }
    final project = Project._(found, sdk);
    if (!project.hasPackageConfig) {
      throw ProjectException(
        'run `flutter pub get` in $found first: the analyzer resolves '
        'package: imports through .dart_tool/package_config.json',
      );
    }
    return project;
  }

  static String? _findRoot(String start) {
    var dir = start;
    while (true) {
      final pubspec = File(p.join(dir, 'pubspec.yaml'));
      if (pubspec.existsSync() &&
          RegExp(
            r'^name:\s*valvn\s*$',
            multiLine: true,
          ).hasMatch(pubspec.readAsStringSync())) {
        return dir;
      }
      final parent = p.dirname(dir);
      if (parent == dir) return null;
      dir = parent;
    }
  }

  bool get hasPackageConfig =>
      File(p.join(root, '.dart_tool', 'package_config.json')).existsSync();

  String get libDir => p.join(root, 'lib');
  String get testDir => p.join(root, 'test');
  String get reportsDir => p.join(root, 'tool', 'l10n_codemod', 'reports');

  /// [path] relative to [root], with forward slashes (stable across OSes).
  String rel(String path) => p.relative(path, from: root).replaceAll(r'\', '/');

  /// `git rev-parse HEAD` of the checkout, or `null` without git.
  String? gitSha() {
    try {
      final r = Process.runSync('git', [
        'rev-parse',
        'HEAD',
      ], workingDirectory: root);
      final sha = (r.stdout as String).trim();
      return r.exitCode == 0 && sha.isNotEmpty ? sha : null;
    } on ProcessException {
      return null;
    }
  }
}

/// A path glob over repository-relative paths: `**` crosses directories, `*`
/// and `?` do not (`lib/features/store/**`, `test/**/*_test.dart`).
class Glob {
  Glob(this.pattern) : _regex = _compile(pattern);

  final String pattern;
  final RegExp _regex;

  bool matches(String relPath) => _regex.hasMatch(relPath);

  static RegExp _compile(String pattern) {
    final b = StringBuffer('^');
    for (var i = 0; i < pattern.length; i++) {
      final c = pattern[i];
      if (c == '*') {
        if (i + 1 < pattern.length && pattern[i + 1] == '*') {
          i++;
          if (i + 1 < pattern.length && pattern[i + 1] == '/') {
            // `**/` is any number of directories, including none.
            b.write('(?:.*/)?');
            i++;
          } else {
            b.write('.*');
          }
        } else {
          b.write('[^/]*');
        }
      } else if (c == '?') {
        b.write('[^/]');
      } else {
        b.write(RegExp.escape(c));
      }
    }
    b.write(r'$');
    return RegExp(b.toString());
  }
}

/// True when [relPath] matches any of [globs] (all paths match when empty).
bool matchesAny(List<Glob> globs, String relPath) =>
    globs.isEmpty || globs.any((g) => g.matches(relPath));
