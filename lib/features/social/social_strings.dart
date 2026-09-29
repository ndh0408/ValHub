/// Vietnamese strings of the party & social feature (VF §6.7, §8.11,
/// SUMMARY §9.9).
abstract final class SocialStrings {
  static const partyTitle = 'Tổ đội & hàng chờ';
  static const friendsTitle = 'Bạn bè & trò chuyện';
  static const chatTitle = 'Trò chuyện';

  // ------------------------------------------------------------ friends
  static const searchHint = 'Tìm theo Riot ID…';
  static const clearSearch = 'Xóa tìm kiếm';
  static String onlineSection(int n) => 'Trực tuyến ($n)';
  static String offlineSection(int n) => 'Ngoại tuyến ($n)';
  static const noFriends =
      'Danh sách bạn bè Riot của bạn đang trống. Hãy kết bạn trong game.';
  static const noSearchResults = 'Không tìm thấy bạn bè nào phù hợp.';
  static String unread(int n) => '$n tin chưa đọc';
  static String unreadBadge(int n) => n > 99 ? '99+' : '$n';
  static const connecting = 'Đang kết nối trò chuyện…';
  static const reconnecting = 'Mất kết nối trò chuyện. Đang kết nối lại…';
  static const chatUnavailable = 'Trò chuyện đang ngoại tuyến.';
  static const friendsPrivacyNote =
      'Danh sách bạn bè và tin nhắn chỉ được tải trực tiếp từ Riot, không lưu '
      'trên máy chủ nào khác.';

  // Status lines (SUMMARY §9.9, VF S60)
  static String inMatch(String? map, {int? ally, int? enemy}) {
    final parts = ['Đang đấu', ?map];
    if (ally != null && enemy != null) parts.add('$ally – $enemy');
    return parts.join(' · ');
  }

  static String agentSelect(String? map) =>
      map == null ? 'Đang chọn đặc vụ' : 'Đang chọn đặc vụ · $map';
  static String inQueue(String? queue) =>
      queue == null ? 'Đang tìm trận' : 'Đang tìm trận · $queue';
  static String inLobby({int? partySize, int? maxPartySize}) =>
      (partySize != null && partySize > 1)
      ? 'Đang ở sảnh chờ · Tổ đội $partySize/${maxPartySize ?? 5}'
      : 'Đang ở sảnh chờ';
  static const shootingRange = 'Đang ở trường bắn';
  static String customGame(String? map) =>
      map == null ? 'Đang chơi tự do' : 'Đang chơi tự do · $map';
  static const inValorant = 'Đang trong VALORANT';
  static const away = 'Vắng mặt';
  static const onlineStatus = 'Trực tuyến';
  static const onlineMobile = 'Trực tuyến trên điện thoại';
  static String playingOther(String game) => 'Đang chơi $game';
  static const offlineStatus = 'Ngoại tuyến';
  static String lastOnline(String relative) => 'Hoạt động $relative';

  /// Other Riot games by `<games>` element name.
  static const otherGames = <String, String>{
    'league_of_legends': 'Liên Minh Huyền Thoại',
    'bacon': 'Huyền Thoại Runeterra',
    'lion': '2XKO',
  };

  // ---------------------------------------------------------------- chat
  static const messageHint = 'Nhập tin nhắn…';
  static const send = 'Gửi';
  static const emptyChat = 'Chưa có tin nhắn. Hãy gửi lời chào!';
  static const viewProfile = 'Xem hồ sơ';
  static const sendFailed =
      'Không gửi được tin nhắn. Kiểm tra kết nối rồi thử lại.';
  static const historyFailed = 'Không tải được lịch sử trò chuyện.';
  static const waitingForConnection =
      'Đang kết nối… Bạn có thể gửi tin khi kết nối xong.';
  static const notFriend = 'Người này không có trong danh sách bạn bè.';
  static const failedBadge = 'Chưa gửi được';

