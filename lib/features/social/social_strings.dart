/// Vietnamese strings of the party & social feature (VF §6.7, §8.11,
/// SUMMARY §9.9).
abstract final class SocialStrings {
  static const partyTitle = 'Tổ đội & hàng chờ';
  static const friendsTitle = 'Bạn bè & trò chuyện';
  static const chatTitle = 'Trò chuyện';

  // ------------------------------------------------------------ friends
  static const searchHint = 'Tìm theo Riot ID…';

  /// "24 bạn · 5 đang trực tuyến" (under the large title).
  static String friendsSummary(int total, int online) =>
      '$total bạn · $online đang trực tuyến';
  static String onlineSection(int n) => 'Trực tuyến ($n)';
  static String offlineSection(int n) => 'Ngoại tuyến ($n)';
  static String playingSection(int n) => 'Đang chơi ($n)';
  static const filterAll = 'Tất cả';
  static const filterOnline = 'Trực tuyến';
  static const filterUnread = 'Chưa đọc';
  static const noFriendsTitle = 'Chưa có bạn bè';
  static const noFilterResults = 'Không có bạn bè nào khớp bộ lọc này.';
  static const noFriends =
      'Danh sách bạn bè Riot của bạn đang trống. Hãy kết bạn trong game.';
  static const noSearchResults = 'Không tìm thấy bạn bè nào phù hợp.';
  static const noSearchResultsTitle = 'Không tìm thấy';
  static const showEveryone = 'Xem tất cả';
  static String unread(int n) => '$n tin chưa đọc';
  static String unreadBadge(int n) => n > 99 ? '99+' : '$n';
  static const connecting = 'Đang kết nối trò chuyện…';
  static const reconnecting = 'Mất kết nối trò chuyện. Đang kết nối lại…';
  static const chatUnavailable = 'Trò chuyện đang ngoại tuyến.';
  static const friendsPrivacyNote =
      'Danh sách bạn bè và tin nhắn được tải trực tiếp từ Riot, không lưu '
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
      ? 'Đang ở sảnh chờ · ${partyOf(partySize, maxPartySize ?? 5)}'
      : 'Đang ở sảnh chờ';

  /// "Tổ đội 3/5".
  static String partyOf(int size, int max) => 'Tổ đội $size/$max';

  /// Leaderboard position of Immortal / Radiant players ("Top 1.234").
  static String leaderboardTop(String position) => 'Top $position';
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
  static const emptyChatTitle = 'Bắt đầu trò chuyện';
  static const emptyChat = 'Chưa có tin nhắn. Hãy gửi lời chào!';

  /// Quick openers: a tap only fills the message box, the player still
  /// taps "Gửi".
  static const suggestions = <String>[
    'Chào bạn!',
    'Làm vài trận không?',
    'Vào tổ đội với mình nhé!',
  ];
  static const viewProfile = 'Xem hồ sơ';
  static const sendFailed =
      'Không gửi được tin nhắn. Kiểm tra kết nối rồi thử lại.';
  static const historyFailed = 'Không tải được lịch sử trò chuyện.';
  static const waitingForConnection =
      'Đang kết nối… Bạn có thể gửi tin khi kết nối xong.';
  static const notFriend = 'Người này không có trong danh sách bạn bè.';
  static const failedBadge = 'Chưa gửi được';

  // --------------------------------------------------------------- party
  static const gameNotRunningTitle =
      'Mở VALORANT trên máy tính hoặc console';
  static const gameNotRunningBody =
      'Tổ đội & hàng chờ chỉ hoạt động khi VALORANT đang chạy trên máy tính '
      'hoặc console của bạn. Mở game rồi kéo xuống để làm mới.';
  static const autoRefresh = 'Tự động làm mới';

