/// Structured legal assets rendered natively and exported verbatim to Markdown.
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
    required this.locale,
    required this.copyright,
    required this.exportHeader,
    required this.exportMetadata,
    this.effectiveDate = LegalInfo.effectiveDate,
    this.preamble = const [],
  });

  /// URL slug and Markdown file stem, e.g. `terms`.
  final String id;
  final String locale;
  final String copyright;
  final String exportHeader;
  final String exportMetadata;

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

  factory LegalDocument.fromJson(Object? json) {
    Map<String, dynamic> map(Object? value) {
      if (value is! Map<String, dynamic>) {
        throw const FormatException('Expected legal object');
      }
      return value;
    }

    String text(Object? value) {
      if (value is! String || value.trim().isEmpty) {
        throw const FormatException('Expected non-empty legal text');
      }
      return value;
    }

    List<T> list<T>(Object? value, T Function(Object?) parse) {
      if (value is! List || value.length > 512) {
        throw const FormatException('Expected bounded legal list');
      }
      return List.unmodifiable(value.map(parse));
    }

    LegalBlock block(Object? value) {
      final b = map(value);
      return switch (b['type']) {
        'p' => LegalParagraph(text(b['text'])),
        'sub' => LegalSubheading(text(b['text'])),
        'callout' => LegalCallout(text(b['text'])),
        'list' => LegalList(
          list(b['items'], (value) {
            final item = map(value);
            return LegalItem(
              text(item['text']),
              lead: item['lead'] == null ? null : text(item['lead']),
            );
          }),
        ),
        _ => throw const FormatException('Unknown legal block'),
      };
    }

    final d = map(json);
    if (d['schema'] != 1) throw const FormatException('Unknown legal schema');
    final export = map(d['export']);
    final sections = list(d['sections'], (value) {
      final section = map(value);
      final blocks = list(section['blocks'], block);
      if (blocks.isEmpty) throw const FormatException('Empty legal section');
      return LegalSection(text(section['heading']), blocks);
    });
    if (sections.isEmpty) throw const FormatException('Empty legal document');
    return LegalDocument(
      id: text(d['id']),
      locale: text(d['locale']),
      title: text(d['title']),
      summary: text(d['summary']),
      version: text(d['version']),
      effectiveDate: text(d['effectiveDate']),
      copyright: text(d['copyright']),
      exportHeader: text(export['header']),
      exportMetadata: text(export['metadata']),
      preamble: list(d['preamble'], block),
      sections: sections,
    );
  }

  /// Check version and block/list counts; semantic/legal review is separate.
  bool hasSameStructureAs(LegalDocument source) {
    bool sameBlocks(List<LegalBlock> a, List<LegalBlock> b) {
      if (a.length != b.length) return false;
      for (var i = 0; i < a.length; i++) {
        if (a[i].runtimeType != b[i].runtimeType) return false;
        if (a[i] case LegalList(:final items)) {
          final other = (b[i] as LegalList).items;
          if (items.length != other.length) return false;
          for (var j = 0; j < items.length; j++) {
            if ((items[j].lead == null) != (other[j].lead == null)) {
              return false;
            }
          }
        }
      }
      return true;
    }

    return id == source.id &&
        version == source.version &&
        effectiveDate == source.effectiveDate &&
        sections.length == source.sections.length &&
        sameBlocks(preamble, source.preamble) &&
        List.generate(
          sections.length,
          (i) => sameBlocks(sections[i].blocks, source.sections[i].blocks),
        ).every((same) => same);
  }
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

/// Markdown export of [doc] (`docs/legal/<id>.md`). The in-app text and the
/// published text are therefore always identical.
String legalDocumentToMarkdown(LegalDocument doc) {
  final out = StringBuffer()
    ..writeln(doc.exportHeader)
    ..writeln()
    ..writeln('# ${doc.title}')
    ..writeln()
    ..writeln(doc.exportMetadata)
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
    ..writeln(doc.copyright);
  return out.toString();
}
