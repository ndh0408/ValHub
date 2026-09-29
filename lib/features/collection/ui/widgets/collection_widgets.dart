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
import '../../../../core/ui/empty_view.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/val_widgets.dart';
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

/// "Glass" search bar used by every picker (C10).
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
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: widget.padding,
      child: TextField(
        controller: _controller,
        onChanged: (v) {
          setState(() {});
          widget.onChanged(v);
        },
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hint,
          isDense: true,
          filled: true,
          fillColor: scheme.surfaceContainerHigh.withValues(alpha: 0.7),
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: CollectionStrings.clearSearch,
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _controller.clear();
                    setState(() {});
                    widget.onChanged('');
                  },
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// Content-tier filter chips (5 edition icons) plus the sort menu.
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
    final theme = Theme.of(context);
    return SizedBox(
      height: 44,
      child: Row(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16, right: 8),
              children: [
                for (final id in kContentTierOrder)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _TierChip(
                      tierUuid: id,
                      selected: query.tiers.contains(id),
                      label:
                          (db?.contentTier(id) ??
                                  ContentFallbacks.contentTier(id))
                              ?.shortName ??
                          '',
                      icon:
                          (db?.contentTier(id) ??
                                  ContentFallbacks.contentTier(id))
                              ?.displayIcon,
                      color: opaqueRgba(
                        (db?.contentTier(id) ??
                                ContentFallbacks.contentTier(id))
                            ?.highlightColor,
                      ),
                      onTap: () => onChanged(query.toggleTier(id)),
                    ),
                  ),
              ],
            ),
          ),
          if (query.tiers.isNotEmpty)
            IconButton(
              tooltip: CollectionStrings.clearFilters,
              visualDensity: VisualDensity.compact,
              onPressed: () => onChanged(query.copyWith(tiers: {})),
              icon: const Icon(Icons.filter_alt_off_outlined, size: 20),
            ),
          PopupMenuButton<SkinSort>(
            tooltip: CollectionStrings.sortLabel,
            initialValue: query.sort,
            onSelected: (s) => onChanged(query.copyWith(sort: s)),
            itemBuilder: (_) => [
              for (final s in sorts)
                CheckedPopupMenuItem(
                  value: s,
                  checked: s == query.sort,
                  child: Text(s.label),
                ),
            ],
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.sort, size: 18),
                  const SizedBox(width: 4),
                  Text(query.sort.label, style: theme.textTheme.labelLarge),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({
    required this.tierUuid,
    required this.selected,
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String tierUuid;
  final bool selected;
  final String label;
  final String? icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    // Tier colour while the icon loads (or when it cannot load offline).
    final dot = SizedBox(
      width: 20,
      height: 20,
      child: Center(
        child: Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            decoration: BoxDecoration(
              color: selected
                  ? color.withValues(alpha: 0.22)
                  : scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: selected ? color : Colors.transparent),
            ),
            child: NetImage(
              icon,
              width: 20,
              height: 20,
              placeholder: dot,
              error: dot,
            ),
          ),
        ),
      ),
    );
  }
}

/// One tappable row of the hub: icon, title, current value and "›".
class HubRow extends StatelessWidget {
  const HubRow({
    super.key,
    required this.icon,
    required this.title,
    this.value,
    this.onTap,
    this.leading,
    this.color = ValColors.red,
  });

  final IconData icon;

  /// Tint of the icon tile (Figma: one color per row).
  final Color color;
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
          padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
          child: Row(
            children: [
              leading ?? IconTile(icon: icon, color: color, size: 34),
              const SizedBox(width: 14),
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
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, color: muted),
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
        color: ValColors.red,
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

/// A grid tile with artwork, a caption and an optional footer; red frame
/// and check when [selected].
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
  final bool dimmed;
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final base = tint ?? scheme.surfaceContainerHigh;
    return Semantics(
      button: onTap != null,
      selected: selected,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? ValColors.red : Colors.transparent,
            width: 2,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Opacity(
            opacity: dimmed ? 0.45 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          base.withValues(alpha: 0.55),
                          base.withValues(alpha: 0.12),
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
                              : NetImage(image, fit: imageFit),
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
    );
  }
}

class _CheckDot extends StatelessWidget {
  const _CheckDot();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(3),
    decoration: const BoxDecoration(
      color: ValColors.red,
      shape: BoxShape.circle,
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
            color: highlighted ? valColorsOf(context).warning : ValColors.red,
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
