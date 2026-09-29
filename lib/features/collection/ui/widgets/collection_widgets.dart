import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_fallbacks.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/domain/loadout/loadout.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/async_value_view.dart';
import '../../../../core/ui/content_tier_badge.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/ui/filter_bar.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/skeleton.dart';
import '../../collection_strings.dart';
import '../../data/skin_query.dart';

/// Builds [builder] with the active account, or an empty state when nobody
/// is signed in.
class CollectionAccountGate extends ConsumerWidget {
  const CollectionAccountGate({super.key, required this.builder});

  final Widget Function(BuildContext context, Account account) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return const EmptyView(
        message: CommonStrings.errorNoAccount,
        icon: Icons.person_off_outlined,
      );
    }
    return builder(context, account);
  }
}

/// Loadout + owned items + content with the standard loading / error states
/// (each source keeps its own "Thử lại").
class LoadoutDataBuilder extends ConsumerWidget {
  const LoadoutDataBuilder({
    super.key,
    required this.puuid,
    required this.builder,
    this.loading,
  });

  final String puuid;
  final Widget? loading;
  final Widget Function(
    BuildContext context,
    LoadoutSnapshot snapshot,
    OwnedItems owned,
    ContentDb db,
  )
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AsyncValueView(
      value: ref.watch(loadoutProvider(puuid)),
      puuid: puuid,
      loading: loading,
      onRetry: () => ref.invalidate(loadoutProvider(puuid)),
      data: (snapshot) => AsyncValueView(
        value: ref.watch(ownedItemsProvider(puuid)),
        puuid: puuid,
        loading: loading,
        onRetry: () => ref.invalidate(entitlementsProvider(puuid)),
        data: (owned) => builder(
          context,
          snapshot,
          owned,
          ref.watch(contentProvider).value ?? ContentDb.empty(),
        ),
      ),
    );
  }
}

/// "Glass" search bar used by every picker (C10): pill field with a clear
/// button (core [GlassSearchField]).
class CollectionSearchField extends StatefulWidget {
  const CollectionSearchField({
    super.key,
    required this.hint,
    required this.onChanged,
    this.initialValue = '',
    this.padding = const EdgeInsets.fromLTRB(16, 8, 16, 8),
  });

  final String hint;
  final ValueChanged<String> onChanged;
  final String initialValue;
  final EdgeInsets padding;

  @override
  State<CollectionSearchField> createState() => _CollectionSearchFieldState();
}

class _CollectionSearchFieldState extends State<CollectionSearchField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.initialValue,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: widget.padding,
    child: GlassSearchField(
      controller: _controller,
      hintText: widget.hint,
      onChanged: widget.onChanged,
    ),
  );
}

/// Content tier of [id] (content, else the bundled fallback).
ContentTier? _tier(ContentDb? db, String id) =>
    db?.contentTier(id) ?? ContentFallbacks.contentTier(id);

/// Sort button + multi-select content-tier chips (rarity color dots) and a
/// "Bỏ lọc" chip while tiers are picked (C6, C7).
class SkinFilterBar extends ConsumerWidget {
  const SkinFilterBar({
    super.key,
    required this.query,
    required this.onChanged,
    this.sorts = SkinSort.values,
  });

  final SkinQuery query;
  final ValueChanged<SkinQuery> onChanged;
  final List<SkinSort> sorts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: FilterChipBar(
        onClear: query.tiers.isEmpty
            ? null
            : () => onChanged(query.copyWith(tiers: {})),
        children: [
          SortButton<SkinSort>(
            options: [for (final s in sorts) (value: s, label: s.label)],
            selected: query.sort,
            onSelected: (s) => onChanged(query.copyWith(sort: s)),
          ),
          for (final id in kContentTierOrder)
            ValFilterChip(
              label: _tier(db, id)?.shortName ?? '',
              dotColor: opaqueRgba(_tier(db, id)?.highlightColor),
              selected: query.tiers.contains(id),
              onSelected: (_) => onChanged(query.toggleTier(id)),
            ),
        ],
      ),
    );
  }
}

/// Opaque rarity color of a skin (muted when it has no tier).
Color skinTierColor(WidgetRef ref, BuildContext context, String? tierUuid) {
  final tint = contentTierTint(ref, tierUuid);
  return tint == Colors.transparent
      ? valColorsOf(context).muted
      : tint.withValues(alpha: 1);
}

/// Short rarity name ("Độc Quyền") of a skin, or `null`.
String? skinTierName(WidgetRef ref, String? tierUuid) {
  if (tierUuid == null) return null;
  return _tier(ref.watch(contentProvider).value, tierUuid)?.shortName;
}

/// Red outline icon of a hub row (ValBuddy grouped-list style).
class HubIcon extends StatelessWidget {
  const HubIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 28,
    child: Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
  );
}

