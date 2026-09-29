/// Vietnamese strings of the Battle Pass feature (VF §6.3, §8.7).
///
/// Numbers arrive already formatted (`formatNumber`), so "1.162.500" etc.
abstract final class BattlePassStrings {
  static const title = 'Battle Pass';
  static const rewardsTitle = 'Phần thưởng Battle Pass';

  // Pass card (S20)
  static const premium = 'Premium';
  static const free = 'Miễn phí';

  /// "Cấp 46 / 55".
  static String levelOf(String level, String count) => 'Cấp $level / $count';

  /// "7.966 / 35.750 XP".
  static String xpOf(String xp, String total) => '$xp / $total XP';

  /// Caption of the level XP: "Lên cấp 47".
  static String nextLevelCaption(String level) => 'Lên cấp $level';
  static const totalXpCaption = 'Tổng XP';
  static const passComplete = 'Đã hoàn thành Battle Pass';

  /// "Phần kết thúc sau 16 ngày".
  static String actEndsInDays(int days) => 'Phần kết thúc sau $days ngày';

  /// "Phần kết thúc sau 11:54:37" (last day).
  static String actEndsIn(String time) => 'Phần kết thúc sau $time';
  static const actEnded = 'Phần này đã kết thúc';
  static const noBattlePass =
      'Chưa có thông tin Battle Pass của Phần hiện tại. Hãy thử lại sau.';

  // Rewards row
  static const viewAllRewards = 'Xem tất cả phần thưởng';

  /// "46/55 đã mở khóa".
  static String unlockedCount(String unlocked, String total) =>
      '$unlocked/$total đã mở khóa';

  // XP pace (ValVN extra)
  /// "21.469 XP / ngày".
  static String xpPerDay(String xp) => '$xp XP / ngày';
  static const xpPerDayCaption = 'Cần mỗi ngày để kịp hoàn thành';

  /// "Còn 15 ngày".
  static String daysLeft(int days) => 'Còn $days ngày';

  /// "Nhiệm vụ tuần còn +76.800 XP".
  static String weeklyXpLeft(String xp) => 'Nhiệm vụ tuần còn +$xp XP';

  // Estimate (ValVN extra)
  /// "Còn cần 321.034 XP".
  static String xpToFinish(String xp) => 'Còn cần $xp XP';

  /// "≈ 81 trận Đấu thường".
  static String matchesEstimate(String n, String queue) => '≈ $n trận $queue';
  static const unratedFallback = 'Đấu thường';
  static const estimateNote =
      'Ước tính khoảng 4.000 XP mỗi trận, chưa tính nhiệm vụ.';

  // Event pass
  static const eventPass = 'Vé sự kiện';

  /// "Kết thúc sau 2 ngày 15:09:24".
  static String eventEndsIn(String time) => 'Kết thúc sau $time';

  // Daily checkpoints (P4)
  static const dailyMissions = 'Nhiệm vụ hằng ngày';
  static const dailyCaption = 'Phần thưởng ngày';
  static const checkpoint = 'Cột mốc';

  /// "Đã đạt 2/4 cột mốc".
  static String checkpointsDone(int done, int total) =>
      'Đã đạt $done/$total cột mốc';

  /// "Cột mốc tiếp theo: 3/4".
  static String nextCheckpoint(int charges, int needed) =>
      'Cột mốc tiếp theo: $charges/$needed';
  static const checkpointRewards = 'Mỗi cột mốc: +XP, +KC';
  static const checkpointHint =
      'Thắng vòng để nạp cột mốc (Sinh Tử không tính).';

  /// "Làm mới sau 11:54:37".
  static String resetsIn(String time) => 'Làm mới sau $time';
  static const dailyAllDone = 'Đã hoàn thành tất cả cột mốc hôm nay';

  /// Semantic label of one pip: "Cột mốc 2: 3/4".
  static String checkpointLabel(int index, int charges, int needed) =>
      'Cột mốc $index: $charges/$needed';
  static const bonusBadge = '×2';

