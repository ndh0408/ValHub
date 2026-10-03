import '../formats.dart';
import '../l10n.dart';

/// Conditional captions take resources from the current view, never a model.
extension ViewLabels on AppLocalizations {
  String battlePassSummary(String level, String count, String unlocked) =>
      '${battlePassLevelOf(level, count)}$battlePassDot${battlePassUnlockedCount(unlocked, count)}';

  String slotCaption(AppFormats formats, int slot) {
    final names = [
      collectionSlotNamesItem0,
      collectionSlotNamesItem1,
      collectionSlotNamesItem2,
      collectionSlotNamesItem3,
    ];
    final position = slot >= 0 && slot < names.length
        ? names[slot]
        : '${slot + 1}';
    return collectionSlotCaption(formats.lower(position));
  }

  String homeOfferLabel(String name, String price, String tier, bool wished) =>
      homeOfferAccessibility(name, price, tier, wished ? 'yes' : 'no');

  String homeTrendingLabel(String name, String votes, bool wished) =>
      homeTrendingAccessibility(name, votes, wished ? 'yes' : 'no');

  String homeTodayRankLabel(int net, int wins, int losses) =>
      homeTodayRankAccessibility(
        net >= 0 ? 'gain' : 'loss',
        net.abs(),
        wins,
        losses,
      );

  String homeResults(int wins, int losses, int draws, [int unknown = 0]) =>
      homeResultSummary(
        wins,
        losses,
        draws > 0 ? draws : 0,
        unknown > 0 ? unknown : 0,
      );

  String liveStatisticsLabel(String kda, String? acs) =>
      liveGamePlayerStatistics(kda, acs == null ? 'no' : 'yes', acs ?? '');

  String skinCommunityLabel(String? average, String count, String votes) =>
      skinDetailCommunitySummary(
        average == null ? 'no' : 'yes',
        average ?? '',
        count,
        votes,
      );

  String wishlistItemLabel(String name, String price, bool wished) =>
      wishlistItemAccessibility(name, price, wished ? 'yes' : 'no');

  String rewardFacts(String contract, String? level) =>
      [contract, ?level].join(profileSeparator);

  List<String> get chatSuggestions => [
    socialSuggestionsItem0,
    socialSuggestionsItem1,
    socialSuggestionsItem2,
  ];
}
