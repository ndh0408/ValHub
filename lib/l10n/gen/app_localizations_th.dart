// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'ดูแหล่งที่มาของตารางราคา';

  @override
  String get commonErrorApi => 'Riot กำลังมีปัญหา ลองอีกครั้งในอีกสักครู่';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonBack => 'ย้อนกลับ';

  @override
  String get commonCancel => 'ยกเลิก';

  @override
  String get commonClearFilters => 'ล้างตัวกรอง';

  @override
  String get commonClearSearch => 'ล้างการค้นหา';

  @override
  String get commonClose => 'ปิด';

  @override
  String get commonConfirm => 'ยืนยัน';

  @override
  String get commonCopied => 'คัดลอกแล้ว';

  @override
  String get commonCopy => 'คัดลอก';

  @override
  String get commonDaily => 'รายวัน';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    return '$n วัน';
  }

  @override
  String commonDaysAgo(int n) {
    return '$n วันที่แล้ว';
  }

  @override
  String get commonDelete => 'ลบ';

  @override
  String get commonDone => 'เสร็จสิ้น';

  @override
  String get commonEmptyGeneric => 'ยังไม่มีอะไรที่นี่';

  @override
  String get commonErrorContentUnavailable =>
      'โหลดข้อมูลสกิน เอเจนท์ และแผนที่ไม่ได้ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get commonErrorGeneric => 'เกิดข้อผิดพลาดบางอย่าง ลองอีกครั้ง';

  @override
  String get commonErrorMaintenance =>
      'เซิร์ฟเวอร์ VALORANT กำลังปิดปรับปรุง กลับมาใหม่ภายหลัง';

  @override
  String get commonErrorNeedsLogin =>
      'การเข้าสู่ระบบ Riot ของคุณหมดอายุแล้ว เข้าสู่ระบบอีกครั้งเพื่อดำเนินการต่อ';

  @override
  String get commonErrorNeedsLoginTitle => 'เข้าสู่ระบบอีกครั้ง';

  @override
  String get commonErrorNetwork =>
      'ไม่มีการเชื่อมต่อ ตรวจสอบ Wi-Fi หรืออินเทอร์เน็ตมือถือแล้วลองอีกครั้ง';

  @override
  String get commonErrorNoAccount => 'คุณยังไม่ได้เข้าสู่ระบบบัญชีใด';

  @override
  String get commonErrorNotFound => 'ไม่พบเนื้อหานี้';

  @override
  String get commonErrorTimeout =>
      'Riot ตอบสนองช้าเกินไป ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get commonErrorTransient =>
      'Riot ไม่ว่างในขณะนี้ ลองอีกครั้งในอีกสักครู่';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot ไม่ว่างในขณะนี้ ลองอีกครั้งใน $duration';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'ระบุภูมิภาค Riot ของคุณไม่ได้ เลือกภูมิภาคในการตั้งค่า';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonFilter => 'กรอง';

  @override
  String get commonGoHome => 'ไปที่หน้าหลัก';

  @override
  String commonHours(int n) {
    return '$n ชั่วโมง';
  }

  @override
  String commonHoursAgo(int n) {
    return '$n ชั่วโมงที่แล้ว';
  }

  @override
  String get commonIncidentTitle => 'เซิร์ฟเวอร์มีปัญหา';

  @override
  String get commonJustNow => 'เมื่อสักครู่';

  @override
  String get commonLoadMore => 'โหลดเพิ่ม';

  @override
  String get commonLoading => 'กำลังโหลด…';

  @override
  String get commonMaintenanceTitle => 'ปิดปรับปรุงเซิร์ฟเวอร์';

  @override
  String commonMinutes(int n) {
    return '$n นาที';
  }

  @override
  String commonMinutesAgo(int n) {
    return '$n นาทีที่แล้ว';
  }

  @override
  String get commonNoData => 'ยังไม่มีอะไรให้ดู';

  @override
  String commonOfflineCached(String time) {
    return 'ออฟไลน์อยู่ — กำลังแสดงข้อมูลที่บันทึกไว้ ($time)';
  }

  @override
  String get commonOk => 'ตกลง';

  @override
  String get commonOpenSettings => 'เปิดการตั้งค่า';

  @override
  String get commonPageNotFound => 'ไม่พบหน้าจอนี้';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'แพ็กคุ้มที่สุด: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'แก้ไขราคาที่คุณกรอก';

  @override
  String get commonPriceEnterOwn => 'กรอกราคาแพ็ก VP ของคุณ';

  @override
  String get commonPriceEstimateBody =>
      'จำนวนเงิน “≈ …” ข้างราคา VP เป็นราคาประมาณ คำนวณจากแพ็ก VP ที่คุ้มที่สุด คุณจ่ายด้วย VP ในเกม ส่วนจำนวนเงินจริงขึ้นอยู่กับแพ็กที่เติม ช่องทางชำระเงิน ภาษี และโปรโมชันในตอนที่ซื้อ';

  @override
  String get commonPriceEstimateTitle => 'ราคาประมาณ';

  @override
  String get commonPriceEstimateTooltip => 'ราคาประมาณ — แตะเพื่อดูวิธีคำนวณ';

  @override
  String get commonPriceHidden =>
      'ซ่อนราคาประมาณแล้ว เปิดอีกครั้งได้ในการตั้งค่า';

  @override
  String get commonPriceHide => 'ซ่อนราคาประมาณ';

  @override
  String get commonPriceOpenSource => 'เปิดหน้าแหล่งที่มา';

  @override
  String get commonPriceOverrideBody =>
      'กรอกจำนวนเงินที่คุณจ่ายจริงสำหรับแพ็ก VP หนึ่งแพ็ก (ดูได้ในร้านค้าในเกมหรือใบเสร็จ) ValHub ใช้ราคานี้ประมาณราคาของไอเทมทุกชิ้น และบันทึกราคาไว้ในอุปกรณ์นี้เท่านั้น';

  @override
  String get commonPriceOverrideCurrency => 'รหัสสกุลเงิน';

  @override
  String get commonPriceOverrideCurrencyHint => 'เช่น THB, USD, EUR, JPY';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'ตัวอย่างราคาประมาณ: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'กรอกรหัสสกุลเงิน 3 ตัวอักษร เช่น THB หรือ USD';

  @override
  String get commonPriceOverrideInvalidNumber => 'กรอกตัวเลขที่มากกว่า 0';

  @override
  String get commonPriceOverridePrice => 'ราคาแพ็ก';

  @override
  String get commonPriceOverrideRemove => 'ลบราคาที่กรอก';

  @override
  String get commonPriceOverrideRemoved => 'ลบราคาที่คุณกรอกแล้ว';

  @override
  String get commonPriceOverrideSave => 'บันทึกราคา';

  @override
  String get commonPriceOverrideSaved => 'บันทึกราคาแพ็ก VP ของคุณแล้ว';

  @override
  String get commonPriceOverrideTitle => 'ราคาแพ็ก VP ของคุณ';

  @override
  String get commonPriceOverrideVp => 'จำนวน VP ในแพ็ก';

  @override
  String get commonPricePacksTitle => 'แพ็ก VP';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'อ้างอิงราคาแพ็ก VP ในภูมิภาค $country';
  }

  @override
  String get commonPriceSourceUser => 'อ้างอิงราคาแพ็ก VP ที่คุณกรอก';

  @override
  String get commonPriceUnavailable =>
      'ยังไม่มีตารางราคาที่ยืนยันแล้วสำหรับภูมิภาคของคุณ กรอกราคาแพ็ก VP ที่คุณเคยซื้อเพื่อดูราคาประมาณ';

  @override
  String commonPriceUpdated(String date) {
    return 'อัปเดตตารางราคา: $date';
  }

  @override
  String get commonPullToRefresh => 'ดึงลงเพื่อรีเฟรช';

  @override
  String get commonRefresh => 'รีเฟรช';

  @override
  String get commonRetry => 'ลองอีกครั้ง';

  @override
  String get commonRiotDisclaimer =>
      'ValHub ไม่ได้รับการรับรองจาก Riot Games และไม่ได้สะท้อนมุมมองหรือความคิดเห็นของ Riot Games หรือผู้ใดที่มีส่วนร่วมอย่างเป็นทางการในการผลิตหรือดูแลผลิตภัณฑ์ของ Riot Games โดย Riot Games และทรัพย์สินที่เกี่ยวข้องทั้งหมดเป็นเครื่องหมายการค้าหรือเครื่องหมายการค้าจดทะเบียนของ Riot Games, Inc.';

  @override
  String get commonSave => 'บันทึก';

  @override
  String get commonSearch => 'ค้นหา…';

  @override
  String commonSeconds(int n) {
    return '$n วินาที';
  }

  @override
  String get commonSeeAll => 'ดูทั้งหมด';

  @override
  String get commonShare => 'แชร์';

  @override
  String get commonSignInAgain => 'เข้าสู่ระบบอีกครั้ง';

  @override
  String get commonSort => 'เรียงลำดับ';

  @override
  String commonSortBy(String option) {
    return 'เรียง: $option';
  }

  @override
  String get commonSortName => 'ชื่อ A–Z';

  @override
  String get commonSortNewest => 'ใหม่ล่าสุด';

  @override
  String get commonSortPriceHigh => 'ราคา: สูงไปต่ำ';

  @override
  String get commonSortPriceLow => 'ราคา: ต่ำไปสูง';

  @override
  String get commonSortRarity => 'ความหายาก';

  @override
  String get commonSortWeapon => 'อาวุธ';

  @override
  String get commonTabBattlePass => 'Battle Pass';

  @override
  String get commonTabCollection => 'คอลเลกชัน';

  @override
  String get commonTabCommunity => 'ชุมชน';

  @override
  String get commonTabHome => 'หน้าหลัก';

  @override
  String get commonTabProfile => 'โปรไฟล์';

  @override
  String get commonTabSettings => 'การตั้งค่า';

  @override
  String get commonTabStore => 'ร้านค้า';

  @override
  String get commonTagline => 'ผู้ช่วย VALORANT ของคุณ';

  @override
  String get commonToday => 'วันนี้';

  @override
  String get commonTodayLower => 'วันนี้';

  @override
  String get commonTomorrow => 'พรุ่งนี้';

  @override
  String get commonUnknownItem => 'ไอเทมที่ไม่ทราบชื่อ';

  @override
  String commonUpdatedAt(String time) {
    return 'อัปเดตเมื่อ $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$time $day';
  }

  @override
  String get commonWeekdaysItem0 => 'วันจันทร์';

  @override
  String get commonWeekdaysItem1 => 'วันอังคาร';

  @override
  String get commonWeekdaysItem2 => 'วันพุธ';

  @override
  String get commonWeekdaysItem3 => 'วันพฤหัสบดี';

  @override
  String get commonWeekdaysItem4 => 'วันศุกร์';

  @override
  String get commonWeekdaysItem5 => 'วันเสาร์';

  @override
  String get commonWeekdaysItem6 => 'วันอาทิตย์';

  @override
  String get commonYesterday => 'เมื่อวาน';

  @override
  String get commonYesterdayTitle => 'เมื่อวาน';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'การเข้าสู่ระบบ Riot หมดอายุแล้ว — กำลังแสดงข้อมูลที่บันทึกไว้ ($time)';
  }

  @override
  String get contentCategoryHeavy => 'อาวุธร้ายแรง';

  @override
  String get contentCategoryMelee => 'อาวุธระยะประชิด';

  @override
  String get contentCategoryRifle => 'Assault Rifles';

  @override
  String get contentCategoryShotgun => 'ปืนลูกซอง';

  @override
  String get contentCategorySidearm => 'Sidearms';

  @override
  String get contentCategorySmg => 'ปืนกลมือ';

  @override
  String get contentCategorySniper => 'Sniper Rifles';

  @override
  String get contentCurrencyAgentTokens => 'เอเจนท์โทเคน';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'Kingdom Credit';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'Radianite';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'VALORANT Point';

  @override
  String get contentDefaultSkin => 'ค่าเริ่มต้น';

  @override
  String get contentItemAgent => 'เอเจนท์';

  @override
  String get contentItemBuddy => 'บัดดี้ปืน';

  @override
  String get contentItemCard => 'การ์ดผู้เล่น';

  @override
  String get contentItemChroma => 'รูปแบบสี';

  @override
  String get contentItemContract => 'สัญญา';

  @override
  String get contentItemCurrency => 'สกุลเงิน';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemLanguageEn => 'ภาษาอังกฤษ';

  @override
  String get contentItemLanguageTitle => 'ชื่อไอเทม';

  @override
  String get contentItemLanguageVi => 'ภาษาเวียดนาม';

  @override
  String get contentItemLevelBorder => 'กรอบเลเวล';

  @override
  String get contentItemSkin => 'สกิน';

  @override
  String get contentItemSpray => 'สเปรย์';

  @override
  String get contentItemTitle => 'ฉายาผู้เล่น';

  @override
  String contentLevel(int n) {
    return 'เลเวล $n';
  }

  @override
  String get contentLevelBase => 'พื้นฐาน';

  @override
  String get contentLevelItemLabelsVFX => 'เอฟเฟกต์ภาพ';

  @override
  String get contentLevelItemLabelsAnimation => 'แอนิเมชัน';

  @override
  String get contentLevelItemLabelsFinisher => 'ท่าปิดฉาก';

  @override
  String get contentLevelItemLabelsKillCounter => 'ตัวนับการสังหาร';

  @override
  String get contentLevelItemLabelsSoundEffects => 'เอฟเฟกต์เสียง';

  @override
  String get contentLevelItemLabelsTransformation => 'การแปลงร่าง';

  @override
  String get contentLevelItemLabelsKillBanner => 'แบนเนอร์สังหาร';

  @override
  String get contentLevelItemLabelsKillEffect => 'เอฟเฟกต์สังหาร';

  @override
  String get contentLevelItemLabelsInspectAndKill =>
      'เอฟเฟกต์ตรวจดูปืนและสังหาร';

  @override
  String get contentLevelItemLabelsVoiceover => 'เสียงพากย์';

  @override
  String get contentLevelItemLabelsSongShuffle => 'สลับเพลง';

  @override
  String get contentLevelItemLabelsRandomizer => 'สุ่ม';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'สลับตามฝ่ายบุก/ป้องกัน';

  @override
  String get contentLevelItemLabelsTopFrag => 'เอฟเฟกต์ท็อปแฟรก';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'เซนเซอร์ชีพจรและแผนที่';

  @override
  String get contentLevelItemLabelsFishAnimation => 'แอนิเมชันปลา';

  @override
  String get contentLimitedEdition => 'รุ่นจำกัดจำนวน';

  @override
  String get contentNoSpray => 'ไม่มี';

  @override
  String get contentNoTitle => 'ไม่มีฉายา';

  @override
  String get contentNotForSale => 'ไม่มีขาย';

  @override
  String get contentQueueNamesCompetitive => 'Competitive';

  @override
  String get contentQueueNamesUnrated => 'Unrated';

  @override
  String get contentQueueNamesSwiftplay => 'Swiftplay';

  @override
  String get contentQueueNamesSpikerush => 'Spike Rush';

  @override
  String get contentQueueNamesDeathmatch => 'Deathmatch';

  @override
  String get contentQueueNamesHurm => 'Team Deathmatch';

  @override
  String get contentQueueNamesGgteam => 'Escalation';

  @override
  String get contentQueueNamesOnefa => 'Replication';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => 'Custom Game';

  @override
  String get contentQueueNames => 'Custom Game';

  @override
  String get contentQueueNamesDodgeball => 'Knockout';

  @override
  String get contentQueueNamesFortcollins => 'Retake';

  @override
  String get contentQueueNamesSkirmish2v2 => 'Skirmish: 2v2';

  @override
  String get contentQueueNamesSkirmishascension1v1 => 'Skirmish: Ascension 1v1';

  @override
  String get contentQueueNamesSkirmishascension2v2 => 'Skirmish: Ascension 2v2';

  @override
  String get contentQueueNamesValaram => 'All Random One Site';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'Snowball Fight';

  @override
  String get contentQueueNamesNewmap => 'Summit';

  @override
  String get contentQueueShortNamesCompetitive => 'Competitive';

  @override
  String get contentQueueShortNamesValaram => 'All Random';

  @override
  String get contentRewardSourceAgent => 'สัญญาเอเจนท์';

  @override
  String get contentRewardSourceBattlePass => 'รางวัล Battle Pass';

  @override
  String get contentRewardSourceEvent => 'อีเวนต์พาส';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'Duelist';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'Initiator';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'Controller';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'Sentinel';

  @override
  String get contentTierDeluxe => 'Deluxe';

  @override
  String get contentTierExclusive => 'Exclusive';

  @override
  String contentTierFull(String shortName) {
    return '$shortName Edition';
  }

  @override
  String get contentTierPremium => 'Premium';

  @override
  String get contentTierSelect => 'Select';

  @override
  String get contentTierUltra => 'Ultra';

  @override
  String get contentUnranked => 'ยังไม่มีแรงก์';

  @override
  String get accountRegionUnknown => 'ไม่ทราบภูมิภาค';

  @override
  String accountRiotCountry(String country) {
    return 'ประเทศของบัญชี Riot: $country';
  }

  @override
  String get accountRiotCountryUnknown => 'ประเทศของบัญชี Riot: ไม่ทราบ';

  @override
  String accountAccountCount(int count, int max) {
    return '$count/$max บัญชี';
  }

  @override
  String accountAccountsHeader(int count, int max) {
    return 'บัญชี ($count/$max)';
  }

  @override
  String get accountActive => 'กำลังใช้';

  @override
  String accountAddAccount(int count, int max) {
    return 'เพิ่มบัญชี ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'ล้างข้อมูลในเครื่อง';

  @override
  String get accountClearLocalDataConfirm =>
      'ล้างประวัติ ชุดอุปกรณ์ที่บันทึกไว้ และข้อมูลของบัญชีที่ออกจากระบบแล้วในอุปกรณ์นี้ใช่ไหม';

  @override
  String get accountClearRrHistory => 'ล้างประวัติ RR';

  @override
  String get accountClearRrHistoryConfirm =>
      'ล้างประวัติ RR ของบัญชีที่เลือกในอุปกรณ์นี้ใช่ไหม';

  @override
  String get accountCopyPassword => 'คัดลอกรหัสผ่าน';

  @override
  String get accountCopyUsername => 'คัดลอกชื่อผู้ใช้';

  @override
  String get accountDeleteLoginNote => 'ลบข้อมูล';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'ลบชื่อผู้ใช้และรหัสผ่านที่บันทึกไว้ของบัญชีนี้ใช่ไหม';

  @override
  String get accountHidePassword => 'ซ่อนรหัสผ่าน';

  @override
  String get accountKeepLocalData => 'เก็บข้อมูลในเครื่องไว้';

  @override
  String get accountKeepLocalDataHint =>
      'เก็บ wishlist ชุดอุปกรณ์ และประวัติไว้ในอุปกรณ์นี้';

  @override
  String accountLevelShort(int level) {
    return 'Lv. $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'บัญชีในการแจ้งเตือนนี้ออกจากระบบแล้ว เข้าสู่ระบบอีกครั้งแล้วเปิดการแจ้งเตือน';

  @override
  String get accountLocalDataCleared => 'ล้างข้อมูลในเครื่องแล้ว';

  @override
  String get accountLoginNote => 'ข้อมูลเข้าสู่ระบบ';

  @override
  String get accountLoginNoteDeleted => 'ลบข้อมูลเข้าสู่ระบบแล้ว';

  @override
  String get accountLoginNoteEmpty => 'ยังไม่ได้บันทึกข้อมูลเข้าสู่ระบบ';

  @override
  String get accountLoginNoteHint =>
      'บันทึกไว้ในอุปกรณ์นี้เท่านั้นและล็อกไว้อย่างปลอดภัย ใช้เพื่อดูหรือกรอกข้อมูลอย่างรวดเร็วเมื่อคุณเข้าสู่ระบบอีกครั้ง';

  @override
  String get accountLoginNoteLocked => 'ปลดล็อกข้อมูลเข้าสู่ระบบ';

  @override
  String get accountLoginNotePassword => 'รหัสผ่าน';

  @override
  String get accountLoginNoteSaved => 'บันทึกข้อมูลเข้าสู่ระบบแล้ว';

  @override
  String get accountLoginNoteUsername => 'ชื่อผู้ใช้ Riot';

  @override
  String get accountManageHint =>
      'ลบบัญชีหรือแก้ไขข้อมูลเข้าสู่ระบบได้ในการตั้งค่า';

  @override
  String accountMaxAccounts(int max) {
    return 'ถึงจำนวนบัญชีสูงสุด $max บัญชีแล้ว';
  }

  @override
  String get accountNeedsLogin => 'เข้าสู่ระบบอีกครั้ง';

  @override
  String accountOnlineCount(int count) {
    return 'ออนไลน์ $count คน';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => 'กรอกบัญชีที่บันทึกไว้';

  @override
  String get accountQuickFillDone => 'กรอกเรียบร้อยแล้ว แตะเข้าสู่ระบบ';

  @override
  String get accountQuickFillNotReady =>
      'หน้าเข้าสู่ระบบยังโหลดไม่เสร็จ รอสักครู่แล้วลองอีกครั้ง';

  @override
  String get accountQuickFillSubtitle =>
      'เลือกบัญชีเพื่อกรอกในหน้าเข้าสู่ระบบ Riot';

  @override
  String get accountQuickFillTitle => 'กรอกบัญชีที่บันทึกไว้';

  @override
  String get accountRegionAp => 'เอเชียแปซิฟิก';

  @override
  String get accountRegionBr => 'บราซิล';

  @override
  String get accountRegionEu => 'ยุโรป';

  @override
  String get accountRegionKr => 'เกาหลี';

  @override
  String get accountRegionLatam => 'ละตินอเมริกา';

  @override
  String get accountRegionNa => 'อเมริกาเหนือ';

  @override
  String get accountRemoveAccount => 'ลบบัญชี';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'ลบ $account ออกจากอุปกรณ์นี้ใช่ไหม คุณเลือกเก็บข้อมูลที่บันทึกไว้ได้';
  }

  @override
  String get accountRrHistoryCleared => 'ล้างประวัติ RR แล้ว';

  @override
  String get accountShowPassword => 'แสดงรหัสผ่าน';

  @override
  String get accountSignOutAll => 'ออกจากระบบทุกบัญชี';

  @override
  String get accountSignOutAllConfirm =>
      'ออกจากระบบและลบบัญชีทั้งหมดออกจากอุปกรณ์นี้ใช่ไหม คุณเลือกเก็บข้อมูลที่บันทึกไว้ได้';

  @override
  String get accountStatusAgentSelect => 'กำลังเลือกเอเจนท์';

  @override
  String get accountStatusInMatch => 'อยู่ในแมตช์';

  @override
  String get accountStatusOffline => 'ออฟไลน์';

  @override
  String get accountStatusOnline => 'ออนไลน์';

  @override
  String get accountStatusUnknown => 'ไม่ทราบสถานะ';

  @override
  String get accountSwitchFailed => 'สลับบัญชีไม่ได้ ลองอีกครั้ง';

  @override
  String accountSwitchTo(String account) {
    return 'สลับไปที่ $account';
  }

  @override
  String get accountSwitcherSubtitle => 'แตะเพื่อสลับบัญชี';

  @override
  String get accountSwitcherTitle => 'บัญชี';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'บัญชี ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'ผู้เล่น';

  @override
  String get accountUnlockLoginNote =>
      'ยืนยันตัวตนเพื่อปลดล็อกข้อมูลเข้าสู่ระบบ Riot';

  @override
  String get authAccountAlreadyAdded => 'เพิ่มบัญชีนี้ไว้แล้ว';

  @override
  String get authAddAsNew => 'เพิ่มเป็นบัญชีใหม่';

  @override
  String get authDifferentAccountBody =>
      'คุณเข้าสู่ระบบด้วยบัญชีที่ต่างจากบัญชีที่ต้องเข้าสู่ระบบอีกครั้ง เพิ่มบัญชีนี้เป็นบัญชีใหม่ไหม';

  @override
  String get authDifferentAccountTitle => 'บัญชีอื่น';

  @override
  String get authLoadingAccount => 'กำลังโหลดบัญชี…';

  @override
  String get authLoginCancelledByRiot =>
      'Riot ปฏิเสธการเข้าสู่ระบบครั้งนี้ ลองอีกครั้ง';

  @override
  String get authLoginFailed => 'เข้าสู่ระบบไม่สำเร็จ';

  @override
  String get authLoginFailedBody =>
      'Riot ยังไม่ยืนยันการเข้าสู่ระบบของคุณ ลองอีกครั้ง';

  @override
  String get authLoginTitle => 'เข้าสู่ระบบ Riot';

  @override
  String get authMissingCookies =>
      'บันทึกการเข้าสู่ระบบในอุปกรณ์นี้ไม่ได้ คุณจึงต้องเข้าสู่ระบบอีกครั้งเมื่อหมดอายุ';

  @override
  String get authOfficialHost => 'หน้าทางการ · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'เปิดลิงก์ในเบราว์เซอร์แล้ว';

  @override
  String get authPageLoadFailed =>
      'โหลดหน้าเข้าสู่ระบบของ Riot ไม่ได้ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get authPreparing => 'กำลังเตรียมหน้าเข้าสู่ระบบ…';

  @override
  String get authReloginDone => 'เข้าสู่ระบบอีกครั้งแล้ว';

  @override
  String get authRememberMeHint =>
      'เปิด \"คงสถานะการเข้าสู่ระบบ\" เพื่อไม่ต้องเข้าสู่ระบบใหม่';

  @override
  String get authSignInCta => 'เข้าสู่ระบบด้วยบัญชี Riot';

  @override
  String get authSignInNote =>
      'คุณเข้าสู่ระบบในหน้าทางการของ Riot โดย ValHub จะบันทึกรหัสผ่านก็ต่อเมื่อคุณเลือกบันทึกข้อมูลเข้าสู่ระบบเอง ข้อมูลการเข้าสู่ระบบและข้อมูลที่บันทึกไว้อยู่ในอุปกรณ์ของคุณเท่านั้น';

  @override
  String get authSocialLoginHint =>
      'หากเข้าสู่ระบบด้วย Google หรือ Facebook ไม่ได้ ให้ใช้ชื่อผู้ใช้ Riot';

  @override
  String get authStateMismatch =>
      'การเข้าสู่ระบบครั้งนี้ไม่ถูกต้อง เริ่มเข้าสู่ระบบใหม่ตั้งแต่ต้น';

  @override
  String get notificationSessionExpiredBody =>
      'เข้าสู่ระบบอีกครั้งเพื่อรับการแจ้งเตือน wishlist ต่อ';

  @override
  String get notificationBackgroundTimingHint =>
      'โหมดประหยัดแบตเตอรี่ของอุปกรณ์อาจทำให้การแจ้งเตือนมาช้า';

  @override
  String get notificationChannelAccountDescription =>
      'เตือนเมื่อบัญชีต้องเข้าสู่ระบบอีกครั้ง';

  @override
  String get notificationChannelAccountName => 'บัญชี';

  @override
  String get notificationChannelBattlePassDescription =>
      'เตือนความคืบหน้าและวันสิ้นสุด Battle Pass';

  @override
  String get notificationChannelBattlePassName => 'Battle Pass';

  @override
  String get notificationChannelCommunityDescription =>
      'กิจกรรมในชุมชนเมื่อคุณเปิด ValHub';

  @override
  String get notificationChannelCommunityName => 'ชุมชน';

  @override
  String get notificationChannelLfgDescription =>
      'ผู้เล่นที่เข้าร่วมปาร์ตี้ของคุณเมื่อคุณเปิด ValHub';

  @override
  String get notificationChannelLfgName => 'ปาร์ตี้';

  @override
  String get notificationChannelNightMarketDescription =>
      'แจ้งเตือนเมื่อไนท์มาร์เก็ตเปิด';

  @override
  String get notificationChannelNightMarketName => 'ไนท์มาร์เก็ต';

  @override
  String get notificationChannelRankDescription =>
      'แรงก์ที่เปลี่ยนเมื่อคุณรีเฟรชโปรไฟล์';

  @override
  String get notificationChannelRankName => 'แรงก์';

  @override
  String get notificationChannelStoreResetDescription =>
      'เตือนเมื่อร้านค้ารายวันรีเฟรช';

  @override
  String get notificationChannelStoreResetName => 'ร้านค้ารีเฟรช';

  @override
  String get notificationChannelWishlistDescription =>
      'แจ้งเตือนเมื่อสกินใน wishlist ปรากฏในร้านค้าของคุณ';

  @override
  String get notificationChannelWishlistName => 'Wishlist';

  @override
  String get notificationLfgJoinedTitle => 'มีผู้เล่นเข้าร่วมปาร์ตี้ของคุณ';

  @override
  String get notificationLocalOnlyHint =>
      'แสดงเฉพาะในอุปกรณ์นี้เมื่อ ValHub อัปเดตข้อมูล';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'การ์ดข้อเสนอของ $account รออยู่: $cards ใบ เปิดเลย';
  }

  @override
  String get notificationNightMarketOpenTitle => 'ไนท์มาร์เก็ตเปิดแล้ว!';

  @override
  String get notificationPassEndingBody =>
      'Battle Pass เหลือเวลาอีกประมาณหนึ่งวัน เปิด ValHub เพื่อดูความคืบหน้าล่าสุด';

  @override
  String get notificationPassEndingTitle => 'Battle Pass ใกล้สิ้นสุดแล้ว';

  @override
  String notificationPassProgressBody(int level) {
    return 'คุณถึงเลเวล $level ใน Battle Pass ปัจจุบันแล้ว';
  }

  @override
  String get notificationPassProgressTitle => 'ความคืบหน้า Battle Pass';

  @override
  String get notificationPrivateAccount => 'บัญชีของคุณ';

  @override
  String notificationRankChangedBody(String rank) {
    return 'แรงก์ปัจจุบัน: $rank เพิ่งอัปเดตจาก Riot';
  }

  @override
  String get notificationRankChangedTitle => 'แรงก์เปลี่ยนแปลง';

  @override
  String get notificationResetTimingUnknown =>
      'เปิดร้านค้าเพื่ออัปเดตเวลารีเฟรชในอุปกรณ์ของคุณ';

  @override
  String get notificationSessionExpiredTitle => 'เข้าสู่ระบบอีกครั้ง';

  @override
  String get notificationStoreResetBody => 'สกินใหม่รอคุณอยู่ในร้านค้า';

  @override
  String get competitiveDivisionIron => 'IRON';

  @override
  String get competitiveDivisionBronze => 'BRONZE';

  @override
  String get competitiveDivisionSilver => 'SILVER';

  @override
  String get competitiveDivisionGold => 'GOLD';

  @override
  String get competitiveDivisionPlatinum => 'PLATINUM';

  @override
  String get competitiveDivisionDiamond => 'DIAMOND';

  @override
  String get competitiveDivisionAscendant => 'ASCENDANT';

  @override
  String get competitiveDivisionImmortal => 'IMMORTAL';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'RADIANT';

  @override
  String get competitiveRankUnknown => 'ไม่ทราบแรงก์';

  @override
  String get competitiveAttack => 'ฝ่ายบุก';

  @override
  String get competitiveCannotEstimate => 'ประมาณการไม่ได้';

  @override
  String get competitiveDefeat => 'แพ้';

  @override
  String get competitiveDefense => 'ฝ่ายป้องกัน';

  @override
  String get competitiveDraw => 'เสมอ';

  @override
  String get competitiveIncognitoPlayer => 'ผู้เล่นที่ซ่อนตัว';

  @override
  String get competitiveMatchPending => 'Riot กำลังประมวลผลแมตช์นี้…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    return 'เหลือแมตช์วัดระดับอีก $n แมตช์';
  }

  @override
  String get competitiveRoundDefuse => 'กู้สไปค์';

  @override
  String get competitiveRoundDetonate => 'สไปค์ระเบิด';

  @override
  String get competitiveRoundElimination => 'กำจัดทั้งทีม';

  @override
  String get competitiveRoundSurrendered => 'ยอมแพ้';

  @override
  String get competitiveRoundTimeExpired => 'หมดเวลา';

  @override
  String get competitiveUnknownPlayer => 'ผู้เล่น';

  @override
  String get competitiveVictory => 'ชนะ';

  @override
  String economyAvailableNow(String place) {
    return 'มีใน$placeแล้ว!';
  }

  @override
  String get economyCollectionValue => 'มูลค่าคอลเลกชัน';

  @override
  String get economyExcludedRewards => 'ไม่รวมสกินที่เป็นรางวัล';

  @override
  String economyPlaceBundle(String name) {
    return 'บันเดิล $name';
  }

  @override
  String get economyPlaceBundleGeneric => 'บันเดิล';

  @override
  String get economyPlaceDaily => 'ร้านค้ารายวัน';

  @override
  String get economyPlaceNightMarket => 'ไนท์มาร์เก็ต';

  @override
  String get economyPriceEstimated => 'ราคาประมาณตามรุ่น';

  @override
  String get economyPriceFromOffers => 'ราคาจากตารางราคาของ Riot';

  @override
  String get economyPriceFromStore => 'ราคาที่เคยเห็นในร้านค้า';

  @override
  String get economyPriceFromTable => 'ราคาตั้ง';

  @override
  String get economyPriceUnknown => 'ไม่ทราบราคา';

  @override
  String get economyValueHasEstimates => 'รวมราคาประมาณ (≈)';

  @override
  String get economyWishlistValue => 'มูลค่ารวมของ wishlist';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'ชุดอุปกรณ์ $n';
  }

  @override
  String get loadoutInvalidChange =>
      'ใช้การเปลี่ยนแปลงนี้กับชุดอุปกรณ์ปัจจุบันไม่ได้';

  @override
  String get loadoutNotPersisted =>
      'Riot ไม่ได้บันทึกการเปลี่ยนแปลงของคุณ ชุดอุปกรณ์จึงยังเหมือนเดิม ลองอีกครั้ง';

  @override
  String get loadoutSaveFailed => 'บันทึกชุดอุปกรณ์ไม่ได้';

  @override
  String get battlePassActEnded => 'แอคท์นี้สิ้นสุดแล้ว';

  @override
  String battlePassActEndsIn(String time) {
    return 'แอคท์สิ้นสุดใน $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    return 'แอคท์สิ้นสุดใน $days วัน';
  }

  @override
  String get battlePassAllMissionsDone => 'ทำภารกิจครบทั้งหมดแล้ว';

  @override
  String get battlePassAllWeeklyDone => 'ทำภารกิจรายสัปดาห์ครบทั้งหมดแล้ว';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'รางวัลสองเท่าที่รออยู่: $n';
  }

  @override
  String battlePassChapter(int n) {
    return 'บทที่ $n';
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
  String get battlePassCheckpoint => 'เช็กพอยต์';

  @override
  String get battlePassCheckpointHint =>
      'ชนะรอบเพื่อสะสมความคืบหน้าเช็กพอยต์ (ไม่นับ Deathmatch)';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'เช็กพอยต์ $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'แต่ละเช็กพอยต์: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'ถึงเช็กพอยต์แล้ว $done/$total';
  }

  @override
  String get battlePassCurrentChapter => 'ปัจจุบัน';

  @override
  String get battlePassDailyAllDone => 'ผ่านเช็กพอยต์ของวันนี้ครบแล้ว';

  @override
  String get battlePassDailyCaption => 'รางวัลรายวัน';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'รางวัลรายวัน · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'เช็กพอยต์ของเมื่อวานหมดอายุแล้ว เข้าเกมหรือรีเฟรชที่นี่';

  @override
  String get battlePassDailyMissions => 'ภารกิจรายวัน';

  @override
  String get battlePassDailyNotReady =>
      'เช็กพอยต์ของวันนี้ยังไม่พร้อม เข้าเกมหรือรีเฟรชที่นี่';

  @override
  String get battlePassDailyPlayToStart =>
      'เช็กพอยต์ของวันนี้ยังไม่พร้อม เข้าเกมเพื่อเริ่มวันใหม่';

  @override
  String battlePassDaysLeft(int days) {
    return 'เหลืออีก $days วัน';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'สิ้นสุด $wall';
  }

  @override
  String get battlePassEpilogue => 'บทส่งท้าย';

  @override
  String get battlePassEstimateNote =>
      'ประมาณการที่ราว 4,000 XP ต่อแมตช์ ยังไม่รวมภารกิจ';

  @override
  String battlePassEventEndsIn(String time) {
    return 'สิ้นสุดใน $time';
  }

  @override
  String get battlePassEventPass => 'อีเวนต์พาส';

  @override
  String get battlePassFilterAll => 'ทั้งหมด';

  @override
  String get battlePassFilterLocked => 'ล็อกอยู่';

  @override
  String get battlePassFilterUnlocked => 'ปลดล็อกแล้ว';

  @override
  String get battlePassFree => 'ฟรี';

  @override
  String get battlePassFreeTrack => 'รางวัลฟรี';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'เลเวล $level / $count';
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

    return '≈ $nString แมตช์ $queue';
  }

  @override
  String get battlePassMissionDone => 'สำเร็จแล้ว';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return 'สำเร็จ $done/$total';
  }

  @override
  String get battlePassMissionsProgressLabel => 'ความคืบหน้าภารกิจรายสัปดาห์';

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'ภารกิจใหม่ $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'ภารกิจใหม่ใน $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'เช็กพอยต์ถัดไป: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'ไปเลเวล $level';
  }

  @override
  String get battlePassNextReward => 'ถัดไป';

  @override
  String get battlePassNoBattlePass =>
      'ยังไม่มีข้อมูล Battle Pass ของแอคท์ปัจจุบัน ลองอีกครั้งภายหลัง';

  @override
  String get battlePassNoRewards => 'Battle Pass นี้ยังไม่มีรางวัล';

  @override
  String get battlePassNoRewardsInFilter => 'ไม่มีรางวัลในหมวดนี้';

  @override
  String get battlePassNoRewardsTitle => 'ยังไม่มีรางวัล';

  @override
  String get battlePassNoWeeklyMissions => 'ขณะนี้ยังไม่มีภารกิจรายสัปดาห์';

  @override
  String get battlePassPassComplete => 'Battle Pass สำเร็จแล้ว';

  @override
  String get battlePassPremium => 'พรีเมียม';

  @override
  String get battlePassPremiumHint =>
      'คุณยังไม่ได้ซื้อพรีเมียม จึงได้รับเฉพาะรางวัลฟรี ซื้อพรีเมียมในเกมเพื่อปลดล็อกเลเวลที่ทำได้แล้ว';

  @override
  String get battlePassRenewButton => 'รีเฟรชเช็กพอยต์';

  @override
  String get battlePassRenewDone => 'รีเฟรชเช็กพอยต์รายวันแล้ว';

  @override
  String get battlePassRenewFailed =>
      'รีเฟรชเช็กพอยต์ไม่ได้ ลองอีกครั้งภายหลัง';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'รีเซ็ต $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'รีเซ็ตใน $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'เลเวล';

  @override
  String get battlePassRewardLocked => 'ล็อกอยู่';

  @override
  String get battlePassRewardNeedsPremium => 'ต้องมีพรีเมียม';

  @override
  String get battlePassRewardStatusLabel => 'สถานะ';

  @override
  String get battlePassRewardTrackLabel => 'ประเภทรางวัล';

  @override
  String get battlePassRewardTypeLabel => 'ประเภท';

  @override
  String get battlePassRewardUnlocked => 'ปลดล็อกแล้ว';

  @override
  String get battlePassRewardsTitle => 'รางวัล';

  @override
  String get battlePassShowAllRewards => 'ดูทั้งหมด';

  @override
  String get battlePassTitle => 'Battle Pass';

  @override
  String get battlePassTotalXpCaption => 'XP รวม';

  @override
  String get battlePassUnknownMission => 'ภารกิจใหม่ (ยังไม่มีคำอธิบาย)';

  @override
  String get battlePassUnknownReward => 'รางวัล';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return 'ปลดล็อกแล้ว $unlocked/$total';
  }

  @override
  String get battlePassUnratedFallback => 'Unrated';

  @override
  String get battlePassViewAllRewards => 'ดูรางวัลทั้งหมด';

  @override
  String get battlePassWeeklyMissions => 'ภารกิจรายสัปดาห์';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'ภารกิจรายสัปดาห์เหลือ +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / วัน';
  }

  @override
  String get battlePassXpPerDayCaption => 'ที่ต้องทำต่อวันเพื่อให้จบทันเวลา';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'ยังต้องการอีก $xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'บันทึกชุดอุปกรณ์ไม่ได้ $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'สกินทั้งหมดที่คุณมี คิดมูลค่าตามราคาในร้านค้า',
      'buddy': 'บัดดี้ปืนที่มีและจำนวนชิ้น',
      'spray': 'สเปรย์ที่คุณใส่ในวงล้อแสดงอารมณ์ได้',
      'card': 'การ์ดผู้เล่นที่ปลดล็อกแล้ว แตะเพื่อดูและติดตั้ง',
      'title': 'ฉายาผู้เล่นที่แสดงใต้ชื่อของคุณได้',
      'flex': 'ไอเทม Flex ที่มี',
      'other': 'เรียกดูคอลเลกชัน',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'ช่อง: $position';
  }

  @override
  String get collectionApplyPreset => 'ใช้';

  @override
  String get collectionApplyPresetBody =>
      'สกิน บัดดี้ปืน วงล้อแสดงอารมณ์ การ์ด และฉายาที่ใช้อยู่จะถูกแทนที่ด้วยชุดนี้';

  @override
  String collectionApplyPresetTitle(String name) {
    return 'ใช้ “$name” ไหม';
  }

  @override
  String get collectionBannerTitlePrefix => 'ฉายา: ';

  @override
  String get collectionBrowseBuddies => 'บัดดี้ปืน';

  @override
  String get collectionBrowseCards => 'การ์ดผู้เล่น';

  @override
  String get collectionBrowseEmpty => 'คุณยังไม่มีไอเทมในหมวดนี้';

  @override
  String get collectionBrowseEmptyTitle => 'ยังไม่มีไอเทม';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'สกิน';

  @override
  String get collectionBrowseSprays => 'สเปรย์';

  @override
  String get collectionBrowseTitle => 'เรียกดูคอลเลกชัน';

  @override
  String get collectionBrowseTitles => 'ฉายาผู้เล่น';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'เหลือ $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'สำหรับ $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'เลือกบัดดี้ปืน';

  @override
  String get collectionBuddyRemoved => 'ถอดบัดดี้ปืนแล้ว';

  @override
  String get collectionBuddySlot => 'บัดดี้ปืน';

  @override
  String get collectionBuddyUnavailable =>
      'ติดบัดดี้ปืนนี้ไม่ได้ รีเฟรชหรือเลือกชิ้นอื่น';

  @override
  String get collectionCachedLoadout =>
      'กำลังแสดงชุดอุปกรณ์ที่บันทึกไว้ ดึงลงเพื่อรีเฟรชก่อนเปลี่ยนแปลง';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'มีการ์ด $nString ใบ';
  }

  @override
  String get collectionChangeBuddy => 'เปลี่ยน';

  @override
  String collectionChromaCount(int owned, int total) {
    return '$owned/$total รูปแบบสี';
  }

  @override
  String get collectionClearFilters => 'ล้างตัวกรอง';

  @override
  String get collectionClearSearch => 'ล้างการค้นหา';

  @override
  String get collectionClearTiers => 'ล้างตัวกรองรุ่น';

  @override
  String get collectionCollectionValue => 'มูลค่าคอลเลกชัน';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'ค่าเริ่มต้น';

  @override
  String get collectionDeletePreset => 'ลบ';

  @override
  String get collectionEmptySlot => 'ว่าง';

  @override
  String get collectionEquip => 'ติดตั้ง';

  @override
  String get collectionEquipped => 'ใช้อยู่';

  @override
  String get collectionEquippedCard => 'การ์ดที่ใช้อยู่';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'การ์ดที่ใช้อยู่: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return 'ติดตั้ง $name แล้ว';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'ใช้อยู่: $skin';
  }

  @override
  String get collectionExcludedRewards => 'ไม่รวมสกินที่เป็นรางวัล';

  @override
  String get collectionExpressionsHint => 'แตะช่องเพื่อเลือกสเปรย์หรือ Flex';

  @override
  String get collectionExpressionsSlots => 'ช่องบนวงล้อ';

  @override
  String get collectionExpressionsTitle => 'วงล้อแสดงอารมณ์';

  @override
  String get collectionFilterTiers => 'รุ่น';

  @override
  String get collectionHideAccountLevel => 'ซ่อนเลเวลบัญชี';

  @override
  String get collectionHideAccountLevelHint =>
      'ผู้เล่นคนอื่นจะไม่เห็นเลเวลบัญชีของคุณ';

  @override
  String get collectionIncognito => 'โหมดไม่ระบุตัวตน';

  @override
  String get collectionIncognitoHint =>
      'ซ่อนชื่อของคุณจากผู้เล่นที่ไม่ได้อยู่ในปาร์ตี้เดียวกันระหว่างแมตช์';

  @override
  String collectionItemsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ไอเทม $nString ชิ้น';
  }

  @override
  String get collectionLevelBorderAuto => 'อัตโนมัติตามเลเวล';

  @override
  String get collectionLevelBorderEmpty => 'ยังไม่มีกรอบเลเวลสำหรับเลเวลของคุณ';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'ตั้งแต่เลเวล $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'บัญชีเลเวล $level';
  }

  @override
  String get collectionLevelBorderTitle => 'เลือกกรอบเลเวล';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'เลเวล $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'เลเวล $n · $type';
  }

  @override
  String get collectionLevels => 'เลเวล';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return 'ปลดล็อกแล้ว $owned/$total เลเวล';
  }

  @override
  String get collectionLobbyBanner => 'แบนเนอร์ในล็อบบี้';

  @override
  String get collectionLocked => 'ล็อกอยู่';

  @override
  String get collectionMeleeNoBuddy => 'อาวุธระยะประชิดติดบัดดี้ปืนไม่ได้';

  @override
  String get collectionMove => 'ย้าย';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy ติดอยู่บน $from ย้ายไปที่ $to ไหม';
  }

  @override
  String get collectionMoveBuddyTitle => 'ย้ายบัดดี้ปืนไหม';

  @override
  String get collectionNoBuddies => 'คุณยังไม่มีบัดดี้ปืน';

  @override
  String get collectionNoBuddy => 'ไม่มีบัดดี้ปืน';

  @override
  String get collectionNoFlex => 'คุณยังไม่มีไอเทม Flex';

  @override
  String get collectionNoResults => 'ไม่พบผลลัพธ์ที่ตรงกัน';

  @override
  String get collectionNoResultsTitle => 'ไม่พบอะไรเลย';

  @override
  String get collectionNoSkinsForWeapon => 'คุณยังไม่มีสกินสำหรับอาวุธนี้';

  @override
  String get collectionNoSprays => 'คุณยังไม่มีสเปรย์';

  @override
  String get collectionNoTitle => 'ไม่มีฉายา';

  @override
  String get collectionOtherWeapons => 'อื่นๆ';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'มีสกิน $n ชิ้น',
      zero: 'ยังไม่มีสกิน',
    );
    return '$_temp0';
  }

  @override
  String collectionOwnedSkinsStat(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'มี $nString สกิน';
  }

  @override
  String get collectionPlayLevelVideo => 'ดูวิดีโอของเลเวลนี้';

  @override
  String get collectionPlayVideo => 'ดูวิดีโอ';

  @override
  String get collectionPlayerCardSubtitle =>
      'แสดงในล็อบบี้ บนกระดานคะแนน และเมื่อคุณกำจัดศัตรู';

  @override
  String get collectionPlayerCardTitle => 'เปลี่ยนการ์ดผู้เล่น';

  @override
  String get collectionPlayerTitleSubtitle =>
      'แสดงใต้ชื่อของคุณในล็อบบี้และในแมตช์';

  @override
  String get collectionPlayerTitleTitle => 'เปลี่ยนฉายาผู้เล่น';

  @override
  String get collectionPresetActions => 'ตัวเลือก';

  @override
  String collectionPresetApplied(String name) {
    return 'ใช้ “$name” แล้ว';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ชุด',
      zero: 'ยังไม่มี',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return 'ลบ “$name” แล้ว';
  }

  @override
  String get collectionPresetNameHint => 'เช่น ไต่แรงก์';

  @override
  String get collectionPresetNameTitle => 'ชื่อชุดอุปกรณ์';

  @override
  String collectionPresetSaved(String name) {
    return 'บันทึก “$name” แล้ว';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'บันทึกเมื่อ $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    return 'ข้ามไอเทม $n ชิ้นที่คุณไม่มีแล้ว';
  }

  @override
  String get collectionPresetsEmpty =>
      'บันทึกชุดอุปกรณ์ที่ใช้อยู่ เพื่อสลับชุดสกิน การ์ด และวงล้อแสดงอารมณ์ได้อย่างรวดเร็วในภายหลัง';

  @override
  String get collectionPresetsEmptyTitle => 'ยังไม่มีชุดอุปกรณ์ที่บันทึกไว้';

  @override
  String get collectionPresetsFull =>
      'มีชุดอุปกรณ์ครบสูงสุด 50 ชุดแล้ว ลบบางชุดเพื่อบันทึกเพิ่ม';

  @override
  String get collectionPresetsNote =>
      'ชุดอุปกรณ์จะบันทึกไว้ในอุปกรณ์นี้เท่านั้น สำหรับบัญชีที่เลือก';

  @override
  String get collectionPresetsTitle => 'ชุดอุปกรณ์ที่บันทึกไว้';

  @override
  String get collectionPreview => 'ดูตัวอย่าง';

  @override
  String get collectionPreviewing => 'กำลังดูตัวอย่าง';

  @override
  String get collectionRemoveBuddy => 'ถอดบัดดี้ปืน';

  @override
  String get collectionRenamePreset => 'เปลี่ยนชื่อ';

  @override
  String get collectionRowCard => 'การ์ดผู้เล่น';

  @override
  String get collectionRowExpressions => 'วงล้อแสดงอารมณ์';

  @override
  String get collectionRowLevelBorder => 'กรอบเลเวล';

  @override
  String get collectionRowPresets => 'ชุดอุปกรณ์ที่บันทึกไว้';

  @override
  String get collectionRowTitle => 'ฉายาผู้เล่น';

  @override
  String get collectionRowWeapons => 'ชุดอาวุธ';

  @override
  String get collectionRowWishlist => 'Wishlist';

  @override
  String get collectionSaveFailed => 'บันทึกชุดอุปกรณ์ไม่ได้';

  @override
  String get collectionSavePreset => 'บันทึกชุดอุปกรณ์ปัจจุบัน';

  @override
  String get collectionSaving => 'กำลังบันทึก…';

  @override
  String get collectionSearchBuddies => 'ค้นหาบัดดี้ปืน…';

  @override
  String get collectionSearchCards => 'ค้นหาการ์ดผู้เล่น…';

  @override
  String get collectionSearchFlex => 'ค้นหา Flex…';

  @override
  String get collectionSearchItems => 'ค้นหา…';

  @override
  String get collectionSearchSkins => 'ค้นหาสกิน…';

  @override
  String get collectionSearchSprays => 'ค้นหาสเปรย์…';

  @override
  String get collectionSearchTitles => 'ค้นหาฉายา…';

  @override
  String get collectionSearchWeapons => 'ค้นหาอาวุธ สกิน หรือบัดดี้ปืน…';

  @override
  String get collectionSectionBrowse => 'เรียกดูคอลเลกชัน';

  @override
  String get collectionSectionIdentity => 'ผู้เล่นคนอื่นมองเห็น';

  @override
  String get collectionSectionLoadout => 'ชุดอุปกรณ์';

  @override
  String get collectionSkinCustomizeTitle => 'ปรับแต่งสกิน';

  @override
  String get collectionSkinNotFound => 'ไม่พบสกินนี้';

  @override
  String get collectionSkinNotOwned => 'คุณยังไม่มีสกินนี้';

  @override
  String get collectionSlotNamesItem0 => 'บน';

  @override
  String get collectionSlotNamesItem1 => 'ขวา';

  @override
  String get collectionSlotNamesItem2 => 'ล่าง';

  @override
  String get collectionSlotNamesItem3 => 'ซ้าย';

  @override
  String get collectionSortLabel => 'เรียงลำดับ';

  @override
  String get collectionSortName => 'ชื่อ';

  @override
  String get collectionSortPrice => 'ราคา';

  @override
  String get collectionSortRarity => 'ความหายาก';

  @override
  String get collectionSortWeapon => 'อาวุธ';

  @override
  String collectionSummaryFiltered(int count, String value) {
    return 'กำลังกรอง: สกิน $count ชิ้น · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'กำลังกรอง: $count/$total ไอเทม';
  }

  @override
  String collectionSummaryItems(int count) {
    return '$count ไอเทม';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    return 'สกิน $count ชิ้น · $value';
  }

  @override
  String get collectionTabFlex => 'Flex';

  @override
  String get collectionTabSprays => 'สเปรย์';

  @override
  String get collectionTapToChangeCard => 'แตะเพื่อเปลี่ยนการ์ด';

  @override
  String get collectionTitle => 'คอลเลกชัน';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'มีฉายา $nString รายการ';
  }

  @override
  String get collectionUndo => 'เลิกทำ';

  @override
  String get collectionUnknownCard => 'การ์ดที่ไม่ทราบชื่อ';

  @override
  String get collectionValueAtStorePrices => 'คิดตามราคาในร้านค้า';

  @override
  String get collectionValueHasEstimates => 'รวมราคาประมาณ (≈)';

  @override
  String collectionValueRewardCount(int n) {
    return 'ไม่นับสกินรางวัล $n ชิ้น';
  }

  @override
  String get collectionValueSeeSkins => 'ดูสกิน';

  @override
  String collectionValueSkinCount(int n) {
    return 'คิดจากสกิน $n ชิ้น';
  }

  @override
  String get collectionVariants => 'รูปแบบสี';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return 'อาวุธที่ใช้สกิน $custom/$total';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'ชุดอาวุธ';

  @override
  String get collectionWeaponNotFound => 'ไม่พบอาวุธนี้';

  @override
  String get collectionWeaponSkinsTitle => 'เลือกสกิน';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'สกิน $n ชิ้น',
      zero: 'ว่าง',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'โพสต์ไม่ได้เพราะมีถ้อยคำที่ไม่เหมาะสม แก้ไขโพสต์แล้วลองอีกครั้ง';

  @override
  String get communityModerationContentScam =>
      'ชุมชนไม่อนุญาตให้โฆษณาซื้อขายบัญชี รับจ้างเล่น หรือฝากเบอร์โทรศัพท์ ลบเนื้อหาเหล่านี้แล้วลองอีกครั้ง';

  @override
  String get communityModerationContentTooComplex =>
      'โพสต์ของคุณมีตัวอักษรกระจัดกระจายมากเกินไป เขียนให้กระชับขึ้นแล้วลองอีกครั้ง';

  @override
  String get communityModerationAccountBanned =>
      'บัญชีนี้ถูกระงับสิทธิ์ใช้งานชุมชน หากคิดว่าเป็นความผิดพลาด ติดต่อ ValHub ได้ในเกี่ยวกับและข้อกฎหมาย';

  @override
  String get communityModerationAccountRestricted =>
      'บัญชีนี้ถูกจำกัดการโพสต์ คอมเมนต์ หาเพื่อนร่วมทีม และโหวต ลองอีกครั้งภายหลังหรือติดต่อ ValHub ในเกี่ยวกับและข้อกฎหมาย';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Competitive',
      'unrated': 'Unrated',
      'swiftplay': 'Swiftplay',
      'spikerush': 'Spike Rush',
      'deathmatch': 'Deathmatch',
      'teamdeathmatch': 'Team Deathmatch',
      'premier': 'Premier',
      'custom': 'Custom Game',
      'other': 'อื่นๆ',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'เอเชียแปซิฟิก',
      'na': 'อเมริกาเหนือ',
      'eu': 'ยุโรป',
      'kr': 'เกาหลี',
      'latam': 'ละตินอเมริกา',
      'br': 'บราซิล',
      'other': 'ไม่ทราบภูมิภาค',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => 'ยังไม่มีสกินในอันดับนี้';

  @override
  String get communityRankingEmptyVotes =>
      'ยังไม่มีการกดถูกใจที่ตรงกับขอบเขตและตัวกรองที่เลือก';

  @override
  String get communityRankingEmptyRatings =>
      'ยังไม่มีคะแนนดาวที่ตรงกับขอบเขตและตัวกรองที่เลือก';

  @override
  String get communityRankingEmptyReviews =>
      'ยังไม่มีรีวิวที่ตรงกับขอบเขตและตัวกรองที่เลือก';

  @override
  String get communityRankingExplore => 'ค้นหาสกินเพื่อดูและให้คะแนน';

  @override
  String get communityRankingExploreHint =>
      'ค้นหาตามชื่อสกินหรืออาวุธ เฉพาะคะแนนจริงจากชุมชนเท่านั้นที่จะแสดงในอันดับ';

  @override
  String get communityRankingClear => 'ล้างตัวกรองอาวุธและช่วงเวลา';

  @override
  String get communityRankingPeriod => 'ช่วงเวลา';

  @override
  String get communityRankingSort => 'จัดอันดับตาม';

  @override
  String get communityRankingWeapon => 'อาวุธ';

  @override
  String get communityRankingNoSearch =>
      'ไม่พบสกินที่ตรงกัน ลองชื่ออื่นหรือล้างตัวกรองอาวุธ';

  @override
  String get communityRankingCatalogUnavailable =>
      'โหลดรายการสกินไม่ได้ ปิดหน้านี้แล้วลองอีกครั้งเมื่อซิงค์ข้อมูลเสร็จ';

  @override
  String get communityConsentExitAccount => 'ไม่ยอมรับ · ออกจากระบบบัญชีนี้';

  @override
  String get communityRankingGlobalAllTime => 'ทั่วโลก · ตลอดกาล';

  @override
  String get communityRankingCatalogTitle => 'สกินทั้งหมด';

  @override
  String get communityReviewOwnershipRequired =>
      'บัญชีของคุณต้องมีสกินนี้จึงจะให้คะแนนได้ แต่คุณยังอ่านคะแนนและคอมเมนต์ของชุมชนได้';

  @override
  String get communityReviewOwnershipUnavailable =>
      'ยืนยันไม่ได้ว่าคุณมีสกินนี้ โหลดคอลเลกชันใหม่หรือลองอีกครั้งเมื่อออนไลน์';

  @override
  String get communityReviewLegacyOwnership =>
      'รีวิวเก่า · ยังไม่ยืนยันการเป็นเจ้าของ';

  @override
  String get communityReviewVerifiedOwner =>
      'ยืนยันการเป็นเจ้าของแล้วในตอนรีวิว';

  @override
  String get communitySkinDiscussionHint =>
      'ทุกคนคอมเมนต์ได้ แต่เฉพาะเจ้าของสกินเท่านั้นที่ให้ดาวและเขียนรีวิวได้';

  @override
  String get communityAddPhotos => 'เพิ่มรูปภาพ';

  @override
  String get communityAgentsPicked => 'เอเจนท์ที่เลือก';

  @override
  String get communityAllModes => 'ทั้งหมด';

  @override
  String get communityAllWeapons => 'อาวุธทั้งหมด';

  @override
  String get communityAnonymousBanner => 'กำลังดูแบบไม่ระบุตัวตน';

  @override
  String get communityAnyLanguage => 'ทุกภาษา';

  @override
  String get communityAnyRank => 'ทุกแรงก์';

  @override
  String get communityAnyRole => 'ทุกบทบาท';

  @override
  String get communityApply => 'ใช้';

  @override
  String get communityAutoRefresh => 'รีเฟรชอัตโนมัติทุก 20 วินาที';

  @override
  String get communityBackToMyCountry => 'กลับไปประเทศของฉัน';

  @override
  String get communityBlockAuthor => 'บล็อกในอุปกรณ์นี้';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'ล้าง';

  @override
  String get communityCodeAuto =>
      'เว้นว่างไว้: ValHub จะสร้างโค้ดจากปาร์ตี้ในเกมของคุณเมื่อโพสต์';

  @override
  String get communityCodeAutoFailed =>
      'สร้างโค้ดปาร์ตี้ไม่ได้ เปิด VALORANT หรือกรอกโค้ดเอง';

  @override
  String get communityCodeGenerated => 'สร้างโค้ดจากปาร์ตี้ปัจจุบันของคุณแล้ว';

  @override
  String get communityCodeInvalid =>
      'โค้ดต้องเป็นตัวพิมพ์ใหญ่หรือตัวเลข 6 ตัวพอดี';

  @override
  String get communityCodeRequired => 'กรอกหรือสร้างโค้ดปาร์ตี้';

  @override
  String get communityComment => 'คอมเมนต์';

  @override
  String get communityCommentHint => 'เขียนคอมเมนต์…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'คอมเมนต์ $nString รายการ';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'คอมเมนต์ · $n';
  }

  @override
  String get communityCommentsTitle => 'คอมเมนต์';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return 'โพสต์: $posts · ผู้เล่น: $authors';
  }

  @override
  String communityCommunityLfg(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'โพสต์หาเพื่อนร่วมทีม $nString โพสต์';
  }

  @override
  String get communityCommunityVotes => 'ชุมชนชื่นชอบ';

  @override
  String get communityComposerHint => 'วันนี้คุณคิดอะไรเกี่ยวกับ VALORANT อยู่';

  @override
  String get communityComposerTitle => 'โพสต์ใหม่';

  @override
  String communityConsentAccount(String riotId) {
    return 'บัญชี: $riotId';
  }

  @override
  String get communityConsentAgree => 'ยอมรับและดำเนินการต่อ';

  @override
  String get communityConsentGateAction => 'เข้าร่วม';

  @override
  String get communityConsentGuidelines => 'แนวทางของชุมชน';

  @override
  String get communityConsentLater => 'ไว้ทีหลัง';

  @override
  String get communityConsentLocal =>
      'รหัสผ่านและข้อมูลเข้าสู่ระบบอื่นๆ ของคุณจะอยู่ในอุปกรณ์นี้เสมอ คุณถอนความยินยอมได้ในการตั้งค่า';

  @override
  String get communityConsentPrivacy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get communityConsentPublic =>
      'ผู้อื่นจะเห็น Riot ID การ์ดผู้เล่น แรงก์ และประเทศของคุณ';

  @override
  String get communityConsentTitle => 'ความเป็นส่วนตัวและชุมชน ValHub';

  @override
  String get communityConsentVerify =>
      'ValHub จะส่งสิทธิ์เข้าถึง Riot ของคุณไปยังเซิร์ฟเวอร์ชุมชน เพื่อยืนยัน Riot ID เมื่อเชื่อมต่อ และตรวจสอบการเป็นเจ้าของสกินเมื่อคุณบันทึกรีวิว เซิร์ฟเวอร์จะอ่านเฉพาะข้อมูลที่จำเป็น ทิ้งสิทธิ์เข้าถึงทันทีหลังใช้งาน และไม่จัดเก็บไว้';

  @override
  String get communityConsentWithdrawn =>
      'ถอนความยินยอมแล้ว คุณต้องยอมรับอีกครั้งเพื่อใช้แอปต่อ';

  @override
  String get communityCountriesEmpty => 'ไม่พบประเทศที่ตรงกัน';

  @override
  String get communityCountriesSearchHint => 'ค้นหาประเทศ…';

  @override
  String get communityCountriesTitle => 'ชุมชนตามประเทศ';

  @override
  String get communityCountryNamesAE => 'สหรัฐอาหรับเอมิเรตส์';

  @override
  String get communityCountryNamesAL => 'แอลเบเนีย';

  @override
  String get communityCountryNamesAM => 'อาร์เมเนีย';

  @override
  String get communityCountryNamesAR => 'อาร์เจนตินา';

  @override
  String get communityCountryNamesAT => 'ออสเตรีย';

  @override
  String get communityCountryNamesAU => 'ออสเตรเลีย';

  @override
  String get communityCountryNamesAZ => 'อาเซอร์ไบจาน';

  @override
  String get communityCountryNamesBA => 'บอสเนียและเฮอร์เซโกวีนา';

  @override
  String get communityCountryNamesBD => 'บังกลาเทศ';

  @override
  String get communityCountryNamesBE => 'เบลเยียม';

  @override
  String get communityCountryNamesBG => 'บัลแกเรีย';

  @override
  String get communityCountryNamesBH => 'บาห์เรน';

  @override
  String get communityCountryNamesBN => 'บรูไน';

  @override
  String get communityCountryNamesBO => 'โบลิเวีย';

  @override
  String get communityCountryNamesBR => 'บราซิล';

  @override
  String get communityCountryNamesBY => 'เบลารุส';

  @override
  String get communityCountryNamesCA => 'แคนาดา';

  @override
  String get communityCountryNamesCH => 'สวิตเซอร์แลนด์';

  @override
  String get communityCountryNamesCL => 'ชิลี';

  @override
  String get communityCountryNamesCN => 'จีน';

  @override
  String get communityCountryNamesCO => 'โคลอมเบีย';

  @override
  String get communityCountryNamesCR => 'คอสตาริกา';

  @override
  String get communityCountryNamesCU => 'คิวบา';

  @override
  String get communityCountryNamesCY => 'ไซปรัส';

  @override
  String get communityCountryNamesCZ => 'เช็กเกีย';

  @override
  String get communityCountryNamesDE => 'เยอรมนี';

  @override
  String get communityCountryNamesDK => 'เดนมาร์ก';

  @override
  String get communityCountryNamesDO => 'สาธารณรัฐโดมินิกัน';

  @override
  String get communityCountryNamesDZ => 'แอลจีเรีย';

  @override
  String get communityCountryNamesEC => 'เอกวาดอร์';

  @override
  String get communityCountryNamesEE => 'เอสโตเนีย';

  @override
  String get communityCountryNamesEG => 'อียิปต์';

  @override
  String get communityCountryNamesES => 'สเปน';

  @override
  String get communityCountryNamesET => 'เอธิโอเปีย';

  @override
  String get communityCountryNamesFI => 'ฟินแลนด์';

  @override
  String get communityCountryNamesFR => 'ฝรั่งเศส';

  @override
  String get communityCountryNamesGB => 'สหราชอาณาจักร';

  @override
  String get communityCountryNamesGE => 'จอร์เจีย';

  @override
  String get communityCountryNamesGH => 'กานา';

  @override
  String get communityCountryNamesGR => 'กรีซ';

  @override
  String get communityCountryNamesGT => 'กัวเตมาลา';

  @override
  String get communityCountryNamesHK => 'ฮ่องกง';

  @override
  String get communityCountryNamesHN => 'ฮอนดูรัส';

  @override
  String get communityCountryNamesHR => 'โครเอเชีย';

  @override
  String get communityCountryNamesHU => 'ฮังการี';

  @override
  String get communityCountryNamesID => 'อินโดนีเซีย';

  @override
  String get communityCountryNamesIE => 'ไอร์แลนด์';

  @override
  String get communityCountryNamesIL => 'อิสราเอล';

  @override
  String get communityCountryNamesIN => 'อินเดีย';

  @override
  String get communityCountryNamesIQ => 'อิรัก';

  @override
  String get communityCountryNamesIR => 'อิหร่าน';

  @override
  String get communityCountryNamesIS => 'ไอซ์แลนด์';

  @override
  String get communityCountryNamesIT => 'อิตาลี';

  @override
  String get communityCountryNamesJO => 'จอร์แดน';

  @override
  String get communityCountryNamesJP => 'ญี่ปุ่น';

  @override
  String get communityCountryNamesKE => 'เคนยา';

  @override
  String get communityCountryNamesKH => 'กัมพูชา';

  @override
  String get communityCountryNamesKR => 'เกาหลีใต้';

  @override
  String get communityCountryNamesKW => 'คูเวต';

  @override
  String get communityCountryNamesKZ => 'คาซัคสถาน';

  @override
  String get communityCountryNamesLA => 'ลาว';

  @override
  String get communityCountryNamesLB => 'เลบานอน';

  @override
  String get communityCountryNamesLK => 'ศรีลังกา';

  @override
  String get communityCountryNamesLT => 'ลิทัวเนีย';

  @override
  String get communityCountryNamesLU => 'ลักเซมเบิร์ก';

  @override
  String get communityCountryNamesLV => 'ลัตเวีย';

  @override
  String get communityCountryNamesLY => 'ลิเบีย';

  @override
  String get communityCountryNamesMA => 'โมร็อกโก';

  @override
  String get communityCountryNamesMD => 'มอลโดวา';

  @override
  String get communityCountryNamesME => 'มอนเตเนโกร';

  @override
  String get communityCountryNamesMK => 'มาซิโดเนียเหนือ';

  @override
  String get communityCountryNamesMM => 'เมียนมา';

  @override
  String get communityCountryNamesMN => 'มองโกเลีย';

  @override
  String get communityCountryNamesMO => 'มาเก๊า';

  @override
  String get communityCountryNamesMT => 'มอลตา';

  @override
  String get communityCountryNamesMX => 'เม็กซิโก';

  @override
  String get communityCountryNamesMY => 'มาเลเซีย';

  @override
  String get communityCountryNamesNG => 'ไนจีเรีย';

  @override
  String get communityCountryNamesNI => 'นิการากัว';

  @override
  String get communityCountryNamesNL => 'เนเธอร์แลนด์';

  @override
  String get communityCountryNamesNO => 'นอร์เวย์';

  @override
  String get communityCountryNamesNP => 'เนปาล';

  @override
  String get communityCountryNamesNZ => 'นิวซีแลนด์';

  @override
  String get communityCountryNamesOM => 'โอมาน';

  @override
  String get communityCountryNamesPA => 'ปานามา';

  @override
  String get communityCountryNamesPE => 'เปรู';

  @override
  String get communityCountryNamesPH => 'ฟิลิปปินส์';

  @override
  String get communityCountryNamesPK => 'ปากีสถาน';

  @override
  String get communityCountryNamesPL => 'โปแลนด์';

  @override
  String get communityCountryNamesPR => 'เปอร์โตริโก';

  @override
  String get communityCountryNamesPT => 'โปรตุเกส';

  @override
  String get communityCountryNamesPY => 'ปารากวัย';

  @override
  String get communityCountryNamesQA => 'กาตาร์';

  @override
  String get communityCountryNamesRO => 'โรมาเนีย';

  @override
  String get communityCountryNamesRS => 'เซอร์เบีย';

  @override
  String get communityCountryNamesRU => 'รัสเซีย';

  @override
  String get communityCountryNamesSA => 'ซาอุดีอาระเบีย';

  @override
  String get communityCountryNamesSE => 'สวีเดน';

  @override
  String get communityCountryNamesSG => 'สิงคโปร์';

  @override
  String get communityCountryNamesSI => 'สโลวีเนีย';

  @override
  String get communityCountryNamesSK => 'สโลวาเกีย';

  @override
  String get communityCountryNamesSV => 'เอลซัลวาดอร์';

  @override
  String get communityCountryNamesTH => 'ไทย';

  @override
  String get communityCountryNamesTL => 'ติมอร์-เลสเต';

  @override
  String get communityCountryNamesTN => 'ตูนิเซีย';

  @override
  String get communityCountryNamesTR => 'ตุรกี';

  @override
  String get communityCountryNamesTW => 'ไต้หวัน';

  @override
  String get communityCountryNamesUA => 'ยูเครน';

  @override
  String get communityCountryNamesUS => 'สหรัฐอเมริกา';

  @override
  String get communityCountryNamesUY => 'อุรุกวัย';

  @override
  String get communityCountryNamesUZ => 'อุซเบกิสถาน';

  @override
  String get communityCountryNamesVE => 'เวเนซุเอลา';

  @override
  String get communityCountryNamesVN => 'เวียดนาม';

  @override
  String get communityCountryNamesZA => 'แอฟริกาใต้';

  @override
  String get communityCreateLfg => 'สร้างโพสต์หาเพื่อนร่วมทีม';

  @override
  String get communityCreateLfgShort => 'โพสต์';

  @override
  String get communityDataDeleted => 'ลบข้อมูลชุมชนของคุณแล้ว';

  @override
  String communityDataFooter(String riotId) {
    return 'ใช้กับบัญชีที่ใช้อยู่: $riotId ไฟล์ที่ดาวน์โหลดจะไม่มีรหัสผ่านหรือข้อมูลเข้าสู่ระบบ Riot';
  }

  @override
  String get communityDataTitle => 'ข้อมูลชุมชนของคุณ';

  @override
  String get communityDecrease => 'ลด';

  @override
  String get communityDelete => 'ลบ';

  @override
  String get communityDeleteComment => 'ลบคอมเมนต์';

  @override
  String get communityDeleteCommentBody => 'คอมเมนต์นี้จะถูกลบอย่างถาวร';

  @override
  String get communityDeleteCommentTitle => 'ลบคอมเมนต์ไหม';

  @override
  String get communityDeleteDataConfirm => 'ลบอย่างถาวร';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'โพสต์ คอมเมนต์ รีวิวสกิน ไลก์ โหวต โพสต์หาเพื่อนร่วมทีม และรูปภาพทั้งหมดของ $riotId ในชุมชน ValHub จะถูกลบอย่างถาวรและกู้คืนไม่ได้ คุณจะกลับไปดูแบบไม่ระบุตัวตน และต้องยอมรับอีกครั้งหากต้องการเข้าร่วมใหม่\n\nบัญชี Riot และข้อมูลในเกมจะไม่ได้รับผลกระทบ ดาวน์โหลดข้อมูลของคุณก่อนหากต้องการเก็บสำเนาไว้';
  }

  @override
  String get communityDeleteDataConfirmTitle => 'ลบข้อมูลชุมชนไหม';

  @override
  String get communityDeleteDataSubtitle =>
      'ลบทุกอย่างที่คุณโพสต์ในชุมชนอย่างถาวร';

  @override
  String get communityDeleteDataTitle => 'ลบข้อมูลชุมชนของฉัน';

  @override
  String get communityDeletePost => 'ลบโพสต์';

  @override
  String get communityDeletePostBody =>
      'โพสต์นี้และคอมเมนต์ทั้งหมดจะถูกลบอย่างถาวร';

  @override
  String get communityDeletePostTitle => 'ลบโพสต์ไหม';

  @override
  String get communityDeleteReview => 'ลบรีวิว';

  @override
  String get communityDeleteReviewBody =>
      'คะแนนและรีวิวของคุณสำหรับสกินนี้จะถูกลบ';

  @override
  String get communityDeleteReviewTitle => 'ลบรีวิวของคุณไหม';

  @override
  String get communityDeleted => 'ลบแล้ว';

  @override
  String get communityDiscard => 'ทิ้ง';

  @override
  String get communityDiscardBody => 'สิ่งที่คุณเพิ่งเขียนจะไม่ถูกบันทึก';

  @override
  String get communityDiscardTitle => 'ทิ้งโพสต์ไหม';

  @override
  String get communityDownload => 'ดาวน์โหลดและแปล';

  @override
  String get communityDownloadingModels => 'กำลังดาวน์โหลดแพ็กภาษา…';

  @override
  String get communityEditReview => 'แก้ไข';

  @override
  String get communityEdited => 'แก้ไขแล้ว';

  @override
  String get communityEmptyPost => 'เขียนอะไรสักอย่างหรือเพิ่มรูปภาพ';

  @override
  String get communityExpired => 'หมดอายุแล้ว';

  @override
  String communityExpiresIn(String t) {
    return 'เหลือ $t';
  }

  @override
  String get communityExportPreparing => 'กำลังเตรียม…';

  @override
  String get communityExportSubject => 'ข้อมูลชุมชน ValHub';

  @override
  String get communityExportSubtitle =>
      'สำเนาของทุกอย่างที่คุณโพสต์ในชุมชน: โพสต์ คอมเมนต์ รีวิว ไลก์ โหวต และโพสต์หาเพื่อนร่วมทีม';

  @override
  String get communityExportTitle => 'ดาวน์โหลดข้อมูลของฉัน';

  @override
  String get communityExtend => 'ต่อเวลา';

  @override
  String get communityExtended => 'ต่อเวลาโพสต์อีก 30 นาทีแล้ว';

  @override
  String get communityFeedEmptyBody =>
      'มาเป็นคนแรกที่แชร์ร้านค้า ไนท์มาร์เก็ต หรือช่วงเวลาเด็ดของคุณ!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'ไม่มีโพสต์ที่ตรงกัน ลองเปลี่ยนภาษาหรือล้างตัวกรอง';

  @override
  String get communityFeedEmptyGuestBody =>
      'ยังไม่มีโพสต์ใหม่ กลับมาดูใหม่ภายหลังหรือเข้าร่วมเพื่อแชร์';

  @override
  String get communityFeedEmptyScopeBody =>
      'ลองดูโพสต์จากชุมชนนานาชาติหรือเปลี่ยนตัวกรอง';

  @override
  String get communityFeedEmptyScopeTitle => 'ยังไม่มีโพสต์ในส่วนนี้';

  @override
  String get communityFeedEmptyTitle => 'ฟีดยังว่างอยู่';

  @override
  String get communityFilters => 'ตัวกรอง';

  @override
  String get communityGenerateCode => 'สร้างโค้ดปาร์ตี้';

  @override
  String get communityGeneratingCode => 'กำลังสร้างโค้ด…';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'แปลโดย Google';

  @override
  String get communityHelpful => 'มีประโยชน์';

  @override
  String communityHelpfulCount(String n) {
    return 'มีประโยชน์ · $n';
  }

  @override
  String get communityHiddenAuthors => 'ผู้เล่นที่ซ่อนและบล็อกไว้';

  @override
  String get communityHiddenAuthorsEmpty => 'คุณยังไม่ได้ซ่อนหรือบล็อกใคร';

  @override
  String get communityHiddenAuthorsHint =>
      'ใช้กับบัญชีนี้ในอุปกรณ์นี้เท่านั้น เนื้อหาของพวกเขาจะถูกซ่อน แต่พวกเขายังเห็นเนื้อหาสาธารณะของคุณได้';

  @override
  String communityImageOf(int i, int n) {
    return 'รูปที่ $i/$n';
  }

  @override
  String get communityIncrease => 'เพิ่ม';

  @override
  String get communityJoin => 'เข้าร่วม';

  @override
  String get communityJoinCodeExpired => 'โค้ดปาร์ตี้หมดอายุหรือใช้ไม่ได้แล้ว';

  @override
  String communityJoinConfirmBody(String name) {
    return 'คุณจะออกจากปาร์ตี้ VALORANT ปัจจุบันเพื่อเข้าร่วมปาร์ตี้ของ $name';
  }

  @override
  String get communityJoinConfirmTitle => 'เข้าร่วมปาร์ตี้นี้ไหม';

  @override
  String get communityJoinGameNotRunning =>
      'เปิด VALORANT บน PC หรือคอนโซลแล้วลองอีกครั้ง';

  @override
  String get communityJoinInvalidCode =>
      'โค้ดปาร์ตี้ใช้ไม่ได้แล้วหรือปาร์ตี้เต็มแล้ว';

  @override
  String get communityJoinParty => 'เข้าร่วมปาร์ตี้';

  @override
  String get communityJoinPartyFull => 'ปาร์ตี้นี้เต็มแล้ว';

  @override
  String get communityJoined =>
      'เข้าร่วมปาร์ตี้แล้ว! เปิด VALORANT เพื่อเล่นด้วยกัน';

  @override
  String get communityJoinedHint =>
      'เข้าร่วมปาร์ตี้แล้ว! เปิด VALORANT เพื่อเล่นด้วยกัน';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'คำขอเข้าร่วม $nString รายการ';
  }

  @override
  String get communityKeepEditing => 'เขียนต่อ';

  @override
  String get communityKindNightMarket => 'ไนท์มาร์เก็ต';

  @override
  String get communityKindStore => 'ร้านค้าวันนี้';

  @override
  String get communityLanguage => 'ภาษา';

  @override
  String get communityLanguageFilter => 'ภาษาของเนื้อหา';

  @override
  String get communityLanguageFilterHint =>
      'แสดงเฉพาะเนื้อหาที่เขียนด้วยภาษาที่เลือก เว้นว่างไว้เพื่อดูทั้งหมด';

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
    return '$n ภาษา';
  }

  @override
  String get communityLfgEmptyBody =>
      'สร้างโพสต์เพื่อให้ผู้เล่นคนอื่นเข้าร่วมปาร์ตี้ของคุณได้ในแตะเดียว';

  @override
  String get communityLfgEmptyTitle => 'ยังไม่มีใครหาเพื่อนร่วมทีม';

  @override
  String get communityLfgExpiredRepost =>
      'โพสต์ของคุณหมดอายุแล้ว สร้างโพสต์ใหม่เพื่อหาเพื่อนร่วมทีม';

  @override
  String get communityLfgExpiryNote => 'โพสต์จะหมดอายุอัตโนมัติหลัง 30 นาที';

  @override
  String get communityLfgGateBody =>
      'เข้าร่วม (ยืนยัน Riot ID ครั้งเดียว) เพื่อดูโพสต์ของผู้เล่นในเซิร์ฟเวอร์เดียวกันและโพสต์หาเพื่อนร่วมทีมของคุณเอง คุณยังดูฟีดและอันดับสกินได้ตามปกติ';

  @override
  String get communityLfgGateTitle => 'หาเพื่อนร่วมทีมสำหรับสมาชิกเท่านั้น';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'คุณกำลังดูเซิร์ฟเวอร์ $region — เฉพาะผู้เล่นที่อยู่เซิร์ฟเวอร์เดียวกับบัญชีของคุณเท่านั้นที่เข้าร่วมปาร์ตี้ได้';
  }

  @override
  String get communityLfgPosted => 'โพสต์หาเพื่อนร่วมทีมแล้ว!';

  @override
  String get communityLfgPreviewTitle => 'หาเพื่อนร่วมทีมแรงก์ใกล้เคียง';

  @override
  String get communityLfgRemoved => 'ลบโพสต์แล้ว';

  @override
  String get communityLfgSameShardNote =>
      'เฉพาะผู้เล่นในเซิร์ฟเวอร์เดียวกันเท่านั้นที่เข้าร่วมปาร์ตี้ได้';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'ภูมิภาค: $region · โพสต์จะหมดอายุอัตโนมัติหลัง 30 นาที';
  }

  @override
  String get communityLike => 'ถูกใจ';

  @override
  String communityLikes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ถูกใจ $nString ครั้ง';
  }

  @override
  String get communityLiveMembers => 'สมาชิก';

  @override
  String get communityLoadMoreFailed => 'โหลดโพสต์เพิ่มไม่ได้ ลองอีกครั้ง';

  @override
  String get communityMatchMyRank => 'ตรงกับแรงก์ของคุณ';

  @override
  String communityMaxPhotos(int max) {
    return 'สูงสุด $max รูป';
  }

  @override
  String communityMemberJoined(String name) {
    return '$name เข้าร่วมปาร์ตี้แล้ว';
  }

  @override
  String get communityMemberJoinedBody =>
      'มีคนเพิ่งเข้าร่วมจากโพสต์หาเพื่อนร่วมทีมของคุณ';

  @override
  String get communityMic => 'ต้องมีไมค์';

  @override
  String get communityMicOn => 'มีไมค์';

  @override
  String get communityMode => 'โหมด';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => 'ตัวเลือกเพิ่มเติม';

  @override
  String get communityMuteAuthor => 'ซ่อนผู้เล่นนี้';

  @override
  String get communityMyPost => 'โพสต์ของคุณ';

  @override
  String get communityNewPost => 'โพสต์';

  @override
  String communityNightMarketOf(String date) {
    return 'ไนท์มาร์เก็ตวันที่ $date';
  }

  @override
  String get communityNoAccountBody =>
      'เพิ่มบัญชี Riot เพื่อโพสต์ หาเพื่อนร่วมทีม และโหวตสกิน';

  @override
  String get communityNoAccountTitle => 'เข้าสู่ระบบเพื่อเข้าร่วม';

  @override
  String get communityNoComments =>
      'ยังไม่มีคอมเมนต์ มาเป็นคนแรกที่พูดอะไรสักอย่าง!';

  @override
  String get communityNoParty =>
      'ไม่พบปาร์ตี้ของคุณ เปิด VALORANT แล้วลองอีกครั้ง หรือกรอกโค้ดเอง';

  @override
  String communityNoPartyWithReason(String reason) {
    return 'ไม่พบปาร์ตี้ของคุณ เปิด VALORANT แล้วลองอีกครั้ง หรือกรอกโค้ดเอง\n$reason';
  }

  @override
  String get communityNoRatings => 'ยังไม่มีคะแนน';

  @override
  String get communityNote => 'หมายเหตุ';

  @override
  String get communityNoteHint =>
      'เช่น ต้องการ Controller 1 คน มีไมค์ เน้นเล่นสนุก';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'รวม $amount';
  }

  @override
  String get communityOpenReviews => 'ดูรีวิว';

  @override
  String get communityOutOfRange => 'อยู่นอกช่วงแรงก์';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'โค้ดปาร์ตี้';

  @override
  String get communityPartyCodeHint => 'เช่น A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'โค้ดปาร์ตี้: $code';
  }

  @override
  String get communityPartySize => 'ปาร์ตี้ปัจจุบัน';

  @override
  String get communityPartySizeFromGame => 'ดึงจากปาร์ตี้ในเกมของคุณ';

  @override
  String communityPartySizeValue(int n) {
    return '$n คน';
  }

  @override
  String get communityPeriodAll => 'ทั้งหมด';

  @override
  String get communityPeriodAllTime => 'ตลอดกาล';

  @override
  String get communityPeriodWeek => 'สัปดาห์นี้';

  @override
  String communityPhotoCount(int n, int max) {
    return '$n/$max รูป';
  }

  @override
  String get communityPickRating => 'เลือกจำนวนดาว';

  @override
  String get communityPlayVideo => 'ดูวิดีโอ';

  @override
  String get communityPostLfg => 'โพสต์';

  @override
  String get communityPostNotFound => 'โพสต์นี้ถูกลบหรือซ่อนแล้ว';

  @override
  String get communityPostTitle => 'โพสต์';

  @override
  String get communityPosted => 'โพสต์แล้ว!';

  @override
  String get communityPrivacyNote =>
      'ValHub จะยืนยัน Riot ID เมื่อคุณเชื่อมต่อชุมชน และยืนยันการเป็นเจ้าของสกินเมื่อคุณรีวิว ชุมชนไม่เคยจัดเก็บรหัสผ่านหรือข้อมูลเข้าสู่ระบบ Riot ของคุณ';

  @override
  String get communityPublish => 'โพสต์';

  @override
  String get communityPublishing => 'กำลังโพสต์…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'จาก';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'ช่วงแรงก์';

  @override
  String get communityRankRangeInvalid =>
      'แรงก์ต่ำสุดต้องไม่สูงกว่าแรงก์สูงสุด';

  @override
  String communityRankSemantics(String n, String name) {
    return 'อันดับ $n: $name';
  }

  @override
  String get communityRankTo => 'ถึง';

  @override
  String get communityRateLimitedTitle => 'รอสักครู่';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ให้คะแนน $nString ครั้ง';
  }

  @override
  String communityRatingSummary(String avg, int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$avg · ให้คะแนน $nString ครั้ง';
  }

  @override
  String get communityRatingWordsItem0 => 'แย่';

  @override
  String get communityRatingWordsItem1 => 'ไม่ค่อยดี';

  @override
  String get communityRatingWordsItem2 => 'พอใช้';

  @override
  String get communityRatingWordsItem3 => 'สวย';

  @override
  String get communityRatingWordsItem4 => 'สุดยอด';

  @override
  String get communityRefreshList => 'รีเฟรช';

  @override
  String get communityRegion => 'ภูมิภาค';

  @override
  String get communityRemoveAttachment => 'ลบไฟล์แนบ';

  @override
  String get communityRemoveLfg => 'ลบโพสต์';

  @override
  String get communityRemoveLfgBody => 'ผู้เล่นคนอื่นจะไม่เห็นโพสต์นี้อีก';

  @override
  String get communityRemoveLfgTitle => 'ลบโพสต์หาเพื่อนร่วมทีมไหม';

  @override
  String get communityRemovePhoto => 'ลบรูปภาพ';

  @override
  String get communityReport => 'รายงาน';

  @override
  String get communityReportConfirmBody =>
      'เนื้อหาที่ถูกรายงานโดยผู้เล่นจำนวนมากจะถูกซ่อนจากชุมชน';

  @override
  String get communityReportConfirmTitle => 'ส่งรายงานไหม';

  @override
  String get communityReportPrompt => 'ทำไมคุณจึงรายงานเนื้อหานี้';

  @override
  String get communityReportReasonsSpam => 'สแปมหรือโฆษณา';

  @override
  String get communityReportReasonsHarassment => 'คุกคามหรือดูหมิ่น';

  @override
  String get communityReportReasonsInappropriate => 'เนื้อหาไม่เหมาะสม';

  @override
  String get communityReportReasonsScam => 'หลอกลวงหรือซื้อขายบัญชี';

  @override
  String get communityReportReasonsOther => 'เหตุผลอื่น';

  @override
  String get communityReportTitle => 'รายงานเนื้อหา';

  @override
  String get communityReported => 'ขอบคุณ! ส่งรายงานของคุณแล้ว';

  @override
  String get communityRetry => 'ลองอีกครั้ง';

  @override
  String get communityReviewDeleted => 'ลบรีวิวแล้ว';

  @override
  String get communityReviewHint => 'แชร์ความเห็นเกี่ยวกับสกินนี้ (ไม่บังคับ)';

  @override
  String get communityReviewSaved => 'บันทึกรีวิวแล้ว!';

  @override
  String get communityReviewTitle => 'ให้คะแนนสกิน';

  @override
  String get communityReviewsEmptyBody => 'ยังไม่มีรีวิว — มาเป็นคนแรกกัน!';

  @override
  String get communityReviewsEmptyTitle => 'ยังไม่มีรีวิว';

  @override
  String communityReviewsHeader(String n) {
    return 'รีวิว · $n';
  }

  @override
  String get communityReviewsSection => 'รีวิว';

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot กำลังมีปัญหา';

  @override
  String get communityRoleFlex => 'เล่นได้ทุกบทบาท';

  @override
  String get communityRoles => 'บทบาทที่ต้องการ';

  @override
  String get communitySaveReview => 'บันทึกรีวิว';

  @override
  String get communityScopeCountry => 'ประเทศของคุณ';

  @override
  String get communityScopeGlobal => 'นานาชาติ';

  @override
  String get communityScopeRegion => 'ภูมิภาค';

  @override
  String get communityScopeWorldwide => 'ทั่วโลก';

  @override
  String get communitySectionFeed => 'ฟีด';

  @override
  String get communitySectionLfg => 'หาเพื่อนร่วมทีม';

  @override
  String get communitySectionSkins => 'อันดับสกิน';

  @override
  String get communitySend => 'ส่ง';

  @override
  String get communitySendComment => 'ส่งคอมเมนต์';

  @override
  String get communityShareNightMarketHint => 'อวดไนท์มาร์เก็ตของคุณให้ทุกคนดู';

  @override
  String communitySharePostTitle(String name) {
    return 'โพสต์ของ $name บน ValHub';
  }

  @override
  String get communityShareStore => 'แชร์ไปที่ชุมชน';

  @override
  String get communityShareStoreHint => 'อวดร้านค้าวันนี้ให้ทุกคนดู';

  @override
  String get communityShowOriginal => 'ดูต้นฉบับ';

  @override
  String get communityShowTranslation => 'ดูคำแปล';

  @override
  String get communitySignInToReview => 'เพิ่มบัญชี Riot เพื่อให้คะแนนสกิน';

  @override
  String get communitySkinNotFound => 'ไม่พบสกินนี้';

  @override
  String get communitySkinsEmptyBody =>
      'กดหัวใจให้สกินที่คุณชอบที่สุดเพื่อดันขึ้นอันดับ!';

  @override
  String get communitySkinsEmptyTitle => 'ยังไม่มีการโหวต';

  @override
  String get communitySlots => 'จำนวนผู้เล่นที่ต้องการ';

  @override
  String communitySlotsTooMany(int max) {
    return 'ปาร์ตี้มีได้สูงสุด 5 คน: เหลือที่ว่างเพียง $max ที่';
  }

  @override
  String communitySlotsWanted(int n) {
    return 'ต้องการ $n คน';
  }

  @override
  String get communitySortHelpful => 'มีประโยชน์ที่สุด';

  @override
  String get communitySortNewest => 'ใหม่ล่าสุด';

  @override
  String get communitySortRating => 'คะแนนสูงสุด';

  @override
  String get communitySortReviews => 'รีวิวมากที่สุด';

  @override
  String get communitySortVotes => 'ถูกใจมากที่สุด';

  @override
  String communityStarLabel(int n) {
    return '$n ดาว';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg จาก 5 ดาว';
  }

  @override
  String get communityStatusFull => 'เต็มแล้ว';

  @override
  String get communityStatusInGame => 'อยู่ในแมตช์';

  @override
  String get communityStatusOpen => 'กำลังหา';

  @override
  String communityStoreOf(String date) {
    return 'ร้านค้าวันที่ $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => 'แตะดาวเพื่อให้คะแนนสกินนี้';

  @override
  String get communityTitle => 'ชุมชน';

  @override
  String communityTooLong(int max) {
    return 'สูงสุด $max ตัวอักษร';
  }

  @override
  String get communityTranslate => 'แปลด้วย Google';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'หากต้องการแปลจาก$fromเป็น$to ValHub ต้องดาวน์โหลดแพ็กภาษาจาก Google (ประมาณ $size) ดาวน์โหลดเพียงครั้งเดียว เนื้อหาจะถูกแปลในอุปกรณ์ของคุณทั้งหมดและไม่ส่งไปยังเซิร์ฟเวอร์ใด';
  }

  @override
  String get communityTranslateDownloadTitle => 'ดาวน์โหลดแพ็กภาษาลงอุปกรณ์ไหม';

  @override
  String get communityTranslateFailed => 'แปลไม่ได้ ลองอีกครั้ง';

  @override
  String get communityTranslateUnavailable =>
      'อุปกรณ์นี้ยังไม่รองรับการแปลในเครื่อง';

  @override
  String get communityTranslatedByGoogle => 'แปลอัตโนมัติโดย Google';

  @override
  String get communityTranslating => 'กำลังแปล…';

  @override
  String get communityTrendingTitle => 'สกินที่ถูกใจที่สุดทั่วโลก';

  @override
  String get communityUnavailableBody =>
      'เชื่อมต่อชุมชน ValHub ไม่ได้ ลองอีกครั้งในอีกสักครู่';

  @override
  String get communityUnavailableTitle => 'เชื่อมต่อชุมชนไม่ได้';

  @override
  String get communityUnhideAuthor => 'เลิกซ่อน / เลิกบล็อก';

  @override
  String get communityUnknownPlayer => 'ผู้เล่น';

  @override
  String get communityUnlike => 'เลิกถูกใจ';

  @override
  String get communityUnvote => 'เอาหัวใจออก';

  @override
  String get communityUploading => 'กำลังอัปโหลดรูปภาพ…';

  @override
  String get communityViewImage => 'ดูรูปภาพ';

  @override
  String get communityVote => 'กดหัวใจให้สกินนี้';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ถูกใจ $nString ครั้ง';
  }

  @override
  String get communityWithdrawConfirm => 'ถอน';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub จะหยุดใช้ชุมชนด้วย $riotId การเชื่อมต่อชุมชนในอุปกรณ์นี้จะถูกลบ และคุณจะกลับไปดูแบบไม่ระบุตัวตน\n\nโพสต์ คอมเมนต์ รีวิว โหวต และโพสต์หาเพื่อนร่วมทีมที่คุณเผยแพร่ไว้จะยังอยู่ในชุมชนและยังแสดง Riot ID ของคุณ จนกว่าคุณจะลบทีละรายการ หรือเลือก \"ลบข้อมูลชุมชนของฉัน\" คุณเข้าร่วมใหม่ได้ทุกเมื่อ';
  }

  @override
  String get communityWithdrawConfirmTitle => 'ถอนความยินยอมไหม';

  @override
  String get communityWithdrawSubtitle =>
      'หยุดใช้ชุมชนด้วยบัญชีนี้ โพสต์ของคุณจะยังคงอยู่';

  @override
  String get communityWithdrawTitle => 'ถอนความยินยอม';

  @override
  String get communityWriteFirstReview => 'เขียนรีวิวแรก';

  @override
  String get communityWritePost => 'เขียนโพสต์';

  @override
  String get communityYou => 'คุณ';

  @override
  String get communityYourCountry => 'ประเทศของคุณ';

  @override
  String get communityYourReview => 'รีวิวของคุณ';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'คุณ: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentNotOwned => 'คุณยังไม่มีเอเจนท์นี้';

  @override
  String get liveGameAgentSelect => 'เลือกเอเจนท์';

  @override
  String get liveGameAgentTaken => 'เพื่อนร่วมทีมล็อกเอเจนท์นี้ไปแล้ว';

  @override
  String get liveGameAnonymous => 'ไม่ระบุตัวตน';

  @override
  String get liveGameAutoRefreshNote => 'รีเฟรชอัตโนมัติเมื่อคุณอยู่ในแมตช์';

  @override
  String get liveGameBuddy => 'บัดดี้ปืน';

  @override
  String get liveGameClose => 'ปิด';

  @override
  String get liveGameCurrentGame => 'แมตช์ปัจจุบัน';

  @override
  String get liveGameEmptyTeam => 'ยังไม่มีผู้เล่น';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'ทีมศัตรูจะแสดงเมื่อแมตช์เริ่ม';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'ทีมศัตรูล็อกแล้ว $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'ข้อมูลแมตช์สดนี้ไม่มีค่าสังหาร/ตาย/ช่วยเหลือ กระดานคะแนนจะแสดงเมื่อ Riot เผยแพร่ข้อมูลหลังแมตช์';

  @override
  String get liveGameFinalScoreboard => 'กระดานคะแนนจบแมตช์';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameHoverLockHint => 'แตะเพื่อเลือก กดค้างเพื่อล็อก';

  @override
  String get liveGameInLobby => 'อยู่ในล็อบบี้';

  @override
  String get liveGameInMatch => 'อยู่ในแมตช์';

  @override
  String get liveGameInQueue => 'กำลังหาแมตช์';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'กำลังหาแมตช์ · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'เลเวล $n';
  }

  @override
  String get liveGameLiveScore => 'สกอร์สด';

  @override
  String get liveGameLoadoutFromAgentSelect => 'ชุดอุปกรณ์จากตอนเลือกเอเจนท์';

  @override
  String get liveGameLoadoutFromMatch => 'ชุดอุปกรณ์ในแมตช์นี้';

  @override
  String get liveGameLobbyHint =>
      'เมื่อพบแมตช์ ValHub จะแสดงรายชื่อผู้เล่นและแรงก์ของทุกทีม';

  @override
  String get liveGameLockFailed => 'ล็อกเอเจนท์นี้ไม่ได้ รีเฟรชแล้วลองอีกครั้ง';

  @override
  String liveGameLockedAgent(String agent) {
    return 'ล็อก $agent แล้ว';
  }

  @override
  String get liveGameLockedTag => 'ล็อกแล้ว';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub จะลองใหม่อัตโนมัติ กระดานคะแนนมักพร้อมภายในประมาณหนึ่งนาที';

  @override
  String get liveGameNoAgentYet => 'ยังไม่ได้เลือกเอเจนท์';

  @override
  String get liveGameNoAgents =>
      'โหลดรายชื่อเอเจนท์ไม่ได้ รีเฟรชเพื่อลองอีกครั้ง';

  @override
  String get liveGameNoLoadout => 'ไม่มีข้อมูลชุดอุปกรณ์ของผู้เล่นนี้';

  @override
  String get liveGameNotInGame => 'ไม่ได้อยู่ในแมตช์';

  @override
  String get liveGameNotInGameHint =>
      'เปิด VALORANT แล้วเข้าคิว — รายละเอียดแมตช์จะแสดงที่นี่โดยอัตโนมัติเมื่อคุณเข้าสู่หน้าเลือกเอเจนท์';

  @override
  String get liveGameNotInGameTitle => 'คุณไม่ได้อยู่ในแมตช์';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'ดูชุดอุปกรณ์ของ $name';
  }

  @override
  String get liveGameOpenParty => 'เปิดปาร์ตี้และคิว';

  @override
  String get liveGameParty => 'ปาร์ตี้';

  @override
  String liveGamePeak(String rank) {
    return 'สูงสุด: $rank';
  }

  @override
  String get liveGamePlayerCard => 'การ์ดผู้เล่น';

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'ชุดอุปกรณ์ของ $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'ชุดอุปกรณ์';

  @override
  String get liveGameQueueHint =>
      'เปิดแอปค้างไว้ — รายละเอียดแมตช์จะแสดงทันทีที่พบแมตช์';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'การออกจากแมตช์อาจทำให้คุณถูกลงโทษ (เสีย RR หรือถูกจำกัดการเข้าคิว) ยังต้องการออกไหม';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'การดอดจ์ในหน้าเลือกเอเจนท์อาจทำให้คุณถูกลงโทษ (เสีย RR หรือถูกจำกัดการเข้าคิว) ยังต้องการออกไหม';

  @override
  String get liveGameQuitConfirmTitle => 'ออกจากแมตช์ไหม';

  @override
  String get liveGameQuitDone => 'ออกจากแมตช์แล้ว';

  @override
  String get liveGameQuitFailed => 'ออกจากแมตช์ไม่ได้';

  @override
  String get liveGameQuitMatch => 'ออกจากแมตช์';

  @override
  String get liveGameQuitMatchChanged =>
      'แมตช์เปลี่ยนช่วงขณะที่คุณกำลังยืนยัน คุณยังไม่ได้ออก ลองอีกครั้ง';

  @override
  String get liveGameRankUnavailable => 'ไม่ทราบแรงก์';

  @override
  String get liveGameRefresh => 'รีเฟรช';

  @override
  String liveGameRefreshIn(int seconds) {
    return 'รีเฟรชใน $seconds วินาที';
  }

  @override
  String get liveGameRefreshNow => 'รีเฟรชเลย';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSelectFailed =>
      'เลือกเอเจนท์นี้ไม่ได้ รีเฟรชแล้วลองอีกครั้ง';

  @override
  String get liveGameSheetTitle => 'รายละเอียดแมตช์';

  @override
  String get liveGameSprays => 'สเปรย์';

  @override
  String get liveGameStatusAgentSelect => 'เลือกเอเจนท์';

  @override
  String get liveGameStatusEnded => 'จบแล้ว';

  @override
  String get liveGameStatusInProgress => 'กำลังแข่ง';

  @override
  String get liveGameStatusUnavailable => 'อัปเดตสถานะแมตช์ไม่ได้';

  @override
  String get liveGameTabAgents => 'เอเจนท์';

  @override
  String get liveGameTabAllPlayers => 'ผู้เล่น';

  @override
  String get liveGameTabEnemyTeam => 'ทีมศัตรู';

  @override
  String get liveGameTabYourTeam => 'ทีมของคุณ';

  @override
  String liveGameTimeLeft(String t) {
    return 'เหลือ $t';
  }

  @override
  String get liveGameViewMatchDetails => 'ดูรายละเอียดแมตช์';

  @override
  String get liveGameWeapons => 'อาวุธ';

  @override
  String get liveGameYou => 'คุณ';

  @override
  String liveGameYouHover(String agent) {
    return 'คุณกำลังเลือก $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'คุณล็อก $agent แล้ว';
  }

  @override
  String get liveGamePickInGame =>
      'เลือกและล็อกเอเจนต์ใน VALORANT ValHub แสดงเฉพาะเวลาที่เหลือและทีมของคุณ';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – เสมอ $draws',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – ไม่ทราบผล $unknown แมตช์',
      zero: '',
    );
    return 'ชนะ $wins – แพ้ $losses$_temp0$_temp1';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'เวลาของอุปกรณ์ ($offset)';
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
      'yes': ' ด้วย $weapon',
      'other': '',
    });
    return '$killer กำจัด $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 วัน',
      'days7': '7 วัน',
      'other': 'ทั้งหมด',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'เอเจนท์',
      'maps': 'แผนที่',
      'queues': 'โหมด',
      'sides': 'บุก / ป้องกัน',
      'trend': 'แนวโน้ม',
      'other': 'โหมด',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'ทุกโหมด';

  @override
  String get profileAbility => 'สกิล';

  @override
  String profileAboutMatches(int n) {
    return '≈ $n แมตช์';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'คะแนนการต่อสู้เฉลี่ย';

  @override
  String profileActRecord(int wins, int games, String rate) {
    return 'แอคท์นี้: ชนะ $wins / $games แมตช์ · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'ผู้เล่นทั้งหมด';

  @override
  String get profileAlreadyReached => 'คุณถึงแรงก์นี้แล้ว';

  @override
  String get profileAtCurrentForm => 'ด้วยฟอร์มปัจจุบัน';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'ด้วยฟอร์มปัจจุบัน ($gain / $loss ต่อแมตช์)';
  }

  @override
  String profileBestCase(int n) {
    return 'ดีที่สุด: ชนะติดกัน $n แมตช์';
  }

  @override
  String get profileByWinRateTitle => 'ตามอัตราชนะ';

  @override
  String get profileChooseMap => 'กรองตามแผนที่';

  @override
  String get profileClearMap => 'ล้างตัวกรองแผนที่';

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
  String get profileCopyRiotId => 'คัดลอก Riot ID';

  @override
  String get profileCurrentRank => 'ปัจจุบัน';

  @override
  String get profileDailyRrEmpty =>
      'ยังไม่มีแมตช์ Competitive ที่บันทึกไว้ในอุปกรณ์นี้';

  @override
  String get profileDailyRrFootnote =>
      'ประวัติ RR บันทึกไว้ในอุปกรณ์ของคุณ รวมถึงแมตช์ที่ Riot ไม่แสดงแล้ว';

  @override
  String get profileDailyRrTitle => 'RR รายวัน';

  @override
  String profileDayBoundary(String zone) {
    return 'นับวันตาม$zone';
  }

  @override
  String profileDaysPlayed(int n) {
    return 'เล่น $n วัน';
  }

  @override
  String get profileDuration => 'ระยะเวลา';

  @override
  String profileDurationOf(String d) {
    return 'ระยะเวลา $d';
  }

  @override
  String get profileEndOfHistory => 'แสดงแมตช์ทั้งหมดแล้ว';

  @override
  String get profileEnemyTeam => 'ทีมศัตรู';

  @override
  String get profileFallDamage => 'ตกจากที่สูง';

  @override
  String get profileFilterAll => 'ทั้งหมด';

  @override
  String get profileFilterMap => 'แผนที่';

  @override
  String get profileFirstBloods => 'เฟิร์สบลัด';

  @override
  String get profileFirstDeaths => 'ตายคนแรก';

  @override
  String get profileFirstHalf => 'ครึ่งแรก';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS, HS% นับเฉพาะโหมดที่เล่นเป็นรอบ';

  @override
  String profileFormPending(int n) {
    return 'ยังมี $n แมตช์ในรายการที่ยังโหลดไม่เสร็จสำหรับสถิตินี้';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR, HS% นับเฉพาะ $roundGames/$games แมตช์ที่เล่นเป็นรอบ';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    return '$games แมตช์ล่าสุด: ชนะ $w แพ้ $l';
  }

  @override
  String get profileFriendsRow => 'เพื่อนและแชท';

  @override
  String profileGainPerWin(String rr) {
    return '$rr RR เมื่อชนะ';
  }

  @override
  String get profileHideKills => 'ซ่อนการสังหาร';

  @override
  String get profileHitBody => 'ลำตัว';

  @override
  String get profileHitDistribution => 'การกระจายของกระสุนที่โดน';

  @override
  String get profileHitHead => 'หัว';

  @override
  String get profileHitLegs => 'ขา';

  @override
  String profileHitShare(String part, String percent) {
    return '$part $percent';
  }

  @override
  String get profileHs => 'HS%';

  @override
  String get profileKast => 'KAST';

  @override
  String get profileKastHint =>
      'สัดส่วนรอบที่คุณสังหาร ช่วยเหลือ รอดชีวิต หรือเพื่อนร่วมทีมแก้แค้นให้';

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
    return '$n วันที่ผ่านมา';
  }

  @override
  String profileLastMatches(int n) {
    return '$n แมตช์ล่าสุด';
  }

  @override
  String profileLeaderboard(String n) {
    return 'ลีดเดอร์บอร์ด #$n';
  }

  @override
  String profileLevel(int n) {
    return 'เลเวล $n';
  }

  @override
  String get profileLevelHidden => 'ซ่อนเลเวล';

  @override
  String profileLossPerLoss(String rr) {
    return '$rr RR เมื่อแพ้';
  }

  @override
  String profileLossStreak(int n) {
    return 'แพ้ติดกัน $n แมตช์';
  }

  @override
  String profileMapFilter(String map) {
    return 'แผนที่: $map';
  }

  @override
  String profileMatchCount(int n) {
    return '$n แมตช์';
  }

  @override
  String get profileMatchDetailTitle => 'รายละเอียดแมตช์';

  @override
  String get profileMatchHistory => 'ประวัติการแข่งขัน';

  @override
  String get profileMatchUnavailable => 'โหลดแมตช์ไม่ได้';

  @override
  String get profileMatchesNeeded => 'จำนวนแมตช์ที่ต้องการ';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'ไม่เคยมีแรงก์';

  @override
  String get profileNoKillsInRound => 'ยังไม่มีข้อมูลการสังหารในรอบนี้';

  @override
  String get profileNoMatches => 'ยังไม่มีแมตช์';

  @override
  String get profileNoMatchesMap => 'ไม่มีแมตช์บนแผนที่นี้ในแมตช์ที่โหลดไว้';

  @override
  String get profileNoMatchesQueue => 'ไม่มีแมตช์ในโหมดนี้';

  @override
  String get profileNoPlayers => 'ยังไม่มีข้อมูลผู้เล่นของแมตช์นี้';

  @override
  String get profileNoRounds => 'ยังไม่มีข้อมูลรายรอบของแมตช์นี้';

  @override
  String get profileOvertime => 'ต่อเวลา';

  @override
  String get profilePlayHubTitle => 'แมตช์และปาร์ตี้';

  @override
  String get profilePartyRow => 'ปาร์ตี้และคิว';

  @override
  String get profilePeakRank => 'สูงสุด';

  @override
  String profilePeakRankOf(String actTitle) {
    return 'สูงสุด · $actTitle';
  }

  @override
  String get profilePerformanceAttack => 'ฝ่ายบุก';

  @override
  String get profilePerformanceDefense => 'ฝ่ายป้องกัน';

  @override
  String get profilePerformanceEmpty =>
      'ยังไม่มีแมตช์ที่บันทึกไว้ในอุปกรณ์นี้ เปิดประวัติการแข่งขันเพื่อบันทึกแมตช์ที่คุณเล่น';

  @override
  String get profilePerformanceGames => 'แมตช์';

  @override
  String get profilePerformanceNoMatches => 'ไม่มีแมตช์ในช่วงเวลาที่เลือก';

  @override
  String profilePerformanceRounds(int n) {
    return 'บันทึกแล้ว $n รอบ';
  }

  @override
  String get profilePerformanceSample =>
      'อัตราจะแสดงเมื่อมีอย่างน้อย 3 แมตช์ ACS, ADR, HS% และ K/D นับเฉพาะโหมดที่เล่นเป็นรอบ';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'ระบุฝ่ายบุกหรือป้องกันได้ใน $known/$total รอบ';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'ประวัติในอุปกรณ์นี้ ตั้งแต่ $date';
  }

  @override
  String get profilePerformanceTitle => 'ผลงาน';

  @override
  String get profilePerformanceTrendEmpty =>
      'ต้องมีอย่างน้อยสองช่วงเวลาที่มี 3 แมตช์ขึ้นไปจึงจะเปรียบเทียบแนวโน้มได้';

  @override
  String get profilePickTargetHint => 'เลือกแรงก์ที่คุณอยากไปถึง';

  @override
  String profilePlacement(int n) {
    return 'อันดับ $n';
  }

  @override
  String profilePlantedAt(String site) {
    return 'วางสไปค์ที่ $site';
  }

  @override
  String get profilePlayerProfileTitle => 'โปรไฟล์ผู้เล่น';

  @override
  String get profilePlayerSummary => 'ผลงาน';

  @override
  String profileProgressTo(String rank) {
    return 'ความคืบหน้าสู่ $rank';
  }

  @override
  String get profileProgressToTarget => 'ความคืบหน้าสู่แรงก์เป้าหมาย';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'ประมาณการจากแมตช์ Competitive ล่าสุด ยังไม่รวมแมตช์วัดระดับและระบบป้องกันการตกแรงก์';

  @override
  String profileRankUpHint(int matches, String rank) {
    return '≈ $matches แมตช์เพื่อไปถึง $rank';
  }

  @override
  String get profileRankUpImmortal =>
      'คุณอยู่ที่ IMMORTAL ขึ้นไปแล้ว — เครื่องมือนี้คำนวณได้ถึง IMMORTAL 1 เท่านั้น';

  @override
  String get profileRankUpNoForm =>
      'ยังไม่มีแมตช์ Competitive ล่าสุดสำหรับประเมินฟอร์มของคุณ';

  @override
  String get profileRankUpOpen => 'เปิดเครื่องคำนวณการขึ้นแรงก์';

  @override
  String get profileRankUpTitle => 'เครื่องคำนวณการขึ้นแรงก์';

  @override
  String get profileRankUpUnranked =>
      'เล่นแมตช์วัดระดับให้ครบเพื่อใช้เครื่องคำนวณการขึ้นแรงก์';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'กระดานคะแนน Competitive';

  @override
  String profileRecentForm(int w, int l) {
    return 'ฟอร์มล่าสุด: ชนะ $w – แพ้ $l';
  }

  @override
  String get profileRecentFormTitle => 'ฟอร์มล่าสุด';

  @override
  String get profileRecentMatches => 'แมตช์ล่าสุด';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: 'ชนะ $w · แพ้ $l · เสมอ $d',
      zero: 'ชนะ $w · แพ้ $l',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'คัดลอก Riot ID แล้ว';

  @override
  String profileRound(int n) {
    return 'รอบที่ $n';
  }

  @override
  String profileRoundKills(int n) {
    return 'สังหาร $n';
  }

  @override
  String get profileRoundLost => 'แพ้รอบ';

  @override
  String get profileRoundTimeline => 'ไทม์ไลน์รอบ';

  @override
  String get profileRoundWon => 'ชนะรอบ';

  @override
  String get profileRoundsHint => 'แตะรอบเพื่อดูการสังหารแต่ละครั้ง';

  @override
  String get profileRr => 'RR';

  @override
  String profileRrLeft(String n) {
    return 'ยังขาดอีก $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'แนวโน้ม RR';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'กระดานคะแนน';

  @override
  String get profileSecondHalf => 'ครึ่งหลัง';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'ดูการสังหาร';

  @override
  String get profileSideSwitch => 'สลับฝั่ง';

  @override
  String get profileSpike => 'สไปค์';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'แรงก์เป้าหมาย';

  @override
  String get profileTeamBlue => 'ทีมสีน้ำเงิน';

  @override
  String get profileTeamMvp => 'MVP ของทีม';

  @override
  String get profileTeamRed => 'ทีมสีแดง';

  @override
  String get profileTitle => 'โปรไฟล์';

  @override
  String profileToday(String text) {
    return 'วันนี้: $text';
  }

  @override
  String get profileTodayNone => 'วันนี้ยังไม่มีแมตช์ Competitive';

  @override
  String get profileTruePeakLocal => 'อ้างอิงประวัติในอุปกรณ์นี้';

  @override
  String get profileWeekdayShortItem0 => 'จ.';

  @override
  String get profileWeekdayShortItem1 => 'อ.';

  @override
  String get profileWeekdayShortItem2 => 'พ.';

  @override
  String get profileWeekdayShortItem3 => 'พฤ.';

  @override
  String get profileWeekdayShortItem4 => 'ศ.';

  @override
  String get profileWeekdayShortItem5 => 'ส.';

  @override
  String get profileWeekdayShortItem6 => 'อา.';

  @override
  String get profileWinRate => 'อัตราชนะ';

  @override
  String profileWinStreak(int n) {
    return 'ชนะติดกัน $n แมตช์';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'แรงก์ของคุณ';

  @override
  String get profileYourSummary => 'ผลงานของคุณ';

  @override
  String get profileYourTeam => 'ทีมของคุณ';

  @override
  String get profileYourWinRate => 'อัตราชนะล่าสุดของคุณ';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'โหมด: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'กรองตามโหมด';

  @override
  String get profilePerformancePerMatchTitle => 'รายแมตช์';

  @override
  String get profilePerformancePerMatchHint => 'แตะแท่งกราฟเพื่อเปิดแมตช์นั้น';

  @override
  String profilePerformanceAverage(String value) {
    return 'เฉลี่ย $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'ต้องมีอย่างน้อย 2 แมตช์แบบเล่นเป็นรอบที่มีค่าสถิตินี้จึงจะแสดงกราฟได้';

  @override
  String get profilePerformanceOpeningsTitle => 'การดวลเปิดรอบ';

  @override
  String get profilePerformanceOpeningWin => 'ชนะการดวลเปิดรอบ';

  @override
  String get profilePerformanceOpeningWinHint =>
      'ในรอบที่คุณได้เฟิร์สบลัดหรือตายคนแรก สัดส่วนที่คุณได้เฟิร์สบลัด';

  @override
  String get profilePerformanceFirstBloodsPerGame => 'เฟิร์สบลัดต่อแมตช์';

  @override
  String get profilePerformanceFirstDeathsPerGame => 'ตายคนแรกต่อแมตช์';

  @override
  String get profilePerformanceMultiKillsTitle => 'สังหารหลายคนในรอบเดียว';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': 'สังหาร 3',
      'k4': 'สังหาร 4',
      'ace': 'เอซ',
      'other': 'สังหาร 2',
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
      other: 'คำนวณจาก $nString แมตช์ที่มีข้อมูลการสังหารครบ',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'อัตราชนะรอบ';

  @override
  String get profilePerformanceDrillHint =>
      'แตะแถวเพื่อดูเฉพาะเอเจนท์ แผนที่ หรือโหมดนั้น';

  @override
  String get profilePerformanceLoadOlder => 'วิเคราะห์แมตช์เก่าเพิ่ม';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ValHub วิเคราะห์เฉพาะแมตช์ที่เปิดในอุปกรณ์นี้ แตะแต่ละครั้งจะเพิ่มแมตช์ที่เก่ากว่าได้สูงสุด $nString แมตช์';
  }

  @override
  String get profilePerformanceSearchingOlder => 'กำลังค้นหาแมตช์ที่เก่ากว่า…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'กำลังวิเคราะห์แมตช์ $doneString/$totalString…';
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
      other: 'เพิ่ม $nString แมตช์ในการวิเคราะห์แล้ว',
      zero: 'ไม่มีแมตช์ใหม่ให้เพิ่ม',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder =>
      'Riot ไม่ได้เก็บแมตช์ที่เก่ากว่านี้แล้ว';

  @override
  String get profileEconomyTitle => 'เศรษฐกิจทีมคุณ';

  @override
  String get profileEconomyHint =>
      'ประเภทการซื้อคิดจากมูลค่าอุปกรณ์รวมของทีมคุณตอนเริ่มรอบ (เกณฑ์ของ vlr.gg สำหรับ 5 คน): Eco ต่ำกว่า 5,000 Semi-eco ต่ำกว่า 10,000 Semi-buy ต่ำกว่า 20,000 และ Full buy ตั้งแต่ 20,000 เครดิต รอบแรกของแต่ละครึ่งคือ Pistol';

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

    return 'ชนะ $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get legalAboutIntro =>
      'ผู้ช่วย VALORANT ของคุณ: ร้านค้ารายวัน wishlist แรงก์ แมตช์ หลายบัญชี และชุมชนผู้เล่น ทั้งหมดอยู่ในอุปกรณ์ของคุณ';

  @override
  String get legalBackToTop => 'กลับไปด้านบน';

  @override
  String get legalConsentAnd => 'และ';

  @override
  String get legalConsentPrefix => 'เมื่อดำเนินการต่อ แสดงว่าคุณยอมรับ';

  @override
  String get legalConsentPrivacy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get legalConsentSuffix => 'ของ ValHub';

  @override
  String get legalConsentTerms => 'ข้อกำหนดการใช้งาน';

  @override
  String get legalContact => 'ติดต่อ';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'ติดต่อ';

  @override
  String get legalCreditsHeader => 'แหล่งข้อมูลและเครดิต';

  @override
  String legalEffectiveFrom(String date) {
    return 'มีผลตั้งแต่ $date';
  }

  @override
  String get legalLegalHeader => 'ข้อกฎหมาย';

  @override
  String get legalLicensePageLegalese => '© 2026 Nguyễn Đức Huy สงวนลิขสิทธิ์';

  @override
  String get legalThirdPartyLicenses => 'ซอฟต์แวร์ของบุคคลที่สาม';

  @override
  String get legalThirdPartyLicensesBody =>
      'สัญญาอนุญาตของซอฟต์แวร์โอเพนซอร์สที่ ValHub ใช้';

  @override
  String get legalTocTitle => 'สารบัญ';

  @override
  String legalVersion(String version) {
    return 'เวอร์ชัน $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'ขณะนี้เอกสารนี้แสดงเป็น$language';
  }

  @override
  String get legalContentUnavailable =>
      'อ่านเอกสารทางกฎหมายไม่ได้ ลองอีกครั้งหรือติดต่อฝ่ายสนับสนุน';

  @override
  String get legalTranslationNotice =>
      'คำแปลนี้จัดทำขึ้นเพื่อความสะดวก หากมีความแตกต่าง ให้ถือฉบับภาษาเวียดนามเป็นหลัก';

  @override
  String get settingsUiLanguageTitle => 'ภาษาของแอป';

  @override
  String get settingsLanguageFollowDevice => 'ใช้ภาษาของอุปกรณ์';

  @override
  String get settingsLanguageSaveFailed => 'บันทึกภาษาไม่ได้ โปรดลองอีกครั้ง';

  @override
  String get settingsGeoCountry => 'ประเทศ';

  @override
  String get settingsGeoSearchCountry => 'ค้นหาชื่อหรือรหัสประเทศ';

  @override
  String get settingsGeoSupportedOnly => 'เฉพาะที่ยืนยันว่ารองรับ';

  @override
  String get settingsGeoUnknown => 'ยังไม่ยืนยันการรองรับ';

  @override
  String get settingsGeoRestricted => 'ถูกจำกัด';

  @override
  String get settingsGeoSeparate => 'บริการแยกต่างหาก';

  @override
  String get settingsGeoAvailable => 'รองรับ';

  @override
  String get settingsGeoNotApplicable => 'ไม่เกี่ยวข้อง';

  @override
  String get settingsGeoConnection => 'การเชื่อมต่อ Riot';

  @override
  String get settingsGeoChooseRegion => 'เลือกภูมิภาค';

  @override
  String get settingsGeoAuto => 'อัตโนมัติตามบัญชี';

  @override
  String get settingsGeoManual => 'เลือกเอง';

  @override
  String get settingsGeoNoRegion => 'ระบุภูมิภาค Riot ของคุณไม่ได้';

  @override
  String get settingsGeoManualWarning =>
      'ตัวเลือกนี้เปลี่ยนเฉพาะเซิร์ฟเวอร์ที่ ValHub เชื่อมต่อ ไม่ได้ย้ายภูมิภาคของบัญชี Riot ของคุณ ValHub จะตรวจสอบการเชื่อมต่อก่อนบันทึก';

  @override
  String get settingsGeoConnectionSaved => 'บันทึกการเชื่อมต่อแล้ว';

  @override
  String get settingsGeoValidationFailed =>
      'ยืนยันบัญชีของคุณบนเซิร์ฟเวอร์นี้ไม่ได้ เลือกภูมิภาคอีกครั้ง';

  @override
  String get settingsGeoHintOnly =>
      'ประเทศใช้สำหรับค้นหาและแนะนำเท่านั้น ภูมิภาคที่เชื่อมต่อจะเป็นไปตามบัญชี Riot ของคุณ';

  @override
  String get settingsGeoUnsupported =>
      'ยังไม่รองรับภูมิภาค Riot นี้ เลือกภูมิภาคในการตั้งค่า';

  @override
  String get settingsGeoSave => 'ตรวจสอบและบันทึก';

  @override
  String get settingsGeoCancel => 'ยกเลิก';

  @override
  String get settingsGeoLoading => 'กำลังตรวจสอบการเชื่อมต่อ…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'ตัวเลือกนี้ใช้กับชื่อประเทศ คำแนะนำ และราคา VP โดยประมาณ ส่วนเซิร์ฟเวอร์ที่เชื่อมต่อและประเทศของบัญชีชุมชนยังคงกำหนดโดย Riot';

  @override
  String get settingsGeoCountryAutomatic => 'ใช้ประเทศของบัญชีหรืออุปกรณ์';

  @override
  String get settingsGeoSaveFailed => 'บันทึกตัวเลือกไม่ได้ ลองอีกครั้ง';

  @override
  String get settingsGeoAllRegions => 'ทุกภูมิภาค';

  @override
  String get settingsGeoSuggestions => 'คำแนะนำ';

  @override
  String get settingsGeoNoCountries => 'ไม่มีประเทศที่ตรงกับตัวกรอง';

  @override
  String get settingsGeoActiveCountries => 'มีความเคลื่อนไหว';

  @override
  String get settingsGeoAllCountries => 'ทุกประเทศ';

  @override
  String get settingsGeoActivityUnavailable =>
      'โหลดความเคลื่อนไหวของแต่ละประเทศไม่ได้ คุณยังเลือกได้จากทุกประเทศ';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ประเทศ',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'คุณเลือก $manual แต่ Riot ระบุว่าบัญชีของคุณอยู่ที่ $detected ตรวจสอบการเชื่อมต่อนี้ต่อไหม';
  }

  @override
  String get settingsGeoUnverified =>
      'ยืนยันการเชื่อมต่อไม่ได้เพราะเซิร์ฟเวอร์หรือเครือข่ายมีปัญหา บันทึกตัวเลือกนี้แล้วลองอีกครั้งภายหลังไหม';

  @override
  String get settingsGeoContinue => 'ดำเนินการต่อ';

  @override
  String settingsGeoMismatch(String region) {
    return 'การเชื่อมต่อที่เลือกเองต่างจากภูมิภาค Riot ของคุณ: $region เปลี่ยนเป็นอัตโนมัติไหม';
  }

  @override
  String get settingsGeoUseAuto => 'ใช้อัตโนมัติ';

  @override
  String get settingsGeoKeepManual => 'ใช้แบบเลือกเองต่อ';

  @override
  String get settingsGeoReviewConnection => 'ดูการเชื่อมต่อ';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'ตรวจสอบล่าสุด: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'ตรวจสอบอีกครั้ง';

  @override
  String get settingsPlatformMobile => 'มือถือ';

  @override
  String get settingsPlatformOther => 'แพลตฟอร์มอื่น';

  @override
  String get settingsContentLanguageFollowApp => 'เหมือนภาษาของแอป';

  @override
  String get settingsContentLanguageHint =>
      'เลือกภาษาของชื่อไอเทม ตัวเลือกนี้ไม่เปลี่ยนภาษาของแอปหรือเซิร์ฟเวอร์ Riot ของคุณ';

  @override
  String settingsLanguageChanged(String language) {
    return 'ภาษา: $language';
  }

  @override
  String get settingsAboutCreditContent => 'valorant-api.com';

  @override
  String get settingsAboutCreditContentBody =>
      'ชื่อ รูปภาพ และข้อมูลของสกิน เอเจนท์ แผนที่ และแรงก์';

  @override
  String get settingsAboutCreditDocs => 'เอกสารจากชุมชน';

  @override
  String get settingsAboutCreditDocsBody =>
      'โปรเจกต์ techchrism/valorant-api-docs และชุมชนนักพัฒนา VALORANT';

  @override
  String get settingsAboutCreditRiot => 'Riot Games';

  @override
  String get settingsAboutCreditRiotBody =>
      'ร้านค้า กระเป๋าเงิน คอลเลกชัน แมตช์ และแรงก์ ดึงมาจากบัญชี Riot ที่คุณเข้าสู่ระบบโดยตรง';

  @override
  String get settingsAboutCreditsHeader => 'แหล่งข้อมูล';

  @override
  String get settingsAboutHeader => 'ข้อมูล';

  @override
  String get settingsAboutLegalHeader => 'ข้อกฎหมาย';

  @override
  String get settingsAboutRowSubtitle =>
      'ความเป็นส่วนตัว ข้อกำหนด ลิขสิทธิ์ และการติดต่อ';

  @override
  String get settingsAboutTitle => 'เกี่ยวกับและข้อกฎหมาย';

  @override
  String get settingsAppHeader => 'ขั้นสูง';

  @override
  String get settingsAppearanceHeader => 'การแสดงผล';

  @override
  String settingsBuildNumber(String build) {
    return 'บิลด์ $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return 'ล้างแล้ว $size';
  }

  @override
  String get settingsClearCache => 'ล้างข้อมูลชั่วคราว';

  @override
  String get settingsClearCacheFailed => 'ล้างข้อมูลชั่วคราวไม่ได้ ลองอีกครั้ง';

  @override
  String get settingsClearCacheSubtitle =>
      'รูปภาพและข้อมูลที่ดาวน์โหลดไว้ในอุปกรณ์ รวมถึงรายงานข้อผิดพลาดที่บันทึกไว้';

  @override
  String get settingsClearLog => 'ล้างรายงานข้อผิดพลาดที่บันทึกไว้';

  @override
  String get settingsClearLogConfirm =>
      'ล้างรายงานข้อผิดพลาดที่บันทึกไว้ในอุปกรณ์นี้ใช่ไหม';

  @override
  String get settingsExportLog => 'ส่งรายงานข้อผิดพลาดถึง ValHub';

  @override
  String get settingsExportLogEmpty =>
      'ยังไม่มีอะไรให้ส่ง ใช้แอปสักพักแล้วลองอีกครั้ง';

  @override
  String get settingsExportLogEmptyTitle => 'ยังไม่มีอะไรให้ส่ง';

  @override
  String get settingsExportLogNote =>
      'รายงานข้อผิดพลาดไม่มีรหัสผ่านหรือข้อมูลเข้าสู่ระบบ Riot ของคุณ';

  @override
  String get settingsExportLogSubtitle =>
      'รายงานข้อผิดพลาดไม่มีรหัสผ่านหรือข้อมูลเข้าสู่ระบบ Riot ของคุณ';

  @override
  String get settingsFeedback => 'ส่งความคิดเห็นถึง ValHub';

  @override
  String get settingsFeedbackSubtitle => 'เปิดหน้าส่งความคิดเห็นของ ValHub';

  @override
  String get settingsItemLanguageEn => 'ภาษาอังกฤษ';

  @override
  String get settingsItemLanguageHint =>
      'ชื่อสกิน เอเจนท์ แผนที่… จะแสดงเป็นภาษานี้';

  @override
  String get settingsItemLanguageLabel => 'ชื่อไอเทม';

  @override
  String get settingsItemLanguagePickerTitle => 'ภาษาของชื่อไอเทม';

  @override
  String get settingsItemLanguageVi => 'ภาษาเวียดนาม';

  @override
  String get settingsLegalNotice => 'ประกาศทางกฎหมาย';

  @override
  String get settingsLinkOpenFailed => 'เปิดลิงก์ไม่ได้ ลองอีกครั้ง';

  @override
  String get settingsLogCleared => 'ล้างรายงานข้อผิดพลาดแล้ว';

  @override
  String settingsLogEntryCount(int count) {
    return '$count รายการ';
  }

  @override
  String settingsLogEntryShown(int shown, int total) {
    return '$shown / $total รายการ';
  }

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — รายงานข้อผิดพลาด';
  }

  @override
  String get settingsLogFilterAll => 'ทั้งหมด';

  @override
  String get settingsLogFilterAuth => 'เข้าสู่ระบบ';

  @override
  String get settingsLogFilterEmpty =>
      'ไม่มีรายการที่ตรงกัน ล้างตัวกรองเพื่อดูเพิ่มเติม';

  @override
  String get settingsLogFilterErrors => 'ปัญหา';

  @override
  String get settingsLogFilterHttp => 'การเชื่อมต่อ';

  @override
  String get settingsLogMore => 'ตัวเลือกเพิ่มเติม';

  @override
  String get settingsLogSearchEmpty => 'ไม่มีรายการที่ตรงกัน';

  @override
  String get settingsLogSearchHint => 'ค้นหาในรายงานข้อผิดพลาด…';

  @override
  String get settingsLogShareFailed => 'ส่งรายงานข้อผิดพลาดไม่ได้ ลองอีกครั้ง';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'เมื่อไนท์มาร์เก็ตเปิด';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'เตือนให้คุณเปิดการ์ดข้อเสนอในไนท์มาร์เก็ต';

  @override
  String get settingsNotifPermissionMissing =>
      'แอปยังไม่ได้รับอนุญาตให้ส่งการแจ้งเตือน';

  @override
  String get settingsNotifStoreReset => 'เมื่อร้านค้ารีเฟรช';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'ทุกวันเวลา $time';
  }

  @override
  String get settingsNotifWishlist => 'เมื่อสกินใน wishlist ปรากฏ';

  @override
  String get settingsNotifWishlistSubtitle =>
      'ตรวจสอบร้านค้าของทุกบัญชี แม้คุณไม่ได้เปิดแอป';

  @override
  String get settingsNotificationsHeader => 'การแจ้งเตือน';

  @override
  String get settingsOptionAutoOpenLiveGame => 'เปิดรายละเอียดแมตช์อัตโนมัติ';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'เปิดหน้าแมตช์ปัจจุบันทันทีที่พบแมตช์';

  @override
  String get settingsOptionOwnPrice => 'ราคาแพ็ก VP ของคุณ';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'ยังไม่ได้กรอก — ใช้ตารางราคาของภูมิภาคหากมี';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'แพลตฟอร์ม';

  @override
  String get settingsOptionShowLiveScore => 'แสดงสกอร์สด';

  @override
  String get settingsOptionShowPeakRank => 'แสดงแรงก์สูงสุดในรายละเอียดแมตช์';

  @override
  String get settingsOptionShowPrice => 'แสดงราคาประมาณ';

  @override
  String get settingsOptionShowPriceInfo => 'วิธีคำนวณราคาประมาณ';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'ข้างราคา VP เช่น $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'ยังไม่มีตารางราคาที่ยืนยันแล้วสำหรับภูมิภาคของคุณ — กรอกราคาแพ็ก VP ของคุณ';

  @override
  String get settingsOptionsHeader => 'ตัวเลือก';

  @override
  String get settingsPhaseComplete => 'เสร็จแล้ว';

  @override
  String get settingsPhaseInProgress => 'กำลังดำเนินการ';

  @override
  String get settingsPhaseScheduled => 'กำหนดการไว้แล้ว';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'ใช้กับ $account';
  }

  @override
  String get settingsPlatformHint =>
      'เลือก PC, PlayStation หรือ Xbox ตามที่คุณเล่น เพื่อดูประวัติการแข่งขันที่ถูกต้อง';

  @override
  String get settingsPlatformPickerTitle => 'เลือกแพลตฟอร์ม';

  @override
  String get settingsPrimingBody =>
      'เปิดการแจ้งเตือนเพื่อรู้เมื่อร้านค้ารีเฟรชและเมื่อสกินใน wishlist ปรากฏ';

  @override
  String get settingsPrimingEnable => 'เปิดการแจ้งเตือน';

  @override
  String get settingsPrimingFootnote =>
      'คุณเปิดหรือปิดการแจ้งเตือนแต่ละประเภทได้ทุกเมื่อในการตั้งค่า';

  @override
  String get settingsPrimingLater => 'ไว้ทีหลัง';

  @override
  String get settingsPrimingPointNightMarket => 'รู้ทันทีเมื่อไนท์มาร์เก็ตเปิด';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'เพื่อให้เปิดการ์ดข้อเสนอได้ทันก่อนหมดเวลา';

  @override
  String get settingsPrimingPointStore => 'เตือนเมื่อร้านค้ารายวันรีเฟรช';

  @override
  String get settingsPrimingPointStoreDetail =>
      'เตือนหลังจากร้านค้าของบัญชีรีเฟรช';

  @override
  String get settingsPrimingPointWishlist =>
      'แจ้งเตือนเมื่อสกินที่คุณตามล่าปรากฏ';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'ตรวจสอบร้านค้าของทุกบัญชี แม้คุณไม่ได้เปิดแอป';

  @override
  String get settingsPrimingTitle => 'ไม่พลาดสกินที่คุณตามล่า';

  @override
  String settingsRemovedAccount(String account) {
    return 'ลบ $account แล้ว';
  }

  @override
  String get settingsServerStatus => 'สถานะเซิร์ฟเวอร์';

  @override
  String get settingsServerStatusMaintenance => 'กำลังปิดปรับปรุง';

  @override
  String settingsServerStatusNotices(int n) {
    return '$n ประกาศ';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'การปิดปรับปรุงและปัญหาของ VALORANT ตามเซิร์ฟเวอร์';

  @override
  String get settingsSessionLogTitle => 'รายงานข้อผิดพลาด ValHub';

  @override
  String get settingsSeverityCritical => 'ร้ายแรง';

  @override
  String get settingsSeverityInfo => 'ข้อมูล';

  @override
  String get settingsSeverityWarning => 'คำเตือน';

  @override
  String get settingsSignedOutAll => 'ออกจากระบบทุกบัญชีแล้ว';

  @override
  String get settingsStatusAllGood => 'เซิร์ฟเวอร์ทำงานตามปกติ';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'ไม่มีปัญหาหรือการปิดปรับปรุงบนเซิร์ฟเวอร์ $region';
  }

  @override
  String get settingsStatusFewerUpdates => 'แสดงน้อยลง';

  @override
  String get settingsStatusIssues => 'Riot กำลังแก้ไขปัญหา';

  @override
  String settingsStatusIssuesBody(int n) {
    return 'เซิร์ฟเวอร์นี้มีประกาศปัญหา $n รายการ';
  }

  @override
  String get settingsStatusKindIncident => 'ปัญหา';

  @override
  String get settingsStatusKindMaintenance => 'ปิดปรับปรุง';

  @override
  String get settingsStatusMaintenanceNow => 'เซิร์ฟเวอร์กำลังปิดปรับปรุง';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'คุณอาจยังเข้าเกมไม่ได้ และ ValHub อาจโหลดข้อมูลไม่ได้ชั่วคราว';

  @override
  String settingsStatusMoreUpdates(int n) {
    return 'ดูอัปเดตเพิ่มอีก $n รายการ';
  }

  @override
  String get settingsStatusRegionPicker => 'เซิร์ฟเวอร์';

  @override
  String get settingsStatusScheduled => 'จะมีการปิดปรับปรุงเร็วๆ นี้';

  @override
  String settingsStatusScheduledBody(int n) {
    return 'Riot ประกาศกำหนดการปิดปรับปรุงไว้ $n รายการ';
  }

  @override
  String get settingsStatusSourceNote =>
      'แหล่งที่มา: หน้าสถานะทางการของ Riot Games เวลาแสดงตามเขตเวลาของอุปกรณ์';

  @override
  String settingsStatusStarted(String when) {
    return 'เริ่ม $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'อัปเดต $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'อัปเดตจาก RIOT';

  @override
  String get settingsSupportHeader => 'ช่วยเหลือ';

  @override
  String settingsSwitchedTo(String account) {
    return 'สลับไปที่ $account แล้ว';
  }

  @override
  String get settingsThemeDark => 'มืด';

  @override
  String get settingsThemeLabel => 'ธีม';

  @override
  String get settingsThemeLight => 'สว่าง';

  @override
  String get settingsThemePickerTitle => 'เลือกธีม';

  @override
  String get settingsThemeSystem => 'ตามระบบ';

  @override
  String get settingsTitle => 'การตั้งค่า';

  @override
  String settingsVersion(String version) {
    return 'เวอร์ชัน $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'แรงก์ ประวัติการแข่งขัน แมตช์ที่กำลังเล่น';

  @override
  String get settingsWelcomeBulletProfileDetail =>
      'RR แต่ละแมตช์ แรงก์ของคู่แข่ง';

  @override
  String get settingsWelcomeBulletStore =>
      'ร้านค้ารายวัน ไนท์มาร์เก็ต และบันเดิล';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'ราคา ความหายาก นับถอยหลังรีเฟรช';

  @override
  String get settingsWelcomeBulletWishlist => 'Wishlist และการแจ้งเตือน';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'รับแจ้งเตือนเมื่อสกินที่คุณตามล่าขึ้นร้านค้า';

  @override
  String get settingsWelcomeFootnote =>
      'คุณเข้าสู่ระบบในหน้าทางการของ Riot โดย ValHub จะบันทึกรหัสผ่านก็ต่อเมื่อคุณเลือกบันทึกข้อมูลเข้าสู่ระบบเอง';

  @override
  String get settingsWelcomeKicker => 'ผู้ช่วย VALORANT';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average (คะแนน: $count) · ',
      'other': '',
    });
    return 'ชุมชน: $_temp0ถูกใจ: $votes';
  }

  @override
  String get skinDetailAddToWishlist => 'เพิ่มใน wishlist';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'มีในร้านค้าของ: $accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    return 'ในร้านค้าของคุณ: ร้านค้ารายวัน $daily ครั้ง ไนท์มาร์เก็ต $night รอบ นับเฉพาะข้อมูลในอุปกรณ์นี้ บันทึกตั้งแต่ $since';
  }

  @override
  String get skinDetailHistoryDelete => 'ลบประวัติร้านค้า';

  @override
  String get skinDetailHistoryDeleteBody =>
      'ลบวันที่ร้านค้าบันทึกไว้ทั้งหมดของบัญชีนี้ในอุปกรณ์นี้ใช่ไหม';

  @override
  String get skinDetailInWishlist => 'อยู่ใน wishlist แล้ว';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'ล็อกอยู่';

  @override
  String get skinDetailMute => 'ปิดเสียง';

  @override
  String get skinDetailNotFound => 'ไม่พบสกินนี้';

  @override
  String get skinDetailOwned => 'มีแล้ว';

  @override
  String get skinDetailPause => 'หยุดชั่วคราว';

  @override
  String get skinDetailPlay => 'เล่น';

  @override
  String get skinDetailPlayVideo => 'ดูวิดีโอ';

  @override
  String get skinDetailRemoveFromWishlist => 'ลบออกจาก wishlist';

  @override
  String get skinDetailTitle => 'รายละเอียดสกิน';

  @override
  String get skinDetailUnmute => 'เปิดเสียง';

  @override
  String get skinDetailUpgrades => 'การอัปเกรด';

  @override
  String get skinDetailVariants => 'รูปแบบสี';

  @override
  String get skinDetailVideoError =>
      'เล่นวิดีโอไม่ได้ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get socialPresenceInMatch => 'อยู่ในแมตช์';

  @override
  String get socialPresenceAgentSelect => 'กำลังเลือกเอเจนท์';

  @override
  String get socialPresenceQueue => 'กำลังหาแมตช์';

  @override
  String get socialPresenceLobby => 'อยู่ในล็อบบี้';

  @override
  String get socialPresenceCustom => 'อยู่ใน Custom Game';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'ปาร์ตี้เปิด',
      'other': 'เฉพาะผู้ได้รับเชิญ',
    });
    return '$size/$max คน · $_temp0';
  }

  @override
  String get socialAccept => 'ยอมรับ';

  @override
  String get socialAcceptInGame => 'ยอมรับคำเชิญนี้ในเกม';

  @override
  String socialActionFailed(String message) {
    return 'ดำเนินการไม่สำเร็จ $message';
  }

  @override
  String get socialAutoRefresh => 'รีเฟรชอัตโนมัติ';

  @override
  String get socialAway => 'ไม่อยู่';

  @override
  String socialCancelQueue(String elapsed) {
    return 'ยกเลิกคิว · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'ยกเลิกคิว';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'ปาร์ตี้ของคุณเข้าคิว $queue ไม่ได้: $reason';
  }

  @override
  String get socialChangeQueue => 'เปลี่ยนคิว';

  @override
  String get socialChatTitle => 'แชท';

  @override
  String get socialChatUnavailable => 'แชทออฟไลน์อยู่';

  @override
  String get socialCloseParty => 'ปิดปาร์ตี้';

  @override
  String get socialClosedState => 'เฉพาะผู้ได้รับเชิญ';

  @override
  String get socialCodeInvalid => 'โค้ดปาร์ตี้มีได้เฉพาะตัวอักษรและตัวเลข';

  @override
  String get socialConnecting => 'กำลังเชื่อมต่อแชท…';

  @override
  String get socialCopyCode => 'คัดลอก';

  @override
  String get socialCurrentQueue => 'เลือกอยู่';

  @override
  String get socialCustomGameLobby => 'ปาร์ตี้ของคุณอยู่ในล็อบบี้ Custom Game';

  @override
  String get socialDecline => 'ปฏิเสธ';

  @override
  String get socialDisableCode => 'ปิดโค้ด';

  @override
  String get socialEmptyChat => 'ยังไม่มีข้อความ ทักทายกันเลย!';

  @override
  String get socialEmptyChatTitle => 'เริ่มแชท';

  @override
  String get socialFailedBadge => 'ส่งไม่สำเร็จ';

  @override
  String get socialFilterAll => 'ทั้งหมด';

  @override
  String get socialFilterOnline => 'ออนไลน์';

  @override
  String get socialFilterUnread => 'ยังไม่อ่าน';

  @override
  String get socialFriendsPrivacyNote =>
      'รายชื่อเพื่อนและข้อความมาจาก Riot โดยตรง ValHub ไม่ได้จัดเก็บไว้ที่อื่น';

  @override
  String socialFriendsSummary(int total, int online) {
    return 'เพื่อน $total คน · ออนไลน์ $online คน';
  }

  @override
  String get socialFriendsTitle => 'เพื่อนและแชท';

  @override
  String get socialGameNotRunningBody =>
      'ปาร์ตี้และคิวใช้งานได้เฉพาะเมื่อ VALORANT กำลังทำงานบน PC หรือคอนโซลของคุณ เปิดเกมแล้วดึงลงเพื่อรีเฟรช';

  @override
  String get socialGameNotRunningTitle => 'เปิด VALORANT บน PC หรือคอนโซล';

  @override
  String get socialGenerateCode => 'สร้างโค้ด';

  @override
  String get socialHistoryFailed =>
      'โหลดข้อความเก่าไม่ได้ เชื่อมต่อใหม่แล้วลองอีกครั้ง';

  @override
  String get socialIdleQueue => 'พร้อมเข้าคิว';

  @override
  String get socialInMatchBanner =>
      'คุณอยู่ในแมตช์ คิวจะเปิดอีกครั้งเมื่อแมตช์จบ';

  @override
  String get socialInValorant => 'อยู่ใน VALORANT';

  @override
  String get socialInviteByRiotId => 'เชิญด้วย Riot ID';

  @override
  String get socialInviteByRiotIdHint => 'เชิญผู้เล่นที่ยังไม่ได้เป็นเพื่อน';

  @override
  String get socialInviteFriends => 'เชิญเพื่อน';

  @override
  String socialInviteFrom(String name) {
    return 'คำเชิญจาก $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'เชิญ $name';
  }

  @override
  String get socialInviteNeedsName =>
      'ยังไม่ทราบ Riot ID ของผู้เล่นนี้ จึงยังเชิญไม่ได้';

  @override
  String socialInviteSent(String name) {
    return 'ส่งคำเชิญถึง $name แล้ว';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · เชิญแล้ว';
  }

  @override
  String get socialInvitesSection => 'คำเชิญ';

  @override
  String get socialJoin => 'เข้าร่วม';

  @override
  String get socialJoinConfirmBody =>
      'คุณจะออกจากปาร์ตี้ปัจจุบันเพื่อเข้าร่วมปาร์ตี้ที่ใช้โค้ดนี้';

  @override
  String get socialJoinConfirmTitle => 'เข้าร่วมปาร์ตี้อื่นไหม';

  @override
  String get socialJoinSection => 'เข้าร่วมปาร์ตี้อื่น';

  @override
  String get socialJoinWithCode => 'กรอกโค้ดเพื่อเข้าร่วม';

  @override
  String get socialJoined => 'เข้าร่วมปาร์ตี้แล้ว';

  @override
  String socialLastOnline(String relative) {
    return 'ใช้งานเมื่อ $relative';
  }

  @override
  String get socialLeader => 'หัวหน้าปาร์ตี้';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'คุณจะออกจากปาร์ตี้ปัจจุบันและกลับไปเล่นคนเดียว';

  @override
  String get socialLeaveConfirmTitle => 'ออกจากปาร์ตี้ไหม';

  @override
  String get socialLeaveParty => 'ออกจากปาร์ตี้';

  @override
  String socialLevel(int n) {
    return 'เลเวล $n';
  }

  @override
  String get socialMatchFound => 'พบแมตช์แล้ว!';

  @override
  String socialMembersSection(int n, int max) {
    return 'สมาชิก ($n/$max)';
  }

  @override
  String get socialMessageHint => 'พิมพ์ข้อความ…';

  @override
  String get socialMoreActions => 'ตัวเลือกเพิ่มเติม';

  @override
  String get socialNoCode =>
      'สร้างโค้ดเพื่อให้เพื่อนเข้าร่วมปาร์ตี้ได้อย่างรวดเร็ว';

  @override
  String get socialNoCodeMember =>
      'หัวหน้าปาร์ตี้สร้างโค้ดเพื่อเชิญอย่างรวดเร็วได้';

  @override
  String get socialNoFilterResults => 'ไม่มีเพื่อนที่ตรงกับตัวกรองนี้';

  @override
  String get socialNoFriends =>
      'รายชื่อเพื่อน Riot ของคุณว่างอยู่ เพิ่มเพื่อนในเกม';

  @override
  String get socialNoFriendsTitle => 'ยังไม่มีเพื่อน';

  @override
  String get socialNoOnlineFriends =>
      'ยังไม่มีเพื่อนคนไหนออนไลน์ใน VALORANT ตอนนี้';

  @override
  String get socialNoSearchResults => 'ไม่พบเพื่อนที่ตรงกัน';

  @override
  String get socialNoSearchResultsTitle => 'ไม่พบอะไรเลย';

  @override
  String get socialNotFriend => 'ผู้เล่นนี้ไม่ได้อยู่ในรายชื่อเพื่อนของคุณ';

  @override
  String get socialNotReady => 'ยังไม่พร้อม';

  @override
  String socialOfflineSection(int n) {
    return 'ออฟไลน์ ($n)';
  }

  @override
  String get socialOfflineStatus => 'ออฟไลน์';

  @override
  String get socialOnlineMobile => 'ออนไลน์บนมือถือ';

  @override
  String socialOnlineSection(int n) {
    return 'ออนไลน์ ($n)';
  }

  @override
  String get socialOnlineStatus => 'ออนไลน์';

  @override
  String get socialOnlyLeader =>
      'เฉพาะหัวหน้าปาร์ตี้เท่านั้นที่เปลี่ยนคิวและเริ่มหาแมตช์ได้';

  @override
  String get socialOpenParty => 'เปิดปาร์ตี้';

  @override
  String get socialOpenState => 'ปาร์ตี้เปิด';

  @override
  String get socialOtherGamesLeagueOfLegends => 'League of Legends';

  @override
  String get socialOtherGamesBacon => 'Legends of Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'โค้ดปาร์ตี้';

  @override
  String socialPartyCodeValue(String code) {
    return 'โค้ดปาร์ตี้: $code';
  }

  @override
  String get socialPartyInvite => 'คำเชิญเข้าปาร์ตี้';

  @override
  String socialPartyOf(int size, int max) {
    return 'ปาร์ตี้ $size/$max';
  }

  @override
  String get socialPartyTitle => 'ปาร์ตี้และคิว';

  @override
  String socialPickQueueSubtitle(int size) {
    return 'ปาร์ตี้ $size คน';
  }

  @override
  String get socialPickQueueTitle => 'เลือกคิว';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'ปิงที่ดีที่สุดไปยังเซิร์ฟเวอร์แมตช์';

  @override
  String socialPlayingOther(String game) {
    return 'กำลังเล่น $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'กำลังเล่น ($n)';
  }

  @override
  String get socialQueueLabel => 'คิว';

  @override
  String get socialQueueLocked => 'เปลี่ยนคิวไม่ได้ขณะอยู่ในแมตช์';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'สูงสุด $max คน',
      one: 'เล่นคนเดียวเท่านั้น',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'ยืนยันสถานะเกมของคุณไม่ได้ รีเฟรชเพื่อใช้งานปุ่มพร้อมและคิว';

  @override
  String get socialReady => 'พร้อม';

  @override
  String socialReadyCount(int ready, int total) {
    return 'พร้อม $ready/$total';
  }

  @override
  String get socialReasonAccountLevel => 'สมาชิกบางคนมีเลเวลบัญชีไม่ถึง';

  @override
  String get socialReasonGeneric => 'ปาร์ตี้ยังไม่ผ่านเงื่อนไข';

  @override
  String socialReasonPartyTooLarge(int max) {
    return 'ปาร์ตี้มีคนมากเกินไป (สูงสุด $max คน)';
  }

  @override
  String get socialReasonRankDisparity =>
      'แรงก์ต่างกันมากเกินไปสำหรับ Competitive';

  @override
  String socialReasonRestricted(String time) {
    return 'ปาร์ตี้ถูกจำกัดการเข้าคิว (เหลืออีก $time)';
  }

  @override
  String get socialReconnecting => 'แชทหลุดการเชื่อมต่อ กำลังเชื่อมต่อใหม่…';

  @override
  String get socialRemoteNote =>
      'การเปลี่ยนแปลงจะส่งไปยัง Riot เมื่อคุณแตะเท่านั้น ValHub ไม่เคยเข้าคิวหรือล็อกเอเจนท์แทนคุณ';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name จะถูกนำออกจากปาร์ตี้ของคุณ';
  }

  @override
  String get socialRemoveConfirmTitle => 'นำออกจากปาร์ตี้ไหม';

  @override
  String get socialRemoveMember => 'นำออกจากปาร์ตี้';

  @override
  String socialRequestFrom(String name) {
    return '$name ต้องการเข้าร่วมปาร์ตี้';
  }

  @override
  String get socialRequestsSection => 'คำขอเข้าร่วม';

  @override
  String get socialRiotIdFieldHint => 'ชื่อ#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Riot ID ประกอบด้วยชื่อ (3–16 ตัวอักษร) เครื่องหมาย # และแท็ก (ตัวอักษรหรือตัวเลข 3–5 ตัว)';

  @override
  String get socialSearchHint => 'ค้นหาด้วย Riot ID…';

  @override
  String socialSearching(String elapsed) {
    return 'กำลังหาแมตช์ · $elapsed';
  }

  @override
  String get socialSend => 'ส่ง';

  @override
  String get socialSendFailed =>
      'ส่งข้อความไม่ได้ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get socialSendInvite => 'ส่งคำเชิญ';

  @override
  String get socialShareCode => 'แชร์';

  @override
  String socialShareCodeText(String code) {
    return 'เข้าร่วมปาร์ตี้ VALORANT ของฉันด้วยโค้ด: $code';
  }

  @override
  String get socialShootingRange => 'อยู่ในสนามฝึกซ้อม';

  @override
  String get socialShowEveryone => 'แสดงทั้งหมด';

  @override
  String get socialStartQueue => 'เริ่มหาแมตช์';

  @override
  String get socialSuggestionsItem0 => 'หวัดดี!';

  @override
  String get socialSuggestionsItem1 => 'เล่นด้วยกันสักสองสามเกมไหม';

  @override
  String get socialSuggestionsItem2 => 'มาเข้าปาร์ตี้กัน!';

  @override
  String socialUnread(int n) {
    return 'ข้อความยังไม่อ่าน $n ข้อความ';
  }

  @override
  String get socialUnready => 'ยกเลิกพร้อม';

  @override
  String get socialViewProfile => 'ดูโปรไฟล์';

  @override
  String get socialWaitingForConnection =>
      'กำลังเชื่อมต่อ… คุณส่งข้อความได้เมื่อเชื่อมต่อเสร็จ';

  @override
  String get socialYou => 'คุณ';

  @override
  String get socialPartyUnavailable =>
      'ซิงค์ปาร์ตี้ของคุณไม่ได้ รีเฟรชเพื่อลองอีกครั้ง';

  @override
  String get storeAccessoryEmpty => 'ร้านค้าอุปกรณ์เสริมว่างอยู่ในขณะนี้';

  @override
  String get storeAccessoryEmptyTitle => 'ยังไม่มีอุปกรณ์เสริม';

  @override
  String storeAccessoryFrom(String contract) {
    return 'จาก: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'รีเฟรชใน $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'รีเฟรช $wall';
  }

  @override
  String get storeAddToWishlist => 'เพิ่มใน wishlist';

  @override
  String get storeBackToBundles => 'ดูบันเดิลที่วางขาย';

  @override
  String get storeBundleBuySeparateLabel => 'ซื้อแยกชิ้น';

  @override
  String get storeBundleDetailTitle => 'รายละเอียดบันเดิล';

  @override
  String storeBundleEndsAt(String wall) {
    return 'สิ้นสุด $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'เหลือ $t';
  }

  @override
  String storeBundleItemCount(int n) {
    return '$n ไอเทม';
  }

  @override
  String get storeBundleItemFree => 'ฟรี';

  @override
  String get storeBundleItemsTitle => 'ไอเทมในบันเดิล';

  @override
  String get storeBundleNotFound => 'ไม่พบบันเดิลนี้ อาจหมดเวลาขายแล้ว';

  @override
  String get storeBundleNotFoundTitle => 'บันเดิลหมดเวลาแล้ว';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'มีแล้ว $owned/$total ไอเทม';
  }

  @override
  String get storeBundlePriceLabel => 'ราคาบันเดิล';

  @override
  String get storeBundleSavingsLabel => 'ประหยัด';

  @override
  String get storeBundleWholesaleOnly => 'ขายเป็นบันเดิลเท่านั้น ไม่ขายแยกชิ้น';

  @override
  String get storeBundlesEmpty => 'ขณะนี้ไม่มีบันเดิลวางขาย';

  @override
  String get storeBundlesEmptyTitle => 'ยังไม่มีบันเดิล';

  @override
  String get storeDailyEmpty => 'วันนี้ไม่มีสกินในร้านค้า';

  @override
  String get storeDailyEmptyTitle => 'ร้านค้าว่าง';

  @override
  String storeDailyResetAt(String time) {
    return 'รีเฟรชทุกวันเวลา $time';
  }

  @override
  String get storeDailyTotalLabel => 'รวม';

  @override
  String get storeNightMarketEmpty => 'ขณะนี้ยังไม่มีไนท์มาร์เก็ต';

  @override
  String get storeNightMarketEmptyTitle => 'ไนท์มาร์เก็ตยังไม่เปิด';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'สิ้นสุด $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'สิ้นสุดใน $t';
  }

  @override
  String get storeNightMarketNote =>
      'ข้อเสนอในไนท์มาร์เก็ตเป็นของบัญชีคุณโดยเฉพาะและรีเฟรชไม่ได้';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'ประหยัดรวม $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'ยังไม่เปิดการ์ด';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'มีแล้ว';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'มีแล้ว $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'ลบออกจาก wishlist';

  @override
  String storeResetNotificationBody(int skinCount, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      skinCount,
      locale: localeName,
      other: 'ดูสกินใหม่ $skinCount ชิ้นวันนี้ของ $account',
      zero: 'ดูสกินใหม่วันนี้ของ $account',
    );
    return '$_temp0';
  }

  @override
  String get storeResetNotificationTitle => 'ร้านค้าของคุณรีเฟรชแล้ว';

  @override
  String storeResetsIn(String t) {
    return 'รีเฟรชใน $t';
  }

  @override
  String get storeSegmentAccessories => 'อุปกรณ์เสริม';

  @override
  String get storeSegmentBundles => 'บันเดิล';

  @override
  String get storeSegmentDaily => 'รายวัน';

  @override
  String get storeSegmentNightMarket => 'ไนท์มาร์เก็ต';

  @override
  String get storeShareButton => 'แชร์';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'ร้านค้าวันนี้';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'ไนท์มาร์เก็ต';

  @override
  String get storeShareCardPriceNote =>
      'ราคาที่แปลงเป็นเพียงการประมาณจากแพ็ก VP';

  @override
  String storeShareCardSaved(String vp) {
    return 'ประหยัด $vp';
  }

  @override
  String get storeShareCardTagline => 'ผู้ช่วย VALORANT ของคุณ';

  @override
  String storeShareCardTotal(String vp) {
    return 'รวม $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'ถึง $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'แชร์ร้านค้าวันนี้';

  @override
  String get storeShareFailed => 'สร้างรูปภาพไม่ได้ ลองอีกครั้ง';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => 'แชร์รูปภาพ';

  @override
  String get storeShareNightMarketTitle => 'แชร์ไนท์มาร์เก็ต';

  @override
  String get storeSharePreparing => 'กำลังโหลดรูปสกิน…';

  @override
  String get storeShareShowPrice => 'แสดงราคาประมาณ';

  @override
  String get storeShareShowPriceHint => 'แปลงตามแพ็ก VP ที่คุ้มที่สุด';

  @override
  String get storeShareShowRiotId => 'แสดง Riot ID บนรูปภาพ';

  @override
  String get storeShareShowRiotIdHint =>
      'ปิดไว้เป็นค่าเริ่มต้นเพื่อความเป็นส่วนตัวของคุณ';

  @override
  String get storeShareSubjectDaily => 'ร้านค้า VALORANT ของฉันวันนี้';

  @override
  String get storeShareSubjectNightMarket => 'ไนท์มาร์เก็ต VALORANT ของฉัน';

  @override
  String get storeShareSubtitle =>
      'แชร์รูปร้านค้าของคุณให้เพื่อนผ่านแอปที่คุณเลือก';

  @override
  String get storeTitle => 'ร้านค้า';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'ยอดคงเหลือ: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return 'ใน wishlist $n';
  }

  @override
  String wishlistNotifDailyBody(
    String skin,
    String account,
    String hasTime,
    String left,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasTime, {
      'yes': '$skin อยู่ในร้านค้าของ $account — เหลือ $left',
      'other': '$skin อยู่ในร้านค้าของ $account',
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
      'discount': '$skin ลด $percent% เหลือ $price ($account)',
      'price': '$skin เหลือเพียง $price ($account)',
      'other': '$skin อยู่ในไนท์มาร์เก็ตของ $account',
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
      'yes': '$skin อยู่ในบันเดิล $bundle ($account)',
      'other': '$skin อยู่ในบันเดิลที่วางขาย ($account)',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: '$names และสกินอื่นอีก $more ชิ้นอยู่ในร้านค้าของ $account',
      zero: '$names อยู่ในร้านค้าของ $account',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', อยู่ใน wishlist แล้ว',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'เพิ่มสกิน';

  @override
  String get wishlistAddToWishlist => 'เพิ่มใน wishlist';

  @override
  String get wishlistAllWeapons => 'อาวุธทั้งหมด';

  @override
  String get wishlistBrowseCatalog => 'ดูสกินทั้งหมด';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString สกิน';
  }

  @override
  String get wishlistCatalogEmpty =>
      'โหลดรายการสกินไม่ได้ รีเฟรชเพื่อลองอีกครั้ง';

  @override
  String get wishlistCatalogEmptyTitle => 'ยังไม่มีสกิน';

  @override
  String wishlistCatalogInWishlist(String count) {
    return 'ใน wishlist: $count';
  }

  @override
  String get wishlistCatalogSubtitle => 'แตะ ♡ เพื่อเพิ่มสกินใน wishlist';

  @override
  String get wishlistCatalogTitle => 'สกินทั้งหมด';

  @override
  String get wishlistChooseWeapon => 'เลือกอาวุธ';

  @override
  String get wishlistClearFilters => 'ล้างตัวกรอง';

  @override
  String get wishlistClearSearch => 'ล้างการค้นหา';

  @override
  String get wishlistEmpty =>
      'wishlist ของคุณว่างอยู่ แตะ ♡ ที่สกินใดก็ได้เพื่อเพิ่ม';

  @override
  String get wishlistEmptyTitle => 'ยังไม่มีสกิน';

  @override
  String wishlistEndsIn(String time) {
    return 'สิ้นสุดใน $time';
  }

  @override
  String get wishlistExcludedRewards => 'ไม่รวมสกินที่เป็นรางวัล';

  @override
  String get wishlistFilterTiers => 'รุ่น';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'กำลังกรอง: $countString สกิน · $value';
  }

  @override
  String get wishlistHasEstimates => 'รวมราคาประมาณ (≈)';

  @override
  String get wishlistInWishlist => 'อยู่ใน wishlist แล้ว';

  @override
  String get wishlistInWishlistLabel => 'อยู่ใน wishlist แล้ว';

  @override
  String get wishlistNoMatch =>
      'ไม่มีสกินที่ตรงกัน ล้างตัวกรองเพื่อดูเพิ่มเติม';

  @override
  String get wishlistNoMatchTitle => 'ไม่พบสกิน';

  @override
  String get wishlistNotifBundleTitle => 'บันเดิลใหม่มีสกินใน wishlist';

  @override
  String get wishlistNotifDailyTitle => 'สกินใน wishlist มาแล้ว!';

  @override
  String get wishlistNotifNightMarketTitle =>
      'ไนท์มาร์เก็ตมีสกินที่คุณอยากได้!';

  @override
  String get wishlistNotifPermissionMissing =>
      'แอปยังไม่ได้รับอนุญาตให้ส่งการแจ้งเตือน';

  @override
  String wishlistNotifSummaryTitle(int count) {
    return 'สกินใน wishlist $count ชิ้นกำลังวางขาย!';
  }

  @override
  String get wishlistNotifToggle => 'การแจ้งเตือน wishlist';

  @override
  String get wishlistNotifToggleSubtitle =>
      'สำหรับบัญชีนี้ แม้คุณไม่ได้เปิดแอป';

  @override
  String wishlistOfAccount(String riotId) {
    return 'wishlist ของ $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'สกินใน wishlist $count ชิ้นกำลังวางขาย!',
      one: 'มีสกินใน wishlist หนึ่งชิ้นกำลังวางขาย!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint => 'แตะแถวที่ไฮไลต์เพื่อดูข้อเสนอ';

  @override
  String get wishlistOpenSettings => 'เปิดการตั้งค่า';

  @override
  String get wishlistOwned => 'มีแล้ว';

  @override
  String get wishlistRemoveAction => 'ลบออกจาก wishlist';

  @override
  String get wishlistRemoveFromWishlist => 'ลบออกจาก wishlist';

  @override
  String wishlistRemoved(String name) {
    return 'ลบ $name ออกจาก wishlist แล้ว';
  }

  @override
  String get wishlistSearchHint => 'ค้นหาสกิน…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString สกิน';
  }

  @override
  String get wishlistSortBy => 'เรียงลำดับ';

  @override
  String wishlistSortLabel(String sort) {
    return 'เรียง: $sort';
  }

  @override
  String get wishlistSortName => 'ชื่อ';

  @override
  String get wishlistSortPrice => 'ราคา';

  @override
  String get wishlistSortRarity => 'ความหายาก';

  @override
  String get wishlistSortWeapon => 'อาวุธ';

  @override
  String get wishlistStoreCheckTitle => 'ตรวจสอบร้านค้าไม่ได้';

  @override
  String get wishlistSubtitle => 'สกินที่คุณกำลังตามล่า';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistTotalValue => 'มูลค่ารวมของ wishlist';

  @override
  String get wishlistUndo => 'เลิกทำ';

  @override
  String get wishlistViewInStore => 'ดูในร้านค้า';

  @override
  String get wishlistWeapon => 'อาวุธ';

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
      'yes': ', อยู่ใน wishlist',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', อยู่ใน wishlist',
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
      'gain': 'เพิ่มขึ้น',
      'other': 'ลดลง',
    });
    return 'วันนี้ $_temp0 $rr RR ชนะ $wins แพ้ $losses';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', เสมอ $draws',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', ไม่ทราบผล $unknown แมตช์',
      zero: '',
    );
    return 'ชนะ $wins – แพ้ $losses$_temp0$_temp1';
  }

  @override
  String get homeAllHiddenBody => 'เปิดปรับแต่งหน้าหลักเพื่อแสดงอีกครั้ง';

  @override
  String get homeAllHiddenTitle => 'คุณซ่อนการ์ดทั้งหมดแล้ว';

  @override
  String get homeCardBattlePass => 'Battle Pass';

  @override
  String get homeCardBattlePassDesc =>
      'เลเวล XP ที่ต้องทำต่อวัน และภารกิจรายสัปดาห์';

  @override
  String get homeCardCommunity => 'ชุมชน';

  @override
  String get homeCardCommunityDesc =>
      'หาเพื่อนร่วมทีมแรงก์ใกล้เคียงและสกินที่ถูกใจที่สุดของสัปดาห์';

  @override
  String get homeCardFriends => 'เพื่อนที่กำลังเล่น';

  @override
  String get homeCardFriendsDesc => 'เพื่อนที่อยู่ในแมตช์หรือกำลังหาแมตช์';

  @override
  String homeCardHidden(String name) {
    return 'ซ่อน \"$name\" แล้ว';
  }

  @override
  String get homeCardLive => 'แมตช์ปัจจุบัน';

  @override
  String get homeCardLiveDesc =>
      'แสดงเมื่อคุณกำลังหาแมตช์ เลือกเอเจนท์ หรืออยู่ในแมตช์';

  @override
  String get homeCardOtherAccounts => 'บัญชีอื่น';

  @override
  String get homeCardOtherAccountsDesc =>
      'สถานะและ wishlist ของบัญชีอื่นๆ ของคุณ';

  @override
  String get homeCardRank => 'แรงก์และฟอร์ม';

  @override
  String get homeCardRankDesc =>
      'แรงก์ RR วันนี้ สถิติชนะ/แพ้ติดกัน และจำนวนแมตช์ที่ต้องเล่นเพื่อขึ้นแรงก์';

  @override
  String get homeCardServerStatus => 'สถานะเซิร์ฟเวอร์';

  @override
  String get homeCardServerStatusDesc =>
      'แสดงเฉพาะเมื่อมีการปิดปรับปรุงหรือปัญหา';

  @override
  String get homeCardStore => 'ร้านค้าวันนี้';

  @override
  String get homeCardStoreDesc => 'สกินรายวัน wishlist และไนท์มาร์เก็ต';

  @override
  String get homeCustomize => 'ปรับแต่งหน้าหลัก';

  @override
  String get homeCustomizeHint => 'ลากเพื่อจัดลำดับ ปิดเพื่อซ่อนการ์ด';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'ไปที่ $name แล้ว';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'เปิด';

  @override
  String get homeFriendsConsentBody =>
      'เพื่อดูว่าเพื่อนคนไหนกำลังเล่น ValHub จะเชื่อมต่อแชท Riot ของบัญชีที่ใช้อยู่ทุกครั้งที่คุณเปิดหน้าหลัก เพื่อนจะเห็นว่าคุณออนไลน์ คุณปิดได้ในปรับแต่งหน้าหลัก';

  @override
  String get homeFriendsConsentDecline => 'ไม่ ซ่อนการ์ด';

  @override
  String get homeFriendsConsentTitle => 'ดูว่าเพื่อนคนไหนกำลังเล่นไหม';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    return 'เพื่อนกำลังเล่น $n คน';
  }

  @override
  String get homeFriendsSeeAll => 'ดูทั้งหมด';

  @override
  String get homeHideCard => 'ซ่อนการ์ดนี้';

  @override
  String homeLeaderboard(String pos) {
    return 'อันดับ $pos บนลีดเดอร์บอร์ด';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'เหลือ $time';
  }

  @override
  String homeLfgNeeds(int n) {
    return 'ต้องการ $n คน';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'หาเพื่อนร่วมทีมแรงก์ใกล้เคียงคุณ';

  @override
  String get homeLiveAllyLabel => 'ทีมของคุณ';

  @override
  String get homeLiveEnemyLabel => 'ทีมศัตรู';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'กำลังหาแมตช์ รอมาแล้ว $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'ทีมของคุณ $ally ทีมศัตรู $enemy';
  }

  @override
  String homeLossStreak(int n) {
    return 'แพ้ Competitive ติดกัน $n แมตช์';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    return '≈ $n แมตช์เพื่อไปถึง $rank';
  }

  @override
  String homeMoreActions(String name) {
    return 'ตัวเลือกสำหรับ $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'เข้าสู่ระบบอีกครั้งเพื่ออัปเดตร้านค้า แรงก์ และ Battle Pass ของ $riotId คุณยังดูข้อมูลที่บันทึกไว้ในอุปกรณ์ได้';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'เหลือ $time';
  }

  @override
  String get homeNightMarketNew => 'ใหม่';

  @override
  String get homeNightMarketTitle => 'ไนท์มาร์เก็ต';

  @override
  String homeNightMarketWaiting(int n) {
    return 'ข้อเสนอ $n รายการรอให้คุณเปิด';
  }

  @override
  String get homeNoRankedToday => 'วันนี้ยังไม่ได้เล่น Competitive';

  @override
  String get homeOpenLfg => 'ดูโพสต์หาเพื่อนร่วมทีมทั้งหมด';

  @override
  String get homeOpenRanking => 'ดูอันดับสกิน';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'บัญชีอื่น ($n)';
  }

  @override
  String homeOtherMore(int n) {
    return '+$n บัญชี';
  }

  @override
  String get homeOtherWishlistHit => 'มีสกินใน wishlist';

  @override
  String homePreviousAct(String rank) {
    return 'แอคท์ก่อน: $rank';
  }

  @override
  String get homeQuietBody => 'ดึงลงเพื่อรีเฟรช';

  @override
  String get homeQuietTitle => 'ยังไม่มีอะไรใหม่';

  @override
  String homeRankToNext(int rr) {
    return 'อีก $rr RR จะขึ้นแรงก์';
  }

  @override
  String get homeResetLayout => 'คืนค่าเริ่มต้น';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'วันนี้ $value';
  }

  @override
  String get homeStatusDetails => 'รายละเอียด';

  @override
  String homeStatusIncident(String region) {
    return 'เซิร์ฟเวอร์มีปัญหา · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'กำลังปิดปรับปรุง · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'จะปิดปรับปรุงเร็วๆ นี้ · $region';
  }

  @override
  String homeStatusMore(int n) {
    return '+$n ประกาศ';
  }

  @override
  String get homeStoreRefreshing => 'กำลังรีเฟรช…';

  @override
  String homeStoreResetsIn(String time) {
    return 'รีเฟรชใน $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'รวม $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'กระเป๋า $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    return 'กระเป๋า $vp · ซื้อได้สูงสุด $n สกิน';
  }

  @override
  String get homeStoreWishlistHit => 'มีสกินใน wishlist!';

  @override
  String homeStoreWishlistHits(int n) {
    return 'สกินใน wishlist $n ชิ้นกำลังวางขาย';
  }

  @override
  String get homeTitle => 'หน้าหลัก';

  @override
  String get homeTrendingTitle => 'สกินที่ถูกใจที่สุดทั่วโลก';

  @override
  String homeTrendingVotes(int n) {
    return 'ถูกใจ $n';
  }

  @override
  String get homeUndo => 'เลิกทำ';

  @override
  String homeWinStreak(int n) {
    return 'ชนะ Competitive ติดกัน $n แมตช์';
  }

  @override
  String get homeStoreOutdated =>
      'ร้านค้าเปลี่ยนแล้ว ValHub ยังโหลดร้านค้าใหม่ไม่ได้';

  @override
  String get communityErrorConsent =>
      'ยอมรับการแชร์ Riot ID กับชุมชนเพื่อดำเนินการต่อ';

  @override
  String get communityErrorForbidden =>
      'คุณยังทำสิ่งนี้ไม่ได้ ดูแนวทางของชุมชนหรือติดต่อ ValHub';

  @override
  String get communityErrorGeneric => 'เกิดข้อผิดพลาดบางอย่าง ลองอีกครั้ง';

  @override
  String get communityErrorImageTooLarge =>
      'รูปภาพใหญ่เกินไป (สูงสุด 2 MB) เลือกรูปอื่น';

  @override
  String get communityErrorImageType => 'เลือกรูปภาพ JPEG, PNG หรือ WebP';

  @override
  String get communityErrorInvalid =>
      'เนื้อหาของคุณไม่ผ่าน ตรวจสอบแล้วลองอีกครั้ง';

  @override
  String get communityErrorNetwork =>
      'เชื่อมต่อชุมชน ValHub ไม่ได้ ตรวจสอบการเชื่อมต่อแล้วลองอีกครั้ง';

  @override
  String get communityErrorNotFound => 'เนื้อหานี้ไม่มีอยู่แล้ว';

  @override
  String get communityErrorPickImage => 'เปิดคลังรูปภาพไม่ได้ ลองอีกครั้ง';

  @override
  String get communityErrorRateLimited =>
      'ชุมชนได้รับคำขอมากเกินไป ลองอีกครั้งในอีกสักครู่';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'ชุมชนได้รับคำขอมากเกินไป ลองอีกครั้งใน $duration';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot ยืนยันบัญชีของคุณไม่ได้ เข้าสู่ระบบบัญชี Riot อีกครั้งแล้วลองใหม่';

  @override
  String get communityErrorRiotUnavailable =>
      'Riot กำลังมีปัญหา ลองอีกครั้งในอีกสักครู่';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot กำลังมีปัญหา ลองอีกครั้งใน $duration';
  }

  @override
  String get communityErrorServer =>
      'ชุมชน ValHub กำลังมีปัญหา ลองอีกครั้งในอีกสักครู่';

  @override
  String get communityErrorStorageFull =>
      'พื้นที่เก็บรูปภาพของชุมชนเต็มแล้ว คุณยังโพสต์ได้แต่แนบรูปไม่ได้ในตอนนี้ ลองอีกครั้งภายหลัง';

  @override
  String get communityErrorTimeout =>
      'ชุมชน ValHub ตอบสนองช้าเกินไป ลองอีกครั้ง';

  @override
  String get communityErrorTitle => 'ดำเนินการไม่สำเร็จ';

  @override
  String get communityErrorUnauthorized =>
      'การเชื่อมต่อชุมชนหมดอายุแล้ว ลองอีกครั้ง';

  @override
  String get communityErrorImageQuota =>
      'พื้นที่เก็บรูปภาพของคุณเต็มแล้ว ลบโพสต์ที่มีรูปภาพบางโพสต์แล้วลองอีกครั้ง';

  @override
  String get smokePlain => 'ตรวจสอบการสร้างโค้ด';

  @override
  String smokeGreeting(String name) {
    return 'สวัสดี $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n รายการ',
    );
    return '$_temp0';
  }
}
