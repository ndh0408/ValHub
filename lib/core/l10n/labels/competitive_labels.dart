import '../../domain/competitive/match_models.dart';
import '../l10n.dart';

/// Match data remains language neutral, including cached results.
extension CompetitiveLabels on AppLocalizations {
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
