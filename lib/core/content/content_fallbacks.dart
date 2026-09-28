import '../l10n/content_strings.dart';
import '../riot/riot_ids.dart';
import 'models/cosmetic_models.dart';

/// Small bundled tables so names, colors and icons render before the first
/// content download or during a valorant-api outage (CA §2.2 step 7).
abstract final class ContentFallbacks {
  static String _currencyIcon(String uuid) =>
      'https://media.valorant-api.com/currencies/$uuid/displayicon.png';

  static String _tierIcon(String uuid) =>
      'https://media.valorant-api.com/contenttiers/$uuid/displayicon.png';

  static final List<Currency> currencies = [
    Currency(
      uuid: CurrencyIds.vp,
      displayName: ContentStrings.currencyVpFull,
      displayIcon: _currencyIcon(CurrencyIds.vp),
    ),
    Currency(
      uuid: CurrencyIds.rp,
      displayName: ContentStrings.currencyRpFull,
      displayIcon: _currencyIcon(CurrencyIds.rp),
    ),
    Currency(
      uuid: CurrencyIds.kc,
      displayName: ContentStrings.currencyKcFull,
      displayIcon: _currencyIcon(CurrencyIds.kc),
    ),
    Currency(
      uuid: CurrencyIds.agentTokens,
      displayName: ContentStrings.currencyAgentTokens,
      displayIcon: _currencyIcon(CurrencyIds.agentTokens),
    ),
  ];

  /// SUMMARY §7.3 / CA §4.1 (`highlightColor` RRGGBBAA).
  static final List<ContentTier> contentTiers = [
    ContentTier(
      uuid: ContentTierIds.select,
      devName: 'Select',
      rank: 0,
      displayName: ContentStrings.tierFull(ContentStrings.tierSelect),
      highlightColor: '5a9fe233',
      displayIcon: _tierIcon(ContentTierIds.select),
    ),
    ContentTier(
      uuid: ContentTierIds.deluxe,
      devName: 'Deluxe',
      rank: 1,
      displayName: ContentStrings.tierFull(ContentStrings.tierDeluxe),
      highlightColor: '00958733',
      displayIcon: _tierIcon(ContentTierIds.deluxe),
    ),
    ContentTier(
      uuid: ContentTierIds.premium,
      devName: 'Premium',
      rank: 2,
      displayName: ContentStrings.tierFull(ContentStrings.tierPremium),
      highlightColor: 'd1548d33',
      displayIcon: _tierIcon(ContentTierIds.premium),
    ),
    ContentTier(
      uuid: ContentTierIds.exclusive,
      devName: 'Exclusive',
      rank: 3,
      displayName: ContentStrings.tierFull(ContentStrings.tierExclusive),
      highlightColor: 'f5955b33',
      displayIcon: _tierIcon(ContentTierIds.exclusive),
    ),
    ContentTier(
      uuid: ContentTierIds.ultra,
      devName: 'Ultra',
      rank: 4,
      displayName: ContentStrings.tierFull(ContentStrings.tierUltra),
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

  /// VF §8.9 queue names (`console_` prefix already stripped by callers).
  static String? queueName(String queueId) =>
      ContentStrings.queueNames[queueId.toLowerCase()];
}
