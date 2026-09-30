/// The `*Strings` classes being migrated and the ARB key namespace of each
/// (docs/design/I18N.md 4.1).
///
/// Key = `lowerCamel(prefix + Member)`: `CommonStrings.retry` ->
/// `commonRetry`, `BattlePassStrings.levelOf` -> `battlePassLevelOf`.
///
/// The order is the canonical namespace order of `app_vi.arb`
/// (`tool/l10n_fmt.dart` `kKeyPrefixOrder`; a root test keeps the two equal).
/// `HomeStrings` appeared with the Home tab, after the design's measurement of
/// 19 classes, and is appended.
library;

const Map<String, String> kStringsClassPrefixes = {
  'CommonStrings': 'common',
  'ContentStrings': 'content',
  'AccountStrings': 'account',
  'AuthStrings': 'auth',
  'NotificationStrings': 'notification',
  'CompetitiveStrings': 'competitive',
  'EconomyStrings': 'economy',
  'LoadoutStrings': 'loadout',
  'BattlePassStrings': 'battlePass',
  'CollectionStrings': 'collection',
  'CommunityStrings': 'community',
  'LiveGameStrings': 'liveGame',
  'ProfileStrings': 'profile',
  'LegalStrings': 'legal',
  'SettingsStrings': 'settings',
  'SkinDetailStrings': 'skinDetail',
  'SocialStrings': 'social',
  'StoreStrings': 'store',
  'WishlistStrings': 'wishlist',
  'HomeStrings': 'home',
};

/// The class names, in canonical order.
Set<String> get kStringsClasses => kStringsClassPrefixes.keys.toSet();

/// The ARB key of [cls].[member]: `commonRetry`.
String arbKeyOf(String cls, String member) {
  final prefix = kStringsClassPrefixes[cls];
  if (prefix == null) throw ArgumentError.value(cls, 'cls', 'unknown class');
  return '$prefix${member[0].toUpperCase()}${member.substring(1)}';
}
