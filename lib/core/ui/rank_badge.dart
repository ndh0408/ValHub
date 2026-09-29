import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../content/content_repository.dart';
import '../l10n/content_strings.dart';
import '../theme/app_theme.dart';
import '../theme/tier_colors.dart';
import 'net_image.dart';

/// Competitive rank icon + Vietnamese name (e.g. "Kim Cương 1"), resolved in
/// the tier table of [seasonId] (SUMMARY §7.4; current table when null).
class RankBadge extends ConsumerWidget {
  const RankBadge({
    super.key,
    required this.tier,
    this.seasonId,
    this.size = 32,
    this.showName = true,
    this.rr,
    this.style,
    this.axis = Axis.horizontal,
  });

  final int tier;
  final String? seasonId;
  final double size;
  final bool showName;

  /// Optional ranked rating shown after the name ("6 RR").
  final int? rr;
  final TextStyle? style;
  final Axis axis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value;
    final t = db?.tier(tier, seasonUuid: seasonId);
    final name = t?.displayName ?? ContentStrings.unranked;
    final icon = t == null || t.isUnranked
        ? (db?.tier(0, seasonUuid: seasonId)?.smallIcon)
        : (size > 48 ? t.largeIcon : t.smallIcon) ?? t.largeIcon;
    final label = rr == null ? name : '$name · $rr RR';
    final image = NetImage(
      icon,
      width: size,
      height: size,
      showSkeleton: false,
    );
    if (!showName) return Tooltip(message: label, child: image);
    final text = Text(
      label,
      style: (style ?? Theme.of(context).textTheme.bodyMedium)?.copyWith(
        color: t == null || t.isUnranked
            ? null
            : legibleAccent(context, opaqueRgba(t.color), min: 3.5),
      ),
    );
    return Flex(
      direction: axis,
      mainAxisSize: MainAxisSize.min,
      children: [
        image,
        SizedBox(width: 8, height: 4),
        Flexible(child: text),
      ],
    );
  }
}
