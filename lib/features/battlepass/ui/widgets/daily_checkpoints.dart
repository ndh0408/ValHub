import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/async_value_view.dart';
import '../../../../core/ui/error_view.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../battlepass_strings.dart';
import '../../data/daily_ticket.dart';
import '../../providers/battlepass_providers.dart';
import 'bp_ui_bits.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// P4 "Nhiệm vụ hằng ngày": the four daily checkpoints of P-16, the reset
/// countdown, and a user-initiated renew when the ticket is missing or
/// expired (SUMMARY U6).
class DailyCheckpointsSection extends ConsumerWidget {
  const DailyCheckpointsSection({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(dailyTicketProvider(puuid));
    final now = ref.watch(clockProvider).now();
    final ticket = ticketAsync.value;
    final expiresAt = ticket?.expiresAt;
    final live = ticket != null && !ticket.isExpired(now);
    void retry() => ref.invalidate(dailyTicketProvider(puuid));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BpSectionTitle(
          title: context.l10n.battlePassDailyMissions,
          subtitle: live && expiresAt != null
              ? context.l10n.battlePassDailyCaptionReset(
                  context.l10n.battlePassResetsAtWall(
                    formatWallTime(expiresAt, now),
                  ),
                )
              : context.l10n.battlePassDailyCaption,
          trailing: live && expiresAt != null
              ? BpHeaderCountdown(
                  expiresAt: expiresAt,
                  builder: context.l10n.battlePassResetsIn,
                  onExpired: retry,
                )
              : null,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: AsyncValueView<DailyTicket?>(
            value: ticketAsync,
            puuid: puuid,
            onRetry: retry,
            loading: const Skeleton(height: 150, radius: 16),
            data: (t) => t == null || t.isExpired(now)
                ? DailyTicketNotReady(puuid: puuid, ticket: t)
                : DailyCheckpointsCard(ticket: t),
          ),
        ),
      ],
    );
  }
}

/// The four checkpoint pips and the progress sentence.
class DailyCheckpointsCard extends StatelessWidget {
  const DailyCheckpointsCard({super.key, required this.ticket});

  final DailyTicket ticket;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final win = valColorsOf(context).win;
    final done = ticket.completedCount;
    final current = ticket.currentIndex;
    return ValCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                for (var i = 0; i < ticket.milestones.length; i++) ...[
                  if (i > 0)
                    Expanded(
                      child: BpProgressBar(
                        value: ticket.milestones[i - 1].isComplete ? 1 : 0,
                        height: 3,
                      ),
                    ),
                  CheckpointPip(
                    index: i + 1,
                    milestone: ticket.milestones[i],
                    isCurrent: i == current,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 14),
            if (ticket.isAllComplete)
              Row(
                children: [
                  Icon(Icons.check_circle, size: 18, color: win),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      context.l10n.battlePassDailyAllDone,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: legibleAccent(context, win),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.battlePassCheckpointsDone(
                      done,
                      kDailyCheckpointCount,
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    context.l10n.battlePassNextCheckpoint(
                      ticket.currentCharges,
                      kChargesPerCheckpoint,
                    ),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            const SizedBox(height: 4),
            Text(
              context.l10n.battlePassCheckpointRewards,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            if (!ticket.isAllComplete)
              Text(
                context.l10n.battlePassCheckpointHint,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            if (ticket.bonusMilestonesPending > 0) ...[
              const SizedBox(height: 4),
              Text(
                context.l10n.battlePassBonusPending(
                  ticket.bonusMilestonesPending,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: valColorsOf(context).warning,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One diamond checkpoint, filled from the bottom by its charges.
class CheckpointPip extends StatelessWidget {
  const CheckpointPip({
    super.key,
    required this.index,
    required this.milestone,
    this.isCurrent = false,
    this.size = 34,
  });

  final int index;
  final DailyMilestone milestone;
  final bool isCurrent;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final complete = milestone.isComplete;
    final accent = scheme.primary;
    final outline = complete || isCurrent ? accent : scheme.outline;
    return Semantics(
      label: context.l10n.battlePassCheckpointLabel(
        index,
        milestone.progress,
        kChargesPerCheckpoint,
      ),
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: size + 8,
            height: size + 8,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                CustomPaint(
                  size: Size.square(size),
                  painter: _DiamondPainter(
                    fraction: milestone.fraction,
                    fill: accent,
                    track: valColorsOf(context).track,
                    outline: outline,
                  ),
                ),
                if (complete)
                  Icon(Icons.check, size: 16, color: scheme.onPrimary),
                if (milestone.bonusApplied)
                  Positioned(
                    right: -6,
                    top: -2,
                    child: BpBadge(
                      context.l10n.battlePassBonusBadge,
                      color: valColorsOf(context).warning,
                      filled: true,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.battlePassCharges(
              milestone.progress,
              kChargesPerCheckpoint,
            ),
            style: theme.textTheme.labelSmall?.copyWith(
              color: complete || isCurrent
                  ? scheme.onSurface
                  : scheme.onSurfaceVariant,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _DiamondPainter extends CustomPainter {
  _DiamondPainter({
    required this.fraction,
    required this.fill,
    required this.track,
    required this.outline,
  });

  final double fraction;
  final Color fill;
  final Color track;
  final Color outline;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final diamond = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, h / 2)
      ..lineTo(w / 2, h)
      ..lineTo(0, h / 2)
      ..close();
    canvas
      ..save()
      ..clipPath(diamond)
      ..drawRect(Offset.zero & size, Paint()..color = track);
    final f = fraction.clamp(0.0, 1.0);
    if (f > 0) {
      canvas.drawRect(
        Rect.fromLTRB(0, h * (1 - f), w, h),
        Paint()..color = fill,
      );
    }
    canvas
      ..restore()
      ..drawPath(
        diamond,
        Paint()
          ..color = outline
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
  }

  @override
  bool shouldRepaint(_DiamondPainter old) =>
      old.fraction != fraction ||
      old.fill != fill ||
      old.track != track ||
      old.outline != outline;
}

/// No ticket today (404) or an expired one: explain, and offer a renew the
/// user must tap (at most once per day).
class DailyTicketNotReady extends ConsumerStatefulWidget {
  const DailyTicketNotReady({super.key, required this.puuid, this.ticket});

  final String puuid;
  final DailyTicket? ticket;

  @override
  ConsumerState<DailyTicketNotReady> createState() =>
      _DailyTicketNotReadyState();
}

class _DailyTicketNotReadyState extends ConsumerState<DailyTicketNotReady> {
  bool _busy = false;

  Future<void> _renew() async {
    setState(() => _busy = true);
    try {
      await ref.read(dailyTicketRenewerProvider).renew(widget.puuid);
      if (mounted) showAppSnackBar(context, BattlePassStrings.renewDone);
    } on Object {
      if (mounted) showAppSnackBar(context, BattlePassStrings.renewFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canRenew = ref
        .watch(dailyTicketRenewerProvider)
        .canRenew(widget.puuid, widget.ticket);
    return ValCard(
      padding: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconTile(
                  icon: Icons.event_repeat,
                  color: valColorsOf(context).warning,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    canRenew
                        ? (widget.ticket == null
                              ? context.l10n.battlePassDailyNotReady
                              : context.l10n.battlePassDailyExpired)
                        : context.l10n.battlePassDailyPlayToStart,
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
              ],
            ),
            if (canRenew) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => unawaited(_renew()),
                  icon: _busy
                      ? const SizedBox.square(
                          dimension: 16,
                          child: CircularProgressIndicator.adaptive(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.refresh, size: 18),
                  label: Text(context.l10n.battlePassRenewButton),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
