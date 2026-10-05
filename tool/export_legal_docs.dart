// Regenerates docs/legal/*.md from the in-app legal documents so the text
// published on the website / store listing is identical to the app.
//
//   dart run tool/export_legal_docs.dart
//
// test/features/settings/legal/legal_documents_test.dart fails when the
// Markdown is out of date.
//
// Only the documents shown in the app are exported (privacy, terms,
// community, notice). The proprietary software licence is maintained by hand
// in the repository (LICENSE, docs/legal/license.md) and is not touched here.
import 'dart:io';

import 'package:valvn/features/settings/legal/legal_documents.dart';

Future<void> main(List<String> args) async {
  if (args.any((arg) => arg != '--check')) {
    throw ArgumentError(
      'Usage: dart run tool/export_legal_docs.dart [--check]',
    );
  }
  final check = args.contains('--check');
  final repository = LegalRepository((path) async {
    final file = File(path);
    return file.existsSync() ? file.readAsString() : null;
  });
  final locales =
      Directory('assets/legal')
          .listSync()
          .whereType<Directory>()
          .map((d) => d.path.split(Platform.pathSeparator).last)
          .toList()
        ..sort();
  for (final locale in locales) {
    for (final document in LegalDocuments.all) {
      if (!File('assets/legal/$locale/${document.id}.json').existsSync()) {
        if (locale == 'vi') {
          throw StateError('Missing authoritative legal document');
        }
        continue;
      }
      final doc = await repository.load(document.id, locale: locale);
      final file = File(LegalDocuments.markdownPath(doc));
      final text = legalDocumentToMarkdown(doc);
      if (check) {
        if (!file.existsSync() ||
            file.readAsStringSync().replaceAll('\r\n', '\n') != text) {
          throw StateError('Legal Markdown is out of date: ${file.path}');
        }
      } else {
        file.parent.createSync(recursive: true);
        file.writeAsStringSync(text);
      }
      stdout.writeln('${check ? 'Verified' : 'Wrote'} ${file.path}');
    }
  }
}
