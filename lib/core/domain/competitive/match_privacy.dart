import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/account_providers.dart';
import '../../storage/prefs.dart';
import '../../util/json.dart';
import 'match_models.dart';
import 'names.dart';

/// Who had Incognito / "hide account level" on in one match (SUMMARY U16).
///
/// Riot's match-details JSON carries no such flag: the only source is the
/// live match (`PlayerIdentity`) seen while polling. Matches the app never
/// saw live cannot be protected.
@immutable
class MatchPrivacy {
  const MatchPrivacy({this.incognito = const {}, this.hiddenLevel = const {}});

  static const none = MatchPrivacy();

  /// PUUIDs (lowercase) with Incognito on.
  final Set<String> incognito;

  /// PUUIDs (lowercase) with the account level hidden.
  final Set<String> hiddenLevel;

  bool get isEmpty => incognito.isEmpty && hiddenLevel.isEmpty;

  /// PUUIDs whose Riot ID must not be shown to [viewer] in [details]:
  /// Incognito players who are neither the viewer nor in the viewer's party.
  Set<String> hiddenIn(MatchDetails details, String? viewer) {
    if (incognito.isEmpty) return const {};
    final me = viewer?.toLowerCase();
    final myParty = details.player(me)?.partyId;
    return {
      for (final p in details.players)
        if (isIdentityHidden(
          incognito: incognito.contains(p.subject),
          isSelf: p.subject == me,
          isPartyMember: myParty != null && p.partyId == myParty,
        ))
          p.subject,
    };
  }

  @override
  bool operator ==(Object other) =>
      other is MatchPrivacy &&
      setEquals(other.incognito, incognito) &&
      setEquals(other.hiddenLevel, hiddenLevel);

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(incognito),
    Object.hashAllUnordered(hiddenLevel),
  );
}

/// Per-account store `{matchId: {incognito, hiddenLevel}}` written while a
/// live match is polled. Lives under `acct.<puuid>.` (wiped on sign-out),
/// bounded to [maxMatches] entries not older than [maxAge].
class MatchPrivacyStore {
  MatchPrivacyStore(this._prefs, {DateTime Function()? now})
    : _now = now ?? DateTime.now;

  final Prefs _prefs;
  final DateTime Function() _now;

  static const maxMatches = 60;
  static const maxAge = Duration(days: 60);

  static String _key(String viewer) =>
      PrefKeys.account(viewer.toLowerCase(), 'matchPrivacy');

  Map<String, Object?> _all(String viewer) =>
      asMap(_prefs.getJson(_key(viewer))) ?? const {};

  MatchPrivacy read(String viewer, String matchId) {
    final entry = asMap(_all(viewer)[matchId.trim().toLowerCase()]);
    if (entry == null) return MatchPrivacy.none;
    Set<String> ids(Object? raw) => {
      for (final v in asList(raw)) ?asString(v)?.toLowerCase(),
    };
    return MatchPrivacy(
      incognito: ids(entry['i']),
      hiddenLevel: ids(entry['l']),
    );
  }

  /// Records [privacy] for [matchId] (no write when nothing changed).
  Future<void> record(
    String viewer,
    String matchId,
    MatchPrivacy privacy,
  ) async {
    final id = matchId.trim().toLowerCase();
    if (id.isEmpty || privacy.isEmpty) return;
    final previous = read(viewer, id);
    final merged = MatchPrivacy(
      incognito: {...previous.incognito, ...privacy.incognito},
      hiddenLevel: {...previous.hiddenLevel, ...privacy.hiddenLevel},
    );
    if (merged == previous) return;
    final now = _now();
    final all = Map<String, Object?>.of(_all(viewer));
    all[id] = {
      'i': merged.incognito.toList(),
      'l': merged.hiddenLevel.toList(),
      't': now.millisecondsSinceEpoch,
    };
    final entries =
        all.entries.where((e) {
          final t = asInt(asMap(e.value)?['t']);
          return t != null &&
              now.difference(DateTime.fromMillisecondsSinceEpoch(t)) < maxAge;
        }).toList()..sort(
          (a, b) => (asInt(asMap(b.value)?['t']) ?? 0).compareTo(
            asInt(asMap(a.value)?['t']) ?? 0,
          ),
        );
    await _prefs.setJson(_key(viewer), {
      for (final e in entries.take(maxMatches)) e.key: e.value,
    });
  }
}

final matchPrivacyStoreProvider = Provider<MatchPrivacyStore>(
  (ref) => MatchPrivacyStore(ref.watch(prefsProvider)),
);

/// [MatchPrivacy] of a match for the active account (not reactive: it is
/// written during the live match, before the match can be opened).
final matchPrivacyProvider = Provider.autoDispose.family<MatchPrivacy, String>((
  ref,
  matchId,
) {
  final viewer = ref.watch(activePuuidProvider);
  if (viewer == null) return MatchPrivacy.none;
  return ref.watch(matchPrivacyStoreProvider).read(viewer, matchId);
});
