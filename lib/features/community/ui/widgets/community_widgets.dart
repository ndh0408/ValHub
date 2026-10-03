import 'package:valvn/features/community/ui/community_error.dart';

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart' hide ErrorDescription;

import '../../../../core/auth/auth_routes.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/geo/countries.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/filter_bar.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/rank_badge.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/util/clock.dart';
import '../../../../core/util/format.dart';
import '../../data/community_exception.dart';
import '../../data/community_models.dart';
import '../consent/consent_sheet.dart';

import 'package:valvn/core/l10n/l10n.dart';

// ---------------------------------------------------------------- segments

/// One segment of [GlassSegmentedControl].
class GlassSegment<T> {
  const GlassSegment({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Glass capsule with a sliding red highlight ("Bảng tin · Tìm đồng đội ·
/// Xếp hạng skin"). The "glass" is a translucent surface with a hairline
/// and a top sheen — no BackdropFilter, so it stays cheap over lists.
class GlassSegmentedControl<T> extends StatelessWidget {
  const GlassSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
    this.height = 44,
    this.margin = const EdgeInsets.symmetric(horizontal: 16),
    this.compact = false,
  });

  final List<GlassSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;
  final double height;
  final EdgeInsetsGeometry margin;

  /// Smaller text (secondary toggles such as "Tất cả / Tuần này").
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final index = math.max(0, segments.indexWhere((s) => s.value == selected));
    final textStyle =
        (compact
                ? Theme.of(context).textTheme.labelMedium
                : Theme.of(context).textTheme.labelLarge)
            ?.copyWith(fontWeight: FontWeight.w700);
    return Padding(
      padding: margin,
      child: Container(
        height: height,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ValRadius.pill),
          border: Border.all(
            color: dark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.06),
          ),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(
                Colors.white.withValues(alpha: dark ? 0.06 : 0.5),
                scheme.surfaceContainer,
              ).withValues(alpha: 0.92),
              scheme.surfaceContainer.withValues(alpha: 0.78),
            ],
          ),
        ),
        child: LayoutBuilder(
          builder: (context, box) {
            final w = box.maxWidth / segments.length;
            return Stack(
              children: [
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  left: w * index,
                  top: 0,
                  bottom: 0,
                  width: w,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(
                        Radius.circular(ValRadius.pill),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFF5A67), Color(0xFFE23445)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x55FF4655),
                          blurRadius: 12,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (var i = 0; i < segments.length; i++)
                      Expanded(
                        child: _GlassSegmentButton(
                          label: segments[i].label,
                          icon: segments[i].icon,
                          selected: i == index,
                          style: textStyle,
                          onTap: () {
                            if (i != index) {
                              unawaited(HapticFeedback.selectionClick());
                              onChanged(segments[i].value);
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _GlassSegmentButton extends StatelessWidget {
  const _GlassSegmentButton({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.style,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurfaceVariant;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: (style ?? const TextStyle()).copyWith(color: color),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 16, color: color),
                      const SizedBox(width: 6),
                    ],
                    Text(label, maxLines: 1),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------------- chips

/// Filter / choice chip of the community tab (the app's `ValFilterChip`).
class CommunityChip extends StatelessWidget {
  const CommunityChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
    this.dotColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;
  final Color? dotColor;

  @override
  Widget build(BuildContext context) => ValFilterChip(
    label: label,
    selected: selected,
    icon: icon,
    dotColor: dotColor,
    onSelected: (_) => onSelected(),
  );
}

/// Pill that opens a popup menu ("Châu Á ▾"): [items] are (value, label).
class CommunityMenuChip<T> extends StatelessWidget {
  const CommunityMenuChip({
    super.key,
    required this.icon,
    required this.label,
    required this.tooltip,
    required this.items,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final String tooltip;
  final List<(T, String)> items;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return PopupMenuButton<T>(
      tooltip: tooltip,
      onSelected: onSelected,
      itemBuilder: (context) => [
        for (final (v, l) in items) PopupMenuItem(value: v, child: Text(l)),
      ],
      child: Chip(
        avatar: Icon(icon, size: 16),
        shape: const StadiumBorder(),
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 2),
            Icon(Icons.expand_more_rounded, size: 16, color: muted),
          ],
        ),
      ),
    );
  }
}
// ------------------------------------------------------------------ author

/// Round avatar of a community author: their player card art, or the red
/// gradient with an initial.
class CommunityAvatar extends ConsumerWidget {
  const CommunityAvatar({
    super.key,
    required this.author,
    this.size = 40,
    this.ring,
  });

  final CommunityAuthor author;
  final double size;

  /// Optional colored ring (e.g. red for the user's own posts).
  final Color? ring;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardId = author.cardId;
    final art = cardId == null
        ? null
        : ref.watch(
            contentProvider.select((c) => c.value?.card(cardId)?.smallArt),
          );
    final initial = author.gameName.isEmpty
        ? '?'
        : author.gameName.characters.first.toUpperCase();
    final fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF4655), Color(0xFF8A1E2A)],
        ),
      ),
      child: Text(
        initial,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: size * 0.42,
          color: Colors.white,
        ),
      ),
    );
    final avatar = ClipOval(
      child: art == null
          ? fallback
          : NetImage(
              art,
              width: size,
              height: size,
              fit: BoxFit.cover,
              error: fallback,
              showSkeleton: false,
            ),
    );
    final r = ring;
    if (r == null) return avatar;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: r, width: 2),
      ),
      child: avatar,
    );
  }
}

