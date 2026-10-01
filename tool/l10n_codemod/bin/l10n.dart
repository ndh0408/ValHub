// The i18n codemod (docs/design/I18N.md section 5). Run from the repository
// root after `flutter pub get` (and `dart pub get` in this directory):
//
//   dart run tool/l10n_codemod/bin/l10n.dart <command> [options]
//
// Wave W0 ships the package skeleton and `scan`; the other commands arrive
// with the waves that need them.
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:l10n_codemod/src/project.dart';
import 'package:l10n_codemod/src/scan.dart';
import 'package:l10n_codemod/src/catalog.dart';
import 'package:l10n_codemod/src/verify.dart';
import 'package:l10n_codemod/src/rewrite.dart';

import '../../l10n_fmt.dart' show formatArb;

Future<void> main(List<String> args) async {
  final runner =
      CommandRunner<int>(
          'l10n',
          'Deterministic, re-runnable codemod that migrates ValVN from the '
              '*Strings classes to gen-l10n ARB messages.',
        )
        ..addCommand(ScanCommand())
        ..addCommand(CatalogCommand('extract'))
        ..addCommand(RewriteCommand())
        ..addCommand(VerifyCommand())
        ..addCommand(CatalogCommand('parity'))
        ..addCommand(
          PlannedCommand(
            'rtl',
            'W7',
            'right-to-left codemod (EdgeInsetsDirectional, ...)',
          ),
        );
  try {
    exitCode = await runner.run(args) ?? 0;
  } on UsageException catch (e) {
    stderr.writeln(e);
    exitCode = 64;
  } on ProjectException catch (e) {
    stderr.writeln('error: $e');
    exitCode = 2;
  }
}

class ScanCommand extends Command<int> {
  ScanCommand() {
    argParser
      ..addOption(
        'root',
        help: 'Repository root (default: found from the working directory).',
      )
      ..addOption(
        'sdk',
        help: 'Dart SDK directory (default: the SDK running this tool).',
      )
      ..addMultiOption(
        'only',
        help:
            'Only report files matching this glob (repeatable), e.g. '
            "'lib/features/store/**'.",
      )
      ..addOption(
        'out',
        help: 'Report file (default: tool/l10n_codemod/reports/scan.json).',
      )
      ..addFlag('write', defaultsTo: true, help: 'Write the JSON report.');
  }

  @override
  String get name => 'scan';

  @override
  String get description =>
      'Resolved-AST inventory of the *Strings usage in lib/ and test/ '
      '(read-only). Run at every wave start.';

  @override
  Future<int> run() async {
    final project = Project.discover(
      root: argResults!['root'] as String?,
      sdkPath: argResults!['sdk'] as String?,
    );
    final result = await scan(
      project,
      only: (argResults!['only'] as List<String>),
    );
    stdout.write(result.summary);
    if (argResults!['write'] as bool) {
      final out = argResults!['out'] as String? ?? defaultReportPath(project);
      writeReport(result, out);
      stdout.writeln('report: $out');
    }
    return 0;
  }
}

/// A command of a later wave: known, documented, not implemented yet.
class PlannedCommand extends Command<int> {
  PlannedCommand(this.name, this.wave, this.description);

  @override
  final String name;

  final String wave;

  @override
  final String description;

  @override
  Future<int> run() async {
    stderr.writeln(
      '`$name` is not implemented yet: it arrives with wave $wave '
      '(docs/design/I18N.md 5.1, 13.2). $description.',
    );
    return 2;
  }
}

class CatalogCommand extends Command<int> {
  CatalogCommand(this.name) {
    argParser
      ..addOption('root')
      ..addOption('sdk')
      ..addFlag('check', negatable: false);
  }
  @override
  final String name;
  @override
  String get description => name == 'extract'
      ? 'Extract ARB messages and an explicit structural-work manifest.'
      : 'Generate comparisons between gen-l10n and legacy Vietnamese text.';
  @override
  Future<int> run() async {
    final project = Project.discover(
      root: argResults!['root'] as String?,
      sdkPath: argResults!['sdk'] as String?,
    );
    final catalog = await extractCatalog(project);
    final check = argResults!['check'] as bool;
    var ok = true;
    if (name == 'extract') {
      ok = writeOrCheck(
        '${project.root}/lib/l10n/arb/app_vi.arb',
        formatArb(encodeJson(catalog.arb)),
        check: check,
      );
      ok =
          writeOrCheck(
            '${project.root}/tool/l10n_codemod/manifest.json',
            encodeJson(catalog.manifest),
            check: check,
          ) &&
          ok;
    } else {
      ok = writeOrCheck(
        '${project.root}/test/l10n/vi_parity_test.dart',
        formatDartSource(project, paritySource(catalog)),
        check: check,
      );
    }
    stdout.writeln(
      '${catalog.members.length} members; ${catalog.messages.length} messages; ${catalog.manual.length} structural members remain.',
    );
    return ok ? 0 : 1;
  }
}

class VerifyCommand extends Command<int> {
  VerifyCommand() {
    argParser
      ..addOption('root')
      ..addOption('sdk')
      ..addMultiOption('only')
      ..addFlag(
        'ci',
        negatable: false,
        help: 'Fail unless production references, Vietnamese literals and analyzer errors are all gone.',
      )
      ..addOption('out');
  }
  @override
  String get name => 'verify';
  @override
  String get description =>
      'Report remaining migration work; --ci gates the completed cutover.';
  @override
  Future<int> run() async {
    final project = Project.discover(
      root: argResults!['root'] as String?,
      sdkPath: argResults!['sdk'] as String?,
    );
    final result = await scan(
      project,
      only: argResults!['only'] as List<String>,
    );
    final report = verificationReport(result.json);
    final out =
        argResults!['out'] as String? ?? '${project.reportsDir}/verify.json';
    File(out).parent.createSync(recursive: true);
    File(out).writeAsStringSync(encodeJson(report));
    stdout.writeln(
      '${report['remainingReferences']} production references; '
      '${report['remainingVietnameseLiterals']} Vietnamese literals; '
      'cutover ready: ${report['readyForCutover']}.',
    );
    return (argResults!['ci'] as bool) && report['readyForCutover'] != true
        ? 1
        : 0;
  }
}

class RewriteCommand extends Command<int> {
  RewriteCommand() {
    argParser
      ..addOption('root')
      ..addOption('sdk')
      ..addMultiOption('only')
      ..addFlag('apply', negatable: false)
      ..addOption('out');
  }
  @override
  String get name => 'rewrite';
  @override
  String get description =>
      'Plan resolved view references and const edits; --apply writes the selected files.';
  @override
  Future<int> run() async {
    final project = Project.discover(
      root: argResults!['root'] as String?,
      sdkPath: argResults!['sdk'] as String?,
    );
    final result = await rewrite(
      project,
      await extractCatalog(project),
      only: argResults!['only'] as List<String>,
      apply: argResults!['apply'] as bool,
    );
    final out =
        argResults!['out'] as String? ?? '${project.reportsDir}/rewrite.json';
    File(out).parent.createSync(recursive: true);
    File(out).writeAsStringSync(encodeJson(result));
    stdout.writeln(
      '${result['edits']} edits; ${result['skipped']} references require structural work; applied: ${result['applied']}.',
    );
    return 0;
  }
}
