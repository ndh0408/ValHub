import '../collection_labels.dart';

import 'package:valvn/core/l10n/labels/content_labels.dart';

import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_fallbacks.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/economy/economy.dart';
import '../../../../core/domain/loadout/loadout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/content_tier_badge.dart';
import '../../../../core/ui/empty_view.dart';
import '../../../../core/ui/error_view.dart';
import '../../../../core/ui/filter_bar.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/segmented_tabs.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/ui/sub_page.dart';
import '../../data/skin_query.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Hero tags shared by the collection screens (list → detail flights).
abstract final class CollectionHeroTags {
  /// The equipped player card: hub banner → "Đổi thẻ người chơi".
  static const equippedCard = 'collection.equippedCard';

  /// A gun's equipped render: weapon grid → that weapon's skins.
  static String gun(String weaponId) => 'collection.gun.$weaponId';

  /// A skin render: skin list → "Tùy chỉnh skin".
  static String skin(String skinUuid) => 'collection.skin.$skinUuid';
}

/// Builds [builder] with the active account, or an empty state when nobody
/// is signed in (sheets; pages use [NoAccountPage]).
class CollectionAccountGate extends ConsumerWidget {
  const CollectionAccountGate({super.key, required this.builder});

  final Widget Function(BuildContext context, Account account) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return EmptyView(
        message: context.l10n.commonErrorNoAccount,
        icon: Icons.person_off_outlined,
      );
    }
    return builder(context, account);
  }
}

/// A collection sub-page when no account is signed in.
class NoAccountPage extends StatelessWidget {
  const NoAccountPage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) => SubPageScaffold(
    title: title,
    body: EmptyView(
      message: context.l10n.commonErrorNoAccount,
      icon: Icons.person_off_outlined,
    ),
  );
}

/// Slivers for data that needs the loadout, the owned items and content:
/// [loading] (a box skeleton mirroring the final layout) until both have
/// loaded, a full-page error with "Thử lại" / "Đăng nhập lại" when one
/// failed, else [data]'s slivers. A failed refresh keeps the data and adds
/// a compact error row on top (like `AsyncValueView`).
///
/// Call it from `build` (it watches the providers through [ref]).
List<Widget> loadoutSlivers(
  WidgetRef ref, {
  required String puuid,
  required Widget loading,
  required List<Widget> Function(
    LoadoutSnapshot snapshot,
    OwnedItems owned,
    ContentDb db,
  )
  data,
}) {
  final loadout = ref.watch(loadoutProvider(puuid));
  final owned = ref.watch(ownedItemsProvider(puuid));
  void retryLoadout() => ref.invalidate(loadoutProvider(puuid));
  void retryOwned() => ref.invalidate(entitlementsProvider(puuid));
  final l = loadout.value;
  final o = owned.value;
  if (l != null && o != null) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    return [
      if (loadout.hasError && !loadout.isLoading)
        SliverToBoxAdapter(
          child: ErrorView(
            error: loadout.error!,
            puuid: puuid,
            compact: true,
            onRetry: retryLoadout,
          ),
        ),
      if (owned.hasError && !owned.isLoading)
        SliverToBoxAdapter(
          child: ErrorView(
            error: owned.error!,
            puuid: puuid,
            compact: true,
            onRetry: retryOwned,
          ),
        ),
      ...data(l, o, db),
    ];
  }
  if (l == null && loadout.hasError && !loadout.isLoading) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(
          error: loadout.error!,
          puuid: puuid,
          onRetry: retryLoadout,
        ),
      ),
    ];
  }
  if (o == null && owned.hasError && !owned.isLoading) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(
          error: owned.error!,
          puuid: puuid,
          onRetry: retryOwned,
        ),
      ),
    ];
  }
  return [SliverToBoxAdapter(child: loading)];
}

/// Like [loadoutSlivers] for screens that only need the owned items.
List<Widget> ownedSlivers(
  WidgetRef ref, {
  required String puuid,
  required Widget loading,
  required List<Widget> Function(OwnedItems owned, ContentDb db) data,
}) {
  final owned = ref.watch(ownedItemsProvider(puuid));
  void retry() => ref.invalidate(entitlementsProvider(puuid));
  if (owned.value case final o?) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    return [
      if (owned.hasError && !owned.isLoading)
        SliverToBoxAdapter(
          child: ErrorView(
            error: owned.error!,
            puuid: puuid,
            compact: true,
            onRetry: retry,
          ),
        ),
      ...data(o, db),
    ];
  }
  if (owned.hasError && !owned.isLoading) {
    return [
      SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorView(error: owned.error!, puuid: puuid, onRetry: retry),
      ),
    ];
  }
  return [SliverToBoxAdapter(child: loading)];
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

