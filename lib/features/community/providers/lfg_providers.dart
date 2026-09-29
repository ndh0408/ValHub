import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/riot/pvp_api.dart';
import '../../../core/util/json.dart';
import '../../social/data/party_models.dart';
import '../../social/providers/party_providers.dart';
import '../data/community_api.dart';
import '../data/community_models.dart';
import 'community_providers.dart';

/// How often the visible LFG list refreshes itself.
const kLfgRefreshInterval = Duration(seconds: 20);

/// Filters of the LFG list (`region == null` = the active account's).
@immutable
class LfgFilter {
  const LfgFilter({this.region, this.mode});

  final String? region;
  final String? mode;

  LfgFilter copyWith({String? Function()? region, String? Function()? mode}) =>
      LfgFilter(
        region: region == null ? this.region : region(),
        mode: mode == null ? this.mode : mode(),
      );

  @override
  bool operator ==(Object other) =>
      other is LfgFilter && other.region == region && other.mode == mode;

  @override
  int get hashCode => Object.hash(region, mode);
}

/// The LFG filter chips (kept while the app runs).
final lfgFilterProvider = NotifierProvider<LfgFilterNotifier, LfgFilter>(
  LfgFilterNotifier.new,
);

class LfgFilterNotifier extends Notifier<LfgFilter> {
  @override
  LfgFilter build() => const LfgFilter();

  void setRegion(String region) => state = state.copyWith(region: () => region);

  void setMode(String? mode) => state = state.copyWith(mode: () => mode);
}

/// Key of [lfgProvider].
typedef LfgQuery = ({String puuid, String region, String? mode});

/// Active LFG posts for a region / mode, newest first.
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
    final api = ref.watch(communityApiProvider);
    return PagedState.fromPage(
      await api.lfg(query.puuid, region: query.region, mode: query.mode),
    );
  }

  @override
  Future<CommunityPage<LfgPost>> fetchPage(String? cursor) => _api.lfg(
    query.puuid,
    region: query.region,
    mode: query.mode,
    cursor: cursor,
  );

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

/// The user's own active LFG post, remembered after creating it (the list
/// may be filtered to another mode). Cleared on removal / expiry.
final myLfgPostProvider =
    NotifierProvider.family<MyLfgNotifier, LfgPost?, String>(MyLfgNotifier.new);

class MyLfgNotifier extends Notifier<LfgPost?> {
  MyLfgNotifier(this.puuid);

  final String puuid;

  @override
  LfgPost? build() => null;

  void set(LfgPost? post) => state = post;
}

/// Creates an LFG post for [puuid] (one active post per user).
Future<LfgPost> createLfgPost(
  WidgetRef ref, {
  required String puuid,
  required String region,
  required String mode,
  required String partyCode,
  required int slots,
  int? rankTier,
  String? note,
  LfgQuery? shownIn,
}) async {
  final post = await ref
      .read(communityApiProvider)
      .createLfg(
        puuid,
        region: region,
        mode: mode,
        partyCode: partyCode,
        slots: slots,
        rankTier: rankTier,
        note: note,
      );
  ref.read(myLfgPostProvider(puuid).notifier).set(post);
  if (shownIn != null) {
    final list = lfgProvider(shownIn);
    if (ref.exists(list)) ref.read(list.notifier).prepend(post);
  }
  return post;
}

/// Removes the user's LFG post.
Future<void> removeLfgPost(
  WidgetRef ref, {
  required String puuid,
  required LfgPost post,
  required LfgQuery shownIn,
}) async {
  await ref.read(communityApiProvider).deleteLfg(puuid, post.id);
  final mine = ref.read(myLfgPostProvider(puuid));
  if (mine?.id == post.id) {
    ref.read(myLfgPostProvider(puuid).notifier).set(null);
  }
  final list = lfgProvider(shownIn);
  if (ref.exists(list)) ref.read(list.notifier).removeLocal(post.id);
}

/// Joins a party by code with the active account (G-19). User-initiated
/// only, after a confirmation.
Future<void> joinLfgParty(WidgetRef ref, String puuid, String code) =>
    ref.read(pvpApiProvider).partyJoinByCode(puuid, code.trim().toUpperCase());

/// The invite code of the account's current party, generating one (G-18)
/// through the party feature when the party has none. `null` when the game
/// is not running or no party exists.
Future<String?> currentPartyCode(WidgetRef ref, String puuid) async {
  final party = partyProvider(puuid);
  // Keeps the auto-disposed party provider alive while we use it.
  final sub = ref.listenManual(party, (_, _) {});
  try {
    return await _partyCode(ref, party);
  } finally {
    sub.close();
  }
}

Future<String?> _partyCode(
  WidgetRef ref,
  AsyncNotifierProvider<PartyNotifier, PartyView> party,
) async {
  final view = await ref.read(party.future);
  final existing = view.party?.inviteCode;
  if (existing != null && partyCodePattern.hasMatch(existing.toUpperCase())) {
    return existing.toUpperCase();
  }
  if (view.party == null) return null;
  await ref.read(party.notifier).generateCode();
  final code = ref.read(party).value?.party?.inviteCode;
  final upper = asNonEmptyString(code)?.toUpperCase();
  return upper != null && partyCodePattern.hasMatch(upper) ? upper : null;
}
