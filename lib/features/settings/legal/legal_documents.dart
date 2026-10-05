import 'legal_document.dart';

export 'legal_document.dart';
export 'legal_info.dart';
export 'legal_repository.dart';

/// Stable route/document identities. Text lives in locale assets, not models.
enum LegalDocumentRef {
  privacy,
  terms,
  community,
  notice;

  String get id => name;
}

/// Every legal document shown in the app, in the order of the "Giới thiệu
/// & pháp lý" hub (docs/design/IA.md "Pháp lý").
///
/// The proprietary software licence is not an in-app document: it lives in
/// the repository (`LICENSE`, `docs/legal/license.md`); the app shows the
/// copyright line at the bottom of the hub instead.
abstract final class LegalDocuments {
  static const privacy = LegalDocumentRef.privacy;
  static const terms = LegalDocumentRef.terms;
  static const community = LegalDocumentRef.community;
  static const notice = LegalDocumentRef.notice;

  static const all = LegalDocumentRef.values;

  /// Markdown copy of [doc] in the repository (`docs/legal/<id>.md`).
  static String markdownPath(LegalDocument doc) => doc.locale == 'vi'
      ? 'docs/legal/${doc.id}.md'
      : 'docs/legal/${doc.locale}/${doc.id}.md';
}
