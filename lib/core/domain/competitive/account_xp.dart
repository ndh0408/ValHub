import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/account_providers.dart';
import '../../riot/pvp_api.dart';
import '../../util/json.dart';
import 'viewer.dart';

/// XP needed per account level (EP §8; not in the response).
const kXpPerAccountLevel = 5000;

/// Level + XP at one point (`StartProgress` / `EndProgress` / `Progress`).
typedef XpProgress = ({int level, int xp});

XpProgress _progress(Object? json) {
  final m = asMap(json);
  return (level: m?.integer('Level') ?? 0, xp: m?.integer('XP') ?? 0);
}

/// One P-9 `History[]` entry (a recent match).
@immutable
class XpHistoryEntry {
  const XpHistoryEntry({
    required this.matchId,
    required this.start,
    required this.end,
    this.matchStart,
    this.xpDelta = 0,
    this.sources = const {},
  });

  static XpHistoryEntry? fromJson(Object? json) {
    final m = asMap(json);
    final id = lowerUuid(m?['ID']);
    if (m == null || id == null) return null;
    return XpHistoryEntry(
      matchId: id,
      matchStart: m.dateTime('MatchStart'),
      start: _progress(m['StartProgress']),
      end: _progress(m['EndProgress']),
      xpDelta: m.integer('XPDelta') ?? 0,
      sources: Map.unmodifiable({
        for (final s in m.maps('XPSources'))
          ?s.text('ID'): s.integer('Amount') ?? 0,
      }),
    );
  }

  final String matchId;
  final DateTime? matchStart;
  final XpProgress start;
  final XpProgress end;
  final int xpDelta;

  /// `time-played`, `match-win`, `first-win-of-the-day` → XP.
  final Map<String, int> sources;
}

/// P-9 account level and XP (R1, A4). Own account only.
@immutable
class AccountXp {
  const AccountXp({
    this.level = 0,
    this.xp = 0,
    this.history = const [],
    this.lastTimeGrantedFirstWin,
    this.nextTimeFirstWinAvailable,
  });

  static AccountXp fromJson(Object? json) {
    final m = asMap(json) ?? const <String, dynamic>{};
    final p = _progress(m['Progress']);
    return AccountXp(
      level: p.level,
      xp: p.xp,
      history: List.unmodifiable([
        for (final h in m.list('History')) ?XpHistoryEntry.fromJson(h),
      ]),
      lastTimeGrantedFirstWin: m.dateTime('LastTimeGrantedFirstWin'),
      nextTimeFirstWinAvailable: m.dateTime('NextTimeFirstWinAvailable'),
    );
  }

  /// "Cấp 222".
  final int level;

  /// XP inside the current level ("184 / 5.000 XP").
  final int xp;
  final List<XpHistoryEntry> history;
  final DateTime? lastTimeGrantedFirstWin;
  final DateTime? nextTimeFirstWinAvailable;

  int get xpPerLevel => kXpPerAccountLevel;

  /// Level bar fill, 0–1.
  double get progress => (xp / kXpPerAccountLevel).clamp(0.0, 1.0);

  int get xpToNextLevel =>
      (kXpPerAccountLevel - xp).clamp(0, kXpPerAccountLevel);

  /// Whether the first-win-of-the-day bonus is available at [now].
  bool isFirstWinAvailable(DateTime now) {
    final next = nextTimeFirstWinAvailable;
    return next == null || !now.toUtc().isBefore(next);
  }
}

/// Account XP of a signed-in account (family key = PUUID; P-9 is own-only),
/// kept 5 minutes. Also caches the level on the [Account] for the account
/// switcher (A4).
///
/// Throws [StateError] for a PUUID that is not signed in on this device (use
/// `players[].accountLevel` of match / live-game data for other players).
final accountXpProvider = FutureProvider.autoDispose.family<AccountXp, String>((
  ref,
  puuid,
) async {
  final id = puuid.trim().toLowerCase();
  final isOwn = ref.watch(accountProvider(id).select((a) => a != null));
  if (!isOwn) {
    throw StateError('Account XP is only available for signed-in accounts');
  }
  final viewer = watchViewer(ref, id);
  final api = ref.watch(pvpApiProvider);
  cacheFor(ref, const Duration(minutes: 5));
  final xp = AccountXp.fromJson(await api.accountXp(viewer));
  if (!ref.mounted) return xp;
  final account = ref.read(accountProvider(id));
  if (account != null && xp.level > 0 && account.level != xp.level) {
    unawaited(
      ref
          .read(accountsProvider.notifier)
          .updateAccount(id, (a) => a.copyWith(level: xp.level))
          .catchError((Object _) {}),
    );
  }
  return xp;
});
