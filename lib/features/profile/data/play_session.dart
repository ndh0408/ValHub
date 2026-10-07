import 'package:flutter/foundation.dart';

import '../../../core/domain/competitive/competitive.dart';
import 'recent_form.dart';

/// Two matches belong to one session when the newer one started at most
/// this long after the older one (a match, the queue and a short break).
const kSessionStartGap = Duration(hours: 2);

/// The session card stays until this long after the last match ended; the
/// next day the recent form and "RR theo ngày" tell the story.
const kSessionShownFor = Duration(hours: 12);

/// Most matches one session counts (about one history page).
const kSessionMaxMatches = 20;

/// The newest run of [history] (newest first) whose starts are at most
/// [kSessionStartGap] apart. Stops at the first entry without a start time.
List<MatchHistoryEntry> latestSessionEntries(
  Iterable<MatchHistoryEntry> history,
) {
  final out = <MatchHistoryEntry>[];
  DateTime? newer;
  for (final e in history) {
    final start = e.startTime;
    if (start == null) break;
    if (newer != null && newer.difference(start) > kSessionStartGap) break;
    out.add(e);
    newer = start;
    if (out.length == kSessionMaxMatches) break;
  }
  return out;
}

/// One match of a [PlaySession].
@immutable
class SessionMatch {
  const SessionMatch({
    required this.matchId,
    required this.outcome,
    this.agentId,
    this.acs,
  });

  final String matchId;
  final MatchOutcome outcome;
  final String? agentId;

  /// Round-based matches only.
  final double? acs;
}

/// A run of matches played in one sitting, built from the match summaries
/// the history list already loads (no extra request) and the RR changes of
/// its ranked matches.
@immutable
class PlaySession {
  const PlaySession({
    required this.matches,
    required this.start,
    required this.end,
    required this.played,
    required this.form,
    this.rrNet,
    this.topAgentId,
    this.topAgentGames = 0,
  });

  /// Oldest first (the order they were played).
  final List<SessionMatch> matches;
  final DateTime start;

  /// When the newest match ended (its start when the length is unknown).
  final DateTime end;

  /// Total length of the matches (queues and breaks not counted).
  final Duration played;

  /// Record and per-round stats (round-based matches only, PR-02).
  final RecentForm form;

  /// Net RR of the ranked matches; `null` without one, or when a ranked
  /// match of the session has no RR change yet (never a partial sum).
  final int? rrNet;

  /// The agent played most, when played more than once.
  final String? topAgentId;
  final int topAgentGames;

  /// Still worth a card: the last match ended within [kSessionShownFor].
  bool isFresh(DateTime now) => now.difference(end) <= kSessionShownFor;
}

/// Builds the session of [entries] (newest first) from their [summaries]
/// (same order, `null` when not loaded) and the RR earned per ranked match.
/// `null` with fewer than two decided matches: one match is not a session.
PlaySession? buildPlaySession(
  List<MatchHistoryEntry> entries,
  List<MatchPlayerSummary?> summaries, {
  required Map<String, int> rrByMatch,
}) {
  assert(entries.length == summaries.length);
  final lines = <MatchStatLine>[];
  final matches = <SessionMatch>[];
  final agents = <String, int>{};
  var played = Duration.zero;
  DateTime? end;
  for (var i = 0; i < entries.length; i++) {
    final s = summaries[i];
    if (s == null) continue;
    final line = MatchStatLine.fromSummary(s);
    if (line == null || line.outcome == MatchOutcome.unknown) continue;
    lines.add(line);
    final length = s.info.gameLength;
    if (length != null) played += length;
    final start = s.info.startTime ?? entries[i].startTime;
    if (end == null && start != null) end = start.add(length ?? Duration.zero);
    final agent = line.agentId;
    if (agent != null) agents[agent] = (agents[agent] ?? 0) + 1;
    matches.add(
      SessionMatch(
        matchId: entries[i].matchId,
        outcome: line.outcome,
        agentId: agent,
        acs: line.mode.isRoundBased && line.rounds > 0
            ? line.score / line.rounds
            : null,
      ),
    );
  }
  final start = entries.lastOrNull?.startTime;
  if (lines.length < 2 || start == null || end == null) return null;

  int? rrNet;
  final ranked = [
    for (final e in entries)
      if (baseQueueId(e.queueId) == 'competitive') e.matchId,
  ];
  if (ranked.isNotEmpty && ranked.every(rrByMatch.containsKey)) {
    rrNet = ranked.fold<int>(0, (sum, id) => sum + rrByMatch[id]!);
  }

  String? topAgent;
  var topGames = 0;
  agents.forEach((id, n) {
    if (n > topGames) {
      topAgent = id;
      topGames = n;
    }
  });

  return PlaySession(
    matches: List.unmodifiable(matches.reversed),
    start: start,
    end: end,
    played: played,
    form: RecentForm.fromLines(lines),
    rrNet: rrNet,
    topAgentId: topGames >= 2 ? topAgent : null,
    topAgentGames: topGames >= 2 ? topGames : 0,
  );
}
