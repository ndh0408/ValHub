/// Common Vietnamese UI strings shared by every feature (VF §8.0, §8.1, §8.13).
///
/// Feature-specific copy lives in `lib/features/<f>/<f>_strings.dart`.
abstract final class CommonStrings {
  static const appName = 'VanHub';
  static const tagline = 'Trợ thủ VALORANT của bạn';

  // Navigation (VF §8.1)
  static const tabHome = 'Trang chủ';
  static const tabStore = 'Cửa hàng';
  static const tabBattlePass = 'Battle Pass';
  static const tabCommunity = 'Cộng đồng';
  static const tabCollection = 'Bộ sưu tập';
  static const tabProfile = 'Hồ sơ';
  static const tabSettings = 'Cài đặt';

  // Actions
  static const retry = 'Thử lại';
  static const cancel = 'Hủy';
  static const ok = 'OK';
  static const close = 'Đóng';
  static const done = 'Xong';
  static const back = 'Quay lại';
  static const save = 'Lưu';
  static const delete = 'Xóa';
  static const confirm = 'Xác nhận';
  static const copy = 'Sao chép';
  static const share = 'Chia sẻ';
  static const refresh = 'Làm mới';
  static const search = 'Tìm kiếm…';
  static const seeAll = 'Xem tất cả';
  static const loadMore = 'Tải thêm';
  static const openSettings = 'Mở cài đặt';
  static const signInAgain = 'Đăng nhập lại';
  static const clearSearch = 'Xóa tìm kiếm';
  static const clearFilters = 'Bỏ lọc';
  static const filter = 'Lọc';
  static const sort = 'Sắp xếp';

  /// "Sắp xếp: Độ hiếm" (sort button label).
  static String sortBy(String option) => 'Sắp xếp: $option';

  // Sort options shared by the skin / item lists
  static const sortRarity = 'Độ hiếm';
  static const sortName = 'Tên A–Z';
  static const sortWeapon = 'Vũ khí';
  static const sortPriceHigh = 'Giá giảm dần';
  static const sortPriceLow = 'Giá tăng dần';
  static const sortNewest = 'Mới nhất';

  // States
  static const loading = 'Đang tải…';
  static const pullToRefresh = 'Kéo để làm mới';
  static const noData = 'Chưa có gì để xem';
  static const emptyGeneric = 'Chưa có gì ở đây.';
  static const copied = 'Đã sao chép';
  static const unknownItem = 'Vật phẩm chưa rõ tên';
  static const estimatePrefix = '≈';
  static const dash = '–';

  /// "Cập nhật lúc 14:05" (the time part is already formatted).
  static String updatedAt(String time) => 'Cập nhật lúc $time';

  /// "Không có mạng — đang hiển thị bản đã lưu (14:05)."
  static String offlineCached(String time) =>
      'Không có mạng — đang hiển thị bản đã lưu ($time).';

  // Errors (VF §8.13, riot-auth §3.5): what happened + what to do, never a
  // status code (docs/design/VOICE.md §5.1).
  static const errorUnsupportedRegion =
      'Chưa xác định được khu vực Riot. Hãy chọn khu vực trong Cài đặt.';
  static const errorGeneric = 'Có gì đó trục trặc. Hãy thử lại.';
  static const errorTimeout =
      'Riot phản hồi quá lâu. Kiểm tra kết nối rồi thử lại.';
  static const errorNetwork =
      'Không kết nối được mạng. Kiểm tra Wi-Fi hoặc dữ liệu di động rồi thử lại.';
  static const errorTransient = 'Riot đang bận. Hãy thử lại sau ít phút.';
  static String errorTransientRetryIn(String duration) =>
      'Riot đang bận. Hãy thử lại sau $duration.';
  static const errorMaintenance =
      'Máy chủ VALORANT đang bảo trì. Hãy quay lại sau.';
  static const errorNeedsLogin =
      'Đăng nhập Riot của bạn đã hết hạn. Hãy đăng nhập lại để tiếp tục.';
  static const errorNeedsLoginTitle = 'Cần đăng nhập lại';
  static const errorNotFound = 'Không tìm thấy nội dung này.';

  /// [status] is deliberately not shown to the player; it stays in the
  /// session log.
  static String errorApi(int status) =>
      'Riot đang gặp trục trặc. Hãy thử lại sau ít phút.';
  static const errorContentUnavailable =
      'Không tải được thông tin skin, đặc vụ và bản đồ. Kiểm tra mạng rồi thử '
      'lại.';
  static const errorNoAccount = 'Bạn chưa đăng nhập tài khoản nào.';
  static const pageNotFound = 'Không tìm thấy màn hình này.';
  static const goHome = 'Về Trang chủ';

