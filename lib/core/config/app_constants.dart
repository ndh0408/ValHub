/// Compile-time constants (SUMMARY §3.1, §5, §12).
library;

/// Riot auth constants (SUMMARY §3.1).
abstract final class AuthConstants {
  static const clientId = 'play-valorant-web-prod';
  static const redirectUri = 'https://playvalorant.com/opt_in';
  static const responseType = 'token id_token';
  static const scope = 'account openid';
  static const uiLocales = 'vi';
  static const reauthNonce = '1';

  static const authHost = 'auth.riotgames.com';
  static const authorizeUrl = 'https://auth.riotgames.com/authorize';
  static const authorizationApiUrl =
      'https://auth.riotgames.com/api/v1/authorization';
  static const userInfoUrl = 'https://auth.riotgames.com/userinfo';
  static const entitlementsUrl =
      'https://entitlements.auth.riotgames.com/api/token/v1';
  static const riotGeoUrl =
      'https://riot-geo.pas.si.riotgames.com/pas/v1/product/valorant';
  static const pasChatUrl =
      'https://riot-geo.pas.si.riotgames.com/pas/v1/service/chat';
  static const clientConfigUrl =
      'https://clientconfig.rpg.riotgames.com/api/v1/config/player?app=Riot%20Client';

  /// Cookie reads after the WebView callback use this URL (riot-auth §1.6).
  static const cookieUrl = 'https://auth.riotgames.com/';

  /// The SSO session cookie that must exist for silent re-auth.
  static const sessionCookie = 'ssid';

  /// Token refresh margin (SUMMARY §3.3).
  static const refreshMargin = Duration(minutes: 5);

  /// Default access-token lifetime when `expires_in` is missing.
  static const defaultTokenLifetime = Duration(seconds: 3600);
}

/// Header values for PD / GLZ / shared calls (SUMMARY §5.1).
abstract final class RiotClientConstants {
  /// Tab/CRLF PC platform JSON, base64 (DailyStore, SkinPeek).
  static const clientPlatform =
      'ew0KCSJwbGF0Zm9ybVR5cGUiOiAiUEMiLA0KCSJwbGF0Zm9ybU9TIjogIldpbmRvd3MiLA0K'
      'CSJwbGF0Zm9ybU9TVmVyc2lvbiI6ICIxMC4wLjE5MDQyLjEuMjU2LjY0Yml0IiwNCgkicGxh'
      'dGZvcm1DaGlwc2V0IjogIlVua25vd24iDQp9';

  /// Used when valorant-api `/v1/version` is unreachable.
  static const fallbackClientVersion = 'release-13.06-shipping-13-5435758';

  /// Used when valorant-api `/v1/version` is unreachable.
  static const fallbackClientBuild = '111.0.0.3261.5663';

  /// `RiotClient/{riotClientBuild} rso-auth (Windows;10;;Professional, x64)`.
  static String apiUserAgent(String clientBuild) =>
      'RiotClient/$clientBuild rso-auth (Windows;10;;Professional, x64)';

  /// Mobile-browser UA for the login WebView on iOS (SUMMARY §3.1).
  static const webViewUserAgentIos =
      'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) '
      'AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 '
      'Safari/604.1';

  /// Mobile-browser UA for the login WebView on Android (SUMMARY §3.1).
  static const webViewUserAgentAndroid =
      'Mozilla/5.0 (Linux; Android 14; Mobile) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/140.0.0.0 Mobile Safari/537.36';

  /// Page size limit for match history / competitive updates (SUMMARY §6.2).
  static const maxPageSize = 20;

  /// Name-service batch size (SUMMARY U15).
  static const nameServiceBatch = 50;
}

/// App-level constants.
abstract final class AppConstants {
  /// Query parameter added to every notification deep link with a fresh
  /// value, so a screen already showing the same location (e.g. `/store`
  /// on the Bundle segment) still reacts to the new tap.
  static const linkNonceParam = 'nav';

  /// Maximum number of signed-in accounts (SUMMARY §3.1).
  static const maxAccounts = 10;

  /// Network timeouts (A9: 30 s).
  static const networkTimeout = Duration(seconds: 30);

  /// valorant-api.com base URL.
  static const contentApiBase = 'https://valorant-api.com/v1';

  /// Public status JSON (X-1). `{region}` is replaced.
  static const statusUrlTemplate =
      'https://valorant.secure.dyn.riotcdn.net/channels/public/x/status/{region}.json';

  /// ValVN community server (docs/community-api.md). Overridden by the
  /// remote-config key `communityBaseUrl`.
  static const communityBaseUrl = 'https://val.gianguyen.cloud';

  /// Optional remote config URL (static JSON, no user data). Empty = disabled.
  static const remoteConfigUrl = '';

  /// valorant-api content cache refresh interval (SUMMARY §10).
  static const contentMaxAge = Duration(days: 7);

  /// Minimum interval between `/v1/version` checks (SUMMARY §3.3 step d).
  static const versionCheckInterval = Duration(hours: 6);

  /// Bump whenever content parsing/models change so installs refetch.
  static const contentSchemaVersion = 1;

  /// Session-log ring buffer size.
  static const sessionLogCapacity = 500;
}
