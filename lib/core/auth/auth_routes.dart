/// Route locations owned by core (the login WebView).
abstract final class AuthRoutes {
  /// `/login` — add an account.
  static const login = '/login';

  /// `/login?reauth=<puuid>` — sign an existing account in again.
  static String loginPath({String? reauthPuuid}) => reauthPuuid == null
      ? login
      : '$login?reauth=${Uri.encodeQueryComponent(reauthPuuid)}';
}
