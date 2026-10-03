import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;

import '../accounts/account.dart';
import '../l10n/app_locale.dart';
import '../storage/prefs.dart';
import '../util/json.dart';

/// valorant-api language for item names (VF §6.8 "Tên vật phẩm").
enum ItemLanguage {
  vi('vi-VN'),
  en('en-US');

  const ItemLanguage(this.apiCode);

  /// `language=` value for valorant-api (case-sensitive).
  final String apiCode;

  static ItemLanguage parse(Object? v) =>
      asString(v) == 'en' ? ItemLanguage.en : ItemLanguage.vi;
}

/// App-wide preferences shared by several features (VF §6.8 S70). Features
/// read them with `ref.watch(appSettingsProvider.select((s) => s.x))` and
/// the settings screen writes them through [AppSettingsNotifier].
@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    ItemLanguage itemLanguage = ItemLanguage.vi,
    String? contentLocale,
    this.autoOpenLiveGame = true,
    this.showPeakRankInGame = true,
    this.showLiveScore = true,
    this.storeResetNotifications = false,
    this.wishlistNotifications = false,
    this.wishlistNotificationsByAccount = const {},
    this.nightMarketNotifications = false,
    this.battlePassNotifications = false,
    this.rankNotifications = false,
    this.communityNotifications = false,
    this.lfgNotifications = false,
    this.showPriceEstimate = true,
  }) : _contentLocale =
           contentLocale ?? (itemLanguage == ItemLanguage.en ? 'en-US' : 'app');

  factory AppSettings.fromJson(Object? json) {
    final m = asMap(json) ?? const <String, dynamic>{};
    const d = AppSettings();
    return AppSettings(
      themeMode: switch (asString(m['themeMode'])) {
        'light' => ThemeMode.light,
        'system' => ThemeMode.system,
        _ => ThemeMode.dark,
      },
      itemLanguage: ItemLanguage.parse(m['itemLanguage']),
      contentLocale: m.containsKey('contentLocale')
          ? normalizeContentLocale(asString(m['contentLocale']))
          : null,
      autoOpenLiveGame: asBool(m['autoOpenLiveGame']) ?? d.autoOpenLiveGame,
      showPeakRankInGame:
          asBool(m['showPeakRankInGame']) ?? d.showPeakRankInGame,
      showLiveScore: asBool(m['showLiveScore']) ?? d.showLiveScore,
      storeResetNotifications:
          asBool(m['storeResetNotifications']) ?? d.storeResetNotifications,
      wishlistNotifications:
          asBool(m['wishlistNotifications']) ?? d.wishlistNotifications,
      wishlistNotificationsByAccount: {
        for (final entry
            in (asMap(m['wishlistNotificationsByAccount']) ??
                    const <String, dynamic>{})
                .entries)
          if (entry.value is bool) entry.key.toLowerCase(): entry.value as bool,
      },
      nightMarketNotifications:
          asBool(m['nightMarketNotifications']) ?? d.nightMarketNotifications,
      battlePassNotifications: asBool(m['battlePassNotifications']) ?? false,
      rankNotifications: asBool(m['rankNotifications']) ?? false,
      communityNotifications: asBool(m['communityNotifications']) ?? false,
      lfgNotifications: asBool(m['lfgNotifications']) ?? false,
      showPriceEstimate: asBool(m['showPriceEstimate']) ?? d.showPriceEstimate,
    );
  }

  /// Dark by default (Valorant style).
  final ThemeMode themeMode;
  final String _contentLocale;

  /// "app" follows UI language; an explicit tag selects independent API names.
  String get contentLocale => normalizeContentLocale(_contentLocale);

  /// Compatibility view for old callers and downgrade-safe settings JSON.
  /// Runtime content consumers use [contentLocale], which supports all 18 tags.
  ItemLanguage get itemLanguage =>
      contentLocale == 'en-US' ? ItemLanguage.en : ItemLanguage.vi;

  AppLocale contentLanguage(AppLocale app) =>
      AppLocale.fromTag(contentLocale) ?? app;

  static String normalizeContentLocale(String? value) =>
      AppLocale.fromTag(value)?.tag ?? 'app';

  /// "Tự động mở chi tiết trận" (G2).
  final bool autoOpenLiveGame;

  /// "Hiện rank cao nhất trong chi tiết trận" (G6).
  final bool showPeakRankInGame;

  /// "Hiện tỉ số trực tiếp" (G7).
  final bool showLiveScore;

  /// "Thông báo khi cửa hàng làm mới" (B8).
  final bool storeResetNotifications;

  /// "Kiểm tra wishlist trong nền" (W2/W4).
  final bool wishlistNotifications;

  /// Per-account choice. Missing entries use the old shared setting so
  /// existing users keep their notification choice after upgrading.
  final Map<String, bool> wishlistNotificationsByAccount;

  bool wishlistNotificationsFor(String puuid) =>
      wishlistNotificationsByAccount[puuid.toLowerCase()] ??
      wishlistNotifications;

  /// "Khi Chợ Đêm mở" (ValHub extra).
  final bool nightMarketNotifications;

  /// "Hiện giá quy đổi ước tính": the local-currency estimate next to VP
  /// prices (ValHub extra).
  final bool battlePassNotifications;
  final bool rankNotifications;
  final bool communityNotifications;
  final bool lfgNotifications;
  final bool showPriceEstimate;

  JsonMap toJson() => {
    'themeMode': themeMode.name,
    'itemLanguage': itemLanguage.name,
    'contentLocale': contentLocale,
    'autoOpenLiveGame': autoOpenLiveGame,
    'showPeakRankInGame': showPeakRankInGame,
    'showLiveScore': showLiveScore,
    'storeResetNotifications': storeResetNotifications,
    'wishlistNotifications': wishlistNotifications,
    'wishlistNotificationsByAccount': wishlistNotificationsByAccount,
    'nightMarketNotifications': nightMarketNotifications,
    'battlePassNotifications': battlePassNotifications,
    'rankNotifications': rankNotifications,
    'communityNotifications': communityNotifications,
    'lfgNotifications': lfgNotifications,
    'showPriceEstimate': showPriceEstimate,
  };

  AppSettings copyWith({
    ThemeMode? themeMode,
    ItemLanguage? itemLanguage,
    String? contentLocale,
    bool? autoOpenLiveGame,
    bool? showPeakRankInGame,
    bool? showLiveScore,
    bool? storeResetNotifications,
    bool? wishlistNotifications,
    Map<String, bool>? wishlistNotificationsByAccount,
    bool? nightMarketNotifications,
    bool? battlePassNotifications,
    bool? rankNotifications,
    bool? communityNotifications,
    bool? lfgNotifications,
    bool? showPriceEstimate,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    contentLocale:
        contentLocale ??
        (itemLanguage == null
            ? this.contentLocale
            : itemLanguage == ItemLanguage.en
            ? 'en-US'
            : 'app'),
    autoOpenLiveGame: autoOpenLiveGame ?? this.autoOpenLiveGame,
    showPeakRankInGame: showPeakRankInGame ?? this.showPeakRankInGame,
    showLiveScore: showLiveScore ?? this.showLiveScore,
    storeResetNotifications:
        storeResetNotifications ?? this.storeResetNotifications,
    wishlistNotifications: wishlistNotifications ?? this.wishlistNotifications,
    wishlistNotificationsByAccount:
        wishlistNotificationsByAccount ?? this.wishlistNotificationsByAccount,
    nightMarketNotifications:
        nightMarketNotifications ?? this.nightMarketNotifications,
    battlePassNotifications:
        battlePassNotifications ?? this.battlePassNotifications,
    rankNotifications: rankNotifications ?? this.rankNotifications,
    communityNotifications:
        communityNotifications ?? this.communityNotifications,
    lfgNotifications: lfgNotifications ?? this.lfgNotifications,
    showPriceEstimate: showPriceEstimate ?? this.showPriceEstimate,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings &&
      other.themeMode == themeMode &&
      other.contentLocale == contentLocale &&
      other.autoOpenLiveGame == autoOpenLiveGame &&
      other.showPeakRankInGame == showPeakRankInGame &&
      other.showLiveScore == showLiveScore &&
      other.storeResetNotifications == storeResetNotifications &&
      other.wishlistNotifications == wishlistNotifications &&
      mapEquals(
        other.wishlistNotificationsByAccount,
        wishlistNotificationsByAccount,
      ) &&
      other.nightMarketNotifications == nightMarketNotifications &&
      other.battlePassNotifications == battlePassNotifications &&
      other.rankNotifications == rankNotifications &&
      other.communityNotifications == communityNotifications &&
      other.lfgNotifications == lfgNotifications &&
      other.showPriceEstimate == showPriceEstimate;

  @override
  int get hashCode => Object.hash(
    themeMode,
    contentLocale,
    autoOpenLiveGame,
    showPeakRankInGame,
    showLiveScore,
    storeResetNotifications,
    wishlistNotifications,
    Object.hashAllUnordered(
      wishlistNotificationsByAccount.entries.map(
        (e) => Object.hash(e.key, e.value),
      ),
    ),
    nightMarketNotifications,
    battlePassNotifications,
    rankNotifications,
    communityNotifications,
    lfgNotifications,
    showPriceEstimate,
  );
}

/// Loads [AppSettings] from prefs (also usable from background isolates).
AppSettings readAppSettings(Prefs prefs) =>
    AppSettings.fromJson(prefs.getJson(PrefKeys.appSettings));

/// One-time upgrade of the single "wishlist alerts" switch.
///
/// Before the per-account switches, one shared switch covered every account.
/// Now each existing account gets an explicit copy of that choice and the
/// shared switch is cleared, so an account added later starts with alerts
/// OFF (opt-in) instead of silently inheriting an old "on". Runs once (guarded
/// by [PrefKeys.wishlistPerAccountMigrated]); safe to call on every start.
Future<void> migrateWishlistNotificationsPerAccount(Prefs prefs) async {
  if (prefs.getBool(PrefKeys.wishlistPerAccountMigrated) ?? false) return;
  final settings = readAppSettings(prefs);
  if (settings.wishlistNotifications) {
    final choices = {...settings.wishlistNotificationsByAccount};
    for (final raw in asList(prefs.getJson(PrefKeys.accounts))) {
      final puuid = Account.fromJson(raw)?.puuid;
      if (puuid != null) choices.putIfAbsent(puuid, () => true);
    }
    await prefs.setJson(
      PrefKeys.appSettings,
      settings
          .copyWith(
            wishlistNotifications: false,
            wishlistNotificationsByAccount: choices,
          )
          .toJson(),
    );
  }
  await prefs.setBool(PrefKeys.wishlistPerAccountMigrated, true);
}

/// Persisted app settings.
final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends Notifier<AppSettings> {
  Future<void> _writes = Future.value();
  late AppSettings _committed;

  @override
  AppSettings build() => _committed = readAppSettings(ref.watch(prefsProvider));

  /// Applies [update] and persists the result.
  Future<void> update(AppSettings Function(AppSettings) update) {
    final next = update(state);
    if (next == state) return _writes;
    final prefs = ref.read(prefsProvider);
    state = next;
    final task = _writes.then((_) async {
      try {
        await prefs.setJson(PrefKeys.appSettings, next.toJson());
        _committed = next;
      } on Object {
        if (ref.mounted && state == next) state = _committed;
        rethrow;
      }
    });
    _writes = task.catchError((Object _) {});
    return task;
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      update((s) => s.copyWith(themeMode: mode));

  Future<void> setItemLanguage(ItemLanguage language) =>
      update((s) => s.copyWith(itemLanguage: language));

  Future<void> setContentLocale(String choice) => update(
    (s) =>
        s.copyWith(contentLocale: AppSettings.normalizeContentLocale(choice)),
  );
}
