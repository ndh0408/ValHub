import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_id.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pl.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_th.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('es', 'MX'),
    Locale('fr'),
    Locale('id'),
    Locale('it'),
    Locale('ja'),
    Locale('ko'),
    Locale('pl'),
    Locale('pt'),
    Locale('ru'),
    Locale('th'),
    Locale('tr'),
    Locale('vi'),
    Locale('zh'),
    Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
  ];

  /// Separator between item names in a localized list.
  ///
  /// In vi, this message translates to:
  /// **', '**
  String get commonListSeparator;

  /// Source link label for a VP price table; preserves the legacy text without an unused URL placeholder.
  ///
  /// In vi, this message translates to:
  /// **'Xem nguồn bảng giá'**
  String get commonPriceSourceLabel;

  /// Safe fallback for Riot API failures. HTTP status stays in the error data, not the player copy.
  ///
  /// In vi, this message translates to:
  /// **'Riot đang gặp trục trặc. Hãy thử lại sau ít phút.'**
  String get commonErrorApi;

  /// CommonStrings.appName —
  ///
  /// In vi, this message translates to:
  /// **'ValHub'**
  String get commonAppName;

  /// CommonStrings.cancel — Actions
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get commonCancel;

  /// CommonStrings.clearFilters — Actions
  ///
  /// In vi, this message translates to:
  /// **'Bỏ lọc'**
  String get commonClearFilters;

  /// CommonStrings.clearSearch — Actions
  ///
  /// In vi, this message translates to:
  /// **'Xóa tìm kiếm'**
  String get commonClearSearch;

  /// CommonStrings.close — Actions
  ///
  /// In vi, this message translates to:
  /// **'Đóng'**
  String get commonClose;

  /// CommonStrings.copied — States
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép'**
  String get commonCopied;

  /// CommonStrings.dash — States
  ///
  /// In vi, this message translates to:
  /// **'–'**
  String get commonDash;

  /// CommonStrings.days — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'{n} ngày'**
  String commonDays(int n);

  /// CommonStrings.daysAgo — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'{n} ngày trước'**
  String commonDaysAgo(int n);

  /// CommonStrings.delete — Actions
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get commonDelete;

  /// CommonStrings.emptyGeneric — States
  ///
  /// In vi, this message translates to:
  /// **'Chưa có gì ở đây.'**
  String get commonEmptyGeneric;

  /// CommonStrings.errorContentUnavailable — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Không tải được thông tin skin, đặc vụ và bản đồ. Kiểm tra mạng rồi thử lại.'**
  String get commonErrorContentUnavailable;

  /// CommonStrings.errorGeneric — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Có gì đó trục trặc. Hãy thử lại.'**
  String get commonErrorGeneric;

  /// CommonStrings.errorMaintenance — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Máy chủ VALORANT đang bảo trì. Hãy quay lại sau.'**
  String get commonErrorMaintenance;

  /// CommonStrings.errorNeedsLogin — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập Riot của bạn đã hết hạn. Hãy đăng nhập lại để tiếp tục.'**
  String get commonErrorNeedsLogin;

  /// CommonStrings.errorNeedsLoginTitle — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Cần đăng nhập lại'**
  String get commonErrorNeedsLoginTitle;

  /// CommonStrings.errorNetwork — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Không kết nối được mạng. Kiểm tra Wi-Fi hoặc dữ liệu di động rồi thử lại.'**
  String get commonErrorNetwork;

  /// CommonStrings.errorNoAccount — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa đăng nhập tài khoản nào.'**
  String get commonErrorNoAccount;

  /// CommonStrings.errorNotFound — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy nội dung này.'**
  String get commonErrorNotFound;

  /// CommonStrings.errorTimeout — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Riot phản hồi quá lâu. Kiểm tra kết nối rồi thử lại.'**
  String get commonErrorTimeout;

  /// CommonStrings.errorTransient — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Riot đang bận. Hãy thử lại sau ít phút.'**
  String get commonErrorTransient;

  /// CommonStrings.errorTransientRetryIn — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Riot đang bận. Hãy thử lại sau {duration}.'**
  String commonErrorTransientRetryIn(String duration);

  /// CommonStrings.errorUnsupportedRegion — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác định được khu vực Riot. Hãy chọn khu vực trong Cài đặt.'**
  String get commonErrorUnsupportedRegion;

  /// CommonStrings.estimatePrefix — States
  ///
  /// In vi, this message translates to:
  /// **'≈'**
  String get commonEstimatePrefix;

  /// CommonStrings.goHome — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Về Trang chủ'**
  String get commonGoHome;

  /// CommonStrings.hours — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'{n} giờ'**
  String commonHours(int n);

  /// CommonStrings.hoursAgo — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'{n} giờ trước'**
  String commonHoursAgo(int n);

  /// CommonStrings.incidentTitle — Maintenance banner
  ///
  /// In vi, this message translates to:
  /// **'Sự cố máy chủ'**
  String get commonIncidentTitle;

  /// CommonStrings.justNow — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'vừa xong'**
  String get commonJustNow;

  /// CommonStrings.loadMore — Actions
  ///
  /// In vi, this message translates to:
  /// **'Tải thêm'**
  String get commonLoadMore;

  /// CommonStrings.loading — States
  ///
  /// In vi, this message translates to:
  /// **'Đang tải…'**
  String get commonLoading;

  /// CommonStrings.maintenanceTitle — Maintenance banner
  ///
  /// In vi, this message translates to:
  /// **'Bảo trì máy chủ'**
  String get commonMaintenanceTitle;

  /// CommonStrings.minutes — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'{n} phút'**
  String commonMinutes(int n);

  /// CommonStrings.minutesAgo — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'{n} phút trước'**
  String commonMinutesAgo(int n);

  /// CommonStrings.noData — States
  ///
  /// In vi, this message translates to:
  /// **'Chưa có gì để xem'**
  String get commonNoData;

  /// "Không có mạng — đang hiển thị bản đã lưu (14:05)."
  ///
  /// In vi, this message translates to:
  /// **'Không có mạng — đang hiển thị bản đã lưu ({time}).'**
  String commonOfflineCached(String time);

  /// CommonStrings.openSettings — Actions
  ///
  /// In vi, this message translates to:
  /// **'Mở cài đặt'**
  String get commonOpenSettings;

  /// CommonStrings.pageNotFound — status code (docs/design/VOICE.md §5.1).
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy màn hình này.'**
  String get commonPageNotFound;

  /// CommonStrings.priceBestPack — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Gói có lợi nhất: {vp} = {price}'**
  String commonPriceBestPack(String vp, String price);

  /// CommonStrings.priceEditOwn — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Sửa giá bạn đã nhập'**
  String get commonPriceEditOwn;

  /// CommonStrings.priceEnterOwn — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Nhập giá gói VP của bạn'**
  String get commonPriceEnterOwn;

  /// CommonStrings.priceEstimateBody — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Số tiền “≈ …” cạnh giá VP là ước tính, quy đổi theo gói VP có lợi nhất. Bạn trả bằng VP trong game; số tiền thật tùy gói nạp, kênh thanh toán, thuế và khuyến mãi lúc bạn mua.'**
  String get commonPriceEstimateBody;

  /// CommonStrings.priceEstimateTitle — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Giá quy đổi ước tính'**
  String get commonPriceEstimateTitle;

  /// CommonStrings.priceEstimateTooltip — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Giá ước tính — chạm để xem cách tính'**
  String get commonPriceEstimateTooltip;

  /// CommonStrings.priceHidden — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Đã ẩn giá quy đổi. Bật lại trong Cài đặt.'**
  String get commonPriceHidden;

  /// CommonStrings.priceHide — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Ẩn giá quy đổi'**
  String get commonPriceHide;

  /// CommonStrings.priceOpenSource — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Mở trang nguồn'**
  String get commonPriceOpenSource;

  /// CommonStrings.priceOverrideBody — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Nhập số tiền bạn thực trả cho một gói VP (xem trong cửa hàng của game hoặc hóa đơn). ValHub dùng giá này để ước tính giá quy đổi cho mọi món đồ; giá chỉ lưu trên thiết bị này.'**
  String get commonPriceOverrideBody;

  /// CommonStrings.priceOverrideCurrency — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Mã tiền tệ'**
  String get commonPriceOverrideCurrency;

  /// CommonStrings.priceOverrideCurrencyHint — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: VND, USD, EUR, JPY'**
  String get commonPriceOverrideCurrencyHint;

  /// CommonStrings.priceOverrideExample — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ ước tính: {vp} ≈ {price}'**
  String commonPriceOverrideExample(String vp, String price);

  /// CommonStrings.priceOverrideInvalidCurrency — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã tiền tệ gồm 3 chữ cái, ví dụ VND hoặc USD.'**
  String get commonPriceOverrideInvalidCurrency;

  /// CommonStrings.priceOverrideInvalidNumber — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Nhập một số lớn hơn 0.'**
  String get commonPriceOverrideInvalidNumber;

  /// CommonStrings.priceOverridePrice — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Giá gói'**
  String get commonPriceOverridePrice;

  /// CommonStrings.priceOverrideRemove — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Xóa giá đã nhập'**
  String get commonPriceOverrideRemove;

  /// CommonStrings.priceOverrideRemoved — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa giá bạn nhập.'**
  String get commonPriceOverrideRemoved;

  /// CommonStrings.priceOverrideSave — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Lưu giá'**
  String get commonPriceOverrideSave;

  /// CommonStrings.priceOverrideSaved — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu giá gói VP của bạn.'**
  String get commonPriceOverrideSaved;

  /// CommonStrings.priceOverrideTitle — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Giá gói VP của bạn'**
  String get commonPriceOverrideTitle;

  /// CommonStrings.priceOverrideVp — "Giá gói VP của bạn" editor
  ///
  /// In vi, this message translates to:
  /// **'Số VP của gói'**
  String get commonPriceOverrideVp;

  /// CommonStrings.pricePacksTitle — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Các gói VP'**
  String get commonPricePacksTitle;

  /// "Bảng giá chính thức ở khu vực VN" (ISO country code).
  ///
  /// In vi, this message translates to:
  /// **'Theo bảng giá gói VP ở khu vực {country}'**
  String commonPriceSourceOfficial(String country);

  /// CommonStrings.priceSourceUser — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Theo giá gói VP do bạn nhập'**
  String get commonPriceSourceUser;

  /// CommonStrings.priceUnavailable — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bảng giá đã xác minh cho khu vực của bạn. Nhập giá của một gói VP bạn từng mua để xem giá quy đổi ước tính.'**
  String get commonPriceUnavailable;

  /// CommonStrings.priceUpdated — Local price estimate next to VP prices (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật bảng giá: {date}'**
  String commonPriceUpdated(String date);

  /// CommonStrings.retry — Actions
  ///
  /// In vi, this message translates to:
  /// **'Thử lại'**
  String get commonRetry;

  /// CommonStrings.riotDisclaimer — Legal (VF §8.13)
  ///
  /// In vi, this message translates to:
  /// **'ValHub không được Riot Games xác nhận và không phản ánh quan điểm của Riot Games hay bất kỳ ai tham gia sản xuất hoặc quản lý các sản phẩm của Riot Games. Riot Games và mọi tài sản liên quan là thương hiệu hoặc thương hiệu đã đăng ký của Riot Games, Inc.'**
  String get commonRiotDisclaimer;

  /// CommonStrings.save — Actions
  ///
  /// In vi, this message translates to:
  /// **'Lưu'**
  String get commonSave;

  /// CommonStrings.search — Actions
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm…'**
  String get commonSearch;

  /// CommonStrings.seconds — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'{n} giây'**
  String commonSeconds(int n);

  /// CommonStrings.share — Actions
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ'**
  String get commonShare;

  /// CommonStrings.signInAgain — Actions
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập lại'**
  String get commonSignInAgain;

  /// CommonStrings.sort — Actions
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp'**
  String get commonSort;

  /// "Sắp xếp: Độ hiếm" (sort button label).
  ///
  /// In vi, this message translates to:
  /// **'Sắp xếp: {option}'**
  String commonSortBy(String option);

  /// CommonStrings.tabBattlePass — Navigation (VF §8.1)
  ///
  /// In vi, this message translates to:
  /// **'Battle Pass'**
  String get commonTabBattlePass;

  /// CommonStrings.tabCollection — Navigation (VF §8.1)
  ///
  /// In vi, this message translates to:
  /// **'Bộ sưu tập'**
  String get commonTabCollection;

  /// CommonStrings.tabCommunity — Navigation (VF §8.1)
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng'**
  String get commonTabCommunity;

  /// CommonStrings.tabHome — Navigation (VF §8.1)
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get commonTabHome;

  /// CommonStrings.tabProfile — Navigation (VF §8.1)
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get commonTabProfile;

  /// CommonStrings.tabSettings — Navigation (VF §8.1)
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get commonTabSettings;

  /// CommonStrings.tabStore — Navigation (VF §8.1)
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng'**
  String get commonTabStore;

  /// CommonStrings.tagline —
  ///
  /// In vi, this message translates to:
  /// **'Trợ thủ VALORANT của bạn'**
  String get commonTagline;

  /// CommonStrings.today — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay'**
  String get commonToday;

  /// CommonStrings.todayLower — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'hôm nay'**
  String get commonTodayLower;

  /// CommonStrings.tomorrow — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'ngày mai'**
  String get commonTomorrow;

  /// CommonStrings.unknownItem — States
  ///
  /// In vi, this message translates to:
  /// **'Vật phẩm chưa rõ tên'**
  String get commonUnknownItem;

  /// "Cập nhật lúc 14:05" (the time part is already formatted).
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật lúc {time}'**
  String commonUpdatedAt(String time);

  /// "07:00 hôm nay" / "07:00 ngày mai" / "23:59 thứ Hai 06/10".
  ///
  /// In vi, this message translates to:
  /// **'{time} {day}'**
  String commonWallTime(String time, String day);

  /// Monday … Sunday, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Hai'**
  String get commonWeekdaysItem0;

  /// Monday … Sunday, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Ba'**
  String get commonWeekdaysItem1;

  /// Monday … Sunday, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Tư'**
  String get commonWeekdaysItem2;

  /// Monday … Sunday, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Năm'**
  String get commonWeekdaysItem3;

  /// Monday … Sunday, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Sáu'**
  String get commonWeekdaysItem4;

  /// Monday … Sunday, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'Thứ Bảy'**
  String get commonWeekdaysItem5;

  /// Monday … Sunday, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'Chủ Nhật'**
  String get commonWeekdaysItem6;

  /// CommonStrings.yesterday — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'hôm qua'**
  String get commonYesterday;

  /// CommonStrings.yesterdayTitle — Time (VF §8.0 rule 7)
  ///
  /// In vi, this message translates to:
  /// **'Hôm qua'**
  String get commonYesterdayTitle;

  /// Strip above store / Battle Pass data shown from the saved copy because the Riot sign-in expired (next to an "Đăng nhập lại" button). {time} is "14:05" or "14:05, 06/10".
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập Riot đã hết hạn — đang hiển thị bản đã lưu ({time}).'**
  String commonSavedCopyNeedsLogin(String time);

  /// ContentStrings.categoryHeavy — Weapon categories keyed by `EEquippableCategory::*` (VF §8.6)
  ///
  /// In vi, this message translates to:
  /// **'Vũ khí hạng nặng'**
  String get contentCategoryHeavy;

  /// ContentStrings.categoryMelee — Weapon categories keyed by `EEquippableCategory::*` (VF §8.6)
  ///
  /// In vi, this message translates to:
  /// **'Cận chiến'**
  String get contentCategoryMelee;

  /// ContentStrings.categoryRifle — Weapon categories keyed by `EEquippableCategory::*` (VF §8.6)
  ///
  /// In vi, this message translates to:
  /// **'Súng trường'**
  String get contentCategoryRifle;

  /// ContentStrings.categoryShotgun — Weapon categories keyed by `EEquippableCategory::*` (VF §8.6)
  ///
  /// In vi, this message translates to:
  /// **'Shotgun'**
  String get contentCategoryShotgun;

  /// ContentStrings.categorySidearm — Weapon categories keyed by `EEquippableCategory::*` (VF §8.6)
  ///
  /// In vi, this message translates to:
  /// **'Súng phụ'**
  String get contentCategorySidearm;

  /// ContentStrings.categorySmg — Weapon categories keyed by `EEquippableCategory::*` (VF §8.6)
  ///
  /// In vi, this message translates to:
  /// **'SMG'**
  String get contentCategorySmg;

  /// ContentStrings.categorySniper — Weapon categories keyed by `EEquippableCategory::*` (VF §8.6)
  ///
  /// In vi, this message translates to:
  /// **'Súng bắn tỉa'**
  String get contentCategorySniper;

  /// ContentStrings.currencyAgentTokens — Currencies (VF §8.3). valorant-api's vi names are re-cased English.
  ///
  /// In vi, this message translates to:
  /// **'Huy hiệu đặc vụ'**
  String get contentCurrencyAgentTokens;

  /// ContentStrings.currencyKc — Currencies (VF §8.3). valorant-api's vi names are re-cased English.
  ///
  /// In vi, this message translates to:
  /// **'KC'**
  String get contentCurrencyKc;

  /// ContentStrings.currencyKcFull — Currencies (VF §8.3). valorant-api's vi names are re-cased English.
  ///
  /// In vi, this message translates to:
  /// **'Kingdom Credit'**
  String get contentCurrencyKcFull;

  /// ContentStrings.currencyRp — Currencies (VF §8.3). valorant-api's vi names are re-cased English.
  ///
  /// In vi, this message translates to:
  /// **'RP'**
  String get contentCurrencyRp;

  /// ContentStrings.currencyRpFull — Currencies (VF §8.3). valorant-api's vi names are re-cased English.
  ///
  /// In vi, this message translates to:
  /// **'Radianite'**
  String get contentCurrencyRpFull;

  /// ContentStrings.currencyVp — Currencies (VF §8.3). valorant-api's vi names are re-cased English.
  ///
  /// In vi, this message translates to:
  /// **'VP'**
  String get contentCurrencyVp;

  /// ContentStrings.currencyVpFull — Currencies (VF §8.3). valorant-api's vi names are re-cased English.
  ///
  /// In vi, this message translates to:
  /// **'VALORANT Point'**
  String get contentCurrencyVpFull;

  /// ContentStrings.itemAgent — Item types (VF §8.2)
  ///
  /// In vi, this message translates to:
  /// **'Đặc vụ'**
  String get contentItemAgent;

  /// ContentStrings.itemBuddy — Item types (VF §8.2)
  ///
  /// In vi, this message translates to:
  /// **'Phụ kiện súng'**
  String get contentItemBuddy;

  /// ContentStrings.itemCard — Item types (VF §8.2)
  ///
  /// In vi, this message translates to:
  /// **'Thẻ người chơi'**
  String get contentItemCard;

  /// ContentStrings.itemChroma — Item types (VF §8.2)
  ///
  /// In vi, this message translates to:
  /// **'Biến thể'**
  String get contentItemChroma;

  /// ContentStrings.itemContract — Item types (VF §8.2)
  ///
  /// In vi, this message translates to:
  /// **'Hợp đồng'**
  String get contentItemContract;

  /// ContentStrings.itemCurrency — Item types (VF §8.2)
  ///
  /// In vi, this message translates to:
  /// **'Tiền tệ'**
  String get contentItemCurrency;

  /// ContentStrings.itemFlex — Item types (VF §8.2)
  ///
  /// In vi, this message translates to:
  /// **'Flex'**
  String get contentItemFlex;

  /// ContentStrings.itemSkin — Item types (VF §8.2)
  ///
  /// In vi, this message translates to:
  /// **'Skin'**
  String get contentItemSkin;

  /// ContentStrings.itemSpray — Item types (VF §8.2)
  ///
  /// In vi, this message translates to:
  /// **'Hình phun sơn'**
  String get contentItemSpray;

  /// ContentStrings.itemTitle — Item types (VF §8.2)
  ///
  /// In vi, this message translates to:
  /// **'Danh hiệu'**
  String get contentItemTitle;

  /// ContentStrings.level — Defaults / placeholders
  ///
  /// In vi, this message translates to:
  /// **'Cấp {n}'**
  String contentLevel(int n);

  /// ContentStrings.levelBase — Defaults / placeholders
  ///
  /// In vi, this message translates to:
  /// **'Cơ bản'**
  String get contentLevelBase;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Hiệu ứng hình ảnh'**
  String get contentLevelItemLabelsVFX;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Hoạt ảnh'**
  String get contentLevelItemLabelsAnimation;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Đòn kết liễu'**
  String get contentLevelItemLabelsFinisher;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Bộ đếm hạ gục'**
  String get contentLevelItemLabelsKillCounter;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Hiệu ứng âm thanh'**
  String get contentLevelItemLabelsSoundEffects;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Biến hình'**
  String get contentLevelItemLabelsTransformation;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Biểu ngữ hạ gục'**
  String get contentLevelItemLabelsKillBanner;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Hiệu ứng hạ gục'**
  String get contentLevelItemLabelsKillEffect;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Hiệu ứng ngắm súng & hạ gục'**
  String get contentLevelItemLabelsInspectAndKill;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Lồng tiếng'**
  String get contentLevelItemLabelsVoiceover;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Đổi bài nhạc'**
  String get contentLevelItemLabelsSongShuffle;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Ngẫu nhiên hóa'**
  String get contentLevelItemLabelsRandomizer;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Đổi theo phe công/thủ'**
  String get contentLevelItemLabelsAttackerDefenderSwap;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Hiệu ứng top frag'**
  String get contentLevelItemLabelsTopFrag;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Cảm biến nhịp tim & bản đồ'**
  String get contentLevelItemLabelsHeartbeatAndMapSensor;

  /// ContentStrings.levelItemLabels — Skin level types keyed by `EEquippableSkinLevelItem::*` (VF §8.4)
  ///
  /// In vi, this message translates to:
  /// **'Hoạt ảnh cá'**
  String get contentLevelItemLabelsFishAnimation;

  /// ContentStrings.noTitle — Defaults / placeholders
  ///
  /// In vi, this message translates to:
  /// **'Không có danh hiệu'**
  String get contentNoTitle;

  /// ContentStrings.notForSale — Reward sources (C9, VF §8.3)
  ///
  /// In vi, this message translates to:
  /// **'Không bán'**
  String get contentNotForSale;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Thi đấu xếp hạng'**
  String get contentQueueNamesCompetitive;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Đấu thường'**
  String get contentQueueNamesUnrated;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Siêu Tốc'**
  String get contentQueueNamesSwiftplay;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Đặt Spike Nhanh'**
  String get contentQueueNamesSpikerush;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Sinh Tử'**
  String get contentQueueNamesDeathmatch;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Sinh Tử Đội'**
  String get contentQueueNamesHurm;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Tăng Tiến'**
  String get contentQueueNamesGgteam;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Nhân bản'**
  String get contentQueueNamesOnefa;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Premier'**
  String get contentQueueNamesPremier;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Chơi tự do'**
  String get contentQueueNamesCustom;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Chơi tự do'**
  String get contentQueueNames;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Knockout'**
  String get contentQueueNamesDodgeball;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Retake'**
  String get contentQueueNamesFortcollins;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Skirmish: 2v2'**
  String get contentQueueNamesSkirmish2v2;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Skirmish: Thăng Hoa 1v1'**
  String get contentQueueNamesSkirmishascension1v1;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Skirmish: Thăng Hoa 2v2'**
  String get contentQueueNamesSkirmishascension2v2;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Tất Cả Ngẫu Nhiên Một Khu Đặt Spike'**
  String get contentQueueNamesValaram;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Gauntlet: Glitched'**
  String get contentQueueNamesAbilitydraftarena;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Trận Chiến Cầu Tuyết'**
  String get contentQueueNamesSnowball;

  /// ContentStrings.queueNames — Queue names fallback (VF §8.9). Live labels come from /v1/gamemodes/queues.
  ///
  /// In vi, this message translates to:
  /// **'Summit'**
  String get contentQueueNamesNewmap;

  /// Short chip labels where the full queue name is too long (VF §8.9).
  ///
  /// In vi, this message translates to:
  /// **'Xếp hạng'**
  String get contentQueueShortNamesCompetitive;

  /// Short chip labels where the full queue name is too long (VF §8.9).
  ///
  /// In vi, this message translates to:
  /// **'Ngẫu nhiên 1 khu'**
  String get contentQueueShortNamesValaram;

  /// ContentStrings.rewardSourceAgent — Reward sources (C9, VF §8.3)
  ///
  /// In vi, this message translates to:
  /// **'Hợp đồng đặc vụ'**
  String get contentRewardSourceAgent;

  /// ContentStrings.rewardSourceBattlePass — Reward sources (C9, VF §8.3)
  ///
  /// In vi, this message translates to:
  /// **'Phần thưởng Battle Pass'**
  String get contentRewardSourceBattlePass;

  /// ContentStrings.rewardSourceEvent — Reward sources (C9, VF §8.3)
  ///
  /// In vi, this message translates to:
  /// **'Vé sự kiện'**
  String get contentRewardSourceEvent;

  /// ContentStrings.roleNames — Agent roles keyed by role uuid (SUMMARY §7.7)
  ///
  /// In vi, this message translates to:
  /// **'Đối đầu'**
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4;

  /// ContentStrings.roleNames — Agent roles keyed by role uuid (SUMMARY §7.7)
  ///
  /// In vi, this message translates to:
  /// **'Khởi tranh'**
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10;

  /// ContentStrings.roleNames — Agent roles keyed by role uuid (SUMMARY §7.7)
  ///
  /// In vi, this message translates to:
  /// **'Kiểm soát'**
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373;

  /// ContentStrings.roleNames — Agent roles keyed by role uuid (SUMMARY §7.7)
  ///
  /// In vi, this message translates to:
  /// **'Hộ vệ'**
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9;

  /// ContentStrings.tierDeluxe — Content tiers, short badge form (SUMMARY §7.3) and full form (VF §8.3).
  ///
  /// In vi, this message translates to:
  /// **'Sang Chảnh'**
  String get contentTierDeluxe;

  /// ContentStrings.tierExclusive — Content tiers, short badge form (SUMMARY §7.3) and full form (VF §8.3).
  ///
  /// In vi, this message translates to:
  /// **'Độc Quyền'**
  String get contentTierExclusive;

  /// ContentStrings.tierFull — Content tiers, short badge form (SUMMARY §7.3) and full form (VF §8.3).
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản {shortName}'**
  String contentTierFull(String shortName);

  /// ContentStrings.tierPremium — Content tiers, short badge form (SUMMARY §7.3) and full form (VF §8.3).
  ///
  /// In vi, this message translates to:
  /// **'Cao Cấp'**
  String get contentTierPremium;

  /// ContentStrings.tierSelect — Content tiers, short badge form (SUMMARY §7.3) and full form (VF §8.3).
  ///
  /// In vi, this message translates to:
  /// **'Tuyển Chọn'**
  String get contentTierSelect;

  /// ContentStrings.tierUltra — Content tiers, short badge form (SUMMARY §7.3) and full form (VF §8.3).
  ///
  /// In vi, this message translates to:
  /// **'Siêu Cấp'**
  String get contentTierUltra;

  /// ContentStrings.unranked — Defaults / placeholders
  ///
  /// In vi, this message translates to:
  /// **'Chưa xếp hạng'**
  String get contentUnranked;

  /// Generic metadata label resolved at render time: accountRegionUnknown
  ///
  /// In vi, this message translates to:
  /// **'Chưa rõ máy chủ'**
  String get accountRegionUnknown;

  /// Profile caption for the country returned by authenticated Riot identity; not the manual device country.
  ///
  /// In vi, this message translates to:
  /// **'Quốc gia tài khoản Riot: {country}'**
  String accountRiotCountry(String country);

  /// Profile country unavailable; never infer it from region, device location or language.
  ///
  /// In vi, this message translates to:
  /// **'Quốc gia tài khoản Riot: Chưa xác định'**
  String get accountRiotCountryUnknown;

  /// AccountStrings.accountsHeader —
  ///
  /// In vi, this message translates to:
  /// **'TÀI KHOẢN ({count}/{max})'**
  String accountAccountsHeader(int count, int max);

  /// AccountStrings.active —
  ///
  /// In vi, this message translates to:
  /// **'Đang dùng'**
  String get accountActive;

  /// AccountStrings.addAccount —
  ///
  /// In vi, this message translates to:
  /// **'Thêm tài khoản ({count}/{max})'**
  String accountAddAccount(int count, int max);

  /// AccountStrings.clearLocalData — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Xóa dữ liệu cục bộ'**
  String get accountClearLocalData;

  /// AccountStrings.clearLocalDataConfirm — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Xóa lịch sử, bộ trang bị đã lưu và dữ liệu của tài khoản đã đăng xuất trên thiết bị này?'**
  String get accountClearLocalDataConfirm;

  /// AccountStrings.clearRrHistory — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Xóa lịch sử RR'**
  String get accountClearRrHistory;

  /// AccountStrings.clearRrHistoryConfirm — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Xóa lịch sử RR của tài khoản đang chọn trên thiết bị này?'**
  String get accountClearRrHistoryConfirm;

  /// AccountStrings.copyPassword — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Sao chép mật khẩu'**
  String get accountCopyPassword;

  /// AccountStrings.copyUsername — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Sao chép tên đăng nhập'**
  String get accountCopyUsername;

  /// AccountStrings.deleteLoginNote — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Xóa thông tin'**
  String get accountDeleteLoginNote;

  /// AccountStrings.deleteLoginNoteConfirm — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Xóa tên đăng nhập và mật khẩu đã lưu của tài khoản này?'**
  String get accountDeleteLoginNoteConfirm;

  /// AccountStrings.hidePassword — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Ẩn mật khẩu'**
  String get accountHidePassword;

  /// AccountStrings.keepLocalData — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Giữ dữ liệu cục bộ'**
  String get accountKeepLocalData;

  /// AccountStrings.keepLocalDataHint — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Giữ wishlist, bộ trang bị và lịch sử trên thiết bị này'**
  String get accountKeepLocalDataHint;

  /// AccountStrings.levelShort —
  ///
  /// In vi, this message translates to:
  /// **'Cấp {level}'**
  String accountLevelShort(int level);

  /// AccountStrings.linkAccountMissing — Quick fill on the Riot login page
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản trong thông báo đã đăng xuất. Hãy đăng nhập lại rồi mở thông báo.'**
  String get accountLinkAccountMissing;

  /// AccountStrings.localDataCleared — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa dữ liệu cục bộ'**
  String get accountLocalDataCleared;

  /// AccountStrings.loginNote — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Thông tin đăng nhập'**
  String get accountLoginNote;

  /// AccountStrings.loginNoteDeleted — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa thông tin đăng nhập'**
  String get accountLoginNoteDeleted;

  /// AccountStrings.loginNoteHint — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Chỉ lưu trên thiết bị này, được khóa an toàn. Dùng để xem lại hoặc điền nhanh khi bạn đăng nhập lại.'**
  String get accountLoginNoteHint;

  /// AccountStrings.loginNoteLocked — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Mở khóa thông tin đăng nhập'**
  String get accountLoginNoteLocked;

  /// AccountStrings.loginNotePassword — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu'**
  String get accountLoginNotePassword;

  /// AccountStrings.loginNoteSaved — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu thông tin đăng nhập'**
  String get accountLoginNoteSaved;

  /// AccountStrings.loginNoteUsername — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Tên đăng nhập Riot'**
  String get accountLoginNoteUsername;

  /// AccountStrings.maxAccounts —
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt tối đa {max} tài khoản.'**
  String accountMaxAccounts(int max);

  /// AccountStrings.needsLogin —
  ///
  /// In vi, this message translates to:
  /// **'Cần đăng nhập lại'**
  String get accountNeedsLogin;

  /// AccountStrings.onlineCount — Live activity of each account in the lists (VF §8: online / offline)
  ///
  /// In vi, this message translates to:
  /// **'{count} đang trực tuyến'**
  String accountOnlineCount(int count);

  /// AccountStrings.platformPc — Platforms (A8)
  ///
  /// In vi, this message translates to:
  /// **'PC'**
  String get accountPlatformPc;

  /// AccountStrings.platformPlayStation — Platforms (A8)
  ///
  /// In vi, this message translates to:
  /// **'PlayStation'**
  String get accountPlatformPlayStation;

  /// AccountStrings.platformXbox — Platforms (A8)
  ///
  /// In vi, this message translates to:
  /// **'Xbox'**
  String get accountPlatformXbox;

  /// AccountStrings.quickFill — Quick fill on the Riot login page
  ///
  /// In vi, this message translates to:
  /// **'Điền tài khoản đã lưu'**
  String get accountQuickFill;

  /// AccountStrings.quickFillDone — Quick fill on the Riot login page
  ///
  /// In vi, this message translates to:
  /// **'Đã điền xong. Hãy bấm Đăng nhập.'**
  String get accountQuickFillDone;

  /// AccountStrings.quickFillNotReady — Quick fill on the Riot login page
  ///
  /// In vi, this message translates to:
  /// **'Trang đăng nhập chưa tải xong. Đợi một chút rồi thử lại.'**
  String get accountQuickFillNotReady;

  /// AccountStrings.quickFillSubtitle — Quick fill on the Riot login page
  ///
  /// In vi, this message translates to:
  /// **'Chọn tài khoản để điền vào trang đăng nhập Riot'**
  String get accountQuickFillSubtitle;

  /// AccountStrings.quickFillTitle — Quick fill on the Riot login page
  ///
  /// In vi, this message translates to:
  /// **'Điền tài khoản đã lưu'**
  String get accountQuickFillTitle;

  /// AccountStrings.regionAp — Regions (VF §8.12)
  ///
  /// In vi, this message translates to:
  /// **'Châu Á - Thái Bình Dương'**
  String get accountRegionAp;

  /// AccountStrings.regionBr — Regions (VF §8.12)
  ///
  /// In vi, this message translates to:
  /// **'Brazil'**
  String get accountRegionBr;

  /// AccountStrings.regionEu — Regions (VF §8.12)
  ///
  /// In vi, this message translates to:
  /// **'Châu Âu'**
  String get accountRegionEu;

  /// AccountStrings.regionKr — Regions (VF §8.12)
  ///
  /// In vi, this message translates to:
  /// **'Hàn Quốc'**
  String get accountRegionKr;

  /// AccountStrings.regionLatam — Regions (VF §8.12)
  ///
  /// In vi, this message translates to:
  /// **'Mỹ Latinh'**
  String get accountRegionLatam;

  /// AccountStrings.regionNa — Regions (VF §8.12)
  ///
  /// In vi, this message translates to:
  /// **'Bắc Mỹ'**
  String get accountRegionNa;

  /// AccountStrings.removeAccount —
  ///
  /// In vi, this message translates to:
  /// **'Xóa tài khoản'**
  String get accountRemoveAccount;

  /// AccountStrings.removeAccountConfirm —
  ///
  /// In vi, this message translates to:
  /// **'Xóa {account} khỏi thiết bị này? Bạn có thể chọn giữ dữ liệu đã lưu.'**
  String accountRemoveAccountConfirm(String account);

  /// AccountStrings.rrHistoryCleared — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa lịch sử RR'**
  String get accountRrHistoryCleared;

  /// AccountStrings.showPassword — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Hiện mật khẩu'**
  String get accountShowPassword;

  /// AccountStrings.signOutAll —
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất tất cả tài khoản'**
  String get accountSignOutAll;

  /// AccountStrings.signOutAllConfirm —
  ///
  /// In vi, this message translates to:
  /// **'Đăng xuất và xóa mọi tài khoản khỏi thiết bị này? Bạn có thể chọn giữ dữ liệu đã lưu.'**
  String get accountSignOutAllConfirm;

  /// AccountStrings.statusAgentSelect — Live activity of each account in the lists (VF §8: online / offline)
  ///
  /// In vi, this message translates to:
  /// **'Đang chọn đặc vụ'**
  String get accountStatusAgentSelect;

  /// AccountStrings.statusInMatch — Live activity of each account in the lists (VF §8: online / offline)
  ///
  /// In vi, this message translates to:
  /// **'Đang đấu'**
  String get accountStatusInMatch;

  /// AccountStrings.statusOffline — Live activity of each account in the lists (VF §8: online / offline)
  ///
  /// In vi, this message translates to:
  /// **'Ngoại tuyến'**
  String get accountStatusOffline;

  /// AccountStrings.statusOnline — Live activity of each account in the lists (VF §8: online / offline)
  ///
  /// In vi, this message translates to:
  /// **'Trực tuyến'**
  String get accountStatusOnline;

  /// AccountStrings.statusUnknown — Live activity of each account in the lists (VF §8: online / offline)
  ///
  /// In vi, this message translates to:
  /// **'Chưa rõ trạng thái'**
  String get accountStatusUnknown;

  /// AccountStrings.switchTo —
  ///
  /// In vi, this message translates to:
  /// **'Chuyển sang {account}'**
  String accountSwitchTo(String account);

  /// AccountStrings.switcherSubtitle —
  ///
  /// In vi, this message translates to:
  /// **'Chạm để chuyển tài khoản'**
  String get accountSwitcherSubtitle;

  /// AccountStrings.switcherTitle —
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get accountSwitcherTitle;

  /// "Tài khoản (3/10)" (sheet title).
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản ({count}/{max})'**
  String accountSwitcherTitleCount(int count, int max);

  /// AccountStrings.unknownPlayer — Quick fill on the Riot login page
  ///
  /// In vi, this message translates to:
  /// **'Người chơi'**
  String get accountUnknownPlayer;

  /// AccountStrings.unlockLoginNote — Login note: the user's own Riot username / password per account
  ///
  /// In vi, this message translates to:
  /// **'Xác thực để mở thông tin đăng nhập Riot'**
  String get accountUnlockLoginNote;

  /// Tooltip of the ⋮ button on an account row in Settings (opens: saved sign-in info, remove account).
  ///
  /// In vi, this message translates to:
  /// **'Tùy chọn cho {riotId}'**
  String accountMoreActions(String riotId);

  /// Action in the account ⋮ menu when no sign-in info is saved yet for that account (opens the note sheet).
  ///
  /// In vi, this message translates to:
  /// **'Lưu thông tin đăng nhập'**
  String get accountLoginNoteAdd;

  /// Subtitle of 'Xóa lịch sử RR' in Settings: it clears the RR history of the active account only.
  ///
  /// In vi, this message translates to:
  /// **'Chỉ tài khoản đang chọn'**
  String get accountClearRrHistorySubtitle;

  /// Subtitle of 'Xóa dữ liệu cục bộ' in Settings: what it clears (sign-ins, wishlists and settings stay).
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử, bộ trang bị đã lưu và dữ liệu của tài khoản đã đăng xuất'**
  String get accountClearLocalDataSubtitle;

  /// Login page: a saved login note could not be used because the device unlock (biometrics / screen lock) failed or no screen lock is set.
  ///
  /// In vi, this message translates to:
  /// **'Cần mở khóa bằng vân tay, khuôn mặt hoặc mã máy để dùng tài khoản đã lưu. Nếu máy chưa đặt khóa màn hình, hãy đặt rồi thử lại.'**
  String get accountQuickFillLocked;

  /// AuthStrings.addAsNew —
  ///
  /// In vi, this message translates to:
  /// **'Thêm tài khoản mới'**
  String get authAddAsNew;

  /// AuthStrings.differentAccountBody —
  ///
  /// In vi, this message translates to:
  /// **'Bạn vừa đăng nhập một tài khoản khác với tài khoản cần đăng nhập lại. Thêm tài khoản này như một tài khoản mới?'**
  String get authDifferentAccountBody;

  /// AuthStrings.differentAccountTitle —
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản khác'**
  String get authDifferentAccountTitle;

  /// AuthStrings.loadingAccount —
  ///
  /// In vi, this message translates to:
  /// **'Đang tải tài khoản…'**
  String get authLoadingAccount;

  /// AuthStrings.loginCancelledByRiot —
  ///
  /// In vi, this message translates to:
  /// **'Riot đã từ chối lần đăng nhập này. Hãy thử lại.'**
  String get authLoginCancelledByRiot;

  /// AuthStrings.loginFailed —
  ///
  /// In vi, this message translates to:
  /// **'Không thể hoàn tất đăng nhập'**
  String get authLoginFailed;

  /// AuthStrings.loginFailedBody —
  ///
  /// In vi, this message translates to:
  /// **'Riot chưa xác nhận đăng nhập của bạn. Hãy thử lại.'**
  String get authLoginFailedBody;

  /// AuthStrings.loginTitle —
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập Riot'**
  String get authLoginTitle;

  /// AuthStrings.missingCookies —
  ///
  /// In vi, this message translates to:
  /// **'Không lưu được đăng nhập trên thiết bị này, nên bạn sẽ phải đăng nhập lại khi hết hạn.'**
  String get authMissingCookies;

  /// AuthStrings.officialHost —
  ///
  /// In vi, this message translates to:
  /// **'Trang chính thức · auth.riotgames.com'**
  String get authOfficialHost;

  /// AuthStrings.openedInBrowser —
  ///
  /// In vi, this message translates to:
  /// **'Đã mở liên kết trong trình duyệt.'**
  String get authOpenedInBrowser;

  /// AuthStrings.pageLoadFailed —
  ///
  /// In vi, this message translates to:
  /// **'Không tải được trang đăng nhập của Riot. Kiểm tra mạng rồi thử lại.'**
  String get authPageLoadFailed;

  /// AuthStrings.preparing —
  ///
  /// In vi, this message translates to:
  /// **'Đang chuẩn bị trang đăng nhập…'**
  String get authPreparing;

  /// AuthStrings.reloginDone —
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng nhập lại'**
  String get authReloginDone;

  /// AuthStrings.signInCta —
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập bằng tài khoản Riot'**
  String get authSignInCta;

  /// AuthStrings.socialLoginHint —
  ///
  /// In vi, this message translates to:
  /// **'Nếu đăng nhập bằng Google hoặc Facebook không được, hãy dùng tên đăng nhập Riot.'**
  String get authSocialLoginHint;

  /// AuthStrings.stateMismatch —
  ///
  /// In vi, this message translates to:
  /// **'Lần đăng nhập này không hợp lệ. Hãy đăng nhập lại từ đầu.'**
  String get authStateMismatch;

  /// Expired Riot session notice; intentionally does not include an account name.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập lại để tiếp tục nhận thông báo wishlist.'**
  String get notificationSessionExpiredBody;

  /// NotificationStrings.backgroundTimingHint —
  ///
  /// In vi, this message translates to:
  /// **'Chế độ tiết kiệm pin của thiết bị có thể làm thông báo đến muộn.'**
  String get notificationBackgroundTimingHint;

  /// NotificationStrings.channelAccountDescription —
  ///
  /// In vi, this message translates to:
  /// **'Nhắc khi một tài khoản cần đăng nhập lại'**
  String get notificationChannelAccountDescription;

  /// NotificationStrings.channelAccountName —
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản'**
  String get notificationChannelAccountName;

  /// NotificationStrings.channelBattlePassDescription —
  ///
  /// In vi, this message translates to:
  /// **'Nhắc tiến độ và ngày kết thúc Battle Pass'**
  String get notificationChannelBattlePassDescription;

  /// NotificationStrings.channelBattlePassName —
  ///
  /// In vi, this message translates to:
  /// **'Battle Pass'**
  String get notificationChannelBattlePassName;

  /// NotificationStrings.channelCommunityDescription —
  ///
  /// In vi, this message translates to:
  /// **'Báo hoạt động cộng đồng khi bạn mở ValHub'**
  String get notificationChannelCommunityDescription;

  /// NotificationStrings.channelCommunityName —
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng'**
  String get notificationChannelCommunityName;

  /// NotificationStrings.channelLfgDescription —
  ///
  /// In vi, this message translates to:
  /// **'Báo người chơi tham gia tổ đội khi bạn mở ValHub'**
  String get notificationChannelLfgDescription;

  /// NotificationStrings.channelLfgName —
  ///
  /// In vi, this message translates to:
  /// **'Tổ đội'**
  String get notificationChannelLfgName;

  /// NotificationStrings.channelNightMarketDescription —
  ///
  /// In vi, this message translates to:
  /// **'Báo khi Chợ Đêm mở'**
  String get notificationChannelNightMarketDescription;

  /// NotificationStrings.channelNightMarketName —
  ///
  /// In vi, this message translates to:
  /// **'Chợ Đêm'**
  String get notificationChannelNightMarketName;

  /// NotificationStrings.channelRankDescription —
  ///
  /// In vi, this message translates to:
  /// **'Báo thay đổi xếp hạng khi bạn cập nhật hồ sơ'**
  String get notificationChannelRankDescription;

  /// NotificationStrings.channelRankName —
  ///
  /// In vi, this message translates to:
  /// **'Xếp hạng'**
  String get notificationChannelRankName;

  /// NotificationStrings.channelStoreResetDescription —
  ///
  /// In vi, this message translates to:
  /// **'Nhắc khi cửa hàng hằng ngày làm mới'**
  String get notificationChannelStoreResetDescription;

  /// NotificationStrings.channelStoreResetName —
  ///
  /// In vi, this message translates to:
  /// **'Làm mới cửa hàng'**
  String get notificationChannelStoreResetName;

  /// NotificationStrings.channelWishlistDescription —
  ///
  /// In vi, this message translates to:
  /// **'Báo khi skin trong wishlist xuất hiện trong cửa hàng'**
  String get notificationChannelWishlistDescription;

  /// NotificationStrings.channelWishlistName —
  ///
  /// In vi, this message translates to:
  /// **'Wishlist'**
  String get notificationChannelWishlistName;

  /// NotificationStrings.lfgJoinedTitle —
  ///
  /// In vi, this message translates to:
  /// **'Có người chơi tham gia tổ đội'**
  String get notificationLfgJoinedTitle;

  /// NotificationStrings.nightMarketOpenBody —
  ///
  /// In vi, this message translates to:
  /// **'Lật {cards} thẻ ưu đãi của {account} ngay.'**
  String notificationNightMarketOpenBody(String cards, String account);

  /// NotificationStrings.nightMarketOpenTitle —
  ///
  /// In vi, this message translates to:
  /// **'Chợ Đêm đã mở!'**
  String get notificationNightMarketOpenTitle;

  /// NotificationStrings.passEndingBody —
  ///
  /// In vi, this message translates to:
  /// **'Battle Pass còn khoảng một ngày. Mở ValHub để xem tiến độ mới nhất.'**
  String get notificationPassEndingBody;

  /// NotificationStrings.passEndingTitle —
  ///
  /// In vi, this message translates to:
  /// **'Battle Pass sắp kết thúc'**
  String get notificationPassEndingTitle;

  /// NotificationStrings.passProgressBody —
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã đạt cấp {level} trong Battle Pass hiện tại.'**
  String notificationPassProgressBody(int level);

  /// NotificationStrings.passProgressTitle —
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ Battle Pass'**
  String get notificationPassProgressTitle;

  /// NotificationStrings.privateAccount —
  ///
  /// In vi, this message translates to:
  /// **'tài khoản của bạn'**
  String get notificationPrivateAccount;

  /// NotificationStrings.rankChangedBody —
  ///
  /// In vi, this message translates to:
  /// **'Xếp hạng hiện tại: {rank}. Dữ liệu vừa cập nhật từ Riot.'**
  String notificationRankChangedBody(String rank);

  /// NotificationStrings.rankChangedTitle —
  ///
  /// In vi, this message translates to:
  /// **'Xếp hạng đã thay đổi'**
  String get notificationRankChangedTitle;

  /// NotificationStrings.resetTimingUnknown —
  ///
  /// In vi, this message translates to:
  /// **'Mở cửa hàng để cập nhật giờ làm mới trên thiết bị của bạn.'**
  String get notificationResetTimingUnknown;

  /// NotificationStrings.sessionExpiredTitle —
  ///
  /// In vi, this message translates to:
  /// **'Cần đăng nhập lại'**
  String get notificationSessionExpiredTitle;

  /// NotificationStrings.storeResetBody —
  ///
  /// In vi, this message translates to:
  /// **'Skin mới đang chờ bạn trong cửa hàng.'**
  String get notificationStoreResetBody;

  /// Rank division fallback for verified numeric tiers; existing Vietnamese label.
  ///
  /// In vi, this message translates to:
  /// **'Sắt'**
  String get competitiveDivisionIron;

  /// Rank division fallback for verified numeric tiers; existing Vietnamese label.
  ///
  /// In vi, this message translates to:
  /// **'Đồng'**
  String get competitiveDivisionBronze;

  /// Rank division fallback for verified numeric tiers; existing Vietnamese label.
  ///
  /// In vi, this message translates to:
  /// **'Bạc'**
  String get competitiveDivisionSilver;

  /// Rank division fallback for verified numeric tiers; existing Vietnamese label.
  ///
  /// In vi, this message translates to:
  /// **'Vàng'**
  String get competitiveDivisionGold;

  /// Rank division fallback for verified numeric tiers; existing Vietnamese label.
  ///
  /// In vi, this message translates to:
  /// **'Bạch Kim'**
  String get competitiveDivisionPlatinum;

  /// Rank division fallback for verified numeric tiers; existing Vietnamese label.
  ///
  /// In vi, this message translates to:
  /// **'Kim Cương'**
  String get competitiveDivisionDiamond;

  /// Rank division fallback for verified numeric tiers; existing Vietnamese label.
  ///
  /// In vi, this message translates to:
  /// **'Thượng Nhân'**
  String get competitiveDivisionAscendant;

  /// Rank division fallback for verified numeric tiers; existing Vietnamese label.
  ///
  /// In vi, this message translates to:
  /// **'Bất Tử'**
  String get competitiveDivisionImmortal;

  /// Rank fallback division and within-division tier; excludes unranked and unknown tier IDs.
  ///
  /// In vi, this message translates to:
  /// **'{division} {number}'**
  String competitiveRankTierCaption(String division, int number);

  /// Rank display fallback; unknown data is distinct from actual unranked.
  ///
  /// In vi, this message translates to:
  /// **'Radiant'**
  String get competitiveDivisionRadiant;

  /// Rank display fallback; unknown data is distinct from actual unranked.
  ///
  /// In vi, this message translates to:
  /// **'Chưa rõ xếp hạng'**
  String get competitiveRankUnknown;

  /// CompetitiveStrings.attack — Sides (VF §8.8)
  ///
  /// In vi, this message translates to:
  /// **'Tấn công'**
  String get competitiveAttack;

  /// Rank-Up Calculator when the recent form cannot reach the target.
  ///
  /// In vi, this message translates to:
  /// **'Không ước tính được'**
  String get competitiveCannotEstimate;

  /// CompetitiveStrings.defeat — Match outcome (VF §8.8)
  ///
  /// In vi, this message translates to:
  /// **'Thua'**
  String get competitiveDefeat;

  /// CompetitiveStrings.defense — Sides (VF §8.8)
  ///
  /// In vi, this message translates to:
  /// **'Phòng thủ'**
  String get competitiveDefense;

  /// CompetitiveStrings.draw — Match outcome (VF §8.8)
  ///
  /// In vi, this message translates to:
  /// **'Hòa'**
  String get competitiveDraw;

  /// CompetitiveStrings.incognitoPlayer — Players (VF §8.8, SUMMARY U16)
  ///
  /// In vi, this message translates to:
  /// **'Người chơi ẩn danh'**
  String get competitiveIncognitoPlayer;

  /// 404 on match details right after a match (SUMMARY §11.5).
  ///
  /// In vi, this message translates to:
  /// **'Riot đang xử lý trận đấu…'**
  String get competitiveMatchPending;

  /// Shown instead of a stat that has no data (HS% in Deathmatch, …).
  ///
  /// In vi, this message translates to:
  /// **'–'**
  String get competitiveNoValue;

  /// Unranked player that still has placement matches to play.
  ///
  /// In vi, this message translates to:
  /// **'Còn {n} trận phân hạng'**
  String competitivePlacementsLeft(int n);

  /// CompetitiveStrings.roundDefuse — Round end types (VF §8.8, VShop-vi)
  ///
  /// In vi, this message translates to:
  /// **'Gỡ Spike'**
  String get competitiveRoundDefuse;

  /// CompetitiveStrings.roundDetonate — Round end types (VF §8.8, VShop-vi)
  ///
  /// In vi, this message translates to:
  /// **'Spike phát nổ'**
  String get competitiveRoundDetonate;

  /// CompetitiveStrings.roundElimination — Round end types (VF §8.8, VShop-vi)
  ///
  /// In vi, this message translates to:
  /// **'Hạ toàn đội'**
  String get competitiveRoundElimination;

  /// CompetitiveStrings.roundSurrendered — Round end types (VF §8.8, VShop-vi)
  ///
  /// In vi, this message translates to:
  /// **'Đầu hàng'**
  String get competitiveRoundSurrendered;

  /// CompetitiveStrings.roundTimeExpired — Round end types (VF §8.8, VShop-vi)
  ///
  /// In vi, this message translates to:
  /// **'Hết giờ'**
  String get competitiveRoundTimeExpired;

  /// CompetitiveStrings.unknownPlayer — Players (VF §8.8, SUMMARY U16)
  ///
  /// In vi, this message translates to:
  /// **'Người chơi'**
  String get competitiveUnknownPlayer;

  /// CompetitiveStrings.victory — Match outcome (VF §8.8)
  ///
  /// In vi, this message translates to:
  /// **'Thắng'**
  String get competitiveVictory;

  /// "Đang có trong Chợ Đêm!" (VF §8.5 wishlistAvailableNow).
  ///
  /// In vi, this message translates to:
  /// **'Đang có trong {place}!'**
  String economyAvailableNow(String place);

  /// EconomyStrings.placeBundle — placeBundle).
  ///
  /// In vi, this message translates to:
  /// **'bundle {name}'**
  String economyPlaceBundle(String name);

  /// EconomyStrings.placeBundleGeneric — placeBundle).
  ///
  /// In vi, this message translates to:
  /// **'bundle'**
  String get economyPlaceBundleGeneric;

  /// EconomyStrings.placeDaily — placeBundle).
  ///
  /// In vi, this message translates to:
  /// **'cửa hàng hằng ngày'**
  String get economyPlaceDaily;

  /// EconomyStrings.placeNightMarket — placeBundle).
  ///
  /// In vi, this message translates to:
  /// **'Chợ Đêm'**
  String get economyPlaceNightMarket;

  /// EconomyStrings.priceEstimated — Price sources (tooltip / caption under a price, B9).
  ///
  /// In vi, this message translates to:
  /// **'Giá ước tính theo phiên bản'**
  String get economyPriceEstimated;

  /// EconomyStrings.priceFromOffers — Price sources (tooltip / caption under a price, B9).
  ///
  /// In vi, this message translates to:
  /// **'Giá từ bảng giá Riot'**
  String get economyPriceFromOffers;

  /// EconomyStrings.priceFromStore — Price sources (tooltip / caption under a price, B9).
  ///
  /// In vi, this message translates to:
  /// **'Giá đã thấy trong cửa hàng'**
  String get economyPriceFromStore;

  /// EconomyStrings.priceFromTable — Price sources (tooltip / caption under a price, B9).
  ///
  /// In vi, this message translates to:
  /// **'Giá niêm yết'**
  String get economyPriceFromTable;

  /// EconomyStrings.priceUnknown — Price sources (tooltip / caption under a price, B9).
  ///
  /// In vi, this message translates to:
  /// **'Chưa rõ giá'**
  String get economyPriceUnknown;

  /// Default preset name ("Bộ trang bị 3").
  ///
  /// In vi, this message translates to:
  /// **'Bộ trang bị {n}'**
  String loadoutDefaultPresetName(int n);

  /// The change does not fit the loadout (unknown weapon, melee buddy…).
  ///
  /// In vi, this message translates to:
  /// **'Thay đổi này không áp dụng được cho trang bị hiện tại.'**
  String get loadoutInvalidChange;

  /// Riot answered 200 but the re-GET shows the old version.
  ///
  /// In vi, this message translates to:
  /// **'Riot chưa lưu thay đổi của bạn nên trang bị vẫn như cũ. Hãy thử lại.'**
  String get loadoutNotPersisted;

  /// Error of any failed save (U8).
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu trang bị'**
  String get loadoutSaveFailed;

  /// "Phần kết thúc sau 11:54:37" (last day).
  ///
  /// In vi, this message translates to:
  /// **'Phần kết thúc sau {time}'**
  String battlePassActEndsIn(String time);

  /// "Phần kết thúc sau 16 ngày".
  ///
  /// In vi, this message translates to:
  /// **'Phần kết thúc sau {days} ngày'**
  String battlePassActEndsInDays(int days);

  /// BattlePassStrings.allMissionsDone — All completed (P5)
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành tất cả nhiệm vụ'**
  String get battlePassAllMissionsDone;

  /// BattlePassStrings.allWeeklyDone — All completed (P5)
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành tất cả nhiệm vụ hằng tuần'**
  String get battlePassAllWeeklyDone;

  /// BattlePassStrings.bonusBadge — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'×2'**
  String get battlePassBonusBadge;

  /// "Thưởng gấp đôi đang chờ: 2".
  ///
  /// In vi, this message translates to:
  /// **'Thưởng gấp đôi đang chờ: {n}'**
  String battlePassBonusPending(int n);

  /// "Chương 3".
  ///
  /// In vi, this message translates to:
  /// **'Chương {n}'**
  String battlePassChapter(int n);

  /// "3/5" levels reached in a chapter.
  ///
  /// In vi, this message translates to:
  /// **'{reached}/{total}'**
  String battlePassChapterProgress(int reached, int total);

  /// Charges of one checkpoint: "3/4".
  ///
  /// In vi, this message translates to:
  /// **'{charges}/{needed}'**
  String battlePassCharges(int charges, int needed);

  /// BattlePassStrings.checkpointHint — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'Thắng vòng để tiến tới cột mốc (Sinh Tử không tính).'**
  String get battlePassCheckpointHint;

  /// Semantic label of one pip: "Cột mốc 2: 3/4".
  ///
  /// In vi, this message translates to:
  /// **'Cột mốc {index}: {charges}/{needed}'**
  String battlePassCheckpointLabel(int index, int charges, int needed);

  /// BattlePassStrings.checkpointRewards — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'Mỗi cột mốc: +XP, +KC'**
  String get battlePassCheckpointRewards;

  /// "Đã đạt 2/4 cột mốc".
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt {done}/{total} cột mốc'**
  String battlePassCheckpointsDone(int done, int total);

  /// BattlePassStrings.currentChapter — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Hiện tại'**
  String get battlePassCurrentChapter;

  /// BattlePassStrings.dailyAllDone — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành tất cả cột mốc hôm nay'**
  String get battlePassDailyAllDone;

  /// BattlePassStrings.dailyCaption — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'Phần thưởng ngày'**
  String get battlePassDailyCaption;

  /// "Phần thưởng ngày · Làm mới lúc 07:00 ngày mai".
  ///
  /// In vi, this message translates to:
  /// **'Phần thưởng ngày · {reset}'**
  String battlePassDailyCaptionReset(String reset);

  /// BattlePassStrings.dailyExpired — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'Cột mốc của ngày trước đã hết hạn. Hãy vào game hoặc làm mới tại đây.'**
  String get battlePassDailyExpired;

  /// BattlePassStrings.dailyMissions — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'Nhiệm vụ hằng ngày'**
  String get battlePassDailyMissions;

  /// BattlePassStrings.dailyNotReady — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'Cột mốc hôm nay chưa sẵn sàng. Hãy vào game hoặc làm mới tại đây.'**
  String get battlePassDailyNotReady;

  /// BattlePassStrings.dailyPlayToStart — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'Cột mốc hôm nay chưa sẵn sàng. Hãy vào game để bắt đầu ngày mới.'**
  String get battlePassDailyPlayToStart;

  /// "Còn 15 ngày".
  ///
  /// In vi, this message translates to:
  /// **'Còn {days} ngày'**
  String battlePassDaysLeft(int days);

  /// Separator between short facts ("Skin · Cấp 12 · Đã mở khóa").
  ///
  /// In vi, this message translates to:
  /// **' · '**
  String get battlePassDot;

  /// BattlePassStrings.endsAtWall — thứ Hai 06/10", "Làm mới lúc 07:00 ngày mai".
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc lúc {wall}'**
  String battlePassEndsAtWall(String wall);

  /// BattlePassStrings.epilogue — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Phần mở rộng'**
  String get battlePassEpilogue;

  /// BattlePassStrings.estimateNote — Estimate (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Ước tính khoảng 4.000 XP mỗi trận, chưa tính nhiệm vụ.'**
  String get battlePassEstimateNote;

  /// "Kết thúc sau 2 ngày 15:09:24".
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc sau {time}'**
  String battlePassEventEndsIn(String time);

  /// BattlePassStrings.eventPass — Event pass
  ///
  /// In vi, this message translates to:
  /// **'Vé sự kiện'**
  String get battlePassEventPass;

  /// BattlePassStrings.filterAll — Rewards filter (remembered)
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get battlePassFilterAll;

  /// BattlePassStrings.filterLocked — Rewards filter (remembered)
  ///
  /// In vi, this message translates to:
  /// **'Còn khóa'**
  String get battlePassFilterLocked;

  /// BattlePassStrings.filterUnlocked — Rewards filter (remembered)
  ///
  /// In vi, this message translates to:
  /// **'Đã mở khóa'**
  String get battlePassFilterUnlocked;

  /// BattlePassStrings.free — Pass card (S20)
  ///
  /// In vi, this message translates to:
  /// **'Miễn phí'**
  String get battlePassFree;

  /// BattlePassStrings.freeTrack — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Phần thưởng miễn phí'**
  String get battlePassFreeTrack;

  /// "Cấp 46 / 55".
  ///
  /// In vi, this message translates to:
  /// **'Cấp {level} / {count}'**
  String battlePassLevelOf(String level, String count);

  /// "Cấp 12".
  ///
  /// In vi, this message translates to:
  /// **'Cấp {n}'**
  String battlePassLevelShort(int n);

  /// "≈ 81 trận Đấu thường".
  ///
  /// In vi, this message translates to:
  /// **'≈ {n} trận {queue}'**
  String battlePassMatchesEstimate(int n, String queue);

  /// BattlePassStrings.missionDone — Weekly missions (P3)
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành'**
  String get battlePassMissionDone;

  /// "8 / 15".
  ///
  /// In vi, this message translates to:
  /// **'{progress} / {target}'**
  String battlePassMissionProgress(String progress, String target);

  /// "2/3 hoàn thành".
  ///
  /// In vi, this message translates to:
  /// **'{done}/{total} hoàn thành'**
  String battlePassMissionsCompleted(int done, int total);

  /// BattlePassStrings.newMissionsAtWall — thứ Hai 06/10", "Làm mới lúc 07:00 ngày mai".
  ///
  /// In vi, this message translates to:
  /// **'Nhiệm vụ mới lúc {wall}'**
  String battlePassNewMissionsAtWall(String wall);

  /// "Nhiệm vụ mới sau 2 ngày 15:09:24".
  ///
  /// In vi, this message translates to:
  /// **'Nhiệm vụ mới sau {time}'**
  String battlePassNewMissionsIn(String time);

  /// "Cột mốc tiếp theo: 3/4".
  ///
  /// In vi, this message translates to:
  /// **'Cột mốc tiếp theo: {charges}/{needed}'**
  String battlePassNextCheckpoint(int charges, int needed);

  /// Caption of the level XP: "Lên cấp 47".
  ///
  /// In vi, this message translates to:
  /// **'Lên cấp {level}'**
  String battlePassNextLevelCaption(String level);

  /// BattlePassStrings.nextReward — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Tiếp theo'**
  String get battlePassNextReward;

  /// BattlePassStrings.noBattlePass — thứ Hai 06/10", "Làm mới lúc 07:00 ngày mai".
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thông tin Battle Pass của Phần hiện tại. Hãy thử lại sau.'**
  String get battlePassNoBattlePass;

  /// BattlePassStrings.noRewards — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Chưa có phần thưởng nào cho Battle Pass này.'**
  String get battlePassNoRewards;

  /// BattlePassStrings.noRewardsInFilter — Rewards filter (remembered)
  ///
  /// In vi, this message translates to:
  /// **'Không có phần thưởng nào trong mục này.'**
  String get battlePassNoRewardsInFilter;

  /// BattlePassStrings.noRewardsTitle — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Chưa có phần thưởng'**
  String get battlePassNoRewardsTitle;

  /// BattlePassStrings.noWeeklyMissions — Weekly missions (P3)
  ///
  /// In vi, this message translates to:
  /// **'Hiện chưa có nhiệm vụ hằng tuần.'**
  String get battlePassNoWeeklyMissions;

  /// BattlePassStrings.passComplete — Pass card (S20)
  ///
  /// In vi, this message translates to:
  /// **'Đã hoàn thành Battle Pass'**
  String get battlePassPassComplete;

  /// BattlePassStrings.premium — Pass card (S20)
  ///
  /// In vi, this message translates to:
  /// **'Premium'**
  String get battlePassPremium;

  /// BattlePassStrings.premiumHint — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa mua Premium: chỉ nhận được phần thưởng Miễn phí. Mua Premium trong game để mở khóa các cấp đã đạt.'**
  String get battlePassPremiumHint;

  /// BattlePassStrings.renewButton — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'Làm mới cột mốc'**
  String get battlePassRenewButton;

  /// BattlePassStrings.renewDone — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'Đã làm mới cột mốc hằng ngày.'**
  String get battlePassRenewDone;

  /// BattlePassStrings.renewFailed — Daily checkpoints (P4)
  ///
  /// In vi, this message translates to:
  /// **'Không thể làm mới cột mốc. Hãy thử lại sau.'**
  String get battlePassRenewFailed;

  /// BattlePassStrings.resetsAtWall — thứ Hai 06/10", "Làm mới lúc 07:00 ngày mai".
  ///
  /// In vi, this message translates to:
  /// **'Làm mới lúc {wall}'**
  String battlePassResetsAtWall(String wall);

  /// "Làm mới sau 11:54:37".
  ///
  /// In vi, this message translates to:
  /// **'Làm mới sau {time}'**
  String battlePassResetsIn(String time);

  /// BattlePassStrings.rewardLevelLabel — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Cấp'**
  String get battlePassRewardLevelLabel;

  /// BattlePassStrings.rewardLocked — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Chưa mở khóa'**
  String get battlePassRewardLocked;

  /// BattlePassStrings.rewardNeedsPremium — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Cần Premium'**
  String get battlePassRewardNeedsPremium;

  /// BattlePassStrings.rewardStatusLabel — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái'**
  String get battlePassRewardStatusLabel;

  /// BattlePassStrings.rewardTrackLabel — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Loại phần thưởng'**
  String get battlePassRewardTrackLabel;

  /// BattlePassStrings.rewardTypeLabel — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Loại'**
  String get battlePassRewardTypeLabel;

  /// BattlePassStrings.rewardUnlocked — Rewards (S21)
  ///
  /// In vi, this message translates to:
  /// **'Đã mở khóa'**
  String get battlePassRewardUnlocked;

  /// BattlePassStrings.rewardsTitle —
  ///
  /// In vi, this message translates to:
  /// **'Phần thưởng'**
  String get battlePassRewardsTitle;

  /// BattlePassStrings.showAllRewards — Rewards filter (remembered)
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get battlePassShowAllRewards;

  /// BattlePassStrings.title —
  ///
  /// In vi, this message translates to:
  /// **'Battle Pass'**
  String get battlePassTitle;

  /// BattlePassStrings.totalXpCaption — Pass card (S20)
  ///
  /// In vi, this message translates to:
  /// **'Tổng XP'**
  String get battlePassTotalXpCaption;

  /// BattlePassStrings.unknownMission — Weekly missions (P3)
  ///
  /// In vi, this message translates to:
  /// **'Nhiệm vụ mới (chưa có mô tả)'**
  String get battlePassUnknownMission;

  /// BattlePassStrings.unknownReward — Rewards filter (remembered)
  ///
  /// In vi, this message translates to:
  /// **'Phần thưởng'**
  String get battlePassUnknownReward;

  /// "46/55 đã mở khóa".
  ///
  /// In vi, this message translates to:
  /// **'{unlocked}/{total} đã mở khóa'**
  String battlePassUnlockedCount(String unlocked, String total);

  /// BattlePassStrings.unratedFallback — Estimate (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Đấu thường'**
  String get battlePassUnratedFallback;

  /// BattlePassStrings.viewAllRewards — Rewards row
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả phần thưởng'**
  String get battlePassViewAllRewards;

  /// BattlePassStrings.weeklyMissions — Weekly missions (P3)
  ///
  /// In vi, this message translates to:
  /// **'Nhiệm vụ hằng tuần'**
  String get battlePassWeeklyMissions;

  /// "Nhiệm vụ tuần còn +76.800 XP".
  ///
  /// In vi, this message translates to:
  /// **'Nhiệm vụ tuần còn +{xp} XP'**
  String battlePassWeeklyXpLeft(String xp);

  /// "7.966 / 35.750 XP".
  ///
  /// In vi, this message translates to:
  /// **'{xp} / {total} XP'**
  String battlePassXpOf(String xp, String total);

  /// "21.469 XP / ngày".
  ///
  /// In vi, this message translates to:
  /// **'{xp} XP / ngày'**
  String battlePassXpPerDay(String xp);

  /// BattlePassStrings.xpPerDayCaption — XP pace (ValHub extra)
  ///
  /// In vi, this message translates to:
  /// **'Cần mỗi ngày để kịp hoàn thành'**
  String get battlePassXpPerDayCaption;

  /// "+38.400 XP".
  ///
  /// In vi, this message translates to:
  /// **'+{xp} XP'**
  String battlePassXpReward(String xp);

  /// "Còn cần 321.034 XP".
  ///
  /// In vi, this message translates to:
  /// **'Còn cần {xp} XP'**
  String battlePassXpToFinish(String xp);

  /// Loadout save failure with a localized cause.
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu trang bị. {detail}'**
  String collectionSaveFailedWith(String detail);

  /// Render-time description for CollectionBrowseType; unknown IDs keep the existing browse-title fallback.
  ///
  /// In vi, this message translates to:
  /// **'{type, select, skin{Mọi skin bạn sở hữu, tính giá trị theo giá cửa hàng} buddy{Phụ kiện súng đã sở hữu và số bản sao} spray{Hình phun sơn bạn có thể gắn vào tổ hợp cảm xúc} card{Thẻ người chơi đã mở khóa, chạm để xem và trang bị} title{Danh hiệu bạn có thể hiển thị dưới tên} flex{Flex đã sở hữu} other{Duyệt bộ sưu tập}}'**
  String collectionBrowseDescription(String type);

  /// Explicit render-time message, preserving existing VI behavior.
  ///
  /// In vi, this message translates to:
  /// **'Ô {position}'**
  String collectionSlotCaption(String position);

  /// CollectionStrings.applyPreset — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get collectionApplyPreset;

  /// CollectionStrings.applyPresetBody — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Skin, phụ kiện súng, tổ hợp cảm xúc, thẻ và danh hiệu đang dùng sẽ được thay bằng bộ này.'**
  String get collectionApplyPresetBody;

  /// CollectionStrings.applyPresetTitle — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng “{name}”?'**
  String collectionApplyPresetTitle(String name);

  /// CollectionStrings.browseBuddies — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Phụ kiện súng'**
  String get collectionBrowseBuddies;

  /// CollectionStrings.browseCards — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Thẻ người chơi'**
  String get collectionBrowseCards;

  /// CollectionStrings.browseEmpty — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có vật phẩm nào ở mục này.'**
  String get collectionBrowseEmpty;

  /// CollectionStrings.browseEmptyTitle — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Chưa có vật phẩm'**
  String get collectionBrowseEmptyTitle;

  /// CollectionStrings.browseFlex — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Flex'**
  String get collectionBrowseFlex;

  /// CollectionStrings.browseSkins — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Skin'**
  String get collectionBrowseSkins;

  /// CollectionStrings.browseSprays — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Hình phun sơn'**
  String get collectionBrowseSprays;

  /// CollectionStrings.browseTitles — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Danh hiệu'**
  String get collectionBrowseTitles;

  /// CollectionStrings.buddyAvailable — S36 buddies
  ///
  /// In vi, this message translates to:
  /// **'Còn {free}/{total}'**
  String collectionBuddyAvailable(int free, int total);

  /// CollectionStrings.buddyFor — S36 buddies
  ///
  /// In vi, this message translates to:
  /// **'Cho {weapon}'**
  String collectionBuddyFor(String weapon);

  /// CollectionStrings.buddyPickerTitle — S36 buddies
  ///
  /// In vi, this message translates to:
  /// **'Chọn phụ kiện súng'**
  String get collectionBuddyPickerTitle;

  /// CollectionStrings.buddyRemoved — S36 buddies
  ///
  /// In vi, this message translates to:
  /// **'Đã gỡ phụ kiện'**
  String get collectionBuddyRemoved;

  /// CollectionStrings.buddySlot — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Phụ kiện súng'**
  String get collectionBuddySlot;

  /// CollectionStrings.buddyUnavailable — S36 buddies
  ///
  /// In vi, this message translates to:
  /// **'Chưa gắn được phụ kiện này. Hãy làm mới hoặc chọn phụ kiện khác.'**
  String get collectionBuddyUnavailable;

  /// CollectionStrings.cachedLoadout — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Đang hiển thị trang bị đã lưu. Kéo để làm mới trước khi thay đổi.'**
  String get collectionCachedLoadout;

  /// CollectionStrings.cardsCount — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'{n} thẻ đã sở hữu'**
  String collectionCardsCount(int n);

  /// CollectionStrings.changeBuddy — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Đổi'**
  String get collectionChangeBuddy;

  /// CollectionStrings.chromaCount — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'{owned}/{total} biến thể'**
  String collectionChromaCount(int owned, int total);

  /// CollectionStrings.clearTiers — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Bỏ lọc phiên bản'**
  String get collectionClearTiers;

  /// CollectionStrings.collectionValue — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Giá trị bộ sưu tập'**
  String get collectionCollectionValue;

  /// CollectionStrings.copies — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'×{n}'**
  String collectionCopies(int n);

  /// CollectionStrings.defaultSkin — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Mặc định'**
  String get collectionDefaultSkin;

  /// CollectionStrings.deletePreset — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get collectionDeletePreset;

  /// CollectionStrings.emptySlot — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Trống'**
  String get collectionEmptySlot;

  /// CollectionStrings.equip — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Trang bị'**
  String get collectionEquip;

  /// CollectionStrings.equipped — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Đang dùng'**
  String get collectionEquipped;

  /// CollectionStrings.equippedCard — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Thẻ đang dùng'**
  String get collectionEquippedCard;

  /// CollectionStrings.equippedCardLabel — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Thẻ đang dùng: {name}'**
  String collectionEquippedCardLabel(String name);

  /// CollectionStrings.equippedItem — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Đã trang bị {name}'**
  String collectionEquippedItem(String name);

  /// CollectionStrings.equippedLine — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Đang dùng: {skin}'**
  String collectionEquippedLine(String skin);

  /// CollectionStrings.excludedRewards — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Không tính skin phần thưởng'**
  String get collectionExcludedRewards;

  /// CollectionStrings.expressionsHint — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào một ô để chọn hình phun sơn hoặc Flex.'**
  String get collectionExpressionsHint;

  /// CollectionStrings.expressionsSlots — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Các ô trên vòng'**
  String get collectionExpressionsSlots;

  /// CollectionStrings.expressionsTitle — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Tổ hợp cảm xúc'**
  String get collectionExpressionsTitle;

  /// CollectionStrings.hideAccountLevel — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Ẩn cấp tài khoản'**
  String get collectionHideAccountLevel;

  /// CollectionStrings.hideAccountLevelHint — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Người chơi khác sẽ không thấy cấp tài khoản của bạn.'**
  String get collectionHideAccountLevelHint;

  /// CollectionStrings.incognito — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Chế độ ẩn danh'**
  String get collectionIncognito;

  /// CollectionStrings.incognitoHint — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Ẩn tên của bạn với người chơi không cùng tổ đội trong trận.'**
  String get collectionIncognitoHint;

  /// CollectionStrings.levelBorderAuto — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Tự động theo cấp'**
  String get collectionLevelBorderAuto;

  /// CollectionStrings.levelBorderFrom — level border
  ///
  /// In vi, this message translates to:
  /// **'Từ cấp {level}'**
  String collectionLevelBorderFrom(int level);

  /// "Tài khoản cấp 474" under the sheet title.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản cấp {level}'**
  String collectionLevelBorderSubtitle(int level);

  /// CollectionStrings.levelBorderTitle — level border
  ///
  /// In vi, this message translates to:
  /// **'Chọn khung cấp'**
  String get collectionLevelBorderTitle;

  /// CollectionStrings.levelCount — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Cấp {owned}/{total}'**
  String collectionLevelCount(int owned, int total);

  /// CollectionStrings.levelLabel — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Cấp {n} · {type}'**
  String collectionLevelLabel(int n, String type);

  /// CollectionStrings.levels — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Cấp độ'**
  String get collectionLevels;

  /// CollectionStrings.levelsUnlocked — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Đã mở {owned}/{total} cấp'**
  String collectionLevelsUnlocked(int owned, int total);

  /// CollectionStrings.lobbyBanner — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Ảnh ở sảnh chờ'**
  String get collectionLobbyBanner;

  /// CollectionStrings.locked — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Chưa mở khóa'**
  String get collectionLocked;

  /// CollectionStrings.meleeNoBuddy — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Vũ khí cận chiến không gắn được phụ kiện.'**
  String get collectionMeleeNoBuddy;

  /// CollectionStrings.move — S36 buddies
  ///
  /// In vi, this message translates to:
  /// **'Chuyển'**
  String get collectionMove;

  /// CollectionStrings.moveBuddyBody — S36 buddies
  ///
  /// In vi, this message translates to:
  /// **'{buddy} đang gắn trên {from}. Chuyển sang {to}?'**
  String collectionMoveBuddyBody(String buddy, String from, String to);

  /// CollectionStrings.moveBuddyTitle — S36 buddies
  ///
  /// In vi, this message translates to:
  /// **'Chuyển phụ kiện?'**
  String get collectionMoveBuddyTitle;

  /// CollectionStrings.noBuddies — S36 buddies
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có phụ kiện súng nào.'**
  String get collectionNoBuddies;

  /// CollectionStrings.noBuddy — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Chưa gắn phụ kiện'**
  String get collectionNoBuddy;

  /// CollectionStrings.noFlex — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có Flex nào.'**
  String get collectionNoFlex;

  /// CollectionStrings.noResults — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy kết quả phù hợp.'**
  String get collectionNoResults;

  /// CollectionStrings.noResultsTitle — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy'**
  String get collectionNoResultsTitle;

  /// CollectionStrings.noSkinsForWeapon — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có skin nào cho vũ khí này.'**
  String get collectionNoSkinsForWeapon;

  /// CollectionStrings.noSprays — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa có hình phun sơn nào.'**
  String get collectionNoSprays;

  /// CollectionStrings.noTitle — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Không có danh hiệu'**
  String get collectionNoTitle;

  /// CollectionStrings.otherWeapons — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Khác'**
  String get collectionOtherWeapons;

  /// CollectionStrings.ownedForWeapon — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'{n, plural, =0{Chưa có skin nào} other{{n} skin đã sở hữu}}'**
  String collectionOwnedForWeapon(int n);

  /// CollectionStrings.ownedSkinsStat — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'{n} skin đã sở hữu'**
  String collectionOwnedSkinsStat(int n);

  /// CollectionStrings.playLevelVideo — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Xem video cấp này'**
  String get collectionPlayLevelVideo;

  /// CollectionStrings.playVideo — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Xem video'**
  String get collectionPlayVideo;

  /// CollectionStrings.playerCardSubtitle — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Hiện ở sảnh chờ, bảng điểm và khi bạn hạ gục đối thủ.'**
  String get collectionPlayerCardSubtitle;

  /// CollectionStrings.playerCardTitle — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Đổi thẻ người chơi'**
  String get collectionPlayerCardTitle;

  /// CollectionStrings.playerTitleSubtitle — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Hiện dưới tên của bạn ở sảnh chờ và trong trận.'**
  String get collectionPlayerTitleSubtitle;

  /// CollectionStrings.playerTitleTitle — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Đổi danh hiệu'**
  String get collectionPlayerTitleTitle;

  /// CollectionStrings.presetActions — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Tùy chọn'**
  String get collectionPresetActions;

  /// CollectionStrings.presetApplied — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Đã áp dụng “{name}”'**
  String collectionPresetApplied(String name);

  /// CollectionStrings.presetCount — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'{n, plural, =0{Chưa có} other{{n} bộ}}'**
  String collectionPresetCount(int n);

  /// CollectionStrings.presetDeleted — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa “{name}”'**
  String collectionPresetDeleted(String name);

  /// CollectionStrings.presetNameHint — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Ví dụ: Leo rank'**
  String get collectionPresetNameHint;

  /// CollectionStrings.presetNameTitle — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Tên bộ trang bị'**
  String get collectionPresetNameTitle;

  /// CollectionStrings.presetSaved — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu “{name}”'**
  String collectionPresetSaved(String name);

  /// CollectionStrings.presetSavedAt — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Lưu ngày {date}'**
  String collectionPresetSavedAt(String date);

  /// CollectionStrings.presetSkipped — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Bỏ qua {n} vật phẩm bạn không còn sở hữu.'**
  String collectionPresetSkipped(int n);

  /// CollectionStrings.presetsEmpty — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Lưu trang bị đang dùng để đổi nhanh giữa các bộ skin, thẻ và tổ hợp cảm xúc sau này.'**
  String get collectionPresetsEmpty;

  /// CollectionStrings.presetsEmptyTitle — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bộ trang bị'**
  String get collectionPresetsEmptyTitle;

  /// CollectionStrings.presetsFull — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Đã đạt tối đa 50 bộ trang bị. Hãy xóa bớt để lưu thêm.'**
  String get collectionPresetsFull;

  /// CollectionStrings.presetsNote — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Bộ trang bị chỉ được lưu trên thiết bị này, cho tài khoản đang chọn.'**
  String get collectionPresetsNote;

  /// CollectionStrings.presetsTitle — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Bộ trang bị đã lưu'**
  String get collectionPresetsTitle;

  /// CollectionStrings.preview — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Xem trước'**
  String get collectionPreview;

  /// CollectionStrings.removeBuddy — S36 buddies
  ///
  /// In vi, this message translates to:
  /// **'Gỡ phụ kiện'**
  String get collectionRemoveBuddy;

  /// CollectionStrings.renamePreset — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Đổi tên'**
  String get collectionRenamePreset;

  /// CollectionStrings.rowExpressions — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Tổ hợp cảm xúc'**
  String get collectionRowExpressions;

  /// CollectionStrings.rowLevelBorder — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Khung cấp'**
  String get collectionRowLevelBorder;

  /// CollectionStrings.rowPresets — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Bộ trang bị đã lưu'**
  String get collectionRowPresets;

  /// CollectionStrings.rowWeapons — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Trang bị vũ khí'**
  String get collectionRowWeapons;

  /// CollectionStrings.rowWishlist — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Wishlist'**
  String get collectionRowWishlist;

  /// CollectionStrings.saveFailed — errors
  ///
  /// In vi, this message translates to:
  /// **'Không thể lưu trang bị'**
  String get collectionSaveFailed;

  /// CollectionStrings.savePreset — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Lưu trang bị hiện tại'**
  String get collectionSavePreset;

  /// CollectionStrings.saving — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Đang lưu…'**
  String get collectionSaving;

  /// CollectionStrings.searchBuddies — S36 buddies
  ///
  /// In vi, this message translates to:
  /// **'Tìm phụ kiện…'**
  String get collectionSearchBuddies;

  /// CollectionStrings.searchCards — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Tìm thẻ người chơi…'**
  String get collectionSearchCards;

  /// CollectionStrings.searchFlex — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Tìm Flex…'**
  String get collectionSearchFlex;

  /// CollectionStrings.searchItems — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Tìm kiếm…'**
  String get collectionSearchItems;

  /// CollectionStrings.searchSkins — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Tìm skin…'**
  String get collectionSearchSkins;

  /// CollectionStrings.searchSprays — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Tìm hình phun sơn…'**
  String get collectionSearchSprays;

  /// CollectionStrings.searchTitles — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Tìm danh hiệu…'**
  String get collectionSearchTitles;

  /// CollectionStrings.searchWeapons — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Tìm vũ khí, skin hoặc phụ kiện…'**
  String get collectionSearchWeapons;

  /// CollectionStrings.sectionBrowse — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Duyệt bộ sưu tập'**
  String get collectionSectionBrowse;

  /// CollectionStrings.sectionIdentity — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Hiển thị với người chơi khác'**
  String get collectionSectionIdentity;

  /// CollectionStrings.sectionLoadout — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Trang bị'**
  String get collectionSectionLoadout;

  /// CollectionStrings.skinCustomizeTitle — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Tùy chỉnh skin'**
  String get collectionSkinCustomizeTitle;

  /// CollectionStrings.skinNotFound — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy skin này.'**
  String get collectionSkinNotFound;

  /// CollectionStrings.skinNotOwned — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa sở hữu skin này.'**
  String get collectionSkinNotOwned;

  /// CollectionStrings.slotNames — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Trên'**
  String get collectionSlotNamesItem0;

  /// CollectionStrings.slotNames — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Phải'**
  String get collectionSlotNamesItem1;

  /// CollectionStrings.slotNames — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Dưới'**
  String get collectionSlotNamesItem2;

  /// CollectionStrings.slotNames — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Trái'**
  String get collectionSlotNamesItem3;

  /// CollectionStrings.sortName — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Tên'**
  String get collectionSortName;

  /// CollectionStrings.sortPrice — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Giá'**
  String get collectionSortPrice;

  /// CollectionStrings.sortRarity — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Độ hiếm'**
  String get collectionSortRarity;

  /// CollectionStrings.sortWeapon — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Vũ khí'**
  String get collectionSortWeapon;

  /// CollectionStrings.summaryFiltered — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Đang lọc: {count} skin · {value}'**
  String collectionSummaryFiltered(int count, String value);

  /// CollectionStrings.summaryFilteredItems — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Đang lọc: {count}/{total} vật phẩm'**
  String collectionSummaryFilteredItems(int count, int total);

  /// CollectionStrings.summaryItems — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'{count} vật phẩm'**
  String collectionSummaryItems(int count);

  /// CollectionStrings.summarySkins — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'{count} skin · {value}'**
  String collectionSummarySkins(int count, String value);

  /// CollectionStrings.tabFlex — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Flex'**
  String get collectionTabFlex;

  /// CollectionStrings.tabSprays — S37 expressions
  ///
  /// In vi, this message translates to:
  /// **'Hình phun sơn'**
  String get collectionTabSprays;

  /// CollectionStrings.tapToChangeCard — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Chạm để đổi thẻ'**
  String get collectionTapToChangeCard;

  /// CollectionStrings.title —
  ///
  /// In vi, this message translates to:
  /// **'Bộ sưu tập'**
  String get collectionTitle;

  /// CollectionStrings.titlesCount — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'{n} danh hiệu đã sở hữu'**
  String collectionTitlesCount(int n);

  /// CollectionStrings.undo — S38 presets
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get collectionUndo;

  /// CollectionStrings.unknownCard — S31 / S32 pickers
  ///
  /// In vi, this message translates to:
  /// **'Thẻ chưa rõ tên'**
  String get collectionUnknownCard;

  /// CollectionStrings.valueAtStorePrices — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Tính theo giá cửa hàng'**
  String get collectionValueAtStorePrices;

  /// CollectionStrings.valueHasEstimates — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Có giá ước tính (≈)'**
  String get collectionValueHasEstimates;

  /// CollectionStrings.valueRewardCount — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'{n} skin phần thưởng không được tính'**
  String collectionValueRewardCount(int n);

  /// CollectionStrings.valueSeeSkins — S39 browse
  ///
  /// In vi, this message translates to:
  /// **'Xem các skin'**
  String get collectionValueSeeSkins;

  /// CollectionStrings.valueSkinCount — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'Tính trên {n} skin'**
  String collectionValueSkinCount(int n);

  /// CollectionStrings.variants — S35 customize
  ///
  /// In vi, this message translates to:
  /// **'Biến thể'**
  String get collectionVariants;

  /// CollectionStrings.weaponLoadoutSubtitle — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'{custom}/{total} vũ khí đang dùng skin'**
  String collectionWeaponLoadoutSubtitle(int custom, int total);

  /// CollectionStrings.weaponLoadoutTitle — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Trang bị vũ khí'**
  String get collectionWeaponLoadoutTitle;

  /// CollectionStrings.weaponNotFound — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy vũ khí này.'**
  String get collectionWeaponNotFound;

  /// CollectionStrings.weaponSkinsTitle — S33 / S34 weapons
  ///
  /// In vi, this message translates to:
  /// **'Chọn skin'**
  String get collectionWeaponSkinsTitle;

  /// CollectionStrings.wishlistCount — S30 hub
  ///
  /// In vi, this message translates to:
  /// **'{n, plural, =0{Trống} other{{n} skin}}'**
  String collectionWishlistCount(int n);

  /// Player-safe copy for Community moderation reason content_inappropriate. Never render arbitrary server text.
  ///
  /// In vi, this message translates to:
  /// **'Chưa đăng được vì có từ ngữ không phù hợp. Hãy sửa nội dung rồi thử lại.'**
  String get communityModerationContentInappropriate;

  /// Player-safe copy for Community moderation reason content_scam. Never render arbitrary server text.
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng không cho phép quảng cáo mua bán tài khoản, cày thuê hay để lại số điện thoại. Hãy bỏ những nội dung này rồi thử lại.'**
  String get communityModerationContentScam;

  /// Player-safe copy for Community moderation reason content_too_complex. Never render arbitrary server text.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung có quá nhiều ký tự rời rạc. Hãy viết gọn hơn rồi thử lại.'**
  String get communityModerationContentTooComplex;

  /// Player-safe copy for Community moderation reason account_banned. Never render arbitrary server text.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản này đã bị khóa quyền dùng Cộng đồng. Nếu cho rằng có nhầm lẫn, hãy liên hệ ValHub trong Giới thiệu & pháp lý.'**
  String get communityModerationAccountBanned;

  /// Player-safe copy for Community moderation reason account_restricted. Never render arbitrary server text.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản này đang bị hạn chế đăng bài, bình luận, tìm đồng đội và bình chọn. Hãy thử lại sau hoặc liên hệ ValHub trong Giới thiệu & pháp lý.'**
  String get communityModerationAccountRestricted;

  /// Community mode label. Unknown codes use the other branch; does not alter API identifiers.
  ///
  /// In vi, this message translates to:
  /// **'{mode, select, competitive{Xếp hạng} unrated{Đấu thường} swiftplay{Siêu Tốc} spikerush{Đặt Spike Nhanh} deathmatch{Sinh Tử} teamdeathmatch{Sinh Tử Đội} premier{Premier} custom{Chơi tự do} other{Khác}}'**
  String communityModeName(String mode);

  /// Community shard label. Unknown regions stay unknown; this does not infer region from country.
  ///
  /// In vi, this message translates to:
  /// **'{region, select, ap{Châu Á - Thái Bình Dương} na{Bắc Mỹ} eu{Châu Âu} kr{Hàn Quốc} latam{Mỹ Latinh} br{Brazil} other{Chưa rõ máy chủ}}'**
  String communityRegionName(String region);

  /// Skin ranking discovery and compact filters; actual community data only.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có skin trong bảng xếp hạng này'**
  String get communityRankingEmptyTitle;

  /// Skin ranking (global, all time, optional weapon filter) sorted by favorites is empty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có lượt yêu thích nào.'**
  String get communityRankingEmptyVotes;

  /// Skin ranking (global, all time, optional weapon filter) sorted by star rating is empty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đánh giá sao nào.'**
  String get communityRankingEmptyRatings;

  /// Skin ranking (global, all time, optional weapon filter) sorted by written reviews is empty.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có nhận xét nào.'**
  String get communityRankingEmptyReviews;

  /// Skin ranking discovery and compact filters; actual community data only.
  ///
  /// In vi, this message translates to:
  /// **'Tìm skin để xem và đánh giá'**
  String get communityRankingExplore;

  /// Skin ranking discovery and compact filters; actual community data only.
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo tên skin hoặc vũ khí. Chỉ đánh giá thực tế của cộng đồng mới xuất hiện trong bảng xếp hạng.'**
  String get communityRankingExploreHint;

  /// Skin ranking empty state action: clears the weapon filter (the only filter of the ranking).
  ///
  /// In vi, this message translates to:
  /// **'Bỏ lọc vũ khí'**
  String get communityRankingClear;

  /// Skin ranking discovery and compact filters; actual community data only.
  ///
  /// In vi, this message translates to:
  /// **'Xếp hạng theo'**
  String get communityRankingSort;

  /// Skin ranking discovery and compact filters; actual community data only.
  ///
  /// In vi, this message translates to:
  /// **'Vũ khí'**
  String get communityRankingWeapon;

  /// Full skin list under the skin ranking: nothing matches the search. When a weapon filter is on, an 'All weapons' button sits next to the list title.
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy skin phù hợp. Thử tên khác.'**
  String get communityRankingNoSearch;

  /// Full skin list under the skin ranking: the game content (skins from valorant-api.com) is not available yet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tải được danh mục skin. Hãy thử lại sau.'**
  String get communityRankingCatalogUnavailable;

  /// Explicit decline alternative in mandatory account onboarding; signs out only the displayed account.
  ///
  /// In vi, this message translates to:
  /// **'Không đồng ý · Đăng xuất tài khoản này'**
  String get communityConsentExitAccount;

  /// Fixed ranking scope and time; product ranking always uses global all-time data.
  ///
  /// In vi, this message translates to:
  /// **'Toàn cầu · Từ trước tới giờ'**
  String get communityRankingGlobalAllTime;

  /// Heading for the real searchable skin catalog below leaderboard results.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả skin'**
  String get communityRankingCatalogTitle;

  /// A skin non-owner can read ratings but cannot submit a star rating or review.
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản phải sở hữu skin này để đánh giá. Bạn vẫn có thể xem đánh giá và bình luận của cộng đồng.'**
  String get communityReviewOwnershipRequired;

  /// Ownership lookup failed; refuse rating submission and allow retry.
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác minh được quyền sở hữu skin. Hãy tải lại Bộ sưu tập hoặc thử lại khi có mạng.'**
  String get communityReviewOwnershipUnavailable;

  /// Legacy review retained without a successful server inventory check; excluded from rating aggregates.
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá cũ · Chưa xác minh sở hữu'**
  String get communityReviewLegacyOwnership;

  /// Review inventory proof applies at the time it was saved, not a claim of current ownership.
  ///
  /// In vi, this message translates to:
  /// **'Đã xác minh sở hữu khi đánh giá'**
  String get communityReviewVerifiedOwner;

  /// Explains plain public skin discussion versus inventory-verified star reviews.
  ///
  /// In vi, this message translates to:
  /// **'Mọi người đều có thể bình luận. Chỉ chủ sở hữu skin được chấm sao và viết đánh giá.'**
  String get communitySkinDiscussionHint;

  /// CommunityStrings.addPhotos — feed
  ///
  /// In vi, this message translates to:
  /// **'Thêm ảnh'**
  String get communityAddPhotos;

  /// CommunityStrings.allModes — LFG
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get communityAllModes;

  /// CommunityStrings.allWeapons — skin votes
  ///
  /// In vi, this message translates to:
  /// **'Tất cả vũ khí'**
  String get communityAllWeapons;

  /// CommunityStrings.anonymousBanner — consent
  ///
  /// In vi, this message translates to:
  /// **'Đang xem ẩn danh'**
  String get communityAnonymousBanner;

  /// CommunityStrings.anyLanguage — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Mọi ngôn ngữ'**
  String get communityAnyLanguage;

  /// CommunityStrings.anyRank — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Mọi rank'**
  String get communityAnyRank;

  /// CommunityStrings.anyRole — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Mọi vai trò'**
  String get communityAnyRole;

  /// CommunityStrings.apply — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng'**
  String get communityApply;

  /// CommunityStrings.backToMyCountry — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Về nước bạn'**
  String get communityBackToMyCountry;

  /// CommunityStrings.blockAuthor — consent
  ///
  /// In vi, this message translates to:
  /// **'Chặn trên thiết bị'**
  String get communityBlockAuthor;

  /// CommunityStrings.charCount — general states
  ///
  /// In vi, this message translates to:
  /// **'{n}/{max}'**
  String communityCharCount(String n, String max);

  /// CommunityStrings.clearFilter — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Bỏ chọn'**
  String get communityClearFilter;

  /// CommunityStrings.codeAuto — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Để trống: ValHub tự tạo mã từ tổ đội trong game khi bạn đăng tin.'**
  String get communityCodeAuto;

  /// CommunityStrings.codeAutoFailed — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Không tạo được mã tổ đội. Hãy mở VALORANT hoặc nhập mã thủ công.'**
  String get communityCodeAutoFailed;

  /// CommunityStrings.codeInvalid — Create LFG sheet
  ///
  /// In vi, this message translates to:
  /// **'Mã gồm đúng 6 chữ cái in hoa hoặc chữ số.'**
  String get communityCodeInvalid;

  /// CommunityStrings.codeRequired — Create LFG sheet
  ///
  /// In vi, this message translates to:
  /// **'Hãy nhập hoặc tạo mã tổ đội.'**
  String get communityCodeRequired;

  /// CommunityStrings.commentHint — comments
  ///
  /// In vi, this message translates to:
  /// **'Viết bình luận…'**
  String get communityCommentHint;

  /// CommunityStrings.comments — feed
  ///
  /// In vi, this message translates to:
  /// **'{n} bình luận'**
  String communityComments(int n);

  /// CommunityStrings.commentsHeader — comments
  ///
  /// In vi, this message translates to:
  /// **'Bình luận · {n}'**
  String communityCommentsHeader(String n);

  /// CommunityStrings.commentsTitle — comments
  ///
  /// In vi, this message translates to:
  /// **'Bình luận'**
  String get communityCommentsTitle;

  /// CommunityStrings.communityActivity — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'{posts} bài · {authors} người'**
  String communityCommunityActivity(String posts, String authors);

  /// CommunityStrings.communityLfg — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'{n} tin tìm đồng đội'**
  String communityCommunityLfg(int n);

  /// CommunityStrings.communityVotes — skin votes
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng yêu thích'**
  String get communityCommunityVotes;

  /// CommunityStrings.composerHint — feed
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang nghĩ gì về VALORANT hôm nay?'**
  String get communityComposerHint;

  /// CommunityStrings.composerTitle — feed
  ///
  /// In vi, this message translates to:
  /// **'Bài viết mới'**
  String get communityComposerTitle;

  /// CommunityStrings.consentAccount — consent
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản: {riotId}'**
  String communityConsentAccount(String riotId);

  /// CommunityStrings.consentAgree — consent
  ///
  /// In vi, this message translates to:
  /// **'Đồng ý và tiếp tục'**
  String get communityConsentAgree;

  /// CommunityStrings.consentGateAction — consent
  ///
  /// In vi, this message translates to:
  /// **'Tham gia'**
  String get communityConsentGateAction;

  /// CommunityStrings.consentGuidelines — consent
  ///
  /// In vi, this message translates to:
  /// **'Tiêu chuẩn cộng đồng'**
  String get communityConsentGuidelines;

  /// CommunityStrings.consentLater — consent
  ///
  /// In vi, this message translates to:
  /// **'Để sau'**
  String get communityConsentLater;

  /// CommunityStrings.consentLocal — consent
  ///
  /// In vi, this message translates to:
  /// **'Mật khẩu và dữ liệu đăng nhập khác của bạn luôn ở lại trên thiết bị này. Bạn có thể rút lại đồng ý trong Cài đặt.'**
  String get communityConsentLocal;

  /// CommunityStrings.consentPrivacy — consent
  ///
  /// In vi, this message translates to:
  /// **'Chính sách quyền riêng tư'**
  String get communityConsentPrivacy;

  /// CommunityStrings.consentPublic — consent
  ///
  /// In vi, this message translates to:
  /// **'Người khác sẽ thấy Riot ID, thẻ người chơi, rank và quốc gia của bạn.'**
  String get communityConsentPublic;

  /// CommunityStrings.consentTitle — consent
  ///
  /// In vi, this message translates to:
  /// **'Quyền riêng tư và Cộng đồng ValHub'**
  String get communityConsentTitle;

  /// CommunityStrings.consentVerify — consent
  ///
  /// In vi, this message translates to:
  /// **'ValHub gửi quyền truy cập Riot cho máy chủ Cộng đồng để xác minh Riot ID khi kết nối và kiểm tra quyền sở hữu skin khi bạn lưu đánh giá. Máy chủ chỉ đọc dữ liệu cần thiết, dùng xong bỏ ngay quyền truy cập, không lưu.'**
  String get communityConsentVerify;

  /// CommunityStrings.consentWithdrawn — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Đã rút lại đồng ý. Cần đồng ý lại để tiếp tục sử dụng app.'**
  String get communityConsentWithdrawn;

  /// CommunityStrings.countriesTitle — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng các nước'**
  String get communityCountriesTitle;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Các Tiểu vương quốc Ả Rập Thống nhất'**
  String get communityCountryNamesAE;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Albania'**
  String get communityCountryNamesAL;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Armenia'**
  String get communityCountryNamesAM;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Argentina'**
  String get communityCountryNamesAR;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Áo'**
  String get communityCountryNamesAT;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Úc'**
  String get communityCountryNamesAU;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Azerbaijan'**
  String get communityCountryNamesAZ;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Bosnia và Herzegovina'**
  String get communityCountryNamesBA;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Bangladesh'**
  String get communityCountryNamesBD;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Bỉ'**
  String get communityCountryNamesBE;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Bulgaria'**
  String get communityCountryNamesBG;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Bahrain'**
  String get communityCountryNamesBH;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Brunei'**
  String get communityCountryNamesBN;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Bolivia'**
  String get communityCountryNamesBO;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Brazil'**
  String get communityCountryNamesBR;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Belarus'**
  String get communityCountryNamesBY;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Canada'**
  String get communityCountryNamesCA;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Thụy Sĩ'**
  String get communityCountryNamesCH;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Chile'**
  String get communityCountryNamesCL;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Trung Quốc'**
  String get communityCountryNamesCN;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Colombia'**
  String get communityCountryNamesCO;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Costa Rica'**
  String get communityCountryNamesCR;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Cuba'**
  String get communityCountryNamesCU;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Síp'**
  String get communityCountryNamesCY;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Séc'**
  String get communityCountryNamesCZ;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Đức'**
  String get communityCountryNamesDE;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Đan Mạch'**
  String get communityCountryNamesDK;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Cộng hòa Dominica'**
  String get communityCountryNamesDO;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Algeria'**
  String get communityCountryNamesDZ;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Ecuador'**
  String get communityCountryNamesEC;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Estonia'**
  String get communityCountryNamesEE;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Ai Cập'**
  String get communityCountryNamesEG;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Tây Ban Nha'**
  String get communityCountryNamesES;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Ethiopia'**
  String get communityCountryNamesET;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Phần Lan'**
  String get communityCountryNamesFI;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Pháp'**
  String get communityCountryNamesFR;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Vương quốc Anh'**
  String get communityCountryNamesGB;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Georgia'**
  String get communityCountryNamesGE;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Ghana'**
  String get communityCountryNamesGH;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Hy Lạp'**
  String get communityCountryNamesGR;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Guatemala'**
  String get communityCountryNamesGT;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Hồng Kông'**
  String get communityCountryNamesHK;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Honduras'**
  String get communityCountryNamesHN;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Croatia'**
  String get communityCountryNamesHR;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Hungary'**
  String get communityCountryNamesHU;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Indonesia'**
  String get communityCountryNamesID;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Ireland'**
  String get communityCountryNamesIE;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Israel'**
  String get communityCountryNamesIL;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Ấn Độ'**
  String get communityCountryNamesIN;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Iraq'**
  String get communityCountryNamesIQ;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Iran'**
  String get communityCountryNamesIR;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Iceland'**
  String get communityCountryNamesIS;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Ý'**
  String get communityCountryNamesIT;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Jordan'**
  String get communityCountryNamesJO;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Nhật Bản'**
  String get communityCountryNamesJP;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Kenya'**
  String get communityCountryNamesKE;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Campuchia'**
  String get communityCountryNamesKH;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Hàn Quốc'**
  String get communityCountryNamesKR;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Kuwait'**
  String get communityCountryNamesKW;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Kazakhstan'**
  String get communityCountryNamesKZ;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Lào'**
  String get communityCountryNamesLA;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Liban'**
  String get communityCountryNamesLB;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Sri Lanka'**
  String get communityCountryNamesLK;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Litva'**
  String get communityCountryNamesLT;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Luxembourg'**
  String get communityCountryNamesLU;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Latvia'**
  String get communityCountryNamesLV;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Libya'**
  String get communityCountryNamesLY;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Maroc'**
  String get communityCountryNamesMA;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Moldova'**
  String get communityCountryNamesMD;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Montenegro'**
  String get communityCountryNamesME;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Bắc Macedonia'**
  String get communityCountryNamesMK;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Myanmar'**
  String get communityCountryNamesMM;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Mông Cổ'**
  String get communityCountryNamesMN;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Ma Cao'**
  String get communityCountryNamesMO;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Malta'**
  String get communityCountryNamesMT;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Mexico'**
  String get communityCountryNamesMX;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Malaysia'**
  String get communityCountryNamesMY;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Nigeria'**
  String get communityCountryNamesNG;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Nicaragua'**
  String get communityCountryNamesNI;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Hà Lan'**
  String get communityCountryNamesNL;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Na Uy'**
  String get communityCountryNamesNO;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Nepal'**
  String get communityCountryNamesNP;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'New Zealand'**
  String get communityCountryNamesNZ;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Oman'**
  String get communityCountryNamesOM;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Panama'**
  String get communityCountryNamesPA;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Peru'**
  String get communityCountryNamesPE;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Philippines'**
  String get communityCountryNamesPH;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Pakistan'**
  String get communityCountryNamesPK;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Ba Lan'**
  String get communityCountryNamesPL;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Puerto Rico'**
  String get communityCountryNamesPR;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Bồ Đào Nha'**
  String get communityCountryNamesPT;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Paraguay'**
  String get communityCountryNamesPY;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Qatar'**
  String get communityCountryNamesQA;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Romania'**
  String get communityCountryNamesRO;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Serbia'**
  String get communityCountryNamesRS;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Nga'**
  String get communityCountryNamesRU;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Ả Rập Xê Út'**
  String get communityCountryNamesSA;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Thụy Điển'**
  String get communityCountryNamesSE;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Singapore'**
  String get communityCountryNamesSG;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Slovenia'**
  String get communityCountryNamesSI;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Slovakia'**
  String get communityCountryNamesSK;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'El Salvador'**
  String get communityCountryNamesSV;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Thái Lan'**
  String get communityCountryNamesTH;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Đông Timor'**
  String get communityCountryNamesTL;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Tunisia'**
  String get communityCountryNamesTN;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Thổ Nhĩ Kỳ'**
  String get communityCountryNamesTR;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Đài Loan'**
  String get communityCountryNamesTW;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Ukraine'**
  String get communityCountryNamesUA;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Hoa Kỳ'**
  String get communityCountryNamesUS;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Uruguay'**
  String get communityCountryNamesUY;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Uzbekistan'**
  String get communityCountryNamesUZ;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Venezuela'**
  String get communityCountryNamesVE;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Việt Nam'**
  String get communityCountryNamesVN;

  /// Country names (ISO 3166-1 alpha-2), Vietnamese for now; the i18n phase localizes them.
  ///
  /// In vi, this message translates to:
  /// **'Nam Phi'**
  String get communityCountryNamesZA;

  /// CommunityStrings.createLfg — LFG
  ///
  /// In vi, this message translates to:
  /// **'Tạo tin tìm đồng đội'**
  String get communityCreateLfg;

  /// CommunityStrings.createLfgShort — LFG
  ///
  /// In vi, this message translates to:
  /// **'Tạo tin'**
  String get communityCreateLfgShort;

  /// CommunityStrings.dataDeleted — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa dữ liệu Cộng đồng của bạn.'**
  String get communityDataDeleted;

  /// CommunityStrings.dataFooter — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng cho tài khoản đang dùng: {riotId}. Tệp tải về không chứa mật khẩu hay dữ liệu đăng nhập Riot.'**
  String communityDataFooter(String riotId);

  /// CommunityStrings.decrease — Create LFG sheet
  ///
  /// In vi, this message translates to:
  /// **'Giảm'**
  String get communityDecrease;

  /// CommunityStrings.delete — feed
  ///
  /// In vi, this message translates to:
  /// **'Xóa'**
  String get communityDelete;

  /// CommunityStrings.deleteComment — comments
  ///
  /// In vi, this message translates to:
  /// **'Xóa bình luận'**
  String get communityDeleteComment;

  /// CommunityStrings.deleteCommentBody — comments
  ///
  /// In vi, this message translates to:
  /// **'Bình luận này sẽ bị xóa vĩnh viễn.'**
  String get communityDeleteCommentBody;

  /// CommunityStrings.deleteCommentTitle — comments
  ///
  /// In vi, this message translates to:
  /// **'Xóa bình luận?'**
  String get communityDeleteCommentTitle;

  /// CommunityStrings.deleteDataConfirm — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Xóa vĩnh viễn'**
  String get communityDeleteDataConfirm;

  /// CommunityStrings.deleteDataConfirmBody — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Toàn bộ bài viết, bình luận, đánh giá skin, lượt thích, bình chọn, tin tìm đồng đội và ảnh của {riotId} trên Cộng đồng ValHub sẽ bị xóa vĩnh viễn và không thể khôi phục. Muốn dùng tiếp tài khoản này trong ValHub, bạn cần đồng ý lại; bạn vẫn có thể chuyển sang tài khoản khác hoặc đăng xuất tài khoản này.\n\nTài khoản Riot và dữ liệu trong game không bị ảnh hưởng. Hãy tải dữ liệu về trước nếu bạn muốn giữ một bản sao.'**
  String communityDeleteDataConfirmBody(String riotId);

  /// CommunityStrings.deleteDataConfirmTitle — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Xóa dữ liệu Cộng đồng?'**
  String get communityDeleteDataConfirmTitle;

  /// CommunityStrings.deleteDataSubtitle — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Xóa vĩnh viễn mọi thứ bạn đã đăng lên Cộng đồng.'**
  String get communityDeleteDataSubtitle;

  /// CommunityStrings.deleteDataTitle — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Xóa dữ liệu Cộng đồng của tôi'**
  String get communityDeleteDataTitle;

  /// CommunityStrings.deletePost — feed
  ///
  /// In vi, this message translates to:
  /// **'Xóa bài viết'**
  String get communityDeletePost;

  /// CommunityStrings.deletePostBody — feed
  ///
  /// In vi, this message translates to:
  /// **'Bài viết và toàn bộ bình luận sẽ bị xóa vĩnh viễn.'**
  String get communityDeletePostBody;

  /// CommunityStrings.deletePostTitle — feed
  ///
  /// In vi, this message translates to:
  /// **'Xóa bài viết?'**
  String get communityDeletePostTitle;

  /// CommunityStrings.deleteReview — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Xóa đánh giá'**
  String get communityDeleteReview;

  /// CommunityStrings.deleteReviewBody — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Điểm và nhận xét của bạn cho skin này sẽ bị xóa.'**
  String get communityDeleteReviewBody;

  /// CommunityStrings.deleteReviewTitle — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Xóa đánh giá của bạn?'**
  String get communityDeleteReviewTitle;

  /// CommunityStrings.deleted — feed
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa.'**
  String get communityDeleted;

  /// CommunityStrings.discard — feed
  ///
  /// In vi, this message translates to:
  /// **'Bỏ'**
  String get communityDiscard;

  /// CommunityStrings.discardBody — feed
  ///
  /// In vi, this message translates to:
  /// **'Nội dung bạn vừa viết sẽ không được lưu.'**
  String get communityDiscardBody;

  /// CommunityStrings.discardTitle — feed
  ///
  /// In vi, this message translates to:
  /// **'Bỏ bài viết?'**
  String get communityDiscardTitle;

  /// CommunityStrings.download — translation
  ///
  /// In vi, this message translates to:
  /// **'Tải và dịch'**
  String get communityDownload;

  /// CommunityStrings.downloadingModels — translation
  ///
  /// In vi, this message translates to:
  /// **'Đang tải gói dịch…'**
  String get communityDownloadingModels;

  /// CommunityStrings.editReview — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Sửa'**
  String get communityEditReview;

  /// CommunityStrings.edited — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'đã sửa'**
  String get communityEdited;

  /// CommunityStrings.emptyPost — feed
  ///
  /// In vi, this message translates to:
  /// **'Hãy viết gì đó hoặc thêm ảnh.'**
  String get communityEmptyPost;

  /// CommunityStrings.expired — LFG
  ///
  /// In vi, this message translates to:
  /// **'Đã hết hạn'**
  String get communityExpired;

  /// CommunityStrings.expiresIn — LFG
  ///
  /// In vi, this message translates to:
  /// **'Còn {t}'**
  String communityExpiresIn(String t);

  /// CommunityStrings.exportPreparing — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Đang chuẩn bị…'**
  String get communityExportPreparing;

  /// CommunityStrings.exportSubject — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu Cộng đồng ValHub'**
  String get communityExportSubject;

  /// CommunityStrings.exportSubtitle — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Bản sao mọi thứ bạn đã đăng trong Cộng đồng: bài viết, bình luận, đánh giá, lượt thích, bình chọn và tin tìm đồng đội.'**
  String get communityExportSubtitle;

  /// CommunityStrings.exportTitle — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Tải dữ liệu của tôi'**
  String get communityExportTitle;

  /// CommunityStrings.extend — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Gia hạn'**
  String get communityExtend;

  /// CommunityStrings.extended — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Đã gia hạn tin thêm 30 phút.'**
  String get communityExtended;

  /// CommunityStrings.feedEmptyBody — feed
  ///
  /// In vi, this message translates to:
  /// **'Hãy là người đầu tiên chia sẻ cửa hàng, Chợ Đêm hay khoảnh khắc của bạn!'**
  String get communityFeedEmptyBody;

  /// CommunityStrings.feedEmptyFilteredBody — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Không có bài phù hợp. Thử đổi ngôn ngữ hoặc bỏ bộ lọc.'**
  String get communityFeedEmptyFilteredBody;

  /// CommunityStrings.feedEmptyGuestBody — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bài mới. Quay lại sau hoặc tham gia để chia sẻ.'**
  String get communityFeedEmptyGuestBody;

  /// CommunityStrings.feedEmptyScopeBody — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Thử xem bài từ cộng đồng quốc tế hoặc đổi bộ lọc.'**
  String get communityFeedEmptyScopeBody;

  /// CommunityStrings.feedEmptyScopeTitle — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bài trong phạm vi này'**
  String get communityFeedEmptyScopeTitle;

  /// CommunityStrings.feedEmptyTitle — feed
  ///
  /// In vi, this message translates to:
  /// **'Bảng tin còn trống'**
  String get communityFeedEmptyTitle;

  /// CommunityStrings.filters — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Bộ lọc'**
  String get communityFilters;

  /// CommunityStrings.googleDisclaimer — translation
  ///
  /// In vi, this message translates to:
  /// **'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.'**
  String get communityGoogleDisclaimer;

  /// CommunityStrings.googleDisclaimerTitle — translation
  ///
  /// In vi, this message translates to:
  /// **'Bản dịch của Google'**
  String get communityGoogleDisclaimerTitle;

  /// CommunityStrings.helpful — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Hữu ích'**
  String get communityHelpful;

  /// CommunityStrings.helpfulCount — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Hữu ích · {n}'**
  String communityHelpfulCount(String n);

  /// CommunityStrings.hiddenAuthors — consent
  ///
  /// In vi, this message translates to:
  /// **'Người đã ẩn và chặn'**
  String get communityHiddenAuthors;

  /// CommunityStrings.hiddenAuthorsEmpty — consent
  ///
  /// In vi, this message translates to:
  /// **'Chưa ẩn hoặc chặn ai'**
  String get communityHiddenAuthorsEmpty;

  /// CommunityStrings.hiddenAuthorsHint — consent
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng riêng cho tài khoản này trên thiết bị này. Nội dung của họ được ẩn; họ vẫn có thể xem nội dung công khai của bạn.'**
  String get communityHiddenAuthorsHint;

  /// CommunityStrings.imageOf — feed
  ///
  /// In vi, this message translates to:
  /// **'Ảnh {i}/{n}'**
  String communityImageOf(int i, int n);

  /// CommunityStrings.increase — Create LFG sheet
  ///
  /// In vi, this message translates to:
  /// **'Tăng'**
  String get communityIncrease;

  /// CommunityStrings.join — LFG
  ///
  /// In vi, this message translates to:
  /// **'Vào'**
  String get communityJoin;

  /// CommunityStrings.joinCodeExpired — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Mã tổ đội đã hết hạn hoặc không còn hiệu lực.'**
  String get communityJoinCodeExpired;

  /// CommunityStrings.joinConfirmBody — LFG
  ///
  /// In vi, this message translates to:
  /// **'Bạn sẽ rời tổ đội hiện tại trong VALORANT để vào tổ đội của {name}.'**
  String communityJoinConfirmBody(String name);

  /// CommunityStrings.joinConfirmTitle — LFG
  ///
  /// In vi, this message translates to:
  /// **'Vào tổ đội này?'**
  String get communityJoinConfirmTitle;

  /// CommunityStrings.joinGameNotRunning — LFG
  ///
  /// In vi, this message translates to:
  /// **'Hãy mở VALORANT trên máy tính hoặc console rồi thử lại.'**
  String get communityJoinGameNotRunning;

  /// CommunityStrings.joinParty — LFG
  ///
  /// In vi, this message translates to:
  /// **'Vào tổ đội'**
  String get communityJoinParty;

  /// CommunityStrings.joinPartyFull — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Tổ đội này đã đủ người.'**
  String get communityJoinPartyFull;

  /// CommunityStrings.joinedHint — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Đã vào tổ đội! Mở VALORANT để chơi cùng nhau.'**
  String get communityJoinedHint;

  /// CommunityStrings.joinsCount — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'{n} người đã yêu cầu vào'**
  String communityJoinsCount(int n);

  /// CommunityStrings.kindNightMarket — feed
  ///
  /// In vi, this message translates to:
  /// **'Chợ Đêm'**
  String get communityKindNightMarket;

  /// CommunityStrings.kindStore — feed
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng hôm nay'**
  String get communityKindStore;

  /// CommunityStrings.language — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ'**
  String get communityLanguage;

  /// CommunityStrings.languageFilter — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ nội dung'**
  String get communityLanguageFilter;

  /// CommunityStrings.languageFilterHint — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Chỉ hiện nội dung viết bằng các ngôn ngữ đã chọn. Bỏ trống để xem tất cả.'**
  String get communityLanguageFilterHint;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'العربية'**
  String get communityLanguageNamesAr;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'Deutsch'**
  String get communityLanguageNamesDe;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'English'**
  String get communityLanguageNamesEn;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'Español'**
  String get communityLanguageNamesEs;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'Français'**
  String get communityLanguageNamesFr;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'Bahasa Indonesia'**
  String get communityLanguageNamesId;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'Italiano'**
  String get communityLanguageNamesIt;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'日本語'**
  String get communityLanguageNamesJa;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'한국어'**
  String get communityLanguageNamesKo;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'Polski'**
  String get communityLanguageNamesPl;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'Português'**
  String get communityLanguageNamesPt;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'Русский'**
  String get communityLanguageNamesRu;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'ไทย'**
  String get communityLanguageNamesTh;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'Türkçe'**
  String get communityLanguageNamesTr;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get communityLanguageNamesVi;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'简体中文'**
  String get communityLanguageNamesZhCN;

  /// VALORANT languages by their native names (not translated).
  ///
  /// In vi, this message translates to:
  /// **'繁體中文'**
  String get communityLanguageNamesZhTW;

  /// CommunityStrings.languagesSelected — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'{n} ngôn ngữ'**
  String communityLanguagesSelected(int n);

  /// CommunityStrings.lfgEmptyBody — LFG
  ///
  /// In vi, this message translates to:
  /// **'Tạo tin để người chơi khác vào tổ đội của bạn chỉ với một chạm.'**
  String get communityLfgEmptyBody;

  /// CommunityStrings.lfgEmptyTitle — LFG
  ///
  /// In vi, this message translates to:
  /// **'Chưa ai tìm đồng đội'**
  String get communityLfgEmptyTitle;

  /// CommunityStrings.lfgExpiredRepost — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Tin của bạn đã hết hạn. Hãy đăng tin mới để tìm đồng đội.'**
  String get communityLfgExpiredRepost;

  /// CommunityStrings.lfgGateBody — consent
  ///
  /// In vi, this message translates to:
  /// **'Tham gia (xác minh Riot ID một lần) để xem tin của người chơi cùng máy chủ và đăng tin tìm đồng đội của bạn. Bạn vẫn xem Bảng tin và Xếp hạng skin bình thường.'**
  String get communityLfgGateBody;

  /// CommunityStrings.lfgGateTitle — consent
  ///
  /// In vi, this message translates to:
  /// **'Tìm đồng đội dành cho thành viên'**
  String get communityLfgGateTitle;

  /// CommunityStrings.lfgOtherShardNote — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang xem máy chủ {region} — chỉ người cùng máy chủ với tài khoản của bạn mới vào tổ đội được.'**
  String communityLfgOtherShardNote(String region);

  /// CommunityStrings.lfgPosted — LFG
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng tin tìm đồng đội!'**
  String get communityLfgPosted;

  /// CommunityStrings.lfgPreviewTitle — previews
  ///
  /// In vi, this message translates to:
  /// **'Tìm đồng đội hợp rank'**
  String get communityLfgPreviewTitle;

  /// CommunityStrings.lfgRemoved — LFG
  ///
  /// In vi, this message translates to:
  /// **'Đã gỡ tin.'**
  String get communityLfgRemoved;

  /// CommunityStrings.lfgSameShardNote — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Chỉ người cùng máy chủ mới vào tổ đội được.'**
  String get communityLfgSameShardNote;

  /// CommunityStrings.lfgSheetSubtitle — LFG
  ///
  /// In vi, this message translates to:
  /// **'Khu vực: {region} · Tin tự hết hạn sau 30 phút.'**
  String communityLfgSheetSubtitle(String region);

  /// CommunityStrings.like — feed
  ///
  /// In vi, this message translates to:
  /// **'Thích'**
  String get communityLike;

  /// CommunityStrings.liveMembers — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Thành viên'**
  String get communityLiveMembers;

  /// CommunityStrings.matchMyRank — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Phù hợp rank của bạn'**
  String get communityMatchMyRank;

  /// CommunityStrings.memberJoined — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'{name} đã vào tổ đội'**
  String communityMemberJoined(String name);

  /// CommunityStrings.memberJoinedBody — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Tin tìm đồng đội của bạn vừa có người vào.'**
  String get communityMemberJoinedBody;

  /// CommunityStrings.mic — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Cần mic'**
  String get communityMic;

  /// CommunityStrings.micOn — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Có mic'**
  String get communityMicOn;

  /// CommunityStrings.mode — Create LFG sheet
  ///
  /// In vi, this message translates to:
  /// **'Chế độ'**
  String get communityMode;

  /// CommunityStrings.modelSize — translation
  ///
  /// In vi, this message translates to:
  /// **'{mb} MB'**
  String communityModelSize(int mb);

  /// CommunityStrings.moreActions — general states
  ///
  /// In vi, this message translates to:
  /// **'Tùy chọn khác'**
  String get communityMoreActions;

  /// CommunityStrings.muteAuthor — consent
  ///
  /// In vi, this message translates to:
  /// **'Ẩn người này'**
  String get communityMuteAuthor;

  /// CommunityStrings.newPost — feed
  ///
  /// In vi, this message translates to:
  /// **'Đăng bài'**
  String get communityNewPost;

  /// CommunityStrings.nightMarketOf — feed
  ///
  /// In vi, this message translates to:
  /// **'Chợ Đêm ngày {date}'**
  String communityNightMarketOf(String date);

  /// CommunityStrings.noAccountBody — general states
  ///
  /// In vi, this message translates to:
  /// **'Thêm tài khoản Riot để đăng bài, tìm đồng đội và bình chọn skin.'**
  String get communityNoAccountBody;

  /// CommunityStrings.noAccountTitle — general states
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập để tham gia'**
  String get communityNoAccountTitle;

  /// CommunityStrings.noComments — comments
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bình luận. Hãy mở lời trước nhé!'**
  String get communityNoComments;

  /// CommunityStrings.noRatings — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đánh giá'**
  String get communityNoRatings;

  /// CommunityStrings.note — Create LFG sheet
  ///
  /// In vi, this message translates to:
  /// **'Ghi chú'**
  String get communityNote;

  /// CommunityStrings.noteHint — Create LFG sheet
  ///
  /// In vi, this message translates to:
  /// **'VD: cần 1 người Kiểm soát, có mic, vui vẻ là chính'**
  String get communityNoteHint;

  /// CommunityStrings.offerSemantics — feed
  ///
  /// In vi, this message translates to:
  /// **'{name}, {price}'**
  String communityOfferSemantics(String name, String price);

  /// CommunityStrings.offersTotal — feed
  ///
  /// In vi, this message translates to:
  /// **'Tổng {amount}'**
  String communityOffersTotal(String amount);

  /// CommunityStrings.openReviews — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Xem đánh giá'**
  String get communityOpenReviews;

  /// CommunityStrings.outOfRange — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Ngoài khoảng rank'**
  String get communityOutOfRange;

  /// CommunityStrings.pageOf — general states
  ///
  /// In vi, this message translates to:
  /// **'{i}/{n}'**
  String communityPageOf(String i, String n);

  /// CommunityStrings.partyCode — Create LFG sheet
  ///
  /// In vi, this message translates to:
  /// **'Mã tổ đội'**
  String get communityPartyCode;

  /// CommunityStrings.partyCodeHint — Create LFG sheet
  ///
  /// In vi, this message translates to:
  /// **'VD: A1B2C3'**
  String get communityPartyCodeHint;

  /// CommunityStrings.partyCodeValue — LFG
  ///
  /// In vi, this message translates to:
  /// **'Mã tổ đội: {code}'**
  String communityPartyCodeValue(String code);

  /// CommunityStrings.partySize — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Tổ đội hiện có'**
  String get communityPartySize;

  /// CommunityStrings.partySizeFromGame — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Lấy từ tổ đội trong game'**
  String get communityPartySizeFromGame;

  /// CommunityStrings.partySizeValue — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'{n} người'**
  String communityPartySizeValue(int n);

  /// CommunityStrings.photoCount — feed
  ///
  /// In vi, this message translates to:
  /// **'{n}/{max} ảnh'**
  String communityPhotoCount(int n, int max);

  /// CommunityStrings.playVideo — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Xem video'**
  String get communityPlayVideo;

  /// CommunityStrings.postLfg — Create LFG sheet
  ///
  /// In vi, this message translates to:
  /// **'Đăng tin'**
  String get communityPostLfg;

  /// CommunityStrings.postNotFound — comments
  ///
  /// In vi, this message translates to:
  /// **'Bài viết này đã bị xóa hoặc ẩn.'**
  String get communityPostNotFound;

  /// CommunityStrings.postTitle — comments
  ///
  /// In vi, this message translates to:
  /// **'Bài viết'**
  String get communityPostTitle;

  /// CommunityStrings.posted — feed
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng bài!'**
  String get communityPosted;

  /// CommunityStrings.publish — feed
  ///
  /// In vi, this message translates to:
  /// **'Đăng'**
  String get communityPublish;

  /// CommunityStrings.publishing — feed
  ///
  /// In vi, this message translates to:
  /// **'Đang đăng…'**
  String get communityPublishing;

  /// CommunityStrings.rankBetween — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'{a} – {b}'**
  String communityRankBetween(String a, String b);

  /// CommunityStrings.rankFrom — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Từ'**
  String get communityRankFrom;

  /// CommunityStrings.rankNumber — skin votes
  ///
  /// In vi, this message translates to:
  /// **'#{n}'**
  String communityRankNumber(String n);

  /// CommunityStrings.rankRange — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Khoảng rank'**
  String get communityRankRange;

  /// CommunityStrings.rankRangeInvalid — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Hãy chọn rank thấp nhất không cao hơn rank cao nhất.'**
  String get communityRankRangeInvalid;

  /// CommunityStrings.rankSemantics — skin votes
  ///
  /// In vi, this message translates to:
  /// **'Hạng {n}: {name}'**
  String communityRankSemantics(String n, String name);

  /// CommunityStrings.rankTo — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Đến'**
  String get communityRankTo;

  /// CommunityStrings.rateLimitedTitle — errors
  ///
  /// In vi, this message translates to:
  /// **'Hãy đợi một chút'**
  String get communityRateLimitedTitle;

  /// CommunityStrings.ratingCount — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'{n} đánh giá'**
  String communityRatingCount(int n);

  /// CommunityStrings.ratingSummary — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'{avg} · {n} đánh giá'**
  String communityRatingSummary(String avg, int n);

  /// CommunityStrings.ratingWords — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Tệ'**
  String get communityRatingWordsItem0;

  /// CommunityStrings.ratingWords — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Chưa ổn'**
  String get communityRatingWordsItem1;

  /// CommunityStrings.ratingWords — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Ổn'**
  String get communityRatingWordsItem2;

  /// CommunityStrings.ratingWords — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Đẹp'**
  String get communityRatingWordsItem3;

  /// CommunityStrings.ratingWords — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Tuyệt phẩm'**
  String get communityRatingWordsItem4;

  /// CommunityStrings.refreshList — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Làm mới'**
  String get communityRefreshList;

  /// CommunityStrings.region — LFG
  ///
  /// In vi, this message translates to:
  /// **'Khu vực'**
  String get communityRegion;

  /// CommunityStrings.removeAttachment — feed
  ///
  /// In vi, this message translates to:
  /// **'Bỏ đính kèm'**
  String get communityRemoveAttachment;

  /// CommunityStrings.removeLfg — LFG
  ///
  /// In vi, this message translates to:
  /// **'Gỡ tin'**
  String get communityRemoveLfg;

  /// CommunityStrings.removeLfgBody — LFG
  ///
  /// In vi, this message translates to:
  /// **'Người khác sẽ không thấy tin này nữa.'**
  String get communityRemoveLfgBody;

  /// CommunityStrings.removeLfgTitle — LFG
  ///
  /// In vi, this message translates to:
  /// **'Gỡ tin tìm đồng đội?'**
  String get communityRemoveLfgTitle;

  /// CommunityStrings.removePhoto — feed
  ///
  /// In vi, this message translates to:
  /// **'Bỏ ảnh'**
  String get communityRemovePhoto;

  /// CommunityStrings.report — feed
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo'**
  String get communityReport;

  /// CommunityStrings.reportConfirmBody — feed
  ///
  /// In vi, this message translates to:
  /// **'Nội dung bị nhiều người báo cáo sẽ được ẩn khỏi Cộng đồng.'**
  String get communityReportConfirmBody;

  /// CommunityStrings.reportConfirmTitle — feed
  ///
  /// In vi, this message translates to:
  /// **'Gửi báo cáo?'**
  String get communityReportConfirmTitle;

  /// CommunityStrings.reportPrompt — feed
  ///
  /// In vi, this message translates to:
  /// **'Vì sao bạn báo cáo nội dung này?'**
  String get communityReportPrompt;

  /// Report reasons: server value → label.
  ///
  /// In vi, this message translates to:
  /// **'Spam hoặc quảng cáo'**
  String get communityReportReasonsSpam;

  /// Report reasons: server value → label.
  ///
  /// In vi, this message translates to:
  /// **'Quấy rối, xúc phạm'**
  String get communityReportReasonsHarassment;

  /// Report reasons: server value → label.
  ///
  /// In vi, this message translates to:
  /// **'Nội dung không phù hợp'**
  String get communityReportReasonsInappropriate;

  /// Report reasons: server value → label.
  ///
  /// In vi, this message translates to:
  /// **'Lừa đảo, mua bán tài khoản'**
  String get communityReportReasonsScam;

  /// Report reasons: server value → label.
  ///
  /// In vi, this message translates to:
  /// **'Lý do khác'**
  String get communityReportReasonsOther;

  /// CommunityStrings.reportTitle — feed
  ///
  /// In vi, this message translates to:
  /// **'Báo cáo nội dung'**
  String get communityReportTitle;

  /// CommunityStrings.reported — feed
  ///
  /// In vi, this message translates to:
  /// **'Cảm ơn bạn! Báo cáo đã được gửi.'**
  String get communityReported;

  /// CommunityStrings.reviewDeleted — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa đánh giá.'**
  String get communityReviewDeleted;

  /// CommunityStrings.reviewHint — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ cảm nhận về skin này (không bắt buộc)'**
  String get communityReviewHint;

  /// CommunityStrings.reviewSaved — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu đánh giá!'**
  String get communityReviewSaved;

  /// CommunityStrings.reviewTitle — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá skin'**
  String get communityReviewTitle;

  /// CommunityStrings.reviewsEmptyBody — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đánh giá — hãy là người đầu tiên!'**
  String get communityReviewsEmptyBody;

  /// CommunityStrings.reviewsEmptyTitle — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Chưa có đánh giá'**
  String get communityReviewsEmptyTitle;

  /// CommunityStrings.reviewsHeader — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá · {n}'**
  String communityReviewsHeader(String n);

  /// CommunityStrings.riotId — general states
  ///
  /// In vi, this message translates to:
  /// **'{name}#{tag}'**
  String communityRiotId(String name, String tag);

  /// CommunityStrings.riotUnavailableTitle — errors
  ///
  /// In vi, this message translates to:
  /// **'Riot đang gặp sự cố'**
  String get communityRiotUnavailableTitle;

  /// CommunityStrings.roleFlex — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Linh hoạt'**
  String get communityRoleFlex;

  /// CommunityStrings.roles — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Vai trò cần'**
  String get communityRoles;

  /// CommunityStrings.saveReview — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Lưu đánh giá'**
  String get communitySaveReview;

  /// CommunityStrings.scopeCountry — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Nước bạn'**
  String get communityScopeCountry;

  /// CommunityStrings.scopeGlobal — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Quốc tế'**
  String get communityScopeGlobal;

  /// CommunityStrings.scopeRegion — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Khu vực'**
  String get communityScopeRegion;

  /// CommunityStrings.sectionFeed — sections
  ///
  /// In vi, this message translates to:
  /// **'Bảng tin'**
  String get communitySectionFeed;

  /// CommunityStrings.sectionLfg — sections
  ///
  /// In vi, this message translates to:
  /// **'Tìm đồng đội'**
  String get communitySectionLfg;

  /// CommunityStrings.sectionSkins — sections
  ///
  /// In vi, this message translates to:
  /// **'Xếp hạng skin'**
  String get communitySectionSkins;

  /// CommunityStrings.send — feed
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get communitySend;

  /// CommunityStrings.sendComment — comments
  ///
  /// In vi, this message translates to:
  /// **'Gửi bình luận'**
  String get communitySendComment;

  /// CommunityStrings.shareNightMarketHint — share
  ///
  /// In vi, this message translates to:
  /// **'Khoe Chợ Đêm của bạn với mọi người'**
  String get communityShareNightMarketHint;

  /// CommunityStrings.sharePostTitle — share
  ///
  /// In vi, this message translates to:
  /// **'Bài viết của {name} trên ValHub'**
  String communitySharePostTitle(String name);

  /// CommunityStrings.shareStore — share
  ///
  /// In vi, this message translates to:
  /// **'Khoe lên Cộng đồng'**
  String get communityShareStore;

  /// CommunityStrings.shareStoreHint — share
  ///
  /// In vi, this message translates to:
  /// **'Khoe cửa hàng hôm nay với mọi người'**
  String get communityShareStoreHint;

  /// CommunityStrings.showOriginal — translation
  ///
  /// In vi, this message translates to:
  /// **'Xem bản gốc'**
  String get communityShowOriginal;

  /// CommunityStrings.showTranslation — translation
  ///
  /// In vi, this message translates to:
  /// **'Xem bản dịch'**
  String get communityShowTranslation;

  /// CommunityStrings.signInToReview — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Thêm tài khoản Riot để đánh giá skin.'**
  String get communitySignInToReview;

  /// CommunityStrings.skinNotFound — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy skin này.'**
  String get communitySkinNotFound;

  /// CommunityStrings.slots — Create LFG sheet
  ///
  /// In vi, this message translates to:
  /// **'Số người cần'**
  String get communitySlots;

  /// CommunityStrings.slotsTooMany — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Tổ đội có tối đa 5 người: chỉ còn {max} chỗ.'**
  String communitySlotsTooMany(int max);

  /// CommunityStrings.slotsWanted — LFG
  ///
  /// In vi, this message translates to:
  /// **'Cần {n} người'**
  String communitySlotsWanted(int n);

  /// CommunityStrings.sortHelpful — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Hữu ích nhất'**
  String get communitySortHelpful;

  /// CommunityStrings.sortNewest — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Mới nhất'**
  String get communitySortNewest;

  /// CommunityStrings.sortRating — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá cao nhất'**
  String get communitySortRating;

  /// CommunityStrings.sortReviews — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Nhiều đánh giá nhất'**
  String get communitySortReviews;

  /// CommunityStrings.sortVotes — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Yêu thích nhất'**
  String get communitySortVotes;

  /// CommunityStrings.starLabel — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'{n} sao'**
  String communityStarLabel(int n);

  /// CommunityStrings.starsSemantics — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'{avg} trên 5 sao'**
  String communityStarsSemantics(String avg);

  /// CommunityStrings.statusFull — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Đã đủ người'**
  String get communityStatusFull;

  /// CommunityStrings.statusInGame — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Đang trong trận'**
  String get communityStatusInGame;

  /// CommunityStrings.statusOpen — LFG v2
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm'**
  String get communityStatusOpen;

  /// CommunityStrings.storeOf — feed
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng ngày {date}'**
  String communityStoreOf(String date);

  /// CommunityStrings.tagSuffix — general states
  ///
  /// In vi, this message translates to:
  /// **'#{tag}'**
  String communityTagSuffix(String tag);

  /// CommunityStrings.tapToRate — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào sao để chấm điểm skin này'**
  String get communityTapToRate;

  /// CommunityStrings.title —
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng'**
  String get communityTitle;

  /// CommunityStrings.tooLong — feed
  ///
  /// In vi, this message translates to:
  /// **'Tối đa {max} ký tự.'**
  String communityTooLong(int max);

  /// CommunityStrings.translate — translation
  ///
  /// In vi, this message translates to:
  /// **'Dịch bằng Google'**
  String get communityTranslate;

  /// CommunityStrings.translateDownloadBody — translation
  ///
  /// In vi, this message translates to:
  /// **'Để dịch từ {from} sang {to}, ValHub cần tải gói ngôn ngữ từ Google (khoảng {size}). Chỉ tải một lần; nội dung được dịch hoàn toàn trên máy của bạn và không gửi tới máy chủ nào.'**
  String communityTranslateDownloadBody(String from, String to, String size);

  /// CommunityStrings.translateDownloadTitle — translation
  ///
  /// In vi, this message translates to:
  /// **'Tải gói dịch trên máy?'**
  String get communityTranslateDownloadTitle;

  /// CommunityStrings.translateFailed — translation
  ///
  /// In vi, this message translates to:
  /// **'Không dịch được. Hãy thử lại.'**
  String get communityTranslateFailed;

  /// CommunityStrings.translatedByGoogle — translation
  ///
  /// In vi, this message translates to:
  /// **'Dịch tự động bởi Google'**
  String get communityTranslatedByGoogle;

  /// CommunityStrings.translating — translation
  ///
  /// In vi, this message translates to:
  /// **'Đang dịch…'**
  String get communityTranslating;

  /// CommunityStrings.trendingTitle — previews
  ///
  /// In vi, this message translates to:
  /// **'Skin được yêu thích toàn cầu'**
  String get communityTrendingTitle;

  /// CommunityStrings.unavailableBody — general states
  ///
  /// In vi, this message translates to:
  /// **'Chưa kết nối được Cộng đồng ValHub. Hãy thử lại sau ít phút.'**
  String get communityUnavailableBody;

  /// CommunityStrings.unavailableTitle — general states
  ///
  /// In vi, this message translates to:
  /// **'Chưa kết nối được Cộng đồng'**
  String get communityUnavailableTitle;

  /// CommunityStrings.unhideAuthor — consent
  ///
  /// In vi, this message translates to:
  /// **'Bỏ ẩn / bỏ chặn'**
  String get communityUnhideAuthor;

  /// CommunityStrings.unknownPlayer — general states
  ///
  /// In vi, this message translates to:
  /// **'Người chơi'**
  String get communityUnknownPlayer;

  /// CommunityStrings.unlike — feed
  ///
  /// In vi, this message translates to:
  /// **'Bỏ thích'**
  String get communityUnlike;

  /// CommunityStrings.unvote — skin votes
  ///
  /// In vi, this message translates to:
  /// **'Bỏ tim'**
  String get communityUnvote;

  /// CommunityStrings.vote — skin votes
  ///
  /// In vi, this message translates to:
  /// **'Thả tim cho skin này'**
  String get communityVote;

  /// CommunityStrings.votes — skin votes
  ///
  /// In vi, this message translates to:
  /// **'{n} lượt thích'**
  String communityVotes(int n);

  /// CommunityStrings.withdrawConfirm — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Rút lại'**
  String get communityWithdrawConfirm;

  /// CommunityStrings.withdrawConfirmBody — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'ValHub sẽ ngừng dùng Cộng đồng bằng {riotId} và xóa kết nối Cộng đồng trên thiết bị này. Muốn dùng tiếp tài khoản này trong ValHub, bạn cần đồng ý lại; bạn vẫn có thể chuyển sang tài khoản khác hoặc đăng xuất tài khoản này.\n\nBài viết, bình luận, đánh giá, bình chọn và tin tìm đồng đội đã đăng vẫn còn trên Cộng đồng và vẫn hiện Riot ID của bạn cho đến khi bạn xóa chúng từng cái, hoặc chọn \"Xóa dữ liệu Cộng đồng của tôi\".'**
  String communityWithdrawConfirmBody(String riotId);

  /// CommunityStrings.withdrawConfirmTitle — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Rút lại đồng ý?'**
  String get communityWithdrawConfirmTitle;

  /// CommunityStrings.withdrawSubtitle — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Ngừng dùng Cộng đồng bằng tài khoản này. Bài đã đăng vẫn được giữ.'**
  String get communityWithdrawSubtitle;

  /// CommunityStrings.withdrawTitle — data rights (Settings)
  ///
  /// In vi, this message translates to:
  /// **'Rút lại đồng ý'**
  String get communityWithdrawTitle;

  /// CommunityStrings.writeFirstReview — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Viết đánh giá đầu tiên'**
  String get communityWriteFirstReview;

  /// CommunityStrings.you — general states
  ///
  /// In vi, this message translates to:
  /// **'Bạn'**
  String get communityYou;

  /// CommunityStrings.yourCountry — scopes (v3)
  ///
  /// In vi, this message translates to:
  /// **'Nước của bạn'**
  String get communityYourCountry;

  /// CommunityStrings.yourReview — skin reviews
  ///
  /// In vi, this message translates to:
  /// **'Đánh giá của bạn'**
  String get communityYourReview;

  /// Subtitle of 'Người đã ẩn và chặn' in Settings: how many people this account hid or blocked.
  ///
  /// In vi, this message translates to:
  /// **'{n, plural, other{Đã ẩn {n} người}}'**
  String communityHiddenAuthorsCount(int n);

  /// LFG card: label of the disabled join button on a post from a server other than the player's account (Riot only lets players of the same server join a party). Keep it short: it sits in a button.
  ///
  /// In vi, this message translates to:
  /// **'Không cùng máy chủ'**
  String get communityLfgOtherServer;

  /// LFG empty state while the default 'Matches your rank' filter is on: nothing fits the player's rank.
  ///
  /// In vi, this message translates to:
  /// **'Không có tin hợp rank của bạn'**
  String get communityLfgEmptyRankTitle;

  /// LFG empty state body while the 'Matches your rank' filter is on: posts whose rank range excludes the player are hidden.
  ///
  /// In vi, this message translates to:
  /// **'Đang ẩn các tin không nhận rank của bạn.'**
  String get communityLfgEmptyRankBody;

  /// LFG empty state action: turns off the 'Matches your rank' filter to list posts of every rank.
  ///
  /// In vi, this message translates to:
  /// **'Xem mọi rank'**
  String get communityLfgShowAllRanks;

  /// Title of the full skin list under the skin ranking while the page's weapon filter is on (weapon = localized weapon name from valorant-api.com).
  ///
  /// In vi, this message translates to:
  /// **'Tất cả skin {weapon}'**
  String communityRankingCatalogWeaponTitle(String weapon);

  /// Title of the post page when the post was deleted or hidden (the message below says which may have happened).
  ///
  /// In vi, this message translates to:
  /// **'Bài viết không còn nữa'**
  String get communityPostGoneTitle;

  /// Explicit render-time message, preserving existing VI behavior.
  ///
  /// In vi, this message translates to:
  /// **'Bạn: {kda}{hasAcs, select, yes{ · ACS {acs}} other{}}'**
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs);

  /// LiveGameStrings.acs — Ended (G11)
  ///
  /// In vi, this message translates to:
  /// **'ACS'**
  String get liveGameAcs;

  /// LiveGameStrings.agentSelect — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Đang chọn đặc vụ'**
  String get liveGameAgentSelect;

  /// LiveGameStrings.anonymous — Rosters (G5, G6)
  ///
  /// In vi, this message translates to:
  /// **'Ẩn danh'**
  String get liveGameAnonymous;

  /// LiveGameStrings.autoRefreshNote — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Tự động làm mới khi có trận.'**
  String get liveGameAutoRefreshNote;

  /// LiveGameStrings.currentGame — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Trận hiện tại'**
  String get liveGameCurrentGame;

  /// LiveGameStrings.emptyTeam — Rosters (G5, G6)
  ///
  /// In vi, this message translates to:
  /// **'Chưa có người chơi.'**
  String get liveGameEmptyTeam;

  /// LiveGameStrings.enemyHiddenInAgentSelect — Agent select (G4)
  ///
  /// In vi, this message translates to:
  /// **'Đội địch sẽ hiện khi trận đấu bắt đầu.'**
  String get liveGameEnemyHiddenInAgentSelect;

  /// "Đội địch đã khóa 4/5".
  ///
  /// In vi, this message translates to:
  /// **'Đội địch đã khóa {locked}/{size}'**
  String liveGameEnemyLocked(int locked, int size);

  /// One short muted line over each team list during a running match: Riot's live data has no kills/deaths/assists; the scoreboard comes with the published match after it ends.
  ///
  /// In vi, this message translates to:
  /// **'K/D/A và bảng điểm có sau khi trận kết thúc.'**
  String get liveGameLiveStatsUnavailable;

  /// LiveGameStrings.finalScoreboard — Ended (G11)
  ///
  /// In vi, this message translates to:
  /// **'Bảng điểm cuối trận'**
  String get liveGameFinalScoreboard;

  /// LiveGameStrings.flex — Player loadout (S51)
  ///
  /// In vi, this message translates to:
  /// **'Flex'**
  String get liveGameFlex;

  /// LiveGameStrings.inLobby — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Đang ở sảnh chờ'**
  String get liveGameInLobby;

  /// LiveGameStrings.inMatch — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Đang đấu'**
  String get liveGameInMatch;

  /// LiveGameStrings.inQueue — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm trận'**
  String get liveGameInQueue;

  /// "Đang tìm trận · 01:32".
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm trận · {elapsed}'**
  String liveGameInQueueFor(String elapsed);

  /// LiveGameStrings.kda — Ended (G11)
  ///
  /// In vi, this message translates to:
  /// **'K/D/A'**
  String get liveGameKda;

  /// "Cấp 120".
  ///
  /// In vi, this message translates to:
  /// **'Cấp {n}'**
  String liveGameLevel(int n);

  /// LiveGameStrings.liveScore — Live score (G7)
  ///
  /// In vi, this message translates to:
  /// **'Tỉ số trực tiếp'**
  String get liveGameLiveScore;

  /// LiveGameStrings.loadoutFromAgentSelect — Player loadout (S51)
  ///
  /// In vi, this message translates to:
  /// **'Trang bị lúc chọn đặc vụ'**
  String get liveGameLoadoutFromAgentSelect;

  /// LiveGameStrings.loadoutFromMatch — Player loadout (S51)
  ///
  /// In vi, this message translates to:
  /// **'Trang bị trong trận này'**
  String get liveGameLoadoutFromMatch;

  /// LiveGameStrings.lobbyHint — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Khi tìm được trận, ValHub sẽ hiện đội hình và rank của mọi người.'**
  String get liveGameLobbyHint;

  /// LiveGameStrings.lockedTag — Rosters (G5, G6)
  ///
  /// In vi, this message translates to:
  /// **'Đã khóa'**
  String get liveGameLockedTag;

  /// LiveGameStrings.matchPendingHint — Ended (G11)
  ///
  /// In vi, this message translates to:
  /// **'ValHub sẽ tự thử lại. Bảng điểm thường có sau khoảng một phút.'**
  String get liveGameMatchPendingHint;

  /// LiveGameStrings.noAgentYet — Rosters (G5, G6)
  ///
  /// In vi, this message translates to:
  /// **'Chưa chọn đặc vụ'**
  String get liveGameNoAgentYet;

  /// LiveGameStrings.noLoadout — Player loadout (S51)
  ///
  /// In vi, this message translates to:
  /// **'Không có thông tin trang bị của người chơi này.'**
  String get liveGameNoLoadout;

  /// LiveGameStrings.notInGame — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Không trong trận'**
  String get liveGameNotInGame;

  /// LiveGameStrings.notInGameHint — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Mở VALORANT và tìm trận — chi tiết trận sẽ tự hiện ở đây khi bạn vào màn hình chọn đặc vụ.'**
  String get liveGameNotInGameHint;

  /// LiveGameStrings.notInGameTitle — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Bạn không ở trong trận nào'**
  String get liveGameNotInGameTitle;

  /// LiveGameStrings.openLoadoutOf — Rosters (G5, G6)
  ///
  /// In vi, this message translates to:
  /// **'Xem trang bị của {name}'**
  String liveGameOpenLoadoutOf(String name);

  /// Opens the party & queue screen (from the idle states).
  ///
  /// In vi, this message translates to:
  /// **'Mở tổ đội & hàng chờ'**
  String get liveGameOpenParty;

  /// LiveGameStrings.party — Rosters (G5, G6)
  ///
  /// In vi, this message translates to:
  /// **'Tổ đội'**
  String get liveGameParty;

  /// "Cao nhất: Vàng 3".
  ///
  /// In vi, this message translates to:
  /// **'Cao nhất: {rank}'**
  String liveGamePeak(String rank);

  /// "Trang bị của Tên#TAG".
  ///
  /// In vi, this message translates to:
  /// **'Trang bị của {name}'**
  String liveGamePlayerLoadoutOf(String name);

  /// LiveGameStrings.playerLoadoutTitle — Player loadout (S51)
  ///
  /// In vi, this message translates to:
  /// **'Trang bị'**
  String get liveGamePlayerLoadoutTitle;

  /// LiveGameStrings.queueHint — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Giữ ứng dụng mở — chi tiết trận sẽ hiện ngay khi tìm được trận.'**
  String get liveGameQueueHint;

  /// LiveGameStrings.quitConfirmBodyInGame — Quit (G10)
  ///
  /// In vi, this message translates to:
  /// **'Rời trận có thể khiến bạn bị phạt (mất RR, khóa hàng chờ). Bạn vẫn muốn rời?'**
  String get liveGameQuitConfirmBodyInGame;

  /// LiveGameStrings.quitConfirmBodyPregame — Quit (G10)
  ///
  /// In vi, this message translates to:
  /// **'Né trận ở màn hình chọn đặc vụ có thể khiến bạn bị phạt (mất RR, khóa hàng chờ). Bạn vẫn muốn rời?'**
  String get liveGameQuitConfirmBodyPregame;

  /// LiveGameStrings.quitConfirmTitle — Quit (G10)
  ///
  /// In vi, this message translates to:
  /// **'Rời trận đấu?'**
  String get liveGameQuitConfirmTitle;

  /// LiveGameStrings.quitDone — Quit (G10)
  ///
  /// In vi, this message translates to:
  /// **'Đã rời trận.'**
  String get liveGameQuitDone;

  /// LiveGameStrings.quitFailed — Quit (G10)
  ///
  /// In vi, this message translates to:
  /// **'Chưa rời được trận.'**
  String get liveGameQuitFailed;

  /// LiveGameStrings.quitMatch — Quit (G10)
  ///
  /// In vi, this message translates to:
  /// **'Rời trận'**
  String get liveGameQuitMatch;

  /// LiveGameStrings.quitMatchChanged — Quit (G10)
  ///
  /// In vi, this message translates to:
  /// **'Trận đã chuyển giai đoạn trong lúc bạn xác nhận. Chưa rời trận, hãy thử lại.'**
  String get liveGameQuitMatchChanged;

  /// LiveGameStrings.rankUnavailable — Rosters (G5, G6)
  ///
  /// In vi, this message translates to:
  /// **'Không rõ rank'**
  String get liveGameRankUnavailable;

  /// LiveGameStrings.refresh — Sheet (S50)
  ///
  /// In vi, this message translates to:
  /// **'Làm mới'**
  String get liveGameRefresh;

  /// Tooltip of the countdown ring: "Tự làm mới sau 4 giây".
  ///
  /// In vi, this message translates to:
  /// **'Tự làm mới sau {seconds} giây'**
  String liveGameRefreshIn(int seconds);

  /// LiveGameStrings.refreshNow — Sheet (S50)
  ///
  /// In vi, this message translates to:
  /// **'Làm mới ngay'**
  String get liveGameRefreshNow;

  /// "8 – 4" (en dash with spaces, VF §8.8).
  ///
  /// In vi, this message translates to:
  /// **'{ally} – {enemy}'**
  String liveGameScore(int ally, int enemy);

  /// LiveGameStrings.sheetTitle — Sheet (S50)
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết trận'**
  String get liveGameSheetTitle;

  /// LiveGameStrings.sprays — Player loadout (S51)
  ///
  /// In vi, this message translates to:
  /// **'Hình phun sơn'**
  String get liveGameSprays;

  /// LiveGameStrings.statusAgentSelect — Status pill
  ///
  /// In vi, this message translates to:
  /// **'Đang chọn đặc vụ'**
  String get liveGameStatusAgentSelect;

  /// LiveGameStrings.statusEnded — Status pill
  ///
  /// In vi, this message translates to:
  /// **'Đã kết thúc'**
  String get liveGameStatusEnded;

  /// LiveGameStrings.statusInProgress — Status pill
  ///
  /// In vi, this message translates to:
  /// **'Đang diễn ra'**
  String get liveGameStatusInProgress;

  /// LiveGameStrings.statusUnavailable — Current game card (R7) / idle states
  ///
  /// In vi, this message translates to:
  /// **'Chưa cập nhật được trạng thái trận'**
  String get liveGameStatusUnavailable;

  /// LiveGameStrings.tabAllPlayers — Tabs (VF §8.10)
  ///
  /// In vi, this message translates to:
  /// **'Người chơi'**
  String get liveGameTabAllPlayers;

  /// LiveGameStrings.tabEnemyTeam — Tabs (VF §8.10)
  ///
  /// In vi, this message translates to:
  /// **'Đội địch'**
  String get liveGameTabEnemyTeam;

  /// LiveGameStrings.tabYourTeam — Tabs (VF §8.10)
  ///
  /// In vi, this message translates to:
  /// **'Đội của bạn'**
  String get liveGameTabYourTeam;

  /// "Còn 0:42".
  ///
  /// In vi, this message translates to:
  /// **'Còn {t}'**
  String liveGameTimeLeft(String t);

  /// LiveGameStrings.viewMatchDetails — Ended (G11)
  ///
  /// In vi, this message translates to:
  /// **'Xem chi tiết trận'**
  String get liveGameViewMatchDetails;

  /// LiveGameStrings.weapons — Player loadout (S51)
  ///
  /// In vi, this message translates to:
  /// **'Vũ khí'**
  String get liveGameWeapons;

  /// LiveGameStrings.you — Rosters (G5, G6)
  ///
  /// In vi, this message translates to:
  /// **'BẠN'**
  String get liveGameYou;

  /// LiveGameStrings.youHover — Agent select (G4)
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang chọn {agent}'**
  String liveGameYouHover(String agent);

  /// LiveGameStrings.youLocked — Agent select (G4)
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã khóa {agent}'**
  String liveGameYouLocked(String agent);

  /// Agent select (information only): agents are picked in the game, the app does not pick or lock agents (Riot bans instalock tools).
  ///
  /// In vi, this message translates to:
  /// **'Chọn và khóa đặc vụ trong VALORANT. ValHub chỉ hiển thị thời gian còn lại và đội của bạn.'**
  String get liveGamePickInGame;

  /// Row on top of the party page back in the lobby: the match just played (result, score and map follow); opens its details.
  ///
  /// In vi, this message translates to:
  /// **'Trận vừa rồi'**
  String get liveGameLastMatchTitle;

  /// Explicit view-boundary statistics display; preserves verified VI text.
  ///
  /// In vi, this message translates to:
  /// **'{wins} thắng – {losses} thua{draws, plural, =0{} other{ – {draws} hòa}}{unknown, plural, =0{} other{ – {unknown} trận chưa rõ kết quả}}'**
  String profileWinLossSummary(int wins, int losses, int draws, int unknown);

  /// Explicit view-boundary statistics display; preserves verified VI text.
  ///
  /// In vi, this message translates to:
  /// **'giờ thiết bị ({offset})'**
  String profileDeviceTimeZone(String offset);

  /// Explicit view-boundary statistics display; preserves verified VI text.
  ///
  /// In vi, this message translates to:
  /// **'{killer} hạ gục {victim}{hasWeapon, select, yes{ bằng {weapon}} other{}} ({time})'**
  String profileKillDescription(
    String killer,
    String victim,
    String hasWeapon,
    String weapon,
    String time,
  );

  /// Explicit view-boundary statistics display; preserves verified VI text.
  ///
  /// In vi, this message translates to:
  /// **'{period, select, days30{30 ngày} days7{7 ngày} other{Toàn bộ}}'**
  String profilePerformancePeriodLabel(String period);

  /// Explicit view-boundary statistics display; preserves verified VI text.
  ///
  /// In vi, this message translates to:
  /// **'{segment, select, agents{Đặc vụ} maps{Bản đồ} queues{Chế độ} sides{Tấn công / Phòng thủ} trend{Xu hướng} other{Chế độ}}'**
  String profilePerformanceSegmentLabel(String segment);

  /// Fallback scope caption, preserving VI.
  ///
  /// In vi, this message translates to:
  /// **'Mọi chế độ'**
  String get profileAllModes;

  /// ProfileStrings.ability — Round timeline: kill feed per round
  ///
  /// In vi, this message translates to:
  /// **'Kỹ năng'**
  String get profileAbility;

  /// "≈ 9 trận".
  ///
  /// In vi, this message translates to:
  /// **'≈ {n} trận'**
  String profileAboutMatches(int n);

  /// ProfileStrings.acs — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'ACS'**
  String get profileAcs;

  /// ProfileStrings.acsHint — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Điểm chiến đấu trung bình'**
  String get profileAcsHint;

  /// "Phần này: 20 thắng / 38 trận · 53%".
  ///
  /// In vi, this message translates to:
  /// **'Phần này: {wins} thắng / {games} trận · {rate}'**
  String profileActRecord(int wins, int games, String rate);

  /// ProfileStrings.adr — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'ADR'**
  String get profileAdr;

  /// ProfileStrings.allPlayers — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Tất cả người chơi'**
  String get profileAllPlayers;

  /// ProfileStrings.alreadyReached — Rank-Up Calculator (S41)
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã đạt hạng này.'**
  String get profileAlreadyReached;

  /// ProfileStrings.atCurrentForm — Rank-Up Calculator (S41)
  ///
  /// In vi, this message translates to:
  /// **'Với phong độ hiện tại'**
  String get profileAtCurrentForm;

  /// "Với phong độ hiện tại (+19 / −16 mỗi trận)".
  ///
  /// In vi, this message translates to:
  /// **'Với phong độ hiện tại ({gain} / {loss} mỗi trận)'**
  String profileAtCurrentFormWith(String gain, String loss);

  /// "Tốt nhất: 7 trận thắng liên tiếp".
  ///
  /// In vi, this message translates to:
  /// **'Tốt nhất: {n} trận thắng liên tiếp'**
  String profileBestCase(int n);

  /// ProfileStrings.byWinRateTitle — Rank-Up Calculator
  ///
  /// In vi, this message translates to:
  /// **'Theo tỉ lệ thắng'**
  String get profileByWinRateTitle;

  /// ProfileStrings.chooseMap — Match history (S40.6)
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo bản đồ'**
  String get profileChooseMap;

  /// ProfileStrings.colA — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'A'**
  String get profileColA;

  /// ProfileStrings.colD — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'D'**
  String get profileColD;

  /// ProfileStrings.colK — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'K'**
  String get profileColK;

  /// ProfileStrings.colPlace — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'#'**
  String get profileColPlace;

  /// ProfileStrings.colPlusMinus — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'+/−'**
  String get profileColPlusMinus;

  /// ProfileStrings.copyRiotId — Header (S40.1)
  ///
  /// In vi, this message translates to:
  /// **'Sao chép Riot ID'**
  String get profileCopyRiotId;

  /// ProfileStrings.currentRank — Rank card (S40.2)
  ///
  /// In vi, this message translates to:
  /// **'Hiện tại'**
  String get profileCurrentRank;

  /// ProfileStrings.dailyRrEmpty — Daily RR (S42)
  ///
  /// In vi, this message translates to:
  /// **'Chưa có trận xếp hạng nào được lưu trên thiết bị này.'**
  String get profileDailyRrEmpty;

  /// ProfileStrings.dailyRrFootnote — Daily RR (S42)
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử RR được lưu ngay trên thiết bị của bạn, kể cả các trận Riot không còn trả về.'**
  String get profileDailyRrFootnote;

  /// ProfileStrings.dailyRrTitle —
  ///
  /// In vi, this message translates to:
  /// **'RR theo ngày'**
  String get profileDailyRrTitle;

  /// "Ngày tính theo giờ thiết bị (UTC+7)".
  ///
  /// In vi, this message translates to:
  /// **'Ngày tính theo {zone}'**
  String profileDayBoundary(String zone);

  /// "5 ngày có trận".
  ///
  /// In vi, this message translates to:
  /// **'{n} ngày có trận'**
  String profileDaysPlayed(int n);

  /// ProfileStrings.endOfHistory — Match history (S40.6)
  ///
  /// In vi, this message translates to:
  /// **'Đã hiển thị tất cả trận đấu'**
  String get profileEndOfHistory;

  /// ProfileStrings.enemyTeam — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Đội địch'**
  String get profileEnemyTeam;

  /// ProfileStrings.fallDamage — Round timeline: kill feed per round
  ///
  /// In vi, this message translates to:
  /// **'Rơi từ trên cao'**
  String get profileFallDamage;

  /// ProfileStrings.filterAll — Match history (S40.6)
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get profileFilterAll;

  /// ProfileStrings.firstBloods — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'First blood'**
  String get profileFirstBloods;

  /// ProfileStrings.firstDeaths —
  ///
  /// In vi, this message translates to:
  /// **'Bị hạ đầu tiên'**
  String get profileFirstDeaths;

  /// ProfileStrings.firstHalf — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Hiệp 1'**
  String get profileFirstHalf;

  /// No round-based match in the window: the tiles are hidden.
  ///
  /// In vi, this message translates to:
  /// **'K/D, ACS, HS% chỉ tính cho các chế độ theo vòng đấu.'**
  String get profileFormNoRoundStats;

  /// Map filter: listed matches whose details are not loaded yet.
  ///
  /// In vi, this message translates to:
  /// **'{n} trận trong danh sách chưa được tải để tính.'**
  String profileFormPending(int n);

  /// Under the form tiles when a Deathmatch-like match is in the window.
  ///
  /// In vi, this message translates to:
  /// **'K/D, ACS, ADR, HS% chỉ tính {roundGames}/{games} trận theo vòng đấu'**
  String profileFormRoundStatsNote(int roundGames, int games);

  /// Screen-reader summary of the W/L strip.
  ///
  /// In vi, this message translates to:
  /// **'{games} trận gần nhất: {w} thắng, {l} thua'**
  String profileFormSemantics(int w, int l, int games);

  /// ProfileStrings.friendsRow — Social rows (S40.5)
  ///
  /// In vi, this message translates to:
  /// **'Bạn bè & trò chuyện'**
  String get profileFriendsRow;

  /// ProfileStrings.hideKills — Round timeline: kill feed per round
  ///
  /// In vi, this message translates to:
  /// **'Ẩn pha hạ gục'**
  String get profileHideKills;

  /// ProfileStrings.hitBody — Match detail hero + summary
  ///
  /// In vi, this message translates to:
  /// **'Thân'**
  String get profileHitBody;

  /// ProfileStrings.hitDistribution — Match detail hero + summary
  ///
  /// In vi, this message translates to:
  /// **'Phân bố phát bắn trúng'**
  String get profileHitDistribution;

  /// ProfileStrings.hitHead — Match detail hero + summary
  ///
  /// In vi, this message translates to:
  /// **'Đầu'**
  String get profileHitHead;

  /// ProfileStrings.hitLegs — Match detail hero + summary
  ///
  /// In vi, this message translates to:
  /// **'Chân'**
  String get profileHitLegs;

  /// "Đầu 24%".
  ///
  /// In vi, this message translates to:
  /// **'{part} {percent}'**
  String profileHitShare(String part, String percent);

  /// ProfileStrings.hs — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'HS%'**
  String get profileHs;

  /// ProfileStrings.kast — Match detail hero + summary
  ///
  /// In vi, this message translates to:
  /// **'KAST'**
  String get profileKast;

  /// ProfileStrings.kastHint — Match detail hero + summary
  ///
  /// In vi, this message translates to:
  /// **'Tỉ lệ vòng bạn hạ gục, hỗ trợ, sống sót hoặc được đồng đội hạ đối thủ vừa hạ bạn'**
  String get profileKastHint;

  /// ProfileStrings.kd — Recent form card (derived from the loaded match history)
  ///
  /// In vi, this message translates to:
  /// **'K/D'**
  String get profileKd;

  /// ProfileStrings.kdaLabel — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'K/D/A'**
  String get profileKdaLabel;

  /// "5/9/1".
  ///
  /// In vi, this message translates to:
  /// **'{k}/{d}/{a}'**
  String profileKdaValue(int k, int d, int a);

  /// "7 ngày qua".
  ///
  /// In vi, this message translates to:
  /// **'{n} ngày qua'**
  String profileLastDays(int n);

  /// "20 trận gần nhất".
  ///
  /// In vi, this message translates to:
  /// **'{n} trận gần nhất'**
  String profileLastMatches(int n);

  /// Leaderboard position ("Bảng xếp hạng #123").
  ///
  /// In vi, this message translates to:
  /// **'Bảng xếp hạng #{n}'**
  String profileLeaderboard(String n);

  /// ProfileStrings.level — Header (S40.1)
  ///
  /// In vi, this message translates to:
  /// **'Cấp {n}'**
  String profileLevel(int n);

  /// ProfileStrings.levelHidden — Player profile (S44)
  ///
  /// In vi, this message translates to:
  /// **'Cấp ẩn'**
  String get profileLevelHidden;

  /// "Chuỗi 2 trận thua".
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi {n} trận thua'**
  String profileLossStreak(int n);

  /// "Bản đồ: Tất cả".
  ///
  /// In vi, this message translates to:
  /// **'Bản đồ: {map}'**
  String profileMapFilter(String map);

  /// "6 trận".
  ///
  /// In vi, this message translates to:
  /// **'{n} trận'**
  String profileMatchCount(int n);

  /// ProfileStrings.matchDetailTitle —
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết trận đấu'**
  String get profileMatchDetailTitle;

  /// ProfileStrings.matchHistory — Match history (S40.6)
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử đấu'**
  String get profileMatchHistory;

  /// ProfileStrings.matchUnavailable — Match history (S40.6)
  ///
  /// In vi, this message translates to:
  /// **'Chưa tải được trận đấu'**
  String get profileMatchUnavailable;

  /// ProfileStrings.matchesNeeded — Rank-Up Calculator (S41)
  ///
  /// In vi, this message translates to:
  /// **'Số trận cần'**
  String get profileMatchesNeeded;

  /// ProfileStrings.mvp — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'MVP'**
  String get profileMvp;

  /// ProfileStrings.neverRanked — Rank card (S40.2)
  ///
  /// In vi, this message translates to:
  /// **'Chưa từng xếp hạng'**
  String get profileNeverRanked;

  /// ProfileStrings.noKillsInRound — Round timeline: kill feed per round
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thông tin hạ gục trong vòng này.'**
  String get profileNoKillsInRound;

  /// ProfileStrings.noMatches — Match history (S40.6)
  ///
  /// In vi, this message translates to:
  /// **'Chưa có trận đấu nào.'**
  String get profileNoMatches;

  /// ProfileStrings.noMatchesMap — Match history (S40.6)
  ///
  /// In vi, this message translates to:
  /// **'Không có trận nào trên bản đồ này trong các trận đã tải.'**
  String get profileNoMatchesMap;

  /// ProfileStrings.noMatchesQueue — Match history (S40.6)
  ///
  /// In vi, this message translates to:
  /// **'Không có trận nào ở chế độ này.'**
  String get profileNoMatchesQueue;

  /// ProfileStrings.noPlayers — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thông tin người chơi của trận này.'**
  String get profileNoPlayers;

  /// ProfileStrings.noRounds — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Chưa có thông tin từng vòng của trận này.'**
  String get profileNoRounds;

  /// ProfileStrings.overtime — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Hiệp phụ'**
  String get profileOvertime;

  /// Combined entry and page title for current match, party and matchmaking.
  ///
  /// In vi, this message translates to:
  /// **'Trận đấu & tổ đội'**
  String get profilePlayHubTitle;

  /// ProfileStrings.peakRank — Rank card (S40.2)
  ///
  /// In vi, this message translates to:
  /// **'Cao nhất'**
  String get profilePeakRank;

  /// ProfileStrings.performanceAttack —
  ///
  /// In vi, this message translates to:
  /// **'Tấn công'**
  String get profilePerformanceAttack;

  /// ProfileStrings.performanceDefense —
  ///
  /// In vi, this message translates to:
  /// **'Phòng thủ'**
  String get profilePerformanceDefense;

  /// ProfileStrings.performanceEmpty —
  ///
  /// In vi, this message translates to:
  /// **'Chưa có trận nào được ghi trên thiết bị này. Mở lịch sử trận để ghi lại những trận bạn đã chơi.'**
  String get profilePerformanceEmpty;

  /// ProfileStrings.performanceNoMatches —
  ///
  /// In vi, this message translates to:
  /// **'Không có trận trong khoảng thời gian đã chọn.'**
  String get profilePerformanceNoMatches;

  /// ProfileStrings.performanceRounds —
  ///
  /// In vi, this message translates to:
  /// **'{n} vòng đã ghi nhận'**
  String profilePerformanceRounds(int n);

  /// ProfileStrings.performanceSample —
  ///
  /// In vi, this message translates to:
  /// **'Tỉ lệ chỉ hiện khi có ít nhất 3 trận. ACS, ADR, HS% và K/D chỉ tính các chế độ theo vòng.'**
  String get profilePerformanceSample;

  /// ProfileStrings.performanceSideCoverage —
  ///
  /// In vi, this message translates to:
  /// **'Xác định được bên tấn công hoặc phòng thủ ở {known}/{total} vòng.'**
  String profilePerformanceSideCoverage(int known, int total);

  /// ProfileStrings.performanceSince —
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử trên thiết bị, từ {date}'**
  String profilePerformanceSince(String date);

  /// ProfileStrings.performanceTitle —
  ///
  /// In vi, this message translates to:
  /// **'Hiệu suất'**
  String get profilePerformanceTitle;

  /// Deathmatch placement "Hạng 3".
  ///
  /// In vi, this message translates to:
  /// **'Hạng {n}'**
  String profilePlacement(int n);

  /// "Đặt Spike ở A".
  ///
  /// In vi, this message translates to:
  /// **'Đặt Spike ở {site}'**
  String profilePlantedAt(String site);

  /// ProfileStrings.playerProfileTitle —
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ người chơi'**
  String get profilePlayerProfileTitle;

  /// ProfileStrings.playerSummary — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Thành tích'**
  String get profilePlayerSummary;

  /// "Tiến độ tới Kim Cương 2".
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ tới {rank}'**
  String profileProgressTo(String rank);

  /// ProfileStrings.progressToTarget — Rank-Up Calculator (redesign)
  ///
  /// In vi, this message translates to:
  /// **'Tiến độ tới hạng mục tiêu'**
  String get profileProgressToTarget;

  /// "Vàng 2 → Vàng 3".
  ///
  /// In vi, this message translates to:
  /// **'{from} → {to}'**
  String profileRankChange(String from, String to);

  /// ProfileStrings.rankUpFootnote — Rank-Up Calculator (S41)
  ///
  /// In vi, this message translates to:
  /// **'Ước tính dựa trên các trận xếp hạng gần đây, chưa tính các trận phân hạng và cơ chế bảo vệ xuống hạng.'**
  String get profileRankUpFootnote;

  /// "≈ 9 trận để lên Kim Cương 2".
  ///
  /// In vi, this message translates to:
  /// **'≈ {matches} trận để lên {rank}'**
  String profileRankUpHint(int matches, String rank);

  /// ProfileStrings.rankUpImmortal — Rank-Up Calculator (S41)
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã ở Bất Tử trở lên — tính năng này chỉ tính đến Bất Tử 1.'**
  String get profileRankUpImmortal;

  /// ProfileStrings.rankUpNoForm — Rank-Up Calculator (S41)
  ///
  /// In vi, this message translates to:
  /// **'Chưa có trận xếp hạng gần đây nào để ước tính phong độ.'**
  String get profileRankUpNoForm;

  /// ProfileStrings.rankUpOpen — Rank card (redesign)
  ///
  /// In vi, this message translates to:
  /// **'Mở tính toán lên hạng'**
  String get profileRankUpOpen;

  /// ProfileStrings.rankUpTitle —
  ///
  /// In vi, this message translates to:
  /// **'Tính toán lên hạng'**
  String get profileRankUpTitle;

  /// ProfileStrings.rankUpUnranked — Rank-Up Calculator (S41)
  ///
  /// In vi, this message translates to:
  /// **'Hãy hoàn thành các trận phân hạng để dùng tính năng tính toán lên hạng.'**
  String get profileRankUpUnranked;

  /// "Kim Cương 1 · 6 RR".
  ///
  /// In vi, this message translates to:
  /// **'{rank} · {rr} RR'**
  String profileRankWithRr(String rank, String rr);

  /// ProfileStrings.rankedScoreboard — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Bảng điểm xếp hạng'**
  String get profileRankedScoreboard;

  /// "Phong độ gần đây: 12 thắng – 8 thua".
  ///
  /// In vi, this message translates to:
  /// **'Phong độ gần đây: {w} thắng – {l} thua'**
  String profileRecentForm(int w, int l);

  /// ProfileStrings.recentFormTitle — Recent form card (derived from the loaded match history)
  ///
  /// In vi, this message translates to:
  /// **'Phong độ gần đây'**
  String get profileRecentFormTitle;

  /// ProfileStrings.recentMatches — Player profile (S44)
  ///
  /// In vi, this message translates to:
  /// **'Trận gần đây'**
  String get profileRecentMatches;

  /// "7T · 3B" (thắng / bại) under the win-rate ring.
  ///
  /// In vi, this message translates to:
  /// **'{d, plural, =0{{w}T · {l}B} other{{w}T · {l}B · {d}H}}'**
  String profileRecordShort(int w, int l, int d);

  /// ProfileStrings.riotIdCopied — Header (S40.1)
  ///
  /// In vi, this message translates to:
  /// **'Đã sao chép Riot ID'**
  String get profileRiotIdCopied;

  /// "Vòng 12".
  ///
  /// In vi, this message translates to:
  /// **'Vòng {n}'**
  String profileRound(int n);

  /// "3 hạ gục".
  ///
  /// In vi, this message translates to:
  /// **'{n} hạ gục'**
  String profileRoundKills(int n);

  /// ProfileStrings.roundLost — Match detail (redesign)
  ///
  /// In vi, this message translates to:
  /// **'Thua vòng'**
  String get profileRoundLost;

  /// ProfileStrings.roundTimeline — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Diễn biến vòng đấu'**
  String get profileRoundTimeline;

  /// ProfileStrings.roundWon — Match detail (redesign)
  ///
  /// In vi, this message translates to:
  /// **'Thắng vòng'**
  String get profileRoundWon;

  /// ProfileStrings.roundsHint — Round timeline: kill feed per round
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào một vòng để xem từng pha hạ gục.'**
  String get profileRoundsHint;

  /// "Còn thiếu 164 RR".
  ///
  /// In vi, this message translates to:
  /// **'Còn thiếu {n} RR'**
  String profileRrLeft(String n);

  /// "6 / 100 RR" progress to the next tier.
  ///
  /// In vi, this message translates to:
  /// **'{rr} / 100 RR'**
  String profileRrToNext(int rr);

  /// ProfileStrings.rrTrendTitle — Rank card (S40.2)
  ///
  /// In vi, this message translates to:
  /// **'Diễn biến RR'**
  String get profileRrTrendTitle;

  /// "6 RR" (number already formatted).
  ///
  /// In vi, this message translates to:
  /// **'{n} RR'**
  String profileRrValue(String n);

  /// "13 – 7".
  ///
  /// In vi, this message translates to:
  /// **'{a} – {b}'**
  String profileScore(int a, int b);

  /// ProfileStrings.scoreboard — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Bảng điểm'**
  String get profileScoreboard;

  /// ProfileStrings.secondHalf — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Hiệp 2'**
  String get profileSecondHalf;

  /// Separator of inline facts ("Xếp hạng · 18 giờ trước").
  ///
  /// In vi, this message translates to:
  /// **' · '**
  String get profileSeparator;

  /// ProfileStrings.showKills — Round timeline: kill feed per round
  ///
  /// In vi, this message translates to:
  /// **'Xem pha hạ gục'**
  String get profileShowKills;

  /// ProfileStrings.sideSwitch — Match detail (redesign)
  ///
  /// In vi, this message translates to:
  /// **'Đổi bên'**
  String get profileSideSwitch;

  /// ProfileStrings.spike — Round timeline: kill feed per round
  ///
  /// In vi, this message translates to:
  /// **'Spike'**
  String get profileSpike;

  /// " #TAG" after a game name.
  ///
  /// In vi, this message translates to:
  /// **' #{tag}'**
  String profileTagSuffix(String tag);

  /// ProfileStrings.targetRank — Rank-Up Calculator (S41)
  ///
  /// In vi, this message translates to:
  /// **'Hạng mục tiêu'**
  String get profileTargetRank;

  /// ProfileStrings.teamBlue — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Đội Xanh'**
  String get profileTeamBlue;

  /// ProfileStrings.teamMvp — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'MVP đội'**
  String get profileTeamMvp;

  /// ProfileStrings.teamRed — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Đội Đỏ'**
  String get profileTeamRed;

  /// ProfileStrings.title —
  ///
  /// In vi, this message translates to:
  /// **'Hồ sơ'**
  String get profileTitle;

  /// "Hôm nay: 2 thắng – 1 thua".
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay: {text}'**
  String profileToday(String text);

  /// ProfileStrings.todayNone — Daily RR row (S40.3)
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay chưa có trận xếp hạng'**
  String get profileTodayNone;

  /// ProfileStrings.truePeakLocal — Rank card (S40.2)
  ///
  /// In vi, this message translates to:
  /// **'Theo lịch sử trên thiết bị'**
  String get profileTruePeakLocal;

  /// Short weekday of a day badge, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'T2'**
  String get profileWeekdayShortItem0;

  /// Short weekday of a day badge, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'T3'**
  String get profileWeekdayShortItem1;

  /// Short weekday of a day badge, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'T4'**
  String get profileWeekdayShortItem2;

  /// Short weekday of a day badge, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'T5'**
  String get profileWeekdayShortItem3;

  /// Short weekday of a day badge, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'T6'**
  String get profileWeekdayShortItem4;

  /// Short weekday of a day badge, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'T7'**
  String get profileWeekdayShortItem5;

  /// Short weekday of a day badge, indexed by `DateTime.weekday - 1`.
  ///
  /// In vi, this message translates to:
  /// **'CN'**
  String get profileWeekdayShortItem6;

  /// ProfileStrings.winRate — Rank-Up Calculator (S41)
  ///
  /// In vi, this message translates to:
  /// **'Tỉ lệ thắng'**
  String get profileWinRate;

  /// "Chuỗi 3 trận thắng".
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi {n} trận thắng'**
  String profileWinStreak(int n);

  /// "184 / 5.000 XP" (numbers already formatted).
  ///
  /// In vi, this message translates to:
  /// **'{xp} / {perLevel} XP'**
  String profileXpProgress(String xp, String perLevel);

  /// ProfileStrings.yourRank — Rank-Up Calculator (S41)
  ///
  /// In vi, this message translates to:
  /// **'Hạng của bạn'**
  String get profileYourRank;

  /// ProfileStrings.yourSummary — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Thành tích của bạn'**
  String get profileYourSummary;

  /// ProfileStrings.yourTeam — Match detail (S43)
  ///
  /// In vi, this message translates to:
  /// **'Đội của bạn'**
  String get profileYourTeam;

  /// ProfileStrings.yourWinRate — Rank-Up Calculator
  ///
  /// In vi, this message translates to:
  /// **'Tỉ lệ thắng gần đây của bạn'**
  String get profileYourWinRate;

  /// Queue filter chip of the Performance screen ("Chế độ: Xếp hạng").
  ///
  /// In vi, this message translates to:
  /// **'Chế độ: {queue}'**
  String profilePerformanceQueueChip(String queue);

  /// Title of the queue picker sheet on the Performance screen.
  ///
  /// In vi, this message translates to:
  /// **'Lọc theo chế độ'**
  String get profilePerformanceChooseQueue;

  /// Card title: one bar per recent match (ACS, K/D, ADR or HS%).
  ///
  /// In vi, this message translates to:
  /// **'Từng trận'**
  String get profilePerformancePerMatchTitle;

  /// Under the per-match chart: tapping a bar opens that match.
  ///
  /// In vi, this message translates to:
  /// **'Chạm một cột để mở trận đó.'**
  String get profilePerformancePerMatchHint;

  /// Dashed average line label of the per-match chart ("Trung bình 231").
  ///
  /// In vi, this message translates to:
  /// **'Trung bình {value}'**
  String profilePerformanceAverage(String value);

  /// Per-match chart without enough round-based matches for the chosen stat.
  ///
  /// In vi, this message translates to:
  /// **'Cần ít nhất 2 trận theo vòng có số liệu này để vẽ biểu đồ.'**
  String get profilePerformanceChartEmpty;

  /// Card title: first bloods and first deaths (who wins the first duel of a round).
  ///
  /// In vi, this message translates to:
  /// **'Giao tranh mở màn'**
  String get profilePerformanceOpeningsTitle;

  /// Share of opening duels won: first bloods / (first bloods + first deaths).
  ///
  /// In vi, this message translates to:
  /// **'Thắng mở màn'**
  String get profilePerformanceOpeningWin;

  /// Tooltip explaining the opening-duel win rate.
  ///
  /// In vi, this message translates to:
  /// **'Trong các vòng bạn là người hạ gục hoặc bị hạ đầu tiên, tỉ lệ bạn là người hạ gục.'**
  String get profilePerformanceOpeningWinHint;

  /// Average first bloods per round-based match.
  ///
  /// In vi, this message translates to:
  /// **'First blood mỗi trận'**
  String get profilePerformanceFirstBloodsPerGame;

  /// Average times the player died first in a round, per round-based match.
  ///
  /// In vi, this message translates to:
  /// **'Bị hạ đầu mỗi trận'**
  String get profilePerformanceFirstDeathsPerGame;

  /// Section title: rounds with 3 kills, 4 kills and aces.
  ///
  /// In vi, this message translates to:
  /// **'Nhiều mạng trong một vòng'**
  String get profilePerformanceMultiKillsTitle;

  /// Label of a multi-kill counter.
  ///
  /// In vi, this message translates to:
  /// **'{kind, select, k3{3 mạng} k4{4 mạng} ace{Ace} other{2 mạng}}'**
  String profilePerformanceMultiKill(String kind);

  /// Sample note of the multi-kill counters.
  ///
  /// In vi, this message translates to:
  /// **'{n, plural, other{Tính trên {n} trận có đủ dữ liệu hạ gục.}}'**
  String profilePerformanceMultiKillsNote(int n);

  /// Round win rate on the attack or defense side.
  ///
  /// In vi, this message translates to:
  /// **'Thắng vòng'**
  String get profilePerformanceRoundWin;

  /// Under the agents / maps / queues table.
  ///
  /// In vi, this message translates to:
  /// **'Chạm một dòng để xem riêng đặc vụ, bản đồ hoặc chế độ đó.'**
  String get profilePerformanceDrillHint;

  /// Button: open older matches from the Riot match history so they are added to the on-device analysis.
  ///
  /// In vi, this message translates to:
  /// **'Phân tích thêm trận cũ'**
  String get profilePerformanceLoadOlder;

  /// Explains the "Phân tích thêm trận cũ" button.
  ///
  /// In vi, this message translates to:
  /// **'ValHub chỉ phân tích những trận đã mở trên máy này. Mỗi lần bấm sẽ thêm tối đa {n} trận cũ hơn.'**
  String profilePerformanceLoadOlderHint(int n);

  /// Backfill progress before the number of matches is known.
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm trận cũ hơn…'**
  String get profilePerformanceSearchingOlder;

  /// Backfill progress ("Đang phân tích 6/20 trận…").
  ///
  /// In vi, this message translates to:
  /// **'Đang phân tích {done}/{total} trận…'**
  String profilePerformanceLoadingOlder(int done, int total);

  /// Result of one backfill run.
  ///
  /// In vi, this message translates to:
  /// **'{n, plural, =0{Không có trận mới để thêm.} other{Đã thêm {n} trận vào phân tích.}}'**
  String profilePerformanceAddedOlder(int n);

  /// Backfill reached the end of the Riot match history.
  ///
  /// In vi, this message translates to:
  /// **'Riot không còn lưu trận nào cũ hơn.'**
  String get profilePerformanceNoOlder;

  /// Match detail card: rounds your team won with each buy type (pistol, eco, semi-eco, semi-buy, full buy).
  ///
  /// In vi, this message translates to:
  /// **'Kinh tế đội bạn'**
  String get profileEconomyTitle;

  /// How the buy types are decided (shown from the info button of the economy card). Keep the numbers and the English buy-type names.
  ///
  /// In vi, this message translates to:
  /// **'Loại mua tính theo tổng giá trị trang bị của đội lúc bắt đầu vòng (quy ước của vlr.gg cho 5 người): Eco dưới 5.000, Semi-eco dưới 10.000, Semi-buy dưới 20.000, Full buy từ 20.000 credits. Vòng đầu mỗi hiệp là Pistol.'**
  String get profileEconomyHint;

  /// Buy type of a team in a round. Players use these English terms (vlr.gg); keep them unless the game client of the language uses others.
  ///
  /// In vi, this message translates to:
  /// **'{type, select, pistol{Pistol} eco{Eco} semiEco{Semi-eco} semiBuy{Semi-buy} fullBuy{Full buy} other{–}}'**
  String profileBuyType(String type);

  /// Rounds won out of rounds played with one buy type ("Thắng 3/5").
  ///
  /// In vi, this message translates to:
  /// **'Thắng {won}/{played}'**
  String profileEconomyWon(int won, int played);

  /// Round line of the match timeline: your team's buy type vs the enemy's ("Full buy vs Eco").
  ///
  /// In vi, this message translates to:
  /// **'{mine} vs {theirs}'**
  String profileEconomyMatchup(String mine, String theirs);

  /// Title (shown uppercase) of the Profile card summarising the matches the player just played in one sitting.
  ///
  /// In vi, this message translates to:
  /// **'Phiên vừa chơi'**
  String get profileSessionTitle;

  /// Time spent in matches during the session, one hour or more ('2 giờ 15 phút').
  ///
  /// In vi, this message translates to:
  /// **'{hours} giờ {minutes} phút'**
  String profileSessionDuration(int hours, int minutes);

  /// Agent played most in the session and how many times ('Nhiều nhất: Jett ×3'). The agent name comes from the game data.
  ///
  /// In vi, this message translates to:
  /// **'Nhiều nhất: {agent} ×{count}'**
  String profileSessionTopAgent(String agent, int count);

  /// LegalStrings.aboutIntro — About hub
  ///
  /// In vi, this message translates to:
  /// **'Trợ thủ VALORANT của bạn: cửa hàng mỗi ngày, wishlist, rank, trận đấu, nhiều tài khoản và cộng đồng người chơi, ngay trên thiết bị của bạn.'**
  String get legalAboutIntro;

  /// LegalStrings.backToTop — Document screen
  ///
  /// In vi, this message translates to:
  /// **'Về đầu trang'**
  String get legalBackToTop;

  /// LegalStrings.consentAnd — Consent line (welcome screen)
  ///
  /// In vi, this message translates to:
  /// **' và '**
  String get legalConsentAnd;

  /// LegalStrings.consentPrefix — Consent line (welcome screen)
  ///
  /// In vi, this message translates to:
  /// **'Bằng việc tiếp tục, bạn đồng ý với '**
  String get legalConsentPrefix;

  /// LegalStrings.consentPrivacy — Consent line (welcome screen)
  ///
  /// In vi, this message translates to:
  /// **'Chính sách quyền riêng tư'**
  String get legalConsentPrivacy;

  /// LegalStrings.consentSuffix — Consent line (welcome screen)
  ///
  /// In vi, this message translates to:
  /// **' của ValHub.'**
  String get legalConsentSuffix;

  /// LegalStrings.consentTerms — Consent line (welcome screen)
  ///
  /// In vi, this message translates to:
  /// **'Điều khoản sử dụng'**
  String get legalConsentTerms;

  /// LegalStrings.contact — About hub
  ///
  /// In vi, this message translates to:
  /// **'Liên hệ'**
  String get legalContact;

  /// LegalStrings.contactBody — About hub
  ///
  /// In vi, this message translates to:
  /// **'ndh0408@gmail.com'**
  String get legalContactBody;

  /// LegalStrings.contactHeader — About hub
  ///
  /// In vi, this message translates to:
  /// **'LIÊN HỆ'**
  String get legalContactHeader;

  /// LegalStrings.effectiveFrom — Document screen
  ///
  /// In vi, this message translates to:
  /// **'Hiệu lực từ {date}'**
  String legalEffectiveFrom(String date);

  /// LegalStrings.legalHeader — About hub
  ///
  /// In vi, this message translates to:
  /// **'PHÁP LÝ'**
  String get legalLegalHeader;

  /// Legalese shown on Flutter's licence page.
  ///
  /// In vi, this message translates to:
  /// **'© 2026 Nguyễn Đức Huy. Bảo lưu mọi quyền.'**
  String get legalLicensePageLegalese;

  /// LegalStrings.thirdPartyLicenses — About hub
  ///
  /// In vi, this message translates to:
  /// **'Phần mềm bên thứ ba'**
  String get legalThirdPartyLicenses;

  /// LegalStrings.thirdPartyLicensesBody — About hub
  ///
  /// In vi, this message translates to:
  /// **'Giấy phép của các phần mềm mã nguồn mở mà ValHub sử dụng'**
  String get legalThirdPartyLicensesBody;

  /// LegalStrings.tocTitle — Document screen
  ///
  /// In vi, this message translates to:
  /// **'MỤC LỤC'**
  String get legalTocTitle;

  /// LegalStrings.version — Document screen
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản {version}'**
  String legalVersion(String version);

  /// Actual source language when a legal translation is unavailable; does not imply legal review or binding status.
  ///
  /// In vi, this message translates to:
  /// **'Văn bản này hiện được hiển thị bằng {language}.'**
  String legalDocumentLanguage(String language);

  /// Bundled legal asset read or validation failed; this is not a Riot server failure.
  ///
  /// In vi, this message translates to:
  /// **'Không đọc được văn bản pháp lý. Hãy thử lại hoặc liên hệ hỗ trợ.'**
  String get legalContentUnavailable;

  /// Shown above a legal document that is a translation (not the authoritative Vietnamese text).
  ///
  /// In vi, this message translates to:
  /// **'Đây là bản dịch để bạn tiện đọc. Nếu có khác biệt, bản tiếng Việt được ưu tiên áp dụng.'**
  String get legalTranslationNotice;

  /// UI language setting and welcome-screen picker; separate from game item names.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ giao diện'**
  String get settingsUiLanguageTitle;

  /// Follow the device's preferred supported UI language.
  ///
  /// In vi, this message translates to:
  /// **'Theo thiết bị'**
  String get settingsLanguageFollowDevice;

  /// Language preference could not be persisted; controller restores the committed choice.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lưu được ngôn ngữ. Vui lòng thử lại.'**
  String get settingsLanguageSaveFailed;

  /// Country and Riot connection settings: settingsGeoCountry
  ///
  /// In vi, this message translates to:
  /// **'Quốc gia'**
  String get settingsGeoCountry;

  /// Country and Riot connection settings: settingsGeoSearchCountry
  ///
  /// In vi, this message translates to:
  /// **'Tìm tên hoặc mã quốc gia'**
  String get settingsGeoSearchCountry;

  /// Country and Riot connection settings: settingsGeoSupportedOnly
  ///
  /// In vi, this message translates to:
  /// **'Chỉ nơi đã xác nhận hỗ trợ'**
  String get settingsGeoSupportedOnly;

  /// Country and Riot connection settings: settingsGeoUnknown
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác minh khả năng hỗ trợ'**
  String get settingsGeoUnknown;

  /// Country and Riot connection settings: settingsGeoRestricted
  ///
  /// In vi, this message translates to:
  /// **'Bị hạn chế'**
  String get settingsGeoRestricted;

  /// Country and Riot connection settings: settingsGeoSeparate
  ///
  /// In vi, this message translates to:
  /// **'Dịch vụ riêng'**
  String get settingsGeoSeparate;

  /// Country and Riot connection settings: settingsGeoAvailable
  ///
  /// In vi, this message translates to:
  /// **'Có hỗ trợ'**
  String get settingsGeoAvailable;

  /// Country and Riot connection settings: settingsGeoNotApplicable
  ///
  /// In vi, this message translates to:
  /// **'Không áp dụng'**
  String get settingsGeoNotApplicable;

  /// Country and Riot connection settings: settingsGeoConnection
  ///
  /// In vi, this message translates to:
  /// **'Kết nối Riot'**
  String get settingsGeoConnection;

  /// Country and Riot connection settings: settingsGeoChooseRegion
  ///
  /// In vi, this message translates to:
  /// **'Chọn khu vực'**
  String get settingsGeoChooseRegion;

  /// Country and Riot connection settings: settingsGeoAuto
  ///
  /// In vi, this message translates to:
  /// **'Tự động theo tài khoản'**
  String get settingsGeoAuto;

  /// Country and Riot connection settings: settingsGeoManual
  ///
  /// In vi, this message translates to:
  /// **'Chọn thủ công'**
  String get settingsGeoManual;

  /// Country and Riot connection settings: settingsGeoNoRegion
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác định được khu vực Riot'**
  String get settingsGeoNoRegion;

  /// Country and Riot connection settings: settingsGeoManualWarning
  ///
  /// In vi, this message translates to:
  /// **'Lựa chọn này chỉ đổi máy chủ mà ValHub kết nối. Nó không chuyển khu vực tài khoản Riot của bạn. ValHub sẽ kiểm tra kết nối trước khi lưu.'**
  String get settingsGeoManualWarning;

  /// Country and Riot connection settings: settingsGeoConnectionSaved
  ///
  /// In vi, this message translates to:
  /// **'Đã lưu cách kết nối'**
  String get settingsGeoConnectionSaved;

  /// Country and Riot connection settings: settingsGeoValidationFailed
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản không được xác nhận trên máy chủ này. Hãy chọn lại khu vực.'**
  String get settingsGeoValidationFailed;

  /// Country and Riot connection settings: settingsGeoHintOnly
  ///
  /// In vi, this message translates to:
  /// **'Quốc gia chỉ dùng để tra cứu và gợi ý. Khu vực kết nối theo tài khoản Riot.'**
  String get settingsGeoHintOnly;

  /// Country and Riot connection settings: settingsGeoSave
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra và lưu'**
  String get settingsGeoSave;

  /// Country and Riot connection settings: settingsGeoCancel
  ///
  /// In vi, this message translates to:
  /// **'Hủy'**
  String get settingsGeoCancel;

  /// Country and Riot connection settings: settingsGeoLoading
  ///
  /// In vi, this message translates to:
  /// **'Đang kiểm tra kết nối…'**
  String get settingsGeoLoading;

  /// Country picker/preference view text; country never chooses a Riot network host.
  ///
  /// In vi, this message translates to:
  /// **'Lựa chọn này dùng cho tên quốc gia, gợi ý và giá VP ước tính. Máy chủ kết nối và quốc gia tài khoản Cộng đồng vẫn do Riot xác định.'**
  String get settingsGeoCountryPreferenceHint;

  /// Country picker/preference view text; country never chooses a Riot network host.
  ///
  /// In vi, this message translates to:
  /// **'Dùng quốc gia tài khoản hoặc thiết bị'**
  String get settingsGeoCountryAutomatic;

  /// Country picker/preference view text; country never chooses a Riot network host.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lưu được lựa chọn. Hãy thử lại.'**
  String get settingsGeoSaveFailed;

  /// Country picker/preference view text; country never chooses a Riot network host.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả khu vực'**
  String get settingsGeoAllRegions;

  /// Country picker/preference view text; country never chooses a Riot network host.
  ///
  /// In vi, this message translates to:
  /// **'Gợi ý'**
  String get settingsGeoSuggestions;

  /// Country picker/preference view text; country never chooses a Riot network host.
  ///
  /// In vi, this message translates to:
  /// **'Không có quốc gia khớp bộ lọc.'**
  String get settingsGeoNoCountries;

  /// Shared country picker, authored after extraction.
  ///
  /// In vi, this message translates to:
  /// **'Có hoạt động'**
  String get settingsGeoActiveCountries;

  /// Shared country picker, authored after extraction.
  ///
  /// In vi, this message translates to:
  /// **'Tất cả quốc gia'**
  String get settingsGeoAllCountries;

  /// Shared country picker, authored after extraction.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tải được hoạt động các nước. Bạn vẫn có thể chọn trong Tất cả quốc gia.'**
  String get settingsGeoActivityUnavailable;

  /// Shared country picker, authored after extraction.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, other{{count} quốc gia}}'**
  String settingsGeoResultCount(int count);

  /// Country and Riot connection settings: settingsGeoManualConfirm
  ///
  /// In vi, this message translates to:
  /// **'Bạn chọn {manual}, nhưng Riot xác định tài khoản ở {detected}. Tiếp tục kiểm tra kết nối này?'**
  String settingsGeoManualConfirm(String manual, String detected);

  /// Country and Riot connection settings: settingsGeoUnverified
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác minh được kết nối do máy chủ hoặc mạng đang gặp lỗi. Lưu lựa chọn này và thử lại sau?'**
  String get settingsGeoUnverified;

  /// Country and Riot connection settings: settingsGeoContinue
  ///
  /// In vi, this message translates to:
  /// **'Tiếp tục'**
  String get settingsGeoContinue;

  /// Banner when the player picked a server by hand that differs from the one Riot gives the account; {region} is the account's server name. Offers to switch back to it.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang chọn máy chủ khác với máy chủ của tài khoản ({region}). Dùng máy chủ của tài khoản?'**
  String settingsGeoMismatch(String region);

  /// Country and Riot connection settings: settingsGeoUseAuto
  ///
  /// In vi, this message translates to:
  /// **'Dùng tự động'**
  String get settingsGeoUseAuto;

  /// Country and Riot connection settings: settingsGeoKeepManual
  ///
  /// In vi, this message translates to:
  /// **'Giữ thủ công'**
  String get settingsGeoKeepManual;

  /// Country and Riot connection settings: settingsGeoReviewConnection
  ///
  /// In vi, this message translates to:
  /// **'Xem kết nối'**
  String get settingsGeoReviewConnection;

  /// Country and Riot connection settings: settingsGeoCheckedAt
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra gần nhất: {time}'**
  String settingsGeoCheckedAt(String time);

  /// Country and Riot connection settings: settingsGeoCheckAgain
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra lại'**
  String get settingsGeoCheckAgain;

  /// Generic metadata label resolved at render time: settingsPlatformMobile
  ///
  /// In vi, this message translates to:
  /// **'Di động'**
  String get settingsPlatformMobile;

  /// Generic metadata label resolved at render time: settingsPlatformOther
  ///
  /// In vi, this message translates to:
  /// **'Nền tảng khác'**
  String get settingsPlatformOther;

  /// Independent item-name language: follow current UI language, not device country or Riot shard.
  ///
  /// In vi, this message translates to:
  /// **'Theo ngôn ngữ ứng dụng'**
  String get settingsContentLanguageFollowApp;

  /// The content-language picker supports all 18 API locales even while UI translations are unshipped.
  ///
  /// In vi, this message translates to:
  /// **'Chọn ngôn ngữ tên vật phẩm. Lựa chọn này không đổi ngôn ngữ giao diện hoặc máy chủ Riot.'**
  String get settingsContentLanguageHint;

  /// Screen-reader confirmation after a persisted UI language choice, with effective native language name.
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ: {language}.'**
  String settingsLanguageChanged(String language);

  /// SettingsStrings.aboutRowSubtitle —
  ///
  /// In vi, this message translates to:
  /// **'Quyền riêng tư, điều khoản, bản quyền và liên hệ'**
  String get settingsAboutRowSubtitle;

  /// SettingsStrings.aboutTitle —
  ///
  /// In vi, this message translates to:
  /// **'Giới thiệu & pháp lý'**
  String get settingsAboutTitle;

  /// SettingsStrings.appearanceHeader — Section headers (S70)
  ///
  /// In vi, this message translates to:
  /// **'GIAO DIỆN'**
  String get settingsAppearanceHeader;

  /// SettingsStrings.buildNumber — NÂNG CAO (the version lives on the About screen only)
  ///
  /// In vi, this message translates to:
  /// **'Bản dựng {build}'**
  String settingsBuildNumber(String build);

  /// SettingsStrings.cacheCleared — NÂNG CAO (the version lives on the About screen only)
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa {size}'**
  String settingsCacheCleared(String size);

  /// SettingsStrings.clearCache — NÂNG CAO (the version lives on the About screen only)
  ///
  /// In vi, this message translates to:
  /// **'Xóa dữ liệu tạm'**
  String get settingsClearCache;

  /// SettingsStrings.clearCacheFailed — NÂNG CAO (the version lives on the About screen only)
  ///
  /// In vi, this message translates to:
  /// **'Chưa xóa được dữ liệu tạm. Hãy thử lại.'**
  String get settingsClearCacheFailed;

  /// SettingsStrings.clearCacheSubtitle — NÂNG CAO (the version lives on the About screen only)
  ///
  /// In vi, this message translates to:
  /// **'Ảnh và dữ liệu đã tải về máy, kể cả báo lỗi đã ghi'**
  String get settingsClearCacheSubtitle;

  /// Row that builds the bug-report file and opens the share sheet.
  ///
  /// In vi, this message translates to:
  /// **'Gửi báo lỗi cho ValHub'**
  String get settingsExportLog;

  /// Snackbar when nothing has been recorded yet.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có gì để gửi. Hãy dùng ứng dụng một lúc rồi thử lại.'**
  String get settingsExportLogEmpty;

  /// SettingsStrings.exportLogSubtitle — NÂNG CAO (the version lives on the About screen only)
  ///
  /// In vi, this message translates to:
  /// **'Báo lỗi không chứa mật khẩu hay dữ liệu đăng nhập Riot của bạn.'**
  String get settingsExportLogSubtitle;

  /// SettingsStrings.feedback — HỖ TRỢ
  ///
  /// In vi, this message translates to:
  /// **'Góp ý cho ValHub'**
  String get settingsFeedback;

  /// SettingsStrings.feedbackSubtitle — HỖ TRỢ
  ///
  /// In vi, this message translates to:
  /// **'Mở trang góp ý của ValHub'**
  String get settingsFeedbackSubtitle;

  /// SettingsStrings.itemLanguageEn — GIAO DIỆN
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Anh'**
  String get settingsItemLanguageEn;

  /// SettingsStrings.itemLanguageLabel — GIAO DIỆN
  ///
  /// In vi, this message translates to:
  /// **'Tên vật phẩm'**
  String get settingsItemLanguageLabel;

  /// SettingsStrings.itemLanguagePickerTitle — GIAO DIỆN
  ///
  /// In vi, this message translates to:
  /// **'Ngôn ngữ tên vật phẩm'**
  String get settingsItemLanguagePickerTitle;

  /// SettingsStrings.itemLanguageVi — GIAO DIỆN
  ///
  /// In vi, this message translates to:
  /// **'Tiếng Việt'**
  String get settingsItemLanguageVi;

  /// SettingsStrings.linkOpenFailed — HỖ TRỢ
  ///
  /// In vi, this message translates to:
  /// **'Chưa mở được liên kết. Hãy thử lại.'**
  String get settingsLinkOpenFailed;

  /// First line of the bug-report file.
  ///
  /// In vi, this message translates to:
  /// **'{appName} {version} — Báo lỗi'**
  String settingsLogFileHeader(String appName, String version);

  /// Failure of the share sheet of the bug report.
  ///
  /// In vi, this message translates to:
  /// **'Chưa gửi được báo lỗi. Hãy thử lại.'**
  String get settingsLogShareFailed;

  /// SettingsStrings.logoPrefix — Welcome (S01)
  ///
  /// In vi, this message translates to:
  /// **'Val'**
  String get settingsLogoPrefix;

  /// SettingsStrings.logoSuffix — Welcome (S01)
  ///
  /// In vi, this message translates to:
  /// **'Hub'**
  String get settingsLogoSuffix;

  /// SettingsStrings.notifNightMarket — THÔNG BÁO
  ///
  /// In vi, this message translates to:
  /// **'Khi Chợ Đêm mở'**
  String get settingsNotifNightMarket;

  /// SettingsStrings.notifNightMarketSubtitle — THÔNG BÁO
  ///
  /// In vi, this message translates to:
  /// **'Nhắc bạn lật thẻ ưu đãi Chợ Đêm'**
  String get settingsNotifNightMarketSubtitle;

  /// SettingsStrings.notifPermissionMissing — THÔNG BÁO
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng chưa có quyền gửi thông báo.'**
  String get settingsNotifPermissionMissing;

  /// SettingsStrings.notifStoreReset — THÔNG BÁO
  ///
  /// In vi, this message translates to:
  /// **'Khi cửa hàng làm mới'**
  String get settingsNotifStoreReset;

  /// [time] = local time of the daily reset (00:00 UTC), e.g. `07:00`.
  ///
  /// In vi, this message translates to:
  /// **'{time} hằng ngày'**
  String settingsNotifStoreResetSubtitle(String time);

  /// SettingsStrings.notifWishlist — THÔNG BÁO
  ///
  /// In vi, this message translates to:
  /// **'Khi skin trong wishlist xuất hiện'**
  String get settingsNotifWishlist;

  /// SettingsStrings.notificationsHeader — Section headers (S70)
  ///
  /// In vi, this message translates to:
  /// **'THÔNG BÁO'**
  String get settingsNotificationsHeader;

  /// SettingsStrings.optionAutoOpenLiveGame — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Tự động mở chi tiết trận'**
  String get settingsOptionAutoOpenLiveGame;

  /// SettingsStrings.optionAutoOpenLiveGameSubtitle — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Mở bảng trận hiện tại ngay khi tìm thấy trận'**
  String get settingsOptionAutoOpenLiveGameSubtitle;

  /// SettingsStrings.optionOwnPrice — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Giá gói VP của bạn'**
  String get settingsOptionOwnPrice;

  /// SettingsStrings.optionOwnPriceEmpty — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Chưa nhập — dùng bảng giá của khu vực nếu có'**
  String get settingsOptionOwnPriceEmpty;

  /// SettingsStrings.optionOwnPriceValue — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'{vp} = {price}'**
  String settingsOptionOwnPriceValue(String vp, String price);

  /// SettingsStrings.optionPlatform — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Nền tảng'**
  String get settingsOptionPlatform;

  /// SettingsStrings.optionShowLiveScore — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Hiện tỉ số trực tiếp'**
  String get settingsOptionShowLiveScore;

  /// SettingsStrings.optionShowPeakRank — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Hiện rank cao nhất trong chi tiết trận'**
  String get settingsOptionShowPeakRank;

  /// SettingsStrings.optionShowPrice — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Hiện giá quy đổi ước tính'**
  String get settingsOptionShowPrice;

  /// SettingsStrings.optionShowPriceInfo — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Cách tính giá quy đổi'**
  String get settingsOptionShowPriceInfo;

  /// SettingsStrings.optionShowPriceSubtitle — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Cạnh giá VP, ví dụ {vp} {price}'**
  String settingsOptionShowPriceSubtitle(String vp, String price);

  /// SettingsStrings.optionShowPriceUnavailable — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bảng giá đã xác minh cho khu vực của bạn — hãy nhập giá gói VP của bạn.'**
  String get settingsOptionShowPriceUnavailable;

  /// SettingsStrings.optionsHeader — Section headers (S70)
  ///
  /// In vi, this message translates to:
  /// **'TÙY CHỌN'**
  String get settingsOptionsHeader;

  /// SettingsStrings.phaseComplete — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Đã xong'**
  String get settingsPhaseComplete;

  /// SettingsStrings.phaseInProgress — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Đang diễn ra'**
  String get settingsPhaseInProgress;

  /// SettingsStrings.phaseScheduled — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Đã lên lịch'**
  String get settingsPhaseScheduled;

  /// SettingsStrings.platformAppliesTo — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Áp dụng cho {account}'**
  String settingsPlatformAppliesTo(String account);

  /// SettingsStrings.platformHint — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Chọn PC, PlayStation hoặc Xbox theo nơi bạn chơi để xem đúng lịch sử đấu.'**
  String get settingsPlatformHint;

  /// SettingsStrings.platformPickerTitle — TÙY CHỌN
  ///
  /// In vi, this message translates to:
  /// **'Chọn nền tảng'**
  String get settingsPlatformPickerTitle;

  /// SettingsStrings.primingBody — Notification priming (S04)
  ///
  /// In vi, this message translates to:
  /// **'Bật thông báo để biết khi cửa hàng làm mới và khi skin trong wishlist xuất hiện.'**
  String get settingsPrimingBody;

  /// SettingsStrings.primingEnable — Notification priming (S04)
  ///
  /// In vi, this message translates to:
  /// **'Bật thông báo'**
  String get settingsPrimingEnable;

  /// SettingsStrings.primingFootnote — Notification priming (S04)
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể bật hoặc tắt từng loại thông báo bất cứ lúc nào trong Cài đặt.'**
  String get settingsPrimingFootnote;

  /// SettingsStrings.primingLater — Notification priming (S04)
  ///
  /// In vi, this message translates to:
  /// **'Để sau'**
  String get settingsPrimingLater;

  /// SettingsStrings.primingPointNightMarket — Notification priming (S04)
  ///
  /// In vi, this message translates to:
  /// **'Biết khi Chợ Đêm mở'**
  String get settingsPrimingPointNightMarket;

  /// SettingsStrings.primingPointNightMarketDetail — Notification priming (S04)
  ///
  /// In vi, this message translates to:
  /// **'Để kịp lật thẻ ưu đãi trước khi hết hạn'**
  String get settingsPrimingPointNightMarketDetail;

  /// SettingsStrings.primingPointStore — Notification priming (S04)
  ///
  /// In vi, this message translates to:
  /// **'Nhắc khi cửa hàng hằng ngày làm mới'**
  String get settingsPrimingPointStore;

  /// SettingsStrings.primingPointStoreDetail — Notification priming (S04)
  ///
  /// In vi, this message translates to:
  /// **'Nhắc sau khi cửa hàng của tài khoản làm mới'**
  String get settingsPrimingPointStoreDetail;

  /// SettingsStrings.primingPointWishlist — Notification priming (S04)
  ///
  /// In vi, this message translates to:
  /// **'Báo khi skin bạn săn xuất hiện'**
  String get settingsPrimingPointWishlist;

  /// SettingsStrings.primingPointWishlistDetail — Notification priming (S04)
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra cửa hàng của mọi tài khoản, kể cả khi bạn không mở ứng dụng'**
  String get settingsPrimingPointWishlistDetail;

  /// SettingsStrings.primingTitle — Notification priming (S04)
  ///
  /// In vi, this message translates to:
  /// **'Đừng bỏ lỡ skin bạn săn'**
  String get settingsPrimingTitle;

  /// SettingsStrings.removedAccount — TÀI KHOẢN
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa {account}'**
  String settingsRemovedAccount(String account);

  /// SettingsStrings.serverStatus — HỖ TRỢ
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái máy chủ'**
  String get settingsServerStatus;

  /// SettingsStrings.serverStatusMaintenance — HỖ TRỢ
  ///
  /// In vi, this message translates to:
  /// **'Đang bảo trì'**
  String get settingsServerStatusMaintenance;

  /// SettingsStrings.serverStatusNotices — HỖ TRỢ
  ///
  /// In vi, this message translates to:
  /// **'{n} thông báo'**
  String settingsServerStatusNotices(int n);

  /// SettingsStrings.serverStatusSubtitle — HỖ TRỢ
  ///
  /// In vi, this message translates to:
  /// **'Bảo trì và sự cố VALORANT theo máy chủ'**
  String get settingsServerStatusSubtitle;

  /// Subject / title of the shared bug-report file ("Gửi báo lỗi cho ValHub").
  ///
  /// In vi, this message translates to:
  /// **'Báo lỗi ValHub'**
  String get settingsSessionLogTitle;

  /// SettingsStrings.severityCritical — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Nghiêm trọng'**
  String get settingsSeverityCritical;

  /// SettingsStrings.severityInfo — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Thông tin'**
  String get settingsSeverityInfo;

  /// SettingsStrings.severityWarning — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Cảnh báo'**
  String get settingsSeverityWarning;

  /// SettingsStrings.signedOutAll — Sign out
  ///
  /// In vi, this message translates to:
  /// **'Đã đăng xuất tất cả tài khoản'**
  String get settingsSignedOutAll;

  /// SettingsStrings.statusAllGood — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Máy chủ hoạt động bình thường'**
  String get settingsStatusAllGood;

  /// SettingsStrings.statusAllGoodBody — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Không có sự cố hay bảo trì nào ở máy chủ {region}.'**
  String settingsStatusAllGoodBody(String region);

  /// SettingsStrings.statusFewerUpdates — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Thu gọn'**
  String get settingsStatusFewerUpdates;

  /// SettingsStrings.statusIssues — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Riot đang xử lý sự cố'**
  String get settingsStatusIssues;

  /// SettingsStrings.statusIssuesBody — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Máy chủ này có {n} thông báo sự cố.'**
  String settingsStatusIssuesBody(int n);

  /// SettingsStrings.statusKindIncident — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Sự cố'**
  String get settingsStatusKindIncident;

  /// SettingsStrings.statusKindMaintenance — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Bảo trì'**
  String get settingsStatusKindMaintenance;

  /// SettingsStrings.statusMaintenanceNow — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Máy chủ đang bảo trì'**
  String get settingsStatusMaintenanceNow;

  /// SettingsStrings.statusMaintenanceNowBody — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Bạn có thể chưa vào được game, và ValHub có thể tạm thời chưa tải được thông tin.'**
  String get settingsStatusMaintenanceNowBody;

  /// SettingsStrings.statusMoreUpdates — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Xem thêm {n} cập nhật'**
  String settingsStatusMoreUpdates(int n);

  /// SettingsStrings.statusScheduled — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Sắp có bảo trì'**
  String get settingsStatusScheduled;

  /// SettingsStrings.statusScheduledBody — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'{n} lịch bảo trì đã được Riot thông báo.'**
  String settingsStatusScheduledBody(int n);

  /// SettingsStrings.statusSourceNote — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Nguồn: trang trạng thái chính thức của Riot Games. Giờ hiển thị theo múi giờ của thiết bị.'**
  String get settingsStatusSourceNote;

  /// SettingsStrings.statusStarted — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu {when}'**
  String settingsStatusStarted(String when);

  /// SettingsStrings.statusUpdated — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'Cập nhật {when}'**
  String settingsStatusUpdated(String when);

  /// SettingsStrings.statusUpdatesHeader — Server status screen (ValHub extra, X-1)
  ///
  /// In vi, this message translates to:
  /// **'CẬP NHẬT TỪ RIOT'**
  String get settingsStatusUpdatesHeader;

  /// SettingsStrings.supportHeader — Section headers (S70)
  ///
  /// In vi, this message translates to:
  /// **'HỖ TRỢ'**
  String get settingsSupportHeader;

  /// SettingsStrings.switchedTo — TÀI KHOẢN
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển sang {account}'**
  String settingsSwitchedTo(String account);

  /// SettingsStrings.themeDark — GIAO DIỆN
  ///
  /// In vi, this message translates to:
  /// **'Tối'**
  String get settingsThemeDark;

  /// SettingsStrings.themeLabel — GIAO DIỆN
  ///
  /// In vi, this message translates to:
  /// **'Chủ đề'**
  String get settingsThemeLabel;

  /// SettingsStrings.themeLight — GIAO DIỆN
  ///
  /// In vi, this message translates to:
  /// **'Sáng'**
  String get settingsThemeLight;

  /// SettingsStrings.themePickerTitle — GIAO DIỆN
  ///
  /// In vi, this message translates to:
  /// **'Chọn chủ đề'**
  String get settingsThemePickerTitle;

  /// SettingsStrings.themeSystem — GIAO DIỆN
  ///
  /// In vi, this message translates to:
  /// **'Theo hệ thống'**
  String get settingsThemeSystem;

  /// SettingsStrings.title —
  ///
  /// In vi, this message translates to:
  /// **'Cài đặt'**
  String get settingsTitle;

  /// SettingsStrings.version — NÂNG CAO (the version lives on the About screen only)
  ///
  /// In vi, this message translates to:
  /// **'Phiên bản {version}'**
  String settingsVersion(String version);

  /// SettingsStrings.welcomeBulletProfile — Welcome (S01)
  ///
  /// In vi, this message translates to:
  /// **'Rank, lịch sử đấu, trận đang diễn ra'**
  String get settingsWelcomeBulletProfile;

  /// SettingsStrings.welcomeBulletProfileDetail — Welcome hero (S01)
  ///
  /// In vi, this message translates to:
  /// **'RR từng trận, rank đối thủ'**
  String get settingsWelcomeBulletProfileDetail;

  /// SettingsStrings.welcomeBulletStore — Welcome (S01)
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng hằng ngày, Chợ Đêm và bundle'**
  String get settingsWelcomeBulletStore;

  /// SettingsStrings.welcomeBulletStoreDetail — Welcome hero (S01)
  ///
  /// In vi, this message translates to:
  /// **'Xem giá, độ hiếm, đếm ngược làm mới'**
  String get settingsWelcomeBulletStoreDetail;

  /// SettingsStrings.welcomeBulletWishlist — Welcome (S01)
  ///
  /// In vi, this message translates to:
  /// **'Wishlist & thông báo'**
  String get settingsWelcomeBulletWishlist;

  /// SettingsStrings.welcomeBulletWishlistDetail — Welcome hero (S01)
  ///
  /// In vi, this message translates to:
  /// **'Báo khi skin bạn săn lên kệ'**
  String get settingsWelcomeBulletWishlistDetail;

  /// SettingsStrings.welcomeFootnote — Welcome (S01)
  ///
  /// In vi, this message translates to:
  /// **'Bạn đăng nhập trên trang chính thức của Riot. ValHub chỉ lưu mật khẩu khi bạn tự chọn lưu thông tin đăng nhập.'**
  String get settingsWelcomeFootnote;

  /// SettingsStrings.welcomeKicker — Welcome hero (S01)
  ///
  /// In vi, this message translates to:
  /// **'TRỢ THỦ VALORANT'**
  String get settingsWelcomeKicker;

  /// Settings section header (shown uppercase): the country used by the app and the local-currency estimate next to VP prices.
  ///
  /// In vi, this message translates to:
  /// **'Quốc gia & giá'**
  String get settingsCountryPriceHeader;

  /// Settings section header (shown uppercase) grouping every clean-up of data stored on this device.
  ///
  /// In vi, this message translates to:
  /// **'Dữ liệu trên máy'**
  String get settingsDataHeader;

  /// Welcome screen highlight title: the Community tab.
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng'**
  String get settingsWelcomeBulletCommunity;

  /// Welcome screen highlight detail under 'Cộng đồng': looking for group, rating and voting on skins.
  ///
  /// In vi, this message translates to:
  /// **'Tìm đồng đội, đánh giá và bình chọn skin'**
  String get settingsWelcomeBulletCommunityDetail;

  /// Explicit render-time message, preserving existing VI behavior.
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng: {hasAverage, select, yes{★ {average} ({count} đánh giá) · } other{}}{votes} lượt thích'**
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  );

  /// SkinDetailStrings.addToWishlist —
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào wishlist'**
  String get skinDetailAddToWishlist;

  /// "Có trong cửa hàng của: Tài khoản 2".
  ///
  /// In vi, this message translates to:
  /// **'Có trong cửa hàng của: {accounts}'**
  String skinDetailAvailableInStoreOf(String accounts);

  /// SkinDetailStrings.historyDelete —
  ///
  /// In vi, this message translates to:
  /// **'Xóa lịch sử cửa hàng'**
  String get skinDetailHistoryDelete;

  /// SkinDetailStrings.historyDeleteBody —
  ///
  /// In vi, this message translates to:
  /// **'Xóa tất cả ngày cửa hàng đã ghi cho tài khoản này trên thiết bị?'**
  String get skinDetailHistoryDeleteBody;

  /// SkinDetailStrings.inWishlist —
  ///
  /// In vi, this message translates to:
  /// **'Đã có trong wishlist'**
  String get skinDetailInWishlist;

  /// "Cấp 4 · Đòn kết liễu".
  ///
  /// In vi, this message translates to:
  /// **'{level} · {item}'**
  String skinDetailLevelCaption(String level, String item);

  /// SkinDetailStrings.locked —
  ///
  /// In vi, this message translates to:
  /// **'Chưa mở khóa'**
  String get skinDetailLocked;

  /// SkinDetailStrings.mute —
  ///
  /// In vi, this message translates to:
  /// **'Tắt tiếng'**
  String get skinDetailMute;

  /// SkinDetailStrings.notFound —
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy skin này.'**
  String get skinDetailNotFound;

  /// SkinDetailStrings.owned —
  ///
  /// In vi, this message translates to:
  /// **'Đã sở hữu'**
  String get skinDetailOwned;

  /// SkinDetailStrings.pause —
  ///
  /// In vi, this message translates to:
  /// **'Tạm dừng'**
  String get skinDetailPause;

  /// SkinDetailStrings.play —
  ///
  /// In vi, this message translates to:
  /// **'Phát'**
  String get skinDetailPlay;

  /// SkinDetailStrings.playVideo —
  ///
  /// In vi, this message translates to:
  /// **'Xem video'**
  String get skinDetailPlayVideo;

  /// SkinDetailStrings.removeFromWishlist —
  ///
  /// In vi, this message translates to:
  /// **'Xóa khỏi wishlist'**
  String get skinDetailRemoveFromWishlist;

  /// SkinDetailStrings.title —
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết skin'**
  String get skinDetailTitle;

  /// SkinDetailStrings.unmute —
  ///
  /// In vi, this message translates to:
  /// **'Bật tiếng'**
  String get skinDetailUnmute;

  /// SkinDetailStrings.upgrades —
  ///
  /// In vi, this message translates to:
  /// **'Nâng cấp'**
  String get skinDetailUpgrades;

  /// SkinDetailStrings.variants —
  ///
  /// In vi, this message translates to:
  /// **'Biến thể'**
  String get skinDetailVariants;

  /// SkinDetailStrings.videoError —
  ///
  /// In vi, this message translates to:
  /// **'Không phát được video. Kiểm tra mạng rồi thử lại.'**
  String get skinDetailVideoError;

  /// Skin sheet line: how many recorded daily shops of the active account offered this skin (only shown when 1 or more). Opens Store history.
  ///
  /// In vi, this message translates to:
  /// **'{n, plural, other{Lên cửa hàng của bạn {n} lần}}'**
  String skinDetailSeenDaily(int n);

  /// Skin sheet line, after skinDetailSeenDaily: how many recorded Night Market runs offered this skin (only when 1 or more). Night Market = the game's official name.
  ///
  /// In vi, this message translates to:
  /// **'{n, plural, other{Chợ Đêm {n} lần}}'**
  String skinDetailSeenNight(int n);

  /// Render-time friend presence copy, preserving existing Vietnamese status semantics.
  ///
  /// In vi, this message translates to:
  /// **'Đang đấu'**
  String get socialPresenceInMatch;

  /// Render-time friend presence copy, preserving existing Vietnamese status semantics.
  ///
  /// In vi, this message translates to:
  /// **'Đang chọn đặc vụ'**
  String get socialPresenceAgentSelect;

  /// Render-time friend presence copy, preserving existing Vietnamese status semantics.
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm trận'**
  String get socialPresenceQueue;

  /// Render-time friend presence copy, preserving existing Vietnamese status semantics.
  ///
  /// In vi, this message translates to:
  /// **'Đang ở sảnh chờ'**
  String get socialPresenceLobby;

  /// Render-time friend presence copy, preserving existing Vietnamese status semantics.
  ///
  /// In vi, this message translates to:
  /// **'Đang chơi tự do'**
  String get socialPresenceCustom;

  /// Render-time friend presence copy, preserving existing Vietnamese status semantics.
  ///
  /// In vi, this message translates to:
  /// **'{status} · {detail}'**
  String socialPresenceDetails(String status, String detail);

  /// Party header summary. state=open for an open party; other means invite-only. Manual select preserves legacy partySummary.
  ///
  /// In vi, this message translates to:
  /// **'{size}/{max} người · {state, select, open{Tổ đội mở} other{Chỉ người được mời}}'**
  String socialPartySummary(int size, int max, String state);

  /// SocialStrings.accept — party
  ///
  /// In vi, this message translates to:
  /// **'Chấp nhận'**
  String get socialAccept;

  /// SocialStrings.acceptInGame — party
  ///
  /// In vi, this message translates to:
  /// **'Hãy chấp nhận lời mời này trong game.'**
  String get socialAcceptInGame;

  /// SocialStrings.actionFailed — party
  ///
  /// In vi, this message translates to:
  /// **'Chưa hoàn tất thao tác. {message}'**
  String socialActionFailed(String message);

  /// SocialStrings.autoRefresh — party
  ///
  /// In vi, this message translates to:
  /// **'Tự động làm mới'**
  String get socialAutoRefresh;

  /// SocialStrings.away — Status lines (SUMMARY §9.9, VF S60)
  ///
  /// In vi, this message translates to:
  /// **'Vắng mặt'**
  String get socialAway;

  /// SocialStrings.cancelQueue — party
  ///
  /// In vi, this message translates to:
  /// **'Hủy tìm trận · {elapsed}'**
  String socialCancelQueue(String elapsed);

  /// SocialStrings.cancelQueueShort — party
  ///
  /// In vi, this message translates to:
  /// **'Hủy tìm trận'**
  String get socialCancelQueueShort;

  /// "Tổ đội chưa thể vào Thi đấu xếp hạng: {reason}" (VF §8.11).
  ///
  /// In vi, this message translates to:
  /// **'Tổ đội chưa thể vào {queue}: {reason}'**
  String socialCantQueue(String queue, String reason);

  /// SocialStrings.changeQueue — party
  ///
  /// In vi, this message translates to:
  /// **'Đổi hàng chờ'**
  String get socialChangeQueue;

  /// SocialStrings.chatUnavailable — friends
  ///
  /// In vi, this message translates to:
  /// **'Trò chuyện đang ngoại tuyến.'**
  String get socialChatUnavailable;

  /// SocialStrings.closeParty — party
  ///
  /// In vi, this message translates to:
  /// **'Đóng tổ đội'**
  String get socialCloseParty;

  /// SocialStrings.codeInvalid — party
  ///
  /// In vi, this message translates to:
  /// **'Mã tổ đội chỉ gồm chữ cái và chữ số.'**
  String get socialCodeInvalid;

  /// SocialStrings.connecting — friends
  ///
  /// In vi, this message translates to:
  /// **'Đang kết nối trò chuyện…'**
  String get socialConnecting;

  /// SocialStrings.copyCode — party
  ///
  /// In vi, this message translates to:
  /// **'Sao chép'**
  String get socialCopyCode;

  /// SocialStrings.currentQueue — party
  ///
  /// In vi, this message translates to:
  /// **'Đang chọn'**
  String get socialCurrentQueue;

  /// SocialStrings.customGameLobby — party
  ///
  /// In vi, this message translates to:
  /// **'Tổ đội đang ở sảnh Chơi tự do.'**
  String get socialCustomGameLobby;

  /// SocialStrings.decline — party
  ///
  /// In vi, this message translates to:
  /// **'Từ chối'**
  String get socialDecline;

  /// SocialStrings.disableCode — party
  ///
  /// In vi, this message translates to:
  /// **'Tắt mã'**
  String get socialDisableCode;

  /// SocialStrings.emptyChat — chat
  ///
  /// In vi, this message translates to:
  /// **'Chưa có tin nhắn. Hãy gửi lời chào!'**
  String get socialEmptyChat;

  /// SocialStrings.emptyChatTitle — chat
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu trò chuyện'**
  String get socialEmptyChatTitle;

  /// SocialStrings.failedBadge — chat
  ///
  /// In vi, this message translates to:
  /// **'Chưa gửi được'**
  String get socialFailedBadge;

  /// SocialStrings.filterAll — friends
  ///
  /// In vi, this message translates to:
  /// **'Tất cả'**
  String get socialFilterAll;

  /// SocialStrings.filterOnline — friends
  ///
  /// In vi, this message translates to:
  /// **'Trực tuyến'**
  String get socialFilterOnline;

  /// SocialStrings.filterUnread — friends
  ///
  /// In vi, this message translates to:
  /// **'Chưa đọc'**
  String get socialFilterUnread;

  /// SocialStrings.friendsPrivacyNote — friends
  ///
  /// In vi, this message translates to:
  /// **'Danh sách bạn bè và tin nhắn lấy trực tiếp từ Riot. ValHub không lưu chúng ở nơi nào khác.'**
  String get socialFriendsPrivacyNote;

  /// "24 bạn · 5 đang trực tuyến" (under the large title).
  ///
  /// In vi, this message translates to:
  /// **'{total} bạn · {online} đang trực tuyến'**
  String socialFriendsSummary(int total, int online);

  /// SocialStrings.friendsTitle —
  ///
  /// In vi, this message translates to:
  /// **'Bạn bè & trò chuyện'**
  String get socialFriendsTitle;

  /// SocialStrings.gameNotRunningBody — party
  ///
  /// In vi, this message translates to:
  /// **'Tổ đội & hàng chờ chỉ hoạt động khi VALORANT đang chạy trên máy tính hoặc console của bạn. Mở game rồi kéo xuống để làm mới.'**
  String get socialGameNotRunningBody;

  /// SocialStrings.gameNotRunningTitle — party
  ///
  /// In vi, this message translates to:
  /// **'Mở VALORANT trên máy tính hoặc máy chơi game'**
  String get socialGameNotRunningTitle;

  /// SocialStrings.generateCode — party
  ///
  /// In vi, this message translates to:
  /// **'Tạo mã'**
  String get socialGenerateCode;

  /// SocialStrings.idleQueue — party
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng tìm trận'**
  String get socialIdleQueue;

  /// SocialStrings.inMatchBanner — party
  ///
  /// In vi, this message translates to:
  /// **'Bạn đang trong trận. Hàng chờ sẽ mở lại khi trận kết thúc.'**
  String get socialInMatchBanner;

  /// SocialStrings.inValorant — Status lines (SUMMARY §9.9, VF S60)
  ///
  /// In vi, this message translates to:
  /// **'Đang trong VALORANT'**
  String get socialInValorant;

  /// SocialStrings.inviteByRiotId — party
  ///
  /// In vi, this message translates to:
  /// **'Mời bằng Riot ID'**
  String get socialInviteByRiotId;

  /// SocialStrings.inviteByRiotIdHint — party
  ///
  /// In vi, this message translates to:
  /// **'Mời cả người chưa kết bạn'**
  String get socialInviteByRiotIdHint;

  /// SocialStrings.inviteFriends — party
  ///
  /// In vi, this message translates to:
  /// **'Mời bạn bè'**
  String get socialInviteFriends;

  /// SocialStrings.inviteFrom — party
  ///
  /// In vi, this message translates to:
  /// **'Lời mời từ {name}'**
  String socialInviteFrom(String name);

  /// SocialStrings.inviteLabel — party
  ///
  /// In vi, this message translates to:
  /// **'Mời {name}'**
  String socialInviteLabel(String name);

  /// SocialStrings.inviteNeedsName — party
  ///
  /// In vi, this message translates to:
  /// **'Chưa biết Riot ID của người này nên chưa thể mời.'**
  String get socialInviteNeedsName;

  /// SocialStrings.inviteSent — party
  ///
  /// In vi, this message translates to:
  /// **'Đã gửi lời mời tới {name}.'**
  String socialInviteSent(String name);

  /// SocialStrings.invitedLabel — party
  ///
  /// In vi, this message translates to:
  /// **'{name} · Đã mời'**
  String socialInvitedLabel(String name);

  /// SocialStrings.invitesSection — party
  ///
  /// In vi, this message translates to:
  /// **'Lời mời'**
  String get socialInvitesSection;

  /// SocialStrings.join — party
  ///
  /// In vi, this message translates to:
  /// **'Tham gia'**
  String get socialJoin;

  /// SocialStrings.joinConfirmBody — party
  ///
  /// In vi, this message translates to:
  /// **'Bạn sẽ rời tổ đội hiện tại để vào tổ đội có mã này.'**
  String get socialJoinConfirmBody;

  /// SocialStrings.joinConfirmTitle — party
  ///
  /// In vi, this message translates to:
  /// **'Tham gia tổ đội khác?'**
  String get socialJoinConfirmTitle;

  /// SocialStrings.joinSection — party
  ///
  /// In vi, this message translates to:
  /// **'Vào tổ đội khác'**
  String get socialJoinSection;

  /// SocialStrings.joinWithCode — party
  ///
  /// In vi, this message translates to:
  /// **'Nhập mã để tham gia'**
  String get socialJoinWithCode;

  /// SocialStrings.joined — party
  ///
  /// In vi, this message translates to:
  /// **'Đã tham gia tổ đội.'**
  String get socialJoined;

  /// SocialStrings.lastOnline — Status lines (SUMMARY §9.9, VF S60)
  ///
  /// In vi, this message translates to:
  /// **'Hoạt động {relative}'**
  String socialLastOnline(String relative);

  /// SocialStrings.leader — party
  ///
  /// In vi, this message translates to:
  /// **'Trưởng nhóm'**
  String get socialLeader;

  /// Leaderboard position of Immortal / Radiant players ("Top 1.234").
  ///
  /// In vi, this message translates to:
  /// **'Top {position}'**
  String socialLeaderboardTop(String position);

  /// SocialStrings.leaveConfirmBody — party
  ///
  /// In vi, this message translates to:
  /// **'Bạn sẽ rời tổ đội hiện tại và về tổ đội riêng.'**
  String get socialLeaveConfirmBody;

  /// SocialStrings.leaveConfirmTitle — party
  ///
  /// In vi, this message translates to:
  /// **'Rời tổ đội?'**
  String get socialLeaveConfirmTitle;

  /// SocialStrings.leaveParty — party
  ///
  /// In vi, this message translates to:
  /// **'Rời tổ đội'**
  String get socialLeaveParty;

  /// SocialStrings.level — party
  ///
  /// In vi, this message translates to:
  /// **'Cấp {n}'**
  String socialLevel(int n);

  /// SocialStrings.matchFound — party
  ///
  /// In vi, this message translates to:
  /// **'Đã tìm thấy trận!'**
  String get socialMatchFound;

  /// SocialStrings.membersSection — party
  ///
  /// In vi, this message translates to:
  /// **'Thành viên ({n}/{max})'**
  String socialMembersSection(int n, int max);

  /// SocialStrings.messageHint — chat
  ///
  /// In vi, this message translates to:
  /// **'Nhập tin nhắn…'**
  String get socialMessageHint;

  /// SocialStrings.moreActions — party
  ///
  /// In vi, this message translates to:
  /// **'Tùy chọn khác'**
  String get socialMoreActions;

  /// SocialStrings.noCode — party
  ///
  /// In vi, this message translates to:
  /// **'Tạo mã để bạn bè vào tổ đội nhanh bằng mã.'**
  String get socialNoCode;

  /// SocialStrings.noCodeMember — party
  ///
  /// In vi, this message translates to:
  /// **'Trưởng nhóm có thể tạo mã để mời nhanh.'**
  String get socialNoCodeMember;

  /// SocialStrings.noFilterResults — friends
  ///
  /// In vi, this message translates to:
  /// **'Không có bạn bè nào khớp bộ lọc này.'**
  String get socialNoFilterResults;

  /// SocialStrings.noFriends — friends
  ///
  /// In vi, this message translates to:
  /// **'Danh sách bạn bè Riot của bạn đang trống. Hãy kết bạn trong game.'**
  String get socialNoFriends;

  /// SocialStrings.noFriendsTitle — friends
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bạn bè'**
  String get socialNoFriendsTitle;

  /// SocialStrings.noOnlineFriends — party
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bạn bè nào đang trực tuyến trong VALORANT.'**
  String get socialNoOnlineFriends;

  /// SocialStrings.noSearchResults — friends
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy bạn bè nào phù hợp.'**
  String get socialNoSearchResults;

  /// SocialStrings.noSearchResultsTitle — friends
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy'**
  String get socialNoSearchResultsTitle;

  /// SocialStrings.notReady — party
  ///
  /// In vi, this message translates to:
  /// **'Chưa sẵn sàng'**
  String get socialNotReady;

  /// SocialStrings.offlineSection — friends
  ///
  /// In vi, this message translates to:
  /// **'Ngoại tuyến ({n})'**
  String socialOfflineSection(int n);

  /// SocialStrings.offlineStatus — Status lines (SUMMARY §9.9, VF S60)
  ///
  /// In vi, this message translates to:
  /// **'Ngoại tuyến'**
  String get socialOfflineStatus;

  /// SocialStrings.onlineMobile — Status lines (SUMMARY §9.9, VF S60)
  ///
  /// In vi, this message translates to:
  /// **'Trực tuyến trên điện thoại'**
  String get socialOnlineMobile;

  /// SocialStrings.onlineSection — friends
  ///
  /// In vi, this message translates to:
  /// **'Trực tuyến ({n})'**
  String socialOnlineSection(int n);

  /// SocialStrings.onlineStatus — Status lines (SUMMARY §9.9, VF S60)
  ///
  /// In vi, this message translates to:
  /// **'Trực tuyến'**
  String get socialOnlineStatus;

  /// SocialStrings.onlyLeader — party
  ///
  /// In vi, this message translates to:
  /// **'Chỉ trưởng nhóm mới có thể đổi hàng chờ và bắt đầu tìm trận.'**
  String get socialOnlyLeader;

  /// SocialStrings.openParty — party
  ///
  /// In vi, this message translates to:
  /// **'Mở tổ đội'**
  String get socialOpenParty;

  /// Other Riot games by `<games>` element name.
  ///
  /// In vi, this message translates to:
  /// **'Liên Minh Huyền Thoại'**
  String get socialOtherGamesLeagueOfLegends;

  /// Other Riot games by `<games>` element name.
  ///
  /// In vi, this message translates to:
  /// **'Huyền Thoại Runeterra'**
  String get socialOtherGamesBacon;

  /// Other Riot games by `<games>` element name.
  ///
  /// In vi, this message translates to:
  /// **'2XKO'**
  String get socialOtherGamesLion;

  /// SocialStrings.partyCode — party
  ///
  /// In vi, this message translates to:
  /// **'Mã tổ đội'**
  String get socialPartyCode;

  /// SocialStrings.partyCodeValue — party
  ///
  /// In vi, this message translates to:
  /// **'Mã tổ đội: {code}'**
  String socialPartyCodeValue(String code);

  /// SocialStrings.partyInvite — party
  ///
  /// In vi, this message translates to:
  /// **'Lời mời vào tổ đội'**
  String get socialPartyInvite;

  /// "Tổ đội 3/5".
  ///
  /// In vi, this message translates to:
  /// **'Tổ đội {size}/{max}'**
  String socialPartyOf(int size, int max);

  /// SocialStrings.partyTitle —
  ///
  /// In vi, this message translates to:
  /// **'Tổ đội & hàng chờ'**
  String get socialPartyTitle;

  /// SocialStrings.pickQueueSubtitle — party
  ///
  /// In vi, this message translates to:
  /// **'Tổ đội {size} người'**
  String socialPickQueueSubtitle(int size);

  /// SocialStrings.pickQueueTitle — party
  ///
  /// In vi, this message translates to:
  /// **'Chọn hàng chờ'**
  String get socialPickQueueTitle;

  /// Best ping of a member to the game servers ("24 ms").
  ///
  /// In vi, this message translates to:
  /// **'{ms} ms'**
  String socialPing(int ms);

  /// SocialStrings.pingTooltip — party
  ///
  /// In vi, this message translates to:
  /// **'Ping tốt nhất tới máy chủ trận đấu'**
  String get socialPingTooltip;

  /// SocialStrings.playingOther — Status lines (SUMMARY §9.9, VF S60)
  ///
  /// In vi, this message translates to:
  /// **'Đang chơi {game}'**
  String socialPlayingOther(String game);

  /// SocialStrings.playingSection — friends
  ///
  /// In vi, this message translates to:
  /// **'Đang chơi ({n})'**
  String socialPlayingSection(int n);

  /// SocialStrings.queueLabel — party
  ///
  /// In vi, this message translates to:
  /// **'Hàng chờ'**
  String get socialQueueLabel;

  /// SocialStrings.queueLocked — party
  ///
  /// In vi, this message translates to:
  /// **'Không thể đổi hàng chờ khi đang trong trận.'**
  String get socialQueueLocked;

  /// SocialStrings.queueMaxParty — party
  ///
  /// In vi, this message translates to:
  /// **'{max, plural, =1{Chỉ chơi một mình} other{Tối đa {max} người}}'**
  String socialQueueMaxParty(int max);

  /// Fail-closed party controls when game session state is unavailable; the user can refresh the existing screen.
  ///
  /// In vi, this message translates to:
  /// **'Chưa xác minh được trạng thái game. Làm mới để sử dụng sẵn sàng và hàng chờ.'**
  String get socialQueueStatusUnavailable;

  /// SocialStrings.ready — party
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng'**
  String get socialReady;

  /// "Sẵn sàng 3/5".
  ///
  /// In vi, this message translates to:
  /// **'Sẵn sàng {ready}/{total}'**
  String socialReadyCount(int ready, int total);

  /// SocialStrings.reasonAccountLevel — party
  ///
  /// In vi, this message translates to:
  /// **'có thành viên chưa đủ cấp tài khoản'**
  String get socialReasonAccountLevel;

  /// SocialStrings.reasonGeneric — party
  ///
  /// In vi, this message translates to:
  /// **'tổ đội chưa đủ điều kiện'**
  String get socialReasonGeneric;

  /// SocialStrings.reasonPartyTooLarge — party
  ///
  /// In vi, this message translates to:
  /// **'tổ đội quá đông (tối đa {max} người)'**
  String socialReasonPartyTooLarge(int max);

  /// SocialStrings.reasonRankDisparity — party
  ///
  /// In vi, this message translates to:
  /// **'chênh lệch rank quá lớn để đấu xếp hạng'**
  String get socialReasonRankDisparity;

  /// SocialStrings.reasonRestricted — party
  ///
  /// In vi, this message translates to:
  /// **'tổ đội đang bị hạn chế tìm trận (còn {time})'**
  String socialReasonRestricted(String time);

  /// SocialStrings.reconnecting — friends
  ///
  /// In vi, this message translates to:
  /// **'Mất kết nối trò chuyện. Đang kết nối lại…'**
  String get socialReconnecting;

  /// SocialStrings.remoteNote — party
  ///
  /// In vi, this message translates to:
  /// **'Mọi thay đổi chỉ được gửi tới Riot khi bạn bấm. ValHub không tự tìm trận hay khóa đặc vụ thay bạn.'**
  String get socialRemoteNote;

  /// SocialStrings.removeConfirmBody — party
  ///
  /// In vi, this message translates to:
  /// **'{name} sẽ bị xóa khỏi tổ đội của bạn.'**
  String socialRemoveConfirmBody(String name);

  /// SocialStrings.removeConfirmTitle — party
  ///
  /// In vi, this message translates to:
  /// **'Xóa khỏi tổ đội?'**
  String get socialRemoveConfirmTitle;

  /// SocialStrings.removeMember — party
  ///
  /// In vi, this message translates to:
  /// **'Xóa khỏi tổ đội'**
  String get socialRemoveMember;

  /// SocialStrings.requestFrom — party
  ///
  /// In vi, this message translates to:
  /// **'{name} muốn vào tổ đội'**
  String socialRequestFrom(String name);

  /// SocialStrings.requestsSection — party
  ///
  /// In vi, this message translates to:
  /// **'Yêu cầu tham gia'**
  String get socialRequestsSection;

  /// SocialStrings.riotIdFieldHint — party
  ///
  /// In vi, this message translates to:
  /// **'Tên#TAG'**
  String get socialRiotIdFieldHint;

  /// SocialStrings.riotIdInvalid — party
  ///
  /// In vi, this message translates to:
  /// **'Riot ID gồm tên (3–16 ký tự), dấu # và tag (3–5 chữ hoặc số).'**
  String get socialRiotIdInvalid;

  /// SocialStrings.searchHint — friends
  ///
  /// In vi, this message translates to:
  /// **'Tìm theo Riot ID…'**
  String get socialSearchHint;

  /// SocialStrings.searching — party
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm trận · {elapsed}'**
  String socialSearching(String elapsed);

  /// SocialStrings.send — chat
  ///
  /// In vi, this message translates to:
  /// **'Gửi'**
  String get socialSend;

  /// SocialStrings.sendFailed — chat
  ///
  /// In vi, this message translates to:
  /// **'Không gửi được tin nhắn. Kiểm tra kết nối rồi thử lại.'**
  String get socialSendFailed;

  /// SocialStrings.sendInvite — party
  ///
  /// In vi, this message translates to:
  /// **'Gửi lời mời'**
  String get socialSendInvite;

  /// SocialStrings.shareCode — party
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ'**
  String get socialShareCode;

  /// Text shared with the party code (OS share sheet).
  ///
  /// In vi, this message translates to:
  /// **'Vào tổ đội VALORANT của mình bằng mã: {code}'**
  String socialShareCodeText(String code);

  /// SocialStrings.shootingRange — Status lines (SUMMARY §9.9, VF S60)
  ///
  /// In vi, this message translates to:
  /// **'Đang ở trường bắn'**
  String get socialShootingRange;

  /// SocialStrings.showEveryone — friends
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get socialShowEveryone;

  /// SocialStrings.startQueue — party
  ///
  /// In vi, this message translates to:
  /// **'Bắt đầu tìm trận'**
  String get socialStartQueue;

  /// Quick openers: a tap only fills the message box, the player still taps "Gửi".
  ///
  /// In vi, this message translates to:
  /// **'Chào bạn!'**
  String get socialSuggestionsItem0;

  /// Quick openers: a tap only fills the message box, the player still taps "Gửi".
  ///
  /// In vi, this message translates to:
  /// **'Làm vài trận không?'**
  String get socialSuggestionsItem1;

  /// Quick openers: a tap only fills the message box, the player still taps "Gửi".
  ///
  /// In vi, this message translates to:
  /// **'Vào tổ đội với mình nhé!'**
  String get socialSuggestionsItem2;

  /// SocialStrings.unread — friends
  ///
  /// In vi, this message translates to:
  /// **'{n} tin chưa đọc'**
  String socialUnread(int n);

  /// SocialStrings.unready — party
  ///
  /// In vi, this message translates to:
  /// **'Bỏ sẵn sàng'**
  String get socialUnready;

  /// SocialStrings.viewProfile — chat
  ///
  /// In vi, this message translates to:
  /// **'Xem hồ sơ'**
  String get socialViewProfile;

  /// SocialStrings.waitingForConnection — chat
  ///
  /// In vi, this message translates to:
  /// **'Đang kết nối… Bạn có thể gửi tin khi kết nối xong.'**
  String get socialWaitingForConnection;

  /// SocialStrings.you — party
  ///
  /// In vi, this message translates to:
  /// **'Bạn'**
  String get socialYou;

  /// Party page: the party could not be read from Riot right now; pull to refresh or tap Retry.
  ///
  /// In vi, this message translates to:
  /// **'Chưa tải được tổ đội. Làm mới để thử lại.'**
  String get socialPartyUnavailable;

  /// Confirmation before accepting a party invite while the player is in a party with other people (title: socialJoinConfirmTitle).
  ///
  /// In vi, this message translates to:
  /// **'Bạn sẽ rời tổ đội hiện tại để vào tổ đội đã mời bạn.'**
  String get socialAcceptConfirmBody;

  /// Button next to a chat message that was not delivered: sends the same text again.
  ///
  /// In vi, this message translates to:
  /// **'Gửi lại'**
  String get socialResend;

  /// StoreStrings.accessoryEmpty — Accessories (S12).
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng phụ kiện hiện không có gì.'**
  String get storeAccessoryEmpty;

  /// StoreStrings.accessoryEmptyTitle — Accessories (S12).
  ///
  /// In vi, this message translates to:
  /// **'Chưa có phụ kiện'**
  String get storeAccessoryEmptyTitle;

  /// StoreStrings.accessoryFrom — Accessories (S12).
  ///
  /// In vi, this message translates to:
  /// **'Từ: {contract}'**
  String storeAccessoryFrom(String contract);

  /// StoreStrings.accessoryRefreshIn — Accessories (S12).
  ///
  /// In vi, this message translates to:
  /// **'Làm mới sau {t}'**
  String storeAccessoryRefreshIn(String t);

  /// "Làm mới lúc 07:00 thứ Năm 01/10" (local wall time).
  ///
  /// In vi, this message translates to:
  /// **'Làm mới lúc {wall}'**
  String storeAccessoryResetAt(String wall);

  /// StoreStrings.addToWishlist — Shared badges and actions.
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào wishlist'**
  String get storeAddToWishlist;

  /// StoreStrings.backToBundles — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Xem các bundle đang bán'**
  String get storeBackToBundles;

  /// StoreStrings.bundleBuySeparateLabel — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Mua lẻ'**
  String get storeBundleBuySeparateLabel;

  /// StoreStrings.bundleDetailTitle —
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết bundle'**
  String get storeBundleDetailTitle;

  /// "Hết hạn lúc 07:00 thứ Tư 21/10" (local wall time).
  ///
  /// In vi, this message translates to:
  /// **'Hết hạn lúc {wall}'**
  String storeBundleEndsAt(String wall);

  /// StoreStrings.bundleEndsIn — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Còn {t}'**
  String storeBundleEndsIn(String t);

  /// StoreStrings.bundleItemCount — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'{n} vật phẩm'**
  String storeBundleItemCount(int n);

  /// StoreStrings.bundleItemFree — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Miễn phí'**
  String get storeBundleItemFree;

  /// StoreStrings.bundleItemsTitle — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Vật phẩm trong bundle'**
  String get storeBundleItemsTitle;

  /// StoreStrings.bundleNotFound — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy bundle này. Có thể bundle đã hết hạn.'**
  String get storeBundleNotFound;

  /// StoreStrings.bundleNotFoundTitle — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Bundle đã hết hạn'**
  String get storeBundleNotFoundTitle;

  /// "Đã sở hữu 2/6 vật phẩm" (bundle detail).
  ///
  /// In vi, this message translates to:
  /// **'Đã sở hữu {owned}/{total} vật phẩm'**
  String storeBundleOwnedCount(int owned, int total);

  /// StoreStrings.bundlePriceLabel — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Giá bundle'**
  String get storeBundlePriceLabel;

  /// StoreStrings.bundleSavingsLabel — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm'**
  String get storeBundleSavingsLabel;

  /// StoreStrings.bundleWholesaleOnly — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Chỉ bán trọn bộ, không mua lẻ.'**
  String get storeBundleWholesaleOnly;

  /// StoreStrings.bundlesEmpty — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Hiện không có bundle nào đang mở bán.'**
  String get storeBundlesEmpty;

  /// StoreStrings.bundlesEmptyTitle — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'Chưa có bundle'**
  String get storeBundlesEmptyTitle;

  /// StoreStrings.dailyEmpty — Daily shop (S10).
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay cửa hàng không có skin nào.'**
  String get storeDailyEmpty;

  /// StoreStrings.dailyEmptyTitle — Daily shop (S10).
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng trống'**
  String get storeDailyEmptyTitle;

  /// Local wall time of the daily reset (device time zone, 24 h): "Làm mới lúc 07:00 hằng ngày".
  ///
  /// In vi, this message translates to:
  /// **'Làm mới lúc {time} hằng ngày'**
  String storeDailyResetAt(String time);

  /// StoreStrings.dailyTotalLabel — Daily shop (S10).
  ///
  /// In vi, this message translates to:
  /// **'Tổng'**
  String get storeDailyTotalLabel;

  /// StoreStrings.nightMarketEmpty — Night Market (S11).
  ///
  /// In vi, this message translates to:
  /// **'Hiện chưa có Chợ Đêm.'**
  String get storeNightMarketEmpty;

  /// StoreStrings.nightMarketEmptyTitle — Night Market (S11).
  ///
  /// In vi, this message translates to:
  /// **'Chợ Đêm chưa mở'**
  String get storeNightMarketEmptyTitle;

  /// "Kết thúc lúc 07:00 thứ Tư 08/10" (local wall time).
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc lúc {wall}'**
  String storeNightMarketEndsAt(String wall);

  /// StoreStrings.nightMarketEndsIn — Night Market (S11).
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc sau {t}'**
  String storeNightMarketEndsIn(String t);

  /// StoreStrings.nightMarketNote — Night Market (S11).
  ///
  /// In vi, this message translates to:
  /// **'Ưu đãi Chợ Đêm là riêng cho tài khoản của bạn và không thể làm mới.'**
  String get storeNightMarketNote;

  /// StoreStrings.nightMarketTotalSavings — Night Market (S11).
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm tổng cộng {amount}'**
  String storeNightMarketTotalSavings(String amount);

  /// Offer not yet flipped in game.
  ///
  /// In vi, this message translates to:
  /// **'Chưa lật'**
  String get storeNightMarketUnrevealed;

  /// Screen-reader label of a store card: "Vandal Reaver, 1.775 VP".
  ///
  /// In vi, this message translates to:
  /// **'{name}, {price}'**
  String storeOfferSemantics(String name, String price);

  /// StoreStrings.ownedBadge — Shared badges and actions.
  ///
  /// In vi, this message translates to:
  /// **'Đã sở hữu'**
  String get storeOwnedBadge;

  /// "Đã sở hữu 1/4" (daily summary chip).
  ///
  /// In vi, this message translates to:
  /// **'Đã sở hữu {owned}/{total}'**
  String storeOwnedCount(int owned, int total);

  /// StoreStrings.quantity — Bundles (S13 / S14).
  ///
  /// In vi, this message translates to:
  /// **'×{n}'**
  String storeQuantity(int n);

  /// StoreStrings.removeFromWishlist — Shared badges and actions.
  ///
  /// In vi, this message translates to:
  /// **'Xóa khỏi wishlist'**
  String get storeRemoveFromWishlist;

  /// StoreStrings.resetNotificationTitle — Store-reset local notification (B8, VF §6.9).
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng đã làm mới'**
  String get storeResetNotificationTitle;

  /// StoreStrings.resetsIn — Daily shop (S10).
  ///
  /// In vi, this message translates to:
  /// **'Làm mới sau {t}'**
  String storeResetsIn(String t);

  /// StoreStrings.segmentAccessories —
  ///
  /// In vi, this message translates to:
  /// **'Phụ kiện'**
  String get storeSegmentAccessories;

  /// StoreStrings.segmentBundles —
  ///
  /// In vi, this message translates to:
  /// **'Bundle'**
  String get storeSegmentBundles;

  /// StoreStrings.segmentDaily —
  ///
  /// In vi, this message translates to:
  /// **'Hằng ngày'**
  String get storeSegmentDaily;

  /// StoreStrings.segmentNightMarket —
  ///
  /// In vi, this message translates to:
  /// **'Chợ Đêm'**
  String get storeSegmentNightMarket;

  /// StoreStrings.shareButton — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ'**
  String get storeShareButton;

  /// StoreStrings.shareCardBrand — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'ValHub'**
  String get storeShareCardBrand;

  /// StoreStrings.shareCardDaily — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng hôm nay'**
  String get storeShareCardDaily;

  /// StoreStrings.shareCardMark — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'V'**
  String get storeShareCardMark;

  /// StoreStrings.shareCardNightMarket — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Chợ Đêm'**
  String get storeShareCardNightMarket;

  /// StoreStrings.shareCardPriceNote — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Giá quy đổi chỉ là ước tính theo gói VP.'**
  String get storeShareCardPriceNote;

  /// "Tiết kiệm 2.331 VP".
  ///
  /// In vi, this message translates to:
  /// **'Tiết kiệm {vp}'**
  String storeShareCardSaved(String vp);

  /// StoreStrings.shareCardTagline — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Trợ thủ VALORANT của bạn'**
  String get storeShareCardTagline;

  /// "Tổng 6.500 VP".
  ///
  /// In vi, this message translates to:
  /// **'Tổng {vp}'**
  String storeShareCardTotal(String vp);

  /// "Đến 07:00 thứ Tư 08/10" (Night Market end on the picture).
  ///
  /// In vi, this message translates to:
  /// **'Đến {wall}'**
  String storeShareCardUntil(String wall);

  /// StoreStrings.shareCardWatermark — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'VALHUB'**
  String get storeShareCardWatermark;

  /// StoreStrings.shareDailyTitle — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ cửa hàng hôm nay'**
  String get storeShareDailyTitle;

  /// StoreStrings.shareFailed — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Không tạo được ảnh. Hãy thử lại.'**
  String get storeShareFailed;

  /// ASCII file names ("valvn-cua-hang-2026-09-29.png").
  ///
  /// In vi, this message translates to:
  /// **'valvn-store-{stamp}.png'**
  String storeShareFileDaily(String stamp);

  /// StoreStrings.shareFileNightMarket — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'valvn-night-market-{stamp}.png'**
  String storeShareFileNightMarket(String stamp);

  /// StoreStrings.shareImage — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ ảnh'**
  String get storeShareImage;

  /// StoreStrings.shareNightMarketTitle — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ Chợ Đêm'**
  String get storeShareNightMarketTitle;

  /// StoreStrings.sharePreparing — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Đang tải ảnh skin…'**
  String get storeSharePreparing;

  /// StoreStrings.shareShowPrice — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Hiện giá quy đổi ước tính'**
  String get storeShareShowPrice;

  /// StoreStrings.shareShowPriceHint — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Quy đổi theo gói VP có lợi nhất.'**
  String get storeShareShowPriceHint;

  /// StoreStrings.shareShowRiotId — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Hiện Riot ID trên ảnh'**
  String get storeShareShowRiotId;

  /// StoreStrings.shareShowRiotIdHint — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Tắt sẵn để giữ riêng tư cho bạn.'**
  String get storeShareShowRiotIdHint;

  /// Share-sheet subject / chooser title.
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng VALORANT hôm nay của mình'**
  String get storeShareSubjectDaily;

  /// StoreStrings.shareSubjectNightMarket — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Chợ Đêm VALORANT của mình'**
  String get storeShareSubjectNightMarket;

  /// StoreStrings.shareSubtitle — "Chia sẻ ảnh": branded picture of the daily shop / Night Market.
  ///
  /// In vi, this message translates to:
  /// **'Chia sẻ ảnh cửa hàng với bạn bè qua ứng dụng bạn chọn.'**
  String get storeShareSubtitle;

  /// StoreStrings.title —
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng'**
  String get storeTitle;

  /// Screen-reader label of the wallet pill.
  ///
  /// In vi, this message translates to:
  /// **'Số dư: {vp} VP, {kc} KC, {rp} RP'**
  String storeWalletSemantics(String vp, String kc, String rp);

  /// "2 trong wishlist" (daily summary chip).
  ///
  /// In vi, this message translates to:
  /// **'{n} trong wishlist'**
  String storeWishlistCount(int n);

  /// Screen and entry title: the daily shops of the active account that this device recorded.
  ///
  /// In vi, this message translates to:
  /// **'Lịch sử cửa hàng'**
  String get storeHistoryTitle;

  /// Subtitle: since when and how many daily shops were recorded ("Ghi trên máy này từ 24/09/2026 · 12 ngày").
  ///
  /// In vi, this message translates to:
  /// **'Ghi trên máy này từ {date} · {days, plural, other{{days} ngày}}'**
  String storeHistorySince(String date, int days);

  /// Store history with no recorded day yet. Riot keeps no past stores, so the history starts with the app.
  ///
  /// In vi, this message translates to:
  /// **'Chưa có ngày nào được ghi. ValHub lưu cửa hàng hằng ngày của bạn mỗi khi bạn mở app, chỉ trên máy này.'**
  String get storeHistoryEmpty;

  /// Section: the skins your daily shop offered most often in the recorded days.
  ///
  /// In vi, this message translates to:
  /// **'Hay xuất hiện nhất'**
  String get storeHistoryMostOffered;

  /// How many recorded daily shops offered the skin ("3 lần").
  ///
  /// In vi, this message translates to:
  /// **'{n, plural, other{{n} lần}}'**
  String storeHistoryTimes(int n);

  /// A recorded day had a Night Market with this many offers.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, other{Chợ Đêm · {count} ưu đãi}}'**
  String storeHistoryNightMarket(int count);

  /// Row under the daily shop that opens the store history.
  ///
  /// In vi, this message translates to:
  /// **'{days, plural, =0{Bắt đầu ghi từ hôm nay} other{{days} ngày đã ghi trên máy này}}'**
  String storeHistoryEntrySubtitle(int days);

  /// Wishlist daily store alert; left is a localized coarse duration, absent when expiry is unknown.
  ///
  /// In vi, this message translates to:
  /// **'{hasTime, select, yes {{skin} đang có trong cửa hàng của {account} — còn {left}.} other {{skin} đang có trong cửa hàng của {account}.}}'**
  String wishlistNotifDailyBody(
    String skin,
    String account,
    String hasTime,
    String left,
  );

  /// Night Market wishlist alert; discount/price branches require real available data, other hides unknown amounts.
  ///
  /// In vi, this message translates to:
  /// **'{mode, select, discount {{skin} giảm {percent}% còn {price} ({account}).} price {{skin} chỉ còn {price} ({account}).} other {{skin} đang có trong Chợ Đêm của {account}.}}'**
  String wishlistNotifNightMarketBody(
    String skin,
    String mode,
    String percent,
    String price,
    String account,
  );

  /// Wishlist bundle alert with a named or unnamed real bundle.
  ///
  /// In vi, this message translates to:
  /// **'{hasName, select, yes {{skin} nằm trong bundle {bundle} ({account}).} other {{skin} nằm trong một bundle đang bán ({account}).}}'**
  String wishlistNotifBundleBody(
    String skin,
    String hasName,
    String bundle,
    String account,
  );

  /// Summary of multiple wishlist hits; names is a localized list, more counts the remaining hits.
  ///
  /// In vi, this message translates to:
  /// **'{more, plural, =0 {{names} đang có trong cửa hàng của {account}.} other {{names} và {more} skin khác đang có trong cửa hàng của {account}.}}'**
  String wishlistNotifSummaryBody(String names, int more, String account);

  /// Explicit render-time message, preserving existing VI behavior.
  ///
  /// In vi, this message translates to:
  /// **'{name}, {price}{wished, select, yes{, đã có trong wishlist} other{}}'**
  String wishlistItemAccessibility(String name, String price, String wished);

  /// WishlistStrings.addSkins — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Thêm skin'**
  String get wishlistAddSkins;

  /// WishlistStrings.addToWishlist — S3B catalog
  ///
  /// In vi, this message translates to:
  /// **'Thêm vào wishlist'**
  String get wishlistAddToWishlist;

  /// WishlistStrings.allWeapons — search, filter, sort
  ///
  /// In vi, this message translates to:
  /// **'Tất cả vũ khí'**
  String get wishlistAllWeapons;

  /// WishlistStrings.browseCatalog — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả skin'**
  String get wishlistBrowseCatalog;

  /// WishlistStrings.catalogCount — S3B catalog
  ///
  /// In vi, this message translates to:
  /// **'{count} skin'**
  String wishlistCatalogCount(int count);

  /// WishlistStrings.catalogEmpty — S3B catalog
  ///
  /// In vi, this message translates to:
  /// **'Chưa tải được danh sách skin. Hãy làm mới để thử lại.'**
  String get wishlistCatalogEmpty;

  /// WishlistStrings.catalogEmptyTitle — S3B catalog
  ///
  /// In vi, this message translates to:
  /// **'Chưa có skin'**
  String get wishlistCatalogEmptyTitle;

  /// WishlistStrings.catalogInWishlist — S3B catalog
  ///
  /// In vi, this message translates to:
  /// **'{count} trong wishlist'**
  String wishlistCatalogInWishlist(String count);

  /// WishlistStrings.catalogSubtitle — titles
  ///
  /// In vi, this message translates to:
  /// **'Chạm ♡ để thêm skin vào wishlist'**
  String get wishlistCatalogSubtitle;

  /// WishlistStrings.catalogTitle — titles
  ///
  /// In vi, this message translates to:
  /// **'Tất cả skin'**
  String get wishlistCatalogTitle;

  /// WishlistStrings.chooseWeapon — search, filter, sort
  ///
  /// In vi, this message translates to:
  /// **'Chọn vũ khí'**
  String get wishlistChooseWeapon;

  /// WishlistStrings.clearFilters — search, filter, sort
  ///
  /// In vi, this message translates to:
  /// **'Bỏ lọc'**
  String get wishlistClearFilters;

  /// WishlistStrings.empty — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Wishlist trống. Chạm ♡ ở bất kỳ skin nào để thêm.'**
  String get wishlistEmpty;

  /// WishlistStrings.emptyTitle — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Chưa có skin nào'**
  String get wishlistEmptyTitle;

  /// "Kết thúc sau 11:54:37".
  ///
  /// In vi, this message translates to:
  /// **'Kết thúc sau {time}'**
  String wishlistEndsIn(String time);

  /// WishlistStrings.excludedRewards — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Không tính skin phần thưởng'**
  String get wishlistExcludedRewards;

  /// "Đang lọc: 3 skin · 5.325 VP" (VF §8.6 filteredValue).
  ///
  /// In vi, this message translates to:
  /// **'Đang lọc: {count} skin · {value}'**
  String wishlistFiltered(int count, String value);

  /// WishlistStrings.noMatch — search, filter, sort
  ///
  /// In vi, this message translates to:
  /// **'Không có skin phù hợp. Bỏ lọc để xem thêm.'**
  String get wishlistNoMatch;

  /// WishlistStrings.noMatchTitle — search, filter, sort
  ///
  /// In vi, this message translates to:
  /// **'Không tìm thấy skin'**
  String get wishlistNoMatchTitle;

  /// WishlistStrings.notifBundleTitle — notifications (VF §6.9)
  ///
  /// In vi, this message translates to:
  /// **'Bundle mới có skin trong wishlist'**
  String get wishlistNotifBundleTitle;

  /// WishlistStrings.notifDailyTitle — notifications (VF §6.9)
  ///
  /// In vi, this message translates to:
  /// **'Skin trong wishlist đã xuất hiện!'**
  String get wishlistNotifDailyTitle;

  /// WishlistStrings.notifNightMarketTitle — notifications (VF §6.9)
  ///
  /// In vi, this message translates to:
  /// **'Chợ Đêm có skin bạn thích!'**
  String get wishlistNotifNightMarketTitle;

  /// WishlistStrings.notifPermissionMissing — Notification toggle (VF §6.4 S3A, §8.5 notifWishlistBg).
  ///
  /// In vi, this message translates to:
  /// **'Ứng dụng chưa có quyền gửi thông báo.'**
  String get wishlistNotifPermissionMissing;

  /// Several hits for one account at once.
  ///
  /// In vi, this message translates to:
  /// **'{count} skin trong wishlist đang được bán!'**
  String wishlistNotifSummaryTitle(int count);

  /// WishlistStrings.notifToggle — Notification toggle (VF §6.4 S3A, §8.5 notifWishlistBg).
  ///
  /// In vi, this message translates to:
  /// **'Thông báo wishlist'**
  String get wishlistNotifToggle;

  /// WishlistStrings.notifToggleSubtitle — Notification toggle (VF §6.4 S3A, §8.5 notifWishlistBg).
  ///
  /// In vi, this message translates to:
  /// **'Cho tài khoản này, kể cả khi bạn không mở ứng dụng'**
  String get wishlistNotifToggleSubtitle;

  /// "Wishlist của Tên#TAG" (VF §8.5 wishlistOfAccount).
  ///
  /// In vi, this message translates to:
  /// **'Wishlist của {riotId}'**
  String wishlistOfAccount(String riotId);

  /// Banner above the list when wishlisted skins are on sale.
  ///
  /// In vi, this message translates to:
  /// **'{count, plural, =1{Một skin trong wishlist đang được bán!} other{{count} skin trong wishlist đang được bán!}}'**
  String wishlistOnSaleBanner(int count);

  /// WishlistStrings.onSaleBannerHint — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Chạm vào dòng được đánh dấu để xem ưu đãi.'**
  String get wishlistOnSaleBannerHint;

  /// WishlistStrings.openSettings — Notification toggle (VF §6.4 S3A, §8.5 notifWishlistBg).
  ///
  /// In vi, this message translates to:
  /// **'Mở cài đặt'**
  String get wishlistOpenSettings;

  /// WishlistStrings.owned — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Đã sở hữu'**
  String get wishlistOwned;

  /// WishlistStrings.removeAction — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Xóa khỏi wishlist'**
  String get wishlistRemoveAction;

  /// WishlistStrings.removeFromWishlist — S3B catalog
  ///
  /// In vi, this message translates to:
  /// **'Xóa khỏi wishlist'**
  String get wishlistRemoveFromWishlist;

  /// WishlistStrings.removed — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Đã xóa {name} khỏi wishlist'**
  String wishlistRemoved(String name);

  /// WishlistStrings.searchHint — search, filter, sort
  ///
  /// In vi, this message translates to:
  /// **'Tìm skin…'**
  String get wishlistSearchHint;

  /// "12 skin".
  ///
  /// In vi, this message translates to:
  /// **'{count} skin'**
  String wishlistSkinCount(int count);

  /// WishlistStrings.sortName — search, filter, sort
  ///
  /// In vi, this message translates to:
  /// **'Tên'**
  String get wishlistSortName;

  /// WishlistStrings.sortPrice — search, filter, sort
  ///
  /// In vi, this message translates to:
  /// **'Giá'**
  String get wishlistSortPrice;

  /// WishlistStrings.sortRarity — search, filter, sort
  ///
  /// In vi, this message translates to:
  /// **'Độ hiếm'**
  String get wishlistSortRarity;

  /// WishlistStrings.sortWeapon — search, filter, sort
  ///
  /// In vi, this message translates to:
  /// **'Vũ khí'**
  String get wishlistSortWeapon;

  /// WishlistStrings.title — titles
  ///
  /// In vi, this message translates to:
  /// **'Wishlist'**
  String get wishlistTitle;

  /// WishlistStrings.totalValue — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Tổng giá trị wishlist'**
  String get wishlistTotalValue;

  /// WishlistStrings.undo — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get wishlistUndo;

  /// WishlistStrings.viewInStore — S3A wishlist
  ///
  /// In vi, this message translates to:
  /// **'Xem trong cửa hàng'**
  String get wishlistViewInStore;

  /// WishlistStrings.weapon — search, filter, sort
  ///
  /// In vi, this message translates to:
  /// **'Vũ khí'**
  String get wishlistWeapon;

  /// Separator between the two live team scores. A game abbreviation.
  ///
  /// In vi, this message translates to:
  /// **'VS'**
  String get homeLiveScoreSeparator;

  /// Explicit render-time message, preserving existing VI behavior.
  ///
  /// In vi, this message translates to:
  /// **'{name}, {price}, {tier}{wished, select, yes{, trong wishlist} other{}}'**
  String homeOfferAccessibility(
    String name,
    String price,
    String tier,
    String wished,
  );

  /// Explicit render-time message, preserving existing VI behavior.
  ///
  /// In vi, this message translates to:
  /// **'{name}, {votes}{wished, select, yes{, trong wishlist} other{}}'**
  String homeTrendingAccessibility(String name, String votes, String wished);

  /// Explicit render-time message, preserving existing VI behavior.
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay {direction, select, gain{tăng} other{giảm}} {rr} RR, {wins} thắng, {losses} thua'**
  String homeTodayRankAccessibility(
    String direction,
    int rr,
    int wins,
    int losses,
  );

  /// Explicit render-time message, preserving existing VI behavior.
  ///
  /// In vi, this message translates to:
  /// **'{wins} thắng – {losses} thua{draws, plural, =0{} other{, {draws} hòa}}{unknown, plural, =0{} other{, {unknown} trận chưa rõ kết quả}}'**
  String homeResultSummary(int wins, int losses, int draws, int unknown);

  /// HomeStrings.allHiddenBody —
  ///
  /// In vi, this message translates to:
  /// **'Mở Tùy chỉnh Trang chủ để hiện lại.'**
  String get homeAllHiddenBody;

  /// HomeStrings.allHiddenTitle —
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã ẩn mọi thẻ'**
  String get homeAllHiddenTitle;

  /// HomeStrings.cardBattlePass — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Battle Pass'**
  String get homeCardBattlePass;

  /// HomeStrings.cardBattlePassDesc — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Cấp, XP cần mỗi ngày và nhiệm vụ tuần.'**
  String get homeCardBattlePassDesc;

  /// HomeStrings.cardCommunity — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng'**
  String get homeCardCommunity;

  /// HomeStrings.cardCommunityDesc — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Tìm đồng đội hợp rank và skin được cộng đồng yêu thích nhất.'**
  String get homeCardCommunityDesc;

  /// HomeStrings.cardFriends — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Bạn bè đang chơi'**
  String get homeCardFriends;

  /// HomeStrings.cardFriendsDesc — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Bạn bè đang trong trận hoặc đang tìm trận.'**
  String get homeCardFriendsDesc;

  /// "Đã ẩn "Cửa hàng hôm nay"".
  ///
  /// In vi, this message translates to:
  /// **'Đã ẩn \"{name}\"'**
  String homeCardHidden(String name);

  /// HomeStrings.cardLive — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Trận hiện tại'**
  String get homeCardLive;

  /// HomeStrings.cardLiveDesc — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Hiện khi bạn đang tìm trận, chọn đặc vụ hoặc trong trận.'**
  String get homeCardLiveDesc;

  /// HomeStrings.cardOtherAccounts — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản khác'**
  String get homeCardOtherAccounts;

  /// HomeStrings.cardOtherAccountsDesc — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái và wishlist của các tài khoản còn lại.'**
  String get homeCardOtherAccountsDesc;

  /// HomeStrings.cardRank — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Rank & phong độ'**
  String get homeCardRank;

  /// HomeStrings.cardRankDesc — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Rank, RR hôm nay, chuỗi trận và số trận lên rank.'**
  String get homeCardRankDesc;

  /// HomeStrings.cardServerStatus — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Trạng thái máy chủ'**
  String get homeCardServerStatus;

  /// HomeStrings.cardServerStatusDesc — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Chỉ hiện khi có bảo trì hoặc sự cố.'**
  String get homeCardServerStatusDesc;

  /// HomeStrings.cardStore — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng hôm nay'**
  String get homeCardStore;

  /// HomeStrings.cardStoreDesc — Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  ///
  /// In vi, this message translates to:
  /// **'Skin hằng ngày, wishlist và Chợ Đêm.'**
  String get homeCardStoreDesc;

  /// HomeStrings.customize —
  ///
  /// In vi, this message translates to:
  /// **'Tùy chỉnh Trang chủ'**
  String get homeCustomize;

  /// HomeStrings.customizeHint —
  ///
  /// In vi, this message translates to:
  /// **'Kéo để sắp xếp. Tắt để ẩn thẻ.'**
  String get homeCustomizeHint;

  /// HomeStrings.dot — Shared card bits
  ///
  /// In vi, this message translates to:
  /// **' · '**
  String get homeDot;

  /// Announced after a deep link scrolled to a card.
  ///
  /// In vi, this message translates to:
  /// **'Đã chuyển đến {name}'**
  String homeFocused(String name);

  /// HomeStrings.friendSemantics — Friends card
  ///
  /// In vi, this message translates to:
  /// **'{name}, {status}'**
  String homeFriendSemantics(String name, String status);

  /// HomeStrings.friendsConsentAllow — Friends card
  ///
  /// In vi, this message translates to:
  /// **'Bật'**
  String get homeFriendsConsentAllow;

  /// HomeStrings.friendsConsentBody — Friends card
  ///
  /// In vi, this message translates to:
  /// **'Để biết bạn bè nào đang chơi, ValHub sẽ kết nối trò chuyện Riot của tài khoản đang dùng mỗi khi bạn mở Trang chủ. Bạn bè sẽ thấy bạn đang trực tuyến. Bạn có thể tắt trong Tùy chỉnh Trang chủ.'**
  String get homeFriendsConsentBody;

  /// HomeStrings.friendsConsentDecline — Friends card
  ///
  /// In vi, this message translates to:
  /// **'Không, ẩn thẻ'**
  String get homeFriendsConsentDecline;

  /// HomeStrings.friendsConsentTitle — Friends card
  ///
  /// In vi, this message translates to:
  /// **'Xem bạn bè nào đang chơi?'**
  String get homeFriendsConsentTitle;

  /// HomeStrings.friendsMore — Friends card
  ///
  /// In vi, this message translates to:
  /// **'+{n}'**
  String homeFriendsMore(int n);

  /// HomeStrings.friendsPlaying — Friends card
  ///
  /// In vi, this message translates to:
  /// **'{n} bạn đang chơi'**
  String homeFriendsPlaying(int n);

  /// HomeStrings.friendsSeeAll — Friends card
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả'**
  String get homeFriendsSeeAll;

  /// HomeStrings.hideCard —
  ///
  /// In vi, this message translates to:
  /// **'Ẩn thẻ này'**
  String get homeHideCard;

  /// HomeStrings.leaderboard — Rank card
  ///
  /// In vi, this message translates to:
  /// **'Hạng {pos} trên bảng xếp hạng'**
  String homeLeaderboard(String pos);

  /// HomeStrings.lfgExpiresIn — Community card
  ///
  /// In vi, this message translates to:
  /// **'Còn {time}'**
  String homeLfgExpiresIn(String time);

  /// HomeStrings.lfgNeeds — Community card
  ///
  /// In vi, this message translates to:
  /// **'Cần {n} người'**
  String homeLfgNeeds(int n);

  /// HomeStrings.lfgRowSemantics — Community card
  ///
  /// In vi, this message translates to:
  /// **'{author}, {details}'**
  String homeLfgRowSemantics(String author, String details);

  /// HomeStrings.lfgTitle — Community card
  ///
  /// In vi, this message translates to:
  /// **'Tìm đồng đội hợp rank bạn'**
  String get homeLfgTitle;

  /// HomeStrings.liveAllyLabel — Live card
  ///
  /// In vi, this message translates to:
  /// **'Đội bạn'**
  String get homeLiveAllyLabel;

  /// HomeStrings.liveEnemyLabel — Live card
  ///
  /// In vi, this message translates to:
  /// **'Đội địch'**
  String get homeLiveEnemyLabel;

  /// Coarse, static value read by screen readers instead of a ticking timer.
  ///
  /// In vi, this message translates to:
  /// **'Đang tìm trận, đã chờ {coarse}'**
  String homeLiveQueueSemantics(String coarse);

  /// HomeStrings.liveScoreSemantics — Live card
  ///
  /// In vi, this message translates to:
  /// **'Đội bạn {ally}, đội địch {enemy}'**
  String homeLiveScoreSemantics(int ally, int enemy);

  /// HomeStrings.lossStreak — Rank card
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi {n} trận thua xếp hạng'**
  String homeLossStreak(int n);

  /// HomeStrings.matchesToRankUp — Rank card
  ///
  /// In vi, this message translates to:
  /// **'≈ {n} trận để lên {rank}'**
  String homeMatchesToRankUp(int n, String rank);

  /// Tooltip / label of the ⋯ button of a card.
  ///
  /// In vi, this message translates to:
  /// **'Tùy chọn cho {name}'**
  String homeMoreActions(String name);

  /// Body of the "sign in again" banner.
  ///
  /// In vi, this message translates to:
  /// **'Đăng nhập lại để cập nhật cửa hàng, rank và Battle Pass của {riotId}. Bạn vẫn có thể xem bản đã lưu trên thiết bị.'**
  String homeNeedsLoginBody(String riotId);

  /// HomeStrings.nightMarketBest — Store card
  ///
  /// In vi, this message translates to:
  /// **'{pct} · {name} · {price}'**
  String homeNightMarketBest(String pct, String name, String price);

  /// HomeStrings.nightMarketEndsIn — Store card
  ///
  /// In vi, this message translates to:
  /// **'Còn {time}'**
  String homeNightMarketEndsIn(String time);

  /// HomeStrings.nightMarketNew — Store card
  ///
  /// In vi, this message translates to:
  /// **'Mới'**
  String get homeNightMarketNew;

  /// HomeStrings.nightMarketTitle — Store card
  ///
  /// In vi, this message translates to:
  /// **'Chợ Đêm'**
  String get homeNightMarketTitle;

  /// HomeStrings.nightMarketWaiting — Store card
  ///
  /// In vi, this message translates to:
  /// **'{n} ưu đãi đang chờ bạn lật'**
  String homeNightMarketWaiting(int n);

  /// HomeStrings.noRankedToday — Rank card
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay chưa đấu xếp hạng'**
  String get homeNoRankedToday;

  /// HomeStrings.openLfg — Community card
  ///
  /// In vi, this message translates to:
  /// **'Xem tất cả tin tìm đồng đội'**
  String get homeOpenLfg;

  /// HomeStrings.openRanking — Community card
  ///
  /// In vi, this message translates to:
  /// **'Xem bảng xếp hạng skin'**
  String get homeOpenRanking;

  /// HomeStrings.otherAccountsTitle — Other accounts card
  ///
  /// In vi, this message translates to:
  /// **'Tài khoản khác ({n})'**
  String homeOtherAccountsTitle(int n);

  /// HomeStrings.otherMore — Other accounts card
  ///
  /// In vi, this message translates to:
  /// **'+{n} tài khoản'**
  String homeOtherMore(int n);

  /// HomeStrings.otherWishlistHit — Other accounts card
  ///
  /// In vi, this message translates to:
  /// **'Có skin trong wishlist'**
  String get homeOtherWishlistHit;

  /// HomeStrings.previousAct — Rank card
  ///
  /// In vi, this message translates to:
  /// **'Phần trước: {rank}'**
  String homePreviousAct(String rank);

  /// HomeStrings.quietBody —
  ///
  /// In vi, this message translates to:
  /// **'Kéo xuống để làm mới.'**
  String get homeQuietBody;

  /// HomeStrings.quietTitle —
  ///
  /// In vi, this message translates to:
  /// **'Chưa có gì mới'**
  String get homeQuietTitle;

  /// HomeStrings.rankToNext — Rank card
  ///
  /// In vi, this message translates to:
  /// **'Còn {rr} RR lên rank'**
  String homeRankToNext(int rr);

  /// HomeStrings.resetLayout —
  ///
  /// In vi, this message translates to:
  /// **'Khôi phục mặc định'**
  String get homeResetLayout;

  /// HomeStrings.rrOnDay — Rank card
  ///
  /// In vi, this message translates to:
  /// **'{day}: {value}'**
  String homeRrOnDay(String day, String value);

  /// HomeStrings.rrToday — Rank card
  ///
  /// In vi, this message translates to:
  /// **'Hôm nay {value}'**
  String homeRrToday(String value);

  /// HomeStrings.statusDetails — Server status card
  ///
  /// In vi, this message translates to:
  /// **'Chi tiết'**
  String get homeStatusDetails;

  /// HomeStrings.statusIncident — Server status card
  ///
  /// In vi, this message translates to:
  /// **'Sự cố máy chủ · {region}'**
  String homeStatusIncident(String region);

  /// HomeStrings.statusMaintenanceNow — Server status card
  ///
  /// In vi, this message translates to:
  /// **'Đang bảo trì · {region}'**
  String homeStatusMaintenanceNow(String region);

  /// HomeStrings.statusMaintenanceScheduled — Server status card
  ///
  /// In vi, this message translates to:
  /// **'Sắp bảo trì · {region}'**
  String homeStatusMaintenanceScheduled(String region);

  /// HomeStrings.statusMore — Server status card
  ///
  /// In vi, this message translates to:
  /// **'+{n} thông báo'**
  String homeStatusMore(int n);

  /// HomeStrings.storeRefreshing — Store card
  ///
  /// In vi, this message translates to:
  /// **'Đang làm mới…'**
  String get homeStoreRefreshing;

  /// HomeStrings.storeResetsIn — Store card
  ///
  /// In vi, this message translates to:
  /// **'Làm mới sau {time}'**
  String homeStoreResetsIn(String time);

  /// HomeStrings.storeTotal — Store card
  ///
  /// In vi, this message translates to:
  /// **'Tổng {vp}'**
  String homeStoreTotal(String vp);

  /// HomeStrings.storeWallet — Store card
  ///
  /// In vi, this message translates to:
  /// **'Ví {vp}'**
  String homeStoreWallet(String vp);

  /// "Ví 2.440 VP · đủ mua tối đa 1 skin": [n] skins bought together, the cheapest first (never a count of skins bought one by one).
  ///
  /// In vi, this message translates to:
  /// **'Ví {vp} · đủ mua tối đa {n} skin'**
  String homeStoreWalletCanBuy(String vp, int n);

  /// HomeStrings.storeWishlistHit — Store card
  ///
  /// In vi, this message translates to:
  /// **'Có skin trong wishlist!'**
  String get homeStoreWishlistHit;

  /// HomeStrings.storeWishlistHits — Store card
  ///
  /// In vi, this message translates to:
  /// **'{n} skin trong wishlist đang bán'**
  String homeStoreWishlistHits(int n);

  /// HomeStrings.title —
  ///
  /// In vi, this message translates to:
  /// **'Trang chủ'**
  String get homeTitle;

  /// HomeStrings.trendingTitle — Community card
  ///
  /// In vi, this message translates to:
  /// **'Skin được yêu thích toàn cầu'**
  String get homeTrendingTitle;

  /// HomeStrings.trendingVotes — Community card
  ///
  /// In vi, this message translates to:
  /// **'{n} lượt thích'**
  String homeTrendingVotes(int n);

  /// HomeStrings.undo —
  ///
  /// In vi, this message translates to:
  /// **'Hoàn tác'**
  String get homeUndo;

  /// The Home streak counts **ranked** matches only (Profile's form card counts the queue chip's matches), so the scope is in the text (PR-19).
  ///
  /// In vi, this message translates to:
  /// **'Chuỗi {n} trận thắng xếp hạng'**
  String homeWinStreak(int n);

  /// Home store card: the saved daily store already reset and the new one could not be loaded (expired sign-in, offline, maintenance). Replaces the skins and the countdown.
  ///
  /// In vi, this message translates to:
  /// **'Cửa hàng đã đổi. ValHub chưa tải được cửa hàng mới.'**
  String get homeStoreOutdated;

  /// Title of the single banner at the top of Home while the device has no network.
  ///
  /// In vi, this message translates to:
  /// **'Không có mạng'**
  String get homeOfflineTitle;

  /// Body of the Home offline banner: cards show their saved copies and refresh by themselves once the network is back.
  ///
  /// In vi, this message translates to:
  /// **'Đang hiển thị bản đã lưu trên máy. ValHub tự cập nhật khi có mạng lại.'**
  String get homeOfflineBody;

  /// Inside a Home card that has nothing saved yet while offline (the banner above explains the rest).
  ///
  /// In vi, this message translates to:
  /// **'Sẽ hiện khi có mạng.'**
  String get homeCardOffline;

  /// CommunityStrings.errorConsent — consent
  ///
  /// In vi, this message translates to:
  /// **'Hãy đồng ý chia sẻ Riot ID với Cộng đồng để tiếp tục.'**
  String get communityErrorConsent;

  /// CommunityStrings.errorForbidden — errors
  ///
  /// In vi, this message translates to:
  /// **'Bạn chưa thể thực hiện việc này. Hãy xem Tiêu chuẩn cộng đồng hoặc liên hệ ValHub.'**
  String get communityErrorForbidden;

  /// CommunityStrings.errorGeneric — errors
  ///
  /// In vi, this message translates to:
  /// **'Có gì đó trục trặc. Hãy thử lại.'**
  String get communityErrorGeneric;

  /// CommunityStrings.errorImageTooLarge — errors
  ///
  /// In vi, this message translates to:
  /// **'Ảnh quá lớn (tối đa 2 MB). Hãy chọn ảnh khác.'**
  String get communityErrorImageTooLarge;

  /// CommunityStrings.errorImageType — errors
  ///
  /// In vi, this message translates to:
  /// **'Hãy chọn ảnh JPEG, PNG hoặc WebP.'**
  String get communityErrorImageType;

  /// CommunityStrings.errorInvalid — errors
  ///
  /// In vi, this message translates to:
  /// **'Nội dung chưa được chấp nhận. Hãy kiểm tra lại rồi thử lại.'**
  String get communityErrorInvalid;

  /// CommunityStrings.errorNetwork — errors
  ///
  /// In vi, this message translates to:
  /// **'Không kết nối được Cộng đồng ValHub. Kiểm tra mạng rồi thử lại.'**
  String get communityErrorNetwork;

  /// CommunityStrings.errorNotFound — errors
  ///
  /// In vi, this message translates to:
  /// **'Nội dung này không còn tồn tại.'**
  String get communityErrorNotFound;

  /// CommunityStrings.errorPickImage — errors
  ///
  /// In vi, this message translates to:
  /// **'Chưa mở được thư viện ảnh. Hãy thử lại.'**
  String get communityErrorPickImage;

  /// CommunityStrings.errorRateLimited — errors
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng đang nhận quá nhiều yêu cầu. Hãy thử lại sau ít phút.'**
  String get communityErrorRateLimited;

  /// CommunityStrings.errorRateLimitedIn — errors
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng đang nhận quá nhiều yêu cầu. Hãy thử lại sau {duration}.'**
  String communityErrorRateLimitedIn(String duration);

  /// CommunityStrings.errorRiotRejected — errors
  ///
  /// In vi, this message translates to:
  /// **'Riot chưa xác minh được tài khoản của bạn. Hãy đăng nhập lại tài khoản Riot rồi thử lại.'**
  String get communityErrorRiotRejected;

  /// CommunityStrings.errorRiotUnavailable — errors
  ///
  /// In vi, this message translates to:
  /// **'Riot đang gặp sự cố. Hãy thử lại sau ít phút.'**
  String get communityErrorRiotUnavailable;

  /// CommunityStrings.errorRiotUnavailableIn — errors
  ///
  /// In vi, this message translates to:
  /// **'Riot đang gặp sự cố. Hãy thử lại sau {duration}.'**
  String communityErrorRiotUnavailableIn(String duration);

  /// CommunityStrings.errorServer — errors
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng ValHub đang gặp sự cố. Hãy thử lại sau ít phút.'**
  String get communityErrorServer;

  /// CommunityStrings.errorStorageFull — errors
  ///
  /// In vi, this message translates to:
  /// **'Kho ảnh của Cộng đồng đã đầy. Bạn vẫn đăng bài được, nhưng chưa thể kèm ảnh. Hãy thử lại sau.'**
  String get communityErrorStorageFull;

  /// CommunityStrings.errorTimeout — errors
  ///
  /// In vi, this message translates to:
  /// **'Cộng đồng ValHub phản hồi quá lâu. Hãy thử lại.'**
  String get communityErrorTimeout;

  /// CommunityStrings.errorTitle — errors
  ///
  /// In vi, this message translates to:
  /// **'Chưa hoàn tất'**
  String get communityErrorTitle;

  /// CommunityStrings.errorUnauthorized — errors
  ///
  /// In vi, this message translates to:
  /// **'Kết nối Cộng đồng đã hết hạn. Hãy thử lại.'**
  String get communityErrorUnauthorized;

  /// Community error (server reason quota_exceeded): the player has used up their image storage.
  ///
  /// In vi, this message translates to:
  /// **'Bạn đã dùng hết dung lượng ảnh. Hãy xóa bớt bài viết có ảnh rồi thử lại.'**
  String get communityErrorImageQuota;

  /// SMOKE/TEST ONLY (W0 foundation). Proves gen-l10n output and the delegate list. Never shown to users; W1 replaces this file with the real template.
  ///
  /// In vi, this message translates to:
  /// **'Kiểm tra sinh mã'**
  String get smokePlain;

  /// SMOKE/TEST ONLY (W0 foundation). A message with a String placeholder. Never shown to users.
  ///
  /// In vi, this message translates to:
  /// **'Xin chào, {name}!'**
  String smokeGreeting(String name);

  /// SMOKE/TEST ONLY (W0 foundation). A plural message with an int placeholder. Never shown to users.
  ///
  /// In vi, this message translates to:
  /// **'{n, plural, other{{n} mục}}'**
  String smokeCount(int n);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'id',
    'it',
    'ja',
    'ko',
    'pl',
    'pt',
    'ru',
    'th',
    'tr',
    'vi',
    'zh',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when language+script codes are specified.
  switch (locale.languageCode) {
    case 'zh':
      {
        switch (locale.scriptCode) {
          case 'Hant':
            return AppLocalizationsZhHant();
        }
        break;
      }
  }

  // Lookup logic when language+country codes are specified.
  switch (locale.languageCode) {
    case 'es':
      {
        switch (locale.countryCode) {
          case 'MX':
            return AppLocalizationsEsMx();
        }
        break;
      }
  }

  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'id':
      return AppLocalizationsId();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pl':
      return AppLocalizationsPl();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'th':
      return AppLocalizationsTh();
    case 'tr':
      return AppLocalizationsTr();
    case 'vi':
      return AppLocalizationsVi();
    case 'zh':
      return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
