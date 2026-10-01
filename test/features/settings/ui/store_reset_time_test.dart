import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/live_game/live_game_strings.dart';
import 'package:valvn/features/profile/profile_strings.dart';
import 'package:valvn/features/settings/settings_strings.dart';
import 'package:valvn/features/settings/ui/sections/notifications_section.dart';

void main() {
  test('store reset follows the saved expiry instead of a fixed hour', () {
    expect(
      nextDailyStoreReset(
        DateTime.utc(2026, 9, 28, 23, 59),
        expiresAt: DateTime.utc(2026, 9, 28, 10, 15),
      ),
      DateTime.utc(2026, 9, 29, 10, 15),
    );
    expect(
      nextDailyStoreReset(
        DateTime.utc(2026, 12, 31, 1),
        expiresAt: DateTime.utc(2026, 12, 31, 11),
      ),
      DateTime.utc(2026, 12, 31, 11),
    );
    expect(SettingsStrings.notifStoreResetSubtitle('08:00'), '08:00 hằng ngày');
  });

  test('without a saved expiry the reset remains unknown', () {
    expect(nextDailyStoreReset(DateTime.utc(2026)), isNull);
  });

  test('glossary §8.10: the enemy team has one name everywhere', () {
    expect(ProfileStrings.enemyTeam, LiveGameStrings.tabEnemyTeam);
  });
}