/// Font size [size] after the user's text scaling (clamped to 200 %).
double _scaled(BuildContext context, double size) =>
    math.min(MediaQuery.textScalerOf(context).scale(size), size * 2);

/// Height of a pinned [SearchStrip] (search field, plus the filter row when
/// [filters]) at the current text size, so it never clips up to 200 %.
double searchStripHeight(BuildContext context, {bool filters = false}) {
  // Field: 12 + 12 content padding + one bodyLarge line (16 × 1.5); the
  // prefix icon keeps it at least 48 dp. 8 dp above and below.
  final field = math.max(48, 24 + _scaled(context, 16) * 1.5);
  var height = 16 + field;
  if (filters) {
    // Compact chips: labelLarge line (14 × 1.43) + padding, 48 dp tap area;
    // 4 dp below the row.
    height += math.max(48, 16 + _scaled(context, 14) * 1.43) + 4;
  }
  return height.ceilToDouble() + 2;
}

/// Content of a pinned search header (a [GlassHeaderDelegate] of
/// [searchStripHeight]): the search field and optional filter row. Never
/// throws an overflow if the fonts are larger than estimated (clips).
class SearchStrip extends StatelessWidget {
  const SearchStrip({super.key, required this.search, this.filters});

  final Widget search;
  final Widget? filters;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: ClipRect(
      child: OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: 0,
        maxHeight: double.infinity,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [search, ?filters],
        ),
      ),
    ),
  );
}

