import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/features/live_game/live_game_strings.dart';
import 'package:valvn/features/profile/profile_strings.dart';
import 'package:valvn/features/settings/settings_strings.dart';
import 'package:valvn/features/settings/ui/sections/notifications_section.dart';

void main() {
  test('store reset is the next 00:00 UTC, not a fixed 07:00', () {
    expect(
      nextDailyStoreReset(DateTime.utc(2026, 9, 28, 23, 59)),
      DateTime.utc(2026, 9, 29),
    );
    expect(
      nextDailyStoreReset(DateTime.utc(2026, 12, 31, 1)),
      DateTime.utc(2027),
    );
    expect(SettingsStrings.notifStoreResetSubtitle('08:00'), '08:00 hằng ngày');
  });

  test('glossary §8.10: the enemy team has one name everywhere', () {
    expect(ProfileStrings.enemyTeam, LiveGameStrings.tabEnemyTeam);
  });
}
