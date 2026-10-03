import '../../domain/competitive/match_models.dart';
import '../l10n.dart';

/// Match data remains language neutral, including cached results.
extension CompetitiveLabels on AppLocalizations {
  String winLossSummary(int wins, int losses, int draws, [int unknown = 0]) =>
      profileWinLossSummary(
        wins,
        losses,
        draws > 0 ? draws : 0,
        unknown > 0 ? unknown : 0,
      );

  String playedAt(String day, String time) =>
      [day, time].join(profileSeparator);

  String matchFacts(String map, String outcome, String? score) =>
      [map, outcome, ?score].join(profileSeparator);

  String matchOutcome(MatchOutcome value) => switch (value) {
    MatchOutcome.win => competitiveVictory,
    MatchOutcome.loss => competitiveDefeat,
    MatchOutcome.draw => competitiveDraw,
    MatchOutcome.unknown => competitiveNoValue,
  };

  String? roundEndType(RoundEndType value) => switch (value) {
    RoundEndType.elimination => competitiveRoundElimination,
    RoundEndType.detonate => competitiveRoundDetonate,
    RoundEndType.defuse => competitiveRoundDefuse,
    RoundEndType.timeExpired => competitiveRoundTimeExpired,
    RoundEndType.surrendered => competitiveRoundSurrendered,
    RoundEndType.unknown => null,
  };

  String teamRole(TeamRole value) => switch (value) {
    TeamRole.attacker => competitiveAttack,
    TeamRole.defender => competitiveDefense,
  };
}