  /// Charges of one checkpoint: "3/4".
  static String charges(int charges, int needed) => '$charges/$needed';

  /// "Thưởng gấp đôi đang chờ: 2".
  static String bonusPending(int n) => 'Thưởng gấp đôi đang chờ: $n';
  static const dailyNotReady =
      'Cột mốc hôm nay chưa được tạo. Hãy vào game hoặc làm mới tại đây.';
  static const dailyExpired =
      'Cột mốc của ngày trước đã hết hạn. Hãy vào game hoặc làm mới tại đây.';
  static const dailyPlayToStart =
      'Cột mốc hôm nay chưa sẵn sàng. Hãy vào game để bắt đầu ngày mới.';
  static const renewButton = 'Làm mới cột mốc';
  static const renewDone = 'Đã làm mới cột mốc hằng ngày.';
  static const renewFailed = 'Không thể làm mới cột mốc. Vui lòng thử lại sau.';

  // Weekly missions (P3)
  static const weeklyMissions = 'Nhiệm vụ hằng tuần';

  /// "8 / 15".
  static String missionProgress(String progress, String target) =>
      '$progress / $target';

  /// "+38.400 XP".
  static String xpReward(String xp) => '+$xp XP';
  static const unknownMission = 'Nhiệm vụ mới (đang cập nhật dữ liệu)';
  static const missionDone = 'Đã hoàn thành';

  /// "2/3 hoàn thành".
  static String missionsCompleted(int done, int total) =>
      '$done/$total hoàn thành';
  static const noWeeklyMissions = 'Hiện chưa có nhiệm vụ hằng tuần.';

  // All completed (P5)
  static const allMissionsDone = 'Đã hoàn thành tất cả nhiệm vụ';
  static const allWeeklyDone = 'Đã hoàn thành tất cả nhiệm vụ hằng tuần';

  /// "Nhiệm vụ mới sau 2 ngày 15:09:24".
  static String newMissionsIn(String time) => 'Nhiệm vụ mới sau $time';

  // Rewards (S21)
  /// "Chương 3".
  static String chapter(int n) => 'Chương $n';
  static const epilogue = 'Phần mở rộng';

  /// "Cấp 12".
  static String levelShort(int n) => 'Cấp $n';

  /// "3/5" levels reached in a chapter.
  static String chapterProgress(int reached, int total) => '$reached/$total';
  static const currentChapter = 'Hiện tại';
  static const freeTrack = 'Phần thưởng miễn phí';
  static const rewardUnlocked = 'Đã mở khóa';
  static const rewardLocked = 'Chưa mở khóa';
  static const rewardNeedsPremium = 'Cần Premium';
  static const premiumHint =
      'Bạn chưa mua Premium: chỉ nhận được phần thưởng Miễn phí. '
      'Mua Premium trong game để mở khóa các cấp đã đạt.';
  static const noRewards = 'Chưa có phần thưởng nào cho Battle Pass này.';
  static const noRewardsTitle = 'Chưa có phần thưởng';

  // Rewards filter (remembered)
  static const filterAll = 'Tất cả';
  static const filterUnlocked = 'Đã mở khóa';
  static const filterLocked = 'Còn khóa';
  static const noRewardsInFilter = 'Không có phần thưởng nào trong mục này.';
  static const showAllRewards = 'Xem tất cả';
  static const missionsProgressLabel = 'Tiến độ nhiệm vụ tuần';
  static const unknownReward = 'Phần thưởng';

  /// Separator between short facts ("Skin · Cấp 12 · Đã mở khóa").
  static const dot = ' · ';

  /// "Cấp 46 / 55 · 46/55 đã mở khóa".
  static String levelSummary(String level, String count, String unlocked) =>
      '${levelOf(level, count)}$dot${unlockedCount(unlocked, count)}';
}
