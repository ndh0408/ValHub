import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../accounts/account.dart';
import '../accounts/account_providers.dart';
import '../content/content_repository.dart';
import '../domain/progress_events.dart';
import '../l10n/notification_strings.dart';
import '../settings/app_settings.dart';
import '../storage/prefs.dart';
import '../util/clock.dart';
import '../util/json.dart';
import 'notification_service.dart';

/// Consumes observations that the UI already fetched. It never polls Riot or
/// requests notification permission. The baseline prevents first-login alerts.
class ProgressNotificationPlanner {
  ProgressNotificationPlanner(this.prefs, this.notifications, this.clock);
  final Prefs prefs;
  final NotificationService notifications;
  final Clock clock;
  Future<void> _pending = Future.value();

  Future<void> observe(
    ProgressObserved event, {
    required Account? Function() account,
    String Function(int)? tierName,
  }) {
    final done = _pending.then((_) => _observe(event, account, tierName));
    _pending = done.catchError((Object _) {});
    return done;
  }

  Future<void> _observe(
    ProgressObserved event,
    Account? Function() findAccount,
    String Function(int)? tierName,
  ) async {
    final account = findAccount();
    if (account == null || account.needsLogin || account.needsRegionSelection) {
      return;
    }
    final settings = readAppSettings(prefs);
    switch (event) {
      case RankObserved():
        final key = PrefKeys.account(event.puuid, 'notification.rankSeen');
        final prior = asMap(prefs.getJson(key));
        await prefs.setJson(key, {'season': event.season, 'tier': event.tier});
        if (findAccount() == null ||
            !settings.rankNotifications ||
            event.tier < 3 ||
            prior?['season'] != event.season ||
            asInt(prior?['tier']) == event.tier ||
            asInt(prior?['tier']) == null) {
          return;
        }
        await notifications.showNow(
          id: NotificationIds.forKey('rank:${event.puuid}:${event.season}'),
          title: NotificationStrings.rankChangedTitle,
          body: NotificationStrings.rankChangedBody(
            tierName?.call(event.tier) ?? '${event.tier}',
          ),
          channel: NotificationChannel.rank,
          accountPuuid: event.puuid,
          payload: Uri(
            path: '/profile',
            queryParameters: {'account': event.puuid},
          ).toString(),
        );
      case PassObserved():
        final key = PrefKeys.account(event.puuid, 'notification.passSeen');
        final prior = asMap(prefs.getJson(key));
        await prefs.setJson(key, {'pass': event.passId, 'level': event.level});
        if (findAccount() == null) return;
        final id = NotificationIds.forKey('battlepass_end:${event.puuid}');
        final end = event.endsAt;
        final at = end?.subtract(const Duration(days: 1));
        if (!settings.battlePassNotifications ||
            event.total <= 0 ||
            event.level >= event.total ||
            at == null ||
            !at.isAfter(clock.now())) {
          await notifications.cancel(id);
        } else {
          await notifications.scheduleAt(
            id: id,
            at: at,
            title: NotificationStrings.passEndingTitle,
            body: NotificationStrings.passEndingBody,
            channel: NotificationChannel.battlePass,
            accountPuuid: event.puuid,
            payload: Uri(
              path: '/battlepass',
              queryParameters: {'account': event.puuid},
            ).toString(),
          );
        }
        final oldLevel = asInt(prior?['level']);
        if (findAccount() == null ||
            !settings.battlePassNotifications ||
            prior?['pass'] != event.passId ||
            oldLevel == null ||
            event.level <= oldLevel ||
            event.level ~/ 10 <= oldLevel ~/ 10) {
          return;
        }
        await notifications.showNow(
          id: NotificationIds.forKey('battlepass_progress:${event.puuid}'),
          title: NotificationStrings.passProgressTitle,
          body: NotificationStrings.passProgressBody(event.level),
          channel: NotificationChannel.battlePass,
          accountPuuid: event.puuid,
          payload: Uri(
            path: '/battlepass',
            queryParameters: {'account': event.puuid},
          ).toString(),
        );
    }
  }
}

class ProgressNotificationHost extends ConsumerStatefulWidget {
  const ProgressNotificationHost({super.key, required this.child});
  final Widget child;
  @override
  ConsumerState<ProgressNotificationHost> createState() =>
      _ProgressNotificationHostState();
}

class _ProgressNotificationHostState
    extends ConsumerState<ProgressNotificationHost> {
  StreamSubscription<ProgressObserved>? _subscription;
  @override
  void initState() {
    super.initState();
    final planner = ProgressNotificationPlanner(
      ref.read(prefsProvider),
      ref.read(notificationServiceProvider),
      ref.read(clockProvider),
    );
    _subscription = ref.read(progressEventsProvider).events.listen((event) {
      unawaited(
        planner
            .observe(
              event,
              account: () =>
                  mounted ? ref.read(accountProvider(event.puuid)) : null,
              tierName: (tier) => mounted
                  ? ref
                            .read(contentProvider)
                            .value
                            ?.tier(
                              tier,
                              seasonUuid: event is RankObserved
                                  ? event.season
                                  : null,
                            )
                            ?.displayName ??
                        '$tier'
                  : '$tier',
            )
            .catchError((Object _) {}),
      );
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