  /// "2/5 người · Tổ đội mở" (under the large title).
  static String partySummary(int size, int max, {required bool open}) =>
      '$size/$max người · ${open ? openState : closedState}';
  static const openState = 'Tổ đội mở';
  static const closedState = 'Chỉ người được mời';
  static const queueLabel = 'Hàng chờ';
  static const changeQueue = 'Đổi hàng chờ';
  static const pickQueueTitle = 'Chọn hàng chờ';
  static String pickQueueSubtitle(int size) => 'Tổ đội $size người';
  static String queueMaxParty(int max) =>
      max == 1 ? 'Chỉ chơi một mình' : 'Tối đa $max người';
  static const currentQueue = 'Đang chọn';
  static String membersSection(int n, int max) => 'Thành viên ($n/$max)';
  static const leader = 'Trưởng nhóm';
  static const you = 'Bạn';
  static const ready = 'Sẵn sàng';
  static const notReady = 'Chưa sẵn sàng';
  static const unready = 'Bỏ sẵn sàng';
  static const startQueue = 'Bắt đầu tìm trận';
  static String cancelQueue(String elapsed) => 'Hủy tìm trận · $elapsed';
  static const cancelQueueShort = 'Hủy tìm trận';
  static String searching(String elapsed) => 'Đang tìm trận · $elapsed';
  static const matchFound = 'Đã tìm thấy trận!';
  static const customGameLobby = 'Tổ đội đang ở phòng chơi tự do.';
  static const onlyLeader =
      'Chỉ trưởng nhóm mới có thể đổi hàng chờ và bắt đầu tìm trận.';
  static const queueLocked = 'Không thể đổi hàng chờ khi đang trong trận.';
  static const inMatchBanner =
      'Bạn đang trong trận. Hàng chờ sẽ mở lại khi trận kết thúc.';
  static String level(int n) => 'Cấp $n';

  /// Best ping of a member to the game servers ("24 ms").
  static String ping(int ms) => '$ms ms';
  static const pingTooltip = 'Ping tốt nhất tới máy chủ trận đấu';

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
  static const noOnlineFriends =
      'Chưa có bạn bè nào đang trực tuyến trong VALORANT.';
  static String inviteSent(String name) => 'Đã gửi lời mời tới $name.';
  static const inviteNeedsName =
      'Chưa biết Riot ID của người này nên chưa thể mời.';
  static String inviteLabel(String name) => 'Mời $name';
  static String invitedLabel(String name) => '$name · Đã mời';
  static const inviteByRiotId = 'Mời bằng Riot ID';
  static const inviteByRiotIdHint = 'Mời cả người chưa kết bạn';
  static const riotIdFieldHint = 'Tên#TAG';
  static const riotIdInvalid =
      'Riot ID gồm tên (3–16 ký tự), dấu # và tag (3–5 chữ hoặc số).';
  static const sendInvite = 'Gửi lời mời';

  static const partyCode = 'Mã tổ đội';
  static String partyCodeValue(String code) => 'Mã tổ đội: $code';
  static const generateCode = 'Tạo mã';
  static const copyCode = 'Sao chép';
  static const shareCode = 'Chia sẻ';

  /// Text shared with the party code (OS share sheet).
  static String shareCodeText(String code) =>
      'Vào tổ đội VALORANT của mình bằng mã: $code';

  /// "Sẵn sàng 3/5".
  static String readyCount(int ready, int total) => 'Sẵn sàng $ready/$total';
  static const idleQueue = 'Sẵn sàng tìm trận';
  static const disableCode = 'Tắt mã';
  static const noCode = 'Tạo mã để bạn bè vào tổ đội nhanh bằng mã.';
  static const noCodeMember = 'Trưởng nhóm có thể tạo mã để mời nhanh.';
  static const joinSection = 'Vào tổ đội khác';
  static const joinWithCode = 'Nhập mã để tham gia';
  static const join = 'Tham gia';
  static const joined = 'Đã tham gia tổ đội.';
  static const codeInvalid = 'Mã tổ đội chỉ gồm chữ cái và chữ số.';
  static const joinConfirmTitle = 'Tham gia tổ đội khác?';
  static const joinConfirmBody =
      'Bạn sẽ rời tổ đội hiện tại để vào tổ đội có mã này.';
  static const remoteNote =
      'Mọi thay đổi chỉ được gửi tới Riot khi bạn bấm. ValVN không tự tìm '
      'trận hay khóa đặc vụ thay bạn.';

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

  /// Platform labels of party members (shown for console players only).
  static String? consolePlatform(String? type) =>
      switch (type?.toLowerCase()) {
        'playstation' || 'ps5' || 'ps4' || 'ps' => 'PlayStation',
        'xbox' || 'xbone' || 'xsx' => 'Xbox',
        _ => null,
      };
}