  // Maintenance banner
  static const maintenanceTitle = 'Bảo trì máy chủ';
  static const incidentTitle = 'Sự cố máy chủ';

  // Time (VF §8.0 rule 7)
  static const justNow = 'vừa xong';
  static const yesterday = 'hôm qua';
  static const today = 'Hôm nay';
  static const yesterdayTitle = 'Hôm qua';
  static String minutesAgo(int n) => '$n phút trước';
  static String hoursAgo(int n) => '$n giờ trước';
  static String daysAgo(int n) => '$n ngày trước';
  static String days(int n) => '$n ngày';
  static String hours(int n) => '$n giờ';
  static String minutes(int n) => '$n phút';
  static String seconds(int n) => '$n giây';

  static const tomorrow = 'ngày mai';
  static const todayLower = 'hôm nay';
  static const daily = 'hằng ngày';

  /// "07:00 hôm nay" / "07:00 ngày mai" / "23:59 thứ Hai 06/10".
  static String wallTime(String time, String day) => '$time $day';

  /// Monday … Sunday, indexed by `DateTime.weekday - 1`.
  static const weekdays = <String>[
    'Thứ Hai',
    'Thứ Ba',
    'Thứ Tư',
    'Thứ Năm',
    'Thứ Sáu',
    'Thứ Bảy',
    'Chủ Nhật',
  ];

  // Local price estimate next to VP prices (VanHub extra)
  static const priceEstimateTitle = 'Giá quy đổi ước tính';
  static const priceEstimateTooltip = 'Giá ước tính — chạm để xem cách tính';
  static const priceEstimateBody =
      'Số tiền “≈ …” cạnh giá VP là ước tính, quy đổi theo gói VP có lợi '
      'nhất. Bạn trả bằng VP trong game; số tiền thật tùy gói nạp, kênh '
      'thanh toán, thuế và khuyến mãi lúc bạn mua.';
  static String priceBestPack(String vp, String price) =>
      'Gói có lợi nhất: $vp = $price';

  /// "Bảng giá chính thức ở khu vực VN" (ISO country code).
  static String priceSourceOfficial(String country) =>
      'Theo bảng giá gói VP ở khu vực $country';
  static const priceSourceUser = 'Theo giá gói VP do bạn nhập';
  static String priceSource(String url) => 'Xem nguồn bảng giá';
  static String priceUpdated(String date) => 'Cập nhật bảng giá: $date';
  static const pricePacksTitle = 'Các gói VP';
  static const priceOpenSource = 'Mở trang nguồn';
  static const priceEnterOwn = 'Nhập giá gói VP của bạn';
  static const priceEditOwn = 'Sửa giá bạn đã nhập';
  static const priceHide = 'Ẩn giá quy đổi';
  static const priceHidden = 'Đã ẩn giá quy đổi. Bật lại trong Cài đặt.';
  static const priceUnavailable =
      'Chưa có bảng giá đã xác minh cho khu vực của bạn. Nhập giá của một gói '
      'VP bạn từng mua để xem giá quy đổi ước tính.';

  // "Giá gói VP của bạn" editor
  static const priceOverrideTitle = 'Giá gói VP của bạn';
  static const priceOverrideBody =
      'Nhập số tiền bạn thực trả cho một gói VP (xem trong cửa hàng của game '
      'hoặc hóa đơn). VanHub dùng giá này để ước tính giá quy đổi cho mọi món '
      'đồ; giá chỉ lưu trên thiết bị này.';
  static const priceOverrideCurrency = 'Mã tiền tệ';
  static const priceOverrideCurrencyHint = 'Ví dụ: VND, USD, EUR, JPY';
  static const priceOverrideVp = 'Số VP của gói';
  static const priceOverridePrice = 'Giá gói';
  static const priceOverrideSave = 'Lưu giá';
  static const priceOverrideRemove = 'Xóa giá đã nhập';
  static const priceOverrideInvalidCurrency =
      'Nhập mã tiền tệ gồm 3 chữ cái, ví dụ VND hoặc USD.';
  static const priceOverrideInvalidNumber = 'Nhập một số lớn hơn 0.';
  static const priceOverrideSaved = 'Đã lưu giá gói VP của bạn.';
  static const priceOverrideRemoved = 'Đã xóa giá bạn nhập.';
  static String priceOverrideExample(String vp, String price) =>
      'Ví dụ ước tính: $vp ≈ $price';

  // Legal (VF §8.13)
  static const riotDisclaimer =
      'VanHub không được Riot Games xác nhận và không phản ánh quan điểm của '
      'Riot Games hay bất kỳ ai tham gia sản xuất hoặc quản lý các sản phẩm '
      'của Riot Games. Riot Games và mọi tài sản liên quan là thương hiệu hoặc '
      'thương hiệu đã đăng ký của Riot Games, Inc.';
}
