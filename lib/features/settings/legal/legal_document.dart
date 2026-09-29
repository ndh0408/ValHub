/// Structured legal documents (Terms, Privacy Policy, …) rendered natively by
/// `LegalDocumentScreen` and exported verbatim to Markdown (`docs/legal/`).
///
/// Pure Dart (no Flutter import) so `tool/export_legal_docs.dart` can run it.
library;

import 'legal_info.dart';

/// One legal document. Sections are numbered when rendered ("1. …").
class LegalDocument {
  const LegalDocument({
    required this.id,
    required this.title,
    required this.summary,
    required this.version,
    required this.sections,
    this.effectiveDate = LegalInfo.effectiveDate,
    this.preamble = const [],
  });

  /// URL slug and Markdown file stem, e.g. `terms`.
  final String id;

  /// "Điều khoản sử dụng".
  final String title;

  /// One-line description (About hub row subtitle).
  final String summary;

  /// "1.0".
  final String version;

  /// "29/09/2026".
  final String effectiveDate;

  /// Unnumbered text shown before the table of contents.
  final List<LegalBlock> preamble;

  final List<LegalSection> sections;
}

/// A numbered section: heading (without the number) and its content.
class LegalSection {
  const LegalSection(this.heading, this.blocks);

  final String heading;
  final List<LegalBlock> blocks;
}

/// Content block of a section.
sealed class LegalBlock {
  const LegalBlock();
}

/// A plain paragraph.
final class LegalParagraph extends LegalBlock {
  const LegalParagraph(this.text);

  final String text;
}

/// An unnumbered sub-heading inside a section.
final class LegalSubheading extends LegalBlock {
  const LegalSubheading(this.text);

  final String text;
}

/// A bulleted list.
final class LegalList extends LegalBlock {
  const LegalList(this.items);

  final List<LegalItem> items;
}

/// A highlighted note ("Tóm tắt", important warnings).
final class LegalCallout extends LegalBlock {
  const LegalCallout(this.text);

  final String text;
}

/// One bullet; [lead] (optional) is rendered in bold before [text].
class LegalItem {
  const LegalItem(this.text, {this.lead});

  final String? lead;
  final String text;
}

/// Heading as displayed and exported: "3. Điều kiện sử dụng".
String numberedHeading(int index, LegalSection section) =>
    '${index + 1}. ${section.heading}';

/// "Phiên bản 1.0 · Hiệu lực từ: 29/09/2026".
String legalMetaLine(LegalDocument doc) =>
    'Phiên bản ${doc.version} · Hiệu lực từ: ${doc.effectiveDate}';

/// Markdown export of [doc] (`docs/legal/<id>.md`). The in-app text and the
/// published text are therefore always identical.
String legalDocumentToMarkdown(LegalDocument doc) {
  final out = StringBuffer()
    ..writeln(
      '<!-- Tệp tạo tự động từ lib/features/settings/legal/. Không sửa tay: '
      'sửa nội dung Dart rồi chạy `dart run tool/export_legal_docs.dart`. -->',
    )
    ..writeln()
    ..writeln('# ${doc.title}')
    ..writeln()
    ..writeln('**${LegalInfo.productName}** · ${legalMetaLine(doc)}')
    ..writeln();
  void writeBlocks(List<LegalBlock> blocks) {
    for (final block in blocks) {
      switch (block) {
        case LegalParagraph(:final text):
          out
            ..writeln(text)
            ..writeln();
        case LegalSubheading(:final text):
          out
            ..writeln('### $text')
            ..writeln();
        case LegalCallout(:final text):
          out
            ..writeln('> $text')
            ..writeln();
        case LegalList(:final items):
          for (final item in items) {
            out.writeln(
              item.lead == null
                  ? '- ${item.text}'
                  : '- **${item.lead}** ${item.text}',
            );
          }
          out.writeln();
      }
    }
  }

  writeBlocks(doc.preamble);
  for (var i = 0; i < doc.sections.length; i++) {
    out
      ..writeln('## ${numberedHeading(i, doc.sections[i])}')
      ..writeln();
    writeBlocks(doc.sections[i].blocks);
  }
  out
    ..writeln('---')
    ..writeln()
    ..writeln(LegalInfo.copyrightNotice);
  return out.toString();
}
