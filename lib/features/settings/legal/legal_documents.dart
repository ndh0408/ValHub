import 'community_guidelines.dart';
import 'legal_document.dart';
import 'legal_notice.dart';
import 'privacy_policy.dart';
import 'software_license.dart';
import 'terms_of_service.dart';

export 'legal_document.dart';
export 'legal_info.dart';

/// Every legal document of ValVN, in the order shown in the About hub.
abstract final class LegalDocuments {
  static const terms = termsOfService;
  static const privacy = privacyPolicy;
  static const community = communityGuidelines;
  static const license = softwareLicense;
  static const notice = legalNotice;

  static const all = <LegalDocument>[
    terms,
    privacy,
    community,
    license,
    notice,
  ];

  /// Markdown copy of [doc] in the repository (`docs/legal/<id>.md`).
  static String markdownPath(LegalDocument doc) => 'docs/legal/${doc.id}.md';
}
