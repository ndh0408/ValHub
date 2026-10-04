import '../../content/models/rank_models.dart';
import '../../domain/competitive/rank_calc.dart';
import '../formats.dart';
import '../l10n.dart';

extension RankDisplay on RankInfo {
  String displayLabel(AppFormats formats) {
    final messages = formats.l10n;
    if (isUnranked) return messages.contentUnranked;
    if (tierName.trim().isNotEmpty) return formats.titleCase(tierName);
    return messages.rankFallbackName(normalizedTier) ??
        messages.competitiveRankUnknown;
  }

  String? placementLabel(AppFormats formats) =>
      isPlacement ? formats.l10n.competitivePlacementsLeft(gamesNeeded) : null;
}

extension CompetitiveTierDisplay on CompetitiveTier {
  String displayLabel(AppFormats formats) => isUnranked
      ? formats.l10n.contentUnranked
      : tierName.trim().isEmpty
      ? formats.l10n.rankFallbackName(tier) ??
            formats.l10n.competitiveRankUnknown
      : formats.titleCase(tierName);
}

extension RankFallbackLabels on AppLocalizations {
  String? rankFallbackName(int tier) {
    if (tier == 27) return competitiveDivisionRadiant;
    if (tier < 3 || tier > 26) return null;
    final index = tier - 3;
    final division = switch (index ~/ 3) {
      0 => competitiveDivisionIron,
      1 => competitiveDivisionBronze,
      2 => competitiveDivisionSilver,
      3 => competitiveDivisionGold,
      4 => competitiveDivisionPlatinum,
      5 => competitiveDivisionDiamond,
      6 => competitiveDivisionAscendant,
      _ => competitiveDivisionImmortal,
    };
    return competitiveRankTierCaption(division, index % 3 + 1);
  }
}
