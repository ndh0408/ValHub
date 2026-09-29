import 'community_guidelines.dart';
import 'legal_document.dart';
import 'legal_notice.dart';
import 'privacy_policy.dart';
import 'terms_of_service.dart';

export 'legal_document.dart';
export 'legal_info.dart';

/// Every legal document shown in the app, in the order of the "Giới thiệu
/// & pháp lý" hub (docs/design/IA.md "Pháp lý").
///
/// The proprietary software licence is not an in-app document: it lives in
/// the repository (`LICENSE`, `docs/legal/license.md`); the app shows the
/// copyright line at the bottom of the hub instead.
abstract final class LegalDocuments {
  static const privacy = privacyPolicy;
  static const terms = termsOfService;
  static const community = communityGuidelines;
  static const notice = legalNotice;

  static const all = <LegalDocument>[privacy, terms, community, notice];

  /// Markdown copy of [doc] in the repository (`docs/legal/<id>.md`).
  static String markdownPath(LegalDocument doc) => 'docs/legal/${doc.id}.md';
}
