import 'package:valvn/core/l10n/labels/content_labels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../content/content_fallbacks.dart';
import '../content/content_repository.dart';
import '../theme/app_theme.dart';
import '../theme/tier_colors.dart';
import 'net_image.dart';
import '../l10n/l10n.dart';

/// Content-tier (rarity) icon, optionally with its short vi name
/// ("Độc Quyền"). Renders nothing for skins without a tier.
class ContentTierBadge extends ConsumerWidget {
  const ContentTierBadge({
    super.key,
    required this.contentTierUuid,
    this.size = 18,
    this.showName = false,
    this.fullName = false,
    this.style,
  });

  final String? contentTierUuid;
  final double size;
  final bool showName;

  /// "Phiên bản Độc Quyền" instead of "Độc Quyền".
  final bool fullName;
  final TextStyle? style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = contentTierUuid;
    if (id == null) return const SizedBox.shrink();
    final db = ref.watch(contentProvider).value;
    final tier = db?.contentTier(id) ?? ContentFallbacks.contentTier(id);
    if (tier == null) return const SizedBox.shrink();
    final icon = NetImage(
      tier.displayIcon,
      width: size,
      height: size,
      showSkeleton: false,
    );
    if (!showName) {
      return Tooltip(
        message: tier.fullName(context.l10n, contentLanguage: db?.language),
        child: icon,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 6),
        Text(
          fullName
              ? tier.fullName(context.l10n, contentLanguage: db?.language)
              : tier.shortName(context.l10n, contentLanguage: db?.language),
          style: (style ?? Theme.of(context).textTheme.labelMedium)?.copyWith(
            color: legibleAccent(context, opaqueRgba(tier.highlightColor)),
          ),
        ),
      ],
    );
  }
}

/// Card tint for a content tier (`highlightColor`, alpha 0x33).
Color contentTierTint(
  WidgetRef ref,
  String? contentTierUuid, {
  Color fallback = Colors.transparent,
}) {
  if (contentTierUuid == null) return fallback;
  final tier =
      ref.watch(contentProvider).value?.contentTier(contentTierUuid) ??
      ContentFallbacks.contentTier(contentTierUuid);
  return tier == null
      ? fallback
      : parseRgba(tier.highlightColor, fallback: fallback);
}