/// One tappable row of the hub: red outline icon, title, grey current
/// value and "›" (min 54 dp tall).
class HubRow extends StatelessWidget {
  const HubRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.leading,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  /// Replaces the icon (e.g. an image).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 10, 10, 10),
          child: Row(
            children: [
              leading ?? HubIcon(icon),
              const SizedBox(width: 12),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, c) => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (value != null) ...[
                        const SizedBox(width: 8),
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: c.maxWidth * 0.5,
                          ),
                          child: Text(
                            value!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: muted,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(Icons.chevron_right, color: muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small "Đang dùng" pill.
class EquippedBadge extends StatelessWidget {
  const EquippedBadge({super.key, this.label = CollectionStrings.equipped});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check, size: 12, color: Colors.white),
          const SizedBox(width: 3),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

/// A grid tile with artwork, a caption and an optional footer; accent
/// frame, glow and check when [selected]. With a [tint] (rarity) the art
/// sits on a soft glow of that color and the tile gets a colored bottom
/// edge.
class ArtTile extends StatelessWidget {
  const ArtTile({
    super.key,
    required this.image,
    required this.label,
    this.selected = false,
    this.onTap,
    this.footer,
    this.imageFit = BoxFit.contain,
    this.imagePadding = const EdgeInsets.all(10),
    this.tint,
    this.dimmed = false,
    this.semanticsLabel,
    this.icon,
  });

  final String? image;

  /// Shown instead of the artwork when [image] is null ("Trống").
  final IconData? icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final Widget? footer;
  final BoxFit imageFit;
  final EdgeInsets imagePadding;
  final Color? tint;

  /// Unavailable: faded art (paint-time tint, no `Opacity` layer) and a
  /// muted caption.
  final bool dimmed;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final accent = scheme.primary;
    final color = tint?.withValues(alpha: 1);
    final base = color ?? scheme.surfaceContainerHigh;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: ValMotion.fast,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ValRadius.card),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.3),
                    blurRadius: 12,
                  ),
                ]
              : const [],
        ),
        child: Material(
          color: scheme.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ValRadius.card),
            side: BorderSide(
              color: selected
                  ? accent
                  : (color?.withValues(alpha: dark ? 0.3 : 0.45) ??
                        valColorsOf(context).hairline),
              width: selected ? 2 : 1,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Ink(
              decoration: color == null
                  ? null
                  : BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: color, width: 3),
                      ),
                    ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: color == null
                            ? LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  base.withValues(alpha: 0.55),
                                  base.withValues(alpha: 0.12),
                                ],
                              )
                            : RadialGradient(
                                radius: 0.8,
                                colors: [
                                  color.withValues(alpha: dark ? 0.34 : 0.22),
                                  color.withValues(alpha: 0.04),
                                ],
                              ),
                      ),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Padding(
                            padding: imagePadding,
                            child: image == null && icon != null
                                ? Icon(
                                    icon,
                                    size: 32,
                                    color: scheme.onSurfaceVariant,
                                  )
                                : NetImage(
                                    image,
                                    fit: imageFit,
                                    opacity: dimmed ? 0.4 : null,
                                  ),
                          ),
                          if (selected)
                            const Positioned(
                              top: 6,
                              right: 6,
                              child: _CheckDot(),
                            ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          label,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            color: dimmed ? scheme.onSurfaceVariant : null,
                          ),
                        ),
                        if (footer != null) ...[
                          const SizedBox(height: 2),
                          footer!,
                        ],
                      ],
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

class _CheckDot extends StatelessWidget {
  const _CheckDot();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.primary,
      shape: BoxShape.circle,
      boxShadow: const [BoxShadow(color: Color(0x55000000), blurRadius: 4)],
    ),
    child: const Icon(Icons.check, size: 14, color: Colors.white),
  );
}

/// "142 skin · 98.765 VP" / "Đang lọc: …" strip.
class SummaryStrip extends StatelessWidget {
  const SummaryStrip({
    super.key,
    required this.text,
    this.caption,
    this.highlighted = false,
  });

  final String text;
  final String? caption;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 18,
            decoration: BoxDecoration(
              color: highlighted
                  ? valColorsOf(context).warning
                  : Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: theme.textTheme.labelLarge,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (caption != null)
                  Text(
                    caption!,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Offline notice shown when the loadout comes from the offline copy.
class CachedLoadoutBanner extends StatelessWidget {
  const CachedLoadoutBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final warning = valColorsOf(context).warning;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 18, color: warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              CollectionStrings.cachedLoadout,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Thin progress bar while a save is in flight (optimistic value shown).
class SavingBar extends StatelessWidget {
  const SavingBar({super.key, required this.visible});

  final bool visible;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 2,
    child: visible
        ? const LinearProgressIndicator(
            minHeight: 2,
            semanticsLabel: CollectionStrings.saving,
          )
        : null,
  );
}

/// Grid skeleton that fits the pickers.
class CollectionGridSkeleton extends StatelessWidget {
  const CollectionGridSkeleton({
    super.key,
    this.crossAxisCount = 3,
    this.childAspectRatio = 0.75,
  });

  final int crossAxisCount;
  final double childAspectRatio;

  @override
  Widget build(BuildContext context) => SkeletonGrid(
    itemCount: crossAxisCount * 3,
    crossAxisCount: crossAxisCount,
    childAspectRatio: childAspectRatio,
  );
}

/// Height of a grid tile whose caption is 2 lines + an optional footer line,
/// scaled with the user's text size (no overflow at 1.3×).
double tileExtent(
  BuildContext context, {
  required double image,
  bool footer = false,
}) {
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
  return image + (footer ? 58 : 40) * scale + 8;
}

/// Height of a [SkinArtCard] in the skin grids: an [image] area plus the
/// name (2 lines) and the price line, scaled with the text size.
double skinCardExtent(BuildContext context, {double image = 104}) =>
    image + _skinCardText(context);

/// `imageFlex` for a [SkinArtCard] of [skinCardExtent] height so the text
/// block always gets the room it needs (no overflow up to 200 % text).
int skinCardImageFlex(BuildContext context, {double image = 104}) {
  final text = _skinCardText(context);
  return (4 * image / text).floor().clamp(1, 8);
}

double _skinCardText(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
  // Name: 2 lines × 14 × 1.25; price row 16; paddings 6 + 12 (+ slack).
  return 51 * scale + 30;
}
