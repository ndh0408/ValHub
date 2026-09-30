/// Vietnamese copy owned by the loadout domain (VF §8.6, SUMMARY U8).
///
/// Screen copy stays in `lib/features/collection/collection_strings.dart`.
abstract final class LoadoutStrings {
  /// Error of any failed save (U8).
  static const saveFailed = 'Không thể lưu trang bị';

  /// Riot answered 200 but the re-GET shows the old version.
  static const notPersisted =
      'Riot chưa lưu thay đổi của bạn nên trang bị vẫn như cũ. Hãy thử lại.';

  /// The change does not fit the loadout (unknown weapon, melee buddy…).
  static const invalidChange =
      'Thay đổi này không áp dụng được cho trang bị hiện tại.';

  /// Default preset name ("Bộ trang bị 3").
  static String defaultPresetName(int n) => 'Bộ trang bị $n';
}
