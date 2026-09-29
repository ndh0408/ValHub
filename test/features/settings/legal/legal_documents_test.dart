import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/settings/legal/legal_documents.dart';

/// Normalizes line endings (Windows checkouts may convert to CRLF).
String _normalize(String s) => s.replaceAll('\r\n', '\n');

List<String> _markdownHeadings(String markdown) => [
  for (final line in markdown.split('\n'))
    if (line.startsWith('## ')) line.substring(3).trim(),
];

void main() {
  group('Markdown copies in docs/legal/ stay in sync with the app', () {
    for (final doc in LegalDocuments.all) {
      test(doc.title, () {
        final file = File(LegalDocuments.markdownPath(doc));
        expect(
          file.existsSync(),
          isTrue,
          reason:
              'Missing ${file.path}: run dart run tool/export_legal_docs.dart',
        );
        final markdown = _normalize(file.readAsStringSync());

        // Same numbered section headings, in the same order.
        expect(_markdownHeadings(markdown), [
          for (var i = 0; i < doc.sections.length; i++)
            numberedHeading(i, doc.sections[i]),
        ]);
        // Same full text.
        expect(
          markdown,
          legalDocumentToMarkdown(doc),
          reason:
              '${file.path} is out of date: run '
              'dart run tool/export_legal_docs.dart',
        );
      });
    }
  });

  group('document metadata', () {
    test('ids are unique slugs; every document is versioned and dated', () {
      final ids = LegalDocuments.all.map((d) => d.id).toList();
      expect(ids.toSet(), hasLength(ids.length));
      for (final doc in LegalDocuments.all) {
        expect(doc.id, matches(RegExp(r'^[a-z]+$')));
        expect(doc.version, isNotEmpty);
        expect(doc.effectiveDate, '29/09/2026');
        expect(doc.sections, isNotEmpty);
        for (final s in doc.sections) {
          expect(s.heading.trim(), isNotEmpty);
          expect(s.blocks, isNotEmpty, reason: s.heading);
        }
      }
    });

    test('contact details come only from LegalInfo (no invented email)', () {
      final emailPattern = RegExp(r'[\w.+-]+@[\w-]+(?:\.[\w-]+)+');
      for (final doc in LegalDocuments.all) {
        final text = legalDocumentToMarkdown(doc);
        final emails = emailPattern.allMatches(text).map((m) => m[0]).toSet();
        expect(
          emails.difference({LegalInfo.contactEmail}),
          isEmpty,
          reason: doc.id,
        );
      }
    });

    test('key commitments are stated', () {
      final privacy = legalDocumentToMarkdown(LegalDocuments.privacy);
      expect(privacy, contains('Nghị định 13/2023/NĐ-CP'));
      expect(privacy, contains('không lưu PUUID'));
      expect(privacy, contains('30 phút'));
      expect(privacy, contains('Cloudflare'));

      final terms = legalDocumentToMarkdown(LegalDocuments.terms);
      expect(
        terms,
        contains('pháp luật nước Cộng hòa xã hội chủ nghĩa Việt Nam'),
      );
    });

    test('the app shows only privacy, terms, community and notice', () {
      // The proprietary licence stays in the repository only (IA "Pháp lý").
      expect(LegalDocuments.all.map((d) => d.id), [
        'privacy',
        'terms',
        'community',
        'notice',
      ]);
      for (final doc in LegalDocuments.all) {
        expect(
          legalDocumentToMarkdown(doc),
          isNot(contains('Giấy phép phần mềm')),
          reason: '${doc.id} must not point to a document the app no longer '
              'shows',
        );
      }
      final terms = legalDocumentToMarkdown(LegalDocuments.terms);
      expect(terms, contains('không phải phần mềm mã nguồn mở'));
      expect(terms, contains(LegalInfo.copyrightNotice));
    });

    test('the licence Markdown is kept in the repository', () {
      final md = _normalize(File('docs/legal/license.md').readAsStringSync());
      expect(md, contains('Giấy phép phần mềm'));
    });

    test('the repository LICENSE is proprietary, not open source', () {
      final license = _normalize(File('LICENSE').readAsStringSync());
      expect(license, contains('All rights reserved.'));
      expect(license, contains('Bảo lưu mọi quyền.'));
      expect(license, contains('NOT open source'));
      expect(license, isNot(contains('Permission is hereby granted')));
    });
  });
}
