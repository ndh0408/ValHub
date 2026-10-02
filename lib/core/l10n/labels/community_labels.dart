import '../l10n.dart';

/// Unknown moderation codes use the ordinary error fallback.
extension CommunityLabels on AppLocalizations {
  String? communityModerationReason(String? reason) => switch (reason) {
    'content_inappropriate' => communityModerationContentInappropriate,
    'content_scam' => communityModerationContentScam,
    'content_too_complex' => communityModerationContentTooComplex,
    'account_banned' => communityModerationAccountBanned,
    'account_restricted' => communityModerationAccountRestricted,
    _ => null,
  };
  String communityLanguageName(String code) => switch (code) {
    'ar' => communityLanguageNamesAr,
    'de' => communityLanguageNamesDe,
    'en' => communityLanguageNamesEn,
    'es' => communityLanguageNamesEs,
    'fr' => communityLanguageNamesFr,
    'id' => communityLanguageNamesId,
    'it' => communityLanguageNamesIt,
    'ja' => communityLanguageNamesJa,
    'ko' => communityLanguageNamesKo,
    'pl' => communityLanguageNamesPl,
    'pt' => communityLanguageNamesPt,
    'ru' => communityLanguageNamesRu,
    'th' => communityLanguageNamesTh,
    'tr' => communityLanguageNamesTr,
    'vi' => communityLanguageNamesVi,
    'zh-CN' => communityLanguageNamesZhCN,
    'zh-TW' => communityLanguageNamesZhTW,
    _ => communityAnyLanguage,
  };
}
