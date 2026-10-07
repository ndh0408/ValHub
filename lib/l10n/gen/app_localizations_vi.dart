// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get commonListSeparator => ', ';

  @override
  String get commonPriceSourceLabel => 'Xem nguồn bảng giá';

  @override
  String get commonErrorApi =>
      'Riot đang gặp trục trặc. Hãy thử lại sau ít phút.';

  @override
  String get commonAppName => 'ValHub';

  @override
  String get commonBack => 'Quay lại';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonClearFilters => 'Bỏ lọc';

  @override
  String get commonClearSearch => 'Xóa tìm kiếm';

  @override
  String get commonClose => 'Đóng';

  @override
  String get commonConfirm => 'Xác nhận';

  @override
  String get commonCopied => 'Đã sao chép';

  @override
  String get commonCopy => 'Sao chép';

  @override
  String get commonDaily => 'hằng ngày';

  @override
  String get commonDash => '–';

  @override
  String commonDays(int n) {
    return '$n ngày';
  }

  @override
  String commonDaysAgo(int n) {
    return '$n ngày trước';
  }

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonDone => 'Xong';

  @override
  String get commonEmptyGeneric => 'Chưa có gì ở đây.';

  @override
  String get commonErrorContentUnavailable =>
      'Không tải được thông tin skin, đặc vụ và bản đồ. Kiểm tra mạng rồi thử lại.';

  @override
  String get commonErrorGeneric => 'Có gì đó trục trặc. Hãy thử lại.';

  @override
  String get commonErrorMaintenance =>
      'Máy chủ VALORANT đang bảo trì. Hãy quay lại sau.';

  @override
  String get commonErrorNeedsLogin =>
      'Đăng nhập Riot của bạn đã hết hạn. Hãy đăng nhập lại để tiếp tục.';

  @override
  String get commonErrorNeedsLoginTitle => 'Cần đăng nhập lại';

  @override
  String get commonErrorNetwork =>
      'Không kết nối được mạng. Kiểm tra Wi-Fi hoặc dữ liệu di động rồi thử lại.';

  @override
  String get commonErrorNoAccount => 'Bạn chưa đăng nhập tài khoản nào.';

  @override
  String get commonErrorNotFound => 'Không tìm thấy nội dung này.';

  @override
  String get commonErrorTimeout =>
      'Riot phản hồi quá lâu. Kiểm tra kết nối rồi thử lại.';

  @override
  String get commonErrorTransient => 'Riot đang bận. Hãy thử lại sau ít phút.';

  @override
  String commonErrorTransientRetryIn(String duration) {
    return 'Riot đang bận. Hãy thử lại sau $duration.';
  }

  @override
  String get commonErrorUnsupportedRegion =>
      'Chưa xác định được khu vực Riot. Hãy chọn khu vực trong Cài đặt.';

  @override
  String get commonEstimatePrefix => '≈';

  @override
  String get commonFilter => 'Lọc';

  @override
  String get commonGoHome => 'Về Trang chủ';

  @override
  String commonHours(int n) {
    return '$n giờ';
  }

  @override
  String commonHoursAgo(int n) {
    return '$n giờ trước';
  }

  @override
  String get commonIncidentTitle => 'Sự cố máy chủ';

  @override
  String get commonJustNow => 'vừa xong';

  @override
  String get commonLoadMore => 'Tải thêm';

  @override
  String get commonLoading => 'Đang tải…';

  @override
  String get commonMaintenanceTitle => 'Bảo trì máy chủ';

  @override
  String commonMinutes(int n) {
    return '$n phút';
  }

  @override
  String commonMinutesAgo(int n) {
    return '$n phút trước';
  }

  @override
  String get commonNoData => 'Chưa có gì để xem';

  @override
  String commonOfflineCached(String time) {
    return 'Không có mạng — đang hiển thị bản đã lưu ($time).';
  }

  @override
  String get commonOk => 'OK';

  @override
  String get commonOpenSettings => 'Mở cài đặt';

  @override
  String get commonPageNotFound => 'Không tìm thấy màn hình này.';

  @override
  String commonPriceBestPack(String vp, String price) {
    return 'Gói có lợi nhất: $vp = $price';
  }

  @override
  String get commonPriceEditOwn => 'Sửa giá bạn đã nhập';

  @override
  String get commonPriceEnterOwn => 'Nhập giá gói VP của bạn';

  @override
  String get commonPriceEstimateBody =>
      'Số tiền “≈ …” cạnh giá VP là ước tính, quy đổi theo gói VP có lợi nhất. Bạn trả bằng VP trong game; số tiền thật tùy gói nạp, kênh thanh toán, thuế và khuyến mãi lúc bạn mua.';

  @override
  String get commonPriceEstimateTitle => 'Giá quy đổi ước tính';

  @override
  String get commonPriceEstimateTooltip =>
      'Giá ước tính — chạm để xem cách tính';

  @override
  String get commonPriceHidden => 'Đã ẩn giá quy đổi. Bật lại trong Cài đặt.';

  @override
  String get commonPriceHide => 'Ẩn giá quy đổi';

  @override
  String get commonPriceOpenSource => 'Mở trang nguồn';

  @override
  String get commonPriceOverrideBody =>
      'Nhập số tiền bạn thực trả cho một gói VP (xem trong cửa hàng của game hoặc hóa đơn). ValHub dùng giá này để ước tính giá quy đổi cho mọi món đồ; giá chỉ lưu trên thiết bị này.';

  @override
  String get commonPriceOverrideCurrency => 'Mã tiền tệ';

  @override
  String get commonPriceOverrideCurrencyHint => 'Ví dụ: VND, USD, EUR, JPY';

  @override
  String commonPriceOverrideExample(String vp, String price) {
    return 'Ví dụ ước tính: $vp ≈ $price';
  }

  @override
  String get commonPriceOverrideInvalidCurrency =>
      'Nhập mã tiền tệ gồm 3 chữ cái, ví dụ VND hoặc USD.';

  @override
  String get commonPriceOverrideInvalidNumber => 'Nhập một số lớn hơn 0.';

  @override
  String get commonPriceOverridePrice => 'Giá gói';

  @override
  String get commonPriceOverrideRemove => 'Xóa giá đã nhập';

  @override
  String get commonPriceOverrideRemoved => 'Đã xóa giá bạn nhập.';

  @override
  String get commonPriceOverrideSave => 'Lưu giá';

  @override
  String get commonPriceOverrideSaved => 'Đã lưu giá gói VP của bạn.';

  @override
  String get commonPriceOverrideTitle => 'Giá gói VP của bạn';

  @override
  String get commonPriceOverrideVp => 'Số VP của gói';

  @override
  String get commonPricePacksTitle => 'Các gói VP';

  @override
  String commonPriceSourceOfficial(String country) {
    return 'Theo bảng giá gói VP ở khu vực $country';
  }

  @override
  String get commonPriceSourceUser => 'Theo giá gói VP do bạn nhập';

  @override
  String get commonPriceUnavailable =>
      'Chưa có bảng giá đã xác minh cho khu vực của bạn. Nhập giá của một gói VP bạn từng mua để xem giá quy đổi ước tính.';

  @override
  String commonPriceUpdated(String date) {
    return 'Cập nhật bảng giá: $date';
  }

  @override
  String get commonPullToRefresh => 'Kéo để làm mới';

  @override
  String get commonRefresh => 'Làm mới';

  @override
  String get commonRetry => 'Thử lại';

  @override
  String get commonRiotDisclaimer =>
      'ValHub không được Riot Games xác nhận và không phản ánh quan điểm của Riot Games hay bất kỳ ai tham gia sản xuất hoặc quản lý các sản phẩm của Riot Games. Riot Games và mọi tài sản liên quan là thương hiệu hoặc thương hiệu đã đăng ký của Riot Games, Inc.';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonSearch => 'Tìm kiếm…';

  @override
  String commonSeconds(int n) {
    return '$n giây';
  }

  @override
  String get commonSeeAll => 'Xem tất cả';

  @override
  String get commonShare => 'Chia sẻ';

  @override
  String get commonSignInAgain => 'Đăng nhập lại';

  @override
  String get commonSort => 'Sắp xếp';

  @override
  String commonSortBy(String option) {
    return 'Sắp xếp: $option';
  }

  @override
  String get commonSortName => 'Tên A–Z';

  @override
  String get commonSortNewest => 'Mới nhất';

  @override
  String get commonSortPriceHigh => 'Giá giảm dần';

  @override
  String get commonSortPriceLow => 'Giá tăng dần';

  @override
  String get commonSortRarity => 'Độ hiếm';

  @override
  String get commonSortWeapon => 'Vũ khí';

  @override
  String get commonTabBattlePass => 'Battle Pass';

  @override
  String get commonTabCollection => 'Bộ sưu tập';

  @override
  String get commonTabCommunity => 'Cộng đồng';

  @override
  String get commonTabHome => 'Trang chủ';

  @override
  String get commonTabProfile => 'Hồ sơ';

  @override
  String get commonTabSettings => 'Cài đặt';

  @override
  String get commonTabStore => 'Cửa hàng';

  @override
  String get commonTagline => 'Trợ thủ VALORANT của bạn';

  @override
  String get commonToday => 'Hôm nay';

  @override
  String get commonTodayLower => 'hôm nay';

  @override
  String get commonTomorrow => 'ngày mai';

  @override
  String get commonUnknownItem => 'Vật phẩm chưa rõ tên';

  @override
  String commonUpdatedAt(String time) {
    return 'Cập nhật lúc $time';
  }

  @override
  String commonWallTime(String time, String day) {
    return '$time $day';
  }

  @override
  String get commonWeekdaysItem0 => 'Thứ Hai';

  @override
  String get commonWeekdaysItem1 => 'Thứ Ba';

  @override
  String get commonWeekdaysItem2 => 'Thứ Tư';

  @override
  String get commonWeekdaysItem3 => 'Thứ Năm';

  @override
  String get commonWeekdaysItem4 => 'Thứ Sáu';

  @override
  String get commonWeekdaysItem5 => 'Thứ Bảy';

  @override
  String get commonWeekdaysItem6 => 'Chủ Nhật';

  @override
  String get commonYesterday => 'hôm qua';

  @override
  String get commonYesterdayTitle => 'Hôm qua';

  @override
  String commonSavedCopyNeedsLogin(String time) {
    return 'Đăng nhập Riot đã hết hạn — đang hiển thị bản đã lưu ($time).';
  }

  @override
  String get contentCategoryHeavy => 'Vũ khí hạng nặng';

  @override
  String get contentCategoryMelee => 'Cận chiến';

  @override
  String get contentCategoryRifle => 'Súng trường';

  @override
  String get contentCategoryShotgun => 'Shotgun';

  @override
  String get contentCategorySidearm => 'Súng phụ';

  @override
  String get contentCategorySmg => 'SMG';

  @override
  String get contentCategorySniper => 'Súng bắn tỉa';

  @override
  String get contentCurrencyAgentTokens => 'Huy hiệu đặc vụ';

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
  String get contentDefaultSkin => 'Mặc định';

  @override
  String get contentItemAgent => 'Đặc vụ';

  @override
  String get contentItemBuddy => 'Phụ kiện súng';

  @override
  String get contentItemCard => 'Thẻ người chơi';

  @override
  String get contentItemChroma => 'Biến thể';

  @override
  String get contentItemContract => 'Hợp đồng';

  @override
  String get contentItemCurrency => 'Tiền tệ';

  @override
  String get contentItemFlex => 'Flex';

  @override
  String get contentItemLanguageEn => 'Tiếng Anh';

  @override
  String get contentItemLanguageTitle => 'Tên vật phẩm';

  @override
  String get contentItemLanguageVi => 'Tiếng Việt';

  @override
  String get contentItemLevelBorder => 'Khung cấp';

  @override
  String get contentItemSkin => 'Skin';

  @override
  String get contentItemSpray => 'Hình phun sơn';

  @override
  String get contentItemTitle => 'Danh hiệu';

  @override
  String contentLevel(int n) {
    return 'Cấp $n';
  }

  @override
  String get contentLevelBase => 'Cơ bản';

  @override
  String get contentLevelItemLabelsVFX => 'Hiệu ứng hình ảnh';

  @override
  String get contentLevelItemLabelsAnimation => 'Hoạt ảnh';

  @override
  String get contentLevelItemLabelsFinisher => 'Đòn kết liễu';

  @override
  String get contentLevelItemLabelsKillCounter => 'Bộ đếm hạ gục';

  @override
  String get contentLevelItemLabelsSoundEffects => 'Hiệu ứng âm thanh';

  @override
  String get contentLevelItemLabelsTransformation => 'Biến hình';

  @override
  String get contentLevelItemLabelsKillBanner => 'Biểu ngữ hạ gục';

  @override
  String get contentLevelItemLabelsKillEffect => 'Hiệu ứng hạ gục';

  @override
  String get contentLevelItemLabelsInspectAndKill =>
      'Hiệu ứng ngắm súng & hạ gục';

  @override
  String get contentLevelItemLabelsVoiceover => 'Lồng tiếng';

  @override
  String get contentLevelItemLabelsSongShuffle => 'Đổi bài nhạc';

  @override
  String get contentLevelItemLabelsRandomizer => 'Ngẫu nhiên hóa';

  @override
  String get contentLevelItemLabelsAttackerDefenderSwap =>
      'Đổi theo phe công/thủ';

  @override
  String get contentLevelItemLabelsTopFrag => 'Hiệu ứng top frag';

  @override
  String get contentLevelItemLabelsHeartbeatAndMapSensor =>
      'Cảm biến nhịp tim & bản đồ';

  @override
  String get contentLevelItemLabelsFishAnimation => 'Hoạt ảnh cá';

  @override
  String get contentLimitedEdition => 'Phiên bản giới hạn';

  @override
  String get contentNoSpray => 'Không có';

  @override
  String get contentNoTitle => 'Không có danh hiệu';

  @override
  String get contentNotForSale => 'Không bán';

  @override
  String get contentQueueNamesCompetitive => 'Thi đấu xếp hạng';

  @override
  String get contentQueueNamesUnrated => 'Đấu thường';

  @override
  String get contentQueueNamesSwiftplay => 'Siêu Tốc';

  @override
  String get contentQueueNamesSpikerush => 'Đặt Spike Nhanh';

  @override
  String get contentQueueNamesDeathmatch => 'Sinh Tử';

  @override
  String get contentQueueNamesHurm => 'Sinh Tử Đội';

  @override
  String get contentQueueNamesGgteam => 'Tăng Tiến';

  @override
  String get contentQueueNamesOnefa => 'Nhân bản';

  @override
  String get contentQueueNamesPremier => 'Premier';

  @override
  String get contentQueueNamesCustom => 'Chơi tự do';

  @override
  String get contentQueueNames => 'Chơi tự do';

  @override
  String get contentQueueNamesDodgeball => 'Knockout';

  @override
  String get contentQueueNamesFortcollins => 'Retake';

  @override
  String get contentQueueNamesSkirmish2v2 => 'Skirmish: 2v2';

  @override
  String get contentQueueNamesSkirmishascension1v1 => 'Skirmish: Thăng Hoa 1v1';

  @override
  String get contentQueueNamesSkirmishascension2v2 => 'Skirmish: Thăng Hoa 2v2';

  @override
  String get contentQueueNamesValaram => 'Tất Cả Ngẫu Nhiên Một Khu Đặt Spike';

  @override
  String get contentQueueNamesAbilitydraftarena => 'Gauntlet: Glitched';

  @override
  String get contentQueueNamesSnowball => 'Trận Chiến Cầu Tuyết';

  @override
  String get contentQueueNamesNewmap => 'Summit';

  @override
  String get contentQueueShortNamesCompetitive => 'Xếp hạng';

  @override
  String get contentQueueShortNamesValaram => 'Ngẫu nhiên 1 khu';

  @override
  String get contentRewardSourceAgent => 'Hợp đồng đặc vụ';

  @override
  String get contentRewardSourceBattlePass => 'Phần thưởng Battle Pass';

  @override
  String get contentRewardSourceEvent => 'Vé sự kiện';

  @override
  String get contentRoleNamesDbe8757e9e924ed4B39f9dfc589691d4 => 'Đối đầu';

  @override
  String get contentRoleNames1b47567f8f7b444bAae3B0c634622d10 => 'Khởi tranh';

  @override
  String get contentRoleNames4ee40330Ecdd4f2f98a8Eb1243428373 => 'Kiểm soát';

  @override
  String get contentRoleNames5fc02f9940914486A53198459a3e95e9 => 'Hộ vệ';

  @override
  String get contentTierDeluxe => 'Sang Chảnh';

  @override
  String get contentTierExclusive => 'Độc Quyền';

  @override
  String contentTierFull(String shortName) {
    return 'Phiên bản $shortName';
  }

  @override
  String get contentTierPremium => 'Cao Cấp';

  @override
  String get contentTierSelect => 'Tuyển Chọn';

  @override
  String get contentTierUltra => 'Siêu Cấp';

  @override
  String get contentUnranked => 'Chưa xếp hạng';

  @override
  String get accountRegionUnknown => 'Chưa rõ máy chủ';

  @override
  String accountRiotCountry(String country) {
    return 'Quốc gia tài khoản Riot: $country';
  }

  @override
  String get accountRiotCountryUnknown =>
      'Quốc gia tài khoản Riot: Chưa xác định';

  @override
  String accountAccountCount(int count, int max) {
    return '$count/$max tài khoản';
  }

  @override
  String accountAccountsHeader(int count, int max) {
    return 'TÀI KHOẢN ($count/$max)';
  }

  @override
  String get accountActive => 'Đang dùng';

  @override
  String accountAddAccount(int count, int max) {
    return 'Thêm tài khoản ($count/$max)';
  }

  @override
  String get accountClearLocalData => 'Xóa dữ liệu cục bộ';

  @override
  String get accountClearLocalDataConfirm =>
      'Xóa lịch sử, bộ trang bị đã lưu và dữ liệu của tài khoản đã đăng xuất trên thiết bị này?';

  @override
  String get accountClearRrHistory => 'Xóa lịch sử RR';

  @override
  String get accountClearRrHistoryConfirm =>
      'Xóa lịch sử RR của tài khoản đang chọn trên thiết bị này?';

  @override
  String get accountCopyPassword => 'Sao chép mật khẩu';

  @override
  String get accountCopyUsername => 'Sao chép tên đăng nhập';

  @override
  String get accountDeleteLoginNote => 'Xóa thông tin';

  @override
  String get accountDeleteLoginNoteConfirm =>
      'Xóa tên đăng nhập và mật khẩu đã lưu của tài khoản này?';

  @override
  String get accountHidePassword => 'Ẩn mật khẩu';

  @override
  String get accountKeepLocalData => 'Giữ dữ liệu cục bộ';

  @override
  String get accountKeepLocalDataHint =>
      'Giữ wishlist, bộ trang bị và lịch sử trên thiết bị này';

  @override
  String accountLevelShort(int level) {
    return 'Cấp $level';
  }

  @override
  String get accountLinkAccountMissing =>
      'Tài khoản trong thông báo đã đăng xuất. Hãy đăng nhập lại rồi mở thông báo.';

  @override
  String get accountLocalDataCleared => 'Đã xóa dữ liệu cục bộ';

  @override
  String get accountLoginNote => 'Thông tin đăng nhập';

  @override
  String get accountLoginNoteDeleted => 'Đã xóa thông tin đăng nhập';

  @override
  String get accountLoginNoteEmpty => 'Chưa lưu thông tin đăng nhập';

  @override
  String get accountLoginNoteHint =>
      'Chỉ lưu trên thiết bị này, được khóa an toàn. Dùng để xem lại hoặc điền nhanh khi bạn đăng nhập lại.';

  @override
  String get accountLoginNoteLocked => 'Mở khóa thông tin đăng nhập';

  @override
  String get accountLoginNotePassword => 'Mật khẩu';

  @override
  String get accountLoginNoteSaved => 'Đã lưu thông tin đăng nhập';

  @override
  String get accountLoginNoteUsername => 'Tên đăng nhập Riot';

  @override
  String get accountManageHint =>
      'Xóa tài khoản hoặc sửa thông tin đăng nhập trong Cài đặt.';

  @override
  String accountMaxAccounts(int max) {
    return 'Đã đạt tối đa $max tài khoản.';
  }

  @override
  String get accountNeedsLogin => 'Cần đăng nhập lại';

  @override
  String accountOnlineCount(int count) {
    return '$count đang trực tuyến';
  }

  @override
  String get accountPlatformPc => 'PC';

  @override
  String get accountPlatformPlayStation => 'PlayStation';

  @override
  String get accountPlatformXbox => 'Xbox';

  @override
  String get accountQuickFill => 'Điền tài khoản đã lưu';

  @override
  String get accountQuickFillDone => 'Đã điền xong. Hãy bấm Đăng nhập.';

  @override
  String get accountQuickFillNotReady =>
      'Trang đăng nhập chưa tải xong. Đợi một chút rồi thử lại.';

  @override
  String get accountQuickFillSubtitle =>
      'Chọn tài khoản để điền vào trang đăng nhập Riot';

  @override
  String get accountQuickFillTitle => 'Điền tài khoản đã lưu';

  @override
  String get accountRegionAp => 'Châu Á - Thái Bình Dương';

  @override
  String get accountRegionBr => 'Brazil';

  @override
  String get accountRegionEu => 'Châu Âu';

  @override
  String get accountRegionKr => 'Hàn Quốc';

  @override
  String get accountRegionLatam => 'Mỹ Latinh';

  @override
  String get accountRegionNa => 'Bắc Mỹ';

  @override
  String get accountRemoveAccount => 'Xóa tài khoản';

  @override
  String accountRemoveAccountConfirm(String account) {
    return 'Xóa $account khỏi thiết bị này? Bạn có thể chọn giữ dữ liệu đã lưu.';
  }

  @override
  String get accountRrHistoryCleared => 'Đã xóa lịch sử RR';

  @override
  String get accountShowPassword => 'Hiện mật khẩu';

  @override
  String get accountSignOutAll => 'Đăng xuất tất cả tài khoản';

  @override
  String get accountSignOutAllConfirm =>
      'Đăng xuất và xóa mọi tài khoản khỏi thiết bị này? Bạn có thể chọn giữ dữ liệu đã lưu.';

  @override
  String get accountStatusAgentSelect => 'Đang chọn đặc vụ';

  @override
  String get accountStatusInMatch => 'Đang đấu';

  @override
  String get accountStatusOffline => 'Ngoại tuyến';

  @override
  String get accountStatusOnline => 'Trực tuyến';

  @override
  String get accountStatusUnknown => 'Chưa rõ trạng thái';

  @override
  String get accountSwitchFailed => 'Chưa chuyển được tài khoản. Hãy thử lại.';

  @override
  String accountSwitchTo(String account) {
    return 'Chuyển sang $account';
  }

  @override
  String get accountSwitcherSubtitle => 'Chạm để chuyển tài khoản';

  @override
  String get accountSwitcherTitle => 'Tài khoản';

  @override
  String accountSwitcherTitleCount(int count, int max) {
    return 'Tài khoản ($count/$max)';
  }

  @override
  String get accountUnknownPlayer => 'Người chơi';

  @override
  String get accountUnlockLoginNote =>
      'Xác thực để mở thông tin đăng nhập Riot';

  @override
  String get authAccountAlreadyAdded => 'Tài khoản này đã được thêm';

  @override
  String get authAddAsNew => 'Thêm tài khoản mới';

  @override
  String get authDifferentAccountBody =>
      'Bạn vừa đăng nhập một tài khoản khác với tài khoản cần đăng nhập lại. Thêm tài khoản này như một tài khoản mới?';

  @override
  String get authDifferentAccountTitle => 'Tài khoản khác';

  @override
  String get authLoadingAccount => 'Đang tải tài khoản…';

  @override
  String get authLoginCancelledByRiot =>
      'Riot đã từ chối lần đăng nhập này. Hãy thử lại.';

  @override
  String get authLoginFailed => 'Không thể hoàn tất đăng nhập';

  @override
  String get authLoginFailedBody =>
      'Riot chưa xác nhận đăng nhập của bạn. Hãy thử lại.';

  @override
  String get authLoginTitle => 'Đăng nhập Riot';

  @override
  String get authMissingCookies =>
      'Không lưu được đăng nhập trên thiết bị này, nên bạn sẽ phải đăng nhập lại khi hết hạn.';

  @override
  String get authOfficialHost => 'Trang chính thức · auth.riotgames.com';

  @override
  String get authOpenedInBrowser => 'Đã mở liên kết trong trình duyệt.';

  @override
  String get authPageLoadFailed =>
      'Không tải được trang đăng nhập của Riot. Kiểm tra mạng rồi thử lại.';

  @override
  String get authPreparing => 'Đang chuẩn bị trang đăng nhập…';

  @override
  String get authReloginDone => 'Đã đăng nhập lại';

  @override
  String get authRememberMeHint =>
      'Hãy bật \"Duy trì đăng nhập\" để không phải đăng nhập lại.';

  @override
  String get authSignInCta => 'Đăng nhập bằng tài khoản Riot';

  @override
  String get authSignInNote =>
      'Bạn đăng nhập trên trang chính thức của Riot. ValHub chỉ lưu mật khẩu khi bạn tự chọn lưu thông tin đăng nhập; dữ liệu đăng nhập và thông tin đã lưu chỉ nằm trên thiết bị của bạn.';

  @override
  String get authSocialLoginHint =>
      'Nếu đăng nhập bằng Google hoặc Facebook không được, hãy dùng tên đăng nhập Riot.';

  @override
  String get authStateMismatch =>
      'Lần đăng nhập này không hợp lệ. Hãy đăng nhập lại từ đầu.';

  @override
  String get notificationSessionExpiredBody =>
      'Đăng nhập lại để tiếp tục nhận thông báo wishlist.';

  @override
  String get notificationBackgroundTimingHint =>
      'Chế độ tiết kiệm pin của thiết bị có thể làm thông báo đến muộn.';

  @override
  String get notificationChannelAccountDescription =>
      'Nhắc khi một tài khoản cần đăng nhập lại';

  @override
  String get notificationChannelAccountName => 'Tài khoản';

  @override
  String get notificationChannelBattlePassDescription =>
      'Nhắc tiến độ và ngày kết thúc Battle Pass';

  @override
  String get notificationChannelBattlePassName => 'Battle Pass';

  @override
  String get notificationChannelCommunityDescription =>
      'Báo hoạt động cộng đồng khi bạn mở ValHub';

  @override
  String get notificationChannelCommunityName => 'Cộng đồng';

  @override
  String get notificationChannelLfgDescription =>
      'Báo người chơi tham gia tổ đội khi bạn mở ValHub';

  @override
  String get notificationChannelLfgName => 'Tổ đội';

  @override
  String get notificationChannelNightMarketDescription => 'Báo khi Chợ Đêm mở';

  @override
  String get notificationChannelNightMarketName => 'Chợ Đêm';

  @override
  String get notificationChannelRankDescription =>
      'Báo thay đổi xếp hạng khi bạn cập nhật hồ sơ';

  @override
  String get notificationChannelRankName => 'Xếp hạng';

  @override
  String get notificationChannelStoreResetDescription =>
      'Nhắc khi cửa hàng hằng ngày làm mới';

  @override
  String get notificationChannelStoreResetName => 'Làm mới cửa hàng';

  @override
  String get notificationChannelWishlistDescription =>
      'Báo khi skin trong wishlist xuất hiện trong cửa hàng';

  @override
  String get notificationChannelWishlistName => 'Wishlist';

  @override
  String get notificationLfgJoinedTitle => 'Có người chơi tham gia tổ đội';

  @override
  String get notificationLocalOnlyHint =>
      'Chỉ báo trên thiết bị này khi ValHub cập nhật dữ liệu';

  @override
  String notificationNightMarketOpenBody(String cards, String account) {
    return 'Lật $cards thẻ ưu đãi của $account ngay.';
  }

  @override
  String get notificationNightMarketOpenTitle => 'Chợ Đêm đã mở!';

  @override
  String get notificationPassEndingBody =>
      'Battle Pass còn khoảng một ngày. Mở ValHub để xem tiến độ mới nhất.';

  @override
  String get notificationPassEndingTitle => 'Battle Pass sắp kết thúc';

  @override
  String notificationPassProgressBody(int level) {
    return 'Bạn đã đạt cấp $level trong Battle Pass hiện tại.';
  }

  @override
  String get notificationPassProgressTitle => 'Tiến độ Battle Pass';

  @override
  String get notificationPrivateAccount => 'tài khoản của bạn';

  @override
  String notificationRankChangedBody(String rank) {
    return 'Xếp hạng hiện tại: $rank. Dữ liệu vừa cập nhật từ Riot.';
  }

  @override
  String get notificationRankChangedTitle => 'Xếp hạng đã thay đổi';

  @override
  String get notificationResetTimingUnknown =>
      'Mở cửa hàng để cập nhật giờ làm mới trên thiết bị của bạn.';

  @override
  String get notificationSessionExpiredTitle => 'Cần đăng nhập lại';

  @override
  String get notificationStoreResetBody =>
      'Skin mới đang chờ bạn trong cửa hàng.';

  @override
  String get competitiveDivisionIron => 'Sắt';

  @override
  String get competitiveDivisionBronze => 'Đồng';

  @override
  String get competitiveDivisionSilver => 'Bạc';

  @override
  String get competitiveDivisionGold => 'Vàng';

  @override
  String get competitiveDivisionPlatinum => 'Bạch Kim';

  @override
  String get competitiveDivisionDiamond => 'Kim Cương';

  @override
  String get competitiveDivisionAscendant => 'Thượng Nhân';

  @override
  String get competitiveDivisionImmortal => 'Bất Tử';

  @override
  String competitiveRankTierCaption(String division, int number) {
    return '$division $number';
  }

  @override
  String get competitiveDivisionRadiant => 'Radiant';

  @override
  String get competitiveRankUnknown => 'Chưa rõ xếp hạng';

  @override
  String get competitiveAttack => 'Tấn công';

  @override
  String get competitiveCannotEstimate => 'Không ước tính được';

  @override
  String get competitiveDefeat => 'Thua';

  @override
  String get competitiveDefense => 'Phòng thủ';

  @override
  String get competitiveDraw => 'Hòa';

  @override
  String get competitiveIncognitoPlayer => 'Người chơi ẩn danh';

  @override
  String get competitiveMatchPending => 'Riot đang xử lý trận đấu…';

  @override
  String get competitiveNoValue => '–';

  @override
  String competitivePlacementsLeft(int n) {
    return 'Còn $n trận phân hạng';
  }

  @override
  String get competitiveRoundDefuse => 'Gỡ Spike';

  @override
  String get competitiveRoundDetonate => 'Spike phát nổ';

  @override
  String get competitiveRoundElimination => 'Hạ toàn đội';

  @override
  String get competitiveRoundSurrendered => 'Đầu hàng';

  @override
  String get competitiveRoundTimeExpired => 'Hết giờ';

  @override
  String get competitiveUnknownPlayer => 'Người chơi';

  @override
  String get competitiveVictory => 'Thắng';

  @override
  String economyAvailableNow(String place) {
    return 'Đang có trong $place!';
  }

  @override
  String get economyCollectionValue => 'Giá trị bộ sưu tập';

  @override
  String get economyExcludedRewards => 'Không tính skin phần thưởng';

  @override
  String economyPlaceBundle(String name) {
    return 'bundle $name';
  }

  @override
  String get economyPlaceBundleGeneric => 'bundle';

  @override
  String get economyPlaceDaily => 'cửa hàng hằng ngày';

  @override
  String get economyPlaceNightMarket => 'Chợ Đêm';

  @override
  String get economyPriceEstimated => 'Giá ước tính theo phiên bản';

  @override
  String get economyPriceFromOffers => 'Giá từ bảng giá Riot';

  @override
  String get economyPriceFromStore => 'Giá đã thấy trong cửa hàng';

  @override
  String get economyPriceFromTable => 'Giá niêm yết';

  @override
  String get economyPriceUnknown => 'Chưa rõ giá';

  @override
  String get economyValueHasEstimates => 'Có giá ước tính (≈)';

  @override
  String get economyWishlistValue => 'Tổng giá trị wishlist';

  @override
  String loadoutDefaultPresetName(int n) {
    return 'Bộ trang bị $n';
  }

  @override
  String get loadoutInvalidChange =>
      'Thay đổi này không áp dụng được cho trang bị hiện tại.';

  @override
  String get loadoutNotPersisted =>
      'Riot chưa lưu thay đổi của bạn nên trang bị vẫn như cũ. Hãy thử lại.';

  @override
  String get loadoutSaveFailed => 'Không thể lưu trang bị';

  @override
  String get battlePassActEnded => 'Phần này đã kết thúc';

  @override
  String battlePassActEndsIn(String time) {
    return 'Phần kết thúc sau $time';
  }

  @override
  String battlePassActEndsInDays(int days) {
    return 'Phần kết thúc sau $days ngày';
  }

  @override
  String get battlePassAllMissionsDone => 'Đã hoàn thành tất cả nhiệm vụ';

  @override
  String get battlePassAllWeeklyDone =>
      'Đã hoàn thành tất cả nhiệm vụ hằng tuần';

  @override
  String get battlePassBonusBadge => '×2';

  @override
  String battlePassBonusPending(int n) {
    return 'Thưởng gấp đôi đang chờ: $n';
  }

  @override
  String battlePassChapter(int n) {
    return 'Chương $n';
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
  String get battlePassCheckpoint => 'Cột mốc';

  @override
  String get battlePassCheckpointHint =>
      'Thắng vòng để tiến tới cột mốc (Sinh Tử không tính).';

  @override
  String battlePassCheckpointLabel(int index, int charges, int needed) {
    return 'Cột mốc $index: $charges/$needed';
  }

  @override
  String get battlePassCheckpointRewards => 'Mỗi cột mốc: +XP, +KC';

  @override
  String battlePassCheckpointsDone(int done, int total) {
    return 'Đã đạt $done/$total cột mốc';
  }

  @override
  String get battlePassCurrentChapter => 'Hiện tại';

  @override
  String get battlePassDailyAllDone => 'Đã hoàn thành tất cả cột mốc hôm nay';

  @override
  String get battlePassDailyCaption => 'Phần thưởng ngày';

  @override
  String battlePassDailyCaptionReset(String reset) {
    return 'Phần thưởng ngày · $reset';
  }

  @override
  String get battlePassDailyExpired =>
      'Cột mốc của ngày trước đã hết hạn. Hãy vào game hoặc làm mới tại đây.';

  @override
  String get battlePassDailyMissions => 'Nhiệm vụ hằng ngày';

  @override
  String get battlePassDailyNotReady =>
      'Cột mốc hôm nay chưa sẵn sàng. Hãy vào game hoặc làm mới tại đây.';

  @override
  String get battlePassDailyPlayToStart =>
      'Cột mốc hôm nay chưa sẵn sàng. Hãy vào game để bắt đầu ngày mới.';

  @override
  String battlePassDaysLeft(int days) {
    return 'Còn $days ngày';
  }

  @override
  String get battlePassDot => ' · ';

  @override
  String battlePassEndsAtWall(String wall) {
    return 'Kết thúc lúc $wall';
  }

  @override
  String get battlePassEpilogue => 'Phần mở rộng';

  @override
  String get battlePassEstimateNote =>
      'Ước tính khoảng 4.000 XP mỗi trận, chưa tính nhiệm vụ.';

  @override
  String battlePassEventEndsIn(String time) {
    return 'Kết thúc sau $time';
  }

  @override
  String get battlePassEventPass => 'Vé sự kiện';

  @override
  String get battlePassFilterAll => 'Tất cả';

  @override
  String get battlePassFilterLocked => 'Còn khóa';

  @override
  String get battlePassFilterUnlocked => 'Đã mở khóa';

  @override
  String get battlePassFree => 'Miễn phí';

  @override
  String get battlePassFreeTrack => 'Phần thưởng miễn phí';

  @override
  String battlePassLevelOf(String level, String count) {
    return 'Cấp $level / $count';
  }

  @override
  String battlePassLevelShort(int n) {
    return 'Cấp $n';
  }

  @override
  String battlePassMatchesEstimate(int n, String queue) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '≈ $nString trận $queue';
  }

  @override
  String get battlePassMissionDone => 'Đã hoàn thành';

  @override
  String battlePassMissionProgress(String progress, String target) {
    return '$progress / $target';
  }

  @override
  String battlePassMissionsCompleted(int done, int total) {
    return '$done/$total hoàn thành';
  }

  @override
  String get battlePassMissionsProgressLabel => 'Tiến độ nhiệm vụ tuần';

  @override
  String battlePassNewMissionsAtWall(String wall) {
    return 'Nhiệm vụ mới lúc $wall';
  }

  @override
  String battlePassNewMissionsIn(String time) {
    return 'Nhiệm vụ mới sau $time';
  }

  @override
  String battlePassNextCheckpoint(int charges, int needed) {
    return 'Cột mốc tiếp theo: $charges/$needed';
  }

  @override
  String battlePassNextLevelCaption(String level) {
    return 'Lên cấp $level';
  }

  @override
  String get battlePassNextReward => 'Tiếp theo';

  @override
  String get battlePassNoBattlePass =>
      'Chưa có thông tin Battle Pass của Phần hiện tại. Hãy thử lại sau.';

  @override
  String get battlePassNoRewards =>
      'Chưa có phần thưởng nào cho Battle Pass này.';

  @override
  String get battlePassNoRewardsInFilter =>
      'Không có phần thưởng nào trong mục này.';

  @override
  String get battlePassNoRewardsTitle => 'Chưa có phần thưởng';

  @override
  String get battlePassNoWeeklyMissions => 'Hiện chưa có nhiệm vụ hằng tuần.';

  @override
  String get battlePassPassComplete => 'Đã hoàn thành Battle Pass';

  @override
  String get battlePassPremium => 'Premium';

  @override
  String get battlePassPremiumHint =>
      'Bạn chưa mua Premium: chỉ nhận được phần thưởng Miễn phí. Mua Premium trong game để mở khóa các cấp đã đạt.';

  @override
  String get battlePassRenewButton => 'Làm mới cột mốc';

  @override
  String get battlePassRenewDone => 'Đã làm mới cột mốc hằng ngày.';

  @override
  String get battlePassRenewFailed =>
      'Không thể làm mới cột mốc. Hãy thử lại sau.';

  @override
  String battlePassResetsAtWall(String wall) {
    return 'Làm mới lúc $wall';
  }

  @override
  String battlePassResetsIn(String time) {
    return 'Làm mới sau $time';
  }

  @override
  String get battlePassRewardLevelLabel => 'Cấp';

  @override
  String get battlePassRewardLocked => 'Chưa mở khóa';

  @override
  String get battlePassRewardNeedsPremium => 'Cần Premium';

  @override
  String get battlePassRewardStatusLabel => 'Trạng thái';

  @override
  String get battlePassRewardTrackLabel => 'Loại phần thưởng';

  @override
  String get battlePassRewardTypeLabel => 'Loại';

  @override
  String get battlePassRewardUnlocked => 'Đã mở khóa';

  @override
  String get battlePassRewardsTitle => 'Phần thưởng';

  @override
  String get battlePassShowAllRewards => 'Xem tất cả';

  @override
  String get battlePassTitle => 'Battle Pass';

  @override
  String get battlePassTotalXpCaption => 'Tổng XP';

  @override
  String get battlePassUnknownMission => 'Nhiệm vụ mới (chưa có mô tả)';

  @override
  String get battlePassUnknownReward => 'Phần thưởng';

  @override
  String battlePassUnlockedCount(String unlocked, String total) {
    return '$unlocked/$total đã mở khóa';
  }

  @override
  String get battlePassUnratedFallback => 'Đấu thường';

  @override
  String get battlePassViewAllRewards => 'Xem tất cả phần thưởng';

  @override
  String get battlePassWeeklyMissions => 'Nhiệm vụ hằng tuần';

  @override
  String battlePassWeeklyXpLeft(String xp) {
    return 'Nhiệm vụ tuần còn +$xp XP';
  }

  @override
  String battlePassXpOf(String xp, String total) {
    return '$xp / $total XP';
  }

  @override
  String battlePassXpPerDay(String xp) {
    return '$xp XP / ngày';
  }

  @override
  String get battlePassXpPerDayCaption => 'Cần mỗi ngày để kịp hoàn thành';

  @override
  String battlePassXpReward(String xp) {
    return '+$xp XP';
  }

  @override
  String battlePassXpToFinish(String xp) {
    return 'Còn cần $xp XP';
  }

  @override
  String collectionSaveFailedWith(String detail) {
    return 'Không thể lưu trang bị. $detail';
  }

  @override
  String collectionBrowseDescription(String type) {
    String _temp0 = intl.Intl.selectLogic(type, {
      'skin': 'Mọi skin bạn sở hữu, tính giá trị theo giá cửa hàng',
      'buddy': 'Phụ kiện súng đã sở hữu và số bản sao',
      'spray': 'Hình phun sơn bạn có thể gắn vào tổ hợp cảm xúc',
      'card': 'Thẻ người chơi đã mở khóa, chạm để xem và trang bị',
      'title': 'Danh hiệu bạn có thể hiển thị dưới tên',
      'flex': 'Flex đã sở hữu',
      'other': 'Duyệt bộ sưu tập',
    });
    return '$_temp0';
  }

  @override
  String collectionSlotCaption(String position) {
    return 'Ô $position';
  }

  @override
  String get collectionApplyPreset => 'Áp dụng';

  @override
  String get collectionApplyPresetBody =>
      'Skin, phụ kiện súng, tổ hợp cảm xúc, thẻ và danh hiệu đang dùng sẽ được thay bằng bộ này.';

  @override
  String collectionApplyPresetTitle(String name) {
    return 'Áp dụng “$name”?';
  }

  @override
  String get collectionBannerTitlePrefix => 'Danh hiệu: ';

  @override
  String get collectionBrowseBuddies => 'Phụ kiện súng';

  @override
  String get collectionBrowseCards => 'Thẻ người chơi';

  @override
  String get collectionBrowseEmpty => 'Bạn chưa có vật phẩm nào ở mục này.';

  @override
  String get collectionBrowseEmptyTitle => 'Chưa có vật phẩm';

  @override
  String get collectionBrowseFlex => 'Flex';

  @override
  String get collectionBrowseSkins => 'Skin';

  @override
  String get collectionBrowseSprays => 'Hình phun sơn';

  @override
  String get collectionBrowseTitle => 'Duyệt bộ sưu tập';

  @override
  String get collectionBrowseTitles => 'Danh hiệu';

  @override
  String collectionBuddyAvailable(int free, int total) {
    return 'Còn $free/$total';
  }

  @override
  String collectionBuddyFor(String weapon) {
    return 'Cho $weapon';
  }

  @override
  String get collectionBuddyPickerTitle => 'Chọn phụ kiện súng';

  @override
  String get collectionBuddyRemoved => 'Đã gỡ phụ kiện';

  @override
  String get collectionBuddySlot => 'Phụ kiện súng';

  @override
  String get collectionBuddyUnavailable =>
      'Chưa gắn được phụ kiện này. Hãy làm mới hoặc chọn phụ kiện khác.';

  @override
  String get collectionCachedLoadout =>
      'Đang hiển thị trang bị đã lưu. Kéo để làm mới trước khi thay đổi.';

  @override
  String collectionCardsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString thẻ đã sở hữu';
  }

  @override
  String get collectionChangeBuddy => 'Đổi';

  @override
  String collectionChromaCount(int owned, int total) {
    return '$owned/$total biến thể';
  }

  @override
  String get collectionClearFilters => 'Bỏ lọc';

  @override
  String get collectionClearSearch => 'Xóa tìm kiếm';

  @override
  String get collectionClearTiers => 'Bỏ lọc phiên bản';

  @override
  String get collectionCollectionValue => 'Giá trị bộ sưu tập';

  @override
  String collectionCopies(int n) {
    return '×$n';
  }

  @override
  String get collectionDefaultSkin => 'Mặc định';

  @override
  String get collectionDeletePreset => 'Xóa';

  @override
  String get collectionEmptySlot => 'Trống';

  @override
  String get collectionEquip => 'Trang bị';

  @override
  String get collectionEquipped => 'Đang dùng';

  @override
  String get collectionEquippedCard => 'Thẻ đang dùng';

  @override
  String collectionEquippedCardLabel(String name) {
    return 'Thẻ đang dùng: $name';
  }

  @override
  String collectionEquippedItem(String name) {
    return 'Đã trang bị $name';
  }

  @override
  String collectionEquippedLine(String skin) {
    return 'Đang dùng: $skin';
  }

  @override
  String get collectionExcludedRewards => 'Không tính skin phần thưởng';

  @override
  String get collectionExpressionsHint =>
      'Chạm vào một ô để chọn hình phun sơn hoặc Flex.';

  @override
  String get collectionExpressionsSlots => 'Các ô trên vòng';

  @override
  String get collectionExpressionsTitle => 'Tổ hợp cảm xúc';

  @override
  String get collectionFilterTiers => 'Phiên bản';

  @override
  String get collectionHideAccountLevel => 'Ẩn cấp tài khoản';

  @override
  String get collectionHideAccountLevelHint =>
      'Người chơi khác sẽ không thấy cấp tài khoản của bạn.';

  @override
  String get collectionIncognito => 'Chế độ ẩn danh';

  @override
  String get collectionIncognitoHint =>
      'Ẩn tên của bạn với người chơi không cùng tổ đội trong trận.';

  @override
  String collectionItemsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString món';
  }

  @override
  String get collectionLevelBorderAuto => 'Tự động theo cấp';

  @override
  String get collectionLevelBorderEmpty =>
      'Chưa có khung cấp nào cho cấp của bạn.';

  @override
  String collectionLevelBorderFrom(int level) {
    return 'Từ cấp $level';
  }

  @override
  String collectionLevelBorderSubtitle(int level) {
    return 'Tài khoản cấp $level';
  }

  @override
  String get collectionLevelBorderTitle => 'Chọn khung cấp';

  @override
  String collectionLevelCount(int owned, int total) {
    return 'Cấp $owned/$total';
  }

  @override
  String collectionLevelLabel(int n, String type) {
    return 'Cấp $n · $type';
  }

  @override
  String get collectionLevels => 'Cấp độ';

  @override
  String collectionLevelsUnlocked(int owned, int total) {
    return 'Đã mở $owned/$total cấp';
  }

  @override
  String get collectionLobbyBanner => 'Ảnh ở sảnh chờ';

  @override
  String get collectionLocked => 'Chưa mở khóa';

  @override
  String get collectionMeleeNoBuddy =>
      'Vũ khí cận chiến không gắn được phụ kiện.';

  @override
  String get collectionMove => 'Chuyển';

  @override
  String collectionMoveBuddyBody(String buddy, String from, String to) {
    return '$buddy đang gắn trên $from. Chuyển sang $to?';
  }

  @override
  String get collectionMoveBuddyTitle => 'Chuyển phụ kiện?';

  @override
  String get collectionNoBuddies => 'Bạn chưa có phụ kiện súng nào.';

  @override
  String get collectionNoBuddy => 'Chưa gắn phụ kiện';

  @override
  String get collectionNoFlex => 'Bạn chưa có Flex nào.';

  @override
  String get collectionNoResults => 'Không tìm thấy kết quả phù hợp.';

  @override
  String get collectionNoResultsTitle => 'Không tìm thấy';

  @override
  String get collectionNoSkinsForWeapon =>
      'Bạn chưa có skin nào cho vũ khí này.';

  @override
  String get collectionNoSprays => 'Bạn chưa có hình phun sơn nào.';

  @override
  String get collectionNoTitle => 'Không có danh hiệu';

  @override
  String get collectionOtherWeapons => 'Khác';

  @override
  String collectionOwnedForWeapon(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skin đã sở hữu',
      zero: 'Chưa có skin nào',
    );
    return '$_temp0';
  }

  @override
  String collectionOwnedSkinsStat(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString skin đã sở hữu';
  }

  @override
  String get collectionPlayLevelVideo => 'Xem video cấp này';

  @override
  String get collectionPlayVideo => 'Xem video';

  @override
  String get collectionPlayerCardSubtitle =>
      'Hiện ở sảnh chờ, bảng điểm và khi bạn hạ gục đối thủ.';

  @override
  String get collectionPlayerCardTitle => 'Đổi thẻ người chơi';

  @override
  String get collectionPlayerTitleSubtitle =>
      'Hiện dưới tên của bạn ở sảnh chờ và trong trận.';

  @override
  String get collectionPlayerTitleTitle => 'Đổi danh hiệu';

  @override
  String get collectionPresetActions => 'Tùy chọn';

  @override
  String collectionPresetApplied(String name) {
    return 'Đã áp dụng “$name”';
  }

  @override
  String collectionPresetCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n bộ',
      zero: 'Chưa có',
    );
    return '$_temp0';
  }

  @override
  String collectionPresetDeleted(String name) {
    return 'Đã xóa “$name”';
  }

  @override
  String get collectionPresetNameHint => 'Ví dụ: Leo rank';

  @override
  String get collectionPresetNameTitle => 'Tên bộ trang bị';

  @override
  String collectionPresetSaved(String name) {
    return 'Đã lưu “$name”';
  }

  @override
  String collectionPresetSavedAt(String date) {
    return 'Lưu ngày $date';
  }

  @override
  String collectionPresetSkipped(int n) {
    return 'Bỏ qua $n vật phẩm bạn không còn sở hữu.';
  }

  @override
  String get collectionPresetsEmpty =>
      'Lưu trang bị đang dùng để đổi nhanh giữa các bộ skin, thẻ và tổ hợp cảm xúc sau này.';

  @override
  String get collectionPresetsEmptyTitle => 'Chưa có bộ trang bị';

  @override
  String get collectionPresetsFull =>
      'Đã đạt tối đa 50 bộ trang bị. Hãy xóa bớt để lưu thêm.';

  @override
  String get collectionPresetsNote =>
      'Bộ trang bị chỉ được lưu trên thiết bị này, cho tài khoản đang chọn.';

  @override
  String get collectionPresetsTitle => 'Bộ trang bị đã lưu';

  @override
  String get collectionPreview => 'Xem trước';

  @override
  String get collectionPreviewing => 'Đang xem';

  @override
  String get collectionRemoveBuddy => 'Gỡ phụ kiện';

  @override
  String get collectionRenamePreset => 'Đổi tên';

  @override
  String get collectionRowCard => 'Thẻ người chơi';

  @override
  String get collectionRowExpressions => 'Tổ hợp cảm xúc';

  @override
  String get collectionRowLevelBorder => 'Khung cấp';

  @override
  String get collectionRowPresets => 'Bộ trang bị đã lưu';

  @override
  String get collectionRowTitle => 'Danh hiệu';

  @override
  String get collectionRowWeapons => 'Trang bị vũ khí';

  @override
  String get collectionRowWishlist => 'Wishlist';

  @override
  String get collectionSaveFailed => 'Không thể lưu trang bị';

  @override
  String get collectionSavePreset => 'Lưu trang bị hiện tại';

  @override
  String get collectionSaving => 'Đang lưu…';

  @override
  String get collectionSearchBuddies => 'Tìm phụ kiện…';

  @override
  String get collectionSearchCards => 'Tìm thẻ người chơi…';

  @override
  String get collectionSearchFlex => 'Tìm Flex…';

  @override
  String get collectionSearchItems => 'Tìm kiếm…';

  @override
  String get collectionSearchSkins => 'Tìm skin…';

  @override
  String get collectionSearchSprays => 'Tìm hình phun sơn…';

  @override
  String get collectionSearchTitles => 'Tìm danh hiệu…';

  @override
  String get collectionSearchWeapons => 'Tìm vũ khí, skin hoặc phụ kiện…';

  @override
  String get collectionSectionBrowse => 'Duyệt bộ sưu tập';

  @override
  String get collectionSectionIdentity => 'Hiển thị với người chơi khác';

  @override
  String get collectionSectionLoadout => 'Trang bị';

  @override
  String get collectionSkinCustomizeTitle => 'Tùy chỉnh skin';

  @override
  String get collectionSkinNotFound => 'Không tìm thấy skin này.';

  @override
  String get collectionSkinNotOwned => 'Bạn chưa sở hữu skin này.';

  @override
  String get collectionSlotNamesItem0 => 'Trên';

  @override
  String get collectionSlotNamesItem1 => 'Phải';

  @override
  String get collectionSlotNamesItem2 => 'Dưới';

  @override
  String get collectionSlotNamesItem3 => 'Trái';

  @override
  String get collectionSortLabel => 'Sắp xếp';

  @override
  String get collectionSortName => 'Tên';

  @override
  String get collectionSortPrice => 'Giá';

  @override
  String get collectionSortRarity => 'Độ hiếm';

  @override
  String get collectionSortWeapon => 'Vũ khí';

  @override
  String collectionSummaryFiltered(int count, String value) {
    return 'Đang lọc: $count skin · $value';
  }

  @override
  String collectionSummaryFilteredItems(int count, int total) {
    return 'Đang lọc: $count/$total vật phẩm';
  }

  @override
  String collectionSummaryItems(int count) {
    return '$count vật phẩm';
  }

  @override
  String collectionSummarySkins(int count, String value) {
    return '$count skin · $value';
  }

  @override
  String get collectionTabFlex => 'Flex';

  @override
  String get collectionTabSprays => 'Hình phun sơn';

  @override
  String get collectionTapToChangeCard => 'Chạm để đổi thẻ';

  @override
  String get collectionTitle => 'Bộ sưu tập';

  @override
  String collectionTitlesCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString danh hiệu đã sở hữu';
  }

  @override
  String get collectionUndo => 'Hoàn tác';

  @override
  String get collectionUnknownCard => 'Thẻ chưa rõ tên';

  @override
  String get collectionValueAtStorePrices => 'Tính theo giá cửa hàng';

  @override
  String get collectionValueHasEstimates => 'Có giá ước tính (≈)';

  @override
  String collectionValueRewardCount(int n) {
    return '$n skin phần thưởng không được tính';
  }

  @override
  String get collectionValueSeeSkins => 'Xem các skin';

  @override
  String collectionValueSkinCount(int n) {
    return 'Tính trên $n skin';
  }

  @override
  String get collectionVariants => 'Biến thể';

  @override
  String collectionWeaponLoadoutSubtitle(int custom, int total) {
    return '$custom/$total vũ khí đang dùng skin';
  }

  @override
  String get collectionWeaponLoadoutTitle => 'Trang bị vũ khí';

  @override
  String get collectionWeaponNotFound => 'Không tìm thấy vũ khí này.';

  @override
  String get collectionWeaponSkinsTitle => 'Chọn skin';

  @override
  String collectionWishlistCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n skin',
      zero: 'Trống',
    );
    return '$_temp0';
  }

  @override
  String get communityModerationContentInappropriate =>
      'Chưa đăng được vì có từ ngữ không phù hợp. Hãy sửa nội dung rồi thử lại.';

  @override
  String get communityModerationContentScam =>
      'Cộng đồng không cho phép quảng cáo mua bán tài khoản, cày thuê hay để lại số điện thoại. Hãy bỏ những nội dung này rồi thử lại.';

  @override
  String get communityModerationContentTooComplex =>
      'Nội dung có quá nhiều ký tự rời rạc. Hãy viết gọn hơn rồi thử lại.';

  @override
  String get communityModerationAccountBanned =>
      'Tài khoản này đã bị khóa quyền dùng Cộng đồng. Nếu cho rằng có nhầm lẫn, hãy liên hệ ValHub trong Giới thiệu & pháp lý.';

  @override
  String get communityModerationAccountRestricted =>
      'Tài khoản này đang bị hạn chế đăng bài, bình luận, tìm đồng đội và bình chọn. Hãy thử lại sau hoặc liên hệ ValHub trong Giới thiệu & pháp lý.';

  @override
  String communityModeName(String mode) {
    String _temp0 = intl.Intl.selectLogic(mode, {
      'competitive': 'Xếp hạng',
      'unrated': 'Đấu thường',
      'swiftplay': 'Siêu Tốc',
      'spikerush': 'Đặt Spike Nhanh',
      'deathmatch': 'Sinh Tử',
      'teamdeathmatch': 'Sinh Tử Đội',
      'premier': 'Premier',
      'custom': 'Chơi tự do',
      'other': 'Khác',
    });
    return '$_temp0';
  }

  @override
  String communityRegionName(String region) {
    String _temp0 = intl.Intl.selectLogic(region, {
      'ap': 'Châu Á - Thái Bình Dương',
      'na': 'Bắc Mỹ',
      'eu': 'Châu Âu',
      'kr': 'Hàn Quốc',
      'latam': 'Mỹ Latinh',
      'br': 'Brazil',
      'other': 'Chưa rõ máy chủ',
    });
    return '$_temp0';
  }

  @override
  String get communityRankingEmptyTitle =>
      'Chưa có skin trong bảng xếp hạng này';

  @override
  String get communityRankingEmptyVotes =>
      'Chưa có lượt yêu thích phù hợp với phạm vi và bộ lọc đang chọn.';

  @override
  String get communityRankingEmptyRatings =>
      'Chưa có đánh giá sao phù hợp với phạm vi và bộ lọc đang chọn.';

  @override
  String get communityRankingEmptyReviews =>
      'Chưa có nhận xét phù hợp với phạm vi và bộ lọc đang chọn.';

  @override
  String get communityRankingExplore => 'Tìm skin để xem và đánh giá';

  @override
  String get communityRankingExploreHint =>
      'Tìm theo tên skin hoặc vũ khí. Chỉ đánh giá thực tế của cộng đồng mới xuất hiện trong bảng xếp hạng.';

  @override
  String get communityRankingClear => 'Bỏ lọc vũ khí và thời gian';

  @override
  String get communityRankingPeriod => 'Thời gian';

  @override
  String get communityRankingSort => 'Xếp hạng theo';

  @override
  String get communityRankingWeapon => 'Vũ khí';

  @override
  String get communityRankingNoSearch =>
      'Không tìm thấy skin phù hợp. Thử tên khác hoặc bỏ lọc vũ khí.';

  @override
  String get communityRankingCatalogUnavailable =>
      'Chưa tải được danh mục skin. Đóng bảng và thử lại sau khi dữ liệu được đồng bộ.';

  @override
  String get communityConsentExitAccount =>
      'Không đồng ý · Đăng xuất tài khoản này';

  @override
  String get communityRankingGlobalAllTime => 'Toàn cầu · Từ trước tới giờ';

  @override
  String get communityRankingCatalogTitle => 'Tất cả skin';

  @override
  String get communityReviewOwnershipRequired =>
      'Tài khoản phải sở hữu skin này để đánh giá. Bạn vẫn có thể xem đánh giá và bình luận của cộng đồng.';

  @override
  String get communityReviewOwnershipUnavailable =>
      'Chưa xác minh được quyền sở hữu skin. Hãy tải lại Bộ sưu tập hoặc thử lại khi có mạng.';

  @override
  String get communityReviewLegacyOwnership =>
      'Đánh giá cũ · Chưa xác minh sở hữu';

  @override
  String get communityReviewVerifiedOwner => 'Đã xác minh sở hữu khi đánh giá';

  @override
  String get communitySkinDiscussionHint =>
      'Mọi người đều có thể bình luận. Chỉ chủ sở hữu skin được chấm sao và viết đánh giá.';

  @override
  String get communityAddPhotos => 'Thêm ảnh';

  @override
  String get communityAgentsPicked => 'Đặc vụ đã chọn';

  @override
  String get communityAllModes => 'Tất cả';

  @override
  String get communityAllWeapons => 'Tất cả vũ khí';

  @override
  String get communityAnonymousBanner => 'Đang xem ẩn danh';

  @override
  String get communityAnyLanguage => 'Mọi ngôn ngữ';

  @override
  String get communityAnyRank => 'Mọi rank';

  @override
  String get communityAnyRole => 'Mọi vai trò';

  @override
  String get communityApply => 'Áp dụng';

  @override
  String get communityAutoRefresh => 'Tự làm mới mỗi 20 giây';

  @override
  String get communityBackToMyCountry => 'Về nước bạn';

  @override
  String get communityBlockAuthor => 'Chặn trên thiết bị';

  @override
  String communityCharCount(String n, String max) {
    return '$n/$max';
  }

  @override
  String get communityClearFilter => 'Bỏ chọn';

  @override
  String get communityCodeAuto =>
      'Để trống: ValHub tự tạo mã từ tổ đội trong game khi bạn đăng tin.';

  @override
  String get communityCodeAutoFailed =>
      'Không tạo được mã tổ đội. Hãy mở VALORANT hoặc nhập mã thủ công.';

  @override
  String get communityCodeGenerated => 'Đã tạo mã từ tổ đội hiện tại của bạn.';

  @override
  String get communityCodeInvalid =>
      'Mã gồm đúng 6 chữ cái in hoa hoặc chữ số.';

  @override
  String get communityCodeRequired => 'Hãy nhập hoặc tạo mã tổ đội.';

  @override
  String get communityComment => 'Bình luận';

  @override
  String get communityCommentHint => 'Viết bình luận…';

  @override
  String communityComments(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString bình luận';
  }

  @override
  String communityCommentsHeader(String n) {
    return 'Bình luận · $n';
  }

  @override
  String get communityCommentsTitle => 'Bình luận';

  @override
  String communityCommunityActivity(String posts, String authors) {
    return '$posts bài · $authors người';
  }

  @override
  String communityCommunityLfg(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString tin tìm đồng đội';
  }

  @override
  String get communityCommunityVotes => 'Cộng đồng yêu thích';

  @override
  String get communityComposerHint => 'Bạn đang nghĩ gì về VALORANT hôm nay?';

  @override
  String get communityComposerTitle => 'Bài viết mới';

  @override
  String communityConsentAccount(String riotId) {
    return 'Tài khoản: $riotId';
  }

  @override
  String get communityConsentAgree => 'Đồng ý và tiếp tục';

  @override
  String get communityConsentGateAction => 'Tham gia';

  @override
  String get communityConsentGuidelines => 'Tiêu chuẩn cộng đồng';

  @override
  String get communityConsentLater => 'Để sau';

  @override
  String get communityConsentLocal =>
      'Mật khẩu và dữ liệu đăng nhập khác của bạn luôn ở lại trên thiết bị này. Bạn có thể rút lại đồng ý trong Cài đặt.';

  @override
  String get communityConsentPrivacy => 'Chính sách quyền riêng tư';

  @override
  String get communityConsentPublic =>
      'Người khác sẽ thấy Riot ID, thẻ người chơi, rank và quốc gia của bạn.';

  @override
  String get communityConsentTitle => 'Quyền riêng tư và Cộng đồng ValHub';

  @override
  String get communityConsentVerify =>
      'ValHub gửi quyền truy cập Riot cho máy chủ Cộng đồng để xác minh Riot ID khi kết nối và kiểm tra quyền sở hữu skin khi bạn lưu đánh giá. Máy chủ chỉ đọc dữ liệu cần thiết, dùng xong bỏ ngay quyền truy cập, không lưu.';

  @override
  String get communityConsentWithdrawn =>
      'Đã rút lại đồng ý. Cần đồng ý lại để tiếp tục sử dụng app.';

  @override
  String get communityCountriesEmpty => 'Không tìm thấy quốc gia phù hợp.';

  @override
  String get communityCountriesSearchHint => 'Tìm quốc gia…';

  @override
  String get communityCountriesTitle => 'Cộng đồng các nước';

  @override
  String get communityCountryNamesAE => 'Các Tiểu vương quốc Ả Rập Thống nhất';

  @override
  String get communityCountryNamesAL => 'Albania';

  @override
  String get communityCountryNamesAM => 'Armenia';

  @override
  String get communityCountryNamesAR => 'Argentina';

  @override
  String get communityCountryNamesAT => 'Áo';

  @override
  String get communityCountryNamesAU => 'Úc';

  @override
  String get communityCountryNamesAZ => 'Azerbaijan';

  @override
  String get communityCountryNamesBA => 'Bosnia và Herzegovina';

  @override
  String get communityCountryNamesBD => 'Bangladesh';

  @override
  String get communityCountryNamesBE => 'Bỉ';

  @override
  String get communityCountryNamesBG => 'Bulgaria';

  @override
  String get communityCountryNamesBH => 'Bahrain';

  @override
  String get communityCountryNamesBN => 'Brunei';

  @override
  String get communityCountryNamesBO => 'Bolivia';

  @override
  String get communityCountryNamesBR => 'Brazil';

  @override
  String get communityCountryNamesBY => 'Belarus';

  @override
  String get communityCountryNamesCA => 'Canada';

  @override
  String get communityCountryNamesCH => 'Thụy Sĩ';

  @override
  String get communityCountryNamesCL => 'Chile';

  @override
  String get communityCountryNamesCN => 'Trung Quốc';

  @override
  String get communityCountryNamesCO => 'Colombia';

  @override
  String get communityCountryNamesCR => 'Costa Rica';

  @override
  String get communityCountryNamesCU => 'Cuba';

  @override
  String get communityCountryNamesCY => 'Síp';

  @override
  String get communityCountryNamesCZ => 'Séc';

  @override
  String get communityCountryNamesDE => 'Đức';

  @override
  String get communityCountryNamesDK => 'Đan Mạch';

  @override
  String get communityCountryNamesDO => 'Cộng hòa Dominica';

  @override
  String get communityCountryNamesDZ => 'Algeria';

  @override
  String get communityCountryNamesEC => 'Ecuador';

  @override
  String get communityCountryNamesEE => 'Estonia';

  @override
  String get communityCountryNamesEG => 'Ai Cập';

  @override
  String get communityCountryNamesES => 'Tây Ban Nha';

  @override
  String get communityCountryNamesET => 'Ethiopia';

  @override
  String get communityCountryNamesFI => 'Phần Lan';

  @override
  String get communityCountryNamesFR => 'Pháp';

  @override
  String get communityCountryNamesGB => 'Vương quốc Anh';

  @override
  String get communityCountryNamesGE => 'Georgia';

  @override
  String get communityCountryNamesGH => 'Ghana';

  @override
  String get communityCountryNamesGR => 'Hy Lạp';

  @override
  String get communityCountryNamesGT => 'Guatemala';

  @override
  String get communityCountryNamesHK => 'Hồng Kông';

  @override
  String get communityCountryNamesHN => 'Honduras';

  @override
  String get communityCountryNamesHR => 'Croatia';

  @override
  String get communityCountryNamesHU => 'Hungary';

  @override
  String get communityCountryNamesID => 'Indonesia';

  @override
  String get communityCountryNamesIE => 'Ireland';

  @override
  String get communityCountryNamesIL => 'Israel';

  @override
  String get communityCountryNamesIN => 'Ấn Độ';

  @override
  String get communityCountryNamesIQ => 'Iraq';

  @override
  String get communityCountryNamesIR => 'Iran';

  @override
  String get communityCountryNamesIS => 'Iceland';

  @override
  String get communityCountryNamesIT => 'Ý';

  @override
  String get communityCountryNamesJO => 'Jordan';

  @override
  String get communityCountryNamesJP => 'Nhật Bản';

  @override
  String get communityCountryNamesKE => 'Kenya';

  @override
  String get communityCountryNamesKH => 'Campuchia';

  @override
  String get communityCountryNamesKR => 'Hàn Quốc';

  @override
  String get communityCountryNamesKW => 'Kuwait';

  @override
  String get communityCountryNamesKZ => 'Kazakhstan';

  @override
  String get communityCountryNamesLA => 'Lào';

  @override
  String get communityCountryNamesLB => 'Liban';

  @override
  String get communityCountryNamesLK => 'Sri Lanka';

  @override
  String get communityCountryNamesLT => 'Litva';

  @override
  String get communityCountryNamesLU => 'Luxembourg';

  @override
  String get communityCountryNamesLV => 'Latvia';

  @override
  String get communityCountryNamesLY => 'Libya';

  @override
  String get communityCountryNamesMA => 'Maroc';

  @override
  String get communityCountryNamesMD => 'Moldova';

  @override
  String get communityCountryNamesME => 'Montenegro';

  @override
  String get communityCountryNamesMK => 'Bắc Macedonia';

  @override
  String get communityCountryNamesMM => 'Myanmar';

  @override
  String get communityCountryNamesMN => 'Mông Cổ';

  @override
  String get communityCountryNamesMO => 'Ma Cao';

  @override
  String get communityCountryNamesMT => 'Malta';

  @override
  String get communityCountryNamesMX => 'Mexico';

  @override
  String get communityCountryNamesMY => 'Malaysia';

  @override
  String get communityCountryNamesNG => 'Nigeria';

  @override
  String get communityCountryNamesNI => 'Nicaragua';

  @override
  String get communityCountryNamesNL => 'Hà Lan';

  @override
  String get communityCountryNamesNO => 'Na Uy';

  @override
  String get communityCountryNamesNP => 'Nepal';

  @override
  String get communityCountryNamesNZ => 'New Zealand';

  @override
  String get communityCountryNamesOM => 'Oman';

  @override
  String get communityCountryNamesPA => 'Panama';

  @override
  String get communityCountryNamesPE => 'Peru';

  @override
  String get communityCountryNamesPH => 'Philippines';

  @override
  String get communityCountryNamesPK => 'Pakistan';

  @override
  String get communityCountryNamesPL => 'Ba Lan';

  @override
  String get communityCountryNamesPR => 'Puerto Rico';

  @override
  String get communityCountryNamesPT => 'Bồ Đào Nha';

  @override
  String get communityCountryNamesPY => 'Paraguay';

  @override
  String get communityCountryNamesQA => 'Qatar';

  @override
  String get communityCountryNamesRO => 'Romania';

  @override
  String get communityCountryNamesRS => 'Serbia';

  @override
  String get communityCountryNamesRU => 'Nga';

  @override
  String get communityCountryNamesSA => 'Ả Rập Xê Út';

  @override
  String get communityCountryNamesSE => 'Thụy Điển';

  @override
  String get communityCountryNamesSG => 'Singapore';

  @override
  String get communityCountryNamesSI => 'Slovenia';

  @override
  String get communityCountryNamesSK => 'Slovakia';

  @override
  String get communityCountryNamesSV => 'El Salvador';

  @override
  String get communityCountryNamesTH => 'Thái Lan';

  @override
  String get communityCountryNamesTL => 'Đông Timor';

  @override
  String get communityCountryNamesTN => 'Tunisia';

  @override
  String get communityCountryNamesTR => 'Thổ Nhĩ Kỳ';

  @override
  String get communityCountryNamesTW => 'Đài Loan';

  @override
  String get communityCountryNamesUA => 'Ukraine';

  @override
  String get communityCountryNamesUS => 'Hoa Kỳ';

  @override
  String get communityCountryNamesUY => 'Uruguay';

  @override
  String get communityCountryNamesUZ => 'Uzbekistan';

  @override
  String get communityCountryNamesVE => 'Venezuela';

  @override
  String get communityCountryNamesVN => 'Việt Nam';

  @override
  String get communityCountryNamesZA => 'Nam Phi';

  @override
  String get communityCreateLfg => 'Tạo tin tìm đồng đội';

  @override
  String get communityCreateLfgShort => 'Tạo tin';

  @override
  String get communityDataDeleted => 'Đã xóa dữ liệu Cộng đồng của bạn.';

  @override
  String communityDataFooter(String riotId) {
    return 'Áp dụng cho tài khoản đang dùng: $riotId. Tệp tải về không chứa mật khẩu hay dữ liệu đăng nhập Riot.';
  }

  @override
  String get communityDataTitle => 'Dữ liệu Cộng đồng của bạn';

  @override
  String get communityDecrease => 'Giảm';

  @override
  String get communityDelete => 'Xóa';

  @override
  String get communityDeleteComment => 'Xóa bình luận';

  @override
  String get communityDeleteCommentBody => 'Bình luận này sẽ bị xóa vĩnh viễn.';

  @override
  String get communityDeleteCommentTitle => 'Xóa bình luận?';

  @override
  String get communityDeleteDataConfirm => 'Xóa vĩnh viễn';

  @override
  String communityDeleteDataConfirmBody(String riotId) {
    return 'Toàn bộ bài viết, bình luận, đánh giá skin, lượt thích, bình chọn, tin tìm đồng đội và ảnh của $riotId trên Cộng đồng ValHub sẽ bị xóa vĩnh viễn và không thể khôi phục. Bạn quay lại chế độ xem ẩn danh và cần đồng ý lại nếu muốn tham gia lần nữa.\n\nTài khoản Riot và dữ liệu trong game không bị ảnh hưởng. Hãy tải dữ liệu về trước nếu bạn muốn giữ một bản sao.';
  }

  @override
  String get communityDeleteDataConfirmTitle => 'Xóa dữ liệu Cộng đồng?';

  @override
  String get communityDeleteDataSubtitle =>
      'Xóa vĩnh viễn mọi thứ bạn đã đăng lên Cộng đồng.';

  @override
  String get communityDeleteDataTitle => 'Xóa dữ liệu Cộng đồng của tôi';

  @override
  String get communityDeletePost => 'Xóa bài viết';

  @override
  String get communityDeletePostBody =>
      'Bài viết và toàn bộ bình luận sẽ bị xóa vĩnh viễn.';

  @override
  String get communityDeletePostTitle => 'Xóa bài viết?';

  @override
  String get communityDeleteReview => 'Xóa đánh giá';

  @override
  String get communityDeleteReviewBody =>
      'Điểm và nhận xét của bạn cho skin này sẽ bị xóa.';

  @override
  String get communityDeleteReviewTitle => 'Xóa đánh giá của bạn?';

  @override
  String get communityDeleted => 'Đã xóa.';

  @override
  String get communityDiscard => 'Bỏ';

  @override
  String get communityDiscardBody => 'Nội dung bạn vừa viết sẽ không được lưu.';

  @override
  String get communityDiscardTitle => 'Bỏ bài viết?';

  @override
  String get communityDownload => 'Tải và dịch';

  @override
  String get communityDownloadingModels => 'Đang tải gói dịch…';

  @override
  String get communityEditReview => 'Sửa';

  @override
  String get communityEdited => 'đã sửa';

  @override
  String get communityEmptyPost => 'Hãy viết gì đó hoặc thêm ảnh.';

  @override
  String get communityExpired => 'Đã hết hạn';

  @override
  String communityExpiresIn(String t) {
    return 'Còn $t';
  }

  @override
  String get communityExportPreparing => 'Đang chuẩn bị…';

  @override
  String get communityExportSubject => 'Dữ liệu Cộng đồng ValHub';

  @override
  String get communityExportSubtitle =>
      'Bản sao mọi thứ bạn đã đăng trong Cộng đồng: bài viết, bình luận, đánh giá, lượt thích, bình chọn và tin tìm đồng đội.';

  @override
  String get communityExportTitle => 'Tải dữ liệu của tôi';

  @override
  String get communityExtend => 'Gia hạn';

  @override
  String get communityExtended => 'Đã gia hạn tin thêm 30 phút.';

  @override
  String get communityFeedEmptyBody =>
      'Hãy là người đầu tiên chia sẻ cửa hàng, Chợ Đêm hay khoảnh khắc của bạn!';

  @override
  String get communityFeedEmptyFilteredBody =>
      'Không có bài phù hợp. Thử đổi ngôn ngữ hoặc bỏ bộ lọc.';

  @override
  String get communityFeedEmptyGuestBody =>
      'Chưa có bài mới. Quay lại sau hoặc tham gia để chia sẻ.';

  @override
  String get communityFeedEmptyScopeBody =>
      'Thử xem bài từ cộng đồng quốc tế hoặc đổi bộ lọc.';

  @override
  String get communityFeedEmptyScopeTitle => 'Chưa có bài trong phạm vi này';

  @override
  String get communityFeedEmptyTitle => 'Bảng tin còn trống';

  @override
  String get communityFilters => 'Bộ lọc';

  @override
  String get communityGenerateCode => 'Tạo mã tổ đội';

  @override
  String get communityGeneratingCode => 'Đang tạo mã…';

  @override
  String get communityGoogleDisclaimer =>
      'THIS SERVICE MAY CONTAIN TRANSLATIONS POWERED BY GOOGLE. GOOGLE DISCLAIMS ALL WARRANTIES RELATED TO THE TRANSLATIONS, EXPRESS OR IMPLIED, INCLUDING ANY WARRANTIES OF ACCURACY, RELIABILITY, AND ANY IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.';

  @override
  String get communityGoogleDisclaimerTitle => 'Bản dịch của Google';

  @override
  String get communityHelpful => 'Hữu ích';

  @override
  String communityHelpfulCount(String n) {
    return 'Hữu ích · $n';
  }

  @override
  String get communityHiddenAuthors => 'Người đã ẩn và chặn';

  @override
  String get communityHiddenAuthorsEmpty => 'Chưa ẩn hoặc chặn ai';

  @override
  String get communityHiddenAuthorsHint =>
      'Áp dụng riêng cho tài khoản này trên thiết bị này. Nội dung của họ được ẩn; họ vẫn có thể xem nội dung công khai của bạn.';

  @override
  String communityImageOf(int i, int n) {
    return 'Ảnh $i/$n';
  }

  @override
  String get communityIncrease => 'Tăng';

  @override
  String get communityJoin => 'Vào';

  @override
  String get communityJoinCodeExpired =>
      'Mã tổ đội đã hết hạn hoặc không còn hiệu lực.';

  @override
  String communityJoinConfirmBody(String name) {
    return 'Bạn sẽ rời tổ đội hiện tại trong VALORANT để vào tổ đội của $name.';
  }

  @override
  String get communityJoinConfirmTitle => 'Vào tổ đội này?';

  @override
  String get communityJoinGameNotRunning =>
      'Hãy mở VALORANT trên máy tính hoặc console rồi thử lại.';

  @override
  String get communityJoinInvalidCode =>
      'Mã tổ đội không còn hiệu lực hoặc tổ đội đã đủ người.';

  @override
  String get communityJoinParty => 'Vào tổ đội';

  @override
  String get communityJoinPartyFull => 'Tổ đội này đã đủ người.';

  @override
  String get communityJoined => 'Đã vào tổ đội! Mở VALORANT để chơi cùng nhau.';

  @override
  String get communityJoinedHint =>
      'Đã vào tổ đội! Mở VALORANT để chơi cùng nhau.';

  @override
  String communityJoinsCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString người đã yêu cầu vào';
  }

  @override
  String get communityKeepEditing => 'Viết tiếp';

  @override
  String get communityKindNightMarket => 'Chợ Đêm';

  @override
  String get communityKindStore => 'Cửa hàng hôm nay';

  @override
  String get communityLanguage => 'Ngôn ngữ';

  @override
  String get communityLanguageFilter => 'Ngôn ngữ nội dung';

  @override
  String get communityLanguageFilterHint =>
      'Chỉ hiện nội dung viết bằng các ngôn ngữ đã chọn. Bỏ trống để xem tất cả.';

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
    return '$n ngôn ngữ';
  }

  @override
  String get communityLfgEmptyBody =>
      'Tạo tin để người chơi khác vào tổ đội của bạn chỉ với một chạm.';

  @override
  String get communityLfgEmptyTitle => 'Chưa ai tìm đồng đội';

  @override
  String get communityLfgExpiredRepost =>
      'Tin của bạn đã hết hạn. Hãy đăng tin mới để tìm đồng đội.';

  @override
  String get communityLfgExpiryNote => 'Tin tự hết hạn sau 30 phút.';

  @override
  String get communityLfgGateBody =>
      'Tham gia (xác minh Riot ID một lần) để xem tin của người chơi cùng máy chủ và đăng tin tìm đồng đội của bạn. Bạn vẫn xem Bảng tin và Xếp hạng skin bình thường.';

  @override
  String get communityLfgGateTitle => 'Tìm đồng đội dành cho thành viên';

  @override
  String communityLfgOtherShardNote(String region) {
    return 'Bạn đang xem máy chủ $region — chỉ người cùng máy chủ với tài khoản của bạn mới vào tổ đội được.';
  }

  @override
  String get communityLfgPosted => 'Đã đăng tin tìm đồng đội!';

  @override
  String get communityLfgPreviewTitle => 'Tìm đồng đội hợp rank';

  @override
  String get communityLfgRemoved => 'Đã gỡ tin.';

  @override
  String get communityLfgSameShardNote =>
      'Chỉ người cùng máy chủ mới vào tổ đội được.';

  @override
  String communityLfgSheetSubtitle(String region) {
    return 'Khu vực: $region · Tin tự hết hạn sau 30 phút.';
  }

  @override
  String get communityLike => 'Thích';

  @override
  String communityLikes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString lượt thích';
  }

  @override
  String get communityLiveMembers => 'Thành viên';

  @override
  String get communityLoadMoreFailed => 'Chưa tải thêm được bài. Hãy thử lại.';

  @override
  String get communityMatchMyRank => 'Phù hợp rank của bạn';

  @override
  String communityMaxPhotos(int max) {
    return 'Tối đa $max ảnh.';
  }

  @override
  String communityMemberJoined(String name) {
    return '$name đã vào tổ đội';
  }

  @override
  String get communityMemberJoinedBody =>
      'Tin tìm đồng đội của bạn vừa có người vào.';

  @override
  String get communityMic => 'Cần mic';

  @override
  String get communityMicOn => 'Có mic';

  @override
  String get communityMode => 'Chế độ';

  @override
  String communityModelSize(int mb) {
    return '$mb MB';
  }

  @override
  String get communityMoreActions => 'Tùy chọn khác';

  @override
  String get communityMuteAuthor => 'Ẩn người này';

  @override
  String get communityMyPost => 'Tin của bạn';

  @override
  String get communityNewPost => 'Đăng bài';

  @override
  String communityNightMarketOf(String date) {
    return 'Chợ Đêm ngày $date';
  }

  @override
  String get communityNoAccountBody =>
      'Thêm tài khoản Riot để đăng bài, tìm đồng đội và bình chọn skin.';

  @override
  String get communityNoAccountTitle => 'Đăng nhập để tham gia';

  @override
  String get communityNoComments => 'Chưa có bình luận. Hãy mở lời trước nhé!';

  @override
  String get communityNoParty =>
      'Không tìm thấy tổ đội. Hãy mở VALORANT rồi thử lại, hoặc nhập mã thủ công.';

  @override
  String communityNoPartyWithReason(String reason) {
    return 'Không tìm thấy tổ đội. Hãy mở VALORANT rồi thử lại, hoặc nhập mã thủ công.\n$reason';
  }

  @override
  String get communityNoRatings => 'Chưa có đánh giá';

  @override
  String get communityNote => 'Ghi chú';

  @override
  String get communityNoteHint =>
      'VD: cần 1 người Kiểm soát, có mic, vui vẻ là chính';

  @override
  String communityOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String communityOffersTotal(String amount) {
    return 'Tổng $amount';
  }

  @override
  String get communityOpenReviews => 'Xem đánh giá';

  @override
  String get communityOutOfRange => 'Ngoài khoảng rank';

  @override
  String communityPageOf(String i, String n) {
    return '$i/$n';
  }

  @override
  String get communityPartyCode => 'Mã tổ đội';

  @override
  String get communityPartyCodeHint => 'VD: A1B2C3';

  @override
  String communityPartyCodeValue(String code) {
    return 'Mã tổ đội: $code';
  }

  @override
  String get communityPartySize => 'Tổ đội hiện có';

  @override
  String get communityPartySizeFromGame => 'Lấy từ tổ đội trong game';

  @override
  String communityPartySizeValue(int n) {
    return '$n người';
  }

  @override
  String get communityPeriodAll => 'Tất cả';

  @override
  String get communityPeriodAllTime => 'Từ trước tới giờ';

  @override
  String get communityPeriodWeek => 'Tuần này';

  @override
  String communityPhotoCount(int n, int max) {
    return '$n/$max ảnh';
  }

  @override
  String get communityPickRating => 'Hãy chọn số sao.';

  @override
  String get communityPlayVideo => 'Xem video';

  @override
  String get communityPostLfg => 'Đăng tin';

  @override
  String get communityPostNotFound => 'Bài viết này đã bị xóa hoặc ẩn.';

  @override
  String get communityPostTitle => 'Bài viết';

  @override
  String get communityPosted => 'Đã đăng bài!';

  @override
  String get communityPrivacyNote =>
      'ValHub xác minh Riot ID khi kết nối Cộng đồng và quyền sở hữu skin khi bạn đánh giá. Cộng đồng không lưu mật khẩu hay dữ liệu đăng nhập Riot của bạn.';

  @override
  String get communityPublish => 'Đăng';

  @override
  String get communityPublishing => 'Đang đăng…';

  @override
  String communityRankBetween(String a, String b) {
    return '$a – $b';
  }

  @override
  String get communityRankFrom => 'Từ';

  @override
  String communityRankNumber(String n) {
    return '#$n';
  }

  @override
  String get communityRankRange => 'Khoảng rank';

  @override
  String get communityRankRangeInvalid =>
      'Hãy chọn rank thấp nhất không cao hơn rank cao nhất.';

  @override
  String communityRankSemantics(String n, String name) {
    return 'Hạng $n: $name';
  }

  @override
  String get communityRankTo => 'Đến';

  @override
  String get communityRateLimitedTitle => 'Hãy đợi một chút';

  @override
  String communityRatingCount(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString đánh giá';
  }

  @override
  String communityRatingSummary(String avg, int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$avg · $nString đánh giá';
  }

  @override
  String get communityRatingWordsItem0 => 'Tệ';

  @override
  String get communityRatingWordsItem1 => 'Chưa ổn';

  @override
  String get communityRatingWordsItem2 => 'Ổn';

  @override
  String get communityRatingWordsItem3 => 'Đẹp';

  @override
  String get communityRatingWordsItem4 => 'Tuyệt phẩm';

  @override
  String get communityRefreshList => 'Làm mới';

  @override
  String get communityRegion => 'Khu vực';

  @override
  String get communityRemoveAttachment => 'Bỏ đính kèm';

  @override
  String get communityRemoveLfg => 'Gỡ tin';

  @override
  String get communityRemoveLfgBody => 'Người khác sẽ không thấy tin này nữa.';

  @override
  String get communityRemoveLfgTitle => 'Gỡ tin tìm đồng đội?';

  @override
  String get communityRemovePhoto => 'Bỏ ảnh';

  @override
  String get communityReport => 'Báo cáo';

  @override
  String get communityReportConfirmBody =>
      'Nội dung bị nhiều người báo cáo sẽ được ẩn khỏi Cộng đồng.';

  @override
  String get communityReportConfirmTitle => 'Gửi báo cáo?';

  @override
  String get communityReportPrompt => 'Vì sao bạn báo cáo nội dung này?';

  @override
  String get communityReportReasonsSpam => 'Spam hoặc quảng cáo';

  @override
  String get communityReportReasonsHarassment => 'Quấy rối, xúc phạm';

  @override
  String get communityReportReasonsInappropriate => 'Nội dung không phù hợp';

  @override
  String get communityReportReasonsScam => 'Lừa đảo, mua bán tài khoản';

  @override
  String get communityReportReasonsOther => 'Lý do khác';

  @override
  String get communityReportTitle => 'Báo cáo nội dung';

  @override
  String get communityReported => 'Cảm ơn bạn! Báo cáo đã được gửi.';

  @override
  String get communityRetry => 'Thử lại';

  @override
  String get communityReviewDeleted => 'Đã xóa đánh giá.';

  @override
  String get communityReviewHint =>
      'Chia sẻ cảm nhận về skin này (không bắt buộc)';

  @override
  String get communityReviewSaved => 'Đã lưu đánh giá!';

  @override
  String get communityReviewTitle => 'Đánh giá skin';

  @override
  String get communityReviewsEmptyBody =>
      'Chưa có đánh giá — hãy là người đầu tiên!';

  @override
  String get communityReviewsEmptyTitle => 'Chưa có đánh giá';

  @override
  String communityReviewsHeader(String n) {
    return 'Đánh giá · $n';
  }

  @override
  String get communityReviewsSection => 'Đánh giá';

  @override
  String communityRiotId(String name, String tag) {
    return '$name#$tag';
  }

  @override
  String get communityRiotUnavailableTitle => 'Riot đang gặp sự cố';

  @override
  String get communityRoleFlex => 'Linh hoạt';

  @override
  String get communityRoles => 'Vai trò cần';

  @override
  String get communitySaveReview => 'Lưu đánh giá';

  @override
  String get communityScopeCountry => 'Nước bạn';

  @override
  String get communityScopeGlobal => 'Quốc tế';

  @override
  String get communityScopeRegion => 'Khu vực';

  @override
  String get communityScopeWorldwide => 'Toàn cầu';

  @override
  String get communitySectionFeed => 'Bảng tin';

  @override
  String get communitySectionLfg => 'Tìm đồng đội';

  @override
  String get communitySectionSkins => 'Xếp hạng skin';

  @override
  String get communitySend => 'Gửi';

  @override
  String get communitySendComment => 'Gửi bình luận';

  @override
  String get communityShareNightMarketHint =>
      'Khoe Chợ Đêm của bạn với mọi người';

  @override
  String communitySharePostTitle(String name) {
    return 'Bài viết của $name trên ValHub';
  }

  @override
  String get communityShareStore => 'Khoe lên Cộng đồng';

  @override
  String get communityShareStoreHint => 'Khoe cửa hàng hôm nay với mọi người';

  @override
  String get communityShowOriginal => 'Xem bản gốc';

  @override
  String get communityShowTranslation => 'Xem bản dịch';

  @override
  String get communitySignInToReview => 'Thêm tài khoản Riot để đánh giá skin.';

  @override
  String get communitySkinNotFound => 'Không tìm thấy skin này.';

  @override
  String get communitySkinsEmptyBody =>
      'Thả tim cho skin bạn thích nhất để đưa nó lên bảng xếp hạng!';

  @override
  String get communitySkinsEmptyTitle => 'Chưa có lượt bình chọn';

  @override
  String get communitySlots => 'Số người cần';

  @override
  String communitySlotsTooMany(int max) {
    return 'Tổ đội có tối đa 5 người: chỉ còn $max chỗ.';
  }

  @override
  String communitySlotsWanted(int n) {
    return 'Cần $n người';
  }

  @override
  String get communitySortHelpful => 'Hữu ích nhất';

  @override
  String get communitySortNewest => 'Mới nhất';

  @override
  String get communitySortRating => 'Đánh giá cao nhất';

  @override
  String get communitySortReviews => 'Nhiều đánh giá nhất';

  @override
  String get communitySortVotes => 'Yêu thích nhất';

  @override
  String communityStarLabel(int n) {
    return '$n sao';
  }

  @override
  String communityStarsSemantics(String avg) {
    return '$avg trên 5 sao';
  }

  @override
  String get communityStatusFull => 'Đã đủ người';

  @override
  String get communityStatusInGame => 'Đang trong trận';

  @override
  String get communityStatusOpen => 'Đang tìm';

  @override
  String communityStoreOf(String date) {
    return 'Cửa hàng ngày $date';
  }

  @override
  String communityTagSuffix(String tag) {
    return '#$tag';
  }

  @override
  String get communityTapToRate => 'Chạm vào sao để chấm điểm skin này';

  @override
  String get communityTitle => 'Cộng đồng';

  @override
  String communityTooLong(int max) {
    return 'Tối đa $max ký tự.';
  }

  @override
  String get communityTranslate => 'Dịch bằng Google';

  @override
  String communityTranslateDownloadBody(String from, String to, String size) {
    return 'Để dịch từ $from sang $to, ValHub cần tải gói ngôn ngữ từ Google (khoảng $size). Chỉ tải một lần; nội dung được dịch hoàn toàn trên máy của bạn và không gửi tới máy chủ nào.';
  }

  @override
  String get communityTranslateDownloadTitle => 'Tải gói dịch trên máy?';

  @override
  String get communityTranslateFailed => 'Không dịch được. Hãy thử lại.';

  @override
  String get communityTranslateUnavailable =>
      'Thiết bị này chưa hỗ trợ dịch trên máy.';

  @override
  String get communityTranslatedByGoogle => 'Dịch tự động bởi Google';

  @override
  String get communityTranslating => 'Đang dịch…';

  @override
  String get communityTrendingTitle => 'Skin được yêu thích toàn cầu';

  @override
  String get communityUnavailableBody =>
      'Chưa kết nối được Cộng đồng ValHub. Hãy thử lại sau ít phút.';

  @override
  String get communityUnavailableTitle => 'Chưa kết nối được Cộng đồng';

  @override
  String get communityUnhideAuthor => 'Bỏ ẩn / bỏ chặn';

  @override
  String get communityUnknownPlayer => 'Người chơi';

  @override
  String get communityUnlike => 'Bỏ thích';

  @override
  String get communityUnvote => 'Bỏ tim';

  @override
  String get communityUploading => 'Đang tải ảnh lên…';

  @override
  String get communityViewImage => 'Xem ảnh';

  @override
  String get communityVote => 'Thả tim cho skin này';

  @override
  String communityVotes(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return '$nString lượt thích';
  }

  @override
  String get communityWithdrawConfirm => 'Rút lại';

  @override
  String communityWithdrawConfirmBody(String riotId) {
    return 'ValHub sẽ ngừng dùng Cộng đồng bằng $riotId: kết nối Cộng đồng trên thiết bị này bị xóa và bạn quay lại chế độ xem ẩn danh.\n\nBài viết, bình luận, đánh giá, bình chọn và tin tìm đồng đội đã đăng vẫn còn trên Cộng đồng và vẫn hiện Riot ID của bạn cho đến khi bạn xóa chúng từng cái, hoặc chọn \"Xóa dữ liệu Cộng đồng của tôi\". Bạn có thể tham gia lại bất cứ lúc nào.';
  }

  @override
  String get communityWithdrawConfirmTitle => 'Rút lại đồng ý?';

  @override
  String get communityWithdrawSubtitle =>
      'Ngừng dùng Cộng đồng bằng tài khoản này. Bài đã đăng vẫn được giữ.';

  @override
  String get communityWithdrawTitle => 'Rút lại đồng ý';

  @override
  String get communityWriteFirstReview => 'Viết đánh giá đầu tiên';

  @override
  String get communityWritePost => 'Viết bài';

  @override
  String get communityYou => 'Bạn';

  @override
  String get communityYourCountry => 'Nước của bạn';

  @override
  String get communityYourReview => 'Đánh giá của bạn';

  @override
  String liveGamePlayerStatistics(String kda, String hasAcs, String acs) {
    String _temp0 = intl.Intl.selectLogic(hasAcs, {
      'yes': ' · ACS $acs',
      'other': '',
    });
    return 'Bạn: $kda$_temp0';
  }

  @override
  String get liveGameAcs => 'ACS';

  @override
  String get liveGameAgentNotOwned => 'Bạn chưa sở hữu đặc vụ này.';

  @override
  String get liveGameAgentSelect => 'Đang chọn đặc vụ';

  @override
  String get liveGameAgentTaken => 'Đồng đội đã khóa đặc vụ này.';

  @override
  String get liveGameAnonymous => 'Ẩn danh';

  @override
  String get liveGameAutoRefreshNote => 'Tự động làm mới khi có trận.';

  @override
  String get liveGameBuddy => 'Phụ kiện súng';

  @override
  String get liveGameClose => 'Đóng';

  @override
  String get liveGameCurrentGame => 'Trận hiện tại';

  @override
  String get liveGameEmptyTeam => 'Chưa có người chơi.';

  @override
  String get liveGameEnemyHiddenInAgentSelect =>
      'Đội địch sẽ hiện khi trận đấu bắt đầu.';

  @override
  String liveGameEnemyLocked(int locked, int size) {
    return 'Đội địch đã khóa $locked/$size';
  }

  @override
  String get liveGameLiveStatsUnavailable =>
      'Nguồn trận trực tiếp này chưa cung cấp Kill/Death/Assist. Bảng điểm hiện khi Riot công bố dữ liệu sau trận.';

  @override
  String get liveGameFinalScoreboard => 'Bảng điểm cuối trận';

  @override
  String get liveGameFlex => 'Flex';

  @override
  String get liveGameHoverLockHint => 'Chạm để chọn thử, giữ để khóa đặc vụ.';

  @override
  String get liveGameInLobby => 'Đang ở sảnh chờ';

  @override
  String get liveGameInMatch => 'Đang đấu';

  @override
  String get liveGameInQueue => 'Đang tìm trận';

  @override
  String liveGameInQueueFor(String elapsed) {
    return 'Đang tìm trận · $elapsed';
  }

  @override
  String get liveGameKda => 'K/D/A';

  @override
  String liveGameLevel(int n) {
    return 'Cấp $n';
  }

  @override
  String get liveGameLiveScore => 'Tỉ số trực tiếp';

  @override
  String get liveGameLoadoutFromAgentSelect => 'Trang bị lúc chọn đặc vụ';

  @override
  String get liveGameLoadoutFromMatch => 'Trang bị trong trận này';

  @override
  String get liveGameLobbyHint =>
      'Khi tìm được trận, ValHub sẽ hiện đội hình và rank của mọi người.';

  @override
  String get liveGameLockFailed =>
      'Chưa khóa được đặc vụ này. Hãy làm mới rồi thử lại.';

  @override
  String liveGameLockedAgent(String agent) {
    return 'Đã khóa $agent';
  }

  @override
  String get liveGameLockedTag => 'Đã khóa';

  @override
  String get liveGameMatchPendingHint =>
      'ValHub sẽ tự thử lại. Bảng điểm thường có sau khoảng một phút.';

  @override
  String get liveGameNoAgentYet => 'Chưa chọn đặc vụ';

  @override
  String get liveGameNoAgents =>
      'Chưa tải được danh sách đặc vụ. Hãy làm mới để thử lại.';

  @override
  String get liveGameNoLoadout =>
      'Không có thông tin trang bị của người chơi này.';

  @override
  String get liveGameNotInGame => 'Không trong trận';

  @override
  String get liveGameNotInGameHint =>
      'Mở VALORANT và tìm trận — chi tiết trận sẽ tự hiện ở đây khi bạn vào màn hình chọn đặc vụ.';

  @override
  String get liveGameNotInGameTitle => 'Bạn không ở trong trận nào';

  @override
  String liveGameOpenLoadoutOf(String name) {
    return 'Xem trang bị của $name';
  }

  @override
  String get liveGameOpenParty => 'Mở tổ đội & hàng chờ';

  @override
  String get liveGameParty => 'Tổ đội';

  @override
  String liveGamePeak(String rank) {
    return 'Cao nhất: $rank';
  }

  @override
  String get liveGamePlayerCard => 'Thẻ người chơi';

  @override
  String liveGamePlayerLoadoutOf(String name) {
    return 'Trang bị của $name';
  }

  @override
  String get liveGamePlayerLoadoutTitle => 'Trang bị';

  @override
  String get liveGameQueueHint =>
      'Giữ ứng dụng mở — chi tiết trận sẽ hiện ngay khi tìm được trận.';

  @override
  String get liveGameQuitConfirmBodyInGame =>
      'Rời trận có thể khiến bạn bị phạt (mất RR, khóa hàng chờ). Bạn vẫn muốn rời?';

  @override
  String get liveGameQuitConfirmBodyPregame =>
      'Né trận ở màn hình chọn đặc vụ có thể khiến bạn bị phạt (mất RR, khóa hàng chờ). Bạn vẫn muốn rời?';

  @override
  String get liveGameQuitConfirmTitle => 'Rời trận đấu?';

  @override
  String get liveGameQuitDone => 'Đã rời trận.';

  @override
  String get liveGameQuitFailed => 'Chưa rời được trận.';

  @override
  String get liveGameQuitMatch => 'Rời trận';

  @override
  String get liveGameQuitMatchChanged =>
      'Trận đã chuyển giai đoạn trong lúc bạn xác nhận. Chưa rời trận, hãy thử lại.';

  @override
  String get liveGameRankUnavailable => 'Không rõ rank';

  @override
  String get liveGameRefresh => 'Làm mới';

  @override
  String liveGameRefreshIn(int seconds) {
    return 'Tự làm mới sau $seconds giây';
  }

  @override
  String get liveGameRefreshNow => 'Làm mới ngay';

  @override
  String liveGameScore(int ally, int enemy) {
    return '$ally – $enemy';
  }

  @override
  String get liveGameSelectFailed =>
      'Chưa chọn được đặc vụ này. Hãy làm mới rồi thử lại.';

  @override
  String get liveGameSheetTitle => 'Chi tiết trận';

  @override
  String get liveGameSprays => 'Hình phun sơn';

  @override
  String get liveGameStatusAgentSelect => 'Đang chọn đặc vụ';

  @override
  String get liveGameStatusEnded => 'Đã kết thúc';

  @override
  String get liveGameStatusInProgress => 'Đang diễn ra';

  @override
  String get liveGameStatusUnavailable => 'Chưa cập nhật được trạng thái trận';

  @override
  String get liveGameTabAgents => 'Đặc vụ';

  @override
  String get liveGameTabAllPlayers => 'Người chơi';

  @override
  String get liveGameTabEnemyTeam => 'Đội địch';

  @override
  String get liveGameTabYourTeam => 'Đội của bạn';

  @override
  String liveGameTimeLeft(String t) {
    return 'Còn $t';
  }

  @override
  String get liveGameViewMatchDetails => 'Xem chi tiết trận';

  @override
  String get liveGameWeapons => 'Vũ khí';

  @override
  String get liveGameYou => 'BẠN';

  @override
  String liveGameYouHover(String agent) {
    return 'Bạn đang chọn $agent';
  }

  @override
  String liveGameYouLocked(String agent) {
    return 'Bạn đã khóa $agent';
  }

  @override
  String get liveGamePickInGame =>
      'Chọn và khóa đặc vụ trong VALORANT. ValHub chỉ hiển thị thời gian còn lại và đội của bạn.';

  @override
  String profileWinLossSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ' – $draws hòa',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ' – $unknown trận chưa rõ kết quả',
      zero: '',
    );
    return '$wins thắng – $losses thua$_temp0$_temp1';
  }

  @override
  String profileDeviceTimeZone(String offset) {
    return 'giờ thiết bị ($offset)';
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
      'yes': ' bằng $weapon',
      'other': '',
    });
    return '$killer hạ gục $victim$_temp0 ($time)';
  }

  @override
  String profilePerformancePeriodLabel(String period) {
    String _temp0 = intl.Intl.selectLogic(period, {
      'days30': '30 ngày',
      'days7': '7 ngày',
      'other': 'Toàn bộ',
    });
    return '$_temp0';
  }

  @override
  String profilePerformanceSegmentLabel(String segment) {
    String _temp0 = intl.Intl.selectLogic(segment, {
      'agents': 'Đặc vụ',
      'maps': 'Bản đồ',
      'queues': 'Chế độ',
      'sides': 'Tấn công / Phòng thủ',
      'trend': 'Xu hướng',
      'other': 'Chế độ',
    });
    return '$_temp0';
  }

  @override
  String get profileAllModes => 'Mọi chế độ';

  @override
  String get profileAbility => 'Kỹ năng';

  @override
  String profileAboutMatches(int n) {
    return '≈ $n trận';
  }

  @override
  String get profileAcs => 'ACS';

  @override
  String get profileAcsHint => 'Điểm chiến đấu trung bình';

  @override
  String profileActRecord(int wins, int games, String rate) {
    return 'Phần này: $wins thắng / $games trận · $rate';
  }

  @override
  String get profileAdr => 'ADR';

  @override
  String get profileAllPlayers => 'Tất cả người chơi';

  @override
  String get profileAlreadyReached => 'Bạn đã đạt hạng này.';

  @override
  String get profileAtCurrentForm => 'Với phong độ hiện tại';

  @override
  String profileAtCurrentFormWith(String gain, String loss) {
    return 'Với phong độ hiện tại ($gain / $loss mỗi trận)';
  }

  @override
  String profileBestCase(int n) {
    return 'Tốt nhất: $n trận thắng liên tiếp';
  }

  @override
  String get profileByWinRateTitle => 'Theo tỉ lệ thắng';

  @override
  String get profileChooseMap => 'Lọc theo bản đồ';

  @override
  String get profileClearMap => 'Bỏ lọc bản đồ';

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
  String get profileCopyRiotId => 'Sao chép Riot ID';

  @override
  String get profileCurrentRank => 'Hiện tại';

  @override
  String get profileDailyRrEmpty =>
      'Chưa có trận xếp hạng nào được lưu trên thiết bị này.';

  @override
  String get profileDailyRrFootnote =>
      'Lịch sử RR được lưu ngay trên thiết bị của bạn, kể cả các trận Riot không còn trả về.';

  @override
  String get profileDailyRrTitle => 'RR theo ngày';

  @override
  String profileDayBoundary(String zone) {
    return 'Ngày tính theo $zone';
  }

  @override
  String profileDaysPlayed(int n) {
    return '$n ngày có trận';
  }

  @override
  String get profileDuration => 'Thời lượng';

  @override
  String profileDurationOf(String d) {
    return 'Thời lượng $d';
  }

  @override
  String get profileEndOfHistory => 'Đã hiển thị tất cả trận đấu';

  @override
  String get profileEnemyTeam => 'Đội địch';

  @override
  String get profileFallDamage => 'Rơi từ trên cao';

  @override
  String get profileFilterAll => 'Tất cả';

  @override
  String get profileFilterMap => 'Bản đồ';

  @override
  String get profileFirstBloods => 'First blood';

  @override
  String get profileFirstDeaths => 'Bị hạ đầu tiên';

  @override
  String get profileFirstHalf => 'Hiệp 1';

  @override
  String get profileFormNoRoundStats =>
      'K/D, ACS, HS% chỉ tính cho các chế độ theo vòng đấu.';

  @override
  String profileFormPending(int n) {
    return '$n trận trong danh sách chưa được tải để tính.';
  }

  @override
  String profileFormRoundStatsNote(int roundGames, int games) {
    return 'K/D, ACS, ADR, HS% chỉ tính $roundGames/$games trận theo vòng đấu';
  }

  @override
  String profileFormSemantics(int w, int l, int games) {
    return '$games trận gần nhất: $w thắng, $l thua';
  }

  @override
  String get profileFriendsRow => 'Bạn bè & trò chuyện';

  @override
  String profileGainPerWin(String rr) {
    return '$rr RR khi thắng';
  }

  @override
  String get profileHideKills => 'Ẩn pha hạ gục';

  @override
  String get profileHitBody => 'Thân';

  @override
  String get profileHitDistribution => 'Phân bố phát bắn trúng';

  @override
  String get profileHitHead => 'Đầu';

  @override
  String get profileHitLegs => 'Chân';

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
      'Tỉ lệ vòng bạn hạ gục, hỗ trợ, sống sót hoặc được đồng đội hạ đối thủ vừa hạ bạn';

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
    return '$n ngày qua';
  }

  @override
  String profileLastMatches(int n) {
    return '$n trận gần nhất';
  }

  @override
  String profileLeaderboard(String n) {
    return 'Bảng xếp hạng #$n';
  }

  @override
  String profileLevel(int n) {
    return 'Cấp $n';
  }

  @override
  String get profileLevelHidden => 'Cấp ẩn';

  @override
  String profileLossPerLoss(String rr) {
    return '$rr RR khi thua';
  }

  @override
  String profileLossStreak(int n) {
    return 'Chuỗi $n trận thua';
  }

  @override
  String profileMapFilter(String map) {
    return 'Bản đồ: $map';
  }

  @override
  String profileMatchCount(int n) {
    return '$n trận';
  }

  @override
  String get profileMatchDetailTitle => 'Chi tiết trận đấu';

  @override
  String get profileMatchHistory => 'Lịch sử đấu';

  @override
  String get profileMatchUnavailable => 'Chưa tải được trận đấu';

  @override
  String get profileMatchesNeeded => 'Số trận cần';

  @override
  String get profileMvp => 'MVP';

  @override
  String get profileNeverRanked => 'Chưa từng xếp hạng';

  @override
  String get profileNoKillsInRound =>
      'Chưa có thông tin hạ gục trong vòng này.';

  @override
  String get profileNoMatches => 'Chưa có trận đấu nào.';

  @override
  String get profileNoMatchesMap =>
      'Không có trận nào trên bản đồ này trong các trận đã tải.';

  @override
  String get profileNoMatchesQueue => 'Không có trận nào ở chế độ này.';

  @override
  String get profileNoPlayers => 'Chưa có thông tin người chơi của trận này.';

  @override
  String get profileNoRounds => 'Chưa có thông tin từng vòng của trận này.';

  @override
  String get profileOvertime => 'Hiệp phụ';

  @override
  String get profilePlayHubTitle => 'Trận đấu & tổ đội';

  @override
  String get profilePartyRow => 'Tổ đội & hàng chờ';

  @override
  String get profilePeakRank => 'Cao nhất';

  @override
  String profilePeakRankOf(String actTitle) {
    return 'Cao nhất · $actTitle';
  }

  @override
  String get profilePerformanceAttack => 'Tấn công';

  @override
  String get profilePerformanceDefense => 'Phòng thủ';

  @override
  String get profilePerformanceEmpty =>
      'Chưa có trận nào được ghi trên thiết bị này. Mở lịch sử trận để ghi lại những trận bạn đã chơi.';

  @override
  String get profilePerformanceGames => 'Số trận';

  @override
  String get profilePerformanceNoMatches =>
      'Không có trận trong khoảng thời gian đã chọn.';

  @override
  String profilePerformanceRounds(int n) {
    return '$n vòng đã ghi nhận';
  }

  @override
  String get profilePerformanceSample =>
      'Tỉ lệ chỉ hiện khi có ít nhất 3 trận. ACS, ADR, HS% và K/D chỉ tính các chế độ theo vòng.';

  @override
  String profilePerformanceSideCoverage(int known, int total) {
    return 'Xác định được bên tấn công hoặc phòng thủ ở $known/$total vòng.';
  }

  @override
  String profilePerformanceSince(String date) {
    return 'Lịch sử trên thiết bị, từ $date';
  }

  @override
  String get profilePerformanceTitle => 'Hiệu suất';

  @override
  String get profilePerformanceTrendEmpty =>
      'Cần ít nhất hai giai đoạn có từ 3 trận để so sánh xu hướng.';

  @override
  String get profilePickTargetHint => 'Chọn hạng bạn muốn đạt';

  @override
  String profilePlacement(int n) {
    return 'Hạng $n';
  }

  @override
  String profilePlantedAt(String site) {
    return 'Đặt Spike ở $site';
  }

  @override
  String get profilePlayerProfileTitle => 'Hồ sơ người chơi';

  @override
  String get profilePlayerSummary => 'Thành tích';

  @override
  String profileProgressTo(String rank) {
    return 'Tiến độ tới $rank';
  }

  @override
  String get profileProgressToTarget => 'Tiến độ tới hạng mục tiêu';

  @override
  String profileRankChange(String from, String to) {
    return '$from → $to';
  }

  @override
  String get profileRankUpFootnote =>
      'Ước tính dựa trên các trận xếp hạng gần đây, chưa tính các trận phân hạng và cơ chế bảo vệ xuống hạng.';

  @override
  String profileRankUpHint(int matches, String rank) {
    return '≈ $matches trận để lên $rank';
  }

  @override
  String get profileRankUpImmortal =>
      'Bạn đã ở Bất Tử trở lên — tính năng này chỉ tính đến Bất Tử 1.';

  @override
  String get profileRankUpNoForm =>
      'Chưa có trận xếp hạng gần đây nào để ước tính phong độ.';

  @override
  String get profileRankUpOpen => 'Mở tính toán lên hạng';

  @override
  String get profileRankUpTitle => 'Tính toán lên hạng';

  @override
  String get profileRankUpUnranked =>
      'Hãy hoàn thành các trận phân hạng để dùng tính năng tính toán lên hạng.';

  @override
  String profileRankWithRr(String rank, String rr) {
    return '$rank · $rr RR';
  }

  @override
  String get profileRankedScoreboard => 'Bảng điểm xếp hạng';

  @override
  String profileRecentForm(int w, int l) {
    return 'Phong độ gần đây: $w thắng – $l thua';
  }

  @override
  String get profileRecentFormTitle => 'Phong độ gần đây';

  @override
  String get profileRecentMatches => 'Trận gần đây';

  @override
  String profileRecordShort(int w, int l, int d) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '${w}T · ${l}B · ${d}H',
      zero: '${w}T · ${l}B',
    );
    return '$_temp0';
  }

  @override
  String get profileRiotIdCopied => 'Đã sao chép Riot ID';

  @override
  String profileRound(int n) {
    return 'Vòng $n';
  }

  @override
  String profileRoundKills(int n) {
    return '$n hạ gục';
  }

  @override
  String get profileRoundLost => 'Thua vòng';

  @override
  String get profileRoundTimeline => 'Diễn biến vòng đấu';

  @override
  String get profileRoundWon => 'Thắng vòng';

  @override
  String get profileRoundsHint => 'Chạm vào một vòng để xem từng pha hạ gục.';

  @override
  String get profileRr => 'RR';

  @override
  String profileRrLeft(String n) {
    return 'Còn thiếu $n RR';
  }

  @override
  String profileRrToNext(int rr) {
    return '$rr / 100 RR';
  }

  @override
  String get profileRrTrendTitle => 'Diễn biến RR';

  @override
  String profileRrValue(String n) {
    return '$n RR';
  }

  @override
  String profileScore(int a, int b) {
    return '$a – $b';
  }

  @override
  String get profileScoreboard => 'Bảng điểm';

  @override
  String get profileSecondHalf => 'Hiệp 2';

  @override
  String get profileSeparator => ' · ';

  @override
  String get profileShowKills => 'Xem pha hạ gục';

  @override
  String get profileSideSwitch => 'Đổi bên';

  @override
  String get profileSpike => 'Spike';

  @override
  String profileTagSuffix(String tag) {
    return ' #$tag';
  }

  @override
  String get profileTargetRank => 'Hạng mục tiêu';

  @override
  String get profileTeamBlue => 'Đội Xanh';

  @override
  String get profileTeamMvp => 'MVP đội';

  @override
  String get profileTeamRed => 'Đội Đỏ';

  @override
  String get profileTitle => 'Hồ sơ';

  @override
  String profileToday(String text) {
    return 'Hôm nay: $text';
  }

  @override
  String get profileTodayNone => 'Hôm nay chưa có trận xếp hạng';

  @override
  String get profileTruePeakLocal => 'Theo lịch sử trên thiết bị';

  @override
  String get profileWeekdayShortItem0 => 'T2';

  @override
  String get profileWeekdayShortItem1 => 'T3';

  @override
  String get profileWeekdayShortItem2 => 'T4';

  @override
  String get profileWeekdayShortItem3 => 'T5';

  @override
  String get profileWeekdayShortItem4 => 'T6';

  @override
  String get profileWeekdayShortItem5 => 'T7';

  @override
  String get profileWeekdayShortItem6 => 'CN';

  @override
  String get profileWinRate => 'Tỉ lệ thắng';

  @override
  String profileWinStreak(int n) {
    return 'Chuỗi $n trận thắng';
  }

  @override
  String profileXpProgress(String xp, String perLevel) {
    return '$xp / $perLevel XP';
  }

  @override
  String get profileYourRank => 'Hạng của bạn';

  @override
  String get profileYourSummary => 'Thành tích của bạn';

  @override
  String get profileYourTeam => 'Đội của bạn';

  @override
  String get profileYourWinRate => 'Tỉ lệ thắng gần đây của bạn';

  @override
  String profilePerformanceQueueChip(String queue) {
    return 'Chế độ: $queue';
  }

  @override
  String get profilePerformanceChooseQueue => 'Lọc theo chế độ';

  @override
  String get profilePerformancePerMatchTitle => 'Từng trận';

  @override
  String get profilePerformancePerMatchHint => 'Chạm một cột để mở trận đó.';

  @override
  String profilePerformanceAverage(String value) {
    return 'Trung bình $value';
  }

  @override
  String get profilePerformanceChartEmpty =>
      'Cần ít nhất 2 trận theo vòng có số liệu này để vẽ biểu đồ.';

  @override
  String get profilePerformanceOpeningsTitle => 'Giao tranh mở màn';

  @override
  String get profilePerformanceOpeningWin => 'Thắng mở màn';

  @override
  String get profilePerformanceOpeningWinHint =>
      'Trong các vòng bạn là người hạ gục hoặc bị hạ đầu tiên, tỉ lệ bạn là người hạ gục.';

  @override
  String get profilePerformanceFirstBloodsPerGame => 'First blood mỗi trận';

  @override
  String get profilePerformanceFirstDeathsPerGame => 'Bị hạ đầu mỗi trận';

  @override
  String get profilePerformanceMultiKillsTitle => 'Nhiều mạng trong một vòng';

  @override
  String profilePerformanceMultiKill(String kind) {
    String _temp0 = intl.Intl.selectLogic(kind, {
      'k3': '3 mạng',
      'k4': '4 mạng',
      'ace': 'Ace',
      'other': '2 mạng',
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
      other: 'Tính trên $nString trận có đủ dữ liệu hạ gục.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceRoundWin => 'Thắng vòng';

  @override
  String get profilePerformanceDrillHint =>
      'Chạm một dòng để xem riêng đặc vụ, bản đồ hoặc chế độ đó.';

  @override
  String get profilePerformanceLoadOlder => 'Phân tích thêm trận cũ';

  @override
  String profilePerformanceLoadOlderHint(int n) {
    final intl.NumberFormat nNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String nString = nNumberFormat.format(n);

    return 'ValHub chỉ phân tích những trận đã mở trên máy này. Mỗi lần bấm sẽ thêm tối đa $nString trận cũ hơn.';
  }

  @override
  String get profilePerformanceSearchingOlder => 'Đang tìm trận cũ hơn…';

  @override
  String profilePerformanceLoadingOlder(int done, int total) {
    final intl.NumberFormat doneNumberFormat = intl.NumberFormat.decimalPattern(
      localeName,
    );
    final String doneString = doneNumberFormat.format(done);
    final intl.NumberFormat totalNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String totalString = totalNumberFormat.format(total);

    return 'Đang phân tích $doneString/$totalString trận…';
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
      other: 'Đã thêm $nString trận vào phân tích.',
      zero: 'Không có trận mới để thêm.',
    );
    return '$_temp0';
  }

  @override
  String get profilePerformanceNoOlder => 'Riot không còn lưu trận nào cũ hơn.';

  @override
  String get profileEconomyTitle => 'Kinh tế đội bạn';

  @override
  String get profileEconomyHint =>
      'Loại mua tính theo tổng giá trị trang bị của đội lúc bắt đầu vòng (quy ước của vlr.gg cho 5 người): Eco dưới 5.000, Semi-eco dưới 10.000, Semi-buy dưới 20.000, Full buy từ 20.000 credits. Vòng đầu mỗi hiệp là Pistol.';

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

    return 'Thắng $wonString/$playedString';
  }

  @override
  String profileEconomyMatchup(String mine, String theirs) {
    return '$mine vs $theirs';
  }

  @override
  String get legalAboutIntro =>
      'Trợ thủ VALORANT của bạn: cửa hàng mỗi ngày, wishlist, rank, trận đấu, nhiều tài khoản và cộng đồng người chơi, ngay trên thiết bị của bạn.';

  @override
  String get legalBackToTop => 'Về đầu trang';

  @override
  String get legalConsentAnd => ' và ';

  @override
  String get legalConsentPrefix => 'Bằng việc tiếp tục, bạn đồng ý với ';

  @override
  String get legalConsentPrivacy => 'Chính sách quyền riêng tư';

  @override
  String get legalConsentSuffix => ' của ValHub.';

  @override
  String get legalConsentTerms => 'Điều khoản sử dụng';

  @override
  String get legalContact => 'Liên hệ';

  @override
  String get legalContactBody => 'ndh0408@gmail.com';

  @override
  String get legalContactHeader => 'LIÊN HỆ';

  @override
  String get legalCreditsHeader => 'NGUỒN DỮ LIỆU & GHI CÔNG';

  @override
  String legalEffectiveFrom(String date) {
    return 'Hiệu lực từ $date';
  }

  @override
  String get legalLegalHeader => 'PHÁP LÝ';

  @override
  String get legalLicensePageLegalese =>
      '© 2026 Nguyễn Đức Huy. Bảo lưu mọi quyền.';

  @override
  String get legalThirdPartyLicenses => 'Phần mềm bên thứ ba';

  @override
  String get legalThirdPartyLicensesBody =>
      'Giấy phép của các phần mềm mã nguồn mở mà ValHub sử dụng';

  @override
  String get legalTocTitle => 'MỤC LỤC';

  @override
  String legalVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String legalDocumentLanguage(String language) {
    return 'Văn bản này hiện được hiển thị bằng $language.';
  }

  @override
  String get legalContentUnavailable =>
      'Không đọc được văn bản pháp lý. Hãy thử lại hoặc liên hệ hỗ trợ.';

  @override
  String get legalTranslationNotice =>
      'Đây là bản dịch để bạn tiện đọc. Nếu có khác biệt, bản tiếng Việt được ưu tiên áp dụng.';

  @override
  String get settingsUiLanguageTitle => 'Ngôn ngữ giao diện';

  @override
  String get settingsLanguageFollowDevice => 'Theo thiết bị';

  @override
  String get settingsLanguageSaveFailed =>
      'Chưa lưu được ngôn ngữ. Vui lòng thử lại.';

  @override
  String get settingsGeoCountry => 'Quốc gia';

  @override
  String get settingsGeoSearchCountry => 'Tìm tên hoặc mã quốc gia';

  @override
  String get settingsGeoSupportedOnly => 'Chỉ nơi đã xác nhận hỗ trợ';

  @override
  String get settingsGeoUnknown => 'Chưa xác minh khả năng hỗ trợ';

  @override
  String get settingsGeoRestricted => 'Bị hạn chế';

  @override
  String get settingsGeoSeparate => 'Dịch vụ riêng';

  @override
  String get settingsGeoAvailable => 'Có hỗ trợ';

  @override
  String get settingsGeoNotApplicable => 'Không áp dụng';

  @override
  String get settingsGeoConnection => 'Kết nối Riot';

  @override
  String get settingsGeoChooseRegion => 'Chọn khu vực';

  @override
  String get settingsGeoAuto => 'Tự động theo tài khoản';

  @override
  String get settingsGeoManual => 'Chọn thủ công';

  @override
  String get settingsGeoNoRegion => 'Chưa xác định được khu vực Riot';

  @override
  String get settingsGeoManualWarning =>
      'Lựa chọn này chỉ đổi máy chủ mà ValHub kết nối. Nó không chuyển khu vực tài khoản Riot của bạn. ValHub sẽ kiểm tra kết nối trước khi lưu.';

  @override
  String get settingsGeoConnectionSaved => 'Đã lưu cách kết nối';

  @override
  String get settingsGeoValidationFailed =>
      'Tài khoản không được xác nhận trên máy chủ này. Hãy chọn lại khu vực.';

  @override
  String get settingsGeoHintOnly =>
      'Quốc gia chỉ dùng để tra cứu và gợi ý. Khu vực kết nối theo tài khoản Riot.';

  @override
  String get settingsGeoUnsupported =>
      'Khu vực Riot chưa được hỗ trợ. Hãy chọn khu vực trong Cài đặt.';

  @override
  String get settingsGeoSave => 'Kiểm tra và lưu';

  @override
  String get settingsGeoCancel => 'Hủy';

  @override
  String get settingsGeoLoading => 'Đang kiểm tra kết nối…';

  @override
  String get settingsGeoCountryPreferenceHint =>
      'Lựa chọn này dùng cho tên quốc gia, gợi ý và giá VP ước tính. Máy chủ kết nối và quốc gia tài khoản Cộng đồng vẫn do Riot xác định.';

  @override
  String get settingsGeoCountryAutomatic =>
      'Dùng quốc gia tài khoản hoặc thiết bị';

  @override
  String get settingsGeoSaveFailed => 'Chưa lưu được lựa chọn. Hãy thử lại.';

  @override
  String get settingsGeoAllRegions => 'Tất cả khu vực';

  @override
  String get settingsGeoSuggestions => 'Gợi ý';

  @override
  String get settingsGeoNoCountries => 'Không có quốc gia khớp bộ lọc.';

  @override
  String get settingsGeoActiveCountries => 'Có hoạt động';

  @override
  String get settingsGeoAllCountries => 'Tất cả quốc gia';

  @override
  String get settingsGeoActivityUnavailable =>
      'Chưa tải được hoạt động các nước. Bạn vẫn có thể chọn trong Tất cả quốc gia.';

  @override
  String settingsGeoResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count quốc gia',
    );
    return '$_temp0';
  }

  @override
  String settingsGeoManualConfirm(String manual, String detected) {
    return 'Bạn chọn $manual, nhưng Riot xác định tài khoản ở $detected. Tiếp tục kiểm tra kết nối này?';
  }

  @override
  String get settingsGeoUnverified =>
      'Chưa xác minh được kết nối do máy chủ hoặc mạng đang gặp lỗi. Lưu lựa chọn này và thử lại sau?';

  @override
  String get settingsGeoContinue => 'Tiếp tục';

  @override
  String settingsGeoMismatch(String region) {
    return 'Kết nối thủ công khác với khu vực Riot: $region. Bạn muốn dùng khu vực tự động?';
  }

  @override
  String get settingsGeoUseAuto => 'Dùng tự động';

  @override
  String get settingsGeoKeepManual => 'Giữ thủ công';

  @override
  String get settingsGeoReviewConnection => 'Xem kết nối';

  @override
  String settingsGeoCheckedAt(String time) {
    return 'Kiểm tra gần nhất: $time';
  }

  @override
  String get settingsGeoCheckAgain => 'Kiểm tra lại';

  @override
  String get settingsPlatformMobile => 'Di động';

  @override
  String get settingsPlatformOther => 'Nền tảng khác';

  @override
  String get settingsContentLanguageFollowApp => 'Theo ngôn ngữ ứng dụng';

  @override
  String get settingsContentLanguageHint =>
      'Chọn ngôn ngữ tên vật phẩm. Lựa chọn này không đổi ngôn ngữ giao diện hoặc máy chủ Riot.';

  @override
  String settingsLanguageChanged(String language) {
    return 'Ngôn ngữ: $language.';
  }

  @override
  String get settingsAboutCreditContent => 'valorant-api.com';

  @override
  String get settingsAboutCreditContentBody =>
      'Tên, hình ảnh và thông tin về skin, đặc vụ, bản đồ và rank.';

  @override
  String get settingsAboutCreditDocs => 'Tài liệu cộng đồng';

  @override
  String get settingsAboutCreditDocsBody =>
      'Dự án techchrism/valorant-api-docs và cộng đồng nhà phát triển VALORANT.';

  @override
  String get settingsAboutCreditRiot => 'Riot Games';

  @override
  String get settingsAboutCreditRiotBody =>
      'Cửa hàng, ví, bộ sưu tập, trận đấu và xếp hạng lấy trực tiếp từ tài khoản Riot bạn đăng nhập.';

  @override
  String get settingsAboutCreditsHeader => 'NGUỒN DỮ LIỆU';

  @override
  String get settingsAboutHeader => 'THÔNG TIN';

  @override
  String get settingsAboutLegalHeader => 'PHÁP LÝ';

  @override
  String get settingsAboutRowSubtitle =>
      'Quyền riêng tư, điều khoản, bản quyền và liên hệ';

  @override
  String get settingsAboutTitle => 'Giới thiệu & pháp lý';

  @override
  String get settingsAppHeader => 'NÂNG CAO';

  @override
  String get settingsAppearanceHeader => 'GIAO DIỆN';

  @override
  String settingsBuildNumber(String build) {
    return 'Bản dựng $build';
  }

  @override
  String settingsCacheCleared(String size) {
    return 'Đã xóa $size';
  }

  @override
  String get settingsClearCache => 'Xóa dữ liệu tạm';

  @override
  String get settingsClearCacheFailed =>
      'Chưa xóa được dữ liệu tạm. Hãy thử lại.';

  @override
  String get settingsClearCacheSubtitle =>
      'Ảnh và dữ liệu đã tải về máy, kể cả báo lỗi đã ghi';

  @override
  String get settingsClearLog => 'Xóa báo lỗi đã ghi';

  @override
  String get settingsClearLogConfirm => 'Xóa báo lỗi đã ghi trên thiết bị này?';

  @override
  String get settingsExportLog => 'Gửi báo lỗi cho ValHub';

  @override
  String get settingsExportLogEmpty =>
      'Chưa có gì để gửi. Hãy dùng ứng dụng một lúc rồi thử lại.';

  @override
  String get settingsExportLogEmptyTitle => 'Chưa có gì để gửi';

  @override
  String get settingsExportLogNote =>
      'Báo lỗi không chứa mật khẩu hay dữ liệu đăng nhập Riot của bạn.';

  @override
  String get settingsExportLogSubtitle =>
      'Báo lỗi không chứa mật khẩu hay dữ liệu đăng nhập Riot của bạn.';

  @override
  String get settingsFeedback => 'Góp ý cho ValHub';

  @override
  String get settingsFeedbackSubtitle => 'Mở trang góp ý của ValHub';

  @override
  String get settingsItemLanguageEn => 'Tiếng Anh';

  @override
  String get settingsItemLanguageHint =>
      'Tên skin, đặc vụ, bản đồ… hiển thị theo ngôn ngữ này.';

  @override
  String get settingsItemLanguageLabel => 'Tên vật phẩm';

  @override
  String get settingsItemLanguagePickerTitle => 'Ngôn ngữ tên vật phẩm';

  @override
  String get settingsItemLanguageVi => 'Tiếng Việt';

  @override
  String get settingsLegalNotice => 'Thông báo pháp lý';

  @override
  String get settingsLinkOpenFailed => 'Chưa mở được liên kết. Hãy thử lại.';

  @override
  String get settingsLogCleared => 'Đã xóa báo lỗi';

  @override
  String settingsLogEntryCount(int count) {
    return '$count mục';
  }

  @override
  String settingsLogEntryShown(int shown, int total) {
    return '$shown / $total mục';
  }

  @override
  String settingsLogFileHeader(String appName, String version) {
    return '$appName $version — Báo lỗi';
  }

  @override
  String get settingsLogFilterAll => 'Tất cả';

  @override
  String get settingsLogFilterAuth => 'Đăng nhập';

  @override
  String get settingsLogFilterEmpty =>
      'Không có mục phù hợp. Hãy bỏ lọc để xem thêm.';

  @override
  String get settingsLogFilterErrors => 'Sự cố';

  @override
  String get settingsLogFilterHttp => 'Kết nối';

  @override
  String get settingsLogMore => 'Tùy chọn khác';

  @override
  String get settingsLogSearchEmpty => 'Không có mục phù hợp.';

  @override
  String get settingsLogSearchHint => 'Tìm trong báo lỗi…';

  @override
  String get settingsLogShareFailed => 'Chưa gửi được báo lỗi. Hãy thử lại.';

  @override
  String get settingsLogoPrefix => 'Val';

  @override
  String get settingsLogoSuffix => 'Hub';

  @override
  String get settingsNotifNightMarket => 'Khi Chợ Đêm mở';

  @override
  String get settingsNotifNightMarketSubtitle =>
      'Nhắc bạn lật thẻ ưu đãi Chợ Đêm';

  @override
  String get settingsNotifPermissionMissing =>
      'Ứng dụng chưa có quyền gửi thông báo.';

  @override
  String get settingsNotifStoreReset => 'Khi cửa hàng làm mới';

  @override
  String settingsNotifStoreResetSubtitle(String time) {
    return '$time hằng ngày';
  }

  @override
  String get settingsNotifWishlist => 'Khi skin trong wishlist xuất hiện';

  @override
  String get settingsNotifWishlistSubtitle =>
      'Kiểm tra cửa hàng của mọi tài khoản, kể cả khi bạn không mở ứng dụng';

  @override
  String get settingsNotificationsHeader => 'THÔNG BÁO';

  @override
  String get settingsOptionAutoOpenLiveGame => 'Tự động mở chi tiết trận';

  @override
  String get settingsOptionAutoOpenLiveGameSubtitle =>
      'Mở bảng trận hiện tại ngay khi tìm thấy trận';

  @override
  String get settingsOptionOwnPrice => 'Giá gói VP của bạn';

  @override
  String get settingsOptionOwnPriceEmpty =>
      'Chưa nhập — dùng bảng giá của khu vực nếu có';

  @override
  String settingsOptionOwnPriceValue(String vp, String price) {
    return '$vp = $price';
  }

  @override
  String get settingsOptionPlatform => 'Nền tảng';

  @override
  String get settingsOptionShowLiveScore => 'Hiện tỉ số trực tiếp';

  @override
  String get settingsOptionShowPeakRank =>
      'Hiện rank cao nhất trong chi tiết trận';

  @override
  String get settingsOptionShowPrice => 'Hiện giá quy đổi ước tính';

  @override
  String get settingsOptionShowPriceInfo => 'Cách tính giá quy đổi';

  @override
  String settingsOptionShowPriceSubtitle(String vp, String price) {
    return 'Cạnh giá VP, ví dụ $vp $price';
  }

  @override
  String get settingsOptionShowPriceUnavailable =>
      'Chưa có bảng giá đã xác minh cho khu vực của bạn — hãy nhập giá gói VP của bạn.';

  @override
  String get settingsOptionsHeader => 'TÙY CHỌN';

  @override
  String get settingsPhaseComplete => 'Đã xong';

  @override
  String get settingsPhaseInProgress => 'Đang diễn ra';

  @override
  String get settingsPhaseScheduled => 'Đã lên lịch';

  @override
  String settingsPlatformAppliesTo(String account) {
    return 'Áp dụng cho $account';
  }

  @override
  String get settingsPlatformHint =>
      'Chọn PC, PlayStation hoặc Xbox theo nơi bạn chơi để xem đúng lịch sử đấu.';

  @override
  String get settingsPlatformPickerTitle => 'Chọn nền tảng';

  @override
  String get settingsPrimingBody =>
      'Bật thông báo để biết khi cửa hàng làm mới và khi skin trong wishlist xuất hiện.';

  @override
  String get settingsPrimingEnable => 'Bật thông báo';

  @override
  String get settingsPrimingFootnote =>
      'Bạn có thể bật hoặc tắt từng loại thông báo bất cứ lúc nào trong Cài đặt.';

  @override
  String get settingsPrimingLater => 'Để sau';

  @override
  String get settingsPrimingPointNightMarket => 'Biết khi Chợ Đêm mở';

  @override
  String get settingsPrimingPointNightMarketDetail =>
      'Để kịp lật thẻ ưu đãi trước khi hết hạn';

  @override
  String get settingsPrimingPointStore => 'Nhắc khi cửa hàng hằng ngày làm mới';

  @override
  String get settingsPrimingPointStoreDetail =>
      'Nhắc sau khi cửa hàng của tài khoản làm mới';

  @override
  String get settingsPrimingPointWishlist => 'Báo khi skin bạn săn xuất hiện';

  @override
  String get settingsPrimingPointWishlistDetail =>
      'Kiểm tra cửa hàng của mọi tài khoản, kể cả khi bạn không mở ứng dụng';

  @override
  String get settingsPrimingTitle => 'Đừng bỏ lỡ skin bạn săn';

  @override
  String settingsRemovedAccount(String account) {
    return 'Đã xóa $account';
  }

  @override
  String get settingsServerStatus => 'Trạng thái máy chủ';

  @override
  String get settingsServerStatusMaintenance => 'Đang bảo trì';

  @override
  String settingsServerStatusNotices(int n) {
    return '$n thông báo';
  }

  @override
  String get settingsServerStatusSubtitle =>
      'Bảo trì và sự cố VALORANT theo máy chủ';

  @override
  String get settingsSessionLogTitle => 'Báo lỗi ValHub';

  @override
  String get settingsSeverityCritical => 'Nghiêm trọng';

  @override
  String get settingsSeverityInfo => 'Thông tin';

  @override
  String get settingsSeverityWarning => 'Cảnh báo';

  @override
  String get settingsSignedOutAll => 'Đã đăng xuất tất cả tài khoản';

  @override
  String get settingsStatusAllGood => 'Máy chủ hoạt động bình thường';

  @override
  String settingsStatusAllGoodBody(String region) {
    return 'Không có sự cố hay bảo trì nào ở máy chủ $region.';
  }

  @override
  String get settingsStatusFewerUpdates => 'Thu gọn';

  @override
  String get settingsStatusIssues => 'Riot đang xử lý sự cố';

  @override
  String settingsStatusIssuesBody(int n) {
    return 'Máy chủ này có $n thông báo sự cố.';
  }

  @override
  String get settingsStatusKindIncident => 'Sự cố';

  @override
  String get settingsStatusKindMaintenance => 'Bảo trì';

  @override
  String get settingsStatusMaintenanceNow => 'Máy chủ đang bảo trì';

  @override
  String get settingsStatusMaintenanceNowBody =>
      'Bạn có thể chưa vào được game, và ValHub có thể tạm thời chưa tải được thông tin.';

  @override
  String settingsStatusMoreUpdates(int n) {
    return 'Xem thêm $n cập nhật';
  }

  @override
  String get settingsStatusRegionPicker => 'Máy chủ';

  @override
  String get settingsStatusScheduled => 'Sắp có bảo trì';

  @override
  String settingsStatusScheduledBody(int n) {
    return '$n lịch bảo trì đã được Riot thông báo.';
  }

  @override
  String get settingsStatusSourceNote =>
      'Nguồn: trang trạng thái chính thức của Riot Games. Giờ hiển thị theo múi giờ của thiết bị.';

  @override
  String settingsStatusStarted(String when) {
    return 'Bắt đầu $when';
  }

  @override
  String settingsStatusUpdated(String when) {
    return 'Cập nhật $when';
  }

  @override
  String get settingsStatusUpdatesHeader => 'CẬP NHẬT TỪ RIOT';

  @override
  String get settingsSupportHeader => 'HỖ TRỢ';

  @override
  String settingsSwitchedTo(String account) {
    return 'Đã chuyển sang $account';
  }

  @override
  String get settingsThemeDark => 'Tối';

  @override
  String get settingsThemeLabel => 'Chủ đề';

  @override
  String get settingsThemeLight => 'Sáng';

  @override
  String get settingsThemePickerTitle => 'Chọn chủ đề';

  @override
  String get settingsThemeSystem => 'Theo hệ thống';

  @override
  String get settingsTitle => 'Cài đặt';

  @override
  String settingsVersion(String version) {
    return 'Phiên bản $version';
  }

  @override
  String get settingsWelcomeBulletProfile =>
      'Rank, lịch sử đấu, trận đang diễn ra';

  @override
  String get settingsWelcomeBulletProfileDetail => 'RR từng trận, rank đối thủ';

  @override
  String get settingsWelcomeBulletStore =>
      'Cửa hàng hằng ngày, Chợ Đêm và bundle';

  @override
  String get settingsWelcomeBulletStoreDetail =>
      'Xem giá, độ hiếm, đếm ngược làm mới';

  @override
  String get settingsWelcomeBulletWishlist => 'Wishlist & thông báo';

  @override
  String get settingsWelcomeBulletWishlistDetail =>
      'Báo khi skin bạn săn lên kệ';

  @override
  String get settingsWelcomeFootnote =>
      'Bạn đăng nhập trên trang chính thức của Riot. ValHub chỉ lưu mật khẩu khi bạn tự chọn lưu thông tin đăng nhập.';

  @override
  String get settingsWelcomeKicker => 'TRỢ THỦ VALORANT';

  @override
  String skinDetailCommunitySummary(
    String hasAverage,
    String average,
    String count,
    String votes,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasAverage, {
      'yes': '★ $average ($count đánh giá) · ',
      'other': '',
    });
    return 'Cộng đồng: $_temp0$votes lượt thích';
  }

  @override
  String get skinDetailAddToWishlist => 'Thêm vào wishlist';

  @override
  String skinDetailAvailableInStoreOf(String accounts) {
    return 'Có trong cửa hàng của: $accounts';
  }

  @override
  String skinDetailHistory(int daily, int night, String since) {
    return 'Trong cửa hàng của bạn: $daily lần ở cửa hàng hằng ngày, $night đợt Chợ Đêm. Chỉ tính dữ liệu trên thiết bị, ghi nhận từ $since.';
  }

  @override
  String get skinDetailHistoryDelete => 'Xóa lịch sử cửa hàng';

  @override
  String get skinDetailHistoryDeleteBody =>
      'Xóa tất cả ngày cửa hàng đã ghi cho tài khoản này trên thiết bị?';

  @override
  String get skinDetailInWishlist => 'Đã có trong wishlist';

  @override
  String skinDetailLevelCaption(String level, String item) {
    return '$level · $item';
  }

  @override
  String get skinDetailLocked => 'Chưa mở khóa';

  @override
  String get skinDetailMute => 'Tắt tiếng';

  @override
  String get skinDetailNotFound => 'Không tìm thấy skin này.';

  @override
  String get skinDetailOwned => 'Đã sở hữu';

  @override
  String get skinDetailPause => 'Tạm dừng';

  @override
  String get skinDetailPlay => 'Phát';

  @override
  String get skinDetailPlayVideo => 'Xem video';

  @override
  String get skinDetailRemoveFromWishlist => 'Xóa khỏi wishlist';

  @override
  String get skinDetailTitle => 'Chi tiết skin';

  @override
  String get skinDetailUnmute => 'Bật tiếng';

  @override
  String get skinDetailUpgrades => 'Nâng cấp';

  @override
  String get skinDetailVariants => 'Biến thể';

  @override
  String get skinDetailVideoError =>
      'Không phát được video. Kiểm tra mạng rồi thử lại.';

  @override
  String get socialPresenceInMatch => 'Đang đấu';

  @override
  String get socialPresenceAgentSelect => 'Đang chọn đặc vụ';

  @override
  String get socialPresenceQueue => 'Đang tìm trận';

  @override
  String get socialPresenceLobby => 'Đang ở sảnh chờ';

  @override
  String get socialPresenceCustom => 'Đang chơi tự do';

  @override
  String socialPresenceDetails(String status, String detail) {
    return '$status · $detail';
  }

  @override
  String socialPartySummary(int size, int max, String state) {
    String _temp0 = intl.Intl.selectLogic(state, {
      'open': 'Tổ đội mở',
      'other': 'Chỉ người được mời',
    });
    return '$size/$max người · $_temp0';
  }

  @override
  String get socialAccept => 'Chấp nhận';

  @override
  String get socialAcceptInGame => 'Hãy chấp nhận lời mời này trong game.';

  @override
  String socialActionFailed(String message) {
    return 'Chưa hoàn tất thao tác. $message';
  }

  @override
  String get socialAutoRefresh => 'Tự động làm mới';

  @override
  String get socialAway => 'Vắng mặt';

  @override
  String socialCancelQueue(String elapsed) {
    return 'Hủy tìm trận · $elapsed';
  }

  @override
  String get socialCancelQueueShort => 'Hủy tìm trận';

  @override
  String socialCantQueue(String queue, String reason) {
    return 'Tổ đội chưa thể vào $queue: $reason';
  }

  @override
  String get socialChangeQueue => 'Đổi hàng chờ';

  @override
  String get socialChatTitle => 'Trò chuyện';

  @override
  String get socialChatUnavailable => 'Trò chuyện đang ngoại tuyến.';

  @override
  String get socialCloseParty => 'Đóng tổ đội';

  @override
  String get socialClosedState => 'Chỉ người được mời';

  @override
  String get socialCodeInvalid => 'Mã tổ đội chỉ gồm chữ cái và chữ số.';

  @override
  String get socialConnecting => 'Đang kết nối trò chuyện…';

  @override
  String get socialCopyCode => 'Sao chép';

  @override
  String get socialCurrentQueue => 'Đang chọn';

  @override
  String get socialCustomGameLobby => 'Tổ đội đang ở sảnh Chơi tự do.';

  @override
  String get socialDecline => 'Từ chối';

  @override
  String get socialDisableCode => 'Tắt mã';

  @override
  String get socialEmptyChat => 'Chưa có tin nhắn. Hãy gửi lời chào!';

  @override
  String get socialEmptyChatTitle => 'Bắt đầu trò chuyện';

  @override
  String get socialFailedBadge => 'Chưa gửi được';

  @override
  String get socialFilterAll => 'Tất cả';

  @override
  String get socialFilterOnline => 'Trực tuyến';

  @override
  String get socialFilterUnread => 'Chưa đọc';

  @override
  String get socialFriendsPrivacyNote =>
      'Danh sách bạn bè và tin nhắn lấy trực tiếp từ Riot. ValHub không lưu chúng ở nơi nào khác.';

  @override
  String socialFriendsSummary(int total, int online) {
    return '$total bạn · $online đang trực tuyến';
  }

  @override
  String get socialFriendsTitle => 'Bạn bè & trò chuyện';

  @override
  String get socialGameNotRunningBody =>
      'Tổ đội & hàng chờ chỉ hoạt động khi VALORANT đang chạy trên máy tính hoặc console của bạn. Mở game rồi kéo xuống để làm mới.';

  @override
  String get socialGameNotRunningTitle =>
      'Mở VALORANT trên máy tính hoặc máy chơi game';

  @override
  String get socialGenerateCode => 'Tạo mã';

  @override
  String get socialHistoryFailed =>
      'Chưa tải được tin nhắn cũ. Hãy kết nối lại rồi thử lại.';

  @override
  String get socialIdleQueue => 'Sẵn sàng tìm trận';

  @override
  String get socialInMatchBanner =>
      'Bạn đang trong trận. Hàng chờ sẽ mở lại khi trận kết thúc.';

  @override
  String get socialInValorant => 'Đang trong VALORANT';

  @override
  String get socialInviteByRiotId => 'Mời bằng Riot ID';

  @override
  String get socialInviteByRiotIdHint => 'Mời cả người chưa kết bạn';

  @override
  String get socialInviteFriends => 'Mời bạn bè';

  @override
  String socialInviteFrom(String name) {
    return 'Lời mời từ $name';
  }

  @override
  String socialInviteLabel(String name) {
    return 'Mời $name';
  }

  @override
  String get socialInviteNeedsName =>
      'Chưa biết Riot ID của người này nên chưa thể mời.';

  @override
  String socialInviteSent(String name) {
    return 'Đã gửi lời mời tới $name.';
  }

  @override
  String socialInvitedLabel(String name) {
    return '$name · Đã mời';
  }

  @override
  String get socialInvitesSection => 'Lời mời';

  @override
  String get socialJoin => 'Tham gia';

  @override
  String get socialJoinConfirmBody =>
      'Bạn sẽ rời tổ đội hiện tại để vào tổ đội có mã này.';

  @override
  String get socialJoinConfirmTitle => 'Tham gia tổ đội khác?';

  @override
  String get socialJoinSection => 'Vào tổ đội khác';

  @override
  String get socialJoinWithCode => 'Nhập mã để tham gia';

  @override
  String get socialJoined => 'Đã tham gia tổ đội.';

  @override
  String socialLastOnline(String relative) {
    return 'Hoạt động $relative';
  }

  @override
  String get socialLeader => 'Trưởng nhóm';

  @override
  String socialLeaderboardTop(String position) {
    return 'Top $position';
  }

  @override
  String get socialLeaveConfirmBody =>
      'Bạn sẽ rời tổ đội hiện tại và về tổ đội riêng.';

  @override
  String get socialLeaveConfirmTitle => 'Rời tổ đội?';

  @override
  String get socialLeaveParty => 'Rời tổ đội';

  @override
  String socialLevel(int n) {
    return 'Cấp $n';
  }

  @override
  String get socialMatchFound => 'Đã tìm thấy trận!';

  @override
  String socialMembersSection(int n, int max) {
    return 'Thành viên ($n/$max)';
  }

  @override
  String get socialMessageHint => 'Nhập tin nhắn…';

  @override
  String get socialMoreActions => 'Tùy chọn khác';

  @override
  String get socialNoCode => 'Tạo mã để bạn bè vào tổ đội nhanh bằng mã.';

  @override
  String get socialNoCodeMember => 'Trưởng nhóm có thể tạo mã để mời nhanh.';

  @override
  String get socialNoFilterResults => 'Không có bạn bè nào khớp bộ lọc này.';

  @override
  String get socialNoFriends =>
      'Danh sách bạn bè Riot của bạn đang trống. Hãy kết bạn trong game.';

  @override
  String get socialNoFriendsTitle => 'Chưa có bạn bè';

  @override
  String get socialNoOnlineFriends =>
      'Chưa có bạn bè nào đang trực tuyến trong VALORANT.';

  @override
  String get socialNoSearchResults => 'Không tìm thấy bạn bè nào phù hợp.';

  @override
  String get socialNoSearchResultsTitle => 'Không tìm thấy';

  @override
  String get socialNotFriend => 'Người này không có trong danh sách bạn bè.';

  @override
  String get socialNotReady => 'Chưa sẵn sàng';

  @override
  String socialOfflineSection(int n) {
    return 'Ngoại tuyến ($n)';
  }

  @override
  String get socialOfflineStatus => 'Ngoại tuyến';

  @override
  String get socialOnlineMobile => 'Trực tuyến trên điện thoại';

  @override
  String socialOnlineSection(int n) {
    return 'Trực tuyến ($n)';
  }

  @override
  String get socialOnlineStatus => 'Trực tuyến';

  @override
  String get socialOnlyLeader =>
      'Chỉ trưởng nhóm mới có thể đổi hàng chờ và bắt đầu tìm trận.';

  @override
  String get socialOpenParty => 'Mở tổ đội';

  @override
  String get socialOpenState => 'Tổ đội mở';

  @override
  String get socialOtherGamesLeagueOfLegends => 'Liên Minh Huyền Thoại';

  @override
  String get socialOtherGamesBacon => 'Huyền Thoại Runeterra';

  @override
  String get socialOtherGamesLion => '2XKO';

  @override
  String get socialPartyCode => 'Mã tổ đội';

  @override
  String socialPartyCodeValue(String code) {
    return 'Mã tổ đội: $code';
  }

  @override
  String get socialPartyInvite => 'Lời mời vào tổ đội';

  @override
  String socialPartyOf(int size, int max) {
    return 'Tổ đội $size/$max';
  }

  @override
  String get socialPartyTitle => 'Tổ đội & hàng chờ';

  @override
  String socialPickQueueSubtitle(int size) {
    return 'Tổ đội $size người';
  }

  @override
  String get socialPickQueueTitle => 'Chọn hàng chờ';

  @override
  String socialPing(int ms) {
    return '$ms ms';
  }

  @override
  String get socialPingTooltip => 'Ping tốt nhất tới máy chủ trận đấu';

  @override
  String socialPlayingOther(String game) {
    return 'Đang chơi $game';
  }

  @override
  String socialPlayingSection(int n) {
    return 'Đang chơi ($n)';
  }

  @override
  String get socialQueueLabel => 'Hàng chờ';

  @override
  String get socialQueueLocked => 'Không thể đổi hàng chờ khi đang trong trận.';

  @override
  String socialQueueMaxParty(int max) {
    String _temp0 = intl.Intl.pluralLogic(
      max,
      locale: localeName,
      other: 'Tối đa $max người',
      one: 'Chỉ chơi một mình',
    );
    return '$_temp0';
  }

  @override
  String get socialQueueStatusUnavailable =>
      'Chưa xác minh được trạng thái game. Làm mới để sử dụng sẵn sàng và hàng chờ.';

  @override
  String get socialReady => 'Sẵn sàng';

  @override
  String socialReadyCount(int ready, int total) {
    return 'Sẵn sàng $ready/$total';
  }

  @override
  String get socialReasonAccountLevel => 'có thành viên chưa đủ cấp tài khoản';

  @override
  String get socialReasonGeneric => 'tổ đội chưa đủ điều kiện';

  @override
  String socialReasonPartyTooLarge(int max) {
    return 'tổ đội quá đông (tối đa $max người)';
  }

  @override
  String get socialReasonRankDisparity =>
      'chênh lệch rank quá lớn để đấu xếp hạng';

  @override
  String socialReasonRestricted(String time) {
    return 'tổ đội đang bị hạn chế tìm trận (còn $time)';
  }

  @override
  String get socialReconnecting => 'Mất kết nối trò chuyện. Đang kết nối lại…';

  @override
  String get socialRemoteNote =>
      'Mọi thay đổi chỉ được gửi tới Riot khi bạn bấm. ValHub không tự tìm trận hay khóa đặc vụ thay bạn.';

  @override
  String socialRemoveConfirmBody(String name) {
    return '$name sẽ bị xóa khỏi tổ đội của bạn.';
  }

  @override
  String get socialRemoveConfirmTitle => 'Xóa khỏi tổ đội?';

  @override
  String get socialRemoveMember => 'Xóa khỏi tổ đội';

  @override
  String socialRequestFrom(String name) {
    return '$name muốn vào tổ đội';
  }

  @override
  String get socialRequestsSection => 'Yêu cầu tham gia';

  @override
  String get socialRiotIdFieldHint => 'Tên#TAG';

  @override
  String get socialRiotIdInvalid =>
      'Riot ID gồm tên (3–16 ký tự), dấu # và tag (3–5 chữ hoặc số).';

  @override
  String get socialSearchHint => 'Tìm theo Riot ID…';

  @override
  String socialSearching(String elapsed) {
    return 'Đang tìm trận · $elapsed';
  }

  @override
  String get socialSend => 'Gửi';

  @override
  String get socialSendFailed =>
      'Không gửi được tin nhắn. Kiểm tra kết nối rồi thử lại.';

  @override
  String get socialSendInvite => 'Gửi lời mời';

  @override
  String get socialShareCode => 'Chia sẻ';

  @override
  String socialShareCodeText(String code) {
    return 'Vào tổ đội VALORANT của mình bằng mã: $code';
  }

  @override
  String get socialShootingRange => 'Đang ở trường bắn';

  @override
  String get socialShowEveryone => 'Xem tất cả';

  @override
  String get socialStartQueue => 'Bắt đầu tìm trận';

  @override
  String get socialSuggestionsItem0 => 'Chào bạn!';

  @override
  String get socialSuggestionsItem1 => 'Làm vài trận không?';

  @override
  String get socialSuggestionsItem2 => 'Vào tổ đội với mình nhé!';

  @override
  String socialUnread(int n) {
    return '$n tin chưa đọc';
  }

  @override
  String get socialUnready => 'Bỏ sẵn sàng';

  @override
  String get socialViewProfile => 'Xem hồ sơ';

  @override
  String get socialWaitingForConnection =>
      'Đang kết nối… Bạn có thể gửi tin khi kết nối xong.';

  @override
  String get socialYou => 'Bạn';

  @override
  String get socialPartyUnavailable =>
      'Chưa đồng bộ được tổ đội. Làm mới để thử lại.';

  @override
  String get storeAccessoryEmpty => 'Cửa hàng phụ kiện hiện không có gì.';

  @override
  String get storeAccessoryEmptyTitle => 'Chưa có phụ kiện';

  @override
  String storeAccessoryFrom(String contract) {
    return 'Từ: $contract';
  }

  @override
  String storeAccessoryRefreshIn(String t) {
    return 'Làm mới sau $t';
  }

  @override
  String storeAccessoryResetAt(String wall) {
    return 'Làm mới lúc $wall';
  }

  @override
  String get storeAddToWishlist => 'Thêm vào wishlist';

  @override
  String get storeBackToBundles => 'Xem các bundle đang bán';

  @override
  String get storeBundleBuySeparateLabel => 'Mua lẻ';

  @override
  String get storeBundleDetailTitle => 'Chi tiết bundle';

  @override
  String storeBundleEndsAt(String wall) {
    return 'Hết hạn lúc $wall';
  }

  @override
  String storeBundleEndsIn(String t) {
    return 'Còn $t';
  }

  @override
  String storeBundleItemCount(int n) {
    return '$n vật phẩm';
  }

  @override
  String get storeBundleItemFree => 'Miễn phí';

  @override
  String get storeBundleItemsTitle => 'Vật phẩm trong bundle';

  @override
  String get storeBundleNotFound =>
      'Không tìm thấy bundle này. Có thể bundle đã hết hạn.';

  @override
  String get storeBundleNotFoundTitle => 'Bundle đã hết hạn';

  @override
  String storeBundleOwnedCount(int owned, int total) {
    return 'Đã sở hữu $owned/$total vật phẩm';
  }

  @override
  String get storeBundlePriceLabel => 'Giá bundle';

  @override
  String get storeBundleSavingsLabel => 'Tiết kiệm';

  @override
  String get storeBundleWholesaleOnly => 'Chỉ bán trọn bộ, không mua lẻ.';

  @override
  String get storeBundlesEmpty => 'Hiện không có bundle nào đang mở bán.';

  @override
  String get storeBundlesEmptyTitle => 'Chưa có bundle';

  @override
  String get storeDailyEmpty => 'Hôm nay cửa hàng không có skin nào.';

  @override
  String get storeDailyEmptyTitle => 'Cửa hàng trống';

  @override
  String storeDailyResetAt(String time) {
    return 'Làm mới lúc $time hằng ngày';
  }

  @override
  String get storeDailyTotalLabel => 'Tổng';

  @override
  String get storeNightMarketEmpty => 'Hiện chưa có Chợ Đêm.';

  @override
  String get storeNightMarketEmptyTitle => 'Chợ Đêm chưa mở';

  @override
  String storeNightMarketEndsAt(String wall) {
    return 'Kết thúc lúc $wall';
  }

  @override
  String storeNightMarketEndsIn(String t) {
    return 'Kết thúc sau $t';
  }

  @override
  String get storeNightMarketNote =>
      'Ưu đãi Chợ Đêm là riêng cho tài khoản của bạn và không thể làm mới.';

  @override
  String storeNightMarketTotalSavings(String amount) {
    return 'Tiết kiệm tổng cộng $amount';
  }

  @override
  String get storeNightMarketUnrevealed => 'Chưa lật';

  @override
  String storeOfferSemantics(String name, String price) {
    return '$name, $price';
  }

  @override
  String get storeOwnedBadge => 'Đã sở hữu';

  @override
  String storeOwnedCount(int owned, int total) {
    return 'Đã sở hữu $owned/$total';
  }

  @override
  String storeQuantity(int n) {
    return '×$n';
  }

  @override
  String get storeRemoveFromWishlist => 'Xóa khỏi wishlist';

  @override
  String storeResetNotificationBody(int skinCount, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      skinCount,
      locale: localeName,
      other: 'Xem $skinCount skin mới hôm nay của $account.',
      zero: 'Xem skin mới hôm nay của $account.',
    );
    return '$_temp0';
  }

  @override
  String get storeResetNotificationTitle => 'Cửa hàng đã làm mới';

  @override
  String storeResetsIn(String t) {
    return 'Làm mới sau $t';
  }

  @override
  String get storeSegmentAccessories => 'Phụ kiện';

  @override
  String get storeSegmentBundles => 'Bundle';

  @override
  String get storeSegmentDaily => 'Hằng ngày';

  @override
  String get storeSegmentNightMarket => 'Chợ Đêm';

  @override
  String get storeShareButton => 'Chia sẻ';

  @override
  String get storeShareCardBrand => 'ValHub';

  @override
  String get storeShareCardDaily => 'Cửa hàng hôm nay';

  @override
  String get storeShareCardMark => 'V';

  @override
  String get storeShareCardNightMarket => 'Chợ Đêm';

  @override
  String get storeShareCardPriceNote =>
      'Giá quy đổi chỉ là ước tính theo gói VP.';

  @override
  String storeShareCardSaved(String vp) {
    return 'Tiết kiệm $vp';
  }

  @override
  String get storeShareCardTagline => 'Trợ thủ VALORANT của bạn';

  @override
  String storeShareCardTotal(String vp) {
    return 'Tổng $vp';
  }

  @override
  String storeShareCardUntil(String wall) {
    return 'Đến $wall';
  }

  @override
  String get storeShareCardWatermark => 'VALHUB';

  @override
  String get storeShareDailyTitle => 'Chia sẻ cửa hàng hôm nay';

  @override
  String get storeShareFailed => 'Không tạo được ảnh. Hãy thử lại.';

  @override
  String storeShareFileDaily(String stamp) {
    return 'valvn-store-$stamp.png';
  }

  @override
  String storeShareFileNightMarket(String stamp) {
    return 'valvn-night-market-$stamp.png';
  }

  @override
  String get storeShareImage => 'Chia sẻ ảnh';

  @override
  String get storeShareNightMarketTitle => 'Chia sẻ Chợ Đêm';

  @override
  String get storeSharePreparing => 'Đang tải ảnh skin…';

  @override
  String get storeShareShowPrice => 'Hiện giá quy đổi ước tính';

  @override
  String get storeShareShowPriceHint => 'Quy đổi theo gói VP có lợi nhất.';

  @override
  String get storeShareShowRiotId => 'Hiện Riot ID trên ảnh';

  @override
  String get storeShareShowRiotIdHint => 'Tắt sẵn để giữ riêng tư cho bạn.';

  @override
  String get storeShareSubjectDaily => 'Cửa hàng VALORANT hôm nay của mình';

  @override
  String get storeShareSubjectNightMarket => 'Chợ Đêm VALORANT của mình';

  @override
  String get storeShareSubtitle =>
      'Chia sẻ ảnh cửa hàng với bạn bè qua ứng dụng bạn chọn.';

  @override
  String get storeTitle => 'Cửa hàng';

  @override
  String storeWalletSemantics(String vp, String kc, String rp) {
    return 'Số dư: $vp VP, $kc KC, $rp RP';
  }

  @override
  String storeWishlistCount(int n) {
    return '$n trong wishlist';
  }

  @override
  String wishlistNotifDailyBody(
    String skin,
    String account,
    String hasTime,
    String left,
  ) {
    String _temp0 = intl.Intl.selectLogic(hasTime, {
      'yes': '$skin đang có trong cửa hàng của $account — còn $left.',
      'other': '$skin đang có trong cửa hàng của $account.',
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
      'discount': '$skin giảm $percent% còn $price ($account).',
      'price': '$skin chỉ còn $price ($account).',
      'other': '$skin đang có trong Chợ Đêm của $account.',
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
      'yes': '$skin nằm trong bundle $bundle ($account).',
      'other': '$skin nằm trong một bundle đang bán ($account).',
    });
    return '$_temp0';
  }

  @override
  String wishlistNotifSummaryBody(String names, int more, String account) {
    String _temp0 = intl.Intl.pluralLogic(
      more,
      locale: localeName,
      other: '$names và $more skin khác đang có trong cửa hàng của $account.',
      zero: '$names đang có trong cửa hàng của $account.',
    );
    return '$_temp0';
  }

  @override
  String wishlistItemAccessibility(String name, String price, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', đã có trong wishlist',
      'other': '',
    });
    return '$name, $price$_temp0';
  }

  @override
  String get wishlistAddSkins => 'Thêm skin';

  @override
  String get wishlistAddToWishlist => 'Thêm vào wishlist';

  @override
  String get wishlistAllWeapons => 'Tất cả vũ khí';

  @override
  String get wishlistBrowseCatalog => 'Xem tất cả skin';

  @override
  String wishlistCatalogCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString skin';
  }

  @override
  String get wishlistCatalogEmpty =>
      'Chưa tải được danh sách skin. Hãy làm mới để thử lại.';

  @override
  String get wishlistCatalogEmptyTitle => 'Chưa có skin';

  @override
  String wishlistCatalogInWishlist(String count) {
    return '$count trong wishlist';
  }

  @override
  String get wishlistCatalogSubtitle => 'Chạm ♡ để thêm skin vào wishlist';

  @override
  String get wishlistCatalogTitle => 'Tất cả skin';

  @override
  String get wishlistChooseWeapon => 'Chọn vũ khí';

  @override
  String get wishlistClearFilters => 'Bỏ lọc';

  @override
  String get wishlistClearSearch => 'Xóa tìm kiếm';

  @override
  String get wishlistEmpty =>
      'Wishlist trống. Chạm ♡ ở bất kỳ skin nào để thêm.';

  @override
  String get wishlistEmptyTitle => 'Chưa có skin nào';

  @override
  String wishlistEndsIn(String time) {
    return 'Kết thúc sau $time';
  }

  @override
  String get wishlistExcludedRewards => 'Không tính skin phần thưởng';

  @override
  String get wishlistFilterTiers => 'Phiên bản';

  @override
  String wishlistFiltered(int count, String value) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return 'Đang lọc: $countString skin · $value';
  }

  @override
  String get wishlistHasEstimates => 'Có giá ước tính (≈)';

  @override
  String get wishlistInWishlist => 'Đã có trong wishlist';

  @override
  String get wishlistInWishlistLabel => 'đã có trong wishlist';

  @override
  String get wishlistNoMatch => 'Không có skin phù hợp. Bỏ lọc để xem thêm.';

  @override
  String get wishlistNoMatchTitle => 'Không tìm thấy skin';

  @override
  String get wishlistNotifBundleTitle => 'Bundle mới có skin trong wishlist';

  @override
  String get wishlistNotifDailyTitle => 'Skin trong wishlist đã xuất hiện!';

  @override
  String get wishlistNotifNightMarketTitle => 'Chợ Đêm có skin bạn thích!';

  @override
  String get wishlistNotifPermissionMissing =>
      'Ứng dụng chưa có quyền gửi thông báo.';

  @override
  String wishlistNotifSummaryTitle(int count) {
    return '$count skin trong wishlist đang được bán!';
  }

  @override
  String get wishlistNotifToggle => 'Thông báo wishlist';

  @override
  String get wishlistNotifToggleSubtitle =>
      'Cho tài khoản này, kể cả khi bạn không mở ứng dụng';

  @override
  String wishlistOfAccount(String riotId) {
    return 'Wishlist của $riotId';
  }

  @override
  String wishlistOnSaleBanner(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count skin trong wishlist đang được bán!',
      one: 'Một skin trong wishlist đang được bán!',
    );
    return '$_temp0';
  }

  @override
  String get wishlistOnSaleBannerHint =>
      'Chạm vào dòng được đánh dấu để xem ưu đãi.';

  @override
  String get wishlistOpenSettings => 'Mở cài đặt';

  @override
  String get wishlistOwned => 'Đã sở hữu';

  @override
  String get wishlistRemoveAction => 'Xóa khỏi wishlist';

  @override
  String get wishlistRemoveFromWishlist => 'Xóa khỏi wishlist';

  @override
  String wishlistRemoved(String name) {
    return 'Đã xóa $name khỏi wishlist';
  }

  @override
  String get wishlistSearchHint => 'Tìm skin…';

  @override
  String wishlistSkinCount(int count) {
    final intl.NumberFormat countNumberFormat =
        intl.NumberFormat.decimalPattern(localeName);
    final String countString = countNumberFormat.format(count);

    return '$countString skin';
  }

  @override
  String get wishlistSortBy => 'Sắp xếp';

  @override
  String wishlistSortLabel(String sort) {
    return 'Sắp xếp: $sort';
  }

  @override
  String get wishlistSortName => 'Tên';

  @override
  String get wishlistSortPrice => 'Giá';

  @override
  String get wishlistSortRarity => 'Độ hiếm';

  @override
  String get wishlistSortWeapon => 'Vũ khí';

  @override
  String get wishlistStoreCheckTitle => 'Chưa kiểm tra được cửa hàng';

  @override
  String get wishlistSubtitle => 'Skin bạn đang săn';

  @override
  String get wishlistTitle => 'Wishlist';

  @override
  String get wishlistTotalValue => 'Tổng giá trị wishlist';

  @override
  String get wishlistUndo => 'Hoàn tác';

  @override
  String get wishlistViewInStore => 'Xem trong cửa hàng';

  @override
  String get wishlistWeapon => 'Vũ khí';

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
      'yes': ', trong wishlist',
      'other': '',
    });
    return '$name, $price, $tier$_temp0';
  }

  @override
  String homeTrendingAccessibility(String name, String votes, String wished) {
    String _temp0 = intl.Intl.selectLogic(wished, {
      'yes': ', trong wishlist',
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
      'gain': 'tăng',
      'other': 'giảm',
    });
    return 'Hôm nay $_temp0 $rr RR, $wins thắng, $losses thua';
  }

  @override
  String homeResultSummary(int wins, int losses, int draws, int unknown) {
    String _temp0 = intl.Intl.pluralLogic(
      draws,
      locale: localeName,
      other: ', $draws hòa',
      zero: '',
    );
    String _temp1 = intl.Intl.pluralLogic(
      unknown,
      locale: localeName,
      other: ', $unknown trận chưa rõ kết quả',
      zero: '',
    );
    return '$wins thắng – $losses thua$_temp0$_temp1';
  }

  @override
  String get homeAllHiddenBody => 'Mở Tùy chỉnh Trang chủ để hiện lại.';

  @override
  String get homeAllHiddenTitle => 'Bạn đã ẩn mọi thẻ';

  @override
  String get homeCardBattlePass => 'Battle Pass';

  @override
  String get homeCardBattlePassDesc => 'Cấp, XP cần mỗi ngày và nhiệm vụ tuần.';

  @override
  String get homeCardCommunity => 'Cộng đồng';

  @override
  String get homeCardCommunityDesc =>
      'Tìm đồng đội hợp rank và skin được yêu thích trong tuần.';

  @override
  String get homeCardFriends => 'Bạn bè đang chơi';

  @override
  String get homeCardFriendsDesc =>
      'Bạn bè đang trong trận hoặc đang tìm trận.';

  @override
  String homeCardHidden(String name) {
    return 'Đã ẩn \"$name\"';
  }

  @override
  String get homeCardLive => 'Trận hiện tại';

  @override
  String get homeCardLiveDesc =>
      'Hiện khi bạn đang tìm trận, chọn đặc vụ hoặc trong trận.';

  @override
  String get homeCardOtherAccounts => 'Tài khoản khác';

  @override
  String get homeCardOtherAccountsDesc =>
      'Trạng thái và wishlist của các tài khoản còn lại.';

  @override
  String get homeCardRank => 'Rank & phong độ';

  @override
  String get homeCardRankDesc =>
      'Rank, RR hôm nay, chuỗi trận và số trận lên rank.';

  @override
  String get homeCardServerStatus => 'Trạng thái máy chủ';

  @override
  String get homeCardServerStatusDesc => 'Chỉ hiện khi có bảo trì hoặc sự cố.';

  @override
  String get homeCardStore => 'Cửa hàng hôm nay';

  @override
  String get homeCardStoreDesc => 'Skin hằng ngày, wishlist và Chợ Đêm.';

  @override
  String get homeCustomize => 'Tùy chỉnh Trang chủ';

  @override
  String get homeCustomizeHint => 'Kéo để sắp xếp. Tắt để ẩn thẻ.';

  @override
  String get homeDot => ' · ';

  @override
  String homeFocused(String name) {
    return 'Đã chuyển đến $name';
  }

  @override
  String homeFriendSemantics(String name, String status) {
    return '$name, $status';
  }

  @override
  String get homeFriendsConsentAllow => 'Bật';

  @override
  String get homeFriendsConsentBody =>
      'Để biết bạn bè nào đang chơi, ValHub sẽ kết nối trò chuyện Riot của tài khoản đang dùng mỗi khi bạn mở Trang chủ. Bạn bè sẽ thấy bạn đang trực tuyến. Bạn có thể tắt trong Tùy chỉnh Trang chủ.';

  @override
  String get homeFriendsConsentDecline => 'Không, ẩn thẻ';

  @override
  String get homeFriendsConsentTitle => 'Xem bạn bè nào đang chơi?';

  @override
  String homeFriendsMore(int n) {
    return '+$n';
  }

  @override
  String homeFriendsPlaying(int n) {
    return '$n bạn đang chơi';
  }

  @override
  String get homeFriendsSeeAll => 'Xem tất cả';

  @override
  String get homeHideCard => 'Ẩn thẻ này';

  @override
  String homeLeaderboard(String pos) {
    return 'Hạng $pos trên bảng xếp hạng';
  }

  @override
  String homeLfgExpiresIn(String time) {
    return 'Còn $time';
  }

  @override
  String homeLfgNeeds(int n) {
    return 'Cần $n người';
  }

  @override
  String homeLfgRowSemantics(String author, String details) {
    return '$author, $details';
  }

  @override
  String get homeLfgTitle => 'Tìm đồng đội hợp rank bạn';

  @override
  String get homeLiveAllyLabel => 'Đội bạn';

  @override
  String get homeLiveEnemyLabel => 'Đội địch';

  @override
  String homeLiveQueueSemantics(String coarse) {
    return 'Đang tìm trận, đã chờ $coarse';
  }

  @override
  String homeLiveScoreSemantics(int ally, int enemy) {
    return 'Đội bạn $ally, đội địch $enemy';
  }

  @override
  String homeLossStreak(int n) {
    return 'Chuỗi $n trận thua xếp hạng';
  }

  @override
  String homeMatchesToRankUp(int n, String rank) {
    return '≈ $n trận để lên $rank';
  }

  @override
  String homeMoreActions(String name) {
    return 'Tùy chọn cho $name';
  }

  @override
  String homeNeedsLoginBody(String riotId) {
    return 'Đăng nhập lại để cập nhật cửa hàng, rank và Battle Pass của $riotId. Bạn vẫn có thể xem bản đã lưu trên thiết bị.';
  }

  @override
  String homeNightMarketBest(String pct, String name, String price) {
    return '$pct · $name · $price';
  }

  @override
  String homeNightMarketEndsIn(String time) {
    return 'Còn $time';
  }

  @override
  String get homeNightMarketNew => 'Mới';

  @override
  String get homeNightMarketTitle => 'Chợ Đêm';

  @override
  String homeNightMarketWaiting(int n) {
    return '$n ưu đãi đang chờ bạn lật';
  }

  @override
  String get homeNoRankedToday => 'Hôm nay chưa đấu xếp hạng';

  @override
  String get homeOpenLfg => 'Xem tất cả tin tìm đồng đội';

  @override
  String get homeOpenRanking => 'Xem bảng xếp hạng skin';

  @override
  String homeOtherAccountsTitle(int n) {
    return 'Tài khoản khác ($n)';
  }

  @override
  String homeOtherMore(int n) {
    return '+$n tài khoản';
  }

  @override
  String get homeOtherWishlistHit => 'Có skin trong wishlist';

  @override
  String homePreviousAct(String rank) {
    return 'Phần trước: $rank';
  }

  @override
  String get homeQuietBody => 'Kéo xuống để làm mới.';

  @override
  String get homeQuietTitle => 'Chưa có gì mới';

  @override
  String homeRankToNext(int rr) {
    return 'Còn $rr RR lên rank';
  }

  @override
  String get homeResetLayout => 'Khôi phục mặc định';

  @override
  String homeRrOnDay(String day, String value) {
    return '$day: $value';
  }

  @override
  String homeRrToday(String value) {
    return 'Hôm nay $value';
  }

  @override
  String get homeStatusDetails => 'Chi tiết';

  @override
  String homeStatusIncident(String region) {
    return 'Sự cố máy chủ · $region';
  }

  @override
  String homeStatusMaintenanceNow(String region) {
    return 'Đang bảo trì · $region';
  }

  @override
  String homeStatusMaintenanceScheduled(String region) {
    return 'Sắp bảo trì · $region';
  }

  @override
  String homeStatusMore(int n) {
    return '+$n thông báo';
  }

  @override
  String get homeStoreRefreshing => 'Đang làm mới…';

  @override
  String homeStoreResetsIn(String time) {
    return 'Làm mới sau $time';
  }

  @override
  String homeStoreTotal(String vp) {
    return 'Tổng $vp';
  }

  @override
  String homeStoreWallet(String vp) {
    return 'Ví $vp';
  }

  @override
  String homeStoreWalletCanBuy(String vp, int n) {
    return 'Ví $vp · đủ mua tối đa $n skin';
  }

  @override
  String get homeStoreWishlistHit => 'Có skin trong wishlist!';

  @override
  String homeStoreWishlistHits(int n) {
    return '$n skin trong wishlist đang bán';
  }

  @override
  String get homeTitle => 'Trang chủ';

  @override
  String get homeTrendingTitle => 'Skin được yêu thích toàn cầu';

  @override
  String homeTrendingVotes(int n) {
    return '$n lượt thích';
  }

  @override
  String get homeUndo => 'Hoàn tác';

  @override
  String homeWinStreak(int n) {
    return 'Chuỗi $n trận thắng xếp hạng';
  }

  @override
  String get homeStoreOutdated =>
      'Cửa hàng đã đổi. ValHub chưa tải được cửa hàng mới.';

  @override
  String get communityErrorConsent =>
      'Hãy đồng ý chia sẻ Riot ID với Cộng đồng để tiếp tục.';

  @override
  String get communityErrorForbidden =>
      'Bạn chưa thể thực hiện việc này. Hãy xem Tiêu chuẩn cộng đồng hoặc liên hệ ValHub.';

  @override
  String get communityErrorGeneric => 'Có gì đó trục trặc. Hãy thử lại.';

  @override
  String get communityErrorImageTooLarge =>
      'Ảnh quá lớn (tối đa 2 MB). Hãy chọn ảnh khác.';

  @override
  String get communityErrorImageType => 'Hãy chọn ảnh JPEG, PNG hoặc WebP.';

  @override
  String get communityErrorInvalid =>
      'Nội dung chưa được chấp nhận. Hãy kiểm tra lại rồi thử lại.';

  @override
  String get communityErrorNetwork =>
      'Không kết nối được Cộng đồng ValHub. Kiểm tra mạng rồi thử lại.';

  @override
  String get communityErrorNotFound => 'Nội dung này không còn tồn tại.';

  @override
  String get communityErrorPickImage =>
      'Chưa mở được thư viện ảnh. Hãy thử lại.';

  @override
  String get communityErrorRateLimited =>
      'Cộng đồng đang nhận quá nhiều yêu cầu. Hãy thử lại sau ít phút.';

  @override
  String communityErrorRateLimitedIn(String duration) {
    return 'Cộng đồng đang nhận quá nhiều yêu cầu. Hãy thử lại sau $duration.';
  }

  @override
  String get communityErrorRiotRejected =>
      'Riot chưa xác minh được tài khoản của bạn. Hãy đăng nhập lại tài khoản Riot rồi thử lại.';

  @override
  String get communityErrorRiotUnavailable =>
      'Riot đang gặp sự cố. Hãy thử lại sau ít phút.';

  @override
  String communityErrorRiotUnavailableIn(String duration) {
    return 'Riot đang gặp sự cố. Hãy thử lại sau $duration.';
  }

  @override
  String get communityErrorServer =>
      'Cộng đồng ValHub đang gặp sự cố. Hãy thử lại sau ít phút.';

  @override
  String get communityErrorStorageFull =>
      'Kho ảnh của Cộng đồng đã đầy. Bạn vẫn đăng bài được, nhưng chưa thể kèm ảnh. Hãy thử lại sau.';

  @override
  String get communityErrorTimeout =>
      'Cộng đồng ValHub phản hồi quá lâu. Hãy thử lại.';

  @override
  String get communityErrorTitle => 'Chưa hoàn tất';

  @override
  String get communityErrorUnauthorized =>
      'Kết nối Cộng đồng đã hết hạn. Hãy thử lại.';

  @override
  String get communityErrorImageQuota =>
      'Bạn đã dùng hết dung lượng ảnh. Hãy xóa bớt bài viết có ảnh rồi thử lại.';

  @override
  String get smokePlain => 'Kiểm tra sinh mã';

  @override
  String smokeGreeting(String name) {
    return 'Xin chào, $name!';
  }

  @override
  String smokeCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mục',
    );
    return '$_temp0';
  }
}
