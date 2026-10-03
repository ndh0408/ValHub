import '../../domain/economy/prices.dart';
import '../../domain/economy/reward_sources.dart';
import '../l10n.dart';
import 'content_labels.dart';

/// Price provenance stays data; captions use the current UI resources.
extension PriceSourceDisplay on PriceSource {
  String label(AppLocalizations l10n) => switch (this) {
    PriceSource.table => l10n.economyPriceFromTable,
    PriceSource.observed => l10n.economyPriceFromStore,
    PriceSource.offers => l10n.economyPriceFromOffers,
    PriceSource.tierFallback => l10n.economyPriceEstimated,
    PriceSource.reward || PriceSource.notForSale => l10n.contentNotForSale,
    PriceSource.unknown => l10n.economyPriceUnknown,
  };
}

extension RewardSourceEntryDisplay on RewardSourceEntry {
  String? label(AppLocalizations l10n) => relation.rewardSourceLabel(l10n);
}

extension PriceQuoteDisplay on PriceQuote {
  String? caption(AppLocalizations l10n) => switch (source) {
    PriceSource.reward => reward?.label(l10n) ?? l10n.contentNotForSale,
    PriceSource.notForSale => l10n.contentNotForSale,
    _ => null,
  };
}
