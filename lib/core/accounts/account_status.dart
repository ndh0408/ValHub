import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../content/content_repository.dart';
import '../domain/competitive/rank_calc.dart';
import '../domain/competitive/rank_models.dart';
import '../domain/competitive/viewer.dart';
import '../l10n/account_strings.dart';
import '../network/riot_exception.dart';
import '../riot/pvp_api.dart';
import '../theme/app_theme.dart';
import '../util/clock.dart';
import '../util/json.dart';
import '../xmpp/xmpp_providers.dart' show appForegroundProvider;
import '../xmpp/xmpp_models.dart' show LoopState;
import 'account_providers.dart';

/// What a signed-in account is doing right now, for the account lists (so
/// the user sees every account's state without switching to it).
enum AccountActivity {
  /// VALORANT is not running for this account (G-1 404).
  offline,

  /// In the menus / lobby.
  online,
  agentSelect,
  inMatch,

  /// Cookies are dead: sign in again.
  needsLogin,

  /// The check failed (network, maintenance…): keep quiet, retry later.
  unknown;

  /// From a G-1 `session/v1/sessions/{puuid}` body; `null` (404) = offline.
  static AccountActivity fromSession(Object? session, {DateTime? now}) {
    if (session == null) return offline;
    final body = asMap(session);
    if (body == null) return unknown;
    final connection = asNonEmptyString(body['cxnState'])?.toUpperCase();
    if (connection != null && connection != 'CONNECTED') return offline;
    if (asBool(body['shouldForceInvalidate']) == true) return offline;
    final expires = asDateTime(body['expiredTime']);
    if (expires != null && !expires.isAfter(now ?? DateTime.now())) {
      return offline;
    }
    final loop = asNonEmptyString(body['loopState']);
    if (loop == null) return unknown;
    return switch (LoopState.parse(loop)) {
      LoopState.menus => online,
      LoopState.pregame => agentSelect,
      LoopState.ingame => inMatch,
      LoopState.unknown => unknown,
    };
  }

  /// The game client is running.
  bool get isOnline => this == online || this == agentSelect || this == inMatch;

  String get label => switch (this) {
    offline => AccountStrings.statusOffline,
    online => AccountStrings.statusOnline,
    agentSelect => AccountStrings.statusAgentSelect,
    inMatch => AccountStrings.statusInMatch,
    needsLogin => AccountStrings.needsLogin,
    unknown => AccountStrings.statusUnknown,
  };

  Color color(BuildContext context) {
    final c = valColorsOf(context);
    return switch (this) {
      online => c.win,
      agentSelect => c.warning,
      inMatch => Theme.of(context).colorScheme.primary,
      needsLogin => c.warning,
      offline || unknown => c.muted,
    };
  }
}

/// How often a visible account list re-checks every account.
const kAccountActivityRefresh = Duration(seconds: 45);

/// Live activity of one account (G-1 with that account's own session).
/// Auto-disposed; wrap the list in [AccountActivityPoller] to refresh it
/// while visible. Never throws: failures read as [AccountActivity.unknown].
///
/// ```dart
/// final activity = ref.watch(accountActivityProvider(a.puuid)).value;
/// ```
final accountActivityProvider = FutureProvider.autoDispose
    .family<AccountActivity, String>((ref, puuid) async {
      final needsLogin = ref.watch(
        accountProvider(puuid).select((a) => a?.needsLogin),
      );
      if (needsLogin == null) return AccountActivity.unknown;
      if (needsLogin) return AccountActivity.needsLogin;
      try {
        final session = await ref
            .read(pvpApiProvider)
            .gameSession(puuid)
            .orNullIfNotFound();
        return AccountActivity.fromSession(
          session,
          now: ref.read(clockProvider).now(),
        );
      } on NeedsLoginException {
        return AccountActivity.needsLogin;
      } on Object {
        // Network, maintenance, odd bodies: never break the account list.
        return AccountActivity.unknown;
      }
    });

/// Re-checks every account's activity every [kAccountActivityRefresh] while
/// [child] is on screen: the timer dies with the widget and skips ticks
/// while its tab is in the background (tickers muted).
class AccountActivityPoller extends ConsumerStatefulWidget {
  const AccountActivityPoller({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AccountActivityPoller> createState() =>
      _AccountActivityPollerState();
}

class _AccountActivityPollerState extends ConsumerState<AccountActivityPoller> {
  Timer? _timer;

  /// False while this tab is in the background.
  var _visible = true;
  var _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final visible = TickerMode.valuesOf(context).enabled;
    if (_initialized && visible && !_visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _visible && ref.read(appForegroundProvider)) {
          ref.invalidate(accountActivityProvider);
        }
      });
    }
    _visible = visible;
    _initialized = true;
  }

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(kAccountActivityRefresh, (_) {
      if (mounted && _visible && ref.read(appForegroundProvider)) {
        ref.invalidate(accountActivityProvider);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(appForegroundProvider, (wasForeground, foreground) {
      if (foreground && wasForeground == false && _visible) {
        ref.invalidate(accountActivityProvider);
      }
    });
    return widget.child;
  }
}

/// Number of accounts whose game is running (for the list headers). Counts
/// only the checks that already finished.
final onlineAccountCountProvider = Provider.autoDispose<int>((ref) {
  var n = 0;
  for (final a in ref.watch(accountsProvider)) {
    final activity = ref.watch(accountActivityProvider(a.puuid)).value;
    if (activity?.isOnline ?? false) n++;
  }
  return n;
});

/// Refreshes the cached current rank (`rankTier` / `rankSeasonId`) of a
/// listed account with one P-11 call, so every account shows its rank
/// without opening its Profile. Light on purpose (no RR history, no
/// keep-alive); failures keep the cached rank.
final accountRankRefreshProvider = FutureProvider.autoDispose
    .family<void, String>((ref, puuid) async {
      final id = puuid.toLowerCase();
      final needsLogin = ref.watch(
        accountProvider(id).select((a) => a?.needsLogin),
      );
      if (needsLogin != false) return;
      final db = ref.watch(contentProvider).value;
      if (db == null) return; // current act unknown until content loads
      final console = watchIsConsole(ref, id);
      try {
        final mmr = PlayerMmr.fromJson(
          await ref.read(pvpApiProvider).mmr(id, subject: id),
        );
        if (!ref.mounted) return;
        final current = currentRankOf(
          db,
          mmr,
          now: ref.read(clockProvider).now(),
          console: console,
        );
        final account = ref.read(accountProvider(id));
        if (account == null ||
            current.actUuid == null ||
            (account.rankTier == current.tier &&
                account.rankSeasonId == current.actUuid)) {
          return;
        }
        await ref
            .read(accountsProvider.notifier)
            .updateAccount(
              id,
              (a) => a.copyWith(
                rankTier: current.tier,
                rankSeasonId: current.actUuid,
              ),
            );
      } on Object {
        // Offline, maintenance, odd body: keep the cached rank.
      }
    });
