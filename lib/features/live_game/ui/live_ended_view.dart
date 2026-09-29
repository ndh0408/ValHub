import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/network/riot_exception.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/section_header.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/util/format.dart';
import '../../profile/profile_routes.dart';
import '../data/live_game_models.dart';
import '../live_game_strings.dart';

/// How often a "still processing" (404) match is fetched again (G11).
const kEndedRetryEvery = Duration(seconds: 20);
const kEndedMaxRetries = 30;

/// Ended state of the sheet (G11): the final scoreboard (K/D/A) once Riot
/// publishes the match, and "Xem chi tiết trận ›" → S43.
class LiveEndedView extends ConsumerStatefulWidget {
  const LiveEndedView({super.key, required this.puuid, required this.ended});

  final String puuid;
  final LiveEndedMatch ended;

  @override
  ConsumerState<LiveEndedView> createState() => _LiveEndedViewState();
}

class _LiveEndedViewState extends ConsumerState<LiveEndedView> {
  Timer? _retry;
  int _attempts = 0;

  String get _id => widget.ended.matchId;

  @override
  void didUpdateWidget(LiveEndedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.ended.matchId != widget.ended.matchId) {
      _retry?.cancel();
      _retry = null;
      _attempts = 0;
    }
  }

  @override
  void dispose() {
    _retry?.cancel();
    super.dispose();
  }

  /// Riot answers 404 until the match is processed: try again later.
  void _scheduleRetry() {
    if (_retry != null || _attempts >= kEndedMaxRetries) return;
    _retry = Timer(kEndedRetryEvery, () {
      _retry = null;
      _attempts++;
      if (mounted) ref.invalidate(matchDetailsProvider(_id));
    });
  }

  Future<void> _refresh() => ref
      .refresh(matchDetailsProvider(_id).future)
      .then<void>((_) {}, onError: (Object _) {});

  void _openDetails() {
    final router = GoRouter.maybeOf(context);
    unawaited(Navigator.of(context).maybePop());
    router?.go(ProfileRoutes.match(_id));
  }

  @override
  Widget build(BuildContext context) {
    final details = ref.watch(matchDetailsProvider(_id));
    final value = details.value;
    final error = details.hasError && !details.isLoading ? details.error : null;
    if (value == null && error is NotFoundException) _scheduleRetry();

    final Widget child;
    if (value != null) {
      child = _Scoreboard(
        details: value,
        puuid: widget.puuid,
        onOpenDetails: _openDetails,
      );
    } else if (error is NotFoundException) {
      child = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          EmptyView(
            icon: Icons.hourglass_top_rounded,
            message:
                '${CompetitiveStrings.matchPending}\n'
                '${LiveGameStrings.matchPendingHint}',
            action: OutlinedButton.icon(
              onPressed: () => ref.invalidate(matchDetailsProvider(_id)),
              icon: const Icon(Icons.refresh),
              label: const Text(CommonStrings.retry),
            ),
          ),
        ],
      );
    } else if (error != null) {
      child = ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          ErrorView(
            error: error,
            puuid: widget.puuid,
            onRetry: () => ref.invalidate(matchDetailsProvider(_id)),
          ),
        ],
      );
    } else {
      child = const SkeletonList(itemCount: 6, itemHeight: 52);
    }
    return RefreshIndicator(onRefresh: _refresh, child: child);
  }
}

class _Scoreboard extends ConsumerWidget {
  const _Scoreboard({
    required this.details,
    required this.puuid,
    required this.onOpenDetails,
  });

  final MatchDetails details;
  final String puuid;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final result = details.resultFor(puuid);
    final myTeam = details.player(puuid)?.teamId;
    final ffa = details.modeKind == MatchModeKind.deathmatch;
    // Same rule as the live roster: Incognito players seen while the match
    // was polled stay anonymous here (SUMMARY U16).
    final hidden = ref
        .watch(matchPrivacyStoreProvider)
        .read(puuid, details.matchId)
        .hiddenIn(details, puuid);
    final outcomeColor = switch (result.outcome) {
      MatchOutcome.win => colors.win,
      MatchOutcome.loss => colors.loss,
      _ => colors.draw,
    };

