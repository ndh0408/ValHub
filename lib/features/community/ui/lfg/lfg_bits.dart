import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/l10n/labels/content_labels.dart';
import '../../../../core/l10n/locale.dart';
import '../../../../core/riot/riot_ids.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/rank_badge.dart';
import '../../data/community_models.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Agent role uuid of an LFG role (`null` for `flex`).
String? lfgRoleUuid(String role) => switch (role) {
  'duelist' => AgentRoleIds.duelist,
  'initiator' => AgentRoleIds.initiator,
  'controller' => AgentRoleIds.controller,
  'sentinel' => AgentRoleIds.sentinel,
  _ => null,
};

/// vi-VN role name (valorant-api names: "Đối đầu", "Khởi tranh"…).
String lfgRoleLabel(AppLocalizations l10n, String role) {
  final uuid = lfgRoleUuid(role);
  return uuid == null
      ? l10n.communityRoleFlex
      : (l10n.agentRoleName(uuid) ?? role);
}

/// Role icon from the content (any agent of that role), else `null`.
String? lfgRoleIcon(ContentDb db, String role) {
  final uuid = lfgRoleUuid(role);
  if (uuid == null) return null;
  for (final a in db.agents) {
    if (a.role?.uuid == uuid) return a.role?.displayIcon;
  }
  return null;
}

/// Small role icon (content art, or a generic icon for "Linh hoạt").
class RoleIcon extends ConsumerWidget {
  const RoleIcon({super.key, required this.role, this.size = 16, this.color});

  final String role;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final icon = lfgRoleIcon(db, role);
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    final fallback = Icon(
      role == 'flex' ? Icons.all_inclusive_rounded : Icons.person_rounded,
      size: size,
      color: c,
    );
    if (icon == null) return fallback;
    return NetImage(
      icon,
      width: size,
      height: size,
      color: c,
      showSkeleton: false,
      error: fallback,
    );
  }
}

/// Role chip: icon + vi name.
class RoleTag extends StatelessWidget {
  const RoleTag({super.key, required this.role});

  final String role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: valColorsOf(context).surface2,
        borderRadius: BorderRadius.circular(ValRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoleIcon(role: role, size: 14),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              lfgRoleLabel(context.l10n, role),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// "Mọi rank" or the two rank icons of the range ("Vàng 1 – Bạch Kim 3").
class RankRangeBadge extends ConsumerWidget {
  const RankRangeBadge({super.key, required this.min, required this.max});

  final int? min;
  final int? max;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final child = min == null && max == null
        ? Text(context.l10n.communityAnyRank, style: style)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RankBadge(tier: min ?? 3, size: 18, showName: false),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(context.l10n.commonDash, style: style),
              ),
              RankBadge(tier: max ?? kMaxRankTier, size: 18, showName: false),
            ],
          );
    return Semantics(
      label: rankRangeLabel(
        context.l10n,
        ref.watch(contentProvider).value ?? ContentDb.empty(),
        min,
        max,
      ),
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: valColorsOf(context).surface2,
          borderRadius: BorderRadius.circular(ValRadius.pill),
        ),
        child: child,
      ),
    );
  }
}

/// "Vàng 1 – Bạch Kim 3" / "Mọi rank".
String rankRangeLabel(AppLocalizations l10n, ContentDb db, int? min, int? max) {
  if (min == null && max == null) return l10n.communityAnyRank;
  String name(int t) => db.tier(t)?.displayName ?? l10n.contentUnranked;
  return l10n.communityRankBetween(name(min ?? 3), name(max ?? kMaxRankTier));
}

/// Party size as dots: ●●●○○ (filled = members, red rings = open slots).
class PartyDots extends StatelessWidget {
  const PartyDots({super.key, required this.size, this.max = 5});

  final int size;
  final int max;

  @override
  Widget build(BuildContext context) {
    final filled = size.clamp(1, max);
    final track = valColorsOf(context).track;
    return Semantics(
      container: true,
      label: context.l10n.communityPartySizeValue(filled),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < max; i++)
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: i < filled ? valColorsOf(context).win : null,
                border: i < filled
                    ? null
                    : Border.all(
                        color: ValColors.red.withValues(alpha: 0.8),
                        width: 1.5,
                      ),
              ),
              child: i < filled
                  ? null
                  : DecoratedBox(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: track.withValues(alpha: 0.2),
                      ),
                    ),
            ),
        ],
      ),
    );
  }
}

/// Status chip of an LFG post.
class LfgStatusChip extends StatelessWidget {
  const LfgStatusChip({super.key, required this.status});

  final LfgStatus status;

  @override
  Widget build(BuildContext context) {
    final c = valColorsOf(context);
    final (label, color, icon) = switch (status) {
      LfgStatus.open => (
        context.l10n.communityStatusOpen,
        c.win,
        Icons.search_rounded,
      ),
      LfgStatus.full => (
        context.l10n.communityStatusFull,
        c.warning,
        Icons.groups_rounded,
      ),
      LfgStatus.inGame => (
        context.l10n.communityStatusInGame,
        ValColors.red,
        Icons.sports_esports_rounded,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(ValRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: legibleAccent(context, color)),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: legibleAccent(context, color),
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// The app's current language as a community language code (today `vi`).
String communityAppLanguage(BuildContext context) {
  final locale = Localizations.maybeLocaleOf(context) ?? appLocale;
  return lfgLanguageForLocale(
    locale.languageCode,
    scriptOrCountry: locale.scriptCode ?? locale.countryCode,
  );
}