/// Author header: avatar, Riot ID, rank icon, relative time and a "Bạn"
/// badge on the user's own content.
class AuthorRow extends ConsumerWidget {
  const AuthorRow({
    super.key,
    required this.author,
    this.createdAt,
    this.isMe = false,
    this.avatarSize = 40,
    this.trailing,
    this.subtitle,
  });

  final CommunityAuthor author;
  final DateTime? createdAt;
  final bool isMe;
  final double avatarSize;
  final Widget? trailing;

  /// Replaces the time line.
  final String? subtitle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final now = ref.watch(clockProvider).now();
    final at = createdAt;
    final tier = author.rankTier;
    final countryName = author.country == null
        ? null
        : ref.watch(countryNamesProvider).value?.name(author.country!) ??
              author.country;
    final line = subtitle ?? (at == null ? null : formatRelative(at, now));
    return Row(
      children: [
        CommunityAvatar(
          author: author,
          size: avatarSize,
          ring: isMe ? ValColors.red : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: author.gameName.isEmpty
                                ? context.l10n.communityUnknownPlayer
                                : author.gameName,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          if (author.tagLine.isNotEmpty)
                            TextSpan(
                              text:
                                  ' ${context.l10n.communityTagSuffix(author.tagLine)}',
                              style: TextStyle(
                                color: muted,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                  if (author.country != null) ...[
                    const SizedBox(width: 6),
                    Tooltip(
                      message: countryName!,
                      child: Text(
                        flagEmoji(author.country),
                        style: const TextStyle(fontSize: 14),
                        semanticsLabel: countryName,
                      ),
                    ),
                  ],
                  if (tier != null && tier > 2) ...[
                    const SizedBox(width: 6),
                    RankBadge(tier: tier, size: 18, showName: false),
                  ],
                  if (isMe) ...[
                    const SizedBox(width: 6),
                    _MiniBadge(context.l10n.communityYou),
                  ],
                ],
              ),
              if (line != null) ...[
                const SizedBox(height: 2),
                Text(
                  line,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: ValColors.red.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall
            ?.copyWith(color: ValColors.red, fontWeight: FontWeight.w700),
      ),
    );
  }
}

// ------------------------------------------------------------- animations

/// A number that slides / fades when it changes.
class AnimatedCount extends StatelessWidget {
  const AnimatedCount({
    super.key,
    required this.value,
    this.style,
    this.format = _plain,
  });

  final int value;
  final TextStyle? style;
  final String Function(int value) format;

  static String _plain(int v) => formatNumber(v);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final incoming = child.key == ValueKey(value);
        final offset = Tween<Offset>(
          begin: Offset(0, incoming ? 0.6 : -0.6),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(position: offset, child: child),
        );
      },
      layoutBuilder: (current, previous) => Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [...previous, ?current],
      ),
      child: Text(
        format(value),
        key: ValueKey(value),
        style: style,
        maxLines: 1,
      ),
    );
  }
}

