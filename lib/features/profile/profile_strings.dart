/// Vietnamese strings of the profile feature (VF §6.5, §8.8).
abstract final class ProfileStrings {
  static const title = 'Hồ sơ';
  static const rankUpTitle = 'Tính toán lên hạng';
  static const dailyRrTitle = 'RR theo ngày';
  static const matchDetailTitle = 'Chi tiết trận đấu';
  static const playerProfileTitle = 'Hồ sơ người chơi';

  /// Separator of inline facts ("Xếp hạng · 18 giờ trước").
  static const separator = ' · ';

  /// Joins inline facts with [separator].
  static String joined(Iterable<String> parts) => parts.join(separator);

  // Header (S40.1)
  /// " #TAG" after a game name.
  static String tagSuffix(String tag) => ' #$tag';
  static const copyRiotId = 'Sao chép Riot ID';
  static const riotIdCopied = 'Đã sao chép Riot ID';
  static String level(int n) => 'Cấp $n';

  /// "184 / 5.000 XP" (numbers already formatted).
  static String xpProgress(String xp, String perLevel) => '$xp / $perLevel XP';

  // Rank card (S40.2)
  static const currentRank = 'Hiện tại';
  static const peakRank = 'Cao nhất';

  /// "Cao nhất · V26 // Phần I".
  static String peakRankOf(String actTitle) => '$peakRank · $actTitle';
  static const truePeakLocal = 'Theo lịch sử trên thiết bị';
  static const neverRanked = 'Chưa từng xếp hạng';

  /// "≈ 9 trận để lên Kim Cương 2".
  static String rankUpHint(int matches, String rank) =>
      '≈ $matches trận để lên $rank';

  /// "Phần này: 20 thắng / 38 trận · 53%".
  static String actRecord(int wins, int games, String rate) =>
      'Phần này: $wins thắng / $games trận · $rate';

  /// Leaderboard position ("Bảng xếp hạng #123").
  static String leaderboard(String n) => 'Bảng xếp hạng #$n';
  static const rrTrendTitle = 'Diễn biến RR';

  /// "20 trận gần nhất".
  static String lastMatches(int n) => '$n trận gần nhất';

  // Daily RR row (S40.3)
  static const todayNone = 'Hôm nay chưa có trận xếp hạng';

  /// "Hôm nay: 2 thắng – 1 thua".
  static String today(String text) => 'Hôm nay: $text';

  // Social rows (S40.5)
  static const partyRow = 'Tổ đội & hàng chờ';
  static const friendsRow = 'Bạn bè & trò chuyện';

  // Match history (S40.6)
  static const matchHistory = 'Lịch sử đấu';
  static const filterAll = 'Tất cả';
  static const filterMap = 'Bản đồ';

  /// "Bản đồ: Tất cả".
  static String mapFilter(String map) => '$filterMap: $map';
  static const chooseMap = 'Lọc theo bản đồ';
  static const noMatches = 'Chưa có trận đấu nào.';
  static const noMatchesQueue = 'Không có trận nào ở chế độ này.';
  static const noMatchesMap =
      'Không có trận nào trên bản đồ này trong các '
      'trận đã tải.';
  static const endOfHistory = 'Đã hiển thị tất cả trận đấu';
  static const matchUnavailable = 'Không tải được trận đấu';

  /// "5/9/1".
  static String kdaValue(int k, int d, int a) => '$k/$d/$a';

  /// "K/D/A 5/9/1".
  static String kda(int k, int d, int a) => 'K/D/A ${kdaValue(k, d, a)}';

  /// "Kim Cương 1 · 6 RR".
  static String rankWithRr(String rank, String rr) => '$rank · $rr RR';

  /// "13 – 7".
  static String score(int a, int b) => '$a – $b';

  /// Deathmatch placement "Hạng 3".
  static String placement(int n) => 'Hạng $n';

  // Rank-Up Calculator (S41)
  static const targetRank = 'Hạng mục tiêu';
  static const yourRank = 'Hạng của bạn';

  /// "Còn thiếu 164 RR".
  static String rrLeft(String n) => 'Còn thiếu $n RR';
  static const alreadyReached = 'Bạn đã đạt hạng này.';
  static const atCurrentForm = 'Với phong độ hiện tại';

  /// "Với phong độ hiện tại (+19 / −16 mỗi trận)".
  static String atCurrentFormWith(String gain, String loss) =>
      '$atCurrentForm ($gain / $loss mỗi trận)';

