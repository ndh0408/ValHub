import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart' show ThemeMode;

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
    this.itemLanguage = ItemLanguage.vi,
    this.autoOpenLiveGame = true,
    this.showPeakRankInGame = true,
    this.showLiveScore = true,
    this.storeResetNotifications = false,
    this.wishlistNotifications = false,
    this.nightMarketNotifications = false,
  });

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
      autoOpenLiveGame: asBool(m['autoOpenLiveGame']) ?? d.autoOpenLiveGame,
      showPeakRankInGame:
          asBool(m['showPeakRankInGame']) ?? d.showPeakRankInGame,
      showLiveScore: asBool(m['showLiveScore']) ?? d.showLiveScore,
      storeResetNotifications:
          asBool(m['storeResetNotifications']) ?? d.storeResetNotifications,
      wishlistNotifications:
          asBool(m['wishlistNotifications']) ?? d.wishlistNotifications,
      nightMarketNotifications:
          asBool(m['nightMarketNotifications']) ?? d.nightMarketNotifications,
    );
  }

  /// Dark by default (Valorant style).
  final ThemeMode themeMode;
  final ItemLanguage itemLanguage;

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

  /// "Khi Chợ Đêm mở" (ValVN extra).
  final bool nightMarketNotifications;

  JsonMap toJson() => {
    'themeMode': themeMode.name,
    'itemLanguage': itemLanguage.name,
    'autoOpenLiveGame': autoOpenLiveGame,
    'showPeakRankInGame': showPeakRankInGame,
    'showLiveScore': showLiveScore,
    'storeResetNotifications': storeResetNotifications,
    'wishlistNotifications': wishlistNotifications,
    'nightMarketNotifications': nightMarketNotifications,
  };

  AppSettings copyWith({
    ThemeMode? themeMode,
    ItemLanguage? itemLanguage,
    bool? autoOpenLiveGame,
    bool? showPeakRankInGame,
    bool? showLiveScore,
    bool? storeResetNotifications,
    bool? wishlistNotifications,
    bool? nightMarketNotifications,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    itemLanguage: itemLanguage ?? this.itemLanguage,
    autoOpenLiveGame: autoOpenLiveGame ?? this.autoOpenLiveGame,
    showPeakRankInGame: showPeakRankInGame ?? this.showPeakRankInGame,
    showLiveScore: showLiveScore ?? this.showLiveScore,
    storeResetNotifications:
        storeResetNotifications ?? this.storeResetNotifications,
    wishlistNotifications: wishlistNotifications ?? this.wishlistNotifications,
    nightMarketNotifications:
        nightMarketNotifications ?? this.nightMarketNotifications,
  );

  @override
  bool operator ==(Object other) =>
      other is AppSettings && mapEquals(other.toJson(), toJson());

  @override
  int get hashCode => Object.hashAll(toJson().values);
}

/// Loads [AppSettings] from prefs (also usable from background isolates).
AppSettings readAppSettings(Prefs prefs) =>
    AppSettings.fromJson(prefs.getJson(PrefKeys.appSettings));

/// Persisted app settings.
final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => readAppSettings(ref.watch(prefsProvider));

  /// Applies [update] and persists the result.
  Future<void> update(AppSettings Function(AppSettings) update) async {
    final next = update(state);
    if (next == state) return;
    state = next;
    await ref.read(prefsProvider).setJson(PrefKeys.appSettings, next.toJson());
  }

  Future<void> setThemeMode(ThemeMode mode) =>
      update((s) => s.copyWith(themeMode: mode));

  Future<void> setItemLanguage(ItemLanguage language) =>
      update((s) => s.copyWith(itemLanguage: language));
}
