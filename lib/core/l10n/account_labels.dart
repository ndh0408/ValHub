import '../accounts/account.dart';
import '../accounts/account_status.dart';
import 'l10n.dart';

/// Resolve metadata labels using the resource instance at render time.
extension AccountLabels on AppLocalizations {
  String? consolePlatformName(String? type) => switch (type?.toLowerCase()) {
    'playstation' || 'ps5' || 'ps4' || 'ps' => accountPlatformPlayStation,
    'xbox' || 'xbone' || 'xsx' => accountPlatformXbox,
    _ => null,
  };

  String accountActivityName(AccountActivity activity) => switch (activity) {
    AccountActivity.offline => accountStatusOffline,
    AccountActivity.online => accountStatusOnline,
    AccountActivity.agentSelect => accountStatusAgentSelect,
    AccountActivity.inMatch => accountStatusInMatch,
    AccountActivity.needsLogin => accountNeedsLogin,
    AccountActivity.unknown => accountStatusUnknown,
  };

  String riotRegionName(String region) => switch (region.toLowerCase()) {
    'ap' => accountRegionAp,
    'na' => accountRegionNa,
    'eu' => accountRegionEu,
    'kr' => accountRegionKr,
    'latam' => accountRegionLatam,
    'br' => accountRegionBr,
    _ => accountRegionUnknown,
  };

  String gamePlatformName(GamePlatform platform) => switch (platform) {
    GamePlatform.pc => accountPlatformPc,
    GamePlatform.playstation => accountPlatformPlayStation,
    GamePlatform.xbox => accountPlatformXbox,
  };

  /// Platform brands stay verbatim. Generic labels are translated resources.
  String statusPlatformName(String id) => switch (id.toLowerCase()) {
    'windows' || 'pc' => accountPlatformPc,
    'macos' => 'Mac',
    'ps4' => 'PlayStation 4',
    'ps5' => 'PlayStation 5',
    'playstation' => accountPlatformPlayStation,
    'xbone' => 'Xbox One',
    'xbox' || 'xboxseries' || 'xbox_series' => accountPlatformXbox,
    'android' => 'Android',
    'ios' => 'iOS',
    'mobile' => settingsPlatformMobile,
    _ => settingsPlatformOther,
  };
}