/// Heart toggle with a scale pop, a ring and a particle burst when it turns
/// on, plus a haptic tick. [count] (optional) animates beside it.
class HeartButton extends StatefulWidget {
  const HeartButton({
    super.key,
    required this.active,
    required this.onTap,
    this.count,
    this.size = 22,
    this.semanticsOn,
    this.semanticsOff,
    this.dense = false,
  });

  final bool active;
  final VoidCallback? onTap;
  final int? count;
  final double size;
  final String? semanticsOn;
  final String? semanticsOff;
  final bool dense;

  @override
  State<HeartButton> createState() => _HeartButtonState();
}

class _HeartButtonState extends State<HeartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _burst = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  late final Animation<double> _scale = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween(
        begin: 1.0,
        end: 1.32,
      ).chain(CurveTween(curve: Curves.easeOut)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween(
        begin: 1.32,
        end: 1.0,
      ).chain(CurveTween(curve: Curves.elasticOut)),
      weight: 65,
    ),
  ]).animate(_burst);

  @override
  void didUpdateWidget(HeartButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active && !oldWidget.active && !_burst.isAnimating) {
      _burst.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _burst.dispose();
    super.dispose();
  }

  void _tap() {
    unawaited(HapticFeedback.lightImpact());
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final color = widget.active ? ValColors.red : muted;
    final heart = SizedBox(
      width: widget.size + 12,
      height: widget.size + 12,
      child: AnimatedBuilder(
        animation: _burst,
        builder: (context, child) => CustomPaint(
          painter: _BurstPainter(_burst.value),
          child: Center(
            child: Transform.scale(scale: _scale.value, child: child),
          ),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 160),
          transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
          child: Icon(
            widget.active ? Icons.favorite_rounded : Icons.favorite_border,
            key: ValueKey(widget.active),
            size: widget.size,
            color: color,
          ),
        ),
      ),
    );
    final count = widget.count;
    return Semantics(
      container: true,
      button: true,
      toggled: widget.active,
      label: widget.active
          ? widget.semanticsOn ?? context.l10n.communityUnlike
          : widget.semanticsOff ?? context.l10n.communityLike,
      value: count == null ? null : formatNumber(count),
      onTap: widget.onTap == null ? null : _tap,
      excludeSemantics: true,
      child: InkWell(
        onTap: widget.onTap == null ? null : _tap,
        borderRadius: BorderRadius.circular(ValRadius.pill),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: widget.dense ? 2 : 6,
            vertical: widget.dense ? 0 : 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              heart,
              if (count != null) ...[
                const SizedBox(width: 2),
                AnimatedCount(
                  value: count,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: widget.active ? ValColors.red : muted,
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Ring + 8 particles around the heart while [t] runs 0 → 1.
class _BurstPainter extends CustomPainter {
  _BurstPainter(this.t);

  final double t;

  static const _colors = [
    ValColors.red,
    Color(0xFFFFB0B7),
    ValColors.gold,
    Color(0xFFFF7A85),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0 || t >= 1) return;
    final center = size.center(Offset.zero);
    final maxR = size.shortestSide * 0.62;
    // Ring expands and thins out during the first half.
    if (t < 0.55) {
      final p = t / 0.55;
      canvas.drawCircle(
        center,
        maxR * (0.35 + 0.65 * p),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3 * (1 - p) + 0.5
          ..color = ValColors.red.withValues(alpha: 0.55 * (1 - p)),
      );
    }
    // Particles fly out in the second part.
    final p = ((t - 0.15) / 0.85).clamp(0.0, 1.0);
    if (p <= 0) return;
    final paint = Paint();
    for (var i = 0; i < 8; i++) {
      final angle = (math.pi * 2 / 8) * i - math.pi / 2;
      final r = maxR * (0.55 + 0.6 * Curves.easeOut.transform(p));
      final dot = 2.6 * (1 - p) + 0.4;
      paint.color = _colors[i % _colors.length].withValues(alpha: 1 - p);
      canvas.drawCircle(
        center + Offset(math.cos(angle), math.sin(angle)) * r,
        dot,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter oldDelegate) => oldDelegate.t != t;
}

// ------------------------------------------------------------------ states

/// Friendly empty state: glowing icon medallion, title, message, action.
class CommunityEmptyState extends StatelessWidget {
  const CommunityEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.action,
    this.padding = const EdgeInsets.fromLTRB(24, 24, 24, 24),
  });

  final IconData icon;
  final String title;
  final String message;
  final Widget? action;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: theme.colorScheme.surfaceContainer,
            ),
            child: Icon(
              icon,
              size: 28,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (action != null) ...[const SizedBox(height: 20), action!],
        ],
      ),
    );
  }
}

