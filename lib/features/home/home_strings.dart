/// Vietnamese strings of the Home ("Trang chủ") dashboard (docs/design/HOME.md
/// §10). Every message with a count or a value is a function, ready for the
/// plural-aware i18n system; numbers and times arrive already formatted.
abstract final class HomeStrings {
  static const title = 'Trang chủ';
  static const customize = 'Tùy chỉnh Trang chủ';
  static const customizeHint = 'Kéo để sắp xếp. Tắt để ẩn thẻ.';
  static const resetLayout = 'Khôi phục mặc định';
  static const hideCard = 'Ẩn thẻ này';

  /// "Đã ẩn "Cửa hàng hôm nay"".
  static String cardHidden(String name) => 'Đã ẩn "$name"';
  static const undo = 'Hoàn tác';

  /// Tooltip / label of the ⋯ button of a card.
  static String moreActions(String name) => 'Tùy chọn cho $name';
  static const allHiddenTitle = 'Bạn đã ẩn mọi thẻ';
  static const allHiddenBody = 'Mở Tùy chỉnh Trang chủ để hiện lại.';
  static const quietTitle = 'Chưa có gì mới';
  static const quietBody = 'Kéo xuống để làm mới.';

  /// Body of the "sign in again" banner.
  static String needsLoginBody(String riotId) =>
      'Phiên của $riotId đã hết hạn. Đăng nhập lại để xem cửa hàng, rank và '
      'Battle Pass.';

  /// Announced after a deep link scrolled to a card.
  static String focused(String name) => 'Đã chuyển đến $name';

  // Card catalogue (titles + one-line descriptions for "Tùy chỉnh")
  static const cardLive = 'Trận hiện tại';
  static const cardLiveDesc =
      'Hiện khi bạn đang tìm trận, chọn đặc vụ hoặc trong trận.';
  static const cardStore = 'Cửa hàng hôm nay';
  static const cardStoreDesc = 'Skin hằng ngày, wishlist và Chợ Đêm.';
  static const cardRank = 'Rank & phong độ';
  static const cardRankDesc =
      'Rank, RR hôm nay, chuỗi trận và số trận lên rank.';
  static const cardBattlePass = 'Battle Pass';
  static const cardBattlePassDesc = 'Cấp, XP cần mỗi ngày và nhiệm vụ tuần.';
  static const cardFriends = 'Bạn bè đang chơi';
  static const cardFriendsDesc = 'Bạn bè đang trong trận hoặc đang tìm trận.';
  static const cardCommunity = 'Cộng đồng';
  static const cardCommunityDesc =
      'Tìm đồng đội hợp rank và skin hot trong tuần.';
  static const cardOtherAccounts = 'Tài khoản khác';
  static const cardOtherAccountsDesc =
      'Trạng thái và wishlist của các tài khoản còn lại.';
  static const cardServerStatus = 'Trạng thái máy chủ';
  static const cardServerStatusDesc = 'Chỉ hiện khi có bảo trì hoặc sự cố.';

  // Live card
  static String liveScoreSemantics(int ally, int enemy) =>
      'Đội bạn $ally, đội địch $enemy';
  static const liveAllyLabel = 'Đội bạn';
  static const liveEnemyLabel = 'Đội địch';

  /// Coarse, static value read by screen readers instead of a ticking timer.
  static String liveQueueSemantics(String coarse) =>
      'Đang tìm trận, đã chờ $coarse';

  // Store card
  static String storeResetsIn(String time) => 'Làm mới sau $time';
  static const storeRefreshing = 'Đang làm mới…';
  static const storeWishlistHit = 'Có skin trong wishlist!';
  static String storeWishlistHits(int n) => '$n skin trong wishlist đang bán';
  static String storeTotal(String vp) => 'Tổng $vp';
  static String storeWallet(String vp, int affordable) =>
      'Ví $vp · đủ mua $affordable skin';
  static const nightMarketTitle = 'Chợ Đêm';
  static String nightMarketWaiting(int n) => '$n ưu đãi đang chờ bạn lật';
  static String nightMarketBest(String pct, String name, String price) =>
      '$pct · $name · $price';
  static const nightMarketNew = 'Mới';
  static String nightMarketEndsIn(String time) => 'Còn $time';
  static String skinTileSemantics(
    String name,
    String price,
    String tier,
    bool wished,
  ) => '$name, $price, $tier${wished ? ', trong wishlist' : ''}';
  static const storeWishlistIn = 'trong';

  // Rank card
  static String rankToNext(int rr) => 'Còn $rr RR lên rank';
  static String rrToday(String value) => 'Hôm nay $value';
  static String rrOnDay(String day, String value) => '$day: $value';
  static String rrTodaySemantics(int net, int wins, int losses) =>
      'Hôm nay ${net >= 0 ? 'tăng' : 'giảm'} ${net.abs()} RR, $wins thắng, '
      '$losses thua';
  static String winsLosses(int w, int l, int d) =>
      d > 0 ? '$w thắng – $l thua, $d hòa' : '$w thắng – $l thua';
  static const noRankedToday = 'Hôm nay chưa đấu xếp hạng';
  static String winStreak(int n) => 'Chuỗi $n trận thắng';
  static String lossStreak(int n) => 'Chuỗi $n trận thua';
  static String matchesToRankUp(int n, String rank) => '≈ $n trận để lên $rank';
  static String previousAct(String rank) => 'Phần trước: $rank';
  static String leaderboard(String pos) => 'Hạng $pos bảng xếp hạng';

  // Friends card
  static String friendsPlaying(int n) => '$n bạn đang chơi';
  static const friendsConsentTitle = 'Xem bạn bè nào đang chơi?';
  static const friendsConsentBody =
      'ValVN sẽ kết nối trò chuyện Riot của tài khoản đang dùng khi bạn mở '
      'Trang chủ. Bạn bè có thể thấy bạn đang trực tuyến. Bạn có thể tắt '
      'trong Tùy chỉnh Trang chủ.';
  static const friendsConsentAllow = 'Bật';
  static const friendsConsentDecline = 'Không, ẩn thẻ';
  static const friendsSeeAll = 'Xem tất cả';
  static String friendSemantics(String name, String status) => '$name, $status';
  static String friendsMore(int n) => '+$n';

  // Community card
  static const lfgTitle = 'Tìm đồng đội hợp rank bạn';
  static String lfgNeeds(int n) => 'Cần $n người';
  static const trendingTitle = 'Skin hot tuần này';
  static String trendingVotes(int n) => '$n lượt thích';
  static const openLfg = 'Xem tất cả tin tìm đồng đội';
  static const openRanking = 'Xem bảng xếp hạng skin';
  static String lfgRowSemantics(String author, String details) =>
      '$author, $details';
  static String lfgExpiresIn(String time) => 'Còn $time';

  // Other accounts card
  static String otherAccountsTitle(int n) => 'Tài khoản khác ($n)';
  static const otherWishlistHit = 'Có skin wishlist';
  static String otherMore(int n) => '+$n tài khoản';

  // Server status card
  static String statusMaintenanceNow(String region) => 'Đang bảo trì · $region';
  static String statusMaintenanceScheduled(String region) =>
      'Sắp bảo trì · $region';
  static String statusIncident(String region) => 'Sự cố máy chủ · $region';
  static String statusMore(int n) => '+$n thông báo';
  static const statusDetails = 'Chi tiết';

  // Shared card bits
  static const dot = ' · ';
}