  /// "≈ 9 trận".
  static String aboutMatches(int n) => '≈ $n trận';

  /// "Tốt nhất: 7 trận thắng liên tiếp".
  static String bestCase(int n) => 'Tốt nhất: $n trận thắng liên tiếp';
  static const winRate = 'Tỉ lệ thắng';
  static const matchesNeeded = 'Số trận cần';

  /// "Phong độ gần đây: 12 thắng – 8 thua".
  static String recentForm(int w, int l) =>
      'Phong độ gần đây: $w thắng – $l thua';
  static const rankUpFootnote =
      'Ước tính dựa trên các trận xếp hạng gần đây, chưa tính giáp hạng và '
      'trận phân hạng.';
  static const rankUpUnranked =
      'Hãy hoàn thành các trận phân hạng để dùng tính năng tính toán lên hạng.';
  static const rankUpImmortal =
      'Bạn đã ở Bất Tử trở lên — tính năng này chỉ tính đến Bất Tử 1.';
  static const rankUpNoForm =
      'Chưa có trận xếp hạng gần đây nào để ước tính phong độ.';

  // Daily RR (S42)
  static const dailyRrEmpty =
      'Chưa có trận xếp hạng nào được lưu trên thiết bị này.';
  static const dailyRrFootnote =
      'Lịch sử RR được lưu ngay trên thiết bị của bạn, kể cả các trận Riot '
      'không còn trả về.';

  /// "4 thắng – 2 thua" (+ " – 1 hòa").
  static String winsLosses(int w, int l, int d) =>
      d > 0 ? '$w thắng – $l thua – $d hòa' : '$w thắng – $l thua';

  /// "Vàng 2 → Vàng 3".
  static String rankChange(String from, String to) => '$from → $to';

  /// "6 trận".
  static String matchCount(int n) => '$n trận';

  // Match detail (S43)
  static const yourSummary = 'Thành tích của bạn';
  static const playerSummary = 'Thành tích';
  static const scoreboard = 'Bảng điểm';
  static const roundTimeline = 'Diễn biến vòng đấu';
  static const acs = 'ACS';
  static const acsHint = 'Điểm chiến đấu trung bình';
  static const hs = 'HS%';
  static const adr = 'ADR';
  static const kdaLabel = 'K/D/A';
  static const firstBloods = 'First blood';
  static const rr = 'RR';

  /// "6 RR" (number already formatted).
  static String rrValue(String n) => '$n RR';
  static const colK = 'K';
  static const colD = 'D';
  static const colA = 'A';
  static const colPlusMinus = '+/−';
  static const colPlace = '#';
  static const mvp = 'MVP';
  static const teamMvp = 'MVP đội';
  static const yourTeam = 'Đội của bạn';
  static const enemyTeam = 'Đội địch';
  static const teamBlue = 'Đội Xanh';
  static const teamRed = 'Đội Đỏ';
  static const allPlayers = 'Tất cả người chơi';
  static const duration = 'Thời lượng';

  /// "Thời lượng 38 phút".
  static String durationOf(String d) => '$duration $d';

  /// "Vòng 12".
  static String round(int n) => 'Vòng $n';
  static const firstHalf = 'Hiệp 1';
  static const secondHalf = 'Hiệp 2';
  static const overtime = 'Hiệp phụ';
  static const noRounds = 'Trận này không có dữ liệu vòng đấu.';
  static const noPlayers = 'Trận này không có dữ liệu người chơi.';

  /// "3 hạ gục".
  static String roundKills(int n) => '$n hạ gục';

  /// "Đặt Spike ở A".
  static String plantedAt(String site) => 'Đặt Spike ở $site';

  // Player profile (S44)
  static const recentMatches = 'Trận gần đây';
  static const levelHidden = 'Cấp ẩn';

  // Recent form card (derived from the loaded match history)
  static const recentFormTitle = 'Phong độ gần đây';
  static const kd = 'K/D';

  /// "Chuỗi 3 trận thắng".
  static String winStreak(int n) => 'Chuỗi $n trận thắng';

  /// "Chuỗi 2 trận thua".
  static String lossStreak(int n) => 'Chuỗi $n trận thua';

  /// "7T · 3B" (thắng / bại) under the win-rate ring.
  static String recordShort(int w, int l, int d) =>
      d > 0 ? '${w}T · ${l}B · ${d}H' : '${w}T · ${l}B';