    final sections = <Widget>[];
    if (ffa) {
      sections
        ..add(const SectionHeader(LiveGameStrings.tabAllPlayers))
        ..addAll([
          for (final s in details.scoreboard)
            if (details.player(s.subject) case final p?)
              _ScoreRow(
                player: p,
                stats: s,
                db: db,
                isSelf: p.subject == puuid,
                hidden: hidden.contains(p.subject),
              ),
        ]);
    } else {
      final sides = [...details.sideIds]
        ..sort((a, b) => (a == myTeam ? 0 : 1).compareTo(b == myTeam ? 0 : 1));
      for (final side in sides) {
        sections.add(
          SectionHeader(
            side == myTeam
                ? LiveGameStrings.tabYourTeam
                : LiveGameStrings.tabEnemyTeam,
          ),
        );
        for (final p in details.playersOfTeam(side)) {
          sections.add(
            _ScoreRow(
              player: p,
              stats: details.statsFor(p.subject),
              db: db,
              isSelf: p.subject == puuid,
              hidden: hidden.contains(p.subject),
            ),
          );
        }
      }
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            children: [
              Text(
                LiveGameStrings.finalScoreboard.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colors.muted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 4,
                children: [
                  Text(
                    result.outcome.label,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: outcomeColor,
                    ),
                  ),
                  if (result.hasScore)
                    Text(
                      LiveGameStrings.score(
                        result.myScore!,
                        result.otherScore!,
                      ),
                      style: theme.textTheme.headlineMedium,
                    ),
                ],
              ),
            ],
          ),
        ),
        const _ColumnsHeader(),
        ...sections,
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: FilledButton.tonalIcon(
            onPressed: onOpenDetails,
            icon: const Icon(Icons.chevron_right),
            iconAlignment: IconAlignment.end,
            label: const Text(
              LiveGameStrings.viewMatchDetails,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

/// "K/D/A · ACS" column labels.
class _ColumnsHeader extends StatelessWidget {
  const _ColumnsHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      letterSpacing: 0.6,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          const Spacer(),
          Text(LiveGameStrings.kda, style: style),
          SizedBox(
            width: 52,
            child: Text(
              LiveGameStrings.acs,
              textAlign: TextAlign.end,
              style: style,
            ),
          ),
        ],
      ),
    );
  }
}

/// Agent, name, K/D/A and ACS of one player.
class _ScoreRow extends StatelessWidget {
  const _ScoreRow({
    required this.player,
    required this.stats,
    required this.db,
    required this.isSelf,
    this.hidden = false,
  });

  final MatchPlayer player;
  final ScoreboardStats? stats;
  final ContentDb db;
  final bool isSelf;

  /// Incognito (and not self / party): show "Người chơi ẩn danh".
  final bool hidden;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final agent = player.characterId == null
        ? null
        : db.agent(player.characterId!);
    final s = stats;
    final kda = s == null
        ? CommonStrings.dash
        : '${formatNumber(s.kills)}/${formatNumber(s.deaths)}/'
              '${formatNumber(s.assists)}';
    final acs = s?.acs;
    final numbers = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.w600,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
    return Container(
      color: isSelf ? theme.colorScheme.primary.withValues(alpha: 0.08) : null,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: NetImage(
              agent?.displayIcon,
              width: 32,
              height: 32,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              playerDisplayName(
                player.name,
                hidden: hidden,
                withTag: false,
                fallback: agent?.displayName,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isSelf ? FontWeight.w700 : null,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: '${LiveGameStrings.kda} $kda',
            excludeSemantics: true,
            child: Text(kda, style: numbers),
          ),
          SizedBox(
            width: 52,
            child: Text(
              acs == null ? CommonStrings.dash : formatNumber(acs.round()),
              textAlign: TextAlign.end,
              style: numbers?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
