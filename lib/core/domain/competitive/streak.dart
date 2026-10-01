import 'package:flutter/foundation.dart';

import 'match_models.dart' show MatchOutcome;

/// Kind of a running result streak.
enum StreakKind { win, loss }

/// The current run of identical results at the head of a match list.
@immutable
class Streak {
  const Streak(this.kind, this.count);

  final StreakKind kind;

  /// How many decided matches in a row (at least 1).
  final int count;

  @override
  bool operator ==(Object other) =>
      other is Streak && other.kind == kind && other.count == count;

  @override
  int get hashCode => Object.hash(kind, count);

  @override
  String toString() => 'Streak(${kind.name} x$count)';
}

/// The one streak rule shared by Profile's recent form (any queue) and
/// Home's ranked streak (PR-19): the run of wins, or of losses, that starts
/// at the newest match of [outcomes] (newest first).
///
/// - [MatchOutcome.unknown] entries (customs without teams, aborted
///   matches) carry no result: they are skipped, neither counted nor
///   breaking the run;
/// - a [MatchOutcome.draw] ends the walk (a draw or remake is not a win or
///   a loss);
/// - `null` when the newest decided match is a draw or nothing is decided.
///
/// The *scope* of the list (all queues, ranked only, one map…) is decided by
/// the caller and must be shown next to the number.
Streak? currentStreak(Iterable<MatchOutcome> outcomes) {
  StreakKind? kind;
  var count = 0;
  for (final outcome in outcomes) {
    if (outcome == MatchOutcome.unknown) continue;
    final k = switch (outcome) {
      MatchOutcome.win => StreakKind.win,
      MatchOutcome.loss => StreakKind.loss,
      _ => null,
    };
    if (k == null) break;
    if (kind == null) {
      kind = k;
    } else if (k != kind) {
      break;
    }
    count++;
  }
  return kind == null ? null : Streak(kind, count);
}
