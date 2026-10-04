/// "Tài khoản khác" (docs/design/HOME.md §5.7): for users with several
/// accounts, what each other account is doing and whether its saved store
/// still sells a wishlist skin. Wishlist hints come from the storefront
/// copies saved on the device (no network); activity is fetched slowly, only
/// for the rows shown and never for accounts that need to sign in again.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/accounts/account_status.dart';
import '../../../../core/accounts/account_widgets.dart';
import '../../../../core/auth/auth_routes.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/account_labels.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../store/store_routes.dart';
import '../../../store/ui/store_screen.dart' show StoreSegment;
import '../../data/home_accounts.dart';
import '../../data/home_card.dart';
import '../../providers/home_card_providers.dart';
import '../../providers/home_refresh.dart';
import '../home_card_frame.dart';

class OtherAccountsHomeCard extends ConsumerWidget {
  const OtherAccountsHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(homeOtherAccountsProvider);
    if (data == null || data.rows.isEmpty) return const SizedBox.shrink();
    final count = data.rows.length + data.more;
    // The slow activity poll: only the rows shown, never an account that
    // has to sign in again, and only while Home is visible.
    return HomeCardPoller(
      every: kHomeAccountsRefresh,
      onTick: () {
        for (final row
            in ref.read(homeOtherAccountsProvider)?.rows ??
                const <OtherAccountSummary>[]) {
          if (row.account.needsLogin) continue;
          ref.invalidate(accountActivityProvider(row.account.puuid));
        }
      },
      child: HomeCardFrame(
        card: HomeCardId.otherAccounts,
        title: context.l10n.homeOtherAccountsTitle(count),
        childPadding: const EdgeInsetsDirectional.fromSTEB(4, 0, 4, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final row in data.rows) _AccountRow(row: row),
            if (data.more > 0)
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(start: 8),
                  child: TextButton.icon(
                    onPressed: () =>
                        unawaited(showAccountSwitcherSheet(context)),
                    icon: const Icon(Icons.chevron_right),
                    iconAlignment: IconAlignment.end,
                    label: Text(context.l10n.homeOtherMore(data.more)),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// One account: avatar with a status dot, Riot ID, what it does now (color
/// and text) or region and level, and a badge for a wishlist hit or "sign in
/// again".
class _AccountRow extends ConsumerWidget {
  const _AccountRow({required this.row});

  final OtherAccountSummary row;

  void _switchTo(WidgetRef ref) {
    Haptics.selection();
    ref.read(activePuuidProvider.notifier).select(row.account.puuid);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final account = row.account;
    final activity = row.activity;
    final meta = [
      if (account.level != null) context.l10n.accountLevelShort(account.level!),
      context.l10n.riotRegionName(account.region),
    ].join(context.l10n.homeDot);
    final needsLogin = account.needsLogin;
    final subtitle = needsLogin
        ? Text(
            context.l10n.accountNeedsLogin,
            style: theme.textTheme.bodySmall?.copyWith(
              color: legibleAccent(context, valColorsOf(context).warning),
            ),
          )
        : activity == null || activity == AccountActivity.unknown
        ? Text(meta, style: theme.textTheme.bodySmall?.copyWith(color: muted))
        : Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: context.l10n.accountActivityName(activity),
                  style: TextStyle(
                    color: legibleAccent(context, activity.color(context)),
                    fontWeight: activity.isOnline ? FontWeight.w700 : null,
                  ),
                ),
                TextSpan(text: '${context.l10n.homeDot}$meta'),
              ],
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: muted),
          );
    final hit = row.hasHits ? row.liveHits.first : null;
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            label: context.l10n.accountSwitchTo(
              account.displayRiotId(context.l10n),
            ),
            excludeSemantics: true,
            child: InkWell(
              borderRadius: BorderRadius.circular(ValRadius.small),
              onTap: () {
                if (needsLogin) {
                  unawaited(
                    context.push<Object?>(
                      AuthRoutes.loginPath(reauthPuuid: account.puuid),
                    ),
                  );
                } else {
                  _switchTo(ref);
                }
              },
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      _StatusDot(
                        activity: activity,
                        child: AccountAvatar(
                          account: account,
                          size: 40,
                          circle: true,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.displayRiotId(context.l10n),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            subtitle,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        if (hit != null)
          _HitBadge(
            onTap: () {
              _switchTo(ref);
              switch (hit.place) {
                case WishlistPlace.daily:
                  context.go(StoreRoutes.segment(StoreSegment.daily));
                case WishlistPlace.nightMarket:
                  context.go(StoreRoutes.segment(StoreSegment.nightMarket));
                case WishlistPlace.bundle:
                  final id = hit.bundleId;
                  if (id == null) {
                    context.go(StoreRoutes.segment(StoreSegment.bundles));
                  } else {
                    unawaited(context.push<Object?>(StoreRoutes.bundle(id)));
                  }
              }
            },
          ),
      ],
    );
  }
}

class _HitBadge extends StatelessWidget {
  const _HitBadge({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final red = theme.colorScheme.primary;
    final fg = legibleAccent(context, red, min: 4.5);
    return Semantics(
      button: true,
      label: context.l10n.homeOtherWishlistHit,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ValRadius.pill),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Center(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: red.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(ValRadius.pill),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.favorite_rounded, size: 14, color: fg),
                  const SizedBox(width: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 88),
                    child: Text(
                      context.l10n.homeOtherWishlistHit,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: fg,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// A colored dot on the avatar while the account's game runs (the text of
/// the subtitle says the same, so color is never the only cue).
class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.activity, required this.child});

  final AccountActivity? activity;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final a = activity;
    if (a == null || !a.isOnline) return child;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        PositionedDirectional(
          end: -1,
          bottom: -1,
          child: Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: a.color(context),
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surfaceContainer,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