/// A pinned [SearchStrip] as a sliver (for pages whose search sits below a
/// preview rather than right under the title).
Widget pinnedSearchSliver(
  BuildContext context, {
  required Widget search,
  Widget? filters,
  Key? key,
}) => SliverPersistentHeader(
  key: key,
  pinned: true,
  delegate: GlassHeaderDelegate(
    height: searchStripHeight(context, filters: filters != null),
    child: SearchStrip(search: search, filters: filters),
  ),
);

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
            options: [
              for (final s in sorts) (value: s, label: s.label(context.l10n)),
            ],
            selected: query.sort,
            onSelected: (s) => onChanged(query.copyWith(sort: s)),
          ),
          for (final id in kContentTierOrder)
            ValFilterChip(
              label:
                  _tier(
                    db,
                    id,
                  )?.shortName(context.l10n, contentLanguage: db?.language) ??
                  '',
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
String? skinTierName(WidgetRef ref, BuildContext context, String? tierUuid) {
  if (tierUuid == null) return null;
  final db = ref.watch(contentProvider).value;
  return _tier(
    db,
    tierUuid,
  )?.shortName(context.l10n, contentLanguage: db?.language);
}

/// Plain bold section title ("Trang bị", "Biến thể") of the collection tab
/// and its sub-pages, with an optional trailing caption.
class CollectionSectionTitle extends StatelessWidget {
  const CollectionSectionTitle(
    this.text, {
    super.key,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 24, 20, 10),
  });

  final String text;
  final String? trailing;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = Semantics(
      header: true,
      child: Text(
        text,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
    );
    return Padding(
      padding: padding,
      child: trailing == null
          ? title
          : Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(child: title),
                const SizedBox(width: 12),
                Flexible(
                  child: Text(
                    trailing!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

/// Red outline icon of a hub row (ValBuddy grouped-list style).
class HubIcon extends StatelessWidget {
  const HubIcon(this.icon, {super.key});

  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: kHubLeadingWidth,
    child: Icon(
      icon,
      size: 22,
      color: legibleAccent(
        context,
        Theme.of(context).colorScheme.primary,
        min: 3,
      ),
    ),
  );
}

/// Width of the leading slot of a [HubRow] (icon or artwork), so every row's
/// title starts at the same x. Wide enough for a weapon render.
const double kHubLeadingWidth = 44;

/// Small artwork from the game content, used in collection navigation rows.
/// Falls back to the row's outline [icon] when the image cannot load.
class HubArtwork extends StatelessWidget {
  const HubArtwork(this.image, {super.key, required this.icon});

  final String image;
  final IconData icon;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: kHubLeadingWidth,
    height: 32,
    child: NetImage(
      image,
      fit: BoxFit.contain,
      showSkeleton: false,
      error: HubIcon(icon),
    ),
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
    this.image,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String? value;
  final VoidCallback? onTap;

  /// Replaces the icon (e.g. a custom widget).
  final Widget? leading;

  /// Game artwork shown instead of the icon (the icon is the fallback when
  /// the image is missing or fails to load).
  final String? image;

  /// Replaces the "›" (e.g. a button).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 54),
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(14, 10, 10, 10),
          child: Row(
            children: [
              leading ??
                  (image == null
                      ? HubIcon(icon)
                      : HubArtwork(image!, icon: icon)),
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
              trailing ?? Icon(Icons.chevron_right, color: muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small "Đang dùng" pill.
class EquippedBadge extends StatelessWidget {
  const EquippedBadge({super.key, this.label});

  final String? label;

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
              label ?? context.l10n.collectionEquipped,
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
                            const PositionedDirectional(
                              top: 6,
                              end: 6,
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

/// "142 skin · 98.765 VP" / "Đang lọc: …" strip with an optional trailing
/// widget (VND estimate).
class SummaryStrip extends StatelessWidget {
  const SummaryStrip({
    super.key,
    required this.text,
    this.caption,
    this.highlighted = false,
    this.trailing,
  });

  final String text;
  final String? caption;
  final bool highlighted;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
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
                ?trailing,
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
              context.l10n.collectionCachedLoadout,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

/// Tinted notice card (locked skin, melee without buddy…).
class CollectionNotice extends StatelessWidget {
  const CollectionNotice({
    super.key,
    required this.icon,
    required this.text,
    this.color,
    this.margin = const EdgeInsets.fromLTRB(16, 12, 16, 0),
  });

  final IconData icon;
  final String text;
  final Color? color;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? valColorsOf(context).warning;
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(ValRadius.small),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: tint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
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
        ? LinearProgressIndicator(
            minHeight: 2,
            semanticsLabel: context.l10n.collectionSaving,
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

/// Skeleton of a `SliverGridDelegateWithMaxCrossAxisExtent` grid with the
/// same column count and tile height as the real one ([rows] rows).
class SkeletonTileGrid extends StatelessWidget {
  const SkeletonTileGrid({
    super.key,
    required this.maxExtent,
    required this.tileHeight,
    this.rows = 3,
    this.spacing = 10,
    this.padding = const EdgeInsets.fromLTRB(16, 4, 16, 16),
    this.shimmer = true,
  });

  final double maxExtent;
  final double tileHeight;
  final int rows;
  final double spacing;
  final EdgeInsets padding;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final grid = LayoutBuilder(
      builder: (context, c) {
        final width = c.maxWidth - padding.horizontal;
        final columns = math.max(1, (width / (maxExtent + spacing)).ceil());
        final tileWidth = (width - spacing * (columns - 1)) / columns;
        return Padding(
          padding: padding,
          child: Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: [
              for (var i = 0; i < columns * rows; i++)
                Skeleton(
                  width: tileWidth,
                  height: tileHeight,
                  radius: ValRadius.card,
                  shimmer: false,
                ),
            ],
          ),
        );
      },
    );
    return shimmer ? SkeletonShimmer(child: grid) : grid;
  }
}

/// Skeleton of a grouped list: a rounded card of [rows] rows.
class SkeletonGroupedRows extends StatelessWidget {
  const SkeletonGroupedRows({
    super.key,
    this.rows = 5,
    this.rowHeight = 52,
    this.shimmer = true,
  });

  final int rows;
  final double rowHeight;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final body = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(ValRadius.card),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Column(
          children: [
            for (var i = 0; i < rows; i++)
              SizedBox(
                height: rowHeight,
                child: const Row(
                  children: [
                    Skeleton(width: 24, height: 24, shimmer: false),
                    SizedBox(width: 14),
                    Expanded(
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: FractionallySizedBox(
                          widthFactor: 0.6,
                          child: Skeleton(height: 14, shimmer: false),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
    return shimmer ? SkeletonShimmer(child: body) : body;
  }
}

/// Height of a grid tile whose caption is 2 lines + an optional footer line,
/// scaled with the user's text size (no overflow up to 200 %).
double tileExtent(
  BuildContext context, {
  required double image,
  bool footer = false,
}) {
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
  return image + (footer ? 58 : 40) * scale + 8;
}

/// Height of a [SkinArtCard] in the skin grids: an [image] area plus the
/// name (2 lines) and the price line (and a VND line when [extraLine]),
/// scaled with the text size.
double skinCardExtent(
  BuildContext context, {
  double image = 104,
  bool extraLine = false,
}) => image + _skinCardText(context, extraLine: extraLine);

/// `imageFlex` for a [SkinArtCard] of [skinCardExtent] height so the text
/// block always gets the room it needs (no overflow up to 200 % text).
int skinCardImageFlex(
  BuildContext context, {
  double image = 104,
  bool extraLine = false,
}) {
  final text = _skinCardText(context, extraLine: extraLine);
  return (4 * image / text).floor().clamp(1, 8);
}

double _skinCardText(BuildContext context, {bool extraLine = false}) {
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
  // Name: 2 lines × 14 × 1.25; price row 16; paddings 6 + 12 (+ slack);
  // VND line: labelSmall ≈ 16 + 2.
  return (51 + (extraLine ? 18 : 0)) * scale + 30;
}
