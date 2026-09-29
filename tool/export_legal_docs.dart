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

void main() {
  for (final doc in LegalDocuments.all) {
    final file = File(LegalDocuments.markdownPath(doc));
    file.parent.createSync(recursive: true);
    file.writeAsStringSync(legalDocumentToMarkdown(doc));
    stdout.writeln('Đã ghi ${file.path}');
  }
}
