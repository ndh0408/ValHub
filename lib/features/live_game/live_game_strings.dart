/// Strings of the live-game feature (VF §6.6, §8.10).
abstract final class LiveGameStrings {
  // Sheet (S50)
  static const sheetTitle = 'Chi tiết trận';
  static const refresh = 'Làm mới';
  static const refreshNow = 'Làm mới ngay';
  static const close = 'Đóng';

  /// Tooltip of the countdown ring: "Tự làm mới sau 4 giây".
  static String refreshIn(int seconds) => 'Tự làm mới sau $seconds giây';

  // Status pill
  static const statusAgentSelect = 'Đang chọn đặc vụ';
  static const statusInProgress = 'Đang diễn ra';
  static const statusEnded = 'Đã kết thúc';

  // Current game card (R7) / idle states
  static const currentGame = 'Trận hiện tại';
  static const notInGame = 'Không trong trận';
  static const inLobby = 'Đang ở sảnh chờ';
  static const inQueue = 'Đang tìm trận';
  static const agentSelect = 'Đang chọn đặc vụ';
  static const inMatch = 'Đang đấu';
  static const statusUnavailable = 'Chưa cập nhật được trạng thái trận';

  /// "Đang tìm trận · 01:32".
  static String inQueueFor(String elapsed) => '$inQueue · $elapsed';

  /// Parts joined with a middle dot ("Đang đấu · Lotus · 8 – 4").
  static String joinParts(Iterable<String> parts) =>
      parts.where((p) => p.trim().isNotEmpty).join(' · ');

  /// "8 – 4" (en dash with spaces, VF §8.8).
  static String score(int ally, int enemy) => '$ally – $enemy';

  static const notInGameTitle = 'Bạn không ở trong trận nào';
  static const notInGameHint =
      'Mở VALORANT và tìm trận — chi tiết trận sẽ tự hiện ở đây khi bạn vào '
      'màn hình chọn đặc vụ.';
  static const lobbyHint =
      'Khi tìm được trận, ValHub sẽ hiện đội hình và rank của mọi người.';
  static const queueHint =
      'Giữ ứng dụng mở — chi tiết trận sẽ hiện ngay khi tìm được trận.';

  /// Opens the party & queue screen (from the idle states).
  static const openParty = 'Mở tổ đội & hàng chờ';
  static const autoRefreshNote = 'Tự động làm mới khi có trận.';

  // Tabs (VF §8.10)
  static const tabAgents = 'Đặc vụ';
  static const tabYourTeam = 'Đội của bạn';
  static const tabEnemyTeam = 'Đội địch';
  static const tabAllPlayers = 'Người chơi';

  // Agent select (G4)
  static const hoverLockHint = 'Chạm để chọn thử, giữ để khóa đặc vụ.';

  /// "Còn 0:42".
  static String timeLeft(String t) => 'Còn $t';
  static String lockedAgent(String agent) => 'Đã khóa $agent';
  static String youLocked(String agent) => 'Bạn đã khóa $agent';
  static String youHover(String agent) => 'Bạn đang chọn $agent';
  static const lockFailed =
      'Chưa khóa được đặc vụ này. Hãy làm mới rồi thử lại.';
  static const selectFailed =
      'Chưa chọn được đặc vụ này. Hãy làm mới rồi thử lại.';
  static const agentNotOwned = 'Bạn chưa sở hữu đặc vụ này.';
  static const agentTaken = 'Đồng đội đã khóa đặc vụ này.';
  static const noAgents =
      'Chưa tải được danh sách đặc vụ. Hãy làm mới để thử lại.';
  static const enemyHiddenInAgentSelect =
      'Đội địch sẽ hiện khi trận đấu bắt đầu.';

  /// "Đội địch đã khóa 4/5".
  static String enemyLocked(int locked, int size) =>
      'Đội địch đã khóa $locked/$size';

  // Rosters (G5, G6)
  static const anonymous = 'Ẩn danh';
  static const you = 'BẠN';
  static const party = 'Tổ đội';
  static const noAgentYet = 'Chưa chọn đặc vụ';
  static const lockedTag = 'Đã khóa';
  static const emptyTeam = 'Chưa có người chơi.';

  /// "Cấp 120".
  static String level(int n) => 'Cấp $n';

  /// "Cao nhất: Vàng 3".
  static String peak(String rank) => 'Cao nhất: $rank';
  static const rankUnavailable = 'Không rõ rank';
  static String openLoadoutOf(String name) => 'Xem trang bị của $name';

  // Live score (G7)
  static const liveScore = 'Tỉ số trực tiếp';

  // Quit (G10)
  static const quitMatch = 'Rời trận';
  static const quitConfirmTitle = 'Rời trận đấu?';
  static const quitConfirmBodyPregame =
      'Né trận ở màn hình chọn đặc vụ có thể khiến bạn bị phạt (mất RR, khóa '
      'hàng chờ). Bạn vẫn muốn rời?';
  static const quitConfirmBodyInGame =
      'Rời trận có thể khiến bạn bị phạt (mất RR, khóa hàng chờ). Bạn vẫn '
      'muốn rời?';
  static const quitDone = 'Đã rời trận.';
  static const quitFailed = 'Chưa rời được trận.';
  static const quitMatchChanged =
      'Trận đã chuyển giai đoạn trong lúc bạn xác nhận. Chưa rời trận, hãy thử lại.';

  // Ended (G11)
  static const finalScoreboard = 'Bảng điểm cuối trận';

  /// "Bạn: 12/8/3 · ACS 245".
  static String yourStats(String kda, String? acs) =>
      acs == null ? 'Bạn: $kda' : 'Bạn: $kda · ACS $acs';
  static const viewMatchDetails = 'Xem chi tiết trận';
  static const matchPendingHint =
      'ValHub sẽ tự thử lại. Bảng điểm thường có sau khoảng một phút.';
  static const kda = 'K/D/A';
  static const acs = 'ACS';

  // Player loadout (S51)
  static const playerLoadoutTitle = 'Trang bị';

  /// "Trang bị của Tên#TAG".
  static String playerLoadoutOf(String name) => 'Trang bị của $name';
  static const weapons = 'Vũ khí';
  static const sprays = 'Hình phun sơn';
  static const flex = 'Flex';
  static const playerCard = 'Thẻ người chơi';
  static const noLoadout = 'Không có thông tin trang bị của người chơi này.';
  static const buddy = 'Phụ kiện súng';

  static const loadoutFromMatch = 'Trang bị trong trận này';
  static const loadoutFromAgentSelect = 'Trang bị lúc chọn đặc vụ';
}
