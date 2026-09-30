/// TAB 0 "Trang chủ" (docs/design/HOME.md §4): the smart dashboard. A header
/// with the account chip and ⚙, the cards in the user's order (a live match
/// and a blocking maintenance pinned to the top), pull-to-refresh and
/// "Tùy chỉnh Trang chủ".
library;

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/semantics.dart' show SemanticsService;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/accounts/account_widgets.dart';
import '../../../core/auth/auth_routes.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/riot/platform_status.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../../../core/util/clock.dart';
import '../../../core/xmpp/xmpp_providers.dart' show appForegroundProvider;
import '../../community/community_previews.dart';
import '../../settings/ui/settings_gear_button.dart';
import '../data/home_card.dart';
import '../data/home_layout.dart';
import '../home_strings.dart';
import '../providers/home_arrangement.dart';
import '../providers/home_card_providers.dart';
import '../providers/home_layout_provider.dart';
import '../providers/home_refresh.dart';
import 'cards/battlepass_home_card.dart';
import 'cards/community_home_card.dart';
import 'cards/friends_home_card.dart';
import 'cards/live_home_card.dart';
import 'cards/other_accounts_home_card.dart';
import 'cards/rank_home_card.dart';
import 'cards/server_status_home_card.dart';
import 'cards/store_home_card.dart';
import 'customize_home_sheet.dart';
import 'home_card_frame.dart';
import 'home_columns.dart';

/// How long a `?focus=` link waits for its card to have data.
const kHomeFocusWait = Duration(seconds: 5);

