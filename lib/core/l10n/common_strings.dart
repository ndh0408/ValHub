/// Common Vietnamese UI strings shared by every feature (VF §8.0, §8.1, §8.13).
///
/// Feature-specific copy lives in `lib/features/<f>/<f>_strings.dart`.
abstract final class CommonStrings {
  static const appName = 'ValVN';
  static const tagline = 'Trợ thủ Valorant của bạn';

  // Navigation (VF §8.1)
  static const tabStore = 'Cửa hàng';
  static const tabBattlePass = 'Battle Pass';
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
  static const sortPriceHigh = 'Giá cao → thấp';
  static const sortPriceLow = 'Giá thấp → cao';
  static const sortNewest = 'Mới nhất';

  // States
  static const loading = 'Đang tải…';
  static const pullToRefresh = 'Kéo để làm mới';
  static const noData = 'Không có dữ liệu';
  static const emptyGeneric = 'Chưa có dữ liệu.';
  static const copied = 'Đã sao chép!';
  static const featureInProgress = 'Tính năng đang được phát triển.';
  static const unknownItem = 'Vật phẩm không xác định';
  static const estimatePrefix = '≈';
  static const dash = '–';

  /// "Cập nhật lúc 14:05" (the time part is already formatted).
  static String updatedAt(String time) => 'Cập nhật lúc $time';

  /// "Đang ngoại tuyến — hiển thị dữ liệu đã lưu (14:05)."
  static String offlineCached(String time) =>
      'Đang ngoại tuyến — hiển thị dữ liệu đã lưu ($time).';

  // Errors (VF §8.13, riot-auth §3.5)
  static const errorGeneric = 'Đã xảy ra lỗi. Vui lòng thử lại.';
  static const errorTimeout =
      'Riot phản hồi quá lâu. Kiểm tra kết nối rồi thử lại.';
  static const errorNetwork = 'Không thể kết nối. Kiểm tra mạng rồi thử lại.';
  static const errorTransient =
      'Máy chủ Riot đang bận. Vui lòng thử lại sau ít phút.';
  static String errorTransientRetryIn(String duration) =>
      'Máy chủ Riot đang bận. Thử lại sau $duration.';
  static const errorMaintenance =
      'Máy chủ VALORANT đang bảo trì. Vui lòng thử lại sau.';
  static const errorNeedsLogin =
      'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
  static const errorNeedsLoginTitle = 'Cần đăng nhập lại';
  static const errorNotFound = 'Không tìm thấy dữ liệu.';
  static String errorApi(int status) =>
      'Riot trả về lỗi ($status). Vui lòng thử lại.';
  static const errorContentUnavailable =
      'Không tải được dữ liệu vật phẩm. Kiểm tra mạng rồi thử lại.';
  static const errorNoAccount = 'Chưa có tài khoản nào được đăng nhập.';
  static const pageNotFound = 'Không tìm thấy trang này.';
  static const goHome = 'Về trang chính';

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

  // Legal (VF §8.13)
  static const riotDisclaimer =
      'ValVN không được Riot Games xác nhận và không phản ánh quan điểm của '
      'Riot Games hay bất kỳ ai tham gia sản xuất hoặc quản lý các sản phẩm '
      'của Riot Games. Riot Games và mọi tài sản liên quan là thương hiệu hoặc '
      'thương hiệu đã đăng ký của Riot Games, Inc.';
}