  /// Screen-reader summary of the W/L strip.
  static String formSemantics(int w, int l, int games) =>
      '$games trận gần nhất: $w thắng, $l thua';

  // Match history (redesign)
  static const clearMap = 'Bỏ lọc bản đồ';

  /// Screen-reader label of a match card.
  static String matchSemantics(String map, String outcome, String? score) =>
      joined([map, outcome, ?score]);

  // Rank card (redesign)
  /// "6 / 100 RR" progress to the next tier.
  static String rrToNext(int rr) => '$rr / 100 RR';
  static const rankUpOpen = 'Mở tính toán lên hạng';

  // Match detail (redesign)
  static const sideSwitch = 'Đổi bên';
  static const roundWon = 'Thắng vòng';
  static const roundLost = 'Thua vòng';

  // Rank-Up Calculator (redesign)
  static const progressToTarget = 'Tiến độ tới hạng mục tiêu';

  // ------------------------------------------------ sub-pages (redesign v3)

  // Match detail hero + summary
  /// "Hôm qua · 14:49" (day header + 24 h local time).
  static String playedAt(String day, String time) => joined([day, time]);

  /// Screen-reader label of the match hero.
  static String matchHeroSemantics(String map, String result, String? score) =>
      joined([map, result, ?score]);
  static const kast = 'KAST';
  static const kastHint =
      'Tỉ lệ vòng bạn có hạ gục, hỗ trợ, sống sót hoặc được đồng đội trả thù';
  static const hitDistribution = 'Phân bố phát bắn trúng';
  static const hitHead = 'Đầu';
  static const hitBody = 'Thân';
  static const hitLegs = 'Chân';

  /// "Đầu 24%".
  static String hitShare(String part, String percent) => '$part $percent';

  // Round timeline: kill feed per round
  static const roundsHint = 'Chạm vào một vòng để xem từng pha hạ gục.';
  static const noKillsInRound = 'Vòng này không có dữ liệu hạ gục.';
  static const spike = 'Spike';
  static const fallDamage = 'Rơi từ trên cao';
  static const ability = 'Kỹ năng';
  static const showKills = 'Xem pha hạ gục';
  static const hideKills = 'Ẩn pha hạ gục';

  /// Screen-reader line of one kill: "Jett hạ gục Sova bằng Vandal (0:42)".
  static String killSemantics(
    String killer,
    String victim,
    String? weapon,
    String time,
  ) => weapon == null || weapon.isEmpty
      ? '$killer hạ gục $victim ($time)'
      : '$killer hạ gục $victim bằng $weapon ($time)';

  // Daily RR
  /// "7 ngày qua".
  static String lastDays(int n) => '$n ngày qua';

  /// "Ngày tính theo giờ trên máy (UTC+7)".
  static String dayBoundary(String zone) => 'Ngày tính theo $zone';

  /// The device time zone: "giờ trên máy (UTC+9)", "giờ trên máy
  /// (UTC−3:30)".
  static String timeZoneLabel(Duration offset) {
    final sign = offset.isNegative ? '−' : '+';
    final abs = offset.abs();
    final h = abs.inHours;
    final m = abs.inMinutes.remainder(60);
    final utc = m == 0
        ? 'UTC$sign$h'
        : 'UTC$sign$h:${m.toString().padLeft(2, '0')}';
    return 'giờ trên máy ($utc)';
  }

  /// "5 ngày có trận".
  static String daysPlayed(int n) => '$n ngày có trận';

  /// Short weekday of a day badge, indexed by `DateTime.weekday - 1`.
  static const weekdayShort = <String>[
    'T2',
    'T3',
    'T4',
    'T5',
    'T6',
    'T7',
    'CN',
  ];

  // Rank-Up Calculator
  /// "Tiến độ tới Kim Cương 2".
  static String progressTo(String rank) => 'Tiến độ tới $rank';

  /// "+22 RR khi thắng".
  static String gainPerWin(String rr) => '$rr RR khi thắng';

  /// "−18 RR khi thua".
  static String lossPerLoss(String rr) => '$rr RR khi thua';
  static const byWinRateTitle = 'Theo tỉ lệ thắng';
  static const yourWinRate = 'Tỉ lệ thắng gần đây của bạn';
  static const pickTargetHint = 'Chọn hạng bạn muốn đạt';
}
