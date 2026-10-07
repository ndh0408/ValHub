import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/countdown_ring.dart';
import '../../../core/ui/countdown_text.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../data/live_game_models.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Typical length of agent select (competitive: 85 s), for the timer ring.
const kAgentSelectPeriod = Duration(seconds: 85);

/// Agent select at a glance (G4, information only): time left, how many
/// enemies locked, and the agent you hovered / locked in the game. Agents
/// are picked in VALORANT: Riot bans "instalock tools" (patch 13.05), which
/// used the same pregame calls a phone-side pick would.
class AgentSelectInfo extends StatelessWidget {
  const AgentSelectInfo({
    super.key,
    required this.match,
    required this.myAgent,
    required this.myLocked,
    required this.onExpired,
  });

  final LiveMatch match;
  final Agent? myAgent;
  final bool myLocked;
  final VoidCallback onExpired;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = valColorsOf(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final endsAt = match.phaseEndsAt;
    final enemySize = match.enemyTeamSize ?? 0;
    final agent = myAgent;
    final timer = endsAt == null
        ? null
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CountdownRing(
                expiresAt: endsAt,
                period: kAgentSelectPeriod,
                size: 18,
                color: colors.warning,
              ),
              const SizedBox(width: 6),
              CountdownText(
                expiresAt: endsAt,
                format: (d) => formatMinutesSeconds(d, padMinutes: false),
                builder: context.l10n.liveGameTimeLeft,
                onExpired: onExpired,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: colors.warning,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          );
    return ValCard(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 6),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.sports_esports_outlined,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(context.l10n.liveGamePickInGame, style: muted),
              ),
            ],
          ),
          if (timer != null || enemySize > 0) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 16,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ?timer,
                if (enemySize > 0)
                  Text(
                    context.l10n.liveGameEnemyLocked(
                      (match.enemyTeamLockCount ?? 0).clamp(0, enemySize),
                      enemySize,
                    ),
                    style: muted,
                  ),
              ],
            ),
          ],
          if (agent != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(
                  myLocked ? Icons.lock : Icons.radio_button_checked,
                  size: 16,
                  color: myLocked ? colors.win : theme.colorScheme.primary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    myLocked
                        ? context.l10n.liveGameYouLocked(agent.displayName)
                        : context.l10n.liveGameYouHover(agent.displayName),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: myLocked ? colors.win : null,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
