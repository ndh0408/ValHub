import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../content/content_repository.dart';
import '../domain/competitive/rank_calc.dart';
import '../domain/competitive/rank.dart' show mmrProvider;
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
    // `expiredTime` may be "0", 0 or "0001-01-01T00:00:00Z" on a live session
    // (unset): only a real timestamp (VALORANT launched in 2020) that already
    // passed proves the session is dead.
    final expires = asDateTime(body['expiredTime']);
    if (expires != null &&
        expires.year >= 2020 &&
        !expires.isAfter(now ?? DateTime.now())) {
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

/// Gap between two accounts' checks in one refresh round (account `i` starts
/// `i × stagger` late, at most [kAccountActivityMaxStagger] in total), so ten
/// accounts do not hit Riot in the same instant every 45 s.
const kAccountActivityStagger = Duration(milliseconds: 300);

/// Longest delay of the last account in a round.
const kAccountActivityMaxStagger = Duration(seconds: 3);

/// Delay of the check of the account at [index] in a refresh round.
Duration accountActivityStaggerFor(int index) {
  if (index <= 0) return Duration.zero;
  final d = kAccountActivityStagger * index;
  return d > kAccountActivityMaxStagger ? kAccountActivityMaxStagger : d;
}

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

  /// Pending staggered refreshes of accounts after the first one.
  final List<Timer> _staggered = [];

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
          _refreshStaggered();
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
        _refreshStaggered();
      }
    });
  }

  /// Re-checks every listed account: the first now, the others one after the
  /// other ([accountActivityStaggerFor]).
  void _refreshStaggered() {
    for (final t in _staggered) {
      t.cancel();
    }
    _staggered.clear();
    final accounts = ref.read(accountsProvider);
    for (var i = 0; i < accounts.length; i++) {
      final puuid = accounts[i].puuid;
      final delay = accountActivityStaggerFor(i);
      if (delay == Duration.zero) {
        ref.invalidate(accountActivityProvider(puuid));
      } else {
        _staggered.add(
          Timer(delay, () {
            if (mounted) ref.invalidate(accountActivityProvider(puuid));
          }),
        );
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final t in _staggered) {
      t.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<bool>(appForegroundProvider, (wasForeground, foreground) {
      if (foreground && wasForeground == false && _visible) {
        _refreshStaggered();
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
/// without opening its Profile. Shares the profile's MMR request/cache;
/// failures keep the cached rank.
final accountRankRefreshProvider = FutureProvider.autoDispose
    .family<void, String>((ref, puuid) async {
      final id = puuid.toLowerCase();
      final needsLogin = ref.watch(
        accountProvider(id).select((a) => a?.needsLogin),
      );
      if (needsLogin != false) return;
      final dbFuture = ref.watch(contentProvider.future);
      final mmrFuture = ref.watch(mmrProvider(id).future);
      // Content and MMR load together; handle an early MMR failure while
      // waiting for content too.
      mmrFuture.ignore();
      final console = watchIsConsole(ref, id);
      try {
        final db = await dbFuture;
        final mmr = await mmrFuture;
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