/// Error state for community data (Vietnamese copy, "Thử lại", or
/// "Đăng nhập lại" when the Riot session is dead).
class CommunityErrorState extends StatelessWidget {
  const CommunityErrorState({
    super.key,
    required this.error,
    this.onRetry,
    this.puuid,
    this.compact = false,
  });

  final Object error;
  final VoidCallback? onRetry;
  final String? puuid;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final d = describeCommunityError(context.l10n, error);
    final theme = Theme.of(context);
    final button = d.needsLogin
        ? FilledButton(
            onPressed: () => context.push(
              AuthRoutes.loginPath(reauthPuuid: d.puuid ?? puuid),
            ),
            child: Text(context.l10n.commonSignInAgain),
          )
        : (onRetry != null && d.canRetry)
        ? OutlinedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.l10n.commonRetry),
          )
        : null;
    if (compact) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            Icon(d.icon, color: theme.colorScheme.error, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                d.message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (button != null) ...[const SizedBox(width: 8), button],
          ],
        ),
      );
    }
    return CommunityEmptyState(
      icon: d.icon,
      title: d.title ?? context.l10n.communityErrorTitle,
      message: d.message,
      action: button,
    );
  }
}

/// Snackbar with the Vietnamese message of [error].
void showCommunityError(BuildContext context, Object error) {
  if (error is CommunityException &&
      error.code == CommunityException.consentRequired) {
    // Not a failure: ask for the missing consent instead.
    unawaited(promptConsentFromContext(context));
    return;
  }
  final messenger = ScaffoldMessenger.maybeOf(context);
  messenger
    ?..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(describeCommunityError(context.l10n, error).message),
      ),
    );
}

/// Adaptive confirmation dialog (Cupertino look on iOS).
Future<bool> confirmCommunityAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
  bool destructive = true,
}) async {
  final ok = await showAdaptiveDialog<bool>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(title),
      content: Text(body),
      actions: [
        adaptiveDialogAction(
          context,
          label: context.l10n.commonCancel,
          onPressed: () => Navigator.of(context).pop(false),
        ),
        adaptiveDialogAction(
          context,
          label: confirmLabel,
          primary: true,
          destructive: destructive,
          onPressed: () => Navigator.of(context).pop(true),
        ),
      ],
    ),
  );
  return ok ?? false;
}

/// A dialog action that looks native on iOS and Android.
Widget adaptiveDialogAction(
  BuildContext context, {
  required String label,
  required VoidCallback onPressed,
  bool primary = false,
  bool destructive = false,
}) {
  final platform = Theme.of(context).platform;
  final cupertino =
      platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
  if (cupertino) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: destructive
            ? ValColors.red
            : Theme.of(context).colorScheme.onSurface,
        textStyle: TextStyle(
          fontWeight: primary ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      child: Text(label),
    );
  }
  if (!primary) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      child: Text(label),
    );
  }
  return FilledButton(
    style: destructive
        ? FilledButton.styleFrom(backgroundColor: ValColors.red)
        : null,
    onPressed: onPressed,
    child: Text(label),
  );
}

// ------------------------------------------------------------------ paging

/// Footer of a paged list: triggers [onLoadMore] when it becomes visible,
/// shows a spinner while loading and a retry row after a failure.
class PagedFooter extends StatefulWidget {
  const PagedFooter({
    super.key,
    required this.hasMore,
    required this.loading,
    required this.error,
    required this.onLoadMore,
  });

