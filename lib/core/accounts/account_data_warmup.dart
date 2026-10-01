import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderListenable;
import 'package:material_ui/material_ui.dart';

import '../../features/battlepass/providers/battlepass_providers.dart';
import '../domain/competitive/account_xp.dart';
import '../domain/competitive/rank.dart' show mmrProvider;
import '../domain/economy/owned_items.dart';
import '../domain/economy/storefront.dart';
import '../domain/loadout/loadout_providers.dart';
import '../util/clock.dart';
import 'account.dart';
import 'account_providers.dart';
import 'account_status.dart';

final accountDataWarmupProvider = Provider<AccountDataWarmup>((ref) {
  return AccountDataWarmup(ref);
});

typedef _SessionKey = (String, String, GamePlatform);

/// Preloads existing per-account providers, so screens use the same in-flight
/// requests, memory TTLs and offline files. No game or community mutations.
class AccountDataWarmup {
  AccountDataWarmup(this._ref);

  final Ref _ref;
  final _identity = <_SessionKey, Future<void>>{};
  final _pages = <_SessionKey, Future<void>>{};
  final _identityUntil = <_SessionKey, DateTime>{};
  final _pagesUntil = <_SessionKey, DateTime>{};

  _SessionKey? _key(String puuid) {
    if (!_ref.mounted) return null;
    final a = _ref.read(accountProvider(puuid));
    if (a == null || a.needsLogin || a.needsRegionSelection) return null;
    return (a.puuid, a.region, a.platform);
  }

  /// Card, level and rank of a saved account, including inactive accounts.
  Future<void> identity(String puuid) => _run(
    puuid,
    _identity,
    _identityUntil,
    () => Future.wait([
      _fetch(loadoutProvider(puuid).future),
      _fetch(accountXpProvider(puuid).future),
      _fetch(accountRankRefreshProvider(puuid).future),
    ]),
  );

  /// The active account gets store, wallet, missions and collection too.
  /// Identity finishes first; the collection's pooled requests run last.
  Future<void> pages(String puuid) =>
      _run(puuid, _pages, _pagesUntil, () async {
        await identity(puuid);
        if (_key(puuid) == null) return const [false];
        final results = await Future.wait([
          _fetch(storefrontProvider(puuid).future),
          _fetch(walletProvider(puuid).future),
          _fetch(playerContractsProvider(puuid).future),
        ]);
        if (_key(puuid) == null) return results;
        results.add(await _fetch(entitlementsProvider(puuid).future));
        return results;
      });

  Future<void> _run(
    String id,
    Map<_SessionKey, Future<void>> pending,
    Map<_SessionKey, DateTime> until,
    Future<List<bool>> Function() work,
  ) {
    final key = _key(id);
    if (key == null) return Future<void>.value();
    if (pending[key] case final inFlight?) return inFlight;
    final now = _ref.read(clockProvider).now();
    if (until[key]?.isAfter(now) ?? false) return Future<void>.value();
    // Defer work so pending is assigned before completion.
    final future = Future<void>.microtask(() async {
      try {
        final results = await work();
        if (_ref.mounted && _key(id) == key) {
          until[key] = _ref
              .read(clockProvider)
              .now()
              .add(
                results.every((ok) => ok)
                    ? const Duration(minutes: 3)
                    : const Duration(seconds: 30),
              );
        }
      } on Object {
        // Logout, disposal, offline or missing native plugins never fail login.
      } finally {
        pending.remove(key)?.ignore();
      }
    });
    pending[key] = future;
    return future;
  }

  Future<bool> _fetch<T>(ProviderListenable<Future<T>> provider) async {
    if (!_ref.mounted) return false;
    // Hold auto-dispose providers until their request settles, then let their
    // existing domain TTL decide when to release them. Errors are not pinned.
    final sub = _ref.listen(provider, (_, _) {});
    try {
      await _ref.read(provider);
      return true;
    } on Object {
      return false;
    } finally {
      sub.close();
    }
  }

  /// Reauthentication also refreshes a healthy cached session. Wait at most
  /// two seconds for identity; slow requests and page loading continue.
  Future<void> afterLogin(String puuid, {bool refresh = true}) async {
    if (_key(puuid) == null) return;
    if (refresh) {
      _identityUntil.removeWhere((key, _) => key.$1 == puuid);
      _pagesUntil.removeWhere((key, _) => key.$1 == puuid);
      _ref
        ..invalidate(loadoutProvider(puuid))
        ..invalidate(accountXpProvider(puuid))
        ..invalidate(mmrProvider(puuid))
        ..invalidate(accountRankRefreshProvider(puuid))
        ..invalidate(storefrontProvider(puuid))
        ..invalidate(walletProvider(puuid))
        ..invalidate(entitlementsProvider(puuid))
        ..invalidate(playerContractsProvider(puuid));
    }
    unawaited(pages(puuid));
    await identity(puuid).timeout(const Duration(seconds: 2), onTimeout: () {});
  }
}

/// Lives above every route: preloading does not depend on visiting Profile,
/// Collection or Settings. Inactive accounts are staggered to avoid a burst.
class AccountDataWarmupHost extends ConsumerStatefulWidget {
  const AccountDataWarmupHost({super.key, required this.child});
  final Widget child;

  @override
  ConsumerState<AccountDataWarmupHost> createState() => _WarmupHostState();
}

class _WarmupHostState extends ConsumerState<AccountDataWarmupHost>
    with WidgetsBindingObserver {
  final _timers = <Timer>[];
  bool _scheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  void _schedule() {
    if (_scheduled) return;
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted) return;
      for (final timer in _timers) {
        timer.cancel();
      }
      _timers.clear();
      final service = ref.read(accountDataWarmupProvider);
      final active = ref.read(activePuuidProvider);
      if (active != null) unawaited(service.pages(active));
      var index = 0;
      for (final a in ref.read(accountsProvider)) {
        if (a.puuid == active || a.needsLogin || a.needsRegionSelection) {
          continue;
        }
        final id = a.puuid;
        _timers.add(
          Timer(Duration(milliseconds: 500 * ++index), () {
            if (mounted) unawaited(service.identity(id));
          }),
        );
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _schedule();
    if (state == AppLifecycleState.paused) {
      for (final timer in _timers) {
        timer.cancel();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    for (final timer in _timers) {
      timer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Metadata writes must not restart the stagger for the remaining accounts.
    ref.listen(
      accountsProvider.select(
        (accounts) => accounts
            .map(
              (a) =>
                  '${a.puuid}:${a.region}:${a.platform.name}:${a.needsLogin}',
            )
            .join('|'),
      ),
      (_, _) => _schedule(),
    );
    ref.listen(activePuuidProvider, (_, _) => _schedule());
    return widget.child;
  }
}
