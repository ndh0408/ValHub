/// Persisted bookkeeping of the background wishlist check (per account,
/// wiped at sign-out with the other `acct.<puuid>.*` prefs).
library;

import '../../../core/storage/prefs.dart';
import '../../../core/util/json.dart';

class WishlistCheckState {
  WishlistCheckState(this._prefs);

  final Prefs _prefs;

  /// UTC day of the last successful check (`2026-09-29`).
  static String checkedDayKey(String puuid) =>
      PrefKeys.account(puuid, 'wishlist.checkedDay');

  /// Hit keys already notified → until when the offer stays on sale.
  static String notifiedKey(String puuid) =>
      PrefKeys.account(puuid, 'wishlist.notified');

  /// Until when the current Night Market was already announced ("Chợ Đêm
  /// đã mở!" is sent once per Night Market).
  static String nightMarketNotifiedKey(String puuid) =>
      PrefKeys.account(puuid, 'nightMarket.notifiedUntil');

  /// Same key as `core/background/session_keep_alive.dart`, so the
  /// "Cần đăng nhập lại" notification is sent once whichever task notices.
  static String needsLoginNotifiedKey(String puuid) =>
      PrefKeys.account(puuid, 'needsLoginNotified');

  /// `yyyy-MM-dd` of [t] in UTC (the store resets at 00:00 UTC).
  static String utcDay(DateTime t) {
    final u = t.toUtc();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${u.year.toString().padLeft(4, '0')}-${two(u.month)}-${two(u.day)}';
  }

  /// Next 00:00 UTC after [t].
  static DateTime nextUtcMidnight(DateTime t) {
    final u = t.toUtc();
    return DateTime.utc(u.year, u.month, u.day + 1);
  }

  bool checkedToday(String puuid, DateTime now) {
    final until = _prefs.getDateTime(
      PrefKeys.account(puuid, 'wishlist.checkedUntil'),
    );
    return until != null
        ? now.isBefore(until)
        : _prefs.getString(checkedDayKey(puuid)) == utcDay(now);
  }

  Future<void> markChecked(
    String puuid,
    DateTime now, {
    DateTime? expiresAt,
  }) async {
    await _prefs.setString(checkedDayKey(puuid), utcDay(now));
    if (expiresAt != null && expiresAt.isAfter(now)) {
      await _prefs.setDateTime(
        PrefKeys.account(puuid, 'wishlist.checkedUntil'),
        expiresAt,
      );
    }
  }

  /// Notified hit keys whose offer is still on sale at [now].
  Map<String, DateTime> notified(String puuid, DateTime now) {
    final raw = asMap(_prefs.getJson(notifiedKey(puuid)));
    if (raw == null) return {};
    return {
      for (final e in raw.entries)
        if (asDateTime(e.value) case final until? when until.isAfter(now))
          e.key: until,
    };
  }

  Future<void> saveNotified(String puuid, Map<String, DateTime> notified) =>
      _prefs.setJson(notifiedKey(puuid), {
        for (final e in notified.entries)
          e.key: e.value.toUtc().toIso8601String(),
      });

  /// Whether the Night Market running at [now] was already announced.
  bool nightMarketNotified(String puuid, DateTime now) {
    final until = asDateTime(_prefs.getString(nightMarketNotifiedKey(puuid)));
    return until != null && until.isAfter(now);
  }

  Future<void> setNightMarketNotified(String puuid, DateTime until) =>
      _prefs.setString(
        nightMarketNotifiedKey(puuid),
        until.toUtc().toIso8601String(),
      );

  bool needsLoginNotified(String puuid) =>
      _prefs.getBool(needsLoginNotifiedKey(puuid)) ?? false;

  Future<void> setNeedsLoginNotified(String puuid, bool value) => value
      ? _prefs.setBool(needsLoginNotifiedKey(puuid), true)
      : _prefs.remove(needsLoginNotifiedKey(puuid));
}
