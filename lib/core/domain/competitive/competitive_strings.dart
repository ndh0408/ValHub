/// Vietnamese copy produced by the shared competitive domain (VF §8.8).
///
/// Feature screens keep their own labels in `<f>_strings.dart`; only text
/// that the domain layer itself returns (outcome labels, placeholders,
/// round-end types) lives here.
abstract final class CompetitiveStrings {
  // Players (VF §8.8, SUMMARY U16)
  static const incognitoPlayer = 'Người chơi ẩn danh';
  static const unknownPlayer = 'Người chơi';

  // Match outcome (VF §8.8)
  static const victory = 'Thắng';
  static const defeat = 'Thua';
  static const draw = 'Hòa';

  /// Shown instead of a stat that has no data (HS% in Deathmatch, …).
  static const noValue = '–';

  /// Rank-Up Calculator when the recent form cannot reach the target.
  static const cannotEstimate = 'Không ước tính được';

  /// 404 on match details right after a match (SUMMARY §11.5).
  static const matchPending = 'Riot đang xử lý trận đấu…';

  /// Unranked player that still has placement matches to play.
  static String placementsLeft(int n) => 'Còn $n trận phân hạng';

  // Round end types (VF §8.8, VShop-vi)
  static const roundElimination = 'Hạ toàn đội';
  static const roundDetonate = 'Spike phát nổ';
  static const roundDefuse = 'Gỡ Spike';
  static const roundTimeExpired = 'Hết giờ';
  static const roundSurrendered = 'Đầu hàng';

  // Sides (VF §8.8)
  static const attack = 'Tấn công';
  static const defense = 'Phòng thủ';

  /// Division names of the current (Episode 5+) tier table, used only while
  /// valorant-api content is not available yet (CA §10.1).
  static const _e5Divisions = [
    'Sắt',
    'Đồng',
    'Bạc',
    'Vàng',
    'Bạch Kim',
    'Kim Cương',
    'Thượng Nhân',
    'Bất Tử',
  ];

  /// Fallback rank name of an Episode 5+ tier (`18` → `Kim Cương 1`,
  /// `27` → `Radiant`); `null` for unranked and unknown tiers.
  static String? fallbackTierName(int tier) {
    if (tier == 27) return 'Radiant';
    if (tier < 3 || tier > 26) return null;
    final i = tier - 3;
    return '${_e5Divisions[i ~/ 3]} ${i % 3 + 1}';
  }
}