  final bool hasMore;
  final bool loading;
  final Object? error;
  final VoidCallback onLoadMore;

  @override
  State<PagedFooter> createState() => _PagedFooterState();
}

class _PagedFooterState extends State<PagedFooter> {
  @override
  void initState() {
    super.initState();
    _maybeLoad();
  }

  @override
  void didUpdateWidget(PagedFooter oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeLoad();
  }

  void _maybeLoad() {
    if (!widget.hasMore || widget.loading || widget.error != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted &&
          widget.hasMore &&
          !widget.loading &&
          widget.error == null) {
        widget.onLoadMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = widget.error;
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                describeCommunityError(context.l10n, error).message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            TextButton(
              onPressed: widget.onLoadMore,
              child: Text(context.l10n.commonRetry),
            ),
          ],
        ),
      );
    }
    if (!widget.hasMore) return const SizedBox(height: 8);
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: SizedBox(
          width: 22,
          height: 22,
          child: CircularProgressIndicator(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

// --------------------------------------------------------------- skeletons

/// Skeleton matching [PostCard] (avatar row, two text lines, image).
class PostCardSkeleton extends StatelessWidget {
  const PostCardSkeleton({super.key, this.withMedia = true});

  final bool withMedia;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Skeleton(width: 40, height: 40, radius: 20, shimmer: false),
              SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(width: 140, height: 14, shimmer: false),
                  SizedBox(height: 6),
                  Skeleton(width: 70, height: 10, shimmer: false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Skeleton(height: 12, shimmer: false),
          const SizedBox(height: 8),
          const Skeleton(width: 200, height: 12, shimmer: false),
          if (withMedia) ...[
            const SizedBox(height: 14),
            const AspectRatio(
              aspectRatio: 16 / 10,
              child: Skeleton(height: null, radius: 12, shimmer: false),
            ),
          ],
          const SizedBox(height: 14),
          const Row(
            children: [
              Skeleton(width: 56, height: 20, shimmer: false),
              SizedBox(width: 16),
              Skeleton(width: 56, height: 20, shimmer: false),
            ],
          ),
        ],
      ),
    );
  }
}

/// Skeleton matching an LFG card.
class LfgCardSkeleton extends StatelessWidget {
  const LfgCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.card),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Skeleton(width: 44, height: 44, radius: 22, shimmer: false),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 130, height: 14, shimmer: false),
                    SizedBox(height: 6),
                    Skeleton(width: 90, height: 10, shimmer: false),
                  ],
                ),
              ),
              Skeleton(width: 64, height: 24, radius: 12, shimmer: false),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              Skeleton(width: 80, height: 22, shimmer: false),
              SizedBox(width: 8),
              Skeleton(width: 80, height: 22, shimmer: false),
            ],
          ),
          SizedBox(height: 14),
          Skeleton(height: 48, radius: 12, shimmer: false),
        ],
      ),
    );
  }
}

/// Skeleton matching a leaderboard row.
class TopSkinSkeleton extends StatelessWidget {
  const TopSkinSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 84,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.card),
      ),
      child: const Row(
        children: [
          Skeleton(width: 24, height: 20, shimmer: false),
          SizedBox(width: 12),
          Skeleton(width: 96, height: 52, radius: 10, shimmer: false),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(height: 14, shimmer: false),
                SizedBox(height: 6),
                Skeleton(width: 60, height: 10, shimmer: false),
              ],
            ),
          ),
          SizedBox(width: 12),
          Skeleton(width: 40, height: 24, shimmer: false),
        ],
      ),
    );
  }
}

/// A shimmering column of [count] skeletons built by [item].
class SkeletonColumn extends StatelessWidget {
  const SkeletonColumn({
    super.key,
    required this.item,
    this.count = 3,
    this.spacing = 12,
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 0),
  });

  final Widget Function(int index) item;
  final int count;
  final double spacing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        padding: padding,
        child: Column(
          children: [
            for (var i = 0; i < count; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              item(i),
            ],
          ],
        ),
      ),
    );
  }
}
