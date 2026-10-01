import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/riot/pvp_api.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/util/json.dart';
import '../../social/data/party_models.dart';
import '../../social/providers/party_providers.dart';
import '../data/community_api.dart';
import '../data/community_exception.dart';
import '../data/community_models.dart';
import '../data/lfg_sync.dart';
import 'community_providers.dart';

/// How often the visible LFG list refreshes itself, and how often the
/// poster's party is synced.
const kLfgRefreshInterval = Duration(seconds: 20);

/// `UiMemory` keys of the LFG filters.
abstract final class LfgMemoryKeys {
  static const region = 'community.lfg.region';
  static const mode = 'community.lfg.mode';
  static const role = 'community.lfg.role';
  static const mic = 'community.lfg.mic';
  static const matchRank = 'community.lfg.matchRank';
  static const language = 'community.lfg.language';
}

/// Filters of the LFG list (`region == null` = the active account's).
@immutable
class LfgFilter {
  const LfgFilter({
    this.region,
    this.mode,
    this.role,
    this.micOnly = false,
    this.matchRank = true,
    this.language,
  });

  final String? region;
  final String? mode;
  final String? role;

  /// Only posts that require a mic.
  final bool micOnly;

  /// "Phù hợp rank của bạn" (on by default).
  final bool matchRank;

  /// Party language (`null` = any).
  final String? language;

  LfgFilter copyWith({
    String? Function()? region,
    String? Function()? mode,
    String? Function()? role,
    bool? micOnly,
    bool? matchRank,
    String? Function()? language,
  }) => LfgFilter(
    region: region == null ? this.region : region(),
    mode: mode == null ? this.mode : mode(),
    role: role == null ? this.role : role(),
    micOnly: micOnly ?? this.micOnly,
    matchRank: matchRank ?? this.matchRank,
    language: language == null ? this.language : language(),
  );

  @override
  bool operator ==(Object other) =>
      other is LfgFilter &&
      other.region == region &&
      other.mode == mode &&
      other.role == role &&
      other.micOnly == micOnly &&
      other.matchRank == matchRank &&
      other.language == language;

  @override
  int get hashCode =>
      Object.hash(region, mode, role, micOnly, matchRank, language);
}

/// The LFG filters, remembered across launches (`UiMemory`).
final lfgFilterProvider = NotifierProvider<LfgFilterNotifier, LfgFilter>(
  LfgFilterNotifier.new,
);

class LfgFilterNotifier extends Notifier<LfgFilter> {
  UiMemory get _memory => ref.read(uiMemoryProvider);

  @override
  LfgFilter build() {
    final m = ref.watch(uiMemoryProvider);
    String? known(String? v, List<String> allowed) =>
        v != null && allowed.contains(v) ? v : null;
    return LfgFilter(
      region: known(m.read(LfgMemoryKeys.region), kCommunityRegions),
      mode: known(m.read(LfgMemoryKeys.mode), kLfgModes),
      role: known(m.read(LfgMemoryKeys.role), kLfgRoles),
      micOnly: m.readBool(LfgMemoryKeys.mic),
      matchRank: m.readBool(LfgMemoryKeys.matchRank, fallback: true),
      language: switch (lfgLanguageCode(m.read(LfgMemoryKeys.language))) {
        kLfgAnyLanguage || null => null,
        final code => code,
      },
    );
  }

  void setRegion(String region) {
    state = state.copyWith(region: () => region);
    _memory.write(LfgMemoryKeys.region, region);
  }

  void setMode(String? mode) {
    state = state.copyWith(mode: () => mode);
    _memory.write(LfgMemoryKeys.mode, mode);
  }

  void setRole(String? role) {
    state = state.copyWith(role: () => role);
    _memory.write(LfgMemoryKeys.role, role);
  }

  void setMicOnly(bool value) {
    state = state.copyWith(micOnly: value);
    _memory.writeBool(LfgMemoryKeys.mic, value);
  }

  void setLanguage(String? language) {
    state = state.copyWith(language: () => language);
    _memory.write(LfgMemoryKeys.language, language);
  }

  void setMatchRank(bool value) {
    state = state.copyWith(matchRank: value);
    _memory.writeBool(LfgMemoryKeys.matchRank, value);
  }
}

/// Key of [lfgProvider].
typedef LfgQuery = ({
  String puuid,
  String region,
  String? mode,
  int? rank,
  String? role,
  bool? mic,
  String? language,
});

/// The viewer's rank for LFG matching (`null` when unranked / unknown).
int? lfgViewerRank(Account account) {
  final t = account.rankTier;
  return t == null || t <= 2 ? null : t;
}

