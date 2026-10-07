// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => '가격표 출처 보기';

  @override
  String get commonErrorApi => 'Riot 서비스에 문제가 있습니다. 잠시 후 다시 시도하세요.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => '취소';

  @override
  String get commonClearFilters => '필터 해제';

  @override
  String get commonClearSearch => '검색어 지우기';

  @override
  String get commonClose => '닫기';

  @override
  String get commonCopied => '복사됨';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    return '$n일';
  }

  @override
  String commonDaysAgo(int n) {
    return '$n일 전';
  }

  @override
  String get commonDelete => '삭제';

  @override
  String get commonEmptyGeneric => '아직 아무것도 없습니다.';

  @override
  String get commonErrorContentUnavailable =>
      '스킨, 요원, 맵 정보를 불러오지 못했습니다. 네트워크를 확인하고 다시 시도하세요.';

  @override
  String get commonErrorGeneric => '문제가 발생했습니다. 다시 시도하세요.';

  @override
  String get commonErrorMaintenance => 'VALORANT 서버 점검 중입니다. 나중에 다시 확인하세요.';

  @override
  String get commonErrorNeedsLogin => 'Riot 로그인이 만료되었습니다. 계속하려면 다시 로그인하세요.';

  @override
  String get commonErrorNeedsLoginTitle => '다시 로그인 필요';

  @override
  String get commonErrorNetwork =>
      '네트워크에 연결할 수 없습니다. Wi-Fi 또는 모바일 데이터를 확인하고 다시 시도하세요.';

  @override
  String get commonErrorNoAccount => '로그인한 계정이 없습니다.';

  @override
  String get commonErrorNotFound => '이 콘텐츠를 찾을 수 없습니다.';

  @override
  String get commonErrorTimeout => 'Riot 응답이 너무 늦습니다. 연결을 확인하고 다시 시도하세요.';

  @override
  String get commonErrorTransient => 'Riot 서비스가 혼잡합니다. 잠시 후 다시 시도하세요.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot 서비스가 혼잡합니다. $duration 후 다시 시도하세요.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Riot 지역을 확인할 수 없습니다. 설정에서 지역을 선택하세요.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => '홈으로';

  @override
  String commonHours(int n) {
    return '$n시간';
  }

  @override
  String commonHoursAgo(int n) {
    return '$n시간 전';
  }

  @override
  String get commonIncidentTitle => '서버 장애';

  @override
  String get commonJustNow => '방금';

  @override
  String get commonLoadMore => '더 보기';

  @override
  String get commonLoading => '불러오는 중…';

  @override
  String get commonMaintenanceTitle => '서버 점검';

  @override
  String commonMinutes(int n) {
    return '$n분';
  }

  @override
  String commonMinutesAgo(int n) {
    return '$n분 전';
  }

  @override
  String get commonNoData => '아직 표시할 내용이 없습니다';

  @override
  String commonOfflineCached(String time) {
    return '오프라인 상태입니다 — 저장된 데이터를 표시합니다($time).';
  }

  @override
  String get commonOpenSettings => '설정 열기';

  @override
  String get commonPageNotFound => '이 화면을 찾을 수 없습니다.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return '가장 유리한 패키지: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => '입력한 가격 수정';

  @override
  String get commonPriceEnterOwn => 'VP 패키지 가격 입력';

  @override
  String get commonPriceEstimateBody =>
      'VP 가격 옆의 “≈ …” 금액은 가장 유리한 VP 패키지 기준으로 환산한 예상 금액입니다. 게임에서는 VP로 결제하며, 실제 금액은 구매 시점의 패키지, 결제 수단, 세금, 프로모션에 따라 달라집니다.';

  @override
  String get commonPriceEstimateTitle => '예상 환산 가격';

  @override
  String get commonPriceEstimateTooltip => '예상 가격 — 탭하여 계산 방법 보기';

  @override
  String get commonPriceHidden => '환산 가격을 숨겼습니다. 설정에서 다시 켤 수 있습니다.';

  @override
  String get commonPriceHide => '환산 가격 숨기기';

  @override
  String get commonPriceOpenSource => '출처 페이지 열기';

  @override
  String get commonPriceOverrideBody =>
      'VP 패키지 하나에 실제로 지불한 금액을 입력하세요(게임 내 상점이나 영수증에서 확인). ValHub는 이 가격으로 모든 아이템의 환산 가격을 계산하며, 가격은 이 기기에만 저장됩니다.';

  @override
  String get commonPriceOverrideCurrency => '통화 코드';

  @override
  String get commonPriceOverrideCurrencyHint => '예: KRW, USD, EUR, JPY';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return '예상 예시: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      '3자리 통화 코드를 입력하세요. 예: KRW 또는 USD.';

  @override
  String get commonPriceOverrideInvalidNumber => '0보다 큰 숫자를 입력하세요.';

  @override
  String get commonPriceOverridePrice => '패키지 가격';

  @override
  String get commonPriceOverrideRemove => '입력한 가격 삭제';

  @override
  String get commonPriceOverrideRemoved => '입력한 가격을 삭제했습니다.';

  @override
  String get commonPriceOverrideSave => '가격 저장';

  @override
  String get commonPriceOverrideSaved => 'VP 패키지 가격을 저장했습니다.';

  @override
  String get commonPriceOverrideTitle => '내 VP 패키지 가격';

  @override
  String get commonPriceOverrideVp => '패키지 VP 수량';

  @override
  String get commonPricePacksTitle => 'VP 패키지';

  @override
  String commonPriceSourceOfficial(String country) {
    return '$country 지역 VP 패키지 가격 기준';
  }

  @override
  String get commonPriceSourceUser => '입력한 VP 패키지 가격 기준';

  @override
  String get commonPriceUnavailable =>
      '아직 내 지역의 확인된 가격표가 없습니다. 구매한 적 있는 VP 패키지 가격을 입력하면 예상 환산 가격을 볼 수 있습니다.';

  @override
  String commonPriceUpdated(String date) {
    return '가격표 업데이트: $date';
  }

  @override
  String get commonRetry => '다시 시도';

  @override
  String get commonRiotDisclaimer =>
      'ValHub는 Riot Games의 보증을 받지 않았으며, Riot Games 또는 Riot Games 자산의 제작이나 관리에 공식적으로 관여하는 누구의 견해나 의견도 반영하지 않습니다. Riot Games 및 모든 관련 자산은 Riot Games, Inc.의 상표 또는 등록 상표입니다.';

  @override
  String get commonSave => '저장';

  @override
  String get commonSearch => '검색…';

  @override
  String commonSeconds(int n) {
    return '$n초';
  }

  @override
  String get commonShare => '공유';

  @override
  String get commonSignInAgain => '다시 로그인';

  @override
  String get commonSort => '정렬';

  @override
  String commonSortBy(String option) {
    return '정렬: $option';
  }

  @override
  String get commonTabBattlePass => 'Battle Pass';

  @override
  String get commonTabCollection => '수집품';

  @override
  String get commonTabCommunity => '커뮤니티';

  @override
  String get commonTabHome => '홈';

  @override
  String get commonTabProfile => '프로필';

  @override
  String get commonTabSettings => '설정';

  @override
  String get commonTabStore => '상점';

  @override
  String get commonTagline => '나만의 VALORANT 도우미';

  @override
  String get commonToday => '오늘';

  @override
  String get commonTodayLower => '오늘';

  @override
  String get commonTomorrow => '내일';

  @override
  String get commonUnknownItem => '알 수 없는 아이템';

  @override
  String commonUpdatedAt(String time) {
    return '$time 업데이트';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$day $time';
  }

  @override
  String get commonWeekdaysItem0 => '월요일';

  @override
  String get commonWeekdaysItem1 => '화요일';

  @override
  String get commonWeekdaysItem2 => '수요일';

  @override
  String get commonWeekdaysItem3 => '목요일';

  @override
  String get commonWeekdaysItem4 => '금요일';

  @override
  String get commonWeekdaysItem5 => '토요일';

  @override
  String get commonWeekdaysItem6 => '일요일';

  @override
  String get commonYesterday => '어제';

  @override
  String get commonYesterdayTitle => '어제';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'Riot 로그인이 만료되었습니다 — 저장된 데이터를 표시합니다($time).';
  }

  @override
  String get contentCategoryHeavy => '중화기';

  @override
  String get contentCategoryMelee => '근접 무기';

  @override
  String get contentCategoryRifle => '돌격소총';

  @override
  String get contentCategoryShotgun => '산탄총';

  @override
  String get contentCategorySidearm => '보조 무기';

  @override
  String get contentCategorySmg => '기관단총';

  @override
  String get contentCategorySniper => '저격소총';

  @override
  String get contentCurrencyAgentTokens => '요원 토큰';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => '킹덤 크레딧';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => '레디어나이트';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => '발로란트 포인트';

  @override
  String get contentItemAgent => '요원';

  @override
  String get contentItemBuddy => '총기 장식';

  @override
  String get contentItemCard => '플레이어 카드';

  @override
  String get contentItemChroma => '색상 변형';

  @override
  String get contentItemContract => '계약';

  @override
  String get contentItemCurrency => '화폐';

  @override
  String get contentItemFlex => '플렉스';

  @override
  String get contentItemSkin => '스킨';

  @override
  String get contentItemSpray => '스프레이';

  @override
  String get contentItemTitle => '칭호';

  @override
  String contentLevel(int n) {
    return '레벨 $n';
  }

  @override
  String get contentLevelBase => '기본';

  @override
  String get contentLevelItemLabelsVFX => '시각 효과';

  @override
  String get contentLevelItemLabelsAnimation => '애니메이션';

  @override
  String get contentLevelItemLabelsFinisher => '마무리 효과';

  @override
  String get contentLevelItemLabelsKillCounter => '처치 카운터';

  @override
  String get contentLevelItemLabelsSoundEffects => '음향 효과';

  @override
  String get contentLevelItemLabelsTransformation => '변신';

  @override
  String get contentLevelItemLabelsKillBanner => '처치 배너';

  @override
  String get contentLevelItemLabelsKillEffect => '처치 효과';

  @override
  String get contentLevelItemLabelsInspectAndKill => '총기 살펴보기 & 처치 효과';

  @override
  String get contentLevelItemLabelsVoiceover => '음성';

  @override
  String get contentLevelItemLabelsSongShuffle => '음악 셔플';

  @override
  String get contentLevelItemLabelsRandomizer => '무작위';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap => '공격/수비 전환';

  @override
  String get contentLevelItemLabelsTopFrag => '최다 처치 효과';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor => '심장 박동 & 지도 감지기';

  @override
  String get contentLevelItemLabelsFishAnimation => '물고기 애니메이션';

  @override
  String get contentNoTitle => '칭호 없음';

  @override
  String get contentNotForSale => '판매하지 않음';

  @override
  String get contentQueueNamesCompetitive => '경쟁전';

  @override
  String get contentQueueNamesUnrated => '일반전';

  @override
  String get contentQueueNamesSwiftplay => '신속플레이';

  @override
  String get contentQueueNamesSpikerush => '스파이크 돌격';

  @override
  String get contentQueueNamesDeathmatch => '데스매치';

  @override
  String get contentQueueNamesHurm => '팀 데스매치';

  @override
  String get contentQueueNamesGgteam => '에스컬레이션';

  @override
  String get contentQueueNamesOnefa => '복제';

  @override
  String get contentQueueNamesPremier => '프리미어';

  @override
  String get contentQueueNamesCustom => '사용자 설정 게임';

  @override
  String get contentQueueNames => '사용자 설정 게임';

  @override
  String get contentQueueNamesDodgeball => '전멸전';

  @override
  String get contentQueueNamesFortcollins => '탈환전';

  @override
  String get contentQueueNamesSkirmish2v2 => '난투: 2대2';

  @override
  String get contentQueueNamesSkirmishascension1v1 => '초월 난투: 1대1';

  @override
  String get contentQueueNamesSkirmishascension2v2 => '초월 난투: 2대2';

  @override
  String get contentQueueNamesValaram => '무작위 총격전';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => '눈싸움';

  @override
  String get contentQueueNamesNewmap => '서밋';

  @override
  String get contentQueueShortNamesCompetitive => '경쟁전';

  @override
  String get contentQueueShortNamesValaram => '무작위 총격전';

  @override
  String get contentRewardSourceAgent => '요원 계약';

  @override
  String get contentRewardSourceBattlePass => 'Battle Pass 보상';

  @override
  String get contentRewardSourceEvent => '이벤트 패스';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => '타격대';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => '척후대';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => '전략가';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => '감시자';

  @override
  String get contentTierDeluxe => '디럭스';

  @override
  String get contentTierExclusive => '익스클루시브';

  @override
  String contentTierFull(String shortName) {
    return '$shortName 에디션';
  }

  @override
  String get contentTierPremium => '프리미엄';

  @override
  String get contentTierSelect => '셀렉트';

  @override
  String get contentTierUltra => '울트라';

  @override
  String get contentUnranked => '랭크 없음';

  @override
  String get accountRegionUnknown => '알 수 없는 지역';

  @override
  String accountRiotCountry(String country) {
    return 'Riot 계정 국가: $country';
  }

  @override
  String get accountRiotCountryUnknown => 'Riot 계정 국가: 알 수 없음';

  @override
  String accountAccountsHeader(int count, int max) {
    return '계정 ($count/$max)';
  }

  @override
  String get accountActive => '사용 중';

  @override
  String accountAddAccount(int count, int max) {
    return '계정 추가 ($count/$max)';
  }

  @override
  String get accountClearLocalData => '기기 데이터 삭제';

  @override
  String get accountClearLocalDataConfirm =>
      '이 기기에서 기록, 저장된 장비 구성, 로그아웃한 계정의 데이터를 삭제할까요?';

  @override
  String get accountClearRrHistory => 'RR 기록 삭제';

  @override
  String get accountClearRrHistoryConfirm => '이 기기에서 선택한 계정의 RR 기록을 삭제할까요?';

  @override
  String get accountCopyPassword => '비밀번호 복사';

  @override
  String get accountCopyUsername => '아이디 복사';

  @override
  String get accountDeleteLoginNote => '정보 삭제';

  @override
  String get accountDeleteLoginNoteConfirm => '이 계정에 저장된 아이디와 비밀번호를 삭제할까요?';

  @override
  String get accountHidePassword => '비밀번호 숨기기';

  @override
  String get accountKeepLocalData => '기기 데이터 유지';

  @override
  String get accountKeepLocalDataHint => '이 기기의 위시리스트, 장비 구성, 기록을 유지합니다';

  @override
  String accountLevelShort(int level) {
    return 'Lv. $level';
  }

  @override
  String get accountLinkAccountMissing =>
      '알림의 계정이 로그아웃되었습니다. 다시 로그인한 후 알림을 여세요.';

  @override
  String get accountLocalDataCleared => '기기 데이터를 삭제했습니다';

  @override
  String get accountLoginNote => '로그인 정보';

  @override
  String get accountLoginNoteDeleted => '로그인 정보를 삭제했습니다';

  @override
  String get accountLoginNoteHint =>
      '이 기기에만 안전하게 잠긴 상태로 저장됩니다. 다시 로그인할 때 확인하거나 빠르게 입력하는 데 사용하세요.';

  @override
  String get accountLoginNoteLocked => '로그인 정보 잠금 해제';

  @override
  String get accountLoginNotePassword => '비밀번호';

  @override
  String get accountLoginNoteSaved => '로그인 정보를 저장했습니다';

  @override
  String get accountLoginNoteUsername => 'Riot 아이디';

  @override
  String accountMaxAccounts(int max) {
    return '최대 $max개 계정에 도달했습니다.';
  }

  @override
  String get accountNeedsLogin => '다시 로그인 필요';

  @override
  String accountOnlineCount(int count) {
    return '$count명 온라인';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => '저장된 계정 입력';

  @override
  String get accountQuickFillDone => '입력을 마쳤습니다. 로그인을 누르세요.';

  @override
  String get accountQuickFillNotReady =>
      '로그인 페이지를 아직 불러오는 중입니다. 잠시 후 다시 시도하세요.';

  @override
  String get accountQuickFillSubtitle => 'Riot 로그인 페이지에 입력할 계정을 선택하세요';

  @override
  String get accountQuickFillTitle => '저장된 계정 입력';

  @override
  String get accountRegionAp => '아시아 태평양';

  @override
  String get accountRegionBr => '브라질';

  @override
  String get accountRegionEu => '유럽';

  @override
  String get accountRegionKr => '한국';

  @override
  String get accountRegionLatam => '라틴 아메리카';

  @override
  String get accountRegionNa => '북미';

  @override
  String get accountRemoveAccount => '계정 삭제';

  @override
  String accountRemoveAccountConfirm(String account) {
    return '이 기기에서 $account 계정을 삭제할까요? 저장된 데이터는 유지하도록 선택할 수 있습니다.';
  }

  @override
  String get accountRrHistoryCleared => 'RR 기록을 삭제했습니다';

  @override
  String get accountShowPassword => '비밀번호 표시';

  @override
  String get accountSignOutAll => '모든 계정에서 로그아웃';

  @override
  String get accountSignOutAllConfirm =>
      '로그아웃하고 이 기기에서 모든 계정을 삭제할까요? 저장된 데이터는 유지하도록 선택할 수 있습니다.';

  @override
  String get accountStatusAgentSelect => '요원 선택 중';

  @override
  String get accountStatusInMatch => '게임 중';

  @override
  String get accountStatusOffline => '오프라인';

  @override
  String get accountStatusOnline => '온라인';

  @override
  String get accountStatusUnknown => '상태 알 수 없음';

  @override
  String accountSwitchTo(String account) {
    return '$account(으)로 전환';
  }

  @override
  String get accountSwitcherSubtitle => '탭하여 계정 전환';

  @override
  String get accountSwitcherTitle => '계정';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return '계정 ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => '플레이어';

  @override
  String get accountUnlockLoginNote => '인증하여 Riot 로그인 정보 잠금 해제';

  @override
  String accountMoreActions(String riotId) {
    return '$riotId 옵션';
  }

  @override
  String get accountLoginNoteAdd => '로그인 정보 저장';

  @override
  String get accountClearRrHistorySubtitle => '선택한 계정만';

  @override
  String get accountClearLocalDataSubtitle => '기록, 저장된 장비 구성, 로그아웃한 계정의 데이터';

  @override
  String get accountQuickFillLocked =>
      '저장된 계정을 사용하려면 지문, 얼굴 또는 기기 PIN으로 잠금을 해제하세요. 화면 잠금이 설정되어 있지 않다면 설정한 뒤 다시 시도하세요.';

  @override
  String get authAddAsNew => '새 계정으로 추가';

  @override
  String get authDifferentAccountBody =>
      '다시 로그인해야 하는 계정과 다른 계정으로 로그인했습니다. 이 계정을 새 계정으로 추가할까요?';

  @override
  String get authDifferentAccountTitle => '다른 계정';

  @override
  String get authLoadingAccount => '계정 불러오는 중…';

  @override
  String get authLoginCancelledByRiot => 'Riot에서 이번 로그인을 거부했습니다. 다시 시도하세요.';

  @override
  String get authLoginFailed => '로그인을 완료할 수 없습니다';

  @override
  String get authLoginFailedBody => 'Riot에서 로그인을 확인하지 못했습니다. 다시 시도하세요.';

  @override
  String get authLoginTitle => 'Riot 로그인';

  @override
  String get authMissingCookies => '이 기기에 로그인 상태를 저장하지 못해, 만료되면 다시 로그인해야 합니다.';

  @override
  String get authOfficialHost => '공식 페이지 · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => '브라우저에서 링크를 열었습니다.';

  @override
  String get authPageLoadFailed =>
      'Riot 로그인 페이지를 불러오지 못했습니다. 네트워크를 확인하고 다시 시도하세요.';

  @override
  String get authPreparing => '로그인 페이지 준비 중…';

  @override
  String get authReloginDone => '다시 로그인했습니다';

  @override
  String get authSignInCta => 'Riot 계정으로 로그인';

  @override
  String get authSocialLoginHint =>
      'Google 또는 Facebook 로그인이 되지 않으면 Riot 아이디로 로그인하세요.';

  @override
  String get authStateMismatch => '유효하지 않은 로그인 시도입니다. 처음부터 다시 로그인하세요.';

  @override
  String get notificationSessionExpiredBody => '위시리스트 알림을 계속 받으려면 다시 로그인하세요.';

  @override
  String get notificationBackgroundTimingHint =>
      '기기의 배터리 절약 모드로 인해 알림이 늦게 도착할 수 있습니다.';

  @override
  String get notificationChannelAccountDescription => '계정에 다시 로그인해야 할 때 알려 줍니다';

  @override
  String get notificationChannelAccountName => '계정';

  @override
  String get notificationChannelBattlePassDescription =>
      'Battle Pass 진행도와 종료일 알림';

  @override
  String get notificationChannelBattlePassName => 'Battle Pass';

  @override
  String get notificationChannelCommunityDescription =>
      'ValHub를 열 때 커뮤니티 활동 알림';

  @override
  String get notificationChannelCommunityName => '커뮤니티';

  @override
  String get notificationChannelLfgDescription => 'ValHub를 열 때 파티 참가 플레이어 알림';

  @override
  String get notificationChannelLfgName => '파티';

  @override
  String get notificationChannelNightMarketDescription => '야시장이 열리면 알림';

  @override
  String get notificationChannelNightMarketName => '야시장';

  @override
  String get notificationChannelRankDescription => '프로필을 새로고침할 때 랭크 변동 알림';

  @override
  String get notificationChannelRankName => '랭크';

  @override
  String get notificationChannelStoreResetDescription => '일일 상점이 초기화되면 알림';

  @override
  String get notificationChannelStoreResetName => '상점 초기화';

  @override
  String get notificationChannelWishlistDescription => '위시리스트의 스킨이 상점에 나오면 알림';

  @override
  String get notificationChannelWishlistName => '위시리스트';

  @override
  String get notificationLfgJoinedTitle => '플레이어가 파티에 참가했습니다';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return '$account의 할인 카드 $cards장이 기다리고 있습니다. 지금 뒤집어 보세요.';
  }

  @override
  String get notificationNightMarketOpenTitle => '야시장이 열렸습니다!';

  @override
  String get notificationPassEndingBody =>
      'Battle Pass 종료까지 약 하루 남았습니다. ValHub에서 최신 진행도를 확인하세요.';

  @override
  String get notificationPassEndingTitle => 'Battle Pass 곧 종료';

  @override
  String notificationPassProgressBody(int level) {
    return '현재 Battle Pass에서 레벨 $level에 도달했습니다.';
  }

  @override
  String get notificationPassProgressTitle => 'Battle Pass 진행도';

  @override
  String get notificationPrivateAccount => '내 계정';

  @override
  String notificationRankChangedBody(String rank) {
    return '현재 랭크: $rank. Riot에서 방금 업데이트되었습니다.';
  }

  @override
  String get notificationRankChangedTitle => '랭크 변동';

  @override
  String get notificationResetTimingUnknown => '상점을 열어 기기의 초기화 시간을 업데이트하세요.';

  @override
  String get notificationSessionExpiredTitle => '다시 로그인 필요';

  @override
  String get notificationStoreResetBody => '상점에서 새 스킨이 기다리고 있습니다.';

  @override
  String get competitiveDivisionIron => '아이언';

  @override
  String get competitiveDivisionBronze => '브론즈';

  @override
  String get competitiveDivisionSilver => '실버';

  @override
  String get competitiveDivisionGold => '골드';

  @override
  String get competitiveDivisionPlatinum => '플래티넘';

  @override
  String get competitiveDivisionDiamond => '다이아몬드';

  @override
  String get competitiveDivisionAscendant => '초월자';

  @override
  String get competitiveDivisionImmortal => '불멸';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => '레디언트';

  @override
  String get competitiveRankUnknown => '랭크 알 수 없음';

  @override
  String get competitiveAttack => '공격';

  @override
  String get competitiveCannotEstimate => '예측할 수 없음';

  @override
  String get competitiveDefeat => '패배';

  @override
  String get competitiveDefense => '수비';

  @override
  String get competitiveDraw => '무승부';

  @override
  String get competitiveIncognitoPlayer => '숨겨진 플레이어';

  @override
  String get competitiveMatchPending => 'Riot에서 게임을 처리하는 중…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    return '배치 게임 $n판 남음';
  }

  @override
  String get competitiveRoundDefuse => '스파이크 해체';

  @override
  String get competitiveRoundDetonate => '스파이크 폭발';

  @override
  String get competitiveRoundElimination => '전원 처치';

  @override
  String get competitiveRoundSurrendered => '항복';

  @override
  String get competitiveRoundTimeExpired => '시간 종료';

  @override
  String get competitiveUnknownPlayer => '플레이어';

  @override
  String get competitiveVictory => '승리';

  @override
  String economyAvailableNow(String place) {
    return '지금 $place에 있습니다!';
  }

  @override
  String economyPlaceBundle(String name) {
    return '$name 번들';
  }

  @override
  String get economyPlaceBundleGeneric => '번들';

  @override
  String get economyPlaceDaily => '일일 상점';

  @override
  String get economyPlaceNightMarket => '야시장';

  @override
  String get economyPriceEstimated => '에디션 기준 예상 가격';

  @override
  String get economyPriceFromOffers => 'Riot 가격표 기준 가격';

  @override
  String get economyPriceFromStore => '상점에서 확인된 가격';

  @override
  String get economyPriceFromTable => '정가';

  @override
  String get economyPriceUnknown => '가격 알 수 없음';

  @override
  String loadoutDefaultPresetName(int n) {
    return '장비 구성 $n';
  }

  @override
  String get loadoutInvalidChange => '현재 장비 구성에 적용할 수 없는 변경입니다.';

  @override
  String get loadoutNotPersisted =>
      'Riot에 변경 사항이 저장되지 않아 장비 구성이 그대로입니다. 다시 시도하세요.';

  @override
  String get loadoutSaveFailed => '장비 구성을 저장할 수 없습니다';

  @override
  String battlePassActEndsIn(String time) {
    return '액트 종료까지 $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    return '액트 종료까지 $days일';
  }

  @override
  String get battlePassAllMissionsDone => '모든 임무 완료';

  @override
  String get battlePassAllWeeklyDone => '모든 주간 임무 완료';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return '대기 중인 2배 보상: $n';
  }

  @override
  String battlePassChapter(int n) {
    return '챕터 $n';
  }

  @override
  String battlePassChapterProgress(int reached, int total) {
    return '$reached/$total';
  }

  @override
  String battlePassCharges(int charges, int needed) {
    return '$charges/$needed';
  }

  @override
  String get battlePassCheckpointHint => '라운드에서 승리해 체크포인트를 진행하세요(데스매치는 제외).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return '체크포인트 $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => '체크포인트마다: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return '체크포인트 $done/$total 달성';
  }

  @override
  String get battlePassCurrentChapter => '현재';

  @override
  String get battlePassDailyAllDone => '오늘의 체크포인트를 모두 완료했습니다';

  @override
  String get battlePassDailyCaption => '일일 보상';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return '일일 보상 · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      '지난 날의 체크포인트가 만료되었습니다. 게임에 접속하거나 여기서 새로고침하세요.';

  @override
  String get battlePassDailyMissions => '일일 임무';

  @override
  String get battlePassDailyNotReady =>
      '오늘의 체크포인트가 아직 준비되지 않았습니다. 게임에 접속하거나 여기서 새로고침하세요.';

  @override
  String get battlePassDailyPlayToStart =>
      '오늘의 체크포인트가 아직 준비되지 않았습니다. 게임에 접속해 새로운 하루를 시작하세요.';

  @override
  String battlePassDaysLeft(int days) {
    return '$days일 남음';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return '$wall 종료';
  }

  @override
  String get battlePassEpilogue => '에필로그';

  @override
  String get battlePassEstimateNote =>
      '게임당 약 4,000 XP 기준 예상치이며, 임무는 포함하지 않습니다.';

  @override
  String battlePassEventEndsIn(String time) {
    return '종료까지 $time';
  }

  @override
  String get battlePassEventPass => '이벤트 패스';

  @override
  String get battlePassFilterAll => '전체';

  @override
  String get battlePassFilterLocked => '잠김';

  @override
  String get battlePassFilterUnlocked => '잠금 해제됨';

  @override
  String get battlePassFree => '무료';

  @override
  String get battlePassFreeTrack => '무료 보상';

  @override
  String battlePassLevelOf(String level, String count) {
    return '레벨 $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'Lv. $n';
  }

  @override
  String battlePassMatchesEstimate(int n, String queue) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$queue ≈ $nString판';
  }

  @override
  String get battlePassMissionDone => '완료';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return '$done/$total 완료';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return '$wall에 새 임무';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return '새 임무까지 $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return '다음 체크포인트: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return '레벨 $level까지';
  }

  @override
  String get battlePassNextReward => '다음';

  @override
  String get battlePassNoBattlePass =>
      '현재 액트의 Battle Pass 정보가 아직 없습니다. 나중에 다시 시도하세요.';

  @override
  String get battlePassNoRewards => '이 Battle Pass에는 아직 보상이 없습니다.';

  @override
  String get battlePassNoRewardsInFilter => '이 항목에는 보상이 없습니다.';

  @override
  String get battlePassNoRewardsTitle => '보상 없음';

  @override
  String get battlePassNoWeeklyMissions => '현재 주간 임무가 없습니다.';

  @override
  String get battlePassPassComplete => 'Battle Pass 완료';

  @override
  String get battlePassPremium => '프리미엄';

  @override
  String get battlePassPremiumHint =>
      '프리미엄을 구매하지 않아 무료 보상만 받을 수 있습니다. 게임에서 프리미엄을 구매하면 달성한 레벨의 보상이 잠금 해제됩니다.';

  @override
  String get battlePassRenewButton => '체크포인트 새로고침';

  @override
  String get battlePassRenewDone => '일일 체크포인트를 새로고침했습니다.';

  @override
  String get battlePassRenewFailed => '체크포인트를 새로고침할 수 없습니다. 나중에 다시 시도하세요.';

  @override
  String battlePassResetsAtWall(String wall) {
    return '$wall 초기화';
  }

  @override
  String battlePassResetsIn(String time) {
    return '초기화까지 $time';
  }

  @override
  String get battlePassRewardLevelLabel => '레벨';

  @override
  String get battlePassRewardLocked => '잠김';

  @override
  String get battlePassRewardNeedsPremium => '프리미엄 필요';

  @override
  String get battlePassRewardStatusLabel => '상태';

  @override
  String get battlePassRewardTrackLabel => '보상 트랙';

  @override
  String get battlePassRewardTypeLabel => '유형';

  @override
  String get battlePassRewardUnlocked => '잠금 해제됨';

  @override
  String get battlePassRewardsTitle => '보상';

  @override
  String get battlePassShowAllRewards => '모두 보기';

  @override
  String get battlePassTitle => 'Battle Pass';

  @override
  String get battlePassTotalXpCaption => '총 XP';

  @override
  String get battlePassUnknownMission => '새 임무 (설명 없음)';

  @override
  String get battlePassUnknownReward => '보상';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return '$unlocked/$total 잠금 해제';
  }

  @override
  String get battlePassUnratedFallback => '일반전';

  @override
  String get battlePassViewAllRewards => '모든 보상 보기';

  @override
  String get battlePassWeeklyMissions => '주간 임무';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return '주간 임무 남은 XP: +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / 일';
  }

  @override
  String get battlePassXpPerDayCaption => '기한 내 완료하려면 하루에 필요한 양';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return '$xp XP 남음';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return '장비 구성을 저장할 수 없습니다. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': '보유한 모든 스킨, 상점 가격 기준 가치',
      'buddy': '보유한 총기 장식과 복제본 수',
      'spray': '표현 휠에 추가할 수 있는 스프레이',
      'card': '잠금 해제한 플레이어 카드, 탭하여 보기 및 장착',
      'title': '이름 아래에 표시할 수 있는 칭호',
      'flex': '보유한 플렉스',
      'other': '수집품 둘러보기',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return '슬롯: $position';
  }

  @override
  String get collectionApplyPreset => '적용';

  @override
  String get collectionApplyPresetBody =>
      '현재 사용 중인 스킨, 총기 장식, 표현 휠, 카드, 칭호가 이 장비 구성으로 교체됩니다.';

  @override
  String collectionApplyPresetTitle(String name) {
    return '“$name”을(를) 적용할까요?';
  }

  @override
  String get collectionBrowseBuddies => '총기 장식';

  @override
  String get collectionBrowseCards => '플레이어 카드';

  @override
  String get collectionBrowseEmpty => '이 항목에 보유한 아이템이 없습니다.';

  @override
  String get collectionBrowseEmptyTitle => '아이템 없음';

  @override
  String get collectionBrowseFlex => '플렉스';

  @override
  String get collectionBrowseSkins => '스킨';

  @override
  String get collectionBrowseSprays => '스프레이';

  @override
  String get collectionBrowseTitles => '칭호';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return '$free/$total 남음';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return '$weapon용';
  }

  @override
  String get collectionBuddyPickerTitle => '총기 장식 선택';

  @override
  String get collectionBuddyRemoved => '총기 장식을 해제했습니다';

  @override
  String get collectionBuddySlot => '총기 장식';

  @override
  String get collectionBuddyUnavailable =>
      '이 총기 장식을 장착할 수 없습니다. 새로고침하거나 다른 장식을 선택하세요.';

  @override
  String get collectionCachedLoadout =>
      '저장된 장비 구성을 표시하고 있습니다. 변경하기 전에 당겨서 새로고침하세요.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '보유 카드 $nString장';
  }

  @override
  String get collectionChangeBuddy => '변경';

  @override
  String collectionChromaCount(int owned, int total) {
    return '색상 변형 $owned/$total';
  }

  @override
  String get collectionClearTiers => '에디션 필터 해제';

  @override
  String get collectionCollectionValue => '수집품 가치';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => '기본';

  @override
  String get collectionDeletePreset => '삭제';

  @override
  String get collectionEmptySlot => '비어 있음';

  @override
  String get collectionEquip => '장착';

  @override
  String get collectionEquipped => '장착 중';

  @override
  String get collectionEquippedCard => '장착 중인 카드';

  @override
  String collectionEquippedCardLabel(String name) {
    return '장착 중인 카드: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return '$name 장착 완료';
  }

  @override
  String collectionEquippedLine(String skin) {
    return '장착 중: $skin';
  }

  @override
  String get collectionExcludedRewards => '보상 스킨 제외';

  @override
  String get collectionExpressionsHint => '슬롯을 탭하여 스프레이 또는 플렉스를 선택하세요.';

  @override
  String get collectionExpressionsSlots => '휠 슬롯';

  @override
  String get collectionExpressionsTitle => '표현 휠';

  @override
  String get collectionHideAccountLevel => '계정 레벨 숨기기';

  @override
  String get collectionHideAccountLevelHint => '다른 플레이어에게 계정 레벨이 표시되지 않습니다.';

  @override
  String get collectionIncognito => '익명 모드';

  @override
  String get collectionIncognitoHint => '게임에서 파티원이 아닌 플레이어에게 이름을 숨깁니다.';

  @override
  String get collectionLevelBorderAuto => '레벨에 따라 자동';

  @override
  String collectionLevelBorderFrom(int level) {
    return '레벨 $level부터';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return '계정 레벨 $level';
  }

  @override
  String get collectionLevelBorderTitle => '레벨 테두리 선택';

  @override
  String collectionLevelCount(int owned, int total) {
    return '레벨 $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return '레벨 $n · $type';
  }

  @override
  String get collectionLevels => '레벨';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return '레벨 $owned/$total 잠금 해제';
  }

  @override
  String get collectionLobbyBanner => '대기실 배너';

  @override
  String get collectionLocked => '잠김';

  @override
  String get collectionMeleeNoBuddy => '근접 무기에는 총기 장식을 장착할 수 없습니다.';

  @override
  String get collectionMove => '이동';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy이(가) $from에 장착되어 있습니다. $to(으)로 옮길까요?';
  }

  @override
  String get collectionMoveBuddyTitle => '총기 장식을 옮길까요?';

  @override
  String get collectionNoBuddies => '보유한 총기 장식이 없습니다.';

  @override
  String get collectionNoBuddy => '총기 장식 없음';

  @override
  String get collectionNoFlex => '보유한 플렉스가 없습니다.';

  @override
  String get collectionNoResults => '일치하는 결과가 없습니다.';

  @override
  String get collectionNoResultsTitle => '결과 없음';

  @override
  String get collectionNoSkinsForWeapon => '이 무기의 스킨을 보유하고 있지 않습니다.';

  @override
  String get collectionNoSprays => '보유한 스프레이가 없습니다.';

  @override
  String get collectionNoTitle => '칭호 없음';

  @override
  String get collectionOtherWeapons => '기타';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '스킨 $n개 보유',
      zero: '보유한 스킨 없음',
    );
    return '$_temp0';
  }

  @override
  String collectionOwnedSkinsStat(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '보유 스킨 $nString개';
  }

  @override
  String get collectionPlayLevelVideo => '이 레벨 영상 보기';

  @override
  String get collectionPlayVideo => '영상 보기';

  @override
  String get collectionPlayerCardSubtitle => '대기실, 점수판, 적을 처치할 때 표시됩니다.';

  @override
  String get collectionPlayerCardTitle => '플레이어 카드 변경';

  @override
  String get collectionPlayerTitleSubtitle => '대기실과 게임에서 이름 아래에 표시됩니다.';

  @override
  String get collectionPlayerTitleTitle => '칭호 변경';

  @override
  String get collectionPresetActions => '옵션';

  @override
  String collectionPresetApplied(String name) {
    return '“$name” 적용 완료';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n개',
      zero: '없음',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return '“$name” 삭제 완료';
  }

  @override
  String get collectionPresetNameHint => '예: 랭크 올리기';

  @override
  String get collectionPresetNameTitle => '장비 구성 이름';

  @override
  String collectionPresetSaved(String name) {
    return '“$name” 저장 완료';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return '$date 저장';
  }

  @override
  String collectionPresetSkipped(int n) {
    return '더 이상 보유하지 않은 아이템 $n개를 건너뛰었습니다.';
  }

  @override
  String get collectionPresetsEmpty =>
      '현재 장비 구성을 저장해 두면 나중에 스킨, 카드, 표현 휠 조합을 빠르게 바꿀 수 있습니다.';

  @override
  String get collectionPresetsEmptyTitle => '저장된 장비 구성 없음';

  @override
  String get collectionPresetsFull =>
      '최대 50개의 장비 구성에 도달했습니다. 더 저장하려면 일부를 삭제하세요.';

  @override
  String get collectionPresetsNote => '장비 구성은 선택한 계정 기준으로 이 기기에만 저장됩니다.';

  @override
  String get collectionPresetsTitle => '저장된 장비 구성';

  @override
  String get collectionPreview => '미리 보기';

  @override
  String get collectionRemoveBuddy => '총기 장식 해제';

  @override
  String get collectionRenamePreset => '이름 변경';

  @override
  String get collectionRowExpressions => '표현 휠';

  @override
  String get collectionRowLevelBorder => '레벨 테두리';

  @override
  String get collectionRowPresets => '저장된 장비 구성';

  @override
  String get collectionRowWeapons => '무기 장비';

  @override
  String get collectionRowWishlist => '위시리스트';

  @override
  String get collectionSaveFailed => '장비 구성을 저장할 수 없습니다';

  @override
  String get collectionSavePreset => '현재 장비 구성 저장';

  @override
  String get collectionSaving => '저장 중…';

  @override
  String get collectionSearchBuddies => '총기 장식 검색…';

  @override
  String get collectionSearchCards => '플레이어 카드 검색…';

  @override
  String get collectionSearchFlex => '플렉스 검색…';

  @override
  String get collectionSearchItems => '검색…';

  @override
  String get collectionSearchSkins => '스킨 검색…';

  @override
  String get collectionSearchSprays => '스프레이 검색…';

  @override
  String get collectionSearchTitles => '칭호 검색…';

  @override
  String get collectionSearchWeapons => '무기, 스킨, 총기 장식 검색…';

  @override
  String get collectionSectionBrowse => '수집품 둘러보기';

  @override
  String get collectionSectionIdentity => '다른 플레이어에게 표시';

  @override
  String get collectionSectionLoadout => '장비';

  @override
  String get collectionSkinCustomizeTitle => '스킨 사용자 설정';

  @override
  String get collectionSkinNotFound => '이 스킨을 찾을 수 없습니다.';

  @override
  String get collectionSkinNotOwned => '이 스킨을 보유하고 있지 않습니다.';

  @override
  String get collectionSlotNamesItem0 => '위';

  @override
  String get collectionSlotNamesItem1 => '오른쪽';

  @override
  String get collectionSlotNamesItem2 => '아래';

  @override
  String get collectionSlotNamesItem3 => '왼쪽';

  @override
  String get collectionSortName => '이름';

  @override
  String get collectionSortPrice => '가격';

  @override
  String get collectionSortRarity => '희귀도';

  @override
  String get collectionSortWeapon => '무기';

  @override
  String collectionSummaryFiltered(int count, String value) {
    return '필터 적용: 스킨 $count개 · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return '필터 적용: 아이템 $count/$total개';
  }

  @override
  String collectionSummaryItems(int count) {
    return '아이템 $count개';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    return '스킨 $count개 · $value';
  }

  @override
  String get collectionTabFlex => '플렉스';

  @override
  String get collectionTabSprays => '스프레이';

  @override
  String get collectionTapToChangeCard => '탭하여 카드 변경';

  @override
  String get collectionTitle => '수집품';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '보유 칭호 $nString개';
  }

  @override
  String get collectionUndo => '실행 취소';

  @override
  String get collectionUnknownCard => '알 수 없는 카드';

  @override
  String get collectionValueAtStorePrices => '상점 가격 기준';

  @override
  String get collectionValueHasEstimates => '예상 가격 포함 (≈)';

  @override
  String collectionValueRewardCount(int n) {
    return '보상 스킨 $n개 제외';
  }

  @override
  String get collectionValueSeeSkins => '스킨 보기';

  @override
  String collectionValueSkinCount(int n) {
    return '스킨 $n개 기준';
  }

  @override
  String get collectionVariants => '색상 변형';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return '무기 $custom/$total개에 스킨 적용 중';
  }

  @override
  String get collectionWeaponLoadoutTitle => '무기 장비';

  @override
  String get collectionWeaponNotFound => '이 무기를 찾을 수 없습니다.';

  @override
  String get collectionWeaponSkinsTitle => '스킨 선택';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '스킨 $n개',
      zero: '비어 있음',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      '부적절한 표현이 있어 게시하지 못했습니다. 내용을 수정한 후 다시 시도하세요.';

  @override
  String get communityModerationContentScam =>
      '커뮤니티에서는 계정 거래, 대리 랭크, 전화번호 남기기 등의 광고를 허용하지 않습니다. 해당 내용을 삭제한 후 다시 시도하세요.';

  @override
  String get communityModerationContentTooComplex =>
      '흩어진 문자가 너무 많습니다. 더 간단하게 작성한 후 다시 시도하세요.';

  @override
  String get communityModerationAccountBanned =>
      '이 계정은 커뮤니티 이용이 정지되었습니다. 착오라고 생각되면 정보 및 법적 고지에서 ValHub에 문의하세요.';

  @override
  String get communityModerationAccountRestricted =>
      '이 계정은 게시물 작성, 댓글, 팀원 찾기, 투표가 제한되어 있습니다. 나중에 다시 시도하거나 정보 및 법적 고지에서 ValHub에 문의하세요.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': '경쟁전',
      'unrated': '일반전',
      'swiftplay': '신속플레이',
      'spikerush': '스파이크 돌격',
      'deathmatch': '데스매치',
      'teamdeathmatch': '팀 데스매치',
      'premier': '프리미어',
      'custom': '사용자 설정 게임',
      'other': '기타',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': '아시아 태평양',
      'na': '북미',
      'eu': '유럽',
      'kr': '한국',
      'latam': '라틴 아메리카',
      'br': '브라질',
      'other': '알 수 없는 지역',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => '이 순위에 아직 스킨이 없습니다';

  @override
  String get communityRankingEmptyVotes => '선택한 범위와 필터에 맞는 좋아요가 아직 없습니다.';

  @override
  String get communityRankingEmptyRatings => '선택한 범위와 필터에 맞는 별점이 아직 없습니다.';

  @override
  String get communityRankingEmptyReviews => '선택한 범위와 필터에 맞는 리뷰가 아직 없습니다.';

  @override
  String get communityRankingExplore => '스킨을 찾아 보고 평가하기';

  @override
  String get communityRankingExploreHint =>
      '스킨 또는 무기 이름으로 검색하세요. 커뮤니티의 실제 평가만 순위에 표시됩니다.';

  @override
  String get communityRankingClear => '무기 및 기간 필터 해제';

  @override
  String get communityRankingSort => '순위 기준';

  @override
  String get communityRankingWeapon => '무기';

  @override
  String get communityRankingNoSearch =>
      '일치하는 스킨이 없습니다. 다른 이름으로 검색하거나 무기 필터를 해제하세요.';

  @override
  String get communityRankingCatalogUnavailable =>
      '스킨 목록을 불러오지 못했습니다. 이 창을 닫고 데이터가 동기화된 후 다시 시도하세요.';

  @override
  String get communityConsentExitAccount => '동의 안 함 · 이 계정에서 로그아웃';

  @override
  String get communityRankingGlobalAllTime => '전 세계 · 전체 기간';

  @override
  String get communityRankingCatalogTitle => '모든 스킨';

  @override
  String get communityReviewOwnershipRequired =>
      '스킨을 평가하려면 계정이 이 스킨을 보유해야 합니다. 커뮤니티 평가와 댓글은 계속 볼 수 있습니다.';

  @override
  String get communityReviewOwnershipUnavailable =>
      '스킨 보유 여부를 확인하지 못했습니다. 수집품을 새로고침하거나 온라인 상태에서 다시 시도하세요.';

  @override
  String get communityReviewLegacyOwnership => '이전 리뷰 · 보유 미확인';

  @override
  String get communityReviewVerifiedOwner => '리뷰 작성 시 보유 확인됨';

  @override
  String get communitySkinDiscussionHint =>
      '누구나 댓글을 남길 수 있습니다. 별점과 리뷰는 스킨 보유자만 작성할 수 있습니다.';

  @override
  String get communityAddPhotos => '사진 추가';

  @override
  String get communityAllModes => '전체';

  @override
  String get communityAllWeapons => '모든 무기';

  @override
  String get communityAnonymousBanner => '익명으로 둘러보는 중';

  @override
  String get communityAnyLanguage => '모든 언어';

  @override
  String get communityAnyRank => '모든 랭크';

  @override
  String get communityAnyRole => '모든 역할군';

  @override
  String get communityApply => '적용';

  @override
  String get communityBackToMyCountry => '내 국가로 돌아가기';

  @override
  String get communityBlockAuthor => '이 기기에서 차단';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => '선택 해제';

  @override
  String get communityCodeAuto => '비워 두기: 게시할 때 ValHub가 게임 내 파티에서 코드를 생성합니다.';

  @override
  String get communityCodeAutoFailed =>
      '파티 코드를 생성하지 못했습니다. VALORANT를 실행하거나 코드를 직접 입력하세요.';

  @override
  String get communityCodeInvalid => '코드는 대문자 또는 숫자 정확히 6자리여야 합니다.';

  @override
  String get communityCodeRequired => '파티 코드를 입력하거나 생성하세요.';

  @override
  String get communityCommentHint => '댓글 작성…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '댓글 $nString개';
  }

  @override
  String communityCommentsHeader(String n) {
    return '댓글 · $n';
  }

  @override
  String get communityCommentsTitle => '댓글';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return '게시물 $posts개 · 플레이어 $authors명';
  }

  @override
  String communityCommunityLfg(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '팀원 찾기 글 $nString개';
  }

  @override
  String get communityCommunityVotes => '커뮤니티 인기';

  @override
  String get communityComposerHint => '오늘 VALORANT에 대해 어떤 생각을 하고 있나요?';

  @override
  String get communityComposerTitle => '새 게시물';

  @override
  String communityConsentAccount(String riotId) {
    return '계정: $riotId';
  }

  @override
  String get communityConsentAgree => '동의하고 계속하기';

  @override
  String get communityConsentGateAction => '참여';

  @override
  String get communityConsentGuidelines => '커뮤니티 가이드라인';

  @override
  String get communityConsentLater => '나중에';

  @override
  String get communityConsentLocal =>
      '비밀번호와 기타 로그인 데이터는 항상 이 기기에만 남습니다. 설정에서 동의를 철회할 수 있습니다.';

  @override
  String get communityConsentPrivacy => '개인정보 처리방침';

  @override
  String get communityConsentPublic =>
      '다른 사람에게 내 Riot ID, 플레이어 카드, 랭크, 국가가 표시됩니다.';

  @override
  String get communityConsentTitle => '개인정보 보호 및 ValHub 커뮤니티';

  @override
  String get communityConsentVerify =>
      'ValHub는 연결 시 Riot ID를 확인하고 리뷰를 저장할 때 스킨 보유 여부를 확인하기 위해 Riot 접근 권한을 커뮤니티 서버로 보냅니다. 서버는 필요한 데이터만 읽고, 사용 후 즉시 접근 권한을 폐기하며, 저장하지 않습니다.';

  @override
  String get communityConsentWithdrawn =>
      '동의를 철회했습니다. 앱을 계속 사용하려면 다시 동의해야 합니다.';

  @override
  String get communityCountriesTitle => '국가별 커뮤니티';

  @override
  String get communityCountryNamesAE => '아랍에미리트';

  @override
  String get communityCountryNamesAL => '알바니아';

  @override
  String get communityCountryNamesAM => '아르메니아';

  @override
  String get communityCountryNamesAR => '아르헨티나';

  @override
  String get communityCountryNamesAT => '오스트리아';

  @override
  String get communityCountryNamesAU => '오스트레일리아';

  @override
  String get communityCountryNamesAZ => '아제르바이잔';

  @override
  String get communityCountryNamesBA => '보스니아 헤르체고비나';

  @override
  String get communityCountryNamesBD => '방글라데시';

  @override
  String get communityCountryNamesBE => '벨기에';

  @override
  String get communityCountryNamesBG => '불가리아';

  @override
  String get communityCountryNamesBH => '바레인';

  @override
  String get communityCountryNamesBN => '브루나이';

  @override
  String get communityCountryNamesBO => '볼리비아';

  @override
  String get communityCountryNamesBR => '브라질';

  @override
  String get communityCountryNamesBY => '벨라루스';

  @override
  String get communityCountryNamesCA => '캐나다';

  @override
  String get communityCountryNamesCH => '스위스';

  @override
  String get communityCountryNamesCL => '칠레';

  @override
  String get communityCountryNamesCN => '중국';

  @override
  String get communityCountryNamesCO => '콜롬비아';

  @override
  String get communityCountryNamesCR => '코스타리카';

  @override
  String get communityCountryNamesCU => '쿠바';

  @override
  String get communityCountryNamesCY => '키프로스';

  @override
  String get communityCountryNamesCZ => '체코';

  @override
  String get communityCountryNamesDE => '독일';

  @override
  String get communityCountryNamesDK => '덴마크';

  @override
  String get communityCountryNamesDO => '도미니카 공화국';

  @override
  String get communityCountryNamesDZ => '알제리';

  @override
  String get communityCountryNamesEC => '에콰도르';

  @override
  String get communityCountryNamesEE => '에스토니아';

  @override
  String get communityCountryNamesEG => '이집트';

  @override
  String get communityCountryNamesES => '스페인';

  @override
  String get communityCountryNamesET => '에티오피아';

  @override
  String get communityCountryNamesFI => '핀란드';

  @override
  String get communityCountryNamesFR => '프랑스';

  @override
  String get communityCountryNamesGB => '영국';

  @override
  String get communityCountryNamesGE => '조지아';

  @override
  String get communityCountryNamesGH => '가나';

  @override
  String get communityCountryNamesGR => '그리스';

  @override
  String get communityCountryNamesGT => '과테말라';

  @override
  String get communityCountryNamesHK => '홍콩';

  @override
  String get communityCountryNamesHN => '온두라스';

  @override
  String get communityCountryNamesHR => '크로아티아';

  @override
  String get communityCountryNamesHU => '헝가리';

  @override
  String get communityCountryNamesID => '인도네시아';

  @override
  String get communityCountryNamesIE => '아일랜드';

  @override
  String get communityCountryNamesIL => '이스라엘';

  @override
  String get communityCountryNamesIN => '인도';

  @override
  String get communityCountryNamesIQ => '이라크';

  @override
  String get communityCountryNamesIR => '이란';

  @override
  String get communityCountryNamesIS => '아이슬란드';

  @override
  String get communityCountryNamesIT => '이탈리아';

  @override
  String get communityCountryNamesJO => '요르단';

  @override
  String get communityCountryNamesJP => '일본';

  @override
  String get communityCountryNamesKE => '케냐';

  @override
  String get communityCountryNamesKH => '캄보디아';

  @override
  String get communityCountryNamesKR => '대한민국';

  @override
  String get communityCountryNamesKW => '쿠웨이트';

  @override
  String get communityCountryNamesKZ => '카자흐스탄';

  @override
  String get communityCountryNamesLA => '라오스';

  @override
  String get communityCountryNamesLB => '레바논';

  @override
  String get communityCountryNamesLK => '스리랑카';

  @override
  String get communityCountryNamesLT => '리투아니아';

  @override
  String get communityCountryNamesLU => '룩셈부르크';

  @override
  String get communityCountryNamesLV => '라트비아';

  @override
  String get communityCountryNamesLY => '리비아';

  @override
  String get communityCountryNamesMA => '모로코';

  @override
  String get communityCountryNamesMD => '몰도바';

  @override
  String get communityCountryNamesME => '몬테네그로';

  @override
  String get communityCountryNamesMK => '북마케도니아';

  @override
  String get communityCountryNamesMM => '미얀마';

  @override
  String get communityCountryNamesMN => '몽골';

  @override
  String get communityCountryNamesMO => '마카오';

  @override
  String get communityCountryNamesMT => '몰타';

  @override
  String get communityCountryNamesMX => '멕시코';

  @override
  String get communityCountryNamesMY => '말레이시아';

  @override
  String get communityCountryNamesNG => '나이지리아';

  @override
  String get communityCountryNamesNI => '니카라과';

  @override
  String get communityCountryNamesNL => '네덜란드';

  @override
  String get communityCountryNamesNO => '노르웨이';

  @override
  String get communityCountryNamesNP => '네팔';

  @override
  String get communityCountryNamesNZ => '뉴질랜드';

  @override
  String get communityCountryNamesOM => '오만';

  @override
  String get communityCountryNamesPA => '파나마';

  @override
  String get communityCountryNamesPE => '페루';

  @override
  String get communityCountryNamesPH => '필리핀';

  @override
  String get communityCountryNamesPK => '파키스탄';

  @override
  String get communityCountryNamesPL => '폴란드';

  @override
  String get communityCountryNamesPR => '푸에르토리코';

  @override
  String get communityCountryNamesPT => '포르투갈';

  @override
  String get communityCountryNamesPY => '파라과이';

  @override
  String get communityCountryNamesQA => '카타르';

  @override
  String get communityCountryNamesRO => '루마니아';

  @override
  String get communityCountryNamesRS => '세르비아';

  @override
  String get communityCountryNamesRU => '러시아';

  @override
  String get communityCountryNamesSA => '사우디아라비아';

  @override
  String get communityCountryNamesSE => '스웨덴';

  @override
  String get communityCountryNamesSG => '싱가포르';

  @override
  String get communityCountryNamesSI => '슬로베니아';

  @override
  String get communityCountryNamesSK => '슬로바키아';

  @override
  String get communityCountryNamesSV => '엘살바도르';

  @override
  String get communityCountryNamesTH => '태국';

  @override
  String get communityCountryNamesTL => '동티모르';

  @override
  String get communityCountryNamesTN => '튀니지';

  @override
  String get communityCountryNamesTR => '튀르키예';

  @override
  String get communityCountryNamesTW => '대만';

  @override
  String get communityCountryNamesUA => '우크라이나';

  @override
  String get communityCountryNamesUS => '미국';

  @override
  String get communityCountryNamesUY => '우루과이';

  @override
  String get communityCountryNamesUZ => '우즈베키스탄';

  @override
  String get communityCountryNamesVE => '베네수엘라';

  @override
  String get communityCountryNamesVN => '베트남';

  @override
  String get communityCountryNamesZA => '남아프리카 공화국';

  @override
  String get communityCreateLfg => '팀원 찾기 글 작성';

  @override
  String get communityCreateLfgShort => '글 작성';

  @override
  String get communityDataDeleted => '커뮤니티 데이터를 삭제했습니다.';

  @override
  String communityDataFooter(String riotId) {
    return '현재 계정에 적용됩니다: $riotId. 다운로드 파일에는 비밀번호나 Riot 로그인 데이터가 포함되지 않습니다.';
  }

  @override
  String get communityDecrease => '줄이기';

  @override
  String get communityDelete => '삭제';

  @override
  String get communityDeleteComment => '댓글 삭제';

  @override
  String get communityDeleteCommentBody => '이 댓글은 영구적으로 삭제됩니다.';

  @override
  String get communityDeleteCommentTitle => '댓글을 삭제할까요?';

  @override
  String get communityDeleteDataConfirm => '영구 삭제';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'ValHub 커뮤니티에 있는 $riotId의 모든 게시물, 댓글, 스킨 리뷰, 좋아요, 투표, 팀원 찾기 글, 사진이 영구적으로 삭제되며 복구할 수 없습니다. 이 계정으로 ValHub를 계속 사용하려면 다시 동의해야 합니다. 다른 계정으로 전환하거나 이 계정에서 로그아웃할 수도 있습니다.\n\nRiot 계정과 게임 내 데이터에는 영향이 없습니다. 사본을 보관하려면 먼저 데이터를 다운로드하세요.';
  }

  @override
  String get communityDeleteDataConfirmTitle => '커뮤니티 데이터를 삭제할까요?';

  @override
  String get communityDeleteDataSubtitle => '커뮤니티에 게시한 모든 내용을 영구적으로 삭제합니다.';

  @override
  String get communityDeleteDataTitle => '내 커뮤니티 데이터 삭제';

  @override
  String get communityDeletePost => '게시물 삭제';

  @override
  String get communityDeletePostBody => '게시물과 모든 댓글이 영구적으로 삭제됩니다.';

  @override
  String get communityDeletePostTitle => '게시물을 삭제할까요?';

  @override
  String get communityDeleteReview => '리뷰 삭제';

  @override
  String get communityDeleteReviewBody => '이 스킨에 남긴 별점과 리뷰가 삭제됩니다.';

  @override
  String get communityDeleteReviewTitle => '내 리뷰를 삭제할까요?';

  @override
  String get communityDeleted => '삭제했습니다.';

  @override
  String get communityDiscard => '버리기';

  @override
  String get communityDiscardBody => '방금 작성한 내용은 저장되지 않습니다.';

  @override
  String get communityDiscardTitle => '게시물을 버릴까요?';

  @override
  String get communityDownload => '다운로드 후 번역';

  @override
  String get communityDownloadingModels => '언어 팩 다운로드 중…';

  @override
  String get communityEditReview => '수정';

  @override
  String get communityEdited => '수정됨';

  @override
  String get communityEmptyPost => '내용을 입력하거나 사진을 추가하세요.';

  @override
  String get communityExpired => '만료됨';

  @override
  String communityExpiresIn(String t) {
    return '$t 남음';
  }

  @override
  String get communityExportPreparing => '준비 중…';

  @override
  String get communityExportSubject => 'ValHub 커뮤니티 데이터';

  @override
  String get communityExportSubtitle =>
      '커뮤니티에 게시한 모든 내용의 사본: 게시물, 댓글, 리뷰, 좋아요, 투표, 팀원 찾기 글.';

  @override
  String get communityExportTitle => '내 데이터 다운로드';

  @override
  String get communityExtend => '연장';

  @override
  String get communityExtended => '글 게시 기간을 30분 연장했습니다.';

  @override
  String get communityFeedEmptyBody => '가장 먼저 내 상점, 야시장, 멋진 순간을 공유해 보세요!';

  @override
  String get communityFeedEmptyFilteredBody =>
      '일치하는 게시물이 없습니다. 다른 언어를 선택하거나 필터를 해제하세요.';

  @override
  String get communityFeedEmptyGuestBody =>
      '아직 새 게시물이 없습니다. 나중에 다시 확인하거나 참여해서 공유하세요.';

  @override
  String get communityFeedEmptyScopeBody => '글로벌 커뮤니티의 게시물을 보거나 필터를 변경해 보세요.';

  @override
  String get communityFeedEmptyScopeTitle => '이 범위에 아직 게시물이 없습니다';

  @override
  String get communityFeedEmptyTitle => '피드가 비어 있습니다';

  @override
  String get communityFilters => '필터';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Google 번역';

  @override
  String get communityHelpful => '도움이 됨';

  @override
  String communityHelpfulCount(String n) {
    return '도움이 됨 · $n';
  }

  @override
  String get communityHiddenAuthors => '숨기거나 차단한 플레이어';

  @override
  String get communityHiddenAuthorsEmpty => '숨기거나 차단한 플레이어가 없습니다';

  @override
  String get communityHiddenAuthorsHint =>
      '이 기기의 이 계정에만 적용됩니다. 해당 플레이어의 콘텐츠는 숨겨지지만, 상대는 여전히 내 공개 콘텐츠를 볼 수 있습니다.';

  @override
  String communityImageOf(int i, int n) {
    return '사진 $i/$n';
  }

  @override
  String get communityIncrease => '늘리기';

  @override
  String get communityJoin => '참가';

  @override
  String get communityJoinCodeExpired => '파티 코드가 만료되었거나 더 이상 유효하지 않습니다.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'VALORANT의 현재 파티를 나가고 $name의 파티에 참가합니다.';
  }

  @override
  String get communityJoinConfirmTitle => '이 파티에 참가할까요?';

  @override
  String get communityJoinGameNotRunning =>
      'PC 또는 콘솔에서 VALORANT를 실행한 후 다시 시도하세요.';

  @override
  String get communityJoinParty => '파티 참가';

  @override
  String get communityJoinPartyFull => '이 파티는 인원이 가득 찼습니다.';

  @override
  String get communityJoinedHint => '파티에 참가했습니다! VALORANT를 열어 함께 플레이하세요.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '참가 요청 $nString건';
  }

  @override
  String get communityKindNightMarket => '야시장';

  @override
  String get communityKindStore => '오늘의 상점';

  @override
  String get communityLanguage => '언어';

  @override
  String get communityLanguageFilter => '콘텐츠 언어';

  @override
  String get communityLanguageFilterHint =>
      '선택한 언어로 작성된 콘텐츠만 표시합니다. 모두 보려면 비워 두세요.';

  @override
  String get communityLanguageNamesAr => 'العربية';

  @override
  String get communityLanguageNamesDe => 'Deutsch';

  @override
  String get communityLanguageNamesEn => 'English';

  @override
  String get communityLanguageNamesEs => 'Español';

  @override
  String get communityLanguageNamesFr => 'Français';

  @override
  String get communityLanguageNamesId => 'Bahasa Indonesia';

  @override
  String get communityLanguageNamesIt => 'Italiano';

  @override
  String get communityLanguageNamesJa => '日本語';

  @override
  String get communityLanguageNamesKo => '한국어';

  @override
  String get communityLanguageNamesPl => 'Polski';

  @override
  String get communityLanguageNamesPt => 'Português';

  @override
  String get communityLanguageNamesRu => 'Русский';

  @override
  String get communityLanguageNamesTh => 'ไทย';

  @override
  String get communityLanguageNamesTr => 'Türkçe';

  @override
  String get communityLanguageNamesVi => 'Tiếng Việt';

  @override
  String get communityLanguageNamesZhCN => '简体中文';

  @override
  String get communityLanguageNamesZhTW => '繁體中文';

  @override
  String communityLanguagesSelected(int n) {
    return '언어 $n개';
  }

  @override
  String get communityLfgEmptyBody =>
      '글을 작성하면 다른 플레이어가 한 번의 탭으로 내 파티에 참가할 수 있습니다.';

  @override
  String get communityLfgEmptyTitle => '아직 팀원을 찾는 사람이 없습니다';

  @override
  String get communityLfgExpiredRepost => '글이 만료되었습니다. 새 글을 작성해 팀원을 찾으세요.';

  @override
  String get communityLfgGateBody =>
      '참여하면(Riot ID 1회 인증) 같은 서버 플레이어의 글을 보고 내 팀원 찾기 글을 올릴 수 있습니다. 피드와 스킨 순위는 지금처럼 볼 수 있습니다.';

  @override
  String get communityLfgGateTitle => '팀원 찾기는 회원 전용입니다';

  @override
  String communityLfgOtherShardNote(String region) {
    return '$region 서버를 보고 있습니다 — 내 계정과 같은 서버의 플레이어만 파티에 참가할 수 있습니다.';
  }

  @override
  String get communityLfgPosted => '팀원 찾기 글을 게시했습니다!';

  @override
  String get communityLfgPreviewTitle => '내 랭크에 맞는 팀원 찾기';

  @override
  String get communityLfgRemoved => '글을 내렸습니다.';

  @override
  String get communityLfgSameShardNote => '같은 서버의 플레이어만 파티에 참가할 수 있습니다.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return '지역: $region · 글은 30분 후 자동으로 만료됩니다.';
  }

  @override
  String get communityLike => '좋아요';

  @override
  String get communityLiveMembers => '파티원';

  @override
  String get communityMatchMyRank => '내 랭크에 맞춤';

  @override
  String communityMemberJoined(String name) {
    return '$name 님이 파티에 참가했습니다';
  }

  @override
  String get communityMemberJoinedBody => '내 팀원 찾기 글을 보고 누군가 참가했습니다.';

  @override
  String get communityMic => '마이크 필수';

  @override
  String get communityMicOn => '마이크 사용';

  @override
  String get communityMode => '모드';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => '더 보기';

  @override
  String get communityMuteAuthor => '이 플레이어 숨기기';

  @override
  String get communityNewPost => '게시';

  @override
  String communityNightMarketOf(String date) {
    return '$date 야시장';
  }

  @override
  String get communityNoAccountBody =>
      'Riot 계정을 추가하면 게시물 작성, 팀원 찾기, 스킨 투표를 할 수 있습니다.';

  @override
  String get communityNoAccountTitle => '로그인하고 참여하기';

  @override
  String get communityNoComments => '아직 댓글이 없습니다. 첫 댓글을 남겨 보세요!';

  @override
  String get communityNoRatings => '아직 평가 없음';

  @override
  String get communityNote => '메모';

  @override
  String get communityNoteHint => '예: 전략가 1명 구함, 마이크 사용, 즐겜 위주';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return '합계 $amount';
  }

  @override
  String get communityOpenReviews => '리뷰 보기';

  @override
  String get communityOutOfRange => '랭크 범위 밖';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => '파티 코드';

  @override
  String get communityPartyCodeHint => '예: A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return '파티 코드: $code';
  }

  @override
  String get communityPartySize => '현재 파티';

  @override
  String get communityPartySizeFromGame => '게임 내 파티에서 가져옴';

  @override
  String communityPartySizeValue(int n) {
    return '$n명';
  }

  @override
  String communityPhotoCount(int n, int max) {
    return '사진 $n/$max장';
  }

  @override
  String get communityPlayVideo => '영상 보기';

  @override
  String get communityPostLfg => '글 게시';

  @override
  String get communityPostNotFound => '삭제되었거나 숨겨진 게시물입니다.';

  @override
  String get communityPostTitle => '게시물';

  @override
  String get communityPosted => '게시했습니다!';

  @override
  String get communityPublish => '게시';

  @override
  String get communityPublishing => '게시 중…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => '최저';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => '랭크 범위';

  @override
  String get communityRankRangeInvalid => '최저 랭크는 최고 랭크보다 높을 수 없습니다.';

  @override
  String communityRankSemantics(String n, String name) {
    return '$n위: $name';
  }

  @override
  String get communityRankTo => '최고';

  @override
  String get communityRateLimitedTitle => '잠시만 기다려 주세요';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '평가 $nString개';
  }

  @override
  String communityRatingSummary(String avg, int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$avg · 평가 $nString개';
  }

  @override
  String get communityRatingWordsItem0 => '별로예요';

  @override
  String get communityRatingWordsItem1 => '아쉬워요';

  @override
  String get communityRatingWordsItem2 => '괜찮아요';

  @override
  String get communityRatingWordsItem3 => '멋져요';

  @override
  String get communityRatingWordsItem4 => '최고예요';

  @override
  String get communityRefreshList => '새로고침';

  @override
  String get communityRegion => '지역';

  @override
  String get communityRemoveAttachment => '첨부 삭제';

  @override
  String get communityRemoveLfg => '글 내리기';

  @override
  String get communityRemoveLfgBody => '다른 플레이어에게 이 글이 더 이상 표시되지 않습니다.';

  @override
  String get communityRemoveLfgTitle => '팀원 찾기 글을 내릴까요?';

  @override
  String get communityRemovePhoto => '사진 삭제';

  @override
  String get communityReport => '신고';

  @override
  String get communityReportConfirmBody => '여러 플레이어에게 신고된 콘텐츠는 커뮤니티에서 숨겨집니다.';

  @override
  String get communityReportConfirmTitle => '신고할까요?';

  @override
  String get communityReportPrompt => '이 콘텐츠를 신고하는 이유는 무엇인가요?';

  @override
  String get communityReportReasonsSpam => '스팸 또는 광고';

  @override
  String get communityReportReasonsHarassment => '괴롭힘, 모욕';

  @override
  String get communityReportReasonsInappropriate => '부적절한 콘텐츠';

  @override
  String get communityReportReasonsScam => '사기, 계정 거래';

  @override
  String get communityReportReasonsOther => '기타 사유';

  @override
  String get communityReportTitle => '콘텐츠 신고';

  @override
  String get communityReported => '감사합니다! 신고가 접수되었습니다.';

  @override
  String get communityReviewDeleted => '리뷰를 삭제했습니다.';

  @override
  String get communityReviewHint => '이 스킨에 대한 생각을 공유하세요(선택 사항)';

  @override
  String get communityReviewSaved => '리뷰를 저장했습니다!';

  @override
  String get communityReviewTitle => '스킨 평가';

  @override
  String get communityReviewsEmptyBody => '아직 리뷰가 없습니다 — 첫 리뷰를 남겨 보세요!';

  @override
  String get communityReviewsEmptyTitle => '아직 리뷰 없음';

  @override
  String communityReviewsHeader(String n) {
    return '리뷰 · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot 서비스에 문제가 있습니다';

  @override
  String get communityRoleFlex => '자유';

  @override
  String get communityRoles => '필요한 역할군';

  @override
  String get communitySaveReview => '리뷰 저장';

  @override
  String get communityScopeCountry => '내 국가';

  @override
  String get communityScopeGlobal => '글로벌';

  @override
  String get communityScopeRegion => '지역';

  @override
  String get communitySectionFeed => '피드';

  @override
  String get communitySectionLfg => '팀원 찾기';

  @override
  String get communitySectionSkins => '스킨 순위';

  @override
  String get communitySend => '보내기';

  @override
  String get communitySendComment => '댓글 보내기';

  @override
  String get communityShareNightMarketHint => '내 야시장을 모두에게 자랑하세요';

  @override
  String communitySharePostTitle(String name) {
    return 'ValHub의 $name 게시물';
  }

  @override
  String get communityShareStore => '커뮤니티에 자랑하기';

  @override
  String get communityShareStoreHint => '오늘의 상점을 모두에게 자랑하세요';

  @override
  String get communityShowOriginal => '원문 보기';

  @override
  String get communityShowTranslation => '번역 보기';

  @override
  String get communitySignInToReview => '스킨을 평가하려면 Riot 계정을 추가하세요.';

  @override
  String get communitySkinNotFound => '이 스킨을 찾을 수 없습니다.';

  @override
  String get communitySlots => '필요 인원';

  @override
  String communitySlotsTooMany(int max) {
    return '파티는 최대 5명입니다: $max자리만 남았습니다.';
  }

  @override
  String communitySlotsWanted(int n) {
    return '$n명 구함';
  }

  @override
  String get communitySortHelpful => '도움 많이 된 순';

  @override
  String get communitySortNewest => '최신순';

  @override
  String get communitySortRating => '평점 높은 순';

  @override
  String get communitySortReviews => '리뷰 많은 순';

  @override
  String get communitySortVotes => '인기순';

  @override
  String communityStarLabel(int n) {
    return '별 $n개';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '별 5개 중 $avg';
  }

  @override
  String get communityStatusFull => '인원 마감';

  @override
  String get communityStatusInGame => '게임 중';

  @override
  String get communityStatusOpen => '모집 중';

  @override
  String communityStoreOf(String date) {
    return '$date 상점';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => '별을 탭하여 이 스킨을 평가하세요';

  @override
  String get communityTitle => '커뮤니티';

  @override
  String communityTooLong(int max) {
    return '최대 $max자까지 가능합니다.';
  }

  @override
  String get communityTranslate => 'Google로 번역';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return '$from에서 $to(으)로 번역하려면 ValHub가 Google에서 언어 팩(약 $size)을 다운로드해야 합니다. 한 번만 다운로드하면 되며, 콘텐츠는 기기에서만 번역되고 어떤 서버로도 전송되지 않습니다.';
  }

  @override
  String get communityTranslateDownloadTitle => '기기 내 언어 팩을 다운로드할까요?';

  @override
  String get communityTranslateFailed => '번역하지 못했습니다. 다시 시도하세요.';

  @override
  String get communityTranslatedByGoogle => 'Google 자동 번역';

  @override
  String get communityTranslating => '번역 중…';

  @override
  String get communityTrendingTitle => '전 세계 인기 스킨';

  @override
  String get communityUnavailableBody =>
      'ValHub 커뮤니티에 연결하지 못했습니다. 잠시 후 다시 시도하세요.';

  @override
  String get communityUnavailableTitle => '커뮤니티에 연결할 수 없음';

  @override
  String get communityUnhideAuthor => '숨김 해제 / 차단 해제';

  @override
  String get communityUnknownPlayer => '플레이어';

  @override
  String get communityUnlike => '좋아요 취소';

  @override
  String get communityUnvote => '하트 취소';

  @override
  String get communityVote => '이 스킨에 하트 누르기';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '좋아요 $nString개';
  }

  @override
  String get communityWithdrawConfirm => '철회';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub에서 $riotId(으)로 커뮤니티를 더 이상 사용하지 않으며 이 기기의 커뮤니티 연결을 삭제합니다. 이 계정으로 ValHub를 계속 사용하려면 다시 동의해야 합니다. 다른 계정으로 전환하거나 이 계정에서 로그아웃할 수도 있습니다.\n\n게시한 게시물, 댓글, 리뷰, 투표, 팀원 찾기 글은 하나씩 삭제하거나 \"내 커뮤니티 데이터 삭제\"를 선택하기 전까지 커뮤니티에 남아 Riot ID가 계속 표시됩니다.';
  }

  @override
  String get communityWithdrawConfirmTitle => '동의를 철회할까요?';

  @override
  String get communityWithdrawSubtitle =>
      '이 계정으로 커뮤니티 사용을 중단합니다. 게시한 글은 유지됩니다.';

  @override
  String get communityWithdrawTitle => '동의 철회';

  @override
  String get communityWriteFirstReview => '첫 리뷰 작성';

  @override
  String get communityYou => '나';

  @override
  String get communityYourCountry => '내 국가';

  @override
  String get communityYourReview => '내 리뷰';

  @override
  String communityHiddenAuthorsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString명 숨김',
    );
    return '$_temp0';
  }

  @override
  String get communityLfgOtherServer => '다른 서버';

  @override
  String get communityLfgEmptyRankTitle => '내 랭크에 맞는 글이 없습니다';

  @override
  String get communityLfgEmptyRankBody => '내 랭크를 받지 않는 글은 숨겨져 있습니다.';

  @override
  String get communityLfgShowAllRanks => '모든 랭크 보기';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return '나: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => '요원 선택';

  @override
  String get liveGameAnonymous => '익명';

  @override
  String get liveGameAutoRefreshNote => '게임 중일 때 자동으로 새로고침됩니다.';

  @override
  String get liveGameCurrentGame => '현재 게임';

  @override
  String get liveGameEmptyTeam => '아직 플레이어가 없습니다.';

  @override
  String get liveGameEnemyHiddenInAgentSelect => '적 팀은 게임이 시작되면 표시됩니다.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return '적 팀 확정 $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable => 'K/D/A와 점수판은 경기가 끝난 뒤 표시됩니다.';

  @override
  String get liveGameFinalScoreboard => '최종 점수판';

  @override
  String get liveGameFlex => '플렉스';

  @override
  String get liveGameInLobby => '대기실';

  @override
  String get liveGameInMatch => '게임 중';

  @override
  String get liveGameInQueue => '대기열';

  @override
  String liveGameInQueueFor(String elapsed) {
    return '대기열 · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return '레벨 $n';
  }

  @override
  String get liveGameLiveScore => '실시간 점수';

  @override
  String get liveGameLoadoutFromAgentSelect => '요원 선택 시 장비';

  @override
  String get liveGameLoadoutFromMatch => '이번 게임 장비';

  @override
  String get liveGameLobbyHint => '게임이 잡히면 ValHub에서 모든 팀의 구성과 랭크를 보여 줍니다.';

  @override
  String get liveGameLockedTag => '확정';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub가 자동으로 다시 시도합니다. 점수판은 보통 1분 정도 후에 준비됩니다.';

  @override
  String get liveGameNoAgentYet => '요원 미선택';

  @override
  String get liveGameNoLoadout => '이 플레이어의 장비 정보가 없습니다.';

  @override
  String get liveGameNotInGame => '게임 중 아님';

  @override
  String get liveGameNotInGameHint =>
      'VALORANT를 열고 대기열에 참가하세요 — 요원 선택 화면에 들어가면 게임 정보가 여기에 자동으로 표시됩니다.';

  @override
  String get liveGameNotInGameTitle => '참여 중인 게임이 없습니다';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return '$name의 장비 보기';
  }

  @override
  String get liveGameOpenParty => '파티 & 대기열 열기';

  @override
  String get liveGameParty => '파티';

  @override
  String liveGamePeak(String rank) {
    return '최고: $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return '$name의 장비';
  }

  @override
  String get liveGamePlayerLoadoutTitle => '장비';

  @override
  String get liveGameQueueHint => '앱을 열어 두세요 — 게임이 잡히면 바로 게임 정보가 표시됩니다.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      '게임을 나가면 불이익(RR 감소, 대기열 제한)을 받을 수 있습니다. 그래도 나갈까요?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      '요원 선택 중 닷지하면 불이익(RR 감소, 대기열 제한)을 받을 수 있습니다. 그래도 나갈까요?';

  @override
  String get liveGameQuitConfirmTitle => '게임을 나갈까요?';

  @override
  String get liveGameQuitDone => '게임을 나갔습니다.';

  @override
  String get liveGameQuitFailed => '게임을 나가지 못했습니다.';

  @override
  String get liveGameQuitMatch => '게임 나가기';

  @override
  String get liveGameQuitMatchChanged =>
      '확인하는 동안 게임 단계가 바뀌었습니다. 아직 게임을 나가지 않았으니 다시 시도하세요.';

  @override
  String get liveGameRankUnavailable => '랭크 알 수 없음';

  @override
  String get liveGameRefresh => '새로고침';

  @override
  String liveGameRefreshIn(int seconds) {
    return '$seconds초 후 자동 새로고침';
  }

  @override
  String get liveGameRefreshNow => '지금 새로고침';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => '게임 정보';

  @override
  String get liveGameSprays => '스프레이';

  @override
  String get liveGameStatusAgentSelect => '요원 선택';

  @override
  String get liveGameStatusEnded => '종료';

  @override
  String get liveGameStatusInProgress => '진행 중';

  @override
  String get liveGameStatusUnavailable => '게임 상태를 업데이트하지 못했습니다';

  @override
  String get liveGameTabAllPlayers => '플레이어';

  @override
  String get liveGameTabEnemyTeam => '적 팀';

  @override
  String get liveGameTabYourTeam => '우리 팀';

  @override
  String liveGameTimeLeft(String t) {
    return '$t 남음';
  }

  @override
  String get liveGameViewMatchDetails => '게임 상세 정보 보기';

  @override
  String get liveGameWeapons => '무기';

  @override
  String get liveGameYou => '나';

  @override
  String liveGameYouHover(String agent) {
    return '$agent 선택 중';
  }

  @override
  String liveGameYouLocked(String agent) {
    return '$agent 확정 완료';
  }

  @override
  String get liveGamePickInGame =>
      '요원 선택과 확정은 VALORANT에서 하세요. ValHub는 남은 시간과 우리 팀만 보여 줍니다.';

  @override
  String get liveGameLastMatchTitle => '방금 끝난 경기';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws무',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – 결과 미확인 $unknown판',
      zero: '',
    );
    return '$wins승 – $losses패$_temp0$_temp1';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return '기기 시간($offset)';
  }

  @override
  String profileKillDescription(
    String killer,
    String victim,
    String hasWeapon,
    String weapon,
    String time,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasWeapon, {
      'yes': '$weapon(으)로 ',
      'other': '',
    });
    return '$killer이(가) $_temp0$victim을(를) 처치 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30일',
      'days7': '7일',
      'other': '전체 기간',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': '요원',
      'maps': '맵',
      'queues': '모드',
      'sides': '공격 / 수비',
      'trend': '추세',
      'other': '모드',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => '모든 모드';

  @override
  String get profileAbility => '스킬';

  @override
  String profileAboutMatches(int n) {
    return '≈ $n판';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => '평균 전투 점수';

  @override
  String profileActRecord(int wins, int games, String rate) {
    return '이번 액트: $wins승 / $games판 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => '모든 플레이어';

  @override
  String get profileAlreadyReached => '이미 이 랭크에 도달했습니다.';

  @override
  String get profileAtCurrentForm => '현재 폼 기준';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return '현재 폼 기준 (게임당 $gain / $loss)';
  }

  @override
  String profileBestCase(int n) {
    return '최선: $n연승';
  }

  @override
  String get profileByWinRateTitle => '승률별';

  @override
  String get profileChooseMap => '맵으로 필터';

  @override
  String get profileColA => 'A';

  @override
  String get profileColD => 'D';

  @override
  String get profileColK => 'K';

  @override
  String get profileColPlace => '#';

  @override
  String get profileColPlusMinus => '+/−';

  @override
  String get profileCopyRiotId => 'Riot ID 복사';

  @override
  String get profileCurrentRank => '현재';

  @override
  String get profileDailyRrEmpty => '이 기기에 저장된 경쟁전 게임이 아직 없습니다.';

  @override
  String get profileDailyRrFootnote =>
      'RR 기록은 기기에 바로 저장되며, Riot에서 더 이상 제공하지 않는 게임도 포함됩니다.';

  @override
  String get profileDailyRrTitle => '일별 RR';

  @override
  String profileDayBoundary(String zone) {
    return '날짜 기준: $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    return '플레이한 날 $n일';
  }

  @override
  String get profileEndOfHistory => '모든 게임을 표시했습니다';

  @override
  String get profileEnemyTeam => '적 팀';

  @override
  String get profileFallDamage => '낙하 피해';

  @override
  String get profileFilterAll => '전체';

  @override
  String get profileFirstBloods => '첫 킬';

  @override
  String get profileFirstDeaths => '첫 데스';

  @override
  String get profileFirstHalf => '전반전';

  @override
  String get profileFormNoRoundStats => 'K/D, ACS, HS%는 라운드 기반 모드만 계산합니다.';

  @override
  String profileFormPending(int n) {
    return '목록의 게임 $n판을 아직 불러오지 않아 계산에 포함되지 않았습니다.';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR, HS%는 라운드 기반 게임 $roundGames/$games판만 계산합니다';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    return '최근 $games판: $w승, $l패';
  }

  @override
  String get profileFriendsRow => '친구 & 채팅';

  @override
  String get profileHideKills => '처치 기록 숨기기';

  @override
  String get profileHitBody => '몸통';

  @override
  String get profileHitDistribution => '명중 부위 분포';

  @override
  String get profileHitHead => '머리';

  @override
  String get profileHitLegs => '다리';

  @override
  String profileHitShare(String part, String percent) {
    return '$part $percent';
  }

  @override
  String get profileHs => 'HS%';

  @override
  String get profileKast => 'KAST';

  @override
  String get profileKastHint => '처치, 어시스트, 생존 또는 트레이드를 기록한 라운드 비율';

  @override
  String get profileKd => 'K/D';

  @override
  String get profileKdaLabel => 'K/D/A';

  @override
  String profileKdaValue(int k, int d, int a) {
    return '$k/$d/$a';
  }

  @override
  String profileLastDays(int n) {
    return '최근 $n일';
  }

  @override
  String profileLastMatches(int n) {
    return '최근 $n판';
  }

  @override
  String profileLeaderboard(String n) {
    return '리더보드 #$n';
  }

  @override
  String profileLevel(int n) {
    return '레벨 $n';
  }

  @override
  String get profileLevelHidden => '레벨 숨김';

  @override
  String profileLossStreak(int n) {
    return '$n연패';
  }

  @override
  String profileMapFilter(String map) {
    return '맵: $map';
  }

  @override
  String profileMatchCount(int n) {
    return '$n판';
  }

  @override
  String get profileMatchDetailTitle => '게임 상세 정보';

  @override
  String get profileMatchHistory => '전적';

  @override
  String get profileMatchUnavailable => '게임을 불러오지 못했습니다';

  @override
  String get profileMatchesNeeded => '필요한 게임 수';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => '랭크 기록 없음';

  @override
  String get profileNoKillsInRound => '이 라운드의 처치 정보가 아직 없습니다.';

  @override
  String get profileNoMatches => '아직 게임이 없습니다.';

  @override
  String get profileNoMatchesMap => '불러온 게임 중 이 맵에서 플레이한 게임이 없습니다.';

  @override
  String get profileNoMatchesQueue => '이 모드에서 플레이한 게임이 없습니다.';

  @override
  String get profileNoPlayers => '이 게임의 플레이어 정보가 아직 없습니다.';

  @override
  String get profileNoRounds => '이 게임의 라운드별 정보가 아직 없습니다.';

  @override
  String get profileOvertime => '연장전';

  @override
  String get profilePlayHubTitle => '게임 & 파티';

  @override
  String get profilePeakRank => '최고';

  @override
  String get profilePerformanceAttack => '공격';

  @override
  String get profilePerformanceDefense => '수비';

  @override
  String get profilePerformanceEmpty =>
      '이 기기에 기록된 게임이 아직 없습니다. 전적을 열어 플레이한 게임을 기록하세요.';

  @override
  String get profilePerformanceNoMatches => '선택한 기간에 게임이 없습니다.';

  @override
  String profilePerformanceRounds(int n) {
    return '기록된 라운드 $n개';
  }

  @override
  String get profilePerformanceSample =>
      '비율은 게임이 3판 이상일 때만 표시됩니다. ACS, ADR, HS%, K/D는 라운드 기반 모드만 계산합니다.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return '$known/$total 라운드에서 공격 또는 수비 진영을 확인했습니다.';
  }

  @override
  String profilePerformanceSince(String date) {
    return '$date부터 이 기기에 기록된 전적';
  }

  @override
  String get profilePerformanceTitle => '성과';

  @override
  String profilePlacement(int n) {
    return '$n위';
  }

  @override
  String profilePlantedAt(String site) {
    return '$site 지점에 스파이크 설치';
  }

  @override
  String get profilePlayerProfileTitle => '플레이어 프로필';

  @override
  String get profilePlayerSummary => '성과';

  @override
  String profileProgressTo(String rank) {
    return '$rank까지 진행도';
  }

  @override
  String get profileProgressToTarget => '목표 랭크까지 진행도';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      '최근 경쟁전 게임을 기준으로 한 예상치이며, 배치 게임과 강등 보호는 반영하지 않습니다.';

  @override
  String profileRankUpHint(int matches, String rank) {
    return '$rank까지 ≈ $matches판';
  }

  @override
  String get profileRankUpImmortal => '이미 불멸 이상입니다 — 이 기능은 불멸 1까지만 계산합니다.';

  @override
  String get profileRankUpNoForm => '폼을 예측할 최근 경쟁전 게임이 없습니다.';

  @override
  String get profileRankUpOpen => '랭크업 계산기 열기';

  @override
  String get profileRankUpTitle => '랭크업 계산기';

  @override
  String get profileRankUpUnranked => '랭크업 계산기를 사용하려면 배치 게임을 완료하세요.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => '경쟁전 점수판';

  @override
  String profileRecentForm(int w, int l) {
    return '최근 폼: $w승 – $l패';
  }

  @override
  String get profileRecentFormTitle => '최근 폼';

  @override
  String get profileRecentMatches => '최근 게임';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$w승 · $l패 · $d무',
      zero: '$w승 · $l패',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Riot ID를 복사했습니다';

  @override
  String profileRound(int n) {
    return '라운드 $n';
  }

  @override
  String profileRoundKills(int n) {
    return '$n킬';
  }

  @override
  String get profileRoundLost => '라운드 패배';

  @override
  String get profileRoundTimeline => '라운드 진행';

  @override
  String get profileRoundWon => '라운드 승리';

  @override
  String get profileRoundsHint => '라운드를 탭하면 각 처치 기록을 볼 수 있습니다.';

  @override
  String profileRrLeft(String n) {
    return '$n RR 남음';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'RR 추이';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => '점수판';

  @override
  String get profileSecondHalf => '후반전';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => '처치 기록 보기';

  @override
  String get profileSideSwitch => '진영 교체';

  @override
  String get profileSpike => '스파이크';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => '목표 랭크';

  @override
  String get profileTeamBlue => '블루 팀';

  @override
  String get profileTeamMvp => '팀 MVP';

  @override
  String get profileTeamRed => '레드 팀';

  @override
  String get profileTitle => '프로필';

  @override
  String profileToday(String text) {
    return '오늘: $text';
  }

  @override
  String get profileTodayNone => '오늘 경쟁전 게임 없음';

  @override
  String get profileTruePeakLocal => '이 기기의 기록 기준';

  @override
  String get profileWeekdayShortItem0 => '월';

  @override
  String get profileWeekdayShortItem1 => '화';

  @override
  String get profileWeekdayShortItem2 => '수';

  @override
  String get profileWeekdayShortItem3 => '목';

  @override
  String get profileWeekdayShortItem4 => '금';

  @override
  String get profileWeekdayShortItem5 => '토';

  @override
  String get profileWeekdayShortItem6 => '일';

  @override
  String get profileWinRate => '승률';

  @override
  String profileWinStreak(int n) {
    return '$n연승';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => '내 랭크';

  @override
  String get profileYourSummary => '내 성과';

  @override
  String get profileYourTeam => '우리 팀';

  @override
  String get profileYourWinRate => '내 최근 승률';

  @override
  String profilePerformanceQueueChip(String queue) {
    return '모드: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => '모드별 필터';

  @override
  String get profilePerformancePerMatchTitle => '게임별';

  @override
  String get profilePerformancePerMatchHint => '막대를 탭하면 해당 게임을 엽니다.';

  @override
  String profilePerformanceAverage(String value) {
    return '평균 $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      '그래프를 표시하려면 이 기록이 있는 라운드 기반 게임이 2판 이상 필요합니다.';

  @override
  String get profilePerformanceOpeningsTitle => '첫 교전';

  @override
  String get profilePerformanceOpeningWin => '첫 교전 승률';

  @override
  String get profilePerformanceOpeningWinHint =>
      '첫 킬을 하거나 첫 데스를 당한 라운드 중 첫 킬을 한 비율입니다.';

  @override
  String get profilePerformanceFirstBloodsPerGame => '게임당 첫 킬';

  @override
  String get profilePerformanceFirstDeathsPerGame => '게임당 첫 데스';

  @override
  String get profilePerformanceMultiKillsTitle => '한 라운드 멀티킬';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3킬',
      'k4': '4킬',
      'ace': '에이스',
      'other': '2킬',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceMultiKillsNote(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '처치 데이터가 모두 있는 게임 $nString판 기준입니다.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => '라운드 승률';

  @override
  String get profilePerformanceDrillHint => '행을 탭하면 해당 요원, 맵 또는 모드만 볼 수 있습니다.';

  @override
  String get profilePerformanceLoadOlder => '이전 게임 분석';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ValHub는 이 기기에서 연 게임만 분석합니다. 탭할 때마다 이전 게임을 최대 $nString판 추가합니다.';
  }

  @override
  String get profilePerformanceSearchingOlder => '이전 게임을 찾는 중…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return '게임 분석 중 $doneString/$totalString…';
  }

  @override
  String profilePerformanceAddedOlder(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '게임 $nString판을 분석에 추가했습니다.',
      zero: '추가할 새 게임이 없습니다.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder => 'Riot에 더 이전 게임 기록이 남아 있지 않습니다.';

  @override
  String get profileEconomyTitle => '우리 팀 경제';

  @override
  String get profileEconomyHint =>
      '구매 유형은 라운드 시작 시 우리 팀 장비 총액으로 정합니다(5인 기준 vlr.gg 방식): Eco 5,000 미만, Semi-eco 10,000 미만, Semi-buy 20,000 미만, Full buy 20,000 크레드 이상. 각 전반/후반의 첫 라운드는 Pistol입니다.';

  @override
  String profileBuyType(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'pistol': 'Pistol',
      'eco': 'Eco',
      'semiEco': 'Semi-eco',
      'semiBuy': 'Semi-buy',
      'fullBuy': 'Full buy',
      'other': '–',
    });
    return '$_temp0';
  }

  @override
  String profileEconomyWon(int won, int played) {
    final intl.NumberFormat wonNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String wonString = wonNumberFormat.format(won);
    final intl.NumberFormat playedNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String playedString = playedNumberFormat.format(played);

    return '승리 $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get profileSessionTitle => '최근 세션';

  @override
  String profileSessionDuration(int hours, int minutes) {
    final intl.NumberFormat hoursNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String hoursString = hoursNumberFormat.format(hours);
    final intl.NumberFormat minutesNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String minutesString = minutesNumberFormat.format(minutes);

    return '$hoursString시간 $minutesString분';
  }

  @override
  String profileSessionTopAgent(String agent, int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '최다: $agent ×$countString';
  }

  @override
  String get legalAboutIntro =>
      '나만의 VALORANT 도우미: 일일 상점, 위시리스트, 랭크, 게임 기록, 여러 계정, 플레이어 커뮤니티를 내 기기에서 바로 확인하세요.';

  @override
  String get legalBackToTop => '맨 위로';

  @override
  String get legalConsentAnd => ' 및 ';

  @override
  String get legalConsentPrefix => '계속하면 ValHub의 ';

  @override
  String get legalConsentPrivacy => '개인정보 처리방침';

  @override
  String get legalConsentSuffix => ' 모두에 동의하게 됩니다.';

  @override
  String get legalConsentTerms => '이용약관';

  @override
  String get legalContact => '문의';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => '문의';

  @override
  String legalEffectiveFrom(String date) {
    return '$date부터 시행';
  }

  @override
  String get legalLegalHeader => '법적 고지';

  @override
  String get legalLicensePageLegalese => '© 2026 Nguyễn Đức Huy. 모든 권리 보유.';

  @override
  String get legalThirdPartyLicenses => '타사 소프트웨어';

  @override
  String get legalThirdPartyLicensesBody => 'ValHub에서 사용하는 오픈 소스 소프트웨어 라이선스';

  @override
  String get legalTocTitle => '목차';

  @override
  String legalVersion(String version) {
    return '버전 $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return '이 문서는 현재 $language(으)로 표시됩니다.';
  }

  @override
  String get legalContentUnavailable =>
      '법적 문서를 읽을 수 없습니다. 다시 시도하거나 지원팀에 문의하세요.';

  @override
  String get legalTranslationNotice =>
      '이 번역은 편의를 위해 제공됩니다. 내용이 다를 경우 베트남어 원문이 우선합니다.';

  @override
  String get settingsUiLanguageTitle => '앱 언어';

  @override
  String get settingsLanguageFollowDevice => '기기 언어 사용';

  @override
  String get settingsLanguageSaveFailed => '언어를 저장하지 못했습니다. 다시 시도하세요.';

  @override
  String get settingsGeoCountry => '국가';

  @override
  String get settingsGeoSearchCountry => '국가 이름 또는 코드 검색';

  @override
  String get settingsGeoSupportedOnly => '지원이 확인된 곳만';

  @override
  String get settingsGeoUnknown => '지원 여부 미확인';

  @override
  String get settingsGeoRestricted => '제한됨';

  @override
  String get settingsGeoSeparate => '별도 서비스';

  @override
  String get settingsGeoAvailable => '지원됨';

  @override
  String get settingsGeoNotApplicable => '해당 없음';

  @override
  String get settingsGeoConnection => 'Riot 연결';

  @override
  String get settingsGeoChooseRegion => '지역 선택';

  @override
  String get settingsGeoAuto => '계정 기준 자동';

  @override
  String get settingsGeoManual => '직접 선택';

  @override
  String get settingsGeoNoRegion => 'Riot 지역을 확인할 수 없습니다';

  @override
  String get settingsGeoManualWarning =>
      '이 설정은 ValHub가 연결하는 서버만 바꿉니다. Riot 계정의 지역은 이전되지 않습니다. ValHub는 저장 전에 연결을 확인합니다.';

  @override
  String get settingsGeoConnectionSaved => '연결 방식을 저장했습니다';

  @override
  String get settingsGeoValidationFailed =>
      '이 서버에서 계정을 확인할 수 없습니다. 지역을 다시 선택하세요.';

  @override
  String get settingsGeoHintOnly => '국가는 조회와 추천에만 사용됩니다. 연결 지역은 Riot 계정을 따릅니다.';

  @override
  String get settingsGeoSave => '확인 후 저장';

  @override
  String get settingsGeoCancel => '취소';

  @override
  String get settingsGeoLoading => '연결 확인 중…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      '이 설정은 국가 이름, 추천, 예상 VP 가격에 사용됩니다. 서버 연결과 커뮤니티 계정 국가는 여전히 Riot이 정합니다.';

  @override
  String get settingsGeoCountryAutomatic => '계정 또는 기기 국가 사용';

  @override
  String get settingsGeoSaveFailed => '선택을 저장하지 못했습니다. 다시 시도하세요.';

  @override
  String get settingsGeoAllRegions => '모든 지역';

  @override
  String get settingsGeoSuggestions => '추천';

  @override
  String get settingsGeoNoCountries => '필터와 일치하는 국가가 없습니다.';

  @override
  String get settingsGeoActiveCountries => '활동 중';

  @override
  String get settingsGeoAllCountries => '모든 국가';

  @override
  String get settingsGeoActivityUnavailable =>
      '국가별 활동을 불러오지 못했습니다. 모든 국가에서 선택할 수 있습니다.';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '국가 $count개',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return '$manual을(를) 선택했지만 Riot에서는 계정이 $detected에 있는 것으로 확인됩니다. 이 연결을 계속 확인할까요?';
  }

  @override
  String get settingsGeoUnverified =>
      '서버 또는 네트워크 문제로 연결을 확인하지 못했습니다. 이 설정을 저장하고 나중에 다시 시도할까요?';

  @override
  String get settingsGeoContinue => '계속';

  @override
  String settingsGeoMismatch(String region) {
    return '계정 서버($region)와 다른 서버를 선택했습니다. 계정 서버를 사용할까요?';
  }

  @override
  String get settingsGeoUseAuto => '자동 사용';

  @override
  String get settingsGeoKeepManual => '직접 선택 유지';

  @override
  String get settingsGeoReviewConnection => '연결 보기';

  @override
  String settingsGeoCheckedAt(String time) {
    return '마지막 확인: $time';
  }

  @override
  String get settingsGeoCheckAgain => '다시 확인';

  @override
  String get settingsPlatformMobile => '모바일';

  @override
  String get settingsPlatformOther => '기타 플랫폼';

  @override
  String get settingsContentLanguageFollowApp => '앱 언어와 동일';

  @override
  String get settingsContentLanguageHint =>
      '아이템 이름의 언어를 선택하세요. 앱 언어나 Riot 서버는 바뀌지 않습니다.';

  @override
  String settingsLanguageChanged(String language) {
    return '언어: $language.';
  }

  @override
  String get settingsAboutRowSubtitle => '개인정보, 약관, 저작권 및 문의';

  @override
  String get settingsAboutTitle => '정보 및 법적 고지';

  @override
  String get settingsAppearanceHeader => '화면';

  @override
  String settingsBuildNumber(String build) {
    return '빌드 $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return '$size 삭제됨';
  }

  @override
  String get settingsClearCache => '임시 데이터 삭제';

  @override
  String get settingsClearCacheFailed => '임시 데이터를 삭제하지 못했습니다. 다시 시도하세요.';

  @override
  String get settingsClearCacheSubtitle => '기기에 다운로드된 이미지와 데이터(기록된 오류 보고 포함)';

  @override
  String get settingsExportLog => 'ValHub에 오류 보고 보내기';

  @override
  String get settingsExportLogEmpty => '아직 보낼 내용이 없습니다. 앱을 잠시 사용한 후 다시 시도하세요.';

  @override
  String get settingsExportLogSubtitle =>
      '오류 보고에는 비밀번호나 Riot 로그인 데이터가 포함되지 않습니다.';

  @override
  String get settingsFeedback => 'ValHub에 의견 보내기';

  @override
  String get settingsFeedbackSubtitle => 'ValHub 의견 페이지 열기';

  @override
  String get settingsItemLanguageEn => '영어';

  @override
  String get settingsItemLanguageLabel => '아이템 이름';

  @override
  String get settingsItemLanguagePickerTitle => '아이템 이름 언어';

  @override
  String get settingsItemLanguageVi => '베트남어';

  @override
  String get settingsLinkOpenFailed => '링크를 열지 못했습니다. 다시 시도하세요.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — 오류 보고';
  }

  @override
  String get settingsLogShareFailed => '오류 보고를 보내지 못했습니다. 다시 시도하세요.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => '야시장이 열릴 때';

  @override
  String get settingsNotifNightMarketSubtitle => '야시장 할인 카드를 뒤집으라고 알려 줍니다';

  @override
  String get settingsNotifPermissionMissing => '앱에 알림 권한이 없습니다.';

  @override
  String get settingsNotifStoreReset => '상점이 초기화될 때';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return '매일 $time';
  }

  @override
  String get settingsNotifWishlist => '위시리스트의 스킨이 나올 때';

  @override
  String get settingsNotificationsHeader => '알림';

  @override
  String get settingsOptionAutoOpenLiveGame => '게임 정보 자동 열기';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      '게임이 잡히면 바로 현재 게임 패널을 엽니다';

  @override
  String get settingsOptionOwnPrice => '내 VP 패키지 가격';

  @override
  String get settingsOptionOwnPriceEmpty => '입력 안 함 — 가능한 경우 지역 가격표 사용';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => '플랫폼';

  @override
  String get settingsOptionShowLiveScore => '실시간 점수 표시';

  @override
  String get settingsOptionShowPeakRank => '게임 정보에 최고 랭크 표시';

  @override
  String get settingsOptionShowPrice => '예상 환산 가격 표시';

  @override
  String get settingsOptionShowPriceInfo => '환산 가격 계산 방법';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'VP 가격 옆에 표시, 예: $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      '아직 내 지역의 확인된 가격표가 없습니다 — VP 패키지 가격을 입력하세요.';

  @override
  String get settingsOptionsHeader => '옵션';

  @override
  String get settingsPhaseComplete => '완료';

  @override
  String get settingsPhaseInProgress => '진행 중';

  @override
  String get settingsPhaseScheduled => '예정됨';

  @override
  String settingsPlatformAppliesTo(String account) {
    return '$account에 적용';
  }

  @override
  String get settingsPlatformHint =>
      '올바른 전적을 보려면 플레이하는 곳에 맞춰 PC, PlayStation 또는 Xbox를 선택하세요.';

  @override
  String get settingsPlatformPickerTitle => '플랫폼 선택';

  @override
  String get settingsPrimingBody =>
      '알림을 켜면 상점이 초기화될 때와 위시리스트의 스킨이 나올 때 알 수 있습니다.';

  @override
  String get settingsPrimingEnable => '알림 켜기';

  @override
  String get settingsPrimingFootnote => '설정에서 언제든지 알림 유형별로 켜거나 끌 수 있습니다.';

  @override
  String get settingsPrimingLater => '나중에';

  @override
  String get settingsPrimingPointNightMarket => '야시장이 열리면 알림';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      '할인 카드가 만료되기 전에 뒤집을 수 있도록';

  @override
  String get settingsPrimingPointStore => '일일 상점 초기화 알림';

  @override
  String get settingsPrimingPointStoreDetail => '계정의 상점이 초기화되면 알려 줍니다';

  @override
  String get settingsPrimingPointWishlist => '노리는 스킨이 나오면 알림';

  @override
  String get settingsPrimingPointWishlistDetail => '앱을 열지 않아도 모든 계정의 상점을 확인합니다';

  @override
  String get settingsPrimingTitle => '노리는 스킨을 놓치지 마세요';

  @override
  String settingsRemovedAccount(String account) {
    return '$account 삭제됨';
  }

  @override
  String get settingsServerStatus => '서버 상태';

  @override
  String get settingsServerStatusMaintenance => '점검 중';

  @override
  String settingsServerStatusNotices(int n) {
    return '공지 $n개';
  }

  @override
  String get settingsServerStatusSubtitle => '서버별 VALORANT 점검 및 장애';

  @override
  String get settingsSessionLogTitle => 'ValHub 오류 보고';

  @override
  String get settingsSeverityCritical => '심각';

  @override
  String get settingsSeverityInfo => '정보';

  @override
  String get settingsSeverityWarning => '경고';

  @override
  String get settingsSignedOutAll => '모든 계정에서 로그아웃했습니다';

  @override
  String get settingsStatusAllGood => '서버가 정상적으로 운영 중입니다';

  @override
  String settingsStatusAllGoodBody(String region) {
    return '$region 서버에 장애나 점검이 없습니다.';
  }

  @override
  String get settingsStatusFewerUpdates => '접기';

  @override
  String get settingsStatusIssues => 'Riot에서 문제를 처리하고 있습니다';

  @override
  String settingsStatusIssuesBody(int n) {
    return '이 서버에 장애 공지가 $n개 있습니다.';
  }

  @override
  String get settingsStatusKindIncident => '장애';

  @override
  String get settingsStatusKindMaintenance => '점검';

  @override
  String get settingsStatusMaintenanceNow => '서버 점검 중';

  @override
  String get settingsStatusMaintenanceNowBody =>
      '지금은 게임에 접속하지 못할 수 있으며, ValHub에서도 일시적으로 정보를 불러오지 못할 수 있습니다.';

  @override
  String settingsStatusMoreUpdates(int n) {
    return '업데이트 $n개 더 보기';
  }

  @override
  String get settingsStatusScheduled => '점검 예정';

  @override
  String settingsStatusScheduledBody(int n) {
    return 'Riot에서 공지한 점검 일정 $n개.';
  }

  @override
  String get settingsStatusSourceNote =>
      '출처: Riot Games 공식 서버 상태 페이지. 시간은 기기의 시간대로 표시됩니다.';

  @override
  String settingsStatusStarted(String when) {
    return '시작: $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return '업데이트: $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'Riot 업데이트';

  @override
  String get settingsSupportHeader => '지원';

  @override
  String settingsSwitchedTo(String account) {
    return '$account(으)로 전환했습니다';
  }

  @override
  String get settingsThemeDark => '다크';

  @override
  String get settingsThemeLabel => '테마';

  @override
  String get settingsThemeLight => '라이트';

  @override
  String get settingsThemePickerTitle => '테마 선택';

  @override
  String get settingsThemeSystem => '시스템 설정';

  @override
  String get settingsTitle => '설정';

  @override
  String settingsVersion(String version) {
    return '버전 $version';
  }

  @override
  String get settingsWelcomeBulletProfile => '랭크, 전적, 진행 중인 게임';

  @override
  String get settingsWelcomeBulletProfileDetail => '게임별 RR, 상대 랭크';

  @override
  String get settingsWelcomeBulletStore => '일일 상점, 야시장, 번들';

  @override
  String get settingsWelcomeBulletStoreDetail => '가격, 희귀도, 초기화 카운트다운';

  @override
  String get settingsWelcomeBulletWishlist => '위시리스트 & 알림';

  @override
  String get settingsWelcomeBulletWishlistDetail => '노리는 스킨이 상점에 뜨면 알림';

  @override
  String get settingsWelcomeFootnote =>
      'Riot 공식 페이지에서 로그인합니다. ValHub는 로그인 정보 저장을 직접 선택한 경우에만 비밀번호를 저장합니다.';

  @override
  String get settingsWelcomeKicker => 'VALORANT 도우미';

  @override
  String get settingsCountryPriceHeader => '국가 및 가격';

  @override
  String get settingsDataHeader => '기기 데이터';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average (평가 $count개) · ',
      'other': '',
    });
    return '커뮤니티: $_temp0좋아요 $votes개';
  }

  @override
  String get skinDetailAddToWishlist => '위시리스트에 추가';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return '상점에 있는 계정: $accounts';
  }

  @override
  String get skinDetailHistoryDelete => '상점 기록 삭제';

  @override
  String get skinDetailHistoryDeleteBody => '이 기기에서 이 계정에 기록된 상점 날짜를 모두 삭제할까요?';

  @override
  String get skinDetailInWishlist => '위시리스트에 있음';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => '잠김';

  @override
  String get skinDetailMute => '음소거';

  @override
  String get skinDetailNotFound => '이 스킨을 찾을 수 없습니다.';

  @override
  String get skinDetailOwned => '보유 중';

  @override
  String get skinDetailPause => '일시정지';

  @override
  String get skinDetailPlay => '재생';

  @override
  String get skinDetailPlayVideo => '영상 보기';

  @override
  String get skinDetailRemoveFromWishlist => '위시리스트에서 삭제';

  @override
  String get skinDetailTitle => '스킨 정보';

  @override
  String get skinDetailUnmute => '음소거 해제';

  @override
  String get skinDetailUpgrades => '업그레이드';

  @override
  String get skinDetailVariants => '색상 변형';

  @override
  String get skinDetailVideoError => '영상을 재생할 수 없습니다. 네트워크를 확인하고 다시 시도하세요.';

  @override
  String skinDetailSeenDaily(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '내 상점에 $nString회 등장',
    );
    return '$_temp0';
  }

  @override
  String skinDetailSeenNight(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '야시장 $nString회',
    );
    return '$_temp0';
  }

  @override
  String get socialPresenceInMatch => '게임 중';

  @override
  String get socialPresenceAgentSelect => '요원 선택 중';

  @override
  String get socialPresenceQueue => '대기열';

  @override
  String get socialPresenceLobby => '대기실';

  @override
  String get socialPresenceCustom => '사용자 설정 게임 중';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': '공개 파티',
      'other': '초대 전용',
    });
    return '$size/$max명 · $_temp0';
  }

  @override
  String get socialAccept => '수락';

  @override
  String get socialAcceptInGame => '게임에서 이 초대를 수락하세요.';

  @override
  String socialActionFailed(String message) {
    return '작업을 완료하지 못했습니다. $message';
  }

  @override
  String get socialAutoRefresh => '자동 새로고침';

  @override
  String get socialAway => '자리 비움';

  @override
  String socialCancelQueue(String elapsed) {
    return '대기열 취소 · $elapsed';
  }

  @override
  String get socialCancelQueueShort => '대기열 취소';

  @override
  String socialCantQueue(String queue, String reason) {
    return '파티가 $queue 대기열에 참가할 수 없습니다: $reason';
  }

  @override
  String get socialChangeQueue => '대기열 변경';

  @override
  String get socialChatUnavailable => '채팅이 오프라인 상태입니다.';

  @override
  String get socialCloseParty => '파티 비공개';

  @override
  String get socialCodeInvalid => '파티 코드는 문자와 숫자로만 구성됩니다.';

  @override
  String get socialConnecting => '채팅 연결 중…';

  @override
  String get socialCopyCode => '복사';

  @override
  String get socialCurrentQueue => '선택됨';

  @override
  String get socialCustomGameLobby => '파티가 사용자 설정 게임 대기실에 있습니다.';

  @override
  String get socialDecline => '거절';

  @override
  String get socialDisableCode => '코드 비활성화';

  @override
  String get socialEmptyChat => '아직 메시지가 없습니다. 인사를 건네 보세요!';

  @override
  String get socialEmptyChatTitle => '채팅 시작';

  @override
  String get socialFailedBadge => '전송 실패';

  @override
  String get socialFilterAll => '전체';

  @override
  String get socialFilterOnline => '온라인';

  @override
  String get socialFilterUnread => '읽지 않음';

  @override
  String get socialFriendsPrivacyNote =>
      '친구 목록과 메시지는 Riot에서 직접 가져옵니다. ValHub는 다른 곳에 저장하지 않습니다.';

  @override
  String socialFriendsSummary(int total, int online) {
    return '친구 $total명 · $online명 온라인';
  }

  @override
  String get socialFriendsTitle => '친구 & 채팅';

  @override
  String get socialGameNotRunningBody =>
      '파티 & 대기열은 PC 또는 콘솔에서 VALORANT가 실행 중일 때만 작동합니다. 게임을 실행한 후 아래로 당겨 새로고침하세요.';

  @override
  String get socialGameNotRunningTitle => 'PC 또는 콘솔에서 VALORANT를 실행하세요';

  @override
  String get socialGenerateCode => '코드 생성';

  @override
  String get socialIdleQueue => '대기열 참가 준비 완료';

  @override
  String get socialInMatchBanner => '게임 중입니다. 게임이 끝나면 대기열이 다시 열립니다.';

  @override
  String get socialInValorant => 'VALORANT 접속 중';

  @override
  String get socialInviteByRiotId => 'Riot ID로 초대';

  @override
  String get socialInviteByRiotIdHint => '아직 친구가 아닌 플레이어도 초대';

  @override
  String get socialInviteFriends => '친구 초대';

  @override
  String socialInviteFrom(String name) {
    return '$name의 초대';
  }

  @override
  String socialInviteLabel(String name) {
    return '$name 초대';
  }

  @override
  String get socialInviteNeedsName => '이 플레이어의 Riot ID를 알 수 없어 아직 초대할 수 없습니다.';

  @override
  String socialInviteSent(String name) {
    return '$name에게 초대를 보냈습니다.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · 초대함';
  }

  @override
  String get socialInvitesSection => '초대';

  @override
  String get socialJoin => '참가';

  @override
  String get socialJoinConfirmBody => '현재 파티를 나가고 이 코드의 파티에 참가합니다.';

  @override
  String get socialJoinConfirmTitle => '다른 파티에 참가할까요?';

  @override
  String get socialJoinSection => '다른 파티 참가';

  @override
  String get socialJoinWithCode => '코드를 입력해 참가';

  @override
  String get socialJoined => '파티에 참가했습니다.';

  @override
  String socialLastOnline(String relative) {
    return '$relative 활동';
  }

  @override
  String get socialLeader => '파티장';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody => '현재 파티를 나가 혼자 있는 파티로 돌아갑니다.';

  @override
  String get socialLeaveConfirmTitle => '파티를 나갈까요?';

  @override
  String get socialLeaveParty => '파티 나가기';

  @override
  String socialLevel(int n) {
    return '레벨 $n';
  }

  @override
  String get socialMatchFound => '게임을 찾았습니다!';

  @override
  String socialMembersSection(int n, int max) {
    return '파티원 ($n/$max)';
  }

  @override
  String get socialMessageHint => '메시지 입력…';

  @override
  String get socialMoreActions => '더 보기';

  @override
  String get socialNoCode => '코드를 생성하면 친구가 코드로 빠르게 파티에 참가할 수 있습니다.';

  @override
  String get socialNoCodeMember => '파티장이 빠른 초대용 코드를 생성할 수 있습니다.';

  @override
  String get socialNoFilterResults => '이 필터와 일치하는 친구가 없습니다.';

  @override
  String get socialNoFriends => 'Riot 친구 목록이 비어 있습니다. 게임에서 친구를 추가하세요.';

  @override
  String get socialNoFriendsTitle => '아직 친구 없음';

  @override
  String get socialNoOnlineFriends => '현재 VALORANT에 온라인인 친구가 없습니다.';

  @override
  String get socialNoSearchResults => '일치하는 친구가 없습니다.';

  @override
  String get socialNoSearchResultsTitle => '결과 없음';

  @override
  String get socialNotReady => '준비 안 됨';

  @override
  String socialOfflineSection(int n) {
    return '오프라인 ($n)';
  }

  @override
  String get socialOfflineStatus => '오프라인';

  @override
  String get socialOnlineMobile => '모바일에서 온라인';

  @override
  String socialOnlineSection(int n) {
    return '온라인 ($n)';
  }

  @override
  String get socialOnlineStatus => '온라인';

  @override
  String get socialOnlyLeader => '파티장만 대기열을 변경하고 매치메이킹을 시작할 수 있습니다.';

  @override
  String get socialOpenParty => '파티 공개';

  @override
  String get socialOtherGamesLeagueOfLegends => '리그 오브 레전드';

  @override
  String get socialOtherGamesBacon => '레전드 오브 룬테라';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => '파티 코드';

  @override
  String socialPartyCodeValue(String code) {
    return '파티 코드: $code';
  }

  @override
  String get socialPartyInvite => '파티 초대';

  @override
  String socialPartyOf(int size, int max) {
    return '파티 $size/$max';
  }

  @override
  String get socialPartyTitle => '파티 & 대기열';

  @override
  String socialPickQueueSubtitle(int size) {
    return '$size인 파티';
  }

  @override
  String get socialPickQueueTitle => '대기열 선택';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => '게임 서버까지의 최저 핑';

  @override
  String socialPlayingOther(String game) {
    return '$game 플레이 중';
  }

  @override
  String socialPlayingSection(int n) {
    return '플레이 중 ($n)';
  }

  @override
  String get socialQueueLabel => '대기열';

  @override
  String get socialQueueLocked => '게임 중에는 대기열을 변경할 수 없습니다.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: '최대 $max명',
      one: '솔로 전용',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      '게임 상태를 확인하지 못했습니다. 준비와 대기열을 사용하려면 새로고침하세요.';

  @override
  String get socialReady => '준비';

  @override
  String socialReadyCount(int ready, int total) {
    return '준비 $ready/$total';
  }

  @override
  String get socialReasonAccountLevel => '계정 레벨이 부족한 파티원이 있습니다';

  @override
  String get socialReasonGeneric => '파티가 아직 조건을 충족하지 않습니다';

  @override
  String socialReasonPartyTooLarge(int max) {
    return '파티 인원이 너무 많습니다(최대 $max명)';
  }

  @override
  String get socialReasonRankDisparity => '경쟁전을 하기에는 랭크 차이가 너무 큽니다';

  @override
  String socialReasonRestricted(String time) {
    return '파티가 대기열 제한 상태입니다($time 남음)';
  }

  @override
  String get socialReconnecting => '채팅 연결이 끊겼습니다. 다시 연결하는 중…';

  @override
  String get socialRemoteNote =>
      '모든 변경 사항은 직접 탭할 때만 Riot에 전송됩니다. ValHub는 대신 대기열에 참가하거나 요원을 확정하지 않습니다.';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name이(가) 파티에서 제외됩니다.';
  }

  @override
  String get socialRemoveConfirmTitle => '파티에서 제외할까요?';

  @override
  String get socialRemoveMember => '파티에서 제외';

  @override
  String socialRequestFrom(String name) {
    return '$name이(가) 파티 참가를 원합니다';
  }

  @override
  String get socialRequestsSection => '참가 요청';

  @override
  String get socialRiotIdFieldHint => '이름#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Riot ID는 이름(3–16자), # 기호, 태그(문자 또는 숫자 3–5자)로 구성됩니다.';

  @override
  String get socialSearchHint => 'Riot ID로 검색…';

  @override
  String socialSearching(String elapsed) {
    return '대기열 · $elapsed';
  }

  @override
  String get socialSend => '보내기';

  @override
  String get socialSendFailed => '메시지를 보내지 못했습니다. 연결을 확인하고 다시 시도하세요.';

  @override
  String get socialSendInvite => '초대 보내기';

  @override
  String get socialShareCode => '공유';

  @override
  String socialShareCodeText(String code) {
    return '코드로 내 VALORANT 파티에 참가하세요: $code';
  }

  @override
  String get socialShootingRange => '사격장';

  @override
  String get socialShowEveryone => '모두 보기';

  @override
  String get socialStartQueue => '대기열 시작';

  @override
  String get socialSuggestionsItem0 => '안녕하세요!';

  @override
  String get socialSuggestionsItem1 => '몇 판 같이 할래요?';

  @override
  String get socialSuggestionsItem2 => '제 파티에 들어오세요!';

  @override
  String socialUnread(int n) {
    return '읽지 않은 메시지 $n개';
  }

  @override
  String get socialUnready => '준비 취소';

  @override
  String get socialViewProfile => '프로필 보기';

  @override
  String get socialWaitingForConnection => '연결 중… 연결되면 메시지를 보낼 수 있습니다.';

  @override
  String get socialYou => '나';

  @override
  String get socialPartyUnavailable => '파티를 동기화하지 못했습니다. 새로고침하여 다시 시도하세요.';

  @override
  String get socialAcceptConfirmBody => '현재 파티를 나가고 초대한 파티에 참가합니다.';

  @override
  String get storeAccessoryEmpty => '현재 액세서리 상점에 아무것도 없습니다.';

  @override
  String get storeAccessoryEmptyTitle => '액세서리 없음';

  @override
  String storeAccessoryFrom(String contract) {
    return '출처: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return '초기화까지 $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return '$wall 초기화';
  }

  @override
  String get storeAddToWishlist => '위시리스트에 추가';

  @override
  String get storeBackToBundles => '판매 중인 번들 보기';

  @override
  String get storeBundleBuySeparateLabel => '개별 구매';

  @override
  String get storeBundleDetailTitle => '번들 정보';

  @override
  String storeBundleEndsAt(String wall) {
    return '$wall 종료';
  }

  @override
  String storeBundleEndsIn(String t) {
    return '$t 남음';
  }

  @override
  String storeBundleItemCount(int n) {
    return '아이템 $n개';
  }

  @override
  String get storeBundleItemFree => '무료';

  @override
  String get storeBundleItemsTitle => '번들 구성품';

  @override
  String get storeBundleNotFound => '이 번들을 찾을 수 없습니다. 판매가 종료되었을 수 있습니다.';

  @override
  String get storeBundleNotFoundTitle => '번들 판매 종료';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return '아이템 $owned/$total개 보유';
  }

  @override
  String get storeBundlePriceLabel => '번들 가격';

  @override
  String get storeBundleSavingsLabel => '절약';

  @override
  String get storeBundleWholesaleOnly => '번들로만 판매되며 개별 구매는 불가합니다.';

  @override
  String get storeBundlesEmpty => '현재 판매 중인 번들이 없습니다.';

  @override
  String get storeBundlesEmptyTitle => '번들 없음';

  @override
  String get storeDailyEmpty => '오늘은 상점에 스킨이 없습니다.';

  @override
  String get storeDailyEmptyTitle => '상점이 비어 있습니다';

  @override
  String storeDailyResetAt(String time) {
    return '매일 $time에 초기화';
  }

  @override
  String get storeDailyTotalLabel => '합계';

  @override
  String get storeNightMarketEmpty => '현재 야시장이 열려 있지 않습니다.';

  @override
  String get storeNightMarketEmptyTitle => '야시장 미개장';

  @override
  String storeNightMarketEndsAt(String wall) {
    return '$wall 종료';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return '종료까지 $t';
  }

  @override
  String get storeNightMarketNote => '야시장 할인은 내 계정에만 제공되며 새로고침할 수 없습니다.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return '총 $amount 절약';
  }

  @override
  String get storeNightMarketUnrevealed => '뒤집지 않음';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => '보유 중';

  @override
  String storeOwnedCount(int owned, int total) {
    return '$owned/$total 보유';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => '위시리스트에서 삭제';

  @override
  String get storeResetNotificationTitle => '상점이 초기화되었습니다';

  @override
  String storeResetsIn(String t) {
    return '초기화까지 $t';
  }

  @override
  String get storeSegmentAccessories => '액세서리';

  @override
  String get storeSegmentBundles => '번들';

  @override
  String get storeSegmentDaily => '일일';

  @override
  String get storeSegmentNightMarket => '야시장';

  @override
  String get storeShareButton => '공유';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => '오늘의 상점';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => '야시장';

  @override
  String get storeShareCardPriceNote => '환산 가격은 VP 패키지 기준 예상치일 뿐입니다.';

  @override
  String storeShareCardSaved(String vp) {
    return '$vp 절약';
  }

  @override
  String get storeShareCardTagline => '나만의 VALORANT 도우미';

  @override
  String storeShareCardTotal(String vp) {
    return '합계 $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return '$wall까지';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => '오늘의 상점 공유';

  @override
  String get storeShareFailed => '이미지를 만들지 못했습니다. 다시 시도하세요.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => '이미지 공유';

  @override
  String get storeShareNightMarketTitle => '야시장 공유';

  @override
  String get storeSharePreparing => '스킨 이미지 불러오는 중…';

  @override
  String get storeShareShowPrice => '예상 환산 가격 표시';

  @override
  String get storeShareShowPriceHint => '가장 유리한 VP 패키지 기준으로 환산합니다.';

  @override
  String get storeShareShowRiotId => '이미지에 Riot ID 표시';

  @override
  String get storeShareShowRiotIdHint => '개인정보 보호를 위해 기본적으로 꺼져 있습니다.';

  @override
  String get storeShareSubjectDaily => '오늘의 내 VALORANT 상점';

  @override
  String get storeShareSubjectNightMarket => '내 VALORANT 야시장';

  @override
  String get storeShareSubtitle => '원하는 앱으로 친구에게 상점 이미지를 공유하세요.';

  @override
  String get storeTitle => '상점';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return '잔액: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return '위시리스트 $n개';
  }

  @override
  String get storeHistoryTitle => '상점 기록';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString일',
    );
    return '$date부터 이 기기에서 기록 · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      '아직 기록된 날이 없습니다. ValHub는 앱을 열 때마다 일일 상점을 이 기기에만 저장합니다.';

  @override
  String get storeHistoryMostOffered => '가장 자주 등장';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString회',
    );
    return '$_temp0';
  }

  @override
  String storeHistoryNightMarket(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '야시장 · 할인 $countString개',
    );
    return '$_temp0';
  }

  @override
  String storeHistoryEntrySubtitle(int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '이 기기에서 $daysString일 기록됨',
      zero: '오늘부터 기록 시작',
    );
    return '$_temp0';
  }

  @override
  String wishlistNotifDailyBody(
    String skin,
    String account,
    String hasTime,
    String left,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasTime, {
      'yes': '$skin이(가) $account의 상점에 있습니다 — $left 남음.',
      'other': '$skin이(가) $account의 상점에 있습니다.',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifNightMarketBody(
    String skin,
    String mode,
    String percent,
    String price,
    String account,
  ) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'discount': '$skin $percent% 할인, 현재 $price ($account).',
      'price': '$skin 단 $price ($account).',
      'other': '$skin이(가) $account의 야시장에 있습니다.',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifBundleBody(
    String skin,
    String hasName,
    String bundle,
    String account,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasName, {
      'yes': '$skin이(가) $bundle 번들에 포함되어 있습니다 ($account).',
      'other': '$skin이(가) 판매 중인 번들에 포함되어 있습니다 ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: '$account의 상점에 지금 있음: $names 외 스킨 $more개.',
      zero: '$account의 상점에 지금 있음: $names.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', 위시리스트에 있음',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => '스킨 추가';

  @override
  String get wishlistAddToWishlist => '위시리스트에 추가';

  @override
  String get wishlistAllWeapons => '모든 무기';

  @override
  String get wishlistBrowseCatalog => '모든 스킨 보기';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '스킨 $countString개';
  }

  @override
  String get wishlistCatalogEmpty => '스킨 목록을 불러오지 못했습니다. 새로고침하여 다시 시도하세요.';

  @override
  String get wishlistCatalogEmptyTitle => '스킨 없음';

  @override
  String wishlistCatalogInWishlist(String count) {
    return '위시리스트 $count개';
  }

  @override
  String get wishlistCatalogSubtitle => '♡를 탭하여 스킨을 위시리스트에 추가하세요';

  @override
  String get wishlistCatalogTitle => '모든 스킨';

  @override
  String get wishlistChooseWeapon => '무기 선택';

  @override
  String get wishlistClearFilters => '필터 해제';

  @override
  String get wishlistEmpty => '위시리스트가 비어 있습니다. 아무 스킨에서나 ♡를 탭하여 추가하세요.';

  @override
  String get wishlistEmptyTitle => '아직 스킨 없음';

  @override
  String wishlistEndsIn(String time) {
    return '종료까지 $time';
  }

  @override
  String get wishlistExcludedRewards => '보상 스킨 제외';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '필터 적용: 스킨 $countString개 · $value';
  }

  @override
  String get wishlistNoMatch => '일치하는 스킨이 없습니다. 필터를 해제하면 더 볼 수 있습니다.';

  @override
  String get wishlistNoMatchTitle => '스킨을 찾을 수 없음';

  @override
  String get wishlistNotifBundleTitle => '새 번들에 위시리스트 스킨이 있습니다';

  @override
  String get wishlistNotifDailyTitle => '위시리스트 스킨이 나왔습니다!';

  @override
  String get wishlistNotifNightMarketTitle => '야시장에 원하는 스킨이 있습니다!';

  @override
  String get wishlistNotifPermissionMissing => '앱에 알림 권한이 없습니다.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    return '위시리스트 스킨 $count개가 판매 중입니다!';
  }

  @override
  String get wishlistNotifToggle => '위시리스트 알림';

  @override
  String get wishlistNotifToggleSubtitle => '앱을 열지 않아도 이 계정에 적용';

  @override
  String wishlistOfAccount(String riotId) {
    return '$riotId의 위시리스트';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '위시리스트 스킨 $count개가 판매 중입니다!',
      one: '위시리스트 스킨 1개가 판매 중입니다!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint => '표시된 항목을 탭하여 할인 정보를 확인하세요.';

  @override
  String get wishlistOpenSettings => '설정 열기';

  @override
  String get wishlistOwned => '보유 중';

  @override
  String get wishlistRemoveAction => '위시리스트에서 삭제';

  @override
  String get wishlistRemoveFromWishlist => '위시리스트에서 삭제';

  @override
  String wishlistRemoved(String name) {
    return '위시리스트에서 $name을(를) 삭제했습니다';
  }

  @override
  String get wishlistSearchHint => '스킨 검색…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '스킨 $countString개';
  }

  @override
  String get wishlistSortName => '이름';

  @override
  String get wishlistSortPrice => '가격';

  @override
  String get wishlistSortRarity => '희귀도';

  @override
  String get wishlistSortWeapon => '무기';

  @override
  String get wishlistTitle => '위시리스트';

  @override
  String get wishlistTotalValue => '위시리스트 총 가치';

  @override
  String get wishlistUndo => '실행 취소';

  @override
  String get wishlistViewInStore => '상점에서 보기';

  @override
  String get wishlistWeapon => '무기';

  @override
  String get homeLiveScoreSeparator => 'VS';

  @override
  String homeOfferAccessibility(
    String name,
    String price,
    String tier,
    String wished,
  ) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', 위시리스트에 있음',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', 위시리스트에 있음',
      'other': '',
    });
    return '$name, $votes$_temp0';
  }

  @override
  String homeTodayRankAccessibility(
    String direction,
    int rr,
    int wins,
    int losses,
  ) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'gain': '상승',
      'other': '하락',
    });
    return '오늘 $rr RR $_temp0, $wins승, $losses패';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', $draws무',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', 결과 미확인 $unknown판',
      zero: '',
    );
    return '$wins승 – $losses패$_temp0$_temp1';
  }

  @override
  String get homeAllHiddenBody => '홈 화면 설정을 열어 다시 표시하세요.';

  @override
  String get homeAllHiddenTitle => '모든 카드를 숨겼습니다';

  @override
  String get homeCardBattlePass => 'Battle Pass';

  @override
  String get homeCardBattlePassDesc => '레벨, 하루에 필요한 XP, 주간 임무.';

  @override
  String get homeCardCommunity => '커뮤니티';

  @override
  String get homeCardCommunityDesc => '내 랭크에 맞는 팀원 찾기와 커뮤니티가 가장 좋아하는 스킨.';

  @override
  String get homeCardFriends => '플레이 중인 친구';

  @override
  String get homeCardFriendsDesc => '게임 중이거나 대기열에 있는 친구.';

  @override
  String homeCardHidden(String name) {
    return '\"$name\" 숨김';
  }

  @override
  String get homeCardLive => '현재 게임';

  @override
  String get homeCardLiveDesc => '대기열, 요원 선택, 게임 중일 때 표시됩니다.';

  @override
  String get homeCardOtherAccounts => '다른 계정';

  @override
  String get homeCardOtherAccountsDesc => '다른 계정의 상태와 위시리스트.';

  @override
  String get homeCardRank => '랭크 & 폼';

  @override
  String get homeCardRankDesc => '랭크, 오늘의 RR, 연승/연패, 랭크업까지 필요한 게임 수.';

  @override
  String get homeCardServerStatus => '서버 상태';

  @override
  String get homeCardServerStatusDesc => '점검 또는 장애가 있을 때만 표시됩니다.';

  @override
  String get homeCardStore => '오늘의 상점';

  @override
  String get homeCardStoreDesc => '일일 스킨, 위시리스트, 야시장.';

  @override
  String get homeCustomize => '홈 화면 설정';

  @override
  String get homeCustomizeHint => '끌어서 순서를 바꾸세요. 끄면 카드가 숨겨집니다.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return '$name(으)로 이동했습니다';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => '켜기';

  @override
  String get homeFriendsConsentBody =>
      '플레이 중인 친구를 확인하기 위해 ValHub는 홈을 열 때마다 현재 계정의 Riot 채팅에 연결합니다. 친구에게 내가 온라인으로 표시됩니다. 홈 화면 설정에서 끌 수 있습니다.';

  @override
  String get homeFriendsConsentDecline => '아니요, 카드 숨기기';

  @override
  String get homeFriendsConsentTitle => '플레이 중인 친구를 볼까요?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    return '친구 $n명 플레이 중';
  }

  @override
  String get homeFriendsSeeAll => '모두 보기';

  @override
  String get homeHideCard => '이 카드 숨기기';

  @override
  String homeLeaderboard(String pos) {
    return '리더보드 $pos위';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return '$time 남음';
  }

  @override
  String homeLfgNeeds(int n) {
    return '$n명 구함';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => '내 랭크에 맞는 팀원 찾기';

  @override
  String get homeLiveAllyLabel => '우리 팀';

  @override
  String get homeLiveEnemyLabel => '적 팀';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return '대기열, $coarse 대기 중';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return '우리 팀 $ally, 적 팀 $enemy';
  }

  @override
  String homeLossStreak(int n) {
    return '경쟁전 $n연패';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    return '$rank까지 ≈ $n판';
  }

  @override
  String homeMoreActions(String name) {
    return '$name 옵션';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return '$riotId의 상점, 랭크, Battle Pass를 업데이트하려면 다시 로그인하세요. 기기에 저장된 정보는 계속 볼 수 있습니다.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return '$time 남음';
  }

  @override
  String get homeNightMarketNew => '새로움';

  @override
  String get homeNightMarketTitle => '야시장';

  @override
  String homeNightMarketWaiting(int n) {
    return '뒤집기를 기다리는 할인 $n개';
  }

  @override
  String get homeNoRankedToday => '오늘 경쟁전 게임 없음';

  @override
  String get homeOpenLfg => '팀원 찾기 글 모두 보기';

  @override
  String get homeOpenRanking => '스킨 순위 보기';

  @override
  String homeOtherAccountsTitle(int n) {
    return '다른 계정 ($n)';
  }

  @override
  String homeOtherMore(int n) {
    return '+$n개 계정';
  }

  @override
  String get homeOtherWishlistHit => '위시리스트 스킨 있음';

  @override
  String homePreviousAct(String rank) {
    return '이전 액트: $rank';
  }

  @override
  String get homeQuietBody => '아래로 당겨 새로고침하세요.';

  @override
  String get homeQuietTitle => '아직 새로운 소식 없음';

  @override
  String homeRankToNext(int rr) {
    return '랭크업까지 $rr RR';
  }

  @override
  String get homeResetLayout => '기본값으로 복원';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return '오늘 $value';
  }

  @override
  String get homeStatusDetails => '자세히';

  @override
  String homeStatusIncident(String region) {
    return '서버 장애 · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return '점검 중 · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return '점검 예정 · $region';
  }

  @override
  String homeStatusMore(int n) {
    return '+공지 $n개';
  }

  @override
  String get homeStoreRefreshing => '새로고침 중…';

  @override
  String homeStoreResetsIn(String time) {
    return '초기화까지 $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return '합계 $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return '지갑 $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    return '지갑 $vp · 최대 스킨 $n개 구매 가능';
  }

  @override
  String get homeStoreWishlistHit => '위시리스트 스킨이 상점에 있습니다!';

  @override
  String homeStoreWishlistHits(int n) {
    return '위시리스트 스킨 $n개 판매 중';
  }

  @override
  String get homeTitle => '홈';

  @override
  String get homeTrendingTitle => '전 세계 인기 스킨';

  @override
  String homeTrendingVotes(int n) {
    return '좋아요 $n개';
  }

  @override
  String get homeUndo => '실행 취소';

  @override
  String homeWinStreak(int n) {
    return '경쟁전 $n연승';
  }

  @override
  String get homeStoreOutdated => '상점이 바뀌었습니다. ValHub가 아직 새 상점을 불러오지 못했습니다.';

  @override
  String get homeOfflineTitle => '오프라인 상태';

  @override
  String get homeOfflineBody =>
      '기기에 저장된 데이터를 표시하고 있습니다. 다시 연결되면 ValHub가 자동으로 업데이트합니다.';

  @override
  String get homeCardOffline => '연결되면 표시됩니다.';

  @override
  String get communityErrorConsent => '계속하려면 커뮤니티와 Riot ID 공유에 동의하세요.';

  @override
  String get communityErrorForbidden =>
      '아직 이 작업을 할 수 없습니다. 커뮤니티 가이드라인을 확인하거나 ValHub에 문의하세요.';

  @override
  String get communityErrorGeneric => '문제가 발생했습니다. 다시 시도하세요.';

  @override
  String get communityErrorImageTooLarge =>
      '이미지가 너무 큽니다(최대 2 MB). 다른 이미지를 선택하세요.';

  @override
  String get communityErrorImageType => 'JPEG, PNG 또는 WebP 이미지를 선택하세요.';

  @override
  String get communityErrorInvalid => '콘텐츠가 승인되지 않았습니다. 확인한 후 다시 시도하세요.';

  @override
  String get communityErrorNetwork =>
      'ValHub 커뮤니티에 연결할 수 없습니다. 네트워크를 확인하고 다시 시도하세요.';

  @override
  String get communityErrorNotFound => '더 이상 존재하지 않는 콘텐츠입니다.';

  @override
  String get communityErrorPickImage => '사진 보관함을 열지 못했습니다. 다시 시도하세요.';

  @override
  String get communityErrorRateLimited => '커뮤니티에 요청이 너무 많습니다. 잠시 후 다시 시도하세요.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return '커뮤니티에 요청이 너무 많습니다. $duration 후 다시 시도하세요.';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot에서 계정을 확인하지 못했습니다. Riot 계정에 다시 로그인한 후 시도하세요.';

  @override
  String get communityErrorRiotUnavailable =>
      'Riot 서비스에 문제가 있습니다. 잠시 후 다시 시도하세요.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot 서비스에 문제가 있습니다. $duration 후 다시 시도하세요.';
  }

  @override
  String get communityErrorServer => 'ValHub 커뮤니티에 문제가 있습니다. 잠시 후 다시 시도하세요.';

  @override
  String get communityErrorStorageFull =>
      '커뮤니티 사진 저장 공간이 가득 찼습니다. 게시물은 작성할 수 있지만 지금은 사진을 첨부할 수 없습니다. 나중에 다시 시도하세요.';

  @override
  String get communityErrorTimeout => 'ValHub 커뮤니티 응답이 너무 늦습니다. 다시 시도하세요.';

  @override
  String get communityErrorTitle => '완료하지 못함';

  @override
  String get communityErrorUnauthorized => '커뮤니티 연결이 만료되었습니다. 다시 시도하세요.';

  @override
  String get communityErrorImageQuota =>
      '이미지 저장 공간을 모두 사용했습니다. 이미지가 있는 게시물을 일부 삭제한 뒤 다시 시도하세요.';

  @override
  String get smokePlain => '코드 생성 확인';

  @override
  String smokeGreeting(String name) {
    return '안녕하세요, $name님!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n개 항목',
    );
    return '$_temp0';
  }
}
