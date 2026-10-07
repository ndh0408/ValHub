// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get commonListSeparator => '، ';

  @override
  String get commonPriceSourceLabel => 'عرض مصدر الأسعار';

  @override
  String get commonErrorApi =>
      'تواجه Riot مشكلة حاليًا. يُرجى المحاولة بعد بضع دقائق.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonCancel => 'إلغاء';

  @override
  String get commonClearFilters => 'مسح عوامل التصفية';

  @override
  String get commonClearSearch => 'مسح البحث';

  @override
  String get commonClose => 'إغلاق';

  @override
  String get commonCopied => 'تم النسخ';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n يوم',
      many: '$n يومًا',
      few: '$n أيام',
      two: '$n يومان',
      one: '$n يوم',
      zero: '$n يوم',
    );
    return '$_temp0';
  }

  @override
  String commonDaysAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'منذ $n يوم',
      many: 'منذ $n يومًا',
      few: 'منذ $n أيام',
      two: 'منذ $n يومين',
      one: 'منذ $n يوم',
      zero: 'منذ $n يوم',
    );
    return '$_temp0';
  }

  @override
  String get commonDelete => 'حذف';

  @override
  String get commonEmptyGeneric => 'لا يوجد شيء هنا بعد.';

  @override
  String get commonErrorContentUnavailable =>
      'تعذّر تحميل المظاهر والعملاء والخرائط. يُرجى التحقق من الاتصال والمحاولة مجددًا.';

  @override
  String get commonErrorGeneric => 'حدث خطأ ما. يُرجى المحاولة مجددًا.';

  @override
  String get commonErrorMaintenance =>
      'خوادم VALORANT قيد الصيانة. يُرجى العودة لاحقًا.';

  @override
  String get commonErrorNeedsLogin =>
      'انتهت صلاحية تسجيل الدخول إلى Riot. يُرجى تسجيل الدخول مجددًا للمتابعة.';

  @override
  String get commonErrorNeedsLoginTitle => 'يلزم تسجيل الدخول مجددًا';

  @override
  String get commonErrorNetwork =>
      'لا يوجد اتصال بالشبكة. يُرجى التحقق من Wi-Fi أو بيانات الجوال والمحاولة مجددًا.';

  @override
  String get commonErrorNoAccount => 'لم يتم تسجيل الدخول إلى أي حساب.';

  @override
  String get commonErrorNotFound => 'تعذّر العثور على هذا المحتوى.';

  @override
  String get commonErrorTimeout =>
      'تستغرق Riot وقتًا طويلًا للرد. يُرجى التحقق من الاتصال والمحاولة مجددًا.';

  @override
  String get commonErrorTransient =>
      'Riot مشغولة حاليًا. يُرجى المحاولة بعد بضع دقائق.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot مشغولة حاليًا. يُرجى المحاولة بعد $duration.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'تعذّر تحديد منطقة Riot. يُرجى اختيار المنطقة من الإعدادات.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonGoHome => 'إلى الرئيسية';

  @override
  String commonHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ساعة',
      many: '$n ساعة',
      few: '$n ساعات',
      two: '$n ساعتان',
      one: '$n ساعة',
      zero: '$n ساعة',
    );
    return '$_temp0';
  }

  @override
  String commonHoursAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'منذ $n ساعة',
      many: 'منذ $n ساعة',
      few: 'منذ $n ساعات',
      two: 'منذ $n ساعتين',
      one: 'منذ $n ساعة',
      zero: 'منذ $n ساعة',
    );
    return '$_temp0';
  }

  @override
  String get commonIncidentTitle => 'عطل في الخادم';

  @override
  String get commonJustNow => 'الآن';

  @override
  String get commonLoadMore => 'تحميل المزيد';

  @override
  String get commonLoading => 'جارٍ التحميل…';

  @override
  String get commonMaintenanceTitle => 'صيانة الخادم';

  @override
  String commonMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n دقيقة',
      many: '$n دقيقة',
      few: '$n دقائق',
      two: '$n دقيقتان',
      one: '$n دقيقة',
      zero: '$n دقيقة',
    );
    return '$_temp0';
  }

  @override
  String commonMinutesAgo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'منذ $n دقيقة',
      many: 'منذ $n دقيقة',
      few: 'منذ $n دقائق',
      two: 'منذ $n دقيقتين',
      one: 'منذ $n دقيقة',
      zero: 'منذ $n دقيقة',
    );
    return '$_temp0';
  }

  @override
  String get commonNoData => 'لا يوجد ما يُعرض بعد';

  @override
  String commonOfflineCached(String time) {
    return 'لا يوجد اتصال — يتم عرض البيانات المحفوظة ($time).';
  }

  @override
  String get commonOpenSettings => 'فتح الإعدادات';

  @override
  String get commonPageNotFound => 'تعذّر العثور على هذه الشاشة.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'الحزمة الأوفر: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'تعديل السعر الذي أدخلته';

  @override
  String get commonPriceEnterOwn => 'أدخل سعر حزمة VP لديك';

  @override
  String get commonPriceEstimateBody =>
      'المبلغ “≈ …” بجانب أسعار VP تقديري، محسوب وفق حزمة VP الأوفر. الدفع داخل اللعبة يكون بـ VP؛ ويعتمد المبلغ الفعلي على الحزمة ووسيلة الدفع والضرائب والعروض وقت الشراء.';

  @override
  String get commonPriceEstimateTitle => 'السعر التقديري';

  @override
  String get commonPriceEstimateTooltip =>
      'سعر تقديري — المس لمعرفة طريقة الحساب';

  @override
  String get commonPriceHidden =>
      'تم إخفاء الأسعار التقديرية. يمكن إظهارها مجددًا من الإعدادات.';

  @override
  String get commonPriceHide => 'إخفاء الأسعار التقديرية';

  @override
  String get commonPriceOpenSource => 'فتح صفحة المصدر';

  @override
  String get commonPriceOverrideBody =>
      'أدخل المبلغ الذي دفعته فعليًا مقابل حزمة VP (راجع متجر اللعبة أو الإيصال). يستخدم ValHub هذا السعر لتقدير أسعار جميع العناصر؛ ويُحفظ على هذا الجهاز فقط.';

  @override
  String get commonPriceOverrideCurrency => 'رمز العملة';

  @override
  String get commonPriceOverrideCurrencyHint => 'مثال: USD، EUR، JPY، VND';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'مثال تقديري: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'أدخل رمز عملة من 3 أحرف، مثل USD أو EUR.';

  @override
  String get commonPriceOverrideInvalidNumber => 'أدخل رقمًا أكبر من 0.';

  @override
  String get commonPriceOverridePrice => 'سعر الحزمة';

  @override
  String get commonPriceOverrideRemove => 'إزالة السعر الذي أدخلته';

  @override
  String get commonPriceOverrideRemoved => 'تمت إزالة السعر الذي أدخلته.';

  @override
  String get commonPriceOverrideSave => 'حفظ السعر';

  @override
  String get commonPriceOverrideSaved => 'تم حفظ سعر حزمة VP.';

  @override
  String get commonPriceOverrideTitle => 'سعر حزمة VP لديك';

  @override
  String get commonPriceOverrideVp => 'عدد VP في الحزمة';

  @override
  String get commonPricePacksTitle => 'حزم VP';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'وفق أسعار حزم VP في المنطقة $country';
  }

  @override
  String get commonPriceSourceUser => 'وفق سعر حزمة VP الذي أدخلته';

  @override
  String get commonPriceUnavailable =>
      'لا توجد قائمة أسعار موثّقة لمنطقتك بعد. أدخل سعر حزمة VP اشتريتها سابقًا لعرض الأسعار التقديرية.';

  @override
  String commonPriceUpdated(String date) {
    return 'تحديث قائمة الأسعار: $date';
  }

  @override
  String get commonRetry => 'إعادة المحاولة';

  @override
  String get commonRiotDisclaimer =>
      'لم تُصادق Riot Games على ValHub، ولا يعكس آراء Riot Games أو أي شخص مشارك رسميًا في إنتاج منتجات Riot Games أو إدارتها. Riot Games وجميع الممتلكات المرتبطة بها علامات تجارية أو علامات تجارية مسجلة لشركة Riot Games, Inc.';

  @override
  String get commonSave => 'حفظ';

  @override
  String get commonSearch => 'بحث…';

  @override
  String commonSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n ثانية',
      many: '$n ثانية',
      few: '$n ثوانٍ',
      two: '$n ثانيتان',
      one: '$n ثانية',
      zero: '$n ثانية',
    );
    return '$_temp0';
  }

  @override
  String get commonShare => 'مشاركة';

  @override
  String get commonSignInAgain => 'تسجيل الدخول مجددًا';

  @override
  String get commonSort => 'ترتيب';

  @override
  String commonSortBy(String option) {
    return 'الترتيب: $option';
  }

  @override
  String get commonTabBattlePass => 'Battle Pass';

  @override
  String get commonTabCollection => 'المجموعة';

  @override
  String get commonTabCommunity => 'المجتمع';

  @override
  String get commonTabHome => 'الرئيسية';

  @override
  String get commonTabProfile => 'الملف الشخصي';

  @override
  String get commonTabSettings => 'الإعدادات';

  @override
  String get commonTabStore => 'المتجر';

  @override
  String get commonTagline => 'رفيقك في VALORANT';

  @override
  String get commonToday => 'اليوم';

  @override
  String get commonTodayLower => 'اليوم';

  @override
  String get commonTomorrow => 'غدًا';

  @override
  String get commonUnknownItem => 'عنصر غير معروف';

  @override
  String commonUpdatedAt(String time) {
    return 'تم التحديث في $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$time $day';
  }

  @override
  String get commonWeekdaysItem0 => 'الاثنين';

  @override
  String get commonWeekdaysItem1 => 'الثلاثاء';

  @override
  String get commonWeekdaysItem2 => 'الأربعاء';

  @override
  String get commonWeekdaysItem3 => 'الخميس';

  @override
  String get commonWeekdaysItem4 => 'الجمعة';

  @override
  String get commonWeekdaysItem5 => 'السبت';

  @override
  String get commonWeekdaysItem6 => 'الأحد';

  @override
  String get commonYesterday => 'أمس';

  @override
  String get commonYesterdayTitle => 'أمس';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'انتهت صلاحية تسجيل الدخول إلى Riot — يتم عرض البيانات المحفوظة ($time).';
  }

  @override
  String get contentCategoryHeavy => 'أسلحة ثقيلة';

  @override
  String get contentCategoryMelee => 'سلاح أبيض';

  @override
  String get contentCategoryRifle => 'بنادق';

  @override
  String get contentCategoryShotgun => 'بنادق الشوتغن';

  @override
  String get contentCategorySidearm => 'مسدسات';

  @override
  String get contentCategorySmg => 'مسدسات رشاشة';

  @override
  String get contentCategorySniper => 'بنادق قنص';

  @override
  String get contentCurrencyAgentTokens => 'عملات عميل';

  @override
  String get contentCurrencyKc => 'KC';

  @override
  String get contentCurrencyKcFull => 'رصيد كينغدام';

  @override
  String get contentCurrencyRp => 'RP';

  @override
  String get contentCurrencyRpFull => 'راديانايت';

  @override
  String get contentCurrencyVp => 'VP';

  @override
  String get contentCurrencyVpFull => 'نقاط VALORANT';

  @override
  String get contentItemAgent => 'عميل';

  @override
  String get contentItemBuddy => 'تعليقة سلاح';

  @override
  String get contentItemCard => 'بطاقة اللاعب';

  @override
  String get contentItemChroma => 'تنويعة';

  @override
  String get contentItemContract => 'عقد';

  @override
  String get contentItemCurrency => 'عملة';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemSkin => 'مظهر';

  @override
  String get contentItemSpray => 'رذاذ';

  @override
  String get contentItemTitle => 'لقب اللاعب';

  @override
  String contentLevel(int n) {
    return 'المستوى $n';
  }

  @override
  String get contentLevelBase => 'أساسي';

  @override
  String get contentLevelItemLabelsVFX => 'مؤثرات بصرية';

  @override
  String get contentLevelItemLabelsAnimation => 'رسوم متحركة';

  @override
  String get contentLevelItemLabelsFinisher => 'ضربة الإنهاء';

  @override
  String get contentLevelItemLabelsKillCounter => 'عدّاد القتلات';

  @override
  String get contentLevelItemLabelsSoundEffects => 'مؤثرات صوتية';

  @override
  String get contentLevelItemLabelsTransformation => 'تحوّل';

  @override
  String get contentLevelItemLabelsKillBanner => 'لافتة القتل';

  @override
  String get contentLevelItemLabelsKillEffect => 'مؤثر القتل';

  @override
  String get contentLevelItemLabelsInspectAndKill => 'مؤثرات الفحص والقتل';

  @override
  String get contentLevelItemLabelsVoiceover => 'تعليق صوتي';

  @override
  String get contentLevelItemLabelsSongShuffle => 'تبديل الأغاني';

  @override
  String get contentLevelItemLabelsRandomizer => 'اختيار عشوائي';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'تبديل حسب الهجوم/الدفاع';

  @override
  String get contentLevelItemLabelsTopFrag => 'مؤثر صاحب أعلى قتلات';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'مستشعر نبضات القلب والخريطة';

  @override
  String get contentLevelItemLabelsFishAnimation => 'حركة السمكة';

  @override
  String get contentNoTitle => 'بلا لقب';

  @override
  String get contentNotForSale => 'غير معروض للبيع';

  @override
  String get contentQueueNamesCompetitive => 'تنافسي';

  @override
  String get contentQueueNamesUnrated => 'غير مصنف';

  @override
  String get contentQueueNamesSwiftplay => 'سويفت بلاي';

  @override
  String get contentQueueNamesSpikerush => 'سبايك راش';

  @override
  String get contentQueueNamesDeathmatch => 'مباراة الموت';

  @override
  String get contentQueueNamesHurm => 'مباراة الموت للفرق';

  @override
  String get contentQueueNamesGgteam => 'إسكيليشن';

  @override
  String get contentQueueNamesOnefa => 'الاستنساخ';

  @override
  String get contentQueueNamesPremier => 'بريمير';

  @override
  String get contentQueueNamesCustom => 'لعبة مخصصة';

  @override
  String get contentQueueNames => 'لعبة مخصصة';

  @override
  String get contentQueueNamesDodgeball => 'ضربة قاضية';

  @override
  String get contentQueueNamesFortcollins => 'استعادة السيطرة';

  @override
  String get contentQueueNamesSkirmish2v2 => 'المناوشة: 2 ضد 2';

  @override
  String get contentQueueNamesSkirmishascension1v1 =>
      'المناوشة: الارتقاء 1 ضد 1';

  @override
  String get contentQueueNamesSkirmishascension2v2 =>
      'المناوشة: الارتقاء 2 ضد 2';

  @override
  String get contentQueueNamesValaram => 'الكل عشوائي في موقع واحد';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'قتال كرات الثلج';

  @override
  String get contentQueueNamesNewmap => 'ساميت';

  @override
  String get contentQueueShortNamesCompetitive => 'تنافسي';

  @override
  String get contentQueueShortNamesValaram => 'عشوائي بالكامل';

  @override
  String get contentRewardSourceAgent => 'عقد عميل';

  @override
  String get contentRewardSourceBattlePass => 'جائزة Battle Pass';

  @override
  String get contentRewardSourceEvent => 'رخصة فعالية';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'مبارز';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'مبادر';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'متحكم';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'حارس';

  @override
  String get contentTierDeluxe => 'فاخر';

  @override
  String get contentTierExclusive => 'حصري';

  @override
  String contentTierFull(String shortName) {
    return 'إصدار $shortName';
  }

  @override
  String get contentTierPremium => 'ممتاز';

  @override
  String get contentTierSelect => 'مختار';

  @override
  String get contentTierUltra => 'خارق';

  @override
  String get contentUnranked => 'بلا تصنيف';

  @override
  String get accountRegionUnknown => 'منطقة غير معروفة';

  @override
  String accountRiotCountry(String country) {
    return 'دولة حساب Riot: $country';
  }

  @override
  String get accountRiotCountryUnknown => 'دولة حساب Riot: غير معروفة';

  @override
  String accountAccountsHeader(int count, int max) {
    return 'الحسابات ($count/$max)';
  }

  @override
  String get accountActive => 'قيد الاستخدام';

  @override
  String accountAddAccount(int count, int max) {
    return 'إضافة حساب ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'مسح البيانات المحلية';

  @override
  String get accountClearLocalDataConfirm =>
      'هل تريد مسح السجل والتجهيزات المحفوظة وبيانات الحسابات التي تم تسجيل الخروج منها على هذا الجهاز؟';

  @override
  String get accountClearRrHistory => 'مسح سجل RR';

  @override
  String get accountClearRrHistoryConfirm =>
      'هل تريد مسح سجل RR للحساب المحدد على هذا الجهاز؟';

  @override
  String get accountCopyPassword => 'نسخ كلمة المرور';

  @override
  String get accountCopyUsername => 'نسخ اسم المستخدم';

  @override
  String get accountDeleteLoginNote => 'حذف المعلومات';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'هل تريد حذف اسم المستخدم وكلمة المرور المحفوظين لهذا الحساب؟';

  @override
  String get accountHidePassword => 'إخفاء كلمة المرور';

  @override
  String get accountKeepLocalData => 'الاحتفاظ بالبيانات المحلية';

  @override
  String get accountKeepLocalDataHint =>
      'الاحتفاظ بقائمة الأمنيات والتجهيزات والسجل على هذا الجهاز';

  @override
  String accountLevelShort(int level) {
    return 'المستوى $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'تم تسجيل الخروج من الحساب الوارد في هذا الإشعار. يُرجى تسجيل الدخول مجددًا ثم فتح الإشعار.';

  @override
  String get accountLocalDataCleared => 'تم مسح البيانات المحلية';

  @override
  String get accountLoginNote => 'معلومات تسجيل الدخول';

  @override
  String get accountLoginNoteDeleted => 'تم حذف معلومات تسجيل الدخول';

  @override
  String get accountLoginNoteEmpty => 'لا توجد معلومات تسجيل دخول محفوظة';

  @override
  String get accountLoginNoteHint =>
      'تُحفظ على هذا الجهاز فقط وهي مقفلة بأمان. استخدمها للرجوع إليها أو لملء بياناتك بسرعة عند تسجيل الدخول مجددًا.';

  @override
  String get accountLoginNoteLocked => 'فتح معلومات تسجيل الدخول';

  @override
  String get accountLoginNotePassword => 'كلمة المرور';

  @override
  String get accountLoginNoteSaved => 'تم حفظ معلومات تسجيل الدخول';

  @override
  String get accountLoginNoteUsername => 'اسم مستخدم Riot';

  @override
  String get accountManageHint =>
      'يمكن إزالة الحسابات أو تعديل معلومات تسجيل الدخول من الإعدادات.';

  @override
  String accountMaxAccounts(int max) {
    return 'تم بلوغ الحد الأقصى من الحسابات ($max).';
  }

  @override
  String get accountNeedsLogin => 'يلزم تسجيل الدخول مجددًا';

  @override
  String accountOnlineCount(int count) {
    return 'متصل الآن: $count';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => 'ملء حساب محفوظ';

  @override
  String get accountQuickFillDone => 'تم ملء البيانات. اضغط على تسجيل الدخول.';

  @override
  String get accountQuickFillNotReady =>
      'لم يكتمل تحميل صفحة تسجيل الدخول بعد. انتظر قليلًا ثم حاول مجددًا.';

  @override
  String get accountQuickFillSubtitle =>
      'اختر حسابًا لملء بياناته في صفحة تسجيل الدخول إلى Riot';

  @override
  String get accountQuickFillTitle => 'ملء حساب محفوظ';

  @override
  String get accountRegionAp => 'آسيا والمحيط الهادئ';

  @override
  String get accountRegionBr => 'البرازيل';

  @override
  String get accountRegionEu => 'أوروبا';

  @override
  String get accountRegionKr => 'كوريا';

  @override
  String get accountRegionLatam => 'أمريكا اللاتينية';

  @override
  String get accountRegionNa => 'أمريكا الشمالية';

  @override
  String get accountRemoveAccount => 'إزالة الحساب';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'هل تريد إزالة $account من هذا الجهاز؟ يمكنك اختيار الاحتفاظ بالبيانات المحفوظة.';
  }

  @override
  String get accountRrHistoryCleared => 'تم مسح سجل RR';

  @override
  String get accountShowPassword => 'إظهار كلمة المرور';

  @override
  String get accountSignOutAll => 'تسجيل الخروج من جميع الحسابات';

  @override
  String get accountSignOutAllConfirm =>
      'هل تريد تسجيل الخروج وإزالة جميع الحسابات من هذا الجهاز؟ يمكنك اختيار الاحتفاظ بالبيانات المحفوظة.';

  @override
  String get accountStatusAgentSelect => 'في اختيار العميل';

  @override
  String get accountStatusInMatch => 'في مباراة';

  @override
  String get accountStatusOffline => 'غير متصل';

  @override
  String get accountStatusOnline => 'متصل';

  @override
  String get accountStatusUnknown => 'الحالة غير معروفة';

  @override
  String accountSwitchTo(String account) {
    return 'التبديل إلى $account';
  }

  @override
  String get accountSwitcherSubtitle => 'المس لتبديل الحساب';

  @override
  String get accountSwitcherTitle => 'الحسابات';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'الحسابات ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'لاعب';

  @override
  String get accountUnlockLoginNote =>
      'تحقّق من هويتك لفتح معلومات تسجيل الدخول إلى Riot';

  @override
  String get authAddAsNew => 'إضافة كحساب جديد';

  @override
  String get authDifferentAccountBody =>
      'سجّلت الدخول بحساب مختلف عن الحساب الذي يلزمه تسجيل الدخول مجددًا. هل تريد إضافة هذا الحساب كحساب جديد؟';

  @override
  String get authDifferentAccountTitle => 'حساب مختلف';

  @override
  String get authLoadingAccount => 'جارٍ تحميل الحساب…';

  @override
  String get authLoginCancelledByRiot =>
      'رفضت Riot محاولة تسجيل الدخول هذه. يُرجى المحاولة مجددًا.';

  @override
  String get authLoginFailed => 'تعذّر إكمال تسجيل الدخول';

  @override
  String get authLoginFailedBody =>
      'لم تؤكد Riot تسجيل دخولك بعد. يُرجى المحاولة مجددًا.';

  @override
  String get authLoginTitle => 'تسجيل الدخول إلى Riot';

  @override
  String get authMissingCookies =>
      'تعذّر حفظ تسجيل الدخول على هذا الجهاز، لذا سيلزمك تسجيل الدخول مجددًا عند انتهاء صلاحيته.';

  @override
  String get authOfficialHost => 'الصفحة الرسمية · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'تم فتح الرابط في المتصفح.';

  @override
  String get authPageLoadFailed =>
      'تعذّر تحميل صفحة تسجيل الدخول إلى Riot. يُرجى التحقق من الاتصال والمحاولة مجددًا.';

  @override
  String get authPreparing => 'جارٍ تجهيز صفحة تسجيل الدخول…';

  @override
  String get authReloginDone => 'تم تسجيل الدخول مجددًا';

  @override
  String get authSignInCta => 'تسجيل الدخول بحساب Riot';

  @override
  String get authSocialLoginHint =>
      'إذا لم ينجح تسجيل الدخول عبر Google أو Facebook، فاستخدم اسم مستخدم Riot.';

  @override
  String get authStateMismatch =>
      'محاولة تسجيل الدخول هذه غير صالحة. يُرجى بدء تسجيل الدخول من جديد.';

  @override
  String get notificationSessionExpiredBody =>
      'سجّل الدخول مجددًا لمواصلة تلقي تنبيهات قائمة الأمنيات.';

  @override
  String get notificationBackgroundTimingHint =>
      'قد يؤدي وضع توفير البطارية في جهازك إلى تأخير الإشعارات.';

  @override
  String get notificationChannelAccountDescription =>
      'تذكير عندما يحتاج حساب إلى تسجيل الدخول مجددًا';

  @override
  String get notificationChannelAccountName => 'الحسابات';

  @override
  String get notificationChannelBattlePassDescription =>
      'تذكيرات بتقدّم Battle Pass وموعد انتهائه';

  @override
  String get notificationChannelBattlePassName => 'Battle Pass';

  @override
  String get notificationChannelCommunityDescription =>
      'نشاط المجتمع عند فتح ValHub';

  @override
  String get notificationChannelCommunityName => 'المجتمع';

  @override
  String get notificationChannelLfgDescription =>
      'انضمام لاعبين إلى فريقك عند فتح ValHub';

  @override
  String get notificationChannelLfgName => 'الفريق';

  @override
  String get notificationChannelNightMarketDescription =>
      'تنبيه عند افتتاح السوق الليلي';

  @override
  String get notificationChannelNightMarketName => 'السوق الليلي';

  @override
  String get notificationChannelRankDescription =>
      'تغيّرات الرتبة عند تحديث ملفك الشخصي';

  @override
  String get notificationChannelRankName => 'الرتبة';

  @override
  String get notificationChannelStoreResetDescription =>
      'تذكير عند تجديد المتجر اليومي';

  @override
  String get notificationChannelStoreResetName => 'تجديد المتجر';

  @override
  String get notificationChannelWishlistDescription =>
      'تنبيه عند ظهور مظهر من قائمة الأمنيات في متجرك';

  @override
  String get notificationChannelWishlistName => 'قائمة الأمنيات';

  @override
  String get notificationLfgJoinedTitle => 'انضم لاعب إلى فريقك';

  @override
  String get notificationLocalOnlyHint =>
      'تظهر على هذا الجهاز فقط عندما يحدّث ValHub بياناته';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'بطاقات العروض بانتظار $account: $cards. اقلبها الآن.';
  }

  @override
  String get notificationNightMarketOpenTitle => 'افتُتح السوق الليلي!';

  @override
  String get notificationPassEndingBody =>
      'تبقّى يوم واحد تقريبًا على انتهاء Battle Pass. افتح ValHub لمعرفة آخر تقدّم لك.';

  @override
  String get notificationPassEndingTitle => 'Battle Pass على وشك الانتهاء';

  @override
  String notificationPassProgressBody(int level) {
    return 'وصلت إلى المستوى $level في Battle Pass الحالي.';
  }

  @override
  String get notificationPassProgressTitle => 'تقدّم Battle Pass';

  @override
  String get notificationPrivateAccount => 'حسابك';

  @override
  String notificationRankChangedBody(String rank) {
    return 'الرتبة الحالية: $rank. تم التحديث للتو من Riot.';
  }

  @override
  String get notificationRankChangedTitle => 'تغيّرت الرتبة';

  @override
  String get notificationResetTimingUnknown =>
      'افتح المتجر لتحديث موعد التجديد على جهازك.';

  @override
  String get notificationSessionExpiredTitle => 'يلزم تسجيل الدخول مجددًا';

  @override
  String get notificationStoreResetBody => 'مظاهر جديدة بانتظارك في المتجر.';

  @override
  String get competitiveDivisionIron => 'حديدي';

  @override
  String get competitiveDivisionBronze => 'برونزي';

  @override
  String get competitiveDivisionSilver => 'فضي';

  @override
  String get competitiveDivisionGold => 'ذهبي';

  @override
  String get competitiveDivisionPlatinum => 'بلاتيني';

  @override
  String get competitiveDivisionDiamond => 'ألماسي';

  @override
  String get competitiveDivisionAscendant => 'المرتقي';

  @override
  String get competitiveDivisionImmortal => 'الأبدي';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'راديانت';

  @override
  String get competitiveRankUnknown => 'الرتبة غير معروفة';

  @override
  String get competitiveAttack => 'الهجوم';

  @override
  String get competitiveCannotEstimate => 'يتعذّر التقدير';

  @override
  String get competitiveDefeat => 'خسارة';

  @override
  String get competitiveDefense => 'الدفاع';

  @override
  String get competitiveDraw => 'تعادل';

  @override
  String get competitiveIncognitoPlayer => 'لاعب مخفي';

  @override
  String get competitiveMatchPending => 'لا تزال Riot تعالج هذه المباراة…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مباراة تحديد مستوى متبقية',
      many: '$n مباراة تحديد مستوى متبقية',
      few: '$n مباريات تحديد مستوى متبقية',
      two: '$n مباراتا تحديد مستوى متبقيتان',
      one: '$n مباراة تحديد مستوى متبقية',
      zero: '$n مباراة تحديد مستوى متبقية',
    );
    return '$_temp0';
  }

  @override
  String get competitiveRoundDefuse => 'تم تعطيل Spike';

  @override
  String get competitiveRoundDetonate => 'انفجر Spike';

  @override
  String get competitiveRoundElimination => 'إقصاء الفريق';

  @override
  String get competitiveRoundSurrendered => 'استسلام';

  @override
  String get competitiveRoundTimeExpired => 'انتهى الوقت';

  @override
  String get competitiveUnknownPlayer => 'لاعب';

  @override
  String get competitiveVictory => 'فوز';

  @override
  String economyAvailableNow(String place) {
    return 'متوفر الآن في $place!';
  }

  @override
  String economyPlaceBundle(String name) {
    return 'باقة $name';
  }

  @override
  String get economyPlaceBundleGeneric => 'الباقة';

  @override
  String get economyPlaceDaily => 'المتجر اليومي';

  @override
  String get economyPlaceNightMarket => 'السوق الليلي';

  @override
  String get economyPriceEstimated => 'سعر تقديري حسب الإصدار';

  @override
  String get economyPriceFromOffers => 'السعر من قائمة أسعار Riot';

  @override
  String get economyPriceFromStore => 'السعر الذي ظهر في المتجر';

  @override
  String get economyPriceFromTable => 'السعر المُعلن';

  @override
  String get economyPriceUnknown => 'السعر غير معروف';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'التجهيزة $n';
  }

  @override
  String get loadoutInvalidChange =>
      'لا يمكن تطبيق هذا التغيير على تجهيزاتك الحالية.';

  @override
  String get loadoutNotPersisted =>
      'لم تحفظ Riot التغيير، لذا بقيت تجهيزاتك كما هي. يُرجى المحاولة مجددًا.';

  @override
  String get loadoutSaveFailed => 'تعذّر حفظ التجهيزات';

  @override
  String battlePassActEndsIn(String time) {
    return 'ينتهي المشهد بعد $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'ينتهي المشهد بعد $days يوم',
      many: 'ينتهي المشهد بعد $days يومًا',
      few: 'ينتهي المشهد بعد $days أيام',
      two: 'ينتهي المشهد بعد $days يومين',
      one: 'ينتهي المشهد بعد $days يوم',
      zero: 'ينتهي المشهد بعد $days يوم',
    );
    return '$_temp0';
  }

  @override
  String get battlePassAllMissionsDone => 'اكتملت جميع المهام';

  @override
  String get battlePassAllWeeklyDone => 'اكتملت جميع المهام الأسبوعية';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'جوائز مضاعفة بانتظارك: $n';
  }

  @override
  String battlePassChapter(int n) {
    return 'الفصل $n';
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
  String get battlePassCheckpointHint =>
      'اربح الجولات للتقدّم نحو المراحل (لا تُحتسب مباراة الموت).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'المرحلة $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'كل مرحلة: +XP، +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'المراحل المحققة: $done/$total';
  }

  @override
  String get battlePassCurrentChapter => 'الحالي';

  @override
  String get battlePassDailyAllDone => 'اكتملت جميع مراحل اليوم';

  @override
  String get battlePassDailyCaption => 'الجوائز اليومية';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'الجوائز اليومية · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'انتهت صلاحية مراحل اليوم السابق. ادخل إلى اللعبة أو حدّثها من هنا.';

  @override
  String get battlePassDailyMissions => 'المهام اليومية';

  @override
  String get battlePassDailyNotReady =>
      'مراحل اليوم ليست جاهزة بعد. ادخل إلى اللعبة أو حدّثها من هنا.';

  @override
  String get battlePassDailyPlayToStart =>
      'مراحل اليوم ليست جاهزة بعد. ادخل إلى اللعبة لبدء يوم جديد.';

  @override
  String battlePassDaysLeft(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'تبقّى $days يوم',
      many: 'تبقّى $days يومًا',
      few: 'تبقّت $days أيام',
      two: 'تبقّى $days يومان',
      one: 'تبقّى $days يوم',
      zero: 'تبقّى $days يوم',
    );
    return '$_temp0';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'ينتهي في $wall';
  }

  @override
  String get battlePassEpilogue => 'الخاتمة';

  @override
  String get battlePassEstimateNote =>
      'التقدير نحو 4,000 XP لكل مباراة، دون احتساب المهام.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'ينتهي بعد $time';
  }

  @override
  String get battlePassEventPass => 'رخصة فعالية';

  @override
  String get battlePassFilterAll => 'الكل';

  @override
  String get battlePassFilterLocked => 'مقفل';

  @override
  String get battlePassFilterUnlocked => 'مفتوح';

  @override
  String get battlePassFree => 'مجاني';

  @override
  String get battlePassFreeTrack => 'الجوائز المجانية';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'المستوى $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'المستوى $n';
  }

  @override
  String battlePassMatchesEstimate(int n, String queue) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString مباراة',
      many: '$nString مباراةً',
      few: '$nString مباريات',
      two: '$nString مباراة',
      one: '$nString مباراة',
      zero: '$nString مباراة',
    );
    return '≈ $_temp0 في $queue';
  }

  @override
  String get battlePassMissionDone => 'مكتملة';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return 'المكتمل: $done/$total';
  }

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'مهام جديدة في $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'مهام جديدة بعد $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'المرحلة التالية: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'إلى المستوى $level';
  }

  @override
  String get battlePassNextReward => 'التالي';

  @override
  String get battlePassNoBattlePass =>
      'لا تتوفر معلومات Battle Pass للمشهد الحالي بعد. يُرجى المحاولة لاحقًا.';

  @override
  String get battlePassNoRewards => 'لا توجد جوائز لهذا Battle Pass بعد.';

  @override
  String get battlePassNoRewardsInFilter => 'لا توجد جوائز في هذا القسم.';

  @override
  String get battlePassNoRewardsTitle => 'لا توجد جوائز بعد';

  @override
  String get battlePassNoWeeklyMissions => 'لا توجد مهام أسبوعية حاليًا.';

  @override
  String get battlePassPassComplete => 'اكتمل Battle Pass';

  @override
  String get battlePassPremium => 'Premium';

  @override
  String get battlePassPremiumHint =>
      'لم تشترِ Premium: تحصل على الجوائز المجانية فقط. اشترِ Premium داخل اللعبة لفتح المستويات التي وصلت إليها.';

  @override
  String get battlePassRenewButton => 'تحديث المراحل';

  @override
  String get battlePassRenewDone => 'تم تحديث المراحل اليومية.';

  @override
  String get battlePassRenewFailed =>
      'تعذّر تحديث المراحل. يُرجى المحاولة لاحقًا.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'التجديد في $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'التجديد بعد $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'المستوى';

  @override
  String get battlePassRewardLocked => 'مقفل';

  @override
  String get battlePassRewardNeedsPremium => 'يتطلب Premium';

  @override
  String get battlePassRewardStatusLabel => 'الحالة';

  @override
  String get battlePassRewardTrackLabel => 'نوع الجائزة';

  @override
  String get battlePassRewardTypeLabel => 'النوع';

  @override
  String get battlePassRewardUnlocked => 'مفتوح';

  @override
  String get battlePassRewardsTitle => 'الجوائز';

  @override
  String get battlePassShowAllRewards => 'عرض الكل';

  @override
  String get battlePassTitle => 'Battle Pass';

  @override
  String get battlePassTotalXpCaption => 'إجمالي XP';

  @override
  String get battlePassUnknownMission => 'مهمة جديدة (لا يوجد وصف بعد)';

  @override
  String get battlePassUnknownReward => 'جائزة';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return 'المفتوح: $unlocked/$total';
  }

  @override
  String get battlePassUnratedFallback => 'غير مصنف';

  @override
  String get battlePassViewAllRewards => 'عرض جميع الجوائز';

  @override
  String get battlePassWeeklyMissions => 'المهام الأسبوعية';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'المهام الأسبوعية: متبقٍّ +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / يوم';
  }

  @override
  String get battlePassXpPerDayCaption =>
      'المطلوب يوميًا لإكماله في الوقت المحدد';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'متبقٍّ $xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'تعذّر حفظ التجهيزات. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'كل المظاهر التي تملكها، مُقيّمة بأسعار المتجر',
      'buddy': 'تعليقات السلاح التي تملكها وعدد نسخها',
      'spray': 'الرذاذات التي يمكنك إضافتها إلى عجلة التعبيرات',
      'card': 'بطاقات اللاعب المفتوحة، المس للعرض والتجهيز',
      'title': 'ألقاب اللاعب التي يمكنك إظهارها تحت اسمك',
      'flex': 'عناصر Flex التي تملكها',
      'other': 'تصفّح المجموعة',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'الخانة: $position';
  }

  @override
  String get collectionApplyPreset => 'تطبيق';

  @override
  String get collectionApplyPresetBody =>
      'سيتم استبدال المظاهر وتعليقات السلاح وعجلة التعبيرات والبطاقة واللقب الحالية بهذه التجهيزات.';

  @override
  String collectionApplyPresetTitle(String name) {
    return 'هل تريد تطبيق “$name”؟';
  }

  @override
  String get collectionBrowseBuddies => 'تعليقات السلاح';

  @override
  String get collectionBrowseCards => 'بطاقات اللاعب';

  @override
  String get collectionBrowseEmpty => 'لا تملك أي عناصر في هذا القسم بعد.';

  @override
  String get collectionBrowseEmptyTitle => 'لا توجد عناصر بعد';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'المظاهر';

  @override
  String get collectionBrowseSprays => 'الرذاذات';

  @override
  String get collectionBrowseTitles => 'ألقاب اللاعب';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'المتاح: $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'لـ $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'اختيار تعليقة سلاح';

  @override
  String get collectionBuddyRemoved => 'تمت إزالة تعليقة السلاح';

  @override
  String get collectionBuddySlot => 'تعليقة سلاح';

  @override
  String get collectionBuddyUnavailable =>
      'تعذّر تركيب تعليقة السلاح هذه. حدّث الصفحة أو اختر تعليقة أخرى.';

  @override
  String get collectionCachedLoadout =>
      'يتم عرض تجهيزاتك المحفوظة. اسحب للتحديث قبل إجراء أي تغيير.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString بطاقة مملوكة',
      many: '$nString بطاقةً مملوكة',
      few: '$nString بطاقات مملوكة',
      two: '$nString بطاقة مملوكة',
      one: '$nString بطاقة مملوكة',
      zero: '$nString بطاقة مملوكة',
    );
    return '$_temp0';
  }

  @override
  String get collectionChangeBuddy => 'تغيير';

  @override
  String collectionChromaCount(int owned, int total) {
    return 'التنويعات: $owned/$total';
  }

  @override
  String get collectionClearTiers => 'مسح تصفية الإصدار';

  @override
  String get collectionCollectionValue => 'قيمة المجموعة';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'قياسي';

  @override
  String get collectionDeletePreset => 'حذف';

  @override
  String get collectionEmptySlot => 'فارغ';

  @override
  String get collectionEquip => 'تجهيز';

  @override
  String get collectionEquipped => 'مُجهَّز';

  @override
  String get collectionEquippedCard => 'البطاقة المُجهَّزة';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'البطاقة المُجهَّزة: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return 'تم تجهيز $name';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'المُجهَّز: $skin';
  }

  @override
  String get collectionExcludedRewards => 'لا تشمل مظاهر الجوائز';

  @override
  String get collectionExpressionsHint => 'المس خانة لاختيار رذاذ أو Flex.';

  @override
  String get collectionExpressionsSlots => 'خانات العجلة';

  @override
  String get collectionExpressionsTitle => 'عجلة التعبيرات';

  @override
  String get collectionHideAccountLevel => 'إخفاء مستوى الحساب';

  @override
  String get collectionHideAccountLevelHint =>
      'لن يرى اللاعبون الآخرون مستوى حسابك.';

  @override
  String get collectionIncognito => 'وضع التخفي';

  @override
  String get collectionIncognitoHint =>
      'إخفاء اسمك عن اللاعبين من خارج فريقك في المباريات.';

  @override
  String get collectionLevelBorderAuto => 'تلقائي حسب المستوى';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'من المستوى $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'مستوى الحساب $level';
  }

  @override
  String get collectionLevelBorderTitle => 'اختيار إطار المستوى';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'المستوى $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'المستوى $n · $type';
  }

  @override
  String get collectionLevels => 'المستويات';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return 'المستويات المفتوحة: $owned/$total';
  }

  @override
  String get collectionLobbyBanner => 'لافتة الردهة';

  @override
  String get collectionLocked => 'مقفل';

  @override
  String get collectionMeleeNoBuddy =>
      'لا يمكن تركيب تعليقة سلاح على السلاح الأبيض.';

  @override
  String get collectionMove => 'نقل';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy مُركَّبة على $from. هل تريد نقلها إلى $to؟';
  }

  @override
  String get collectionMoveBuddyTitle => 'نقل تعليقة السلاح؟';

  @override
  String get collectionNoBuddies => 'لا تملك أي تعليقة سلاح بعد.';

  @override
  String get collectionNoBuddy => 'بلا تعليقة سلاح';

  @override
  String get collectionNoFlex => 'لا تملك أي عناصر Flex بعد.';

  @override
  String get collectionNoResults => 'لا توجد نتائج مطابقة.';

  @override
  String get collectionNoResultsTitle => 'لم يتم العثور على شيء';

  @override
  String get collectionNoSkinsForWeapon => 'لا تملك أي مظهر لهذا السلاح بعد.';

  @override
  String get collectionNoSprays => 'لا تملك أي رذاذ بعد.';

  @override
  String get collectionNoTitle => 'بلا لقب';

  @override
  String get collectionOtherWeapons => 'أخرى';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مظهر مملوك',
      many: '$n مظهرًا مملوكًا',
      few: '$n مظاهر مملوكة',
      two: '$n مظهران مملوكان',
      one: '$n مظهر مملوك',
      zero: 'لا توجد مظاهر بعد',
    );
    return '$_temp0';
  }

  @override
  String collectionOwnedSkinsStat(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString مظهر مملوك',
      many: '$nString مظهرًا مملوكًا',
      few: '$nString مظاهر مملوكة',
      two: '$nString مظهر مملوك',
      one: '$nString مظهر مملوك',
      zero: '$nString مظهر مملوك',
    );
    return '$_temp0';
  }

  @override
  String get collectionPlayLevelVideo => 'مشاهدة فيديو هذا المستوى';

  @override
  String get collectionPlayVideo => 'مشاهدة الفيديو';

  @override
  String get collectionPlayerCardSubtitle =>
      'تظهر في الردهة وعلى لوحة النتائج وعند إقصائك لخصم.';

  @override
  String get collectionPlayerCardTitle => 'تغيير بطاقة اللاعب';

  @override
  String get collectionPlayerTitleSubtitle =>
      'يظهر تحت اسمك في الردهة وخلال المباريات.';

  @override
  String get collectionPlayerTitleTitle => 'تغيير لقب اللاعب';

  @override
  String get collectionPresetActions => 'خيارات';

  @override
  String collectionPresetApplied(String name) {
    return 'تم تطبيق “$name”';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n تجهيزة',
      many: '$n تجهيزة',
      few: '$n تجهيزات',
      two: '$n تجهيزتان',
      one: '$n تجهيزة',
      zero: 'لا يوجد بعد',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return 'تم حذف “$name”';
  }

  @override
  String get collectionPresetNameHint => 'مثال: رفع الرتبة';

  @override
  String get collectionPresetNameTitle => 'اسم التجهيزة';

  @override
  String collectionPresetSaved(String name) {
    return 'تم حفظ “$name”';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'حُفظت في $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'تم تخطي $n عنصر لم تعد تملكها.',
      many: 'تم تخطي $n عنصرًا لم تعد تملكها.',
      few: 'تم تخطي $n عناصر لم تعد تملكها.',
      two: 'تم تخطي $n عنصرين لم تعد تملكهما.',
      one: 'تم تخطي $n عنصر لم تعد تملكه.',
      zero: 'تم تخطي $n عنصر لم تعد تملكه.',
    );
    return '$_temp0';
  }

  @override
  String get collectionPresetsEmpty =>
      'احفظ تجهيزاتك الحالية للتبديل بسرعة لاحقًا بين مجموعات المظاهر والبطاقات وعجلات التعبيرات.';

  @override
  String get collectionPresetsEmptyTitle => 'لا توجد تجهيزات محفوظة بعد';

  @override
  String get collectionPresetsFull =>
      'وصلت إلى الحد الأقصى وهو 50 تجهيزة. احذف بعضها لحفظ المزيد.';

  @override
  String get collectionPresetsNote =>
      'تُحفظ التجهيزات على هذا الجهاز فقط، للحساب المحدد.';

  @override
  String get collectionPresetsTitle => 'التجهيزات المحفوظة';

  @override
  String get collectionPreview => 'معاينة';

  @override
  String get collectionRemoveBuddy => 'إزالة تعليقة السلاح';

  @override
  String get collectionRenamePreset => 'إعادة تسمية';

  @override
  String get collectionRowExpressions => 'عجلة التعبيرات';

  @override
  String get collectionRowLevelBorder => 'إطار المستوى';

  @override
  String get collectionRowPresets => 'التجهيزات المحفوظة';

  @override
  String get collectionRowWeapons => 'تجهيزات الأسلحة';

  @override
  String get collectionRowWishlist => 'قائمة الأمنيات';

  @override
  String get collectionSaveFailed => 'تعذّر حفظ التجهيزات';

  @override
  String get collectionSavePreset => 'حفظ التجهيزات الحالية';

  @override
  String get collectionSaving => 'جارٍ الحفظ…';

  @override
  String get collectionSearchBuddies => 'ابحث عن تعليقات السلاح…';

  @override
  String get collectionSearchCards => 'ابحث عن بطاقات اللاعب…';

  @override
  String get collectionSearchFlex => 'ابحث عن Flex…';

  @override
  String get collectionSearchItems => 'بحث…';

  @override
  String get collectionSearchSkins => 'ابحث عن المظاهر…';

  @override
  String get collectionSearchSprays => 'ابحث عن الرذاذات…';

  @override
  String get collectionSearchTitles => 'ابحث عن الألقاب…';

  @override
  String get collectionSearchWeapons =>
      'ابحث عن الأسلحة أو المظاهر أو تعليقات السلاح…';

  @override
  String get collectionSectionBrowse => 'تصفّح المجموعة';

  @override
  String get collectionSectionIdentity => 'مرئي للاعبين الآخرين';

  @override
  String get collectionSectionLoadout => 'التجهيزات';

  @override
  String get collectionSkinCustomizeTitle => 'تخصيص المظهر';

  @override
  String get collectionSkinNotFound => 'تعذّر العثور على هذا المظهر.';

  @override
  String get collectionSkinNotOwned => 'لا تملك هذا المظهر بعد.';

  @override
  String get collectionSlotNamesItem0 => 'أعلى';

  @override
  String get collectionSlotNamesItem1 => 'يمين';

  @override
  String get collectionSlotNamesItem2 => 'أسفل';

  @override
  String get collectionSlotNamesItem3 => 'يسار';

  @override
  String get collectionSortName => 'الاسم';

  @override
  String get collectionSortPrice => 'السعر';

  @override
  String get collectionSortRarity => 'الندرة';

  @override
  String get collectionSortWeapon => 'السلاح';

  @override
  String collectionSummaryFiltered(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مظهر',
      many: '$count مظهرًا',
      few: '$count مظاهر',
      two: '$count مظهران',
      one: '$count مظهر',
      zero: '$count مظهر',
    );
    return 'التصفية: $_temp0 · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'التصفية: $count/$total من العناصر';
  }

  @override
  String collectionSummaryItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر',
      many: '$count عنصرًا',
      few: '$count عناصر',
      two: '$count عنصران',
      one: '$count عنصر',
      zero: '$count عنصر',
    );
    return '$_temp0';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مظهر',
      many: '$count مظهرًا',
      few: '$count مظاهر',
      two: '$count مظهران',
      one: '$count مظهر',
      zero: '$count مظهر',
    );
    return '$_temp0 · $value';
  }

  @override
  String get collectionTabFlex => 'Flex';

  @override
  String get collectionTabSprays => 'الرذاذات';

  @override
  String get collectionTapToChangeCard => 'المس لتغيير البطاقة';

  @override
  String get collectionTitle => 'المجموعة';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString لقب مملوك',
      many: '$nString لقبًا مملوكًا',
      few: '$nString ألقاب مملوكة',
      two: '$nString لقب مملوك',
      one: '$nString لقب مملوك',
      zero: '$nString لقب مملوك',
    );
    return '$_temp0';
  }

  @override
  String get collectionUndo => 'تراجع';

  @override
  String get collectionUnknownCard => 'بطاقة غير معروفة';

  @override
  String get collectionValueAtStorePrices => 'بناءً على أسعار المتجر';

  @override
  String get collectionValueHasEstimates => 'تشمل أسعارًا تقديرية (≈)';

  @override
  String collectionValueRewardCount(int n) {
    return 'مظاهر جوائز غير محتسبة: $n';
  }

  @override
  String get collectionValueSeeSkins => 'عرض المظاهر';

  @override
  String collectionValueSkinCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'بناءً على $n مظهر',
      many: 'بناءً على $n مظهرًا',
      few: 'بناءً على $n مظاهر',
      two: 'بناءً على $n مظهرين',
      one: 'بناءً على $n مظهر',
      zero: 'بناءً على $n مظهر',
    );
    return '$_temp0';
  }

  @override
  String get collectionVariants => 'التنويعات';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return 'أسلحة بمظاهر: $custom/$total';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'تجهيزات الأسلحة';

  @override
  String get collectionWeaponNotFound => 'تعذّر العثور على هذا السلاح.';

  @override
  String get collectionWeaponSkinsTitle => 'اختيار مظهر';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مظهر',
      many: '$n مظهرًا',
      few: '$n مظاهر',
      two: '$n مظهران',
      one: '$n مظهر',
      zero: 'فارغة',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'تعذّر النشر بسبب ألفاظ غير لائقة. يُرجى تعديل المنشور والمحاولة مجددًا.';

  @override
  String get communityModerationContentScam =>
      'لا يسمح المجتمع بإعلانات بيع الحسابات أو خدمات رفع الرتبة أو أرقام الهواتف. يُرجى إزالة هذا المحتوى والمحاولة مجددًا.';

  @override
  String get communityModerationContentTooComplex =>
      'يحتوي المنشور على عدد كبير من الرموز المتفرقة. يُرجى تبسيطه والمحاولة مجددًا.';

  @override
  String get communityModerationAccountBanned =>
      'تم حظر هذا الحساب من المجتمع. إذا كنت تعتقد أن هذا خطأ، فتواصل مع ValHub من قسم حول التطبيق والمعلومات القانونية.';

  @override
  String get communityModerationAccountRestricted =>
      'هذا الحساب ممنوع مؤقتًا من النشر والتعليق والبحث عن زملاء الفريق والتصويت. يُرجى المحاولة لاحقًا أو التواصل مع ValHub من قسم حول التطبيق والمعلومات القانونية.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'تنافسي',
      'unrated': 'غير مصنف',
      'swiftplay': 'سويفت بلاي',
      'spikerush': 'سبايك راش',
      'deathmatch': 'مباراة الموت',
      'teamdeathmatch': 'مباراة الموت للفرق',
      'premier': 'بريمير',
      'custom': 'لعبة مخصصة',
      'other': 'أخرى',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'آسيا والمحيط الهادئ',
      'na': 'أمريكا الشمالية',
      'eu': 'أوروبا',
      'kr': 'كوريا',
      'latam': 'أمريكا اللاتينية',
      'br': 'البرازيل',
      'other': 'منطقة غير معروفة',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle => 'لا توجد مظاهر في هذا الترتيب بعد';

  @override
  String get communityRankingEmptyVotes =>
      'لا توجد تفضيلات تطابق النطاق وعوامل التصفية المحددة بعد.';

  @override
  String get communityRankingEmptyRatings =>
      'لا توجد تقييمات بالنجوم تطابق النطاق وعوامل التصفية المحددة بعد.';

  @override
  String get communityRankingEmptyReviews =>
      'لا توجد مراجعات تطابق النطاق وعوامل التصفية المحددة بعد.';

  @override
  String get communityRankingExplore => 'ابحث عن مظاهر لعرضها وتقييمها';

  @override
  String get communityRankingExploreHint =>
      'ابحث باسم المظهر أو السلاح. لا تظهر في الترتيب إلا تقييمات المجتمع الحقيقية.';

  @override
  String get communityRankingClear => 'مسح تصفية السلاح والوقت';

  @override
  String get communityRankingSort => 'الترتيب حسب';

  @override
  String get communityRankingWeapon => 'السلاح';

  @override
  String get communityRankingNoSearch =>
      'لا توجد مظاهر مطابقة. جرّب اسمًا آخر أو امسح تصفية السلاح.';

  @override
  String get communityRankingCatalogUnavailable =>
      'تعذّر تحميل قائمة المظاهر. أغلق هذه اللوحة وحاول مجددًا بعد مزامنة البيانات.';

  @override
  String get communityConsentExitAccount => 'رفض · تسجيل الخروج من هذا الحساب';

  @override
  String get communityRankingGlobalAllTime => 'عالمي · كل الأوقات';

  @override
  String get communityRankingCatalogTitle => 'جميع المظاهر';

  @override
  String get communityReviewOwnershipRequired =>
      'يجب أن يملك حسابك هذا المظهر لتقييمه. لا يزال بإمكانك قراءة تقييمات المجتمع وتعليقاته.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'تعذّر التحقق من امتلاكك لهذا المظهر. أعد تحميل المجموعة أو حاول مجددًا عند الاتصال بالإنترنت.';

  @override
  String get communityReviewLegacyOwnership =>
      'مراجعة قديمة · لم يتم التحقق من الامتلاك';

  @override
  String get communityReviewVerifiedOwner =>
      'تم التحقق من الامتلاك وقت المراجعة';

  @override
  String get communitySkinDiscussionHint =>
      'يمكن للجميع التعليق. لا يمنح النجوم ويكتب المراجعات إلا مالكو المظهر.';

  @override
  String get communityAddPhotos => 'إضافة صور';

  @override
  String get communityAllModes => 'الكل';

  @override
  String get communityAllWeapons => 'جميع الأسلحة';

  @override
  String get communityAnonymousBanner => 'تتصفح دون الكشف عن هويتك';

  @override
  String get communityAnyLanguage => 'أي لغة';

  @override
  String get communityAnyRank => 'أي رتبة';

  @override
  String get communityAnyRole => 'أي دور';

  @override
  String get communityApply => 'تطبيق';

  @override
  String get communityBackToMyCountry => 'العودة إلى بلدي';

  @override
  String get communityBlockAuthor => 'حظر على هذا الجهاز';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'مسح';

  @override
  String get communityCodeAuto =>
      'اتركه فارغًا: سينشئ ValHub رمزًا من فريقك داخل اللعبة عند النشر.';

  @override
  String get communityCodeAutoFailed =>
      'تعذّر إنشاء رمز الفريق. افتح VALORANT أو أدخل الرمز يدويًا.';

  @override
  String get communityCodeInvalid =>
      'يجب أن يتكون الرمز من 6 أحرف كبيرة أو أرقام بالضبط.';

  @override
  String get communityCodeRequired => 'أدخل رمز الفريق أو أنشئه.';

  @override
  String get communityCommentHint => 'اكتب تعليقًا…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString تعليق',
      many: '$nString تعليقًا',
      few: '$nString تعليقات',
      two: '$nString تعليق',
      one: '$nString تعليق',
      zero: '$nString تعليق',
    );
    return '$_temp0';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'التعليقات · $n';
  }

  @override
  String get communityCommentsTitle => 'التعليقات';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return 'المنشورات: $posts · اللاعبون: $authors';
  }

  @override
  String communityCommunityLfg(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString منشور للبحث عن زملاء',
      many: '$nString منشورًا للبحث عن زملاء',
      few: '$nString منشورات للبحث عن زملاء',
      two: '$nString منشور للبحث عن زملاء',
      one: '$nString منشور للبحث عن زملاء',
      zero: '$nString منشور للبحث عن زملاء',
    );
    return '$_temp0';
  }

  @override
  String get communityCommunityVotes => 'مفضلات المجتمع';

  @override
  String get communityComposerHint => 'ما رأيك في VALORANT اليوم؟';

  @override
  String get communityComposerTitle => 'منشور جديد';

  @override
  String communityConsentAccount(String riotId) {
    return 'الحساب: $riotId';
  }

  @override
  String get communityConsentAgree => 'موافقة ومتابعة';

  @override
  String get communityConsentGateAction => 'انضمام';

  @override
  String get communityConsentGuidelines => 'إرشادات المجتمع';

  @override
  String get communityConsentLater => 'لاحقًا';

  @override
  String get communityConsentLocal =>
      'تبقى كلمة المرور وبيانات تسجيل الدخول الأخرى على هذا الجهاز دائمًا. يمكنك سحب موافقتك من الإعدادات.';

  @override
  String get communityConsentPrivacy => 'سياسة الخصوصية';

  @override
  String get communityConsentPublic =>
      'سيرى الآخرون Riot ID وبطاقة اللاعب والرتبة والدولة الخاصة بك.';

  @override
  String get communityConsentTitle => 'الخصوصية ومجتمع ValHub';

  @override
  String get communityConsentVerify =>
      'يرسل ValHub صلاحية الوصول إلى Riot إلى خادم المجتمع للتحقق من Riot ID عند الاتصال، وللتحقق من امتلاك المظهر عند حفظ مراجعة. لا يقرأ الخادم إلا ما يحتاج إليه، ويتخلص من صلاحية الوصول فورًا بعد ذلك، ولا يحفظها أبدًا.';

  @override
  String get communityConsentWithdrawn =>
      'تم سحب الموافقة. يلزم الموافقة مجددًا لمواصلة استخدام التطبيق.';

  @override
  String get communityCountriesTitle => 'المجتمعات حسب الدولة';

  @override
  String get communityCountryNamesAE => 'الإمارات العربية المتحدة';

  @override
  String get communityCountryNamesAL => 'ألبانيا';

  @override
  String get communityCountryNamesAM => 'أرمينيا';

  @override
  String get communityCountryNamesAR => 'الأرجنتين';

  @override
  String get communityCountryNamesAT => 'النمسا';

  @override
  String get communityCountryNamesAU => 'أستراليا';

  @override
  String get communityCountryNamesAZ => 'أذربيجان';

  @override
  String get communityCountryNamesBA => 'البوسنة والهرسك';

  @override
  String get communityCountryNamesBD => 'بنغلاديش';

  @override
  String get communityCountryNamesBE => 'بلجيكا';

  @override
  String get communityCountryNamesBG => 'بلغاريا';

  @override
  String get communityCountryNamesBH => 'البحرين';

  @override
  String get communityCountryNamesBN => 'بروناي';

  @override
  String get communityCountryNamesBO => 'بوليفيا';

  @override
  String get communityCountryNamesBR => 'البرازيل';

  @override
  String get communityCountryNamesBY => 'بيلاروسيا';

  @override
  String get communityCountryNamesCA => 'كندا';

  @override
  String get communityCountryNamesCH => 'سويسرا';

  @override
  String get communityCountryNamesCL => 'تشيلي';

  @override
  String get communityCountryNamesCN => 'الصين';

  @override
  String get communityCountryNamesCO => 'كولومبيا';

  @override
  String get communityCountryNamesCR => 'كوستاريكا';

  @override
  String get communityCountryNamesCU => 'كوبا';

  @override
  String get communityCountryNamesCY => 'قبرص';

  @override
  String get communityCountryNamesCZ => 'التشيك';

  @override
  String get communityCountryNamesDE => 'ألمانيا';

  @override
  String get communityCountryNamesDK => 'الدنمارك';

  @override
  String get communityCountryNamesDO => 'جمهورية الدومينيكان';

  @override
  String get communityCountryNamesDZ => 'الجزائر';

  @override
  String get communityCountryNamesEC => 'الإكوادور';

  @override
  String get communityCountryNamesEE => 'إستونيا';

  @override
  String get communityCountryNamesEG => 'مصر';

  @override
  String get communityCountryNamesES => 'إسبانيا';

  @override
  String get communityCountryNamesET => 'إثيوبيا';

  @override
  String get communityCountryNamesFI => 'فنلندا';

  @override
  String get communityCountryNamesFR => 'فرنسا';

  @override
  String get communityCountryNamesGB => 'المملكة المتحدة';

  @override
  String get communityCountryNamesGE => 'جورجيا';

  @override
  String get communityCountryNamesGH => 'غانا';

  @override
  String get communityCountryNamesGR => 'اليونان';

  @override
  String get communityCountryNamesGT => 'غواتيمالا';

  @override
  String get communityCountryNamesHK => 'هونغ كونغ';

  @override
  String get communityCountryNamesHN => 'هندوراس';

  @override
  String get communityCountryNamesHR => 'كرواتيا';

  @override
  String get communityCountryNamesHU => 'المجر';

  @override
  String get communityCountryNamesID => 'إندونيسيا';

  @override
  String get communityCountryNamesIE => 'أيرلندا';

  @override
  String get communityCountryNamesIL => 'إسرائيل';

  @override
  String get communityCountryNamesIN => 'الهند';

  @override
  String get communityCountryNamesIQ => 'العراق';

  @override
  String get communityCountryNamesIR => 'إيران';

  @override
  String get communityCountryNamesIS => 'آيسلندا';

  @override
  String get communityCountryNamesIT => 'إيطاليا';

  @override
  String get communityCountryNamesJO => 'الأردن';

  @override
  String get communityCountryNamesJP => 'اليابان';

  @override
  String get communityCountryNamesKE => 'كينيا';

  @override
  String get communityCountryNamesKH => 'كمبوديا';

  @override
  String get communityCountryNamesKR => 'كوريا الجنوبية';

  @override
  String get communityCountryNamesKW => 'الكويت';

  @override
  String get communityCountryNamesKZ => 'كازاخستان';

  @override
  String get communityCountryNamesLA => 'لاوس';

  @override
  String get communityCountryNamesLB => 'لبنان';

  @override
  String get communityCountryNamesLK => 'سريلانكا';

  @override
  String get communityCountryNamesLT => 'ليتوانيا';

  @override
  String get communityCountryNamesLU => 'لوكسمبورغ';

  @override
  String get communityCountryNamesLV => 'لاتفيا';

  @override
  String get communityCountryNamesLY => 'ليبيا';

  @override
  String get communityCountryNamesMA => 'المغرب';

  @override
  String get communityCountryNamesMD => 'مولدوفا';

  @override
  String get communityCountryNamesME => 'الجبل الأسود';

  @override
  String get communityCountryNamesMK => 'مقدونيا الشمالية';

  @override
  String get communityCountryNamesMM => 'ميانمار';

  @override
  String get communityCountryNamesMN => 'منغوليا';

  @override
  String get communityCountryNamesMO => 'ماكاو';

  @override
  String get communityCountryNamesMT => 'مالطا';

  @override
  String get communityCountryNamesMX => 'المكسيك';

  @override
  String get communityCountryNamesMY => 'ماليزيا';

  @override
  String get communityCountryNamesNG => 'نيجيريا';

  @override
  String get communityCountryNamesNI => 'نيكاراغوا';

  @override
  String get communityCountryNamesNL => 'هولندا';

  @override
  String get communityCountryNamesNO => 'النرويج';

  @override
  String get communityCountryNamesNP => 'نيبال';

  @override
  String get communityCountryNamesNZ => 'نيوزيلندا';

  @override
  String get communityCountryNamesOM => 'عُمان';

  @override
  String get communityCountryNamesPA => 'بنما';

  @override
  String get communityCountryNamesPE => 'بيرو';

  @override
  String get communityCountryNamesPH => 'الفلبين';

  @override
  String get communityCountryNamesPK => 'باكستان';

  @override
  String get communityCountryNamesPL => 'بولندا';

  @override
  String get communityCountryNamesPR => 'بورتوريكو';

  @override
  String get communityCountryNamesPT => 'البرتغال';

  @override
  String get communityCountryNamesPY => 'باراغواي';

  @override
  String get communityCountryNamesQA => 'قطر';

  @override
  String get communityCountryNamesRO => 'رومانيا';

  @override
  String get communityCountryNamesRS => 'صربيا';

  @override
  String get communityCountryNamesRU => 'روسيا';

  @override
  String get communityCountryNamesSA => 'المملكة العربية السعودية';

  @override
  String get communityCountryNamesSE => 'السويد';

  @override
  String get communityCountryNamesSG => 'سنغافورة';

  @override
  String get communityCountryNamesSI => 'سلوفينيا';

  @override
  String get communityCountryNamesSK => 'سلوفاكيا';

  @override
  String get communityCountryNamesSV => 'السلفادور';

  @override
  String get communityCountryNamesTH => 'تايلاند';

  @override
  String get communityCountryNamesTL => 'تيمور الشرقية';

  @override
  String get communityCountryNamesTN => 'تونس';

  @override
  String get communityCountryNamesTR => 'تركيا';

  @override
  String get communityCountryNamesTW => 'تايوان';

  @override
  String get communityCountryNamesUA => 'أوكرانيا';

  @override
  String get communityCountryNamesUS => 'الولايات المتحدة';

  @override
  String get communityCountryNamesUY => 'الأوروغواي';

  @override
  String get communityCountryNamesUZ => 'أوزبكستان';

  @override
  String get communityCountryNamesVE => 'فنزويلا';

  @override
  String get communityCountryNamesVN => 'فيتنام';

  @override
  String get communityCountryNamesZA => 'جنوب أفريقيا';

  @override
  String get communityCreateLfg => 'إنشاء منشور بحث عن زملاء';

  @override
  String get communityCreateLfgShort => 'نشر';

  @override
  String get communityDataDeleted => 'تم حذف بياناتك في المجتمع.';

  @override
  String communityDataFooter(String riotId) {
    return 'ينطبق على الحساب الحالي: $riotId. لا يتضمن الملف الذي يتم تنزيله كلمة المرور أو بيانات تسجيل الدخول إلى Riot.';
  }

  @override
  String get communityDataTitle => 'بياناتك في المجتمع';

  @override
  String get communityDecrease => 'إنقاص';

  @override
  String get communityDelete => 'حذف';

  @override
  String get communityDeleteComment => 'حذف التعليق';

  @override
  String get communityDeleteCommentBody => 'سيتم حذف هذا التعليق نهائيًا.';

  @override
  String get communityDeleteCommentTitle => 'حذف التعليق؟';

  @override
  String get communityDeleteDataConfirm => 'حذف نهائي';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'سيتم حذف جميع المنشورات والتعليقات ومراجعات المظاهر والإعجابات والأصوات ومنشورات البحث عن زملاء والصور الخاصة بـ $riotId في مجتمع ValHub نهائيًا، ولا يمكن استعادتها. ستعود إلى التصفح دون الكشف عن هويتك، وستحتاج إلى الموافقة مجددًا إذا أردت الانضمام مرة أخرى.\n\nلن يتأثر حساب Riot وبيانات اللعبة. نزّل بياناتك أولًا إذا أردت الاحتفاظ بنسخة منها.';
  }

  @override
  String get communityDeleteDataConfirmTitle => 'حذف بيانات المجتمع؟';

  @override
  String get communityDeleteDataSubtitle =>
      'احذف نهائيًا كل ما نشرته في المجتمع.';

  @override
  String get communityDeleteDataTitle => 'حذف بياناتي في المجتمع';

  @override
  String get communityDeletePost => 'حذف المنشور';

  @override
  String get communityDeletePostBody =>
      'سيتم حذف هذا المنشور وجميع تعليقاته نهائيًا.';

  @override
  String get communityDeletePostTitle => 'حذف المنشور؟';

  @override
  String get communityDeleteReview => 'حذف المراجعة';

  @override
  String get communityDeleteReviewBody =>
      'سيتم حذف تقييمك ومراجعتك لهذا المظهر.';

  @override
  String get communityDeleteReviewTitle => 'حذف مراجعتك؟';

  @override
  String get communityDeleted => 'تم الحذف.';

  @override
  String get communityDiscard => 'تجاهل';

  @override
  String get communityDiscardBody => 'لن يتم حفظ ما كتبته للتو.';

  @override
  String get communityDiscardTitle => 'تجاهل المنشور؟';

  @override
  String get communityDownload => 'تنزيل وترجمة';

  @override
  String get communityDownloadingModels => 'جارٍ تنزيل حزمة اللغة…';

  @override
  String get communityEditReview => 'تعديل';

  @override
  String get communityEdited => 'معدَّل';

  @override
  String get communityEmptyPost => 'اكتب شيئًا أو أضف صورة.';

  @override
  String get communityExpired => 'منتهي الصلاحية';

  @override
  String communityExpiresIn(String t) {
    return 'متبقٍّ $t';
  }

  @override
  String get communityExportPreparing => 'جارٍ التجهيز…';

  @override
  String get communityExportSubject => 'بيانات مجتمع ValHub';

  @override
  String get communityExportSubtitle =>
      'نسخة من كل ما نشرته في المجتمع: المنشورات والتعليقات والمراجعات والإعجابات والأصوات ومنشورات البحث عن زملاء.';

  @override
  String get communityExportTitle => 'تنزيل بياناتي';

  @override
  String get communityExtend => 'تمديد';

  @override
  String get communityExtended => 'تم تمديد المنشور 30 دقيقة.';

  @override
  String get communityFeedEmptyBody =>
      'كن أول من يشارك متجره أو السوق الليلي أو أفضل لحظاته!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'لا توجد منشورات مطابقة. جرّب لغة أخرى أو امسح عوامل التصفية.';

  @override
  String get communityFeedEmptyGuestBody =>
      'لا توجد منشورات جديدة بعد. عُد لاحقًا أو انضم للمشاركة.';

  @override
  String get communityFeedEmptyScopeBody =>
      'جرّب منشورات المجتمع الدولي أو غيّر عوامل التصفية.';

  @override
  String get communityFeedEmptyScopeTitle => 'لا توجد منشورات هنا بعد';

  @override
  String get communityFeedEmptyTitle => 'الموجز فارغ';

  @override
  String get communityFilters => 'عوامل التصفية';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'ترجمة Google';

  @override
  String get communityHelpful => 'مفيد';

  @override
  String communityHelpfulCount(String n) {
    return 'مفيد · $n';
  }

  @override
  String get communityHiddenAuthors => 'اللاعبون المخفيون والمحظورون';

  @override
  String get communityHiddenAuthorsEmpty => 'لم تُخفِ أو تحظر أحدًا';

  @override
  String get communityHiddenAuthorsHint =>
      'ينطبق على هذا الحساب على هذا الجهاز فقط. يتم إخفاء محتواهم، ولا يزال بإمكانهم رؤية محتواك العام.';

  @override
  String communityImageOf(int i, int n) {
    return 'الصورة $i/$n';
  }

  @override
  String get communityIncrease => 'زيادة';

  @override
  String get communityJoin => 'انضمام';

  @override
  String get communityJoinCodeExpired =>
      'انتهت صلاحية رمز الفريق أو لم يعد صالحًا.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'ستغادر فريقك الحالي في VALORANT للانضمام إلى فريق $name.';
  }

  @override
  String get communityJoinConfirmTitle => 'الانضمام إلى هذا الفريق؟';

  @override
  String get communityJoinGameNotRunning =>
      'افتح VALORANT على الكمبيوتر أو جهاز الألعاب ثم حاول مجددًا.';

  @override
  String get communityJoinParty => 'الانضمام إلى الفريق';

  @override
  String get communityJoinPartyFull => 'هذا الفريق مكتمل.';

  @override
  String get communityJoinedHint =>
      'انضممت إلى الفريق! افتح VALORANT للعب معًا.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString طلب انضمام',
      many: '$nString طلبَ انضمام',
      few: '$nString طلبات انضمام',
      two: '$nString طلب انضمام',
      one: '$nString طلب انضمام',
      zero: '$nString طلب انضمام',
    );
    return '$_temp0';
  }

  @override
  String get communityKindNightMarket => 'السوق الليلي';

  @override
  String get communityKindStore => 'متجر اليوم';

  @override
  String get communityLanguage => 'اللغة';

  @override
  String get communityLanguageFilter => 'لغة المحتوى';

  @override
  String get communityLanguageFilterHint =>
      'إظهار المحتوى المكتوب باللغات المحددة فقط. اتركه فارغًا لعرض كل شيء.';

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
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n لغة',
      many: '$n لغة',
      few: '$n لغات',
      two: '$n لغتان',
      one: '$n لغة',
      zero: '$n لغة',
    );
    return '$_temp0';
  }

  @override
  String get communityLfgEmptyBody =>
      'أنشئ منشورًا ليتمكن اللاعبون الآخرون من الانضمام إلى فريقك بلمسة واحدة.';

  @override
  String get communityLfgEmptyTitle => 'لا أحد يبحث عن زملاء بعد';

  @override
  String get communityLfgExpiredRepost =>
      'انتهت صلاحية منشورك. أنشئ منشورًا جديدًا للبحث عن زملاء.';

  @override
  String get communityLfgGateBody =>
      'انضم (بالتحقق من Riot ID مرة واحدة) لرؤية منشورات اللاعبين على خادمك ونشر طلب البحث عن زملاء الخاص بك. لا يزال بإمكانك تصفّح الموجز وترتيب المظاهر كالمعتاد.';

  @override
  String get communityLfgGateTitle => 'البحث عن زملاء متاح للأعضاء';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'أنت تتصفح خادم $region — لا يمكن الانضمام إلى الفرق إلا للاعبين على نفس خادم حسابك.';
  }

  @override
  String get communityLfgPosted => 'تم نشر طلب البحث عن زملاء!';

  @override
  String get communityLfgPreviewTitle => 'ابحث عن زملاء في مستوى رتبتك';

  @override
  String get communityLfgRemoved => 'تمت إزالة المنشور.';

  @override
  String get communityLfgSameShardNote =>
      'لا يمكن الانضمام إلى الفريق إلا للاعبين على نفس الخادم.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'المنطقة: $region · تنتهي صلاحية المنشورات تلقائيًا بعد 30 دقيقة.';
  }

  @override
  String get communityLike => 'إعجاب';

  @override
  String get communityLiveMembers => 'الأعضاء';

  @override
  String get communityMatchMyRank => 'يناسب رتبتك';

  @override
  String communityMemberJoined(String name) {
    return 'انضم $name إلى الفريق';
  }

  @override
  String get communityMemberJoinedBody =>
      'انضم شخص للتو عبر منشور البحث عن زملاء الخاص بك.';

  @override
  String get communityMic => 'الميكروفون مطلوب';

  @override
  String get communityMicOn => 'لديه ميكروفون';

  @override
  String get communityMode => 'الوضع';

  @override
  String communityModelSize(int mb) {
    return '$mb ميغابايت';
  }

  @override
  String get communityMoreActions => 'خيارات أخرى';

  @override
  String get communityMuteAuthor => 'إخفاء هذا اللاعب';

  @override
  String get communityNewPost => 'نشر';

  @override
  String communityNightMarketOf(String date) {
    return 'السوق الليلي بتاريخ $date';
  }

  @override
  String get communityNoAccountBody =>
      'أضف حساب Riot للنشر والبحث عن زملاء والتصويت على المظاهر.';

  @override
  String get communityNoAccountTitle => 'سجّل الدخول للانضمام';

  @override
  String get communityNoComments => 'لا توجد تعليقات بعد. كن أول من يعلّق!';

  @override
  String get communityNoRatings => 'لا توجد تقييمات بعد';

  @override
  String get communityNote => 'ملاحظة';

  @override
  String get communityNoteHint =>
      'مثال: نحتاج متحكمًا واحدًا، مع ميكروفون، للمتعة فقط';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name، $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'الإجمالي $amount';
  }

  @override
  String get communityOpenReviews => 'عرض المراجعات';

  @override
  String get communityOutOfRange => 'خارج نطاق الرتبة';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'رمز الفريق';

  @override
  String get communityPartyCodeHint => 'مثال: A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'رمز الفريق: $code';
  }

  @override
  String get communityPartySize => 'الفريق الحالي';

  @override
  String get communityPartySizeFromGame => 'مأخوذ من فريقك داخل اللعبة';

  @override
  String communityPartySizeValue(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n لاعب',
      many: '$n لاعبًا',
      few: '$n لاعبين',
      two: '$n لاعبان',
      one: '$n لاعب',
      zero: '$n لاعب',
    );
    return '$_temp0';
  }

  @override
  String communityPhotoCount(int n, int max) {
    return 'الصور: $n/$max';
  }

  @override
  String get communityPlayVideo => 'مشاهدة الفيديو';

  @override
  String get communityPostLfg => 'نشر';

  @override
  String get communityPostNotFound => 'تم حذف هذا المنشور أو إخفاؤه.';

  @override
  String get communityPostTitle => 'المنشور';

  @override
  String get communityPosted => 'تم النشر!';

  @override
  String get communityPublish => 'نشر';

  @override
  String get communityPublishing => 'جارٍ النشر…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'من';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'نطاق الرتبة';

  @override
  String get communityRankRangeInvalid =>
      'لا يمكن أن تكون أدنى رتبة أعلى من أعلى رتبة.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'المركز $n: $name';
  }

  @override
  String get communityRankTo => 'إلى';

  @override
  String get communityRateLimitedTitle => 'انتظر لحظة';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString تقييم',
      many: '$nString تقييمًا',
      few: '$nString تقييمات',
      two: '$nString تقييم',
      one: '$nString تقييم',
      zero: '$nString تقييم',
    );
    return '$_temp0';
  }

  @override
  String communityRatingSummary(String avg, int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString تقييم',
      many: '$nString تقييمًا',
      few: '$nString تقييمات',
      two: '$nString تقييم',
      one: '$nString تقييم',
      zero: '$nString تقييم',
    );
    return '$avg · $_temp0';
  }

  @override
  String get communityRatingWordsItem0 => 'سيئ';

  @override
  String get communityRatingWordsItem1 => 'عادي';

  @override
  String get communityRatingWordsItem2 => 'مقبول';

  @override
  String get communityRatingWordsItem3 => 'رائع';

  @override
  String get communityRatingWordsItem4 => 'تحفة';

  @override
  String get communityRefreshList => 'تحديث';

  @override
  String get communityRegion => 'المنطقة';

  @override
  String get communityRemoveAttachment => 'إزالة المرفق';

  @override
  String get communityRemoveLfg => 'إزالة المنشور';

  @override
  String get communityRemoveLfgBody =>
      'لن يرى اللاعبون الآخرون هذا المنشور بعد الآن.';

  @override
  String get communityRemoveLfgTitle => 'إزالة منشور البحث عن زملاء؟';

  @override
  String get communityRemovePhoto => 'إزالة الصورة';

  @override
  String get communityReport => 'إبلاغ';

  @override
  String get communityReportConfirmBody =>
      'سيتم إخفاء المحتوى الذي يبلّغ عنه كثير من اللاعبين من المجتمع.';

  @override
  String get communityReportConfirmTitle => 'إرسال البلاغ؟';

  @override
  String get communityReportPrompt => 'لماذا تبلّغ عن هذا المحتوى؟';

  @override
  String get communityReportReasonsSpam => 'رسائل مزعجة أو إعلانات';

  @override
  String get communityReportReasonsHarassment => 'مضايقة أو إهانة';

  @override
  String get communityReportReasonsInappropriate => 'محتوى غير لائق';

  @override
  String get communityReportReasonsScam => 'احتيال أو بيع حسابات';

  @override
  String get communityReportReasonsOther => 'سبب آخر';

  @override
  String get communityReportTitle => 'الإبلاغ عن محتوى';

  @override
  String get communityReported => 'شكرًا لك! تم إرسال البلاغ.';

  @override
  String get communityReviewDeleted => 'تم حذف المراجعة.';

  @override
  String get communityReviewHint => 'شارك رأيك في هذا المظهر (اختياري)';

  @override
  String get communityReviewSaved => 'تم حفظ المراجعة!';

  @override
  String get communityReviewTitle => 'تقييم المظهر';

  @override
  String get communityReviewsEmptyBody =>
      'لا توجد مراجعات بعد — كن أول من يكتب مراجعة!';

  @override
  String get communityReviewsEmptyTitle => 'لا توجد مراجعات بعد';

  @override
  String communityReviewsHeader(String n) {
    return 'المراجعات · $n';
  }

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'تواجه Riot مشكلة';

  @override
  String get communityRoleFlex => 'مرن';

  @override
  String get communityRoles => 'الأدوار المطلوبة';

  @override
  String get communitySaveReview => 'حفظ المراجعة';

  @override
  String get communityScopeCountry => 'بلدك';

  @override
  String get communityScopeGlobal => 'دولي';

  @override
  String get communityScopeRegion => 'المنطقة';

  @override
  String get communitySectionFeed => 'الموجز';

  @override
  String get communitySectionLfg => 'البحث عن زملاء';

  @override
  String get communitySectionSkins => 'ترتيب المظاهر';

  @override
  String get communitySend => 'إرسال';

  @override
  String get communitySendComment => 'إرسال التعليق';

  @override
  String get communityShareNightMarketHint =>
      'اعرض السوق الليلي الخاص بك على الجميع';

  @override
  String communitySharePostTitle(String name) {
    return 'منشور $name على ValHub';
  }

  @override
  String get communityShareStore => 'مشاركة في المجتمع';

  @override
  String get communityShareStoreHint => 'اعرض متجر اليوم على الجميع';

  @override
  String get communityShowOriginal => 'عرض الأصل';

  @override
  String get communityShowTranslation => 'عرض الترجمة';

  @override
  String get communitySignInToReview => 'أضف حساب Riot لتقييم المظاهر.';

  @override
  String get communitySkinNotFound => 'تعذّر العثور على هذا المظهر.';

  @override
  String get communitySlots => 'عدد اللاعبين المطلوب';

  @override
  String communitySlotsTooMany(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'يضم الفريق 5 لاعبين كحد أقصى: لم يتبقَّ سوى $max مكان.',
      many: 'يضم الفريق 5 لاعبين كحد أقصى: لم يتبقَّ سوى $max مكانًا.',
      few: 'يضم الفريق 5 لاعبين كحد أقصى: لم يتبقَّ سوى $max أماكن.',
      two: 'يضم الفريق 5 لاعبين كحد أقصى: لم يتبقَّ سوى $max مكانين.',
      one: 'يضم الفريق 5 لاعبين كحد أقصى: لم يتبقَّ سوى $max مكان.',
      zero: 'يضم الفريق 5 لاعبين كحد أقصى: لم يتبقَّ سوى $max مكان.',
    );
    return '$_temp0';
  }

  @override
  String communitySlotsWanted(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'مطلوب $n لاعب',
      many: 'مطلوب $n لاعبًا',
      few: 'مطلوب $n لاعبين',
      two: 'مطلوب $n لاعبان',
      one: 'مطلوب $n لاعب',
      zero: 'مطلوب $n لاعب',
    );
    return '$_temp0';
  }

  @override
  String get communitySortHelpful => 'الأكثر فائدة';

  @override
  String get communitySortNewest => 'الأحدث';

  @override
  String get communitySortRating => 'الأعلى تقييمًا';

  @override
  String get communitySortReviews => 'الأكثر مراجعة';

  @override
  String get communitySortVotes => 'الأكثر تفضيلًا';

  @override
  String communityStarLabel(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n نجمة',
      many: '$n نجمة',
      few: '$n نجوم',
      two: '$n نجمتان',
      one: '$n نجمة',
      zero: '$n نجمة',
    );
    return '$_temp0';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg من 5 نجوم';
  }

  @override
  String get communityStatusFull => 'مكتمل';

  @override
  String get communityStatusInGame => 'في مباراة';

  @override
  String get communityStatusOpen => 'يبحث';

  @override
  String communityStoreOf(String date) {
    return 'المتجر بتاريخ $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => 'المس النجوم لتقييم هذا المظهر';

  @override
  String get communityTitle => 'المجتمع';

  @override
  String communityTooLong(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'الحد الأقصى $max حرف.',
      many: 'الحد الأقصى $max حرفًا.',
      few: 'الحد الأقصى $max أحرف.',
      two: 'الحد الأقصى $max حرفان.',
      one: 'الحد الأقصى $max حرف.',
      zero: 'الحد الأقصى $max حرف.',
    );
    return '$_temp0';
  }

  @override
  String get communityTranslate => 'الترجمة عبر Google';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'للترجمة من $from إلى $to، يحتاج ValHub إلى تنزيل حزمة لغة من Google (حوالي $size). يتم التنزيل مرة واحدة فقط؛ وتتم الترجمة بالكامل على جهازك دون إرسال المحتوى إلى أي خادم.';
  }

  @override
  String get communityTranslateDownloadTitle =>
      'تنزيل حزمة الترجمة على الجهاز؟';

  @override
  String get communityTranslateFailed =>
      'تعذّرت الترجمة. يُرجى المحاولة مجددًا.';

  @override
  String get communityTranslatedByGoogle => 'ترجمة تلقائية من Google';

  @override
  String get communityTranslating => 'جارٍ الترجمة…';

  @override
  String get communityTrendingTitle => 'المظاهر الأكثر تفضيلًا عالميًا';

  @override
  String get communityUnavailableBody =>
      'تعذّر الاتصال بمجتمع ValHub. يُرجى المحاولة بعد بضع دقائق.';

  @override
  String get communityUnavailableTitle => 'تعذّر الاتصال بالمجتمع';

  @override
  String get communityUnhideAuthor => 'إلغاء الإخفاء / إلغاء الحظر';

  @override
  String get communityUnknownPlayer => 'لاعب';

  @override
  String get communityUnlike => 'إلغاء الإعجاب';

  @override
  String get communityUnvote => 'إزالة القلب';

  @override
  String get communityVote => 'امنح قلبًا لهذا المظهر';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString إعجاب',
      many: '$nString إعجابًا',
      few: '$nString إعجابات',
      two: '$nString إعجاب',
      one: '$nString إعجاب',
      zero: '$nString إعجاب',
    );
    return '$_temp0';
  }

  @override
  String get communityWithdrawConfirm => 'سحب';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'سيتوقف ValHub عن استخدام المجتمع بحساب $riotId: ستتم إزالة اتصال المجتمع على هذا الجهاز وستعود إلى التصفح دون الكشف عن هويتك.\n\nتبقى المنشورات والتعليقات والمراجعات والأصوات ومنشورات البحث عن زملاء التي نشرتها في المجتمع، وتستمر في إظهار Riot ID الخاص بك حتى تحذفها واحدًا تلو الآخر، أو تختار \"حذف بياناتي في المجتمع\". يمكنك الانضمام مجددًا في أي وقت.';
  }

  @override
  String get communityWithdrawConfirmTitle => 'سحب الموافقة؟';

  @override
  String get communityWithdrawSubtitle =>
      'التوقف عن استخدام المجتمع بهذا الحساب. سيتم الاحتفاظ بمنشوراتك.';

  @override
  String get communityWithdrawTitle => 'سحب الموافقة';

  @override
  String get communityWriteFirstReview => 'اكتب أول مراجعة';

  @override
  String get communityYou => 'أنت';

  @override
  String get communityYourCountry => 'بلدك';

  @override
  String get communityYourReview => 'مراجعتك';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'أنت: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentSelect => 'اختيار العميل';

  @override
  String get liveGameAnonymous => 'مجهول';

  @override
  String get liveGameAutoRefreshNote =>
      'يتم التحديث تلقائيًا عندما تكون في مباراة.';

  @override
  String get liveGameCurrentGame => 'المباراة الحالية';

  @override
  String get liveGameEmptyTeam => 'لا يوجد لاعبون بعد.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'سيظهر الفريق الخصم عند بدء المباراة.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'قفل الفريق الخصم $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'لا يوفّر مصدر المباراة المباشرة هذا القتلات/الوفيات/المساعدات. تظهر لوحة النتائج عندما تنشر Riot بيانات ما بعد المباراة.';

  @override
  String get liveGameFinalScoreboard => 'لوحة النتائج النهائية';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameInLobby => 'في الردهة';

  @override
  String get liveGameInMatch => 'في مباراة';

  @override
  String get liveGameInQueue => 'في قائمة الانتظار';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'في قائمة الانتظار · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'المستوى $n';
  }

  @override
  String get liveGameLiveScore => 'النتيجة المباشرة';

  @override
  String get liveGameLoadoutFromAgentSelect => 'التجهيزات من اختيار العميل';

  @override
  String get liveGameLoadoutFromMatch => 'التجهيزات في هذه المباراة';

  @override
  String get liveGameLobbyHint =>
      'عند العثور على مباراة، يعرض ValHub تشكيلة كل فريق ورتب اللاعبين.';

  @override
  String get liveGameLockedTag => 'مقفل';

  @override
  String get liveGameMatchPendingHint =>
      'سيعيد ValHub المحاولة تلقائيًا. تكون لوحة النتائج جاهزة عادةً خلال دقيقة تقريبًا.';

  @override
  String get liveGameNoAgentYet => 'لم يتم اختيار عميل';

  @override
  String get liveGameNoLoadout => 'لا تتوفر معلومات تجهيزات لهذا اللاعب.';

  @override
  String get liveGameNotInGame => 'لست في مباراة';

  @override
  String get liveGameNotInGameHint =>
      'افتح VALORANT وابدأ البحث عن مباراة — ستظهر تفاصيل المباراة هنا تلقائيًا عند الوصول إلى اختيار العميل.';

  @override
  String get liveGameNotInGameTitle => 'لست في أي مباراة';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'عرض تجهيزات $name';
  }

  @override
  String get liveGameOpenParty => 'فتح الفريق وقائمة الانتظار';

  @override
  String get liveGameParty => 'الفريق';

  @override
  String liveGamePeak(String rank) {
    return 'الأعلى: $rank';
  }

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'تجهيزات $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'التجهيزات';

  @override
  String get liveGameQueueHint =>
      'أبقِ التطبيق مفتوحًا — ستظهر تفاصيل المباراة فور العثور عليها.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'قد تتعرض لعقوبة عند مغادرة المباراة (خسارة RR، تقييد قائمة الانتظار). هل تريد المغادرة رغم ذلك؟';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'قد تتعرض لعقوبة عند المغادرة أثناء اختيار العميل (خسارة RR، تقييد قائمة الانتظار). هل تريد المغادرة رغم ذلك؟';

  @override
  String get liveGameQuitConfirmTitle => 'مغادرة المباراة؟';

  @override
  String get liveGameQuitDone => 'غادرت المباراة.';

  @override
  String get liveGameQuitFailed => 'تعذّرت مغادرة المباراة.';

  @override
  String get liveGameQuitMatch => 'مغادرة المباراة';

  @override
  String get liveGameQuitMatchChanged =>
      'انتقلت المباراة إلى مرحلة جديدة أثناء التأكيد. لم تغادر المباراة؛ يُرجى المحاولة مجددًا.';

  @override
  String get liveGameRankUnavailable => 'الرتبة غير معروفة';

  @override
  String get liveGameRefresh => 'تحديث';

  @override
  String liveGameRefreshIn(int seconds) {
    String _temp0 = intl.Intl.pluralLogic(
      seconds,
      locale: localeName,
      other: 'تحديث تلقائي بعد $seconds ثانية',
      many: 'تحديث تلقائي بعد $seconds ثانية',
      few: 'تحديث تلقائي بعد $seconds ثوانٍ',
      two: 'تحديث تلقائي بعد $seconds ثانيتين',
      one: 'تحديث تلقائي بعد $seconds ثانية',
      zero: 'تحديث تلقائي بعد $seconds ثانية',
    );
    return '$_temp0';
  }

  @override
  String get liveGameRefreshNow => 'تحديث الآن';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSheetTitle => 'تفاصيل المباراة';

  @override
  String get liveGameSprays => 'الرذاذات';

  @override
  String get liveGameStatusAgentSelect => 'اختيار العميل';

  @override
  String get liveGameStatusEnded => 'انتهت';

  @override
  String get liveGameStatusInProgress => 'جارية';

  @override
  String get liveGameStatusUnavailable => 'تعذّر تحديث حالة المباراة';

  @override
  String get liveGameTabAllPlayers => 'اللاعبون';

  @override
  String get liveGameTabEnemyTeam => 'الفريق الخصم';

  @override
  String get liveGameTabYourTeam => 'فريقك';

  @override
  String liveGameTimeLeft(String t) {
    return 'متبقٍّ $t';
  }

  @override
  String get liveGameViewMatchDetails => 'عرض تفاصيل المباراة';

  @override
  String get liveGameWeapons => 'الأسلحة';

  @override
  String get liveGameYou => 'أنت';

  @override
  String liveGameYouHover(String agent) {
    return 'أنت تختار $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'قفلت $agent';
  }

  @override
  String get liveGamePickInGame =>
      'اختر عميلك وثبّته داخل VALORANT. يعرض ValHub الوقت المتبقي وفريقك فقط.';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins انتصار',
      many: '$wins انتصارًا',
      few: '$wins انتصارات',
      two: '$wins انتصاران',
      one: '$wins انتصار',
      zero: '$wins انتصار',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses خسارة',
      many: '$losses خسارة',
      few: '$losses خسارات',
      two: '$losses خسارتان',
      one: '$losses خسارة',
      zero: '$losses خسارة',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws تعادل',
      many: ' – $draws تعادلًا',
      few: ' – $draws تعادلات',
      two: ' – $draws تعادلان',
      one: ' – $draws تعادل',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown مباراة نتيجتها غير معروفة',
      many: ' – $unknown مباراة نتيجتها غير معروفة',
      few: ' – $unknown مباريات نتيجتها غير معروفة',
      two: ' – $unknown مباراتان نتيجتهما غير معروفة',
      one: ' – $unknown مباراة نتيجتها غير معروفة',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'توقيت الجهاز ($offset)';
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
      'yes': ' باستخدام $weapon',
      'other': '',
    });
    return '$killer أقصى $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 يومًا',
      'days7': '7 أيام',
      'other': 'كل الأوقات',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'العملاء',
      'maps': 'الخرائط',
      'queues': 'الأوضاع',
      'sides': 'الهجوم / الدفاع',
      'trend': 'الاتجاه',
      'other': 'الأوضاع',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'كل الأوضاع';

  @override
  String get profileAbility => 'قدرة';

  @override
  String profileAboutMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مباراة',
      many: '$n مباراة',
      few: '$n مباريات',
      two: '$n مباراتان',
      one: '$n مباراة',
      zero: '$n مباراة',
    );
    return '≈ $_temp0';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'متوسط نقاط القتال';

  @override
  String profileActRecord(int wins, int games, String rate) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins انتصار',
      many: '$wins انتصارًا',
      few: '$wins انتصارات',
      two: '$wins انتصاران',
      one: '$wins انتصار',
      zero: '$wins انتصار',
    );
    String _temp1 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: '$games مباراة',
      many: '$games مباراة',
      few: '$games مباريات',
      two: '$games مباراتان',
      one: '$games مباراة',
      zero: '$games مباراة',
    );
    return 'هذا المشهد: $_temp0 / $_temp1 · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'جميع اللاعبين';

  @override
  String get profileAlreadyReached => 'وصلت إلى هذه الرتبة بالفعل.';

  @override
  String get profileAtCurrentForm => 'بمستواك الحالي';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'بمستواك الحالي ($gain / $loss لكل مباراة)';
  }

  @override
  String profileBestCase(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'أفضل حالة: $n انتصار متتالٍ',
      many: 'أفضل حالة: $n انتصارًا متتاليًا',
      few: 'أفضل حالة: $n انتصارات متتالية',
      two: 'أفضل حالة: $n انتصاران متتاليان',
      one: 'أفضل حالة: $n انتصار متتالٍ',
      zero: 'أفضل حالة: $n انتصار متتالٍ',
    );
    return '$_temp0';
  }

  @override
  String get profileByWinRateTitle => 'حسب نسبة الفوز';

  @override
  String get profileChooseMap => 'التصفية حسب الخريطة';

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
  String get profileCopyRiotId => 'نسخ Riot ID';

  @override
  String get profileCurrentRank => 'الحالية';

  @override
  String get profileDailyRrEmpty =>
      'لا توجد مباريات تنافسية محفوظة على هذا الجهاز بعد.';

  @override
  String get profileDailyRrFootnote =>
      'يُحفظ سجل RR على جهازك مباشرةً، بما في ذلك المباريات التي لم تعد Riot تعرضها.';

  @override
  String get profileDailyRrTitle => 'RR اليومي';

  @override
  String profileDayBoundary(String zone) {
    return 'تُحسب الأيام وفق $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n يوم لعب',
      many: '$n يومًا من اللعب',
      few: '$n أيام لعب',
      two: '$n يوما لعب',
      one: '$n يوم لعب',
      zero: '$n يوم لعب',
    );
    return '$_temp0';
  }

  @override
  String get profileEndOfHistory => 'تم عرض جميع المباريات';

  @override
  String get profileEnemyTeam => 'الفريق الخصم';

  @override
  String get profileFallDamage => 'ضرر السقوط';

  @override
  String get profileFilterAll => 'الكل';

  @override
  String get profileFirstBloods => 'أول إقصاء';

  @override
  String get profileFirstDeaths => 'أول وفاة';

  @override
  String get profileFirstHalf => 'الشوط الأول';

  @override
  String get profileFormNoRoundStats =>
      'تُحتسب K/D و ACS و HS% في الأوضاع القائمة على الجولات فقط.';

  @override
  String profileFormPending(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'لم يتم بعد تحميل $n مباراة من القائمة لحساب هذه الإحصائيات.',
      many: 'لم يتم بعد تحميل $n مباراة من القائمة لحساب هذه الإحصائيات.',
      few: 'لم يتم بعد تحميل $n مباريات من القائمة لحساب هذه الإحصائيات.',
      two: 'لم يتم بعد تحميل $n مباراتين من القائمة لحساب هذه الإحصائيات.',
      one: 'لم يتم بعد تحميل $n مباراة من القائمة لحساب هذه الإحصائيات.',
      zero: 'لم يتم بعد تحميل $n مباراة من القائمة لحساب هذه الإحصائيات.',
    );
    return '$_temp0';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'تُحتسب K/D و ACS و ADR و HS% في $roundGames/$games من المباريات القائمة على الجولات فقط';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    String _temp0 = intl.Intl.pluralLogic(
      games,
      locale: localeName,
      other: 'آخر $games مباراة',
      many: 'آخر $games مباراة',
      few: 'آخر $games مباريات',
      two: 'آخر $games مباراتين',
      one: 'آخر $games مباراة',
      zero: 'آخر $games مباراة',
    );
    String _temp1 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w انتصار',
      many: '$w انتصارًا',
      few: '$w انتصارات',
      two: '$w انتصاران',
      one: '$w انتصار',
      zero: '$w انتصار',
    );
    String _temp2 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l خسارة',
      many: '$l خسارة',
      few: '$l خسارات',
      two: '$l خسارتان',
      one: '$l خسارة',
      zero: '$l خسارة',
    );
    return '$_temp0: $_temp1، $_temp2';
  }

  @override
  String get profileFriendsRow => 'الأصدقاء والدردشة';

  @override
  String get profileHideKills => 'إخفاء الإقصاءات';

  @override
  String get profileHitBody => 'الجسم';

  @override
  String get profileHitDistribution => 'توزيع الإصابات';

  @override
  String get profileHitHead => 'الرأس';

  @override
  String get profileHitLegs => 'الساقان';

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
      'نسبة الجولات التي حققت فيها إقصاءً أو مساعدة أو نجوت فيها أو ثأر لك فيها زميل';

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
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'آخر $n يوم',
      many: 'آخر $n يومًا',
      few: 'آخر $n أيام',
      two: 'آخر $n يومين',
      one: 'آخر $n يوم',
      zero: 'آخر $n يوم',
    );
    return '$_temp0';
  }

  @override
  String profileLastMatches(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'آخر $n مباراة',
      many: 'آخر $n مباراة',
      few: 'آخر $n مباريات',
      two: 'آخر $n مباراتين',
      one: 'آخر $n مباراة',
      zero: 'آخر $n مباراة',
    );
    return '$_temp0';
  }

  @override
  String profileLeaderboard(String n) {
    return 'لوحة المتصدرين #$n';
  }

  @override
  String profileLevel(int n) {
    return 'المستوى $n';
  }

  @override
  String get profileLevelHidden => 'المستوى مخفي';

  @override
  String profileLossStreak(int n) {
    return 'سلسلة خسارات: $n';
  }

  @override
  String profileMapFilter(String map) {
    return 'الخريطة: $map';
  }

  @override
  String profileMatchCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مباراة',
      many: '$n مباراة',
      few: '$n مباريات',
      two: '$n مباراتان',
      one: '$n مباراة',
      zero: '$n مباراة',
    );
    return '$_temp0';
  }

  @override
  String get profileMatchDetailTitle => 'تفاصيل المباراة';

  @override
  String get profileMatchHistory => 'سجل المباريات';

  @override
  String get profileMatchUnavailable => 'تعذّر تحميل المباراة';

  @override
  String get profileMatchesNeeded => 'المباريات المطلوبة';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'لم يُصنَّف من قبل';

  @override
  String get profileNoKillsInRound => 'لا توجد معلومات إقصاء لهذه الجولة بعد.';

  @override
  String get profileNoMatches => 'لا توجد مباريات بعد.';

  @override
  String get profileNoMatchesMap =>
      'لا توجد مباريات على هذه الخريطة ضمن المباريات المحمّلة.';

  @override
  String get profileNoMatchesQueue => 'لا توجد مباريات في هذا الوضع.';

  @override
  String get profileNoPlayers => 'لا تتوفر معلومات اللاعبين لهذه المباراة بعد.';

  @override
  String get profileNoRounds => 'لا تتوفر معلومات الجولات لهذه المباراة بعد.';

  @override
  String get profileOvertime => 'الوقت الإضافي';

  @override
  String get profilePlayHubTitle => 'المباراة والفريق';

  @override
  String get profilePeakRank => 'الأعلى';

  @override
  String get profilePerformanceAttack => 'الهجوم';

  @override
  String get profilePerformanceDefense => 'الدفاع';

  @override
  String get profilePerformanceEmpty =>
      'لم تُسجَّل أي مباريات على هذا الجهاز بعد. افتح سجل المباريات لتسجيل المباريات التي لعبتها.';

  @override
  String get profilePerformanceNoMatches =>
      'لا توجد مباريات في النطاق الزمني المحدد.';

  @override
  String profilePerformanceRounds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n جولة مسجلة',
      many: '$n جولة مسجلة',
      few: '$n جولات مسجلة',
      two: '$n جولتان مسجلتان',
      one: '$n جولة مسجلة',
      zero: '$n جولة مسجلة',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceSample =>
      'لا تظهر النسب إلا مع 3 مباريات على الأقل. تُحتسب ACS و ADR و HS% و K/D في الأوضاع القائمة على الجولات فقط.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'تم تحديد جهة الهجوم أو الدفاع في $known/$total من الجولات.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'السجل على هذا الجهاز منذ $date';
  }

  @override
  String get profilePerformanceTitle => 'الأداء';

  @override
  String profilePlacement(int n) {
    return 'المركز $n';
  }

  @override
  String profilePlantedAt(String site) {
    return 'زُرع Spike في $site';
  }

  @override
  String get profilePlayerProfileTitle => 'ملف اللاعب';

  @override
  String get profilePlayerSummary => 'الأداء';

  @override
  String profileProgressTo(String rank) {
    return 'التقدّم نحو $rank';
  }

  @override
  String get profileProgressToTarget => 'التقدّم نحو الرتبة المستهدفة';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'تقدير مبني على المباريات التنافسية الأخيرة؛ لا يأخذ في الحسبان مباريات تحديد المستوى أو الحماية من الهبوط.';

  @override
  String profileRankUpHint(int matches, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '≈ $matches مباراة للوصول إلى $rank',
      many: '≈ $matches مباراة للوصول إلى $rank',
      few: '≈ $matches مباريات للوصول إلى $rank',
      two: '≈ $matches مباراتان للوصول إلى $rank',
      one: '≈ $matches مباراة للوصول إلى $rank',
      zero: '≈ $matches مباراة للوصول إلى $rank',
    );
    return '$_temp0';
  }

  @override
  String get profileRankUpImmortal =>
      'رتبتك الأبدي أو أعلى بالفعل — هذه الأداة تحسب حتى الأبدي 1 فقط.';

  @override
  String get profileRankUpNoForm =>
      'لا توجد مباريات تنافسية حديثة لتقدير مستواك.';

  @override
  String get profileRankUpOpen => 'فتح حاسبة الترقية';

  @override
  String get profileRankUpTitle => 'حاسبة الترقية';

  @override
  String get profileRankUpUnranked =>
      'أكمل مباريات تحديد المستوى لاستخدام حاسبة الترقية.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'لوحة نتائج التنافسي';

  @override
  String profileRecentForm(int w, int l) {
    String _temp0 = intl.Intl.pluralLogic(
      w,
      locale: localeName,
      other: '$w انتصار',
      many: '$w انتصارًا',
      few: '$w انتصارات',
      two: '$w انتصاران',
      one: '$w انتصار',
      zero: '$w انتصار',
    );
    String _temp1 = intl.Intl.pluralLogic(
      l,
      locale: localeName,
      other: '$l خسارة',
      many: '$l خسارة',
      few: '$l خسارات',
      two: '$l خسارتان',
      one: '$l خسارة',
      zero: '$l خسارة',
    );
    return 'الأداء الأخير: $_temp0 – $_temp1';
  }

  @override
  String get profileRecentFormTitle => 'الأداء الأخير';

  @override
  String get profileRecentMatches => 'المباريات الأخيرة';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$wف · $lخ · $dت',
      many: '$wف · $lخ · $dت',
      few: '$wف · $lخ · $dت',
      two: '$wف · $lخ · $dت',
      one: '$wف · $lخ · $dت',
      zero: '$wف · $lخ',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'تم نسخ Riot ID';

  @override
  String profileRound(int n) {
    return 'الجولة $n';
  }

  @override
  String profileRoundKills(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n إقصاء',
      many: '$n إقصاءً',
      few: '$n إقصاءات',
      two: '$n إقصاءان',
      one: '$n إقصاء',
      zero: '$n إقصاء',
    );
    return '$_temp0';
  }

  @override
  String get profileRoundLost => 'خسارة الجولة';

  @override
  String get profileRoundTimeline => 'مجريات الجولات';

  @override
  String get profileRoundWon => 'الفوز بالجولة';

  @override
  String get profileRoundsHint => 'المس جولة لعرض كل إقصاء.';

  @override
  String profileRrLeft(String n) {
    return 'متبقٍّ $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'اتجاه RR';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'لوحة النتائج';

  @override
  String get profileSecondHalf => 'الشوط الثاني';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'عرض الإقصاءات';

  @override
  String get profileSideSwitch => 'تبديل الجهة';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'الرتبة المستهدفة';

  @override
  String get profileTeamBlue => 'الفريق الأزرق';

  @override
  String get profileTeamMvp => 'MVP الفريق';

  @override
  String get profileTeamRed => 'الفريق الأحمر';

  @override
  String get profileTitle => 'الملف الشخصي';

  @override
  String profileToday(String text) {
    return 'اليوم: $text';
  }

  @override
  String get profileTodayNone => 'لا توجد مباريات تنافسية اليوم';

  @override
  String get profileTruePeakLocal => 'وفق السجل على هذا الجهاز';

  @override
  String get profileWeekdayShortItem0 => 'إثنين';

  @override
  String get profileWeekdayShortItem1 => 'ثلاثاء';

  @override
  String get profileWeekdayShortItem2 => 'أربعاء';

  @override
  String get profileWeekdayShortItem3 => 'خميس';

  @override
  String get profileWeekdayShortItem4 => 'جمعة';

  @override
  String get profileWeekdayShortItem5 => 'سبت';

  @override
  String get profileWeekdayShortItem6 => 'أحد';

  @override
  String get profileWinRate => 'نسبة الفوز';

  @override
  String profileWinStreak(int n) {
    return 'سلسلة انتصارات: $n';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'رتبتك';

  @override
  String get profileYourSummary => 'أداؤك';

  @override
  String get profileYourTeam => 'فريقك';

  @override
  String get profileYourWinRate => 'نسبة فوزك مؤخرًا';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'الوضع: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'التصفية حسب الوضع';

  @override
  String get profilePerformancePerMatchTitle => 'حسب المباراة';

  @override
  String get profilePerformancePerMatchHint => 'المس عمودًا لفتح تلك المباراة.';

  @override
  String profilePerformanceAverage(String value) {
    return 'المتوسط $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'يلزم وجود مباراتين على الأقل من الأوضاع القائمة على الجولات تتضمنان هذه الإحصائية لعرض المخطط.';

  @override
  String get profilePerformanceOpeningsTitle => 'مواجهات الافتتاح';

  @override
  String get profilePerformanceOpeningWin => 'الفوز بمواجهات الافتتاح';

  @override
  String get profilePerformanceOpeningWinHint =>
      'من بين الجولات التي حققت فيها أول إقصاء أو كنت أول من يُقصى، نسبة الجولات التي حققت فيها أول إقصاء.';

  @override
  String get profilePerformanceFirstBloodsPerGame => 'أول إقصاء لكل مباراة';

  @override
  String get profilePerformanceFirstDeathsPerGame => 'أول وفاة لكل مباراة';

  @override
  String get profilePerformanceMultiKillsTitle =>
      'إقصاءات متعددة في جولة واحدة';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 إقصاءات',
      'k4': '4 إقصاءات',
      'ace': 'إيس',
      'other': 'إقصاءان',
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
      other: 'استنادًا إلى $nString مباراة تتوفر فيها بيانات الإقصاء كاملة.',
      many: 'استنادًا إلى $nString مباراة تتوفر فيها بيانات الإقصاء كاملة.',
      few: 'استنادًا إلى $nString مباريات تتوفر فيها بيانات الإقصاء كاملة.',
      two: 'استنادًا إلى $nString مباراتين تتوفر فيها بيانات الإقصاء كاملة.',
      one: 'استنادًا إلى $nString مباراة تتوفر فيها بيانات الإقصاء كاملة.',
      zero: 'استنادًا إلى $nString مباراة تتوفر فيها بيانات الإقصاء كاملة.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'نسبة الفوز بالجولات';

  @override
  String get profilePerformanceDrillHint =>
      'المس صفًا لعرض ذلك العميل أو الخريطة أو الوضع فقط.';

  @override
  String get profilePerformanceLoadOlder => 'تحليل مباريات أقدم';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'يحلل ValHub المباريات المفتوحة على هذا الجهاز فقط. تضيف كل نقرة مباريات أقدم (حتى $nString).';
  }

  @override
  String get profilePerformanceSearchingOlder => 'جارٍ البحث عن مباريات أقدم…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'جارٍ تحليل المباريات: $doneString/$totalString…';
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
      other: 'تمت إضافة $nString مباراة إلى التحليل.',
      many: 'تمت إضافة $nString مباراة إلى التحليل.',
      few: 'تمت إضافة $nString مباريات إلى التحليل.',
      two: 'تمت إضافة $nString مباراتين إلى التحليل.',
      one: 'تمت إضافة $nString مباراة إلى التحليل.',
      zero: 'لا توجد مباريات جديدة لإضافتها.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder => 'لم تعد Riot تحتفظ بمباريات أقدم.';

  @override
  String get profileEconomyTitle => 'اقتصاد فريقك';

  @override
  String get profileEconomyHint =>
      'يُحدَّد نوع الشراء حسب القيمة الإجمالية لعتاد فريقك في بداية الجولة (اصطلاح vlr.gg لخمسة لاعبين): Eco أقل من 5,000، وSemi-eco أقل من 10,000، وSemi-buy أقل من 20,000، وFull buy من 20,000 رصيد فأكثر. الجولة الأولى من كل شوط هي Pistol.';

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

    return 'الفوز $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get legalAboutIntro =>
      'رفيقك في VALORANT: المتجر اليومي وقائمة الأمنيات والرتبة والمباريات وحسابات متعددة ومجتمع للاعبين، على جهازك مباشرةً.';

  @override
  String get legalBackToTop => 'العودة إلى الأعلى';

  @override
  String get legalConsentAnd => ' و ';

  @override
  String get legalConsentPrefix => 'بالمتابعة، فإنك توافق على ';

  @override
  String get legalConsentPrivacy => 'سياسة الخصوصية';

  @override
  String get legalConsentSuffix => ' الخاصة بـ ValHub.';

  @override
  String get legalConsentTerms => 'شروط الاستخدام';

  @override
  String get legalContact => 'التواصل';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'التواصل';

  @override
  String legalEffectiveFrom(String date) {
    return 'ساري المفعول اعتبارًا من $date';
  }

  @override
  String get legalLegalHeader => 'المعلومات القانونية';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. جميع الحقوق محفوظة.';

  @override
  String get legalThirdPartyLicenses => 'برامج الجهات الخارجية';

  @override
  String get legalThirdPartyLicensesBody =>
      'تراخيص البرامج مفتوحة المصدر التي يستخدمها ValHub';

  @override
  String get legalTocTitle => 'المحتويات';

  @override
  String legalVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'يُعرض هذا المستند حاليًا باللغة: $language.';
  }

  @override
  String get legalContentUnavailable =>
      'تعذّرت قراءة المستند القانوني. يُرجى المحاولة مجددًا أو التواصل مع الدعم.';

  @override
  String get legalTranslationNotice =>
      'هذه الترجمة مقدَّمة للتيسير فقط. في حال وجود أي اختلاف، تكون النسخة الفيتنامية هي المعتمدة.';

  @override
  String get settingsUiLanguageTitle => 'لغة التطبيق';

  @override
  String get settingsLanguageFollowDevice => 'استخدام لغة الجهاز';

  @override
  String get settingsLanguageSaveFailed =>
      'تعذّر حفظ اللغة. يُرجى المحاولة مجددًا.';

  @override
  String get settingsGeoCountry => 'الدولة';

  @override
  String get settingsGeoSearchCountry => 'ابحث باسم الدولة أو رمزها';

  @override
  String get settingsGeoSupportedOnly => 'المدعومة المؤكدة فقط';

  @override
  String get settingsGeoUnknown => 'الدعم غير مؤكد';

  @override
  String get settingsGeoRestricted => 'مقيّدة';

  @override
  String get settingsGeoSeparate => 'خدمة منفصلة';

  @override
  String get settingsGeoAvailable => 'مدعومة';

  @override
  String get settingsGeoNotApplicable => 'غير منطبق';

  @override
  String get settingsGeoConnection => 'الاتصال بـ Riot';

  @override
  String get settingsGeoChooseRegion => 'اختيار المنطقة';

  @override
  String get settingsGeoAuto => 'تلقائي حسب الحساب';

  @override
  String get settingsGeoManual => 'اختيار يدوي';

  @override
  String get settingsGeoNoRegion => 'تعذّر تحديد منطقة Riot';

  @override
  String get settingsGeoManualWarning =>
      'هذا الخيار يغيّر الخادم الذي يتصل به ValHub فقط، ولا ينقل منطقة حساب Riot الخاص بك. سيتحقق ValHub من الاتصال قبل الحفظ.';

  @override
  String get settingsGeoConnectionSaved => 'تم حفظ الاتصال';

  @override
  String get settingsGeoValidationFailed =>
      'تعذّر تأكيد حسابك على هذا الخادم. يُرجى اختيار المنطقة مجددًا.';

  @override
  String get settingsGeoHintOnly =>
      'تُستخدم الدولة للبحث والاقتراحات فقط. تتبع منطقة الاتصال حساب Riot الخاص بك.';

  @override
  String get settingsGeoSave => 'تحقّق واحفظ';

  @override
  String get settingsGeoCancel => 'إلغاء';

  @override
  String get settingsGeoLoading => 'جارٍ التحقق من الاتصال…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'يُستخدم هذا الخيار لأسماء الدول والاقتراحات وأسعار VP التقديرية. أما الخادم الذي تتصل به ودولة حسابك في المجتمع فتحددهما Riot.';

  @override
  String get settingsGeoCountryAutomatic => 'استخدام دولة الحساب أو الجهاز';

  @override
  String get settingsGeoSaveFailed =>
      'تعذّر حفظ اختيارك. يُرجى المحاولة مجددًا.';

  @override
  String get settingsGeoAllRegions => 'جميع المناطق';

  @override
  String get settingsGeoSuggestions => 'اقتراحات';

  @override
  String get settingsGeoNoCountries => 'لا توجد دول تطابق عامل التصفية.';

  @override
  String get settingsGeoActiveCountries => 'نشطة';

  @override
  String get settingsGeoAllCountries => 'جميع الدول';

  @override
  String get settingsGeoActivityUnavailable =>
      'تعذّر تحميل نشاط الدول. لا يزال بإمكانك الاختيار من جميع الدول.';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count دولة',
      many: '$count دولة',
      few: '$count دول',
      two: '$count دولتان',
      one: '$count دولة',
      zero: '$count دولة',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'اخترت $manual، لكن Riot تحدد حسابك في $detected. هل تريد متابعة التحقق من هذا الاتصال؟';
  }

  @override
  String get settingsGeoUnverified =>
      'تعذّر التحقق من الاتصال بسبب مشكلة في الخادم أو الشبكة. هل تريد حفظ هذا الخيار والمحاولة لاحقًا؟';

  @override
  String get settingsGeoContinue => 'متابعة';

  @override
  String settingsGeoMismatch(String region) {
    return 'يختلف اتصالك اليدوي عن منطقة Riot الخاصة بك: $region. هل تريد التبديل إلى الوضع التلقائي؟';
  }

  @override
  String get settingsGeoUseAuto => 'استخدام التلقائي';

  @override
  String get settingsGeoKeepManual => 'الإبقاء على اليدوي';

  @override
  String get settingsGeoReviewConnection => 'عرض الاتصال';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'آخر تحقق: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'التحقق مجددًا';

  @override
  String get settingsPlatformMobile => 'الجوال';

  @override
  String get settingsPlatformOther => 'منصة أخرى';

  @override
  String get settingsContentLanguageFollowApp => 'نفس لغة التطبيق';

  @override
  String get settingsContentLanguageHint =>
      'اختر لغة أسماء العناصر. لا يغيّر هذا لغة التطبيق أو خادم Riot.';

  @override
  String settingsLanguageChanged(String language) {
    return 'اللغة: $language.';
  }

  @override
  String get settingsAboutHeader => 'معلومات';

  @override
  String get settingsAboutRowSubtitle =>
      'الخصوصية والشروط وحقوق النشر والتواصل';

  @override
  String get settingsAboutTitle => 'حول التطبيق والمعلومات القانونية';

  @override
  String get settingsAppHeader => 'متقدم';

  @override
  String get settingsAppearanceHeader => 'المظهر';

  @override
  String settingsBuildNumber(String build) {
    return 'البنية $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return 'تم مسح $size';
  }

  @override
  String get settingsClearCache => 'مسح البيانات المؤقتة';

  @override
  String get settingsClearCacheFailed =>
      'تعذّر مسح البيانات المؤقتة. يُرجى المحاولة مجددًا.';

  @override
  String get settingsClearCacheSubtitle =>
      'الصور والبيانات التي تم تنزيلها على جهازك، بما في ذلك تقارير الأخطاء المسجلة';

  @override
  String get settingsExportLog => 'إرسال تقرير خطأ إلى ValHub';

  @override
  String get settingsExportLogEmpty =>
      'لا يوجد ما يُرسل بعد. استخدم التطبيق لبعض الوقت ثم حاول مجددًا.';

  @override
  String get settingsExportLogSubtitle =>
      'لا تتضمن تقارير الأخطاء كلمة المرور أو بيانات تسجيل الدخول إلى Riot.';

  @override
  String get settingsFeedback => 'إرسال ملاحظات إلى ValHub';

  @override
  String get settingsFeedbackSubtitle => 'فتح صفحة الملاحظات في ValHub';

  @override
  String get settingsItemLanguageEn => 'الإنجليزية';

  @override
  String get settingsItemLanguageLabel => 'أسماء العناصر';

  @override
  String get settingsItemLanguagePickerTitle => 'لغة أسماء العناصر';

  @override
  String get settingsItemLanguageVi => 'الفيتنامية';

  @override
  String get settingsLinkOpenFailed =>
      'تعذّر فتح الرابط. يُرجى المحاولة مجددًا.';

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — تقرير خطأ';
  }

  @override
  String get settingsLogShareFailed =>
      'تعذّر إرسال تقرير الخطأ. يُرجى المحاولة مجددًا.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'عند افتتاح السوق الليلي';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'تذكير بقلب بطاقات عروض السوق الليلي';

  @override
  String get settingsNotifPermissionMissing =>
      'لا يملك التطبيق إذنًا بإرسال الإشعارات.';

  @override
  String get settingsNotifStoreReset => 'عند تجديد المتجر';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return 'يوميًا في $time';
  }

  @override
  String get settingsNotifWishlist => 'عند ظهور مظهر من قائمة الأمنيات';

  @override
  String get settingsNotifWishlistSubtitle =>
      'يتحقق من متجر كل الحسابات، حتى عندما يكون التطبيق مغلقًا';

  @override
  String get settingsNotificationsHeader => 'الإشعارات';

  @override
  String get settingsOptionAutoOpenLiveGame => 'فتح تفاصيل المباراة تلقائيًا';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'فتح لوحة المباراة الحالية فور العثور على مباراة';

  @override
  String get settingsOptionOwnPrice => 'سعر حزمة VP لديك';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'غير محدد — تُستخدم قائمة أسعار منطقتك إن توفرت';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'المنصة';

  @override
  String get settingsOptionShowLiveScore => 'إظهار النتيجة المباشرة';

  @override
  String get settingsOptionShowPeakRank => 'إظهار أعلى رتبة في تفاصيل المباراة';

  @override
  String get settingsOptionShowPrice => 'إظهار الأسعار التقديرية';

  @override
  String get settingsOptionShowPriceInfo => 'كيف تُحسب الأسعار التقديرية';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'بجانب أسعار VP، مثل $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'لا توجد قائمة أسعار موثّقة لمنطقتك بعد — أدخل سعر حزمة VP لديك.';

  @override
  String get settingsOptionsHeader => 'الخيارات';

  @override
  String get settingsPhaseComplete => 'مكتملة';

  @override
  String get settingsPhaseInProgress => 'جارية';

  @override
  String get settingsPhaseScheduled => 'مجدولة';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'ينطبق على $account';
  }

  @override
  String get settingsPlatformHint =>
      'اختر PC أو PlayStation أو Xbox حسب المنصة التي تلعب عليها لعرض سجل المباريات الصحيح.';

  @override
  String get settingsPlatformPickerTitle => 'اختيار المنصة';

  @override
  String get settingsPrimingBody =>
      'فعّل الإشعارات لتعرف متى يتجدد متجرك ومتى يظهر مظهر من قائمة الأمنيات.';

  @override
  String get settingsPrimingEnable => 'تفعيل الإشعارات';

  @override
  String get settingsPrimingFootnote =>
      'يمكنك تفعيل كل نوع من الإشعارات أو إيقافه في أي وقت من الإعدادات.';

  @override
  String get settingsPrimingLater => 'لاحقًا';

  @override
  String get settingsPrimingPointNightMarket => 'اعرف متى يُفتتح السوق الليلي';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'لتتمكن من قلب بطاقات العروض قبل انتهاء صلاحيتها';

  @override
  String get settingsPrimingPointStore => 'تذكيرات عند تجديد المتجر اليومي';

  @override
  String get settingsPrimingPointStoreDetail => 'تذكير بعد تجديد متجر حسابك';

  @override
  String get settingsPrimingPointWishlist => 'تنبيه عند ظهور مظهر تبحث عنه';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'يتحقق من متجر كل الحسابات، حتى عندما يكون التطبيق مغلقًا';

  @override
  String get settingsPrimingTitle => 'لا تفوّت أي مظهر تبحث عنه';

  @override
  String settingsRemovedAccount(String account) {
    return 'تمت إزالة $account';
  }

  @override
  String get settingsServerStatus => 'حالة الخادم';

  @override
  String get settingsServerStatusMaintenance => 'قيد الصيانة';

  @override
  String settingsServerStatusNotices(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n إشعار',
      many: '$n إشعارًا',
      few: '$n إشعارات',
      two: '$n إشعاران',
      one: '$n إشعار',
      zero: '$n إشعار',
    );
    return '$_temp0';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'صيانة VALORANT وأعطاله حسب الخادم';

  @override
  String get settingsSessionLogTitle => 'تقرير خطأ ValHub';

  @override
  String get settingsSeverityCritical => 'حرج';

  @override
  String get settingsSeverityInfo => 'معلومات';

  @override
  String get settingsSeverityWarning => 'تحذير';

  @override
  String get settingsSignedOutAll => 'تم تسجيل الخروج من جميع الحسابات';

  @override
  String get settingsStatusAllGood => 'الخوادم تعمل بشكل طبيعي';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'لا توجد أعطال أو صيانة على خادم $region.';
  }

  @override
  String get settingsStatusFewerUpdates => 'عرض أقل';

  @override
  String get settingsStatusIssues => 'تعمل Riot على حل مشكلة';

  @override
  String settingsStatusIssuesBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'يوجد على هذا الخادم $n إشعار عطل.',
      many: 'يوجد على هذا الخادم $n إشعارًا عن الأعطال.',
      few: 'يوجد على هذا الخادم $n إشعارات أعطال.',
      two: 'يوجد على هذا الخادم $n إشعارا عطل.',
      one: 'يوجد على هذا الخادم $n إشعار عطل.',
      zero: 'يوجد على هذا الخادم $n إشعار عطل.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusKindIncident => 'عطل';

  @override
  String get settingsStatusKindMaintenance => 'صيانة';

  @override
  String get settingsStatusMaintenanceNow => 'الخادم قيد الصيانة';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'قد لا تتمكن من اللعب حاليًا، وقد يتعذّر على ValHub تحميل المعلومات مؤقتًا.';

  @override
  String settingsStatusMoreUpdates(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'عرض $n تحديث إضافي',
      many: 'عرض $n تحديثًا إضافيًا',
      few: 'عرض $n تحديثات إضافية',
      two: 'عرض $n تحديثين إضافيين',
      one: 'عرض $n تحديث إضافي',
      zero: 'عرض $n تحديث إضافي',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusScheduled => 'صيانة قادمة';

  @override
  String settingsStatusScheduledBody(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'أعلنت Riot عن $n موعد للصيانة.',
      many: 'أعلنت Riot عن $n موعدًا للصيانة.',
      few: 'أعلنت Riot عن $n مواعيد للصيانة.',
      two: 'أعلنت Riot عن $n موعدين للصيانة.',
      one: 'أعلنت Riot عن $n موعد للصيانة.',
      zero: 'أعلنت Riot عن $n موعد للصيانة.',
    );
    return '$_temp0';
  }

  @override
  String get settingsStatusSourceNote =>
      'المصدر: صفحة الحالة الرسمية لـ Riot Games. تُعرض الأوقات حسب المنطقة الزمنية لجهازك.';

  @override
  String settingsStatusStarted(String when) {
    return 'البدء: $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'التحديث: $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'تحديثات من RIOT';

  @override
  String get settingsSupportHeader => 'الدعم';

  @override
  String settingsSwitchedTo(String account) {
    return 'تم التبديل إلى $account';
  }

  @override
  String get settingsThemeDark => 'داكن';

  @override
  String get settingsThemeLabel => 'السمة';

  @override
  String get settingsThemeLight => 'فاتح';

  @override
  String get settingsThemePickerTitle => 'اختيار السمة';

  @override
  String get settingsThemeSystem => 'حسب النظام';

  @override
  String get settingsTitle => 'الإعدادات';

  @override
  String settingsVersion(String version) {
    return 'الإصدار $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'الرتبة وسجل المباريات والمباريات المباشرة';

  @override
  String get settingsWelcomeBulletProfileDetail => 'RR لكل مباراة ورتب الخصوم';

  @override
  String get settingsWelcomeBulletStore =>
      'المتجر اليومي والسوق الليلي والباقات';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'الأسعار والندرة والعد التنازلي للتجديد';

  @override
  String get settingsWelcomeBulletWishlist => 'قائمة الأمنيات والإشعارات';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'تنبيه عند ظهور مظهر تبحث عنه في متجرك';

  @override
  String get settingsWelcomeFootnote =>
      'يتم تسجيل الدخول عبر صفحة Riot الرسمية. لا يحفظ ValHub كلمة المرور إلا إذا اخترت حفظ معلومات تسجيل الدخول.';

  @override
  String get settingsWelcomeKicker => 'رفيقك في VALORANT';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average (التقييمات: $count) · ',
      'other': '',
    });
    return 'المجتمع: $_temp0الإعجابات: $votes';
  }

  @override
  String get skinDetailAddToWishlist => 'إضافة إلى قائمة الأمنيات';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'متوفر في متجر: $accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    String _temp0 = intl.Intl.pluralLogic(
      daily,
      locale: localeName,
      other: '$daily مرة في المتجر اليومي',
      many: '$daily مرة في المتجر اليومي',
      few: '$daily مرات في المتجر اليومي',
      two: '$daily مرتان في المتجر اليومي',
      one: '$daily مرة في المتجر اليومي',
      zero: '$daily مرة في المتجر اليومي',
    );
    String _temp1 = intl.Intl.pluralLogic(
      night,
      locale: localeName,
      other: '$night مرة في السوق الليلي',
      many: '$night مرة في السوق الليلي',
      few: '$night مرات في السوق الليلي',
      two: '$night مرتان في السوق الليلي',
      one: '$night مرة في السوق الليلي',
      zero: '$night مرة في السوق الليلي',
    );
    return 'في متجرك: $_temp0، $_temp1. يُحتسب ما سُجّل على هذا الجهاز فقط منذ $since.';
  }

  @override
  String get skinDetailHistoryDelete => 'حذف سجل المتجر';

  @override
  String get skinDetailHistoryDeleteBody =>
      'هل تريد حذف كل أيام المتجر المسجلة لهذا الحساب على هذا الجهاز؟';

  @override
  String get skinDetailInWishlist => 'في قائمة الأمنيات';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'مقفل';

  @override
  String get skinDetailMute => 'كتم الصوت';

  @override
  String get skinDetailNotFound => 'تعذّر العثور على هذا المظهر.';

  @override
  String get skinDetailOwned => 'مملوك';

  @override
  String get skinDetailPause => 'إيقاف مؤقت';

  @override
  String get skinDetailPlay => 'تشغيل';

  @override
  String get skinDetailPlayVideo => 'مشاهدة الفيديو';

  @override
  String get skinDetailRemoveFromWishlist => 'إزالة من قائمة الأمنيات';

  @override
  String get skinDetailTitle => 'تفاصيل المظهر';

  @override
  String get skinDetailUnmute => 'إلغاء كتم الصوت';

  @override
  String get skinDetailUpgrades => 'الترقيات';

  @override
  String get skinDetailVariants => 'التنويعات';

  @override
  String get skinDetailVideoError =>
      'تعذّر تشغيل الفيديو. يُرجى التحقق من الاتصال والمحاولة مجددًا.';

  @override
  String get socialPresenceInMatch => 'في مباراة';

  @override
  String get socialPresenceAgentSelect => 'في اختيار العميل';

  @override
  String get socialPresenceQueue => 'في قائمة الانتظار';

  @override
  String get socialPresenceLobby => 'في الردهة';

  @override
  String get socialPresenceCustom => 'في لعبة مخصصة';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'فريق مفتوح',
      'other': 'بالدعوة فقط',
    });
    return 'اللاعبون: $size/$max · $_temp0';
  }

  @override
  String get socialAccept => 'قبول';

  @override
  String get socialAcceptInGame => 'اقبل هذه الدعوة داخل اللعبة.';

  @override
  String socialActionFailed(String message) {
    return 'تعذّر إكمال الإجراء. $message';
  }

  @override
  String get socialAutoRefresh => 'تحديث تلقائي';

  @override
  String get socialAway => 'بعيد';

  @override
  String socialCancelQueue(String elapsed) {
    return 'إلغاء البحث · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'إلغاء البحث';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'لا يمكن لفريقك البحث في $queue: $reason';
  }

  @override
  String get socialChangeQueue => 'تغيير قائمة الانتظار';

  @override
  String get socialChatUnavailable => 'الدردشة غير متصلة.';

  @override
  String get socialCloseParty => 'إغلاق الفريق';

  @override
  String get socialCodeInvalid => 'تتكون رموز الفريق من أحرف وأرقام فقط.';

  @override
  String get socialConnecting => 'جارٍ الاتصال بالدردشة…';

  @override
  String get socialCopyCode => 'نسخ';

  @override
  String get socialCurrentQueue => 'المحدد';

  @override
  String get socialCustomGameLobby => 'فريقك في ردهة لعبة مخصصة.';

  @override
  String get socialDecline => 'رفض';

  @override
  String get socialDisableCode => 'تعطيل الرمز';

  @override
  String get socialEmptyChat => 'لا توجد رسائل بعد. ابدأ بالتحية!';

  @override
  String get socialEmptyChatTitle => 'ابدأ الدردشة';

  @override
  String get socialFailedBadge => 'لم يُرسَل';

  @override
  String get socialFilterAll => 'الكل';

  @override
  String get socialFilterOnline => 'متصل';

  @override
  String get socialFilterUnread => 'غير مقروءة';

  @override
  String get socialFriendsPrivacyNote =>
      'تأتي قائمة أصدقائك ورسائلك مباشرةً من Riot. لا يحفظها ValHub في أي مكان آخر.';

  @override
  String socialFriendsSummary(int total, int online) {
    String _temp0 = intl.Intl.pluralLogic(
      total,
      locale: localeName,
      other: '$total صديق',
      many: '$total صديقًا',
      few: '$total أصدقاء',
      two: '$total صديقان',
      one: '$total صديق',
      zero: '$total صديق',
    );
    return '$_temp0 · متصل الآن: $online';
  }

  @override
  String get socialFriendsTitle => 'الأصدقاء والدردشة';

  @override
  String get socialGameNotRunningBody =>
      'لا يعمل الفريق وقائمة الانتظار إلا أثناء تشغيل VALORANT على الكمبيوتر أو جهاز الألعاب. افتح اللعبة ثم اسحب للأسفل للتحديث.';

  @override
  String get socialGameNotRunningTitle =>
      'افتح VALORANT على الكمبيوتر أو جهاز الألعاب';

  @override
  String get socialGenerateCode => 'إنشاء رمز';

  @override
  String get socialIdleQueue => 'جاهز للبحث';

  @override
  String get socialInMatchBanner =>
      'أنت في مباراة. ستُفتح قائمة الانتظار مجددًا عند انتهاء المباراة.';

  @override
  String get socialInValorant => 'في VALORANT';

  @override
  String get socialInviteByRiotId => 'دعوة عبر Riot ID';

  @override
  String get socialInviteByRiotIdHint => 'ادعُ لاعبين ليسوا من أصدقائك بعد';

  @override
  String get socialInviteFriends => 'دعوة الأصدقاء';

  @override
  String socialInviteFrom(String name) {
    return 'دعوة من $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'دعوة $name';
  }

  @override
  String get socialInviteNeedsName =>
      'Riot ID لهذا اللاعب غير معروف، لذا لا يمكن دعوته بعد.';

  @override
  String socialInviteSent(String name) {
    return 'تم إرسال الدعوة إلى $name.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · تمت دعوته';
  }

  @override
  String get socialInvitesSection => 'الدعوات';

  @override
  String get socialJoin => 'انضمام';

  @override
  String get socialJoinConfirmBody =>
      'ستغادر فريقك الحالي للانضمام إلى الفريق صاحب هذا الرمز.';

  @override
  String get socialJoinConfirmTitle => 'الانضمام إلى فريق آخر؟';

  @override
  String get socialJoinSection => 'الانضمام إلى فريق آخر';

  @override
  String get socialJoinWithCode => 'أدخل رمزًا للانضمام';

  @override
  String get socialJoined => 'انضممت إلى الفريق.';

  @override
  String socialLastOnline(String relative) {
    return 'نشط $relative';
  }

  @override
  String get socialLeader => 'القائد';

  @override
  String socialLeaderboardTop(String position) {
    return 'المركز $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'ستغادر فريقك الحالي وتعود إلى فريق فردي.';

  @override
  String get socialLeaveConfirmTitle => 'مغادرة الفريق؟';

  @override
  String get socialLeaveParty => 'مغادرة الفريق';

  @override
  String socialLevel(int n) {
    return 'المستوى $n';
  }

  @override
  String get socialMatchFound => 'تم العثور على مباراة!';

  @override
  String socialMembersSection(int n, int max) {
    return 'الأعضاء ($n/$max)';
  }

  @override
  String get socialMessageHint => 'اكتب رسالة…';

  @override
  String get socialMoreActions => 'خيارات أخرى';

  @override
  String get socialNoCode =>
      'أنشئ رمزًا ليتمكن أصدقاؤك من الانضمام إلى فريقك بسرعة.';

  @override
  String get socialNoCodeMember =>
      'يمكن لقائد الفريق إنشاء رمز للدعوات السريعة.';

  @override
  String get socialNoFilterResults =>
      'لا يوجد أصدقاء يطابقون عامل التصفية هذا.';

  @override
  String get socialNoFriends =>
      'قائمة أصدقائك في Riot فارغة. أضف أصدقاء داخل اللعبة.';

  @override
  String get socialNoFriendsTitle => 'لا يوجد أصدقاء بعد';

  @override
  String get socialNoOnlineFriends =>
      'لا يوجد أي من أصدقائك متصلًا في VALORANT حاليًا.';

  @override
  String get socialNoSearchResults => 'لا يوجد أصدقاء مطابقون.';

  @override
  String get socialNoSearchResultsTitle => 'لم يتم العثور على شيء';

  @override
  String get socialNotReady => 'غير جاهز';

  @override
  String socialOfflineSection(int n) {
    return 'غير متصل ($n)';
  }

  @override
  String get socialOfflineStatus => 'غير متصل';

  @override
  String get socialOnlineMobile => 'متصل عبر الجوال';

  @override
  String socialOnlineSection(int n) {
    return 'متصل ($n)';
  }

  @override
  String get socialOnlineStatus => 'متصل';

  @override
  String get socialOnlyLeader =>
      'لا يمكن إلا لقائد الفريق تغيير قائمة الانتظار وبدء البحث عن مباراة.';

  @override
  String get socialOpenParty => 'فتح الفريق';

  @override
  String get socialOtherGamesLeagueOfLegends => 'ليج أوف ليجندز';

  @override
  String get socialOtherGamesBacon => 'أساطير رونيتيرا';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'رمز الفريق';

  @override
  String socialPartyCodeValue(String code) {
    return 'رمز الفريق: $code';
  }

  @override
  String get socialPartyInvite => 'دعوة إلى الفريق';

  @override
  String socialPartyOf(int size, int max) {
    return 'الفريق $size/$max';
  }

  @override
  String get socialPartyTitle => 'الفريق وقائمة الانتظار';

  @override
  String socialPickQueueSubtitle(int size) {
    String _temp0 = intl.Intl.pluralLogic(
      size,
      locale: localeName,
      other: 'فريق من $size لاعب',
      many: 'فريق من $size لاعبًا',
      few: 'فريق من $size لاعبين',
      two: 'فريق من $size لاعبين',
      one: 'فريق من $size لاعب',
      zero: 'فريق من $size لاعب',
    );
    return '$_temp0';
  }

  @override
  String get socialPickQueueTitle => 'اختيار قائمة الانتظار';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'أفضل Ping إلى خوادم المباريات';

  @override
  String socialPlayingOther(String game) {
    return 'يلعب $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'يلعبون ($n)';
  }

  @override
  String get socialQueueLabel => 'قائمة الانتظار';

  @override
  String get socialQueueLocked =>
      'لا يمكن تغيير قائمة الانتظار أثناء المباراة.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'الحد الأقصى $max لاعب',
      many: 'الحد الأقصى $max لاعبًا',
      few: 'الحد الأقصى $max لاعبين',
      two: 'الحد الأقصى $max لاعبان',
      one: 'لعب فردي فقط',
      zero: 'الحد الأقصى $max لاعب',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'تعذّر التحقق من حالة اللعبة. حدّث الصفحة لاستخدام الجاهزية وقائمة الانتظار.';

  @override
  String get socialReady => 'جاهز';

  @override
  String socialReadyCount(int ready, int total) {
    return 'جاهز $ready/$total';
  }

  @override
  String get socialReasonAccountLevel => 'مستوى حساب أحد الأعضاء منخفض جدًا';

  @override
  String get socialReasonGeneric => 'الفريق غير مؤهل بعد';

  @override
  String socialReasonPartyTooLarge(int max) {
    return 'الفريق كبير جدًا (الحد الأقصى $max)';
  }

  @override
  String get socialReasonRankDisparity => 'فارق الرتب كبير جدًا للعب التنافسي';

  @override
  String socialReasonRestricted(String time) {
    return 'الفريق ممنوع مؤقتًا من البحث عن مباراة (متبقٍّ $time)';
  }

  @override
  String get socialReconnecting =>
      'انقطع الاتصال بالدردشة. جارٍ إعادة الاتصال…';

  @override
  String get socialRemoteNote =>
      'لا تُرسل التغييرات إلى Riot إلا عندما تضغط. لا يبحث ValHub عن مباراة ولا يقفل عميلًا نيابةً عنك أبدًا.';

  @override
  String socialRemoveConfirmBody(String name) {
    return 'ستتم إزالة $name من فريقك.';
  }

  @override
  String get socialRemoveConfirmTitle => 'إزالة من الفريق؟';

  @override
  String get socialRemoveMember => 'إزالة من الفريق';

  @override
  String socialRequestFrom(String name) {
    return 'يريد $name الانضمام إلى الفريق';
  }

  @override
  String get socialRequestsSection => 'طلبات الانضمام';

  @override
  String get socialRiotIdFieldHint => 'الاسم#TAG';

  @override
  String get socialRiotIdInvalid =>
      'يتكون Riot ID من اسم (3–16 حرفًا) ثم # ثم وسم (3–5 أحرف أو أرقام).';

  @override
  String get socialSearchHint => 'ابحث عبر Riot ID…';

  @override
  String socialSearching(String elapsed) {
    return 'في قائمة الانتظار · $elapsed';
  }

  @override
  String get socialSend => 'إرسال';

  @override
  String get socialSendFailed =>
      'تعذّر إرسال الرسالة. يُرجى التحقق من الاتصال والمحاولة مجددًا.';

  @override
  String get socialSendInvite => 'إرسال دعوة';

  @override
  String get socialShareCode => 'مشاركة';

  @override
  String socialShareCodeText(String code) {
    return 'انضم إلى فريقي في VALORANT بالرمز: $code';
  }

  @override
  String get socialShootingRange => 'في ميدان الرماية';

  @override
  String get socialShowEveryone => 'عرض الكل';

  @override
  String get socialStartQueue => 'بدء البحث';

  @override
  String get socialSuggestionsItem0 => 'مرحبًا!';

  @override
  String get socialSuggestionsItem1 => 'نلعب بضع مباريات؟';

  @override
  String get socialSuggestionsItem2 => 'انضم إلى فريقي!';

  @override
  String socialUnread(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n رسالة غير مقروءة',
      many: '$n رسالة غير مقروءة',
      few: '$n رسائل غير مقروءة',
      two: '$n رسالتان غير مقروءتين',
      one: '$n رسالة غير مقروءة',
      zero: '$n رسالة غير مقروءة',
    );
    return '$_temp0';
  }

  @override
  String get socialUnready => 'إلغاء الجاهزية';

  @override
  String get socialViewProfile => 'عرض الملف الشخصي';

  @override
  String get socialWaitingForConnection =>
      'جارٍ الاتصال… يمكنك إرسال الرسائل بعد اكتمال الاتصال.';

  @override
  String get socialYou => 'أنت';

  @override
  String get socialPartyUnavailable =>
      'تعذّرت مزامنة فريقك. حدّث الصفحة لإعادة المحاولة.';

  @override
  String get storeAccessoryEmpty => 'متجر الإكسسوارات فارغ حاليًا.';

  @override
  String get storeAccessoryEmptyTitle => 'لا توجد إكسسوارات بعد';

  @override
  String storeAccessoryFrom(String contract) {
    return 'من: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'التجديد بعد $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'التجديد في $wall';
  }

  @override
  String get storeAddToWishlist => 'إضافة إلى قائمة الأمنيات';

  @override
  String get storeBackToBundles => 'عرض الباقات المعروضة';

  @override
  String get storeBundleBuySeparateLabel => 'الشراء بشكل منفصل';

  @override
  String get storeBundleDetailTitle => 'تفاصيل الباقة';

  @override
  String storeBundleEndsAt(String wall) {
    return 'تنتهي في $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'متبقٍّ $t';
  }

  @override
  String storeBundleItemCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n عنصر',
      many: '$n عنصرًا',
      few: '$n عناصر',
      two: '$n عنصران',
      one: '$n عنصر',
      zero: '$n عنصر',
    );
    return '$_temp0';
  }

  @override
  String get storeBundleItemFree => 'مجاني';

  @override
  String get storeBundleItemsTitle => 'عناصر الباقة';

  @override
  String get storeBundleNotFound =>
      'تعذّر العثور على هذه الباقة. ربما انتهت صلاحيتها.';

  @override
  String get storeBundleNotFoundTitle => 'انتهت صلاحية الباقة';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'المملوك: $owned/$total من العناصر';
  }

  @override
  String get storeBundlePriceLabel => 'سعر الباقة';

  @override
  String get storeBundleSavingsLabel => 'توفّر';

  @override
  String get storeBundleWholesaleOnly =>
      'تُباع كباقة كاملة فقط، لا بشكل منفصل.';

  @override
  String get storeBundlesEmpty => 'لا توجد باقات معروضة للبيع حاليًا.';

  @override
  String get storeBundlesEmptyTitle => 'لا توجد باقات بعد';

  @override
  String get storeDailyEmpty => 'لا توجد مظاهر في المتجر اليوم.';

  @override
  String get storeDailyEmptyTitle => 'المتجر فارغ';

  @override
  String storeDailyResetAt(String time) {
    return 'يتجدد يوميًا في $time';
  }

  @override
  String get storeDailyTotalLabel => 'الإجمالي';

  @override
  String get storeNightMarketEmpty => 'لا يوجد سوق ليلي حاليًا.';

  @override
  String get storeNightMarketEmptyTitle => 'السوق الليلي غير مفتوح';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'ينتهي في $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'ينتهي بعد $t';
  }

  @override
  String get storeNightMarketNote =>
      'عروض السوق الليلي خاصة بحسابك ولا يمكن تجديدها.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'إجمالي التوفير $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'لم تُقلب';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name، $price';
  }

  @override
  String get storeOwnedBadge => 'مملوك';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'المملوك: $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'إزالة من قائمة الأمنيات';

  @override
  String get storeResetNotificationTitle => 'تجدد متجرك';

  @override
  String storeResetsIn(String t) {
    return 'التجديد بعد $t';
  }

  @override
  String get storeSegmentAccessories => 'الإكسسوارات';

  @override
  String get storeSegmentBundles => 'الباقات';

  @override
  String get storeSegmentDaily => 'اليومي';

  @override
  String get storeSegmentNightMarket => 'السوق الليلي';

  @override
  String get storeShareButton => 'مشاركة';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'متجر اليوم';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'السوق الليلي';

  @override
  String get storeShareCardPriceNote =>
      'الأسعار المحوّلة تقديرية فقط ومبنية على حزم VP.';

  @override
  String storeShareCardSaved(String vp) {
    return 'توفير $vp';
  }

  @override
  String get storeShareCardTagline => 'رفيقك في VALORANT';

  @override
  String storeShareCardTotal(String vp) {
    return 'الإجمالي $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'حتى $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'مشاركة متجر اليوم';

  @override
  String get storeShareFailed => 'تعذّر إنشاء الصورة. يُرجى المحاولة مجددًا.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => 'مشاركة صورة';

  @override
  String get storeShareNightMarketTitle => 'مشاركة السوق الليلي';

  @override
  String get storeSharePreparing => 'جارٍ تحميل صور المظاهر…';

  @override
  String get storeShareShowPrice => 'إظهار الأسعار التقديرية';

  @override
  String get storeShareShowPriceHint => 'محسوبة وفق حزمة VP الأوفر.';

  @override
  String get storeShareShowRiotId => 'إظهار Riot ID على الصورة';

  @override
  String get storeShareShowRiotIdHint => 'معطّل افتراضيًا للحفاظ على خصوصيتك.';

  @override
  String get storeShareSubjectDaily => 'متجري في VALORANT اليوم';

  @override
  String get storeShareSubjectNightMarket => 'سوقي الليلي في VALORANT';

  @override
  String get storeShareSubtitle => 'شارك صورة متجرك مع أصدقائك عبر أي تطبيق.';

  @override
  String get storeTitle => 'المتجر';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'الرصيد: $vp VP، $kc KC، $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return 'في قائمة الأمنيات: $n';
  }

  @override
  String get storeHistoryTitle => 'سجل المتجر';

  @override
  String storeHistorySince(String date, int days) {
    final intl.NumberFormat daysNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String daysString = daysNumberFormat.format(days);

    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$daysString يوم',
      many: '$daysString يومًا',
      few: '$daysString أيام',
      two: '$daysString يومان',
      one: '$daysString يوم',
      zero: '$daysString يوم',
    );
    return 'يُسجَّل على هذا الجهاز منذ $date · $_temp0';
  }

  @override
  String get storeHistoryEmpty =>
      'لم يُسجَّل أي يوم بعد. يحفظ ValHub متجرك اليومي في كل مرة تفتح فيها التطبيق، على هذا الجهاز فقط.';

  @override
  String get storeHistoryMostOffered => 'الأكثر ظهورًا';

  @override
  String storeHistoryTimes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$nString مرة',
      many: '$nString مرة',
      few: '$nString مرات',
      two: '$nString مرتان',
      one: '$nString مرة',
      zero: '$nString مرة',
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
      other: 'السوق الليلي · $countString عرض',
      many: 'السوق الليلي · $countString عرضًا',
      few: 'السوق الليلي · $countString عروض',
      two: 'السوق الليلي · $countString عرضان',
      one: 'السوق الليلي · $countString عرض',
      zero: 'السوق الليلي · $countString عرض',
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
      other: 'سُجِّل على هذا الجهاز: $daysString يوم',
      many: 'سُجِّل على هذا الجهاز: $daysString يومًا',
      few: 'سُجِّل على هذا الجهاز: $daysString أيام',
      two: 'سُجِّل على هذا الجهاز: $daysString يومان',
      one: 'سُجِّل على هذا الجهاز: $daysString يوم',
      zero: 'بدأ التسجيل اليوم',
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
      'yes': '$skin متوفر في متجر $account — متبقٍّ $left.',
      'other': '$skin متوفر في متجر $account.',
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
      'discount': '$skin بخصم $percent%، الآن بسعر $price ($account).',
      'price': '$skin بسعر $price فقط ($account).',
      'other': '$skin متوفر في السوق الليلي لـ $account.',
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
      'yes': '$skin ضمن باقة $bundle ($account).',
      'other': '$skin ضمن باقة معروضة للبيع ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: 'متوفر الآن في متجر $account: $names و$more مظهر آخر.',
      many: 'متوفر الآن في متجر $account: $names و$more مظهرًا آخر.',
      few: 'متوفر الآن في متجر $account: $names و$more مظاهر أخرى.',
      two: 'متوفر الآن في متجر $account: $names و$more مظهران آخران.',
      one: 'متوفر الآن في متجر $account: $names و$more مظهر آخر.',
      zero: 'متوفر الآن في متجر $account: $names.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': '، في قائمة الأمنيات',
      'other': '',
    });
    return '$name، $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'إضافة مظاهر';

  @override
  String get wishlistAddToWishlist => 'إضافة إلى قائمة الأمنيات';

  @override
  String get wishlistAllWeapons => 'جميع الأسلحة';

  @override
  String get wishlistBrowseCatalog => 'عرض جميع المظاهر';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString مظهر',
      many: '$countString مظهرًا',
      few: '$countString مظاهر',
      two: '$countString مظهر',
      one: '$countString مظهر',
      zero: '$countString مظهر',
    );
    return '$_temp0';
  }

  @override
  String get wishlistCatalogEmpty =>
      'تعذّر تحميل قائمة المظاهر. حدّث الصفحة لإعادة المحاولة.';

  @override
  String get wishlistCatalogEmptyTitle => 'لا توجد مظاهر بعد';

  @override
  String wishlistCatalogInWishlist(String count) {
    return 'في قائمة الأمنيات: $count';
  }

  @override
  String get wishlistCatalogSubtitle => 'المس ♡ لإضافة مظهر إلى قائمة الأمنيات';

  @override
  String get wishlistCatalogTitle => 'جميع المظاهر';

  @override
  String get wishlistChooseWeapon => 'اختيار السلاح';

  @override
  String get wishlistClearFilters => 'مسح عوامل التصفية';

  @override
  String get wishlistEmpty =>
      'قائمة الأمنيات فارغة. المس ♡ على أي مظهر لإضافته.';

  @override
  String get wishlistEmptyTitle => 'لا توجد مظاهر بعد';

  @override
  String wishlistEndsIn(String time) {
    return 'ينتهي بعد $time';
  }

  @override
  String get wishlistExcludedRewards => 'لا تشمل مظاهر الجوائز';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString مظهر',
      many: '$countString مظهرًا',
      few: '$countString مظاهر',
      two: '$countString مظهر',
      one: '$countString مظهر',
      zero: '$countString مظهر',
    );
    return 'حسب التصفية: $_temp0 · $value';
  }

  @override
  String get wishlistNoMatch =>
      'لا توجد مظاهر مطابقة. امسح عوامل التصفية لعرض المزيد.';

  @override
  String get wishlistNoMatchTitle => 'لم يتم العثور على مظاهر';

  @override
  String get wishlistNotifBundleTitle =>
      'باقة جديدة تضم مظهرًا من قائمة الأمنيات';

  @override
  String get wishlistNotifDailyTitle => 'ظهر مظهر من قائمة الأمنيات!';

  @override
  String get wishlistNotifNightMarketTitle => 'في سوقك الليلي مظهر تريده!';

  @override
  String get wishlistNotifPermissionMissing =>
      'لا يملك التطبيق إذنًا بإرسال الإشعارات.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مظهر من قائمة الأمنيات معروض للبيع!',
      many: '$count مظهرًا من قائمة الأمنيات معروضة للبيع!',
      few: '$count مظاهر من قائمة الأمنيات معروضة للبيع!',
      two: '$count مظهران من قائمة الأمنيات معروضان للبيع!',
      one: '$count مظهر من قائمة الأمنيات معروض للبيع!',
      zero: '$count مظهر من قائمة الأمنيات معروض للبيع!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistNotifToggle => 'إشعارات قائمة الأمنيات';

  @override
  String get wishlistNotifToggleSubtitle =>
      'لهذا الحساب، حتى عندما يكون التطبيق مغلقًا';

  @override
  String wishlistOfAccount(String riotId) {
    return 'قائمة أمنيات $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count مظهر من قائمة الأمنيات معروض للبيع!',
      many: '$count مظهرًا من قائمة الأمنيات معروضة للبيع!',
      few: '$count مظاهر من قائمة الأمنيات معروضة للبيع!',
      two: '$count مظهران من قائمة الأمنيات معروضان للبيع!',
      one: 'مظهر من قائمة الأمنيات معروض للبيع!',
      zero: '$count مظهر من قائمة الأمنيات معروض للبيع!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint => 'المس صفًا مميزًا لعرض العرض.';

  @override
  String get wishlistOpenSettings => 'فتح الإعدادات';

  @override
  String get wishlistOwned => 'مملوك';

  @override
  String get wishlistRemoveAction => 'إزالة من قائمة الأمنيات';

  @override
  String get wishlistRemoveFromWishlist => 'إزالة من قائمة الأمنيات';

  @override
  String wishlistRemoved(String name) {
    return 'تمت إزالة $name من قائمة الأمنيات';
  }

  @override
  String get wishlistSearchHint => 'ابحث عن المظاهر…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$countString مظهر',
      many: '$countString مظهرًا',
      few: '$countString مظاهر',
      two: '$countString مظهر',
      one: '$countString مظهر',
      zero: '$countString مظهر',
    );
    return '$_temp0';
  }

  @override
  String get wishlistSortName => 'الاسم';

  @override
  String get wishlistSortPrice => 'السعر';

  @override
  String get wishlistSortRarity => 'الندرة';

  @override
  String get wishlistSortWeapon => 'السلاح';

  @override
  String get wishlistTitle => 'قائمة الأمنيات';

  @override
  String get wishlistTotalValue => 'إجمالي قيمة قائمة الأمنيات';

  @override
  String get wishlistUndo => 'تراجع';

  @override
  String get wishlistViewInStore => 'عرض في المتجر';

  @override
  String get wishlistWeapon => 'السلاح';

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
      'yes': '، في قائمة الأمنيات',
      'other': '',
    });
    return '$name، $price، $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': '، في قائمة الأمنيات',
      'other': '',
    });
    return '$name، $votes$_temp0';
  }

  @override
  String homeTodayRankAccessibility(
    String direction,
    int rr,
    int wins,
    int losses,
  ) {
    String _temp0 = intl.Intl.selectLogic(direction, {
      'gain': 'ارتفاع',
      'other': 'انخفاض',
    });
    String _temp1 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins انتصار',
      many: '$wins انتصارًا',
      few: '$wins انتصارات',
      two: '$wins انتصاران',
      one: '$wins انتصار',
      zero: '$wins انتصار',
    );
    String _temp2 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses خسارة',
      many: '$losses خسارة',
      few: '$losses خسارات',
      two: '$losses خسارتان',
      one: '$losses خسارة',
      zero: '$losses خسارة',
    );
    return 'اليوم $_temp0 $rr RR، $_temp1، $_temp2';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      wins,
      locale: localeName,
      other: '$wins انتصار',
      many: '$wins انتصارًا',
      few: '$wins انتصارات',
      two: '$wins انتصاران',
      one: '$wins انتصار',
      zero: '$wins انتصار',
    );
    String _temp1 = intl.Intl.pluralLogic(
      losses,
      locale: localeName,
      other: '$losses خسارة',
      many: '$losses خسارة',
      few: '$losses خسارات',
      two: '$losses خسارتان',
      one: '$losses خسارة',
      zero: '$losses خسارة',
    );
    String _temp2 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: '، $draws تعادل',
      many: '، $draws تعادلًا',
      few: '، $draws تعادلات',
      two: '، $draws تعادلان',
      one: '، $draws تعادل',
      zero: '',
    );
    String _temp3 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: '، $unknown مباراة نتيجتها غير معروفة',
      many: '، $unknown مباراة نتيجتها غير معروفة',
      few: '، $unknown مباريات نتيجتها غير معروفة',
      two: '، $unknown مباراتان نتيجتهما غير معروفة',
      one: '، $unknown مباراة نتيجتها غير معروفة',
      zero: '',
    );
    return '$_temp0 – $_temp1$_temp2$_temp3';
  }

  @override
  String get homeAllHiddenBody => 'افتح تخصيص الرئيسية لإظهارها مجددًا.';

  @override
  String get homeAllHiddenTitle => 'أخفيت جميع البطاقات';

  @override
  String get homeCardBattlePass => 'Battle Pass';

  @override
  String get homeCardBattlePassDesc =>
      'المستوى وXP المطلوب يوميًا والمهام الأسبوعية.';

  @override
  String get homeCardCommunity => 'المجتمع';

  @override
  String get homeCardCommunityDesc =>
      'ابحث عن زملاء في مستوى رتبتك وتعرّف على المظاهر الأكثر تفضيلًا لدى المجتمع.';

  @override
  String get homeCardFriends => 'أصدقاء يلعبون';

  @override
  String get homeCardFriendsDesc =>
      'الأصدقاء الموجودون في مباراة أو في قائمة الانتظار.';

  @override
  String homeCardHidden(String name) {
    return 'تم إخفاء \"$name\"';
  }

  @override
  String get homeCardLive => 'المباراة الحالية';

  @override
  String get homeCardLiveDesc =>
      'تظهر عندما تكون في قائمة الانتظار أو في اختيار العميل أو في مباراة.';

  @override
  String get homeCardOtherAccounts => 'حسابات أخرى';

  @override
  String get homeCardOtherAccountsDesc =>
      'حالة حساباتك الأخرى وقوائم أمنياتها.';

  @override
  String get homeCardRank => 'الرتبة والأداء';

  @override
  String get homeCardRankDesc =>
      'الرتبة وRR اليوم والسلاسل وعدد المباريات للترقية.';

  @override
  String get homeCardServerStatus => 'حالة الخادم';

  @override
  String get homeCardServerStatusDesc => 'تظهر فقط أثناء الصيانة أو الأعطال.';

  @override
  String get homeCardStore => 'متجر اليوم';

  @override
  String get homeCardStoreDesc =>
      'المظاهر اليومية وقائمة الأمنيات والسوق الليلي.';

  @override
  String get homeCustomize => 'تخصيص الرئيسية';

  @override
  String get homeCustomizeHint =>
      'اسحب لإعادة الترتيب. أوقف التشغيل لإخفاء بطاقة.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'تم الانتقال إلى $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name، $status';
  }

  @override
  String get homeFriendsConsentAllow => 'تفعيل';

  @override
  String get homeFriendsConsentBody =>
      'لمعرفة الأصدقاء الذين يلعبون، يتصل ValHub بدردشة Riot للحساب الحالي في كل مرة تفتح فيها الرئيسية. سيراك أصدقاؤك متصلًا. يمكنك إيقاف ذلك من تخصيص الرئيسية.';

  @override
  String get homeFriendsConsentDecline => 'لا، إخفاء البطاقة';

  @override
  String get homeFriendsConsentTitle => 'معرفة الأصدقاء الذين يلعبون؟';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n صديق يلعبون',
      many: '$n صديقًا يلعبون',
      few: '$n أصدقاء يلعبون',
      two: '$n صديقان يلعبان',
      one: '$n صديق يلعب',
      zero: '$n صديق يلعب',
    );
    return '$_temp0';
  }

  @override
  String get homeFriendsSeeAll => 'عرض الكل';

  @override
  String get homeHideCard => 'إخفاء هذه البطاقة';

  @override
  String homeLeaderboard(String pos) {
    return 'المركز #$pos في لوحة المتصدرين';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'متبقٍّ $time';
  }

  @override
  String homeLfgNeeds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'مطلوب $n لاعب',
      many: 'مطلوب $n لاعبًا',
      few: 'مطلوب $n لاعبين',
      two: 'مطلوب $n لاعبان',
      one: 'مطلوب $n لاعب',
      zero: 'مطلوب $n لاعب',
    );
    return '$_temp0';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author، $details';
  }

  @override
  String get homeLfgTitle => 'ابحث عن زملاء في مستوى رتبتك';

  @override
  String get homeLiveAllyLabel => 'فريقك';

  @override
  String get homeLiveEnemyLabel => 'الفريق الخصم';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'في قائمة الانتظار، مدة الانتظار $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'فريقك $ally، الفريق الخصم $enemy';
  }

  @override
  String homeLossStreak(int n) {
    return 'سلسلة خسارات في التنافسي: $n';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '≈ $n مباراة للوصول إلى $rank',
      many: '≈ $n مباراة للوصول إلى $rank',
      few: '≈ $n مباريات للوصول إلى $rank',
      two: '≈ $n مباراتان للوصول إلى $rank',
      one: '≈ $n مباراة للوصول إلى $rank',
      zero: '≈ $n مباراة للوصول إلى $rank',
    );
    return '$_temp0';
  }

  @override
  String homeMoreActions(String name) {
    return 'خيارات $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'سجّل الدخول مجددًا لتحديث المتجر والرتبة وBattle Pass الخاصة بـ $riotId. لا يزال بإمكانك عرض النسخة المحفوظة على جهازك.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'متبقٍّ $time';
  }

  @override
  String get homeNightMarketNew => 'جديد';

  @override
  String get homeNightMarketTitle => 'السوق الليلي';

  @override
  String homeNightMarketWaiting(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n عرض بانتظار أن تقلبها',
      many: '$n عرضًا بانتظار أن تقلبها',
      few: '$n عروض بانتظار أن تقلبها',
      two: '$n عرضان بانتظار أن تقلبهما',
      one: '$n عرض بانتظار أن تقلبه',
      zero: '$n عرض بانتظار أن تقلبه',
    );
    return '$_temp0';
  }

  @override
  String get homeNoRankedToday => 'لا توجد مباريات تنافسية اليوم';

  @override
  String get homeOpenLfg => 'عرض كل منشورات البحث عن زملاء';

  @override
  String get homeOpenRanking => 'عرض ترتيب المظاهر';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'حسابات أخرى ($n)';
  }

  @override
  String homeOtherMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n حساب',
      many: '+$n حسابًا',
      few: '+$n حسابات',
      two: '+$n حسابان',
      one: '+$n حساب',
      zero: '+$n حساب',
    );
    return '$_temp0';
  }

  @override
  String get homeOtherWishlistHit => 'مظهر من قائمة الأمنيات متوفر';

  @override
  String homePreviousAct(String rank) {
    return 'المشهد السابق: $rank';
  }

  @override
  String get homeQuietBody => 'اسحب للأسفل للتحديث.';

  @override
  String get homeQuietTitle => 'لا جديد بعد';

  @override
  String homeRankToNext(int rr) {
    return 'متبقٍّ $rr RR للترقية';
  }

  @override
  String get homeResetLayout => 'استعادة الافتراضي';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'اليوم $value';
  }

  @override
  String get homeStatusDetails => 'التفاصيل';

  @override
  String homeStatusIncident(String region) {
    return 'عطل في الخادم · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'قيد الصيانة · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'صيانة قادمة · $region';
  }

  @override
  String homeStatusMore(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '+$n إشعار',
      many: '+$n إشعارًا',
      few: '+$n إشعارات',
      two: '+$n إشعاران',
      one: '+$n إشعار',
      zero: '+$n إشعار',
    );
    return '$_temp0';
  }

  @override
  String get homeStoreRefreshing => 'جارٍ التحديث…';

  @override
  String homeStoreResetsIn(String time) {
    return 'التجديد بعد $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'الإجمالي $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'المحفظة $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مظهر كحد أقصى',
      many: '$n مظهرًا كحد أقصى',
      few: '$n مظاهر كحد أقصى',
      two: '$n مظهرين كحد أقصى',
      one: '$n مظهر كحد أقصى',
      zero: '$n مظهر كحد أقصى',
    );
    return 'المحفظة $vp · تكفي لشراء $_temp0';
  }

  @override
  String get homeStoreWishlistHit => 'مظهر من قائمة الأمنيات في المتجر!';

  @override
  String homeStoreWishlistHits(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n مظهر من قائمة الأمنيات معروض للبيع',
      many: '$n مظهرًا من قائمة الأمنيات معروضة للبيع',
      few: '$n مظاهر من قائمة الأمنيات معروضة للبيع',
      two: '$n مظهران من قائمة الأمنيات معروضان للبيع',
      one: '$n مظهر من قائمة الأمنيات معروض للبيع',
      zero: '$n مظهر من قائمة الأمنيات معروض للبيع',
    );
    return '$_temp0';
  }

  @override
  String get homeTitle => 'الرئيسية';

  @override
  String get homeTrendingTitle => 'المظاهر الأكثر تفضيلًا عالميًا';

  @override
  String homeTrendingVotes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n إعجاب',
      many: '$n إعجابًا',
      few: '$n إعجابات',
      two: '$n إعجابان',
      one: '$n إعجاب',
      zero: '$n إعجاب',
    );
    return '$_temp0';
  }

  @override
  String get homeUndo => 'تراجع';

  @override
  String homeWinStreak(int n) {
    return 'سلسلة انتصارات في التنافسي: $n';
  }

  @override
  String get homeStoreOutdated =>
      'تم تحديث المتجر. لم يتمكن ValHub بعد من تحميل المتجر الجديد.';

  @override
  String get communityErrorConsent =>
      'وافق على مشاركة Riot ID مع المجتمع للمتابعة.';

  @override
  String get communityErrorForbidden =>
      'لا يمكنك القيام بذلك بعد. راجع إرشادات المجتمع أو تواصل مع ValHub.';

  @override
  String get communityErrorGeneric => 'حدث خطأ ما. يُرجى المحاولة مجددًا.';

  @override
  String get communityErrorImageTooLarge =>
      'الصورة كبيرة جدًا (الحد الأقصى 2 ميغابايت). اختر صورة أخرى.';

  @override
  String get communityErrorImageType => 'اختر صورة بتنسيق JPEG أو PNG أو WebP.';

  @override
  String get communityErrorInvalid => 'لم يُقبل المحتوى. راجعه وحاول مجددًا.';

  @override
  String get communityErrorNetwork =>
      'تعذّر الاتصال بمجتمع ValHub. يُرجى التحقق من الاتصال والمحاولة مجددًا.';

  @override
  String get communityErrorNotFound => 'هذا المحتوى لم يعد موجودًا.';

  @override
  String get communityErrorPickImage =>
      'تعذّر فتح مكتبة الصور. يُرجى المحاولة مجددًا.';

  @override
  String get communityErrorRateLimited =>
      'يتلقى المجتمع طلبات كثيرة جدًا. يُرجى المحاولة بعد بضع دقائق.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'يتلقى المجتمع طلبات كثيرة جدًا. يُرجى المحاولة بعد $duration.';
  }

  @override
  String get communityErrorRiotRejected =>
      'تعذّر على Riot التحقق من حسابك. سجّل الدخول إلى حساب Riot مجددًا ثم حاول مرة أخرى.';

  @override
  String get communityErrorRiotUnavailable =>
      'تواجه Riot مشكلة حاليًا. يُرجى المحاولة بعد بضع دقائق.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'تواجه Riot مشكلة حاليًا. يُرجى المحاولة بعد $duration.';
  }

  @override
  String get communityErrorServer =>
      'يواجه مجتمع ValHub مشكلة. يُرجى المحاولة بعد بضع دقائق.';

  @override
  String get communityErrorStorageFull =>
      'مساحة صور المجتمع ممتلئة. لا يزال بإمكانك النشر، لكن لا يمكن إرفاق صور حاليًا. يُرجى المحاولة لاحقًا.';

  @override
  String get communityErrorTimeout =>
      'يستغرق مجتمع ValHub وقتًا طويلًا للرد. يُرجى المحاولة مجددًا.';

  @override
  String get communityErrorTitle => 'تعذّر الإكمال';

  @override
  String get communityErrorUnauthorized =>
      'انتهت صلاحية اتصالك بالمجتمع. يُرجى المحاولة مجددًا.';

  @override
  String get communityErrorImageQuota =>
      'لقد استهلكت مساحة تخزين الصور بالكامل. احذف بعض المنشورات التي تحتوي على صور ثم حاول مرة أخرى.';

  @override
  String get smokePlain => 'فحص توليد الشيفرة';

  @override
  String smokeGreeting(String name) {
    return 'مرحبًا، $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n عنصر',
      many: '$n عنصرًا',
      few: '$n عناصر',
      two: '$n عنصران',
      one: '$n عنصر',
      zero: '$n عنصر',
    );
    return '$_temp0';
  }
}