/// The LFG query shown for [account] with [filter].
LfgQuery lfgQueryFor(Account account, LfgFilter filter) => (
  puuid: account.puuid,
  region: filter.region ?? communityAccountRegion(account),
  mode: filter.mode,
  rank: filter.matchRank ? lfgViewerRank(account) : null,
  role: filter.role,
  mic: filter.micOnly ? true : null,
  language: filter.language,
);

/// Open LFG posts for a query, newest first.
final lfgProvider = AsyncNotifierProvider.autoDispose
    .family<LfgNotifier, PagedState<LfgPost>, LfgQuery>(LfgNotifier.new);

class LfgNotifier extends AsyncNotifier<PagedState<LfgPost>>
    with PagedLoader<LfgPost> {
  LfgNotifier(this.query);

  final LfgQuery query;

  CommunityApi get _api => ref.read(communityApiProvider);

  @override
  Future<PagedState<LfgPost>> build() async {
    ref.watch(accountProvider(query.puuid).select((a) => a?.needsLogin));
    ref.watch(communityApiProvider);
    return PagedState.fromPage(await fetchPage(null));
  }

  @override
  Future<CommunityPage<LfgPost>> fetchPage(String? cursor) async {
    final page = await _api.lfg(
      query.puuid,
      region: query.region,
      mode: query.mode,
      rank: query.rank,
      role: query.role,
      mic: query.mic,
      language: query.language,
      cursor: cursor,
    );
    // The server filters too; keep the list honest if it does not.
    return CommunityPage(
      [
        for (final p in page.items)
          if (p.status == LfgStatus.open &&
              (query.rank == null || p.acceptsRank(query.rank)) &&
              (query.role == null ||
                  p.roles.isEmpty ||
                  p.roles.contains(query.role)) &&
              (query.mic != true || p.mic == true) &&
              (query.language == null ||
                  p.language == query.language ||
                  p.language == kLfgAnyLanguage))
            p,
      ],
      nextCursor: page.nextCursor,
      applied: page.applied,
    );
  }

  @override
  String idOf(LfgPost item) => item.id;

  /// Periodic refresh: keeps the list on errors (no error state flash).
  Future<void> silentRefresh() async {
    final current = state.value;
    if (current == null || state.isLoading) return refresh();
    try {
      final page = await fetchPage(null);
      if (ref.mounted) state = AsyncData(PagedState.fromPage(page));
    } on Object {
      // Keep the current list; the next tick retries.
    }
  }
}

/// The user's own LFG post (`GET /v1/lfg/mine`, any status), kept in sync by
/// the poster poller. `null` when there is none (or the server cannot say).
final myLfgProvider =
    AsyncNotifierProvider.family<MyLfgNotifier, LfgPost?, String>(
      MyLfgNotifier.new,
    );

class MyLfgNotifier extends AsyncNotifier<LfgPost?> {
  MyLfgNotifier(this.puuid);

  final String puuid;

  /// When the post was last PATCHed / created (heartbeat bookkeeping).
  DateTime? lastPatchAt;

  @override
  Future<LfgPost?> build() async {
    ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
    try {
      return await ref.watch(communityApiProvider).myLfg(puuid);
    } on CommunityException {
      return null;
    }
  }

  void set(LfgPost? post, {DateTime? patchedAt}) {
    state = AsyncData(post);
    lastPatchAt = post == null ? null : (patchedAt ?? lastPatchAt);
  }

  /// "Gia hạn": PATCH without changes (extends the post by 30 minutes).
  Future<LfgPost> extend(DateTime now) async {
    final post = state.value;
    if (post == null) {
      throw const CommunityException(CommunityException.notFound);
    }
    try {
      final updated = await ref
          .read(communityApiProvider)
          .updateLfg(puuid, post.id, status: post.status);
      set(updated, patchedAt: now);
      return updated;
    } on CommunityException catch (e) {
      // The server answers 404 once the post expired: it must be posted
      // again, so drop it.
      if (e.code == CommunityException.notFound) {
        set(null);
        throw const LfgPostExpired();
      }
      rethrow;
    }
  }
}

/// The own LFG post expired on the server (PATCH → 404): post a new one.
class LfgPostExpired implements Exception {
  const LfgPostExpired();
}

/// The poster's live party, published by the poller for the pinned card.
final lfgLivePartyProvider =
    NotifierProvider.family<LfgLivePartyNotifier, LfgPartySnapshot?, String>(
      LfgLivePartyNotifier.new,
    );

class LfgLivePartyNotifier extends Notifier<LfgPartySnapshot?> {
  LfgLivePartyNotifier(this.puuid);

  final String puuid;

  @override
  LfgPartySnapshot? build() => null;