  // --------------------------------------------------------------- party
  static const gameNotRunningTitle = 'Hãy mở Valorant trên máy tính/console';
  static const gameNotRunningBody =
      'Tổ đội & hàng chờ chỉ hoạt động khi VALORANT đang chạy trên máy tính '
      'hoặc console của bạn. Mở game rồi kéo xuống để làm mới.';
  static const autoRefresh = 'Tự động làm mới';
  static const queueSection = 'Hàng chờ';
  static String membersSection(int n, int max) => 'Thành viên ($n/$max)';
  static const leader = 'Trưởng nhóm';
  static const you = 'Bạn';
  static const youTag = '(bạn)';
  static const ready = 'Sẵn sàng';
  static const notReady = 'Chưa sẵn sàng';
  static const unready = 'Bỏ sẵn sàng';
  static const startQueue = 'Bắt đầu tìm trận';
  static String cancelQueue(String elapsed) => 'Hủy tìm trận · $elapsed';
  static const cancelQueueShort = 'Hủy tìm trận';
  static String searching(String elapsed) => 'Đang tìm trận · $elapsed';
  static const matchFound = 'Đã tìm thấy trận!';
  static const customGameLobby = 'Tổ đội đang ở phòng chơi tự do.';
  static const onlyLeaderQueue = 'Chỉ trưởng nhóm mới có thể bắt đầu tìm trận.';
  static const onlyLeaderChangeQueue =
      'Chỉ trưởng nhóm mới có thể đổi hàng chờ.';
  static const queueLocked = 'Không thể đổi hàng chờ khi đang trong trận.';
  static const inMatchBanner =
      'Bạn đang trong trận. Hàng chờ sẽ mở lại khi trận kết thúc.';
  static const levelShort = 'Cấp';
  static String level(int n) => 'Cấp $n';

  /// "Tổ đội chưa thể vào Thi đấu xếp hạng: {reason}" (VF §8.11).
  static String cantQueue(String queue, String reason) =>
      'Tổ đội chưa thể vào $queue: $reason';
  static const reasonRankDisparity = 'chênh lệch rank quá lớn để đấu xếp hạng';
  static String reasonPartyTooLarge(int max) =>
      'tổ đội quá đông (tối đa $max người)';
  static const reasonAccountLevel = 'có thành viên chưa đủ cấp tài khoản';
  static String reasonRestricted(String time) =>
      'tổ đội đang bị hạn chế tìm trận (còn $time)';
  static const reasonGeneric = 'tổ đội chưa đủ điều kiện';

  /// Upper-cases the first letter ("chênh lệch…" → "Chênh lệch…").
  static String sentence(String s) =>
      s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';

  static const inviteFriends = 'Mời bạn bè';
  static const invited = 'Đã mời';
  static const inParty = 'Trong tổ đội';
  static const noOnlineFriends =
      'Chưa có bạn bè nào đang trực tuyến trong VALORANT.';
  static String inviteSent(String name) => 'Đã gửi lời mời tới $name.';
  static const inviteNeedsName =
      'Chưa biết Riot ID của người này nên chưa thể mời.';
  static String inviteLabel(String name) => 'Mời $name';
  static String invitedLabel(String name) => '$name · $invited';

  static const partyCode = 'Mã tổ đội';
  static String partyCodeValue(String code) => 'Mã tổ đội: $code';
  static const generateCode = 'Tạo mã';
  static const copyCode = 'Sao chép';
  static const disableCode = 'Tắt mã';
  static const noCode = 'Tạo mã để bạn bè tham gia nhanh bằng mã.';
  static const codeCopied = 'Đã sao chép mã tổ đội!';
  static const joinWithCode = 'Nhập mã để tham gia';
  static const join = 'Tham gia';
  static const joined = 'Đã tham gia tổ đội.';
  static const codeInvalid = 'Mã tổ đội chỉ gồm chữ cái và chữ số.';
  static const joinConfirmTitle = 'Tham gia tổ đội khác?';
  static const joinConfirmBody =
      'Bạn sẽ rời tổ đội hiện tại để vào tổ đội có mã này.';

  static const invitesSection = 'Lời mời';
  static String inviteFrom(String name) => 'Lời mời từ $name';
  static const partyInvite = 'Lời mời vào tổ đội';
  static const accept = 'Chấp nhận';
  static const decline = 'Từ chối';
  static const acceptInGame = 'Hãy chấp nhận lời mời này trong game.';
  static const requestsSection = 'Yêu cầu tham gia';
  static String requestFrom(String name) => '$name muốn vào tổ đội';

  static const removeMember = 'Xóa khỏi tổ đội';
  static const removeConfirmTitle = 'Xóa khỏi tổ đội?';
  static String removeConfirmBody(String name) =>
      '$name sẽ bị xóa khỏi tổ đội của bạn.';
  static const leaveParty = 'Rời tổ đội';
  static const leaveConfirmTitle = 'Rời tổ đội?';
  static const leaveConfirmBody =
      'Bạn sẽ rời tổ đội hiện tại và về tổ đội riêng.';
  static const openParty = 'Mở tổ đội';
  static const closeParty = 'Đóng tổ đội';
  static const moreActions = 'Tùy chọn khác';

  static String actionFailed(String message) => 'Không thể thực hiện. $message';

  /// Platform labels of party members.
  static String platform(String? type) => switch (type?.toLowerCase()) {
    'playstation' || 'ps5' || 'ps' => 'PlayStation',
    'xbox' || 'xbone' || 'xsx' => 'Xbox',
    _ => 'PC',
  };
}
