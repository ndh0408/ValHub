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

Future<void> main(List<String> args) async {
  final runner =
      CommandRunner<int>(
          'l10n',
          'Deterministic, re-runnable codemod that migrates ValVN from the '
              '*Strings classes to gen-l10n ARB messages.',
        )
        ..addCommand(ScanCommand())
        ..addCommand(
          PlannedCommand(
            'extract',
            'W1',
            'build app_vi.arb, manifest.json and reports from the *Strings classes',
          ),
        )
        ..addCommand(
          PlannedCommand(
            'rewrite',
            'W2',
            'rewrite references to context.l10n.<key> (rules R1-R9)',
          ),
        )
        ..addCommand(
          PlannedCommand(
            'verify',
            'W2',
            'report the *Strings references that remain (--ci after W4)',
          ),
        )
        ..addCommand(
          PlannedCommand(
            'parity',
            'W1',
            'generate test/l10n/vi_parity_test.dart',
          ),
        )
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