  void set(LfgPartySnapshot? party) => state = party;
}

/// The party code could not be generated automatically.
class LfgCodeUnavailable implements Exception {
  const LfgCodeUnavailable();
}

/// Creates an LFG post for [puuid] (one active post per user). An empty
/// [partyCode] is generated from the account's party (G-18, opening the
/// party) as part of this single user action.
Future<LfgPost> createLfgPost(
  WidgetRef ref, {
  required String puuid,
  required String region,
  required String mode,
  required String partyCode,
  required int slots,
  int? rankTier,
  String? note,
  int? rankMin,
  int? rankMax,
  List<String> roles = const [],
  bool? mic,
  String? language,
  int? partySize,
  LfgQuery? shownIn,
  DateTime? now,
}) async {
  var code = partyCode.trim().toUpperCase();
  if (code.isEmpty) {
    code = await currentPartyCode(ref, puuid, openParty: true) ?? '';
    if (code.isEmpty) throw const LfgCodeUnavailable();
  }
  final post = await ref
      .read(communityApiProvider)
      .createLfg(
        puuid,
        region: region,
        mode: mode,
        partyCode: code,
        slots: slots,
        rankTier: rankTier,
        note: note,
        rankMin: rankMin,
        rankMax: rankMax,
        roles: roles,
        mic: mic,
        language: language,
        partySize: partySize,
      );
  ref.read(myLfgProvider(puuid).notifier).set(post, patchedAt: now);
  if (shownIn != null) {
    final list = lfgProvider(shownIn);
    if (ref.exists(list)) ref.read(list.notifier).removeLocal(post.id);
  }
  return post;
}

/// Removes the user's LFG post.
Future<void> removeLfgPost(
  WidgetRef ref, {
  required String puuid,
  required LfgPost post,
  LfgQuery? shownIn,
}) async {
  await ref.read(communityApiProvider).deleteLfg(puuid, post.id);
  final mine = ref.read(myLfgProvider(puuid)).value;
  if (mine?.id == post.id) ref.read(myLfgProvider(puuid).notifier).set(null);
  if (shownIn != null) {
    final list = lfgProvider(shownIn);
    if (ref.exists(list)) ref.read(list.notifier).removeLocal(post.id);
  }
}

/// Joins the party of [post] by code with the active account (G-19), then
/// records the join (best effort). User-initiated only, after a
/// confirmation.
Future<void> joinLfgPost(WidgetRef ref, String puuid, LfgPost post) async {
  final join = await ref
      .read(communityApiProvider)
      .requestLfgJoin(puuid, post.id);
  if (!ref.context.mounted || ref.read(accountProvider(puuid)) == null) return;
  await ref.read(pvpApiProvider).partyJoinByCode(puuid, join.partyCode);
}

/// Joins a party by code with the active account (G-19).
Future<void> joinLfgParty(WidgetRef ref, String puuid, String code) =>
    ref.read(pvpApiProvider).partyJoinByCode(puuid, code.trim().toUpperCase());

/// The invite code of the account's current party, generating one (G-18)
/// through the party feature when the party has none (and opening the party
/// when [openParty]). `null` when the game is not running or no party
/// exists.
Future<String?> currentPartyCode(
  WidgetRef ref,
  String puuid, {
  bool openParty = false,
}) async {
  final party = partyProvider(puuid);
  // Keeps the auto-disposed party provider alive while we use it.
  final sub = ref.listenManual(party, (_, _) {});
  try {
    return await _partyCode(ref, party, openParty: openParty);
  } finally {
    sub.close();
  }
}

Future<String?> _partyCode(
  WidgetRef ref,
  AsyncNotifierProvider<PartyNotifier, PartyView> party, {
  required bool openParty,
}) async {
  final view = await ref.read(party.future);
  final current = view.party;
  if (current == null) return null;
  if (openParty && !current.isOpen) {
    try {
      await ref.read(party.notifier).setOpen(true);
    } on Object {
      // Joining by code works for closed parties too.
    }
  }
  final existing = asNonEmptyString(current.inviteCode)?.toUpperCase();
  if (existing != null && partyCodePattern.hasMatch(existing)) return existing;
  await ref.read(party.notifier).generateCode();
  final code = ref.read(party).value?.party?.inviteCode;
  final upper = asNonEmptyString(code)?.toUpperCase();
  return upper != null && partyCodePattern.hasMatch(upper) ? upper : null;
}

/// Reads the live party of [puuid] for the create sheet (party size).
Future<LfgPartySnapshot?> readLiveParty(WidgetRef ref, String puuid) async {
  try {
    return await readLfgParty(ref.read(pvpApiProvider), puuid);
  } on Object {
    return null;
  }
}