/// Widest content (dp); wider screens are centered.
const kHomeMaxContentWidth = 1280.0;

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, this.focus, this.linkNonce});

  /// Card to scroll to (`/home?focus=battlepass`).
  final HomeCardId? focus;

  /// Changes on every deep-link tap, so the same focus applies again.
  final String? linkNonce;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _scroll = ScrollController();
  final _pinnedKey = GlobalKey(debugLabel: 'home.pinned');
  final Map<HomeCardId, GlobalKey> _keys = {
    for (final c in HomeCardId.values)
      c: GlobalKey(debugLabel: 'home.${c.storageId}'),
  };

  String? _puuid;
  HomeCardId? _pendingFocus;
  Timer? _focusTimeout;
  HomeCardId? _pulse;
  Timer? _pulseTimer;
  double? _pinnedHeight;
  DateTime? _backgroundedAt;

  @override
  void initState() {
    super.initState();
    _pendingFocus = widget.focus;
    if (_pendingFocus != null) _armFocusTimeout();
  }

  @override
  void didUpdateWidget(HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final focus = widget.focus;
    if (focus != null &&
        (focus != oldWidget.focus || widget.linkNonce != oldWidget.linkNonce)) {
      _pendingFocus = focus;
      _armFocusTimeout();
    }
  }

  void _armFocusTimeout() {
    _focusTimeout?.cancel();
    _focusTimeout = Timer(kHomeFocusWait, () => _pendingFocus = null);
  }

  @override
  void dispose() {
    _focusTimeout?.cancel();
    _pulseTimer?.cancel();
    _scroll.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ scrolling

  /// After the first frame in which the pending focus card is shown: scroll
  /// it into view, pulse its border and announce it. A hidden card leaves
  /// the scroll at the top and announces nothing.
  void _applyFocus(HomeArrangement arrangement) {
    final card = _pendingFocus;
    if (card == null || !arrangement.all.contains(card)) return;
    _pendingFocus = null;
    _focusTimeout?.cancel();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = _keys[card]?.currentContext;
      if (target == null) return;
      final reduced = homeReducedMotion(context);
      unawaited(
        Scrollable.ensureVisible(
          target,
          alignment: 0.1,
          duration: reduced ? Duration.zero : ValMotion.medium,
          curve: ValMotion.curve,
        ),
      );
      if (!reduced) {
        setState(() => _pulse = card);
        _pulseTimer?.cancel();
        _pulseTimer = Timer(const Duration(seconds: 1), () {
          if (mounted) setState(() => _pulse = null);
        });
      }
      if (MediaQuery.supportsAnnounceOf(context)) {
        unawaited(
          SemanticsService.sendAnnouncement(
            View.of(context),
            HomeStrings.focused(card.title),
            Directionality.of(context),
          ),
        );
      }
    });
  }

  /// A pinned card appearing or leaving while the user is scrolled down
  /// must not push the visible cards: compensate the scroll offset by the
  /// change of the pinned region's height.
  void _anchorPinned() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final render = _pinnedKey.currentContext?.findRenderObject();
      final height = render is RenderBox && render.hasSize
          ? render.size.height
          : 0.0;
      final before = _pinnedHeight;
      _pinnedHeight = height;
      if (before == null || before == height || !_scroll.hasClients) return;
      final position = _scroll.position;
      if (position.pixels <= 0) return;
      position.jumpTo(
        (position.pixels + (height - before)).clamp(
          position.minScrollExtent,
          position.maxScrollExtent,
        ),
      );
    });
  }

  void _onAccountChanged(String? puuid) {
    if (_puuid == puuid) return;
    final first = _puuid == null;
    _puuid = puuid;
    if (first) return;
    // Another account: its cards start at the top.
    _pinnedHeight = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
    });
  }

  // ---------------------------------------------------------- polling

  void _pollStatus() {
    if (ref.read(homeLayoutProvider).isHidden(HomeCardId.serverStatus)) return;
    for (final region in ref.read(homeStatusRegionsProvider)) {
      ref.invalidate(platformStatusProvider(region));
    }
  }

  void _pollLfg() {
    final puuid = _puuid;
    if (puuid == null ||
        !ref.read(homeStartupGateProvider) ||
        ref.read(homeLayoutProvider).isHidden(HomeCardId.community)) {
      return;
    }
    ref.invalidate(matchingLfgPreviewProvider(puuid));
  }

  // ------------------------------------------------------------ build

  Widget _card(HomeCardId id, String puuid) => switch (id) {
    HomeCardId.live => LiveHomeCard(puuid: puuid),
    HomeCardId.store => StoreHomeCard(puuid: puuid),
    HomeCardId.rank => RankHomeCard(puuid: puuid),
    HomeCardId.battlePass => BattlePassHomeCard(puuid: puuid),
    HomeCardId.friends => const FriendsHomeCard(),
    HomeCardId.community => CommunityHomeCard(puuid: puuid),
    HomeCardId.otherAccounts => const OtherAccountsHomeCard(),
    HomeCardId.serverStatus => const ServerStatusHomeCard(),
  };

  Widget _slot(HomeCardId id, String puuid) =>
      _CardSlot(key: _keys[id], pulse: _pulse == id, child: _card(id, puuid));

  @override
  Widget build(BuildContext context) {
    final puuid = ref.watch(activeAccountProvider.select((a) => a?.puuid));
    final needsLogin = ref.watch(
      activeAccountProvider.select((a) => a?.needsLogin ?? false),
    );
    _onAccountChanged(puuid);

    // Coming back after a while: the community previews and the server
    // status may be stale (everything else follows its own TTL).
    ref.listen<bool>(appForegroundProvider, (was, foreground) {
      final now = ref.read(clockProvider).now();
      if (!foreground) {
        _backgroundedAt = now;
        return;
      }
      final away = _backgroundedAt;
      _backgroundedAt = null;
      if (away != null && now.difference(away) >= kHomeResumeRefreshAfter) {
        _pollStatus();
        _pollLfg();
      }
    });

    final roomy = MediaQuery.sizeOf(context).width >= 360;
    if (puuid == null) {
      return const TabPageScaffold(
        title: HomeStrings.title,
        showAccountChip: false,
        showMaintenanceBanner: false,
        body: EmptyView(
          message: CommonStrings.errorNoAccount,
          icon: Icons.person_off_outlined,
        ),
      );
    }

    final arrangement = ref.watch(homeArrangementProvider(puuid));
    _applyFocus(arrangement);
    _anchorPinned();

    final size = MediaQuery.sizeOf(context);
    final side = math.max(
      ValSpace.gutter,
      (size.width - kHomeMaxContentWidth) / 2,
    );

    return HomeCardPoller(
      every: kHomeStatusRefresh,
      onTick: _pollStatus,
      child: HomeCardPoller(
        every: kHomeLfgRefresh,
        onTick: _pollLfg,
        child: TabPageScaffold(
          title: HomeStrings.title,
          showAccountChip: false,
          // The server-status card replaces the banner (no duplicate).
          showMaintenanceBanner: false,
          controller: _scroll,
          actions: [
            AccountChip(showName: roomy),
            const SettingsGearButton(),
          ],
          onRefresh: () => refreshHome(ref, puuid: puuid, shown: arrangement),
          slivers: [
            SliverSafeArea(
              top: false,
              bottom: false,
              sliver: SliverPadding(
                padding: EdgeInsets.fromLTRB(side, 4, side, 0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (needsLogin) ...[
                        _NeedsLoginBanner(puuid: puuid),
                        const SizedBox(height: kHomeCardGap),
                      ],
                      // Full width: a blocking maintenance, then a live match.
                      Column(
                        key: _pinnedKey,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (final id in arrangement.pinned) ...[
                            _slot(id, puuid),
                            const SizedBox(height: kHomeCardGap),
                          ],
                        ],
                      ),
                      HomeColumns(
                        cards: arrangement.flow,
                        sidePadding: side,
                        builder: (context, id, index) => _slot(id, puuid),
                      ),
                      if (arrangement.allUserHidden)
                        EmptyView(
                          icon: Icons.visibility_off_outlined,
                          title: HomeStrings.allHiddenTitle,
                          message: HomeStrings.allHiddenBody,
                          action: FilledButton.icon(
                            onPressed: () =>
                                unawaited(showCustomizeHomeSheet(context)),
                            icon: const Icon(Icons.tune_rounded),
                            label: const Text(HomeStrings.customize),
                          ),
                        )
                      else if (arrangement.isEmpty)
                        const EmptyView(
                          icon: Icons.inbox_outlined,
                          title: HomeStrings.quietTitle,
                          message: HomeStrings.quietBody,
                        ),
                      // Also in the quiet state: the user can still arrange the
                      // cards for when they have something to show.
                      if (!arrangement.allUserHidden)
                        Align(
                          alignment: Alignment.center,
                          child: TextButton.icon(
                            onPressed: () =>
                                unawaited(showCustomizeHomeSheet(context)),
                            icon: const Icon(Icons.tune_rounded),
                            label: const Text(HomeStrings.customize),
                          ),
                        ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A card with an accent border that pulses once after a `?focus=` link.
class _CardSlot extends StatelessWidget {
  const _CardSlot({super.key, required this.pulse, required this.child});

  final bool pulse;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: pulse ? 1 : 0,
              duration: ValMotion.medium,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ValRadius.card),
                  border: Border.all(color: color, width: 2),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// One banner under the header when the active account's session died: the
/// Riot cards are hidden instead of five identical errors.
class _NeedsLoginBanner extends ConsumerWidget {
  const _NeedsLoginBanner({required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final warning = valColorsOf(context).warning;
    final riotId =
        ref.watch(activeAccountProvider.select((a) => a?.riotId)) ?? '';
    return Material(
      color: warning.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(ValRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_clock_outlined,
              color: legibleAccent(context, warning, min: 3),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      CommonStrings.errorNeedsLoginTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    HomeStrings.needsLoginBody(riotId),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => unawaited(
                      context.push<Object?>(
                        AuthRoutes.loginPath(reauthPuuid: puuid),
                      ),
                    ),
                    child: const Text(CommonStrings.signInAgain),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
