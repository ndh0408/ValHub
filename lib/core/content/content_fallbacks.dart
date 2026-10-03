import '../riot/riot_ids.dart';
import 'models/cosmetic_models.dart';

/// Locale-neutral bundled tables so colors and icons render before the first
/// content download or during a valorant-api outage (CA §2.2 step 7).
abstract final class ContentFallbacks {
  static String _currencyIcon(String uuid) =>
      'https://media.valorant-api.com/currencies/$uuid/displayicon.png';

  static String _tierIcon(String uuid) =>
      'https://media.valorant-api.com/contenttiers/$uuid/displayicon.png';

  static final List<Currency> currencies = [
    Currency(
      uuid: CurrencyIds.vp,
      displayName: '',
      displayIcon: _currencyIcon(CurrencyIds.vp),
    ),
    Currency(
      uuid: CurrencyIds.rp,
      displayName: '',
      displayIcon: _currencyIcon(CurrencyIds.rp),
    ),
    Currency(
      uuid: CurrencyIds.kc,
      displayName: '',
      displayIcon: _currencyIcon(CurrencyIds.kc),
    ),
    Currency(
      uuid: CurrencyIds.agentTokens,
      displayName: '',
      displayIcon: _currencyIcon(CurrencyIds.agentTokens),
    ),
  ];

  /// SUMMARY §7.3 / CA §4.1 (`highlightColor` RRGGBBAA).
  static final List<ContentTier> contentTiers = [
    ContentTier(
      uuid: ContentTierIds.select,
      devName: 'Select',
      rank: 0,
      displayName: '',
      highlightColor: '5a9fe233',
      displayIcon: _tierIcon(ContentTierIds.select),
    ),
    ContentTier(
      uuid: ContentTierIds.deluxe,
      devName: 'Deluxe',
      rank: 1,
      displayName: '',
      highlightColor: '00958733',
      displayIcon: _tierIcon(ContentTierIds.deluxe),
    ),
    ContentTier(
      uuid: ContentTierIds.premium,
      devName: 'Premium',
      rank: 2,
      displayName: '',
      highlightColor: 'd1548d33',
      displayIcon: _tierIcon(ContentTierIds.premium),
    ),
    ContentTier(
      uuid: ContentTierIds.exclusive,
      devName: 'Exclusive',
      rank: 3,
      displayName: '',
      highlightColor: 'f5955b33',
      displayIcon: _tierIcon(ContentTierIds.exclusive),
    ),
    ContentTier(
      uuid: ContentTierIds.ultra,
      devName: 'Ultra',
      rank: 4,
      displayName: '',
      highlightColor: 'fad66333',
      displayIcon: _tierIcon(ContentTierIds.ultra),
    ),
  ];

  static Currency? currency(String uuid) {
    final id = uuid.toLowerCase();
    for (final c in currencies) {
      if (c.uuid == id) return c;
    }
    return null;
  }

  static ContentTier? contentTier(String uuid) {
    final id = uuid.toLowerCase();
    for (final t in contentTiers) {
      if (t.uuid == id) return t;
    }
    return null;
  }
}
