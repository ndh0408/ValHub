import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/accounts/account.dart';
import '../../core/accounts/account_providers.dart';
import '../../core/content/content_db.dart';
import '../../core/content/content_repository.dart';
import '../../core/domain/economy/economy.dart';
import '../../core/l10n/common_strings.dart';
import '../../core/l10n/content_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/adaptive.dart';
import '../../core/ui/content_tier_badge.dart';
import '../../core/ui/currency_amount.dart';
import '../../core/ui/empty_view.dart';
import '../../core/ui/error_view.dart';
import '../../core/ui/net_image.dart';
import '../../core/ui/skeleton.dart';
import '../../core/ui/sub_page.dart';
import '../../core/ui/val_widgets.dart';
import '../../core/ui/vnd_estimate.dart';
import '../community/ui/skins/skin_vote_button.dart';
import '../store/ui/widgets/store_ui_bits.dart';
import 'providers/skin_availability.dart';
import 'skin_detail_strings.dart';
import 'skin_video_view.dart';

/// Context the sheet is opened from.
enum SkinDetailMode {
  /// From the store / Night Market / bundle: price + wishlist button.
  store,

  /// From the collection: owned levels / chromas, "Đã sở hữu".
  owned,

  /// From the wishlist or the all-skins catalog: wishlist toggle.
  catalog,
}

/// Opens S15 "Chi tiết skin" as a full-height modal sheet.
///
/// [skinOrLevelUuid] may be a skin, level or chroma uuid (resolved with
/// `ContentDb.skinByAnyUuid`); a chroma uuid preselects that variant.
Future<void> showSkinDetailSheet(
  BuildContext context, {
  required String skinOrLevelUuid,
  SkinDetailMode mode = SkinDetailMode.store,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => SkinDetailSheet(skinOrLevelUuid: skinOrLevelUuid, mode: mode),
);

/// The media shown for [chroma] of [skin]: its full render, and the video
/// of that variant (the base variant falls back to the skin's best level
/// video, VF §6.2 S15).
({String? render, String? video}) skinMedia(
  WeaponSkin skin,
  SkinChroma? chroma,
) {
  final render = chroma?.fullRender ?? chroma?.displayIcon ?? skin.render;
  final video = chroma == null || chroma.isBase
      ? (chroma?.streamedVideo ?? skin.previewVideo)
      : chroma.streamedVideo;
  return (render: render, video: video);
}

/// S15 body: render / video, tier + price (or reward source), variants,
/// upgrade levels with videos, owned state, wishlist button and the
/// optional "Có trong cửa hàng của: …" line.
class SkinDetailSheet extends ConsumerStatefulWidget {
  const SkinDetailSheet({
    super.key,
    required this.skinOrLevelUuid,
    this.mode = SkinDetailMode.store,
  });

  final String skinOrLevelUuid;
  final SkinDetailMode mode;

  @override
  ConsumerState<SkinDetailSheet> createState() => _SkinDetailSheetState();
}

class _SkinDetailSheetState extends ConsumerState<SkinDetailSheet> {
  /// Selected chroma uuid; `null` = the one [widget.skinOrLevelUuid] names,
  /// else the base variant.
  String? _chromaUuid;
  bool _missReported = false;

  SkinChroma? _selectedChroma(WeaponSkin skin) {
    final wanted = (_chromaUuid ?? widget.skinOrLevelUuid).toLowerCase();
    for (final c in skin.chromas) {
      if (c.uuid == wanted) return c;
    }
    return skin.chromas.firstOrNull;
  }

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(contentProvider);
    final db = contentAsync.value;
    final skin = db?.skinByAnyUuid(widget.skinOrLevelUuid);

    final Widget body;
    if (db == null || db.isEmpty) {
      body = contentAsync.hasError && !contentAsync.isLoading
          ? ErrorView(
              error: contentAsync.error!,
              onRetry: () => ref.invalidate(contentProvider),
            )
          : const _LoadingBody();
    } else if (skin == null) {
      _reportMiss();
      body = const EmptyView(
        message: SkinDetailStrings.notFound,
        icon: Icons.search_off,
      );
    } else {
      body = _SkinBody(
        skin: skin,
        mode: widget.mode,
        chroma: _selectedChroma(skin),
        onChromaSelected: (c) => setState(() => _chromaUuid = c.uuid),
      );
    }

    return FractionallySizedBox(
      heightFactor: 0.9,
      alignment: Alignment.topCenter,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SheetHeader(
            title: skin?.displayName ?? SkinDetailStrings.title,
            subtitle: skin == null ? null : _subtitle(db!, skin),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }

  /// "Vandal · Cao Cấp" under the name.
  static String? _subtitle(ContentDb db, WeaponSkin skin) {
    final tierId = skin.contentTierUuid;
    final parts = [
      ?db.weapon(skin.weaponUuid)?.displayName,
      if (tierId != null) ?db.contentTier(tierId)?.shortName,
    ].where((p) => p.trim().isNotEmpty).toList();
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// A skin uuid missing from the content (new patch): ask for a
  /// rate-limited content refresh.
  void _reportMiss() {
    if (_missReported) return;
    _missReported = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(ref.read(contentMissReporterProvider).report());
    });
  }
}

class _LoadingBody extends StatelessWidget {
  const _LoadingBody();

  @override
  Widget build(BuildContext context) {
    // Never scrolls, but clips instead of overflowing on short sheets.
    return const SkeletonShimmer(
      child: SingleChildScrollView(
        physics: NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: Skeleton(height: null, radius: 16, shimmer: false),
            ),
            SizedBox(height: 14),
            Skeleton(height: 64, radius: 16, shimmer: false),
            SizedBox(height: 20),
            Skeleton(width: 120, height: 16, shimmer: false),
            SizedBox(height: 12),
            Row(
              children: [
                Skeleton(width: 52, height: 52, radius: 26, shimmer: false),
                SizedBox(width: 12),
                Skeleton(width: 52, height: 52, radius: 26, shimmer: false),
                SizedBox(width: 12),
                Skeleton(width: 52, height: 52, radius: 26, shimmer: false),
              ],
            ),
            SizedBox(height: 24),
            Skeleton(height: 48, radius: 12, shimmer: false),
          ],
        ),
      ),
    );
  }
}

class _SkinBody extends ConsumerWidget {
  const _SkinBody({
    required this.skin,
    required this.mode,
    required this.chroma,
    required this.onChromaSelected,
  });

  final WeaponSkin skin;
  final SkinDetailMode mode;
  final SkinChroma? chroma;
  final ValueChanged<SkinChroma> onChromaSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final puuid = ref.watch(activeAccountProvider)?.puuid;
    final media = skinMedia(skin, chroma);
    final quote = ref.watch(priceServiceProvider).priceForSkin(skin.uuid);
    final reward = ref.watch(rewardSourceIndexProvider).forSkin(skin);
    final owned = puuid == null
        ? null
        : ref.watch(ownedItemsProvider(puuid)).value;
    final isOwned = owned?.isSkinOwned(skin.uuid) ?? false;
    // Locks only make sense for a skin the account owns.
    final ownedForLocks = isOwned && skin.isCollectible ? owned : null;
    final inWishlist =
        puuid != null &&
        wishlistContains(ref.watch(wishlistProvider(puuid)), skin.uuid, db);
    final showWishlist =
        puuid != null &&
        skin.isCollectible &&
        !(mode == SkinDetailMode.owned && isOwned);
    final List<Account> elsewhere =
        mode == SkinDetailMode.store || puuid == null
        ? const []
        : ref.watch(skinAvailableElsewhereProvider(skin.uuid)).value ??
              const [];
    final tint = contentTierTint(
      ref,
      skin.contentTierUuid,
      fallback: valColorsOf(context).muted,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        _Media(render: media.render, video: media.video, tint: tint),
        const SizedBox(height: 14),
        ValCard(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 6,
                children: [
                  TierLabel(
                    contentTierUuid: skin.contentTierUuid,
                    fullName: true,
                    iconSize: 20,
                    style: theme.textTheme.titleSmall,
                  ),
                  _PriceLabel(quote: quote),
                ],
              ),
              if (reward != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.military_tech_outlined, size: 16, color: muted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        SkinDetailStrings.rewardDetail(
                          reward.contractName,
                          reward.level == null
                              ? null
                              : ContentStrings.level(reward.level!),
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: muted,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else if (quote.isEstimate) ...[
                const SizedBox(height: 6),
                Text(
                  quote.source.label,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ],
              if (isOwned) ...[
                const SizedBox(height: 10),
                const OwnedBadge(label: SkinDetailStrings.owned),
              ],
            ],
          ),
        ),
        const SizedBox(height: 8),
        SkinVoteButton(skinUuid: skin.uuid, weaponUuid: skin.weaponUuid),
        if (elsewhere.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.storefront_outlined, size: 16, color: muted),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  SkinDetailStrings.availableInStoreOf(
                    elsewhere.map((a) => a.riotId).join(', '),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              ),
            ],
          ),
        ],
        if (skin.chromas.length > 1) ...[
          const SizedBox(height: 20),
          _SectionTitle(
            SkinDetailStrings.variants,
            trailing: chroma == null || chroma!.isBase ? null : chroma!.label,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final c in skin.chromas)
                _ChromaSwatch(
                  chroma: c,
                  selected: c.uuid == chroma?.uuid,
                  locked:
                      ownedForLocks != null &&
                      !ownedForLocks.isChromaOwned(c.uuid),
                  onTap: () {
                    if (c.uuid != chroma?.uuid) Haptics.selection();
                    onChromaSelected(c);
                  },
                ),
            ],
          ),
        ],
        if (skin.levels.length > 1) ...[
          const SizedBox(height: 20),
          const _SectionTitle(SkinDetailStrings.upgrades),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final l in skin.levels)
                _LevelChip(
                  level: l,
                  locked:
                      ownedForLocks != null &&
                      !ownedForLocks.isSkinLevelOwned(l.uuid),
                ),
            ],
          ),
        ],
        if (puuid != null && showWishlist) ...[
          const SizedBox(height: 24),
          _WishlistButton(
            active: inWishlist,
            onPressed: () {
              Haptics.light();
              unawaited(
                ref
                    .read(wishlistProvider(puuid).notifier)
                    .toggleSkin(skin.uuid, db),
              );
            },
          ),
        ],
      ],
    );
  }
}

class _Media extends StatelessWidget {
  const _Media({required this.render, required this.video, required this.tint});

  final String? render;
  final String? video;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dark = theme.brightness == Brightness.dark;
    final solid = tint.withValues(alpha: 1);
    final v = video;
    return Semantics(
      button: v != null,
      label: v == null ? null : SkinDetailStrings.playVideo,
      child: Material(
        color: scheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ValRadius.card),
          side: BorderSide(color: solid.withValues(alpha: 0.35)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: v == null
              ? null
              : () => unawaited(openSkinVideo(context, videoUrl: v)),
          child: Ink(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.9,
                colors: [
                  solid.withValues(alpha: dark ? 0.5 : 0.3),
                  solid.withValues(alpha: dark ? 0.04 : 0.02),
                ],
              ),
              border: Border(bottom: BorderSide(color: solid, width: 3)),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                    child: AnimatedSwitcher(
                      duration: ValMotion.medium,
                      switchInCurve: ValMotion.curve,
                      transitionBuilder: (child, animation) => FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: Tween(
                            begin: 0.94,
                            end: 1.0,
                          ).animate(animation),
                          child: child,
                        ),
                      ),
                      child: NetImage(
                        render,
                        key: ValueKey(render),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  if (v != null)
                    PositionedDirectional(
                      end: 10,
                      bottom: 12,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.62),
                          borderRadius: BorderRadius.circular(ValRadius.pill),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(8, 6, 12, 6),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.play_circle_fill,
                                color: ValColors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                SkinDetailStrings.playVideo,
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
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

/// Price or reward-source label (VF §6.2 S15, C9).
class _PriceLabel extends StatelessWidget {
  const _PriceLabel({required this.quote});

  final PriceQuote quote;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w700,
    );
    final caption = quote.caption;
    if (caption != null) {
      return Text(
        caption,
        style: style?.copyWith(color: valColorsOf(context).warning),
      );
    }
    final vp = quote.vp;
    if (vp == null) return Text(CommonStrings.dash, style: style);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        CurrencyAmount.vp(
          vp,
          iconSize: 18,
          estimate: quote.isEstimate,
          style: style,
        ),
        VndEstimate(vp),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.trailing});

  final String title;
  final String? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          title,
          style: ValText.sectionTitle.copyWith(
            fontSize: 17,
            color: theme.colorScheme.onSurface,
          ),
        ),
        if (trailing != null) ...[
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              trailing!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ChromaSwatch extends StatelessWidget {
  const _ChromaSwatch({
    required this.chroma,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final SkinChroma chroma;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: locked
          ? '${chroma.label}, ${SkinDetailStrings.locked}'
          : chroma.label,
      excludeSemantics: true,
      child: Tooltip(
        message: chroma.label,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: AnimatedContainer(
            duration: ValMotion.fast,
            curve: ValMotion.curve,
            width: 52,
            height: 52,
            padding: EdgeInsets.all(selected ? 4 : 3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? scheme.primary : scheme.outline,
                width: selected ? 2.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: scheme.primary.withValues(alpha: 0.35),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: scheme.surfaceContainerHigh,
                    child: NetImage(
                      chroma.swatch ?? chroma.displayIcon,
                      fit: BoxFit.cover,
                      showSkeleton: false,
                    ),
                  ),
                  if (locked)
                    ColoredBox(
                      color: Colors.black.withValues(alpha: 0.55),
                      child: const Icon(
                        Icons.lock,
                        size: 16,
                        color: Colors.white,
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

class _LevelChip extends StatelessWidget {
  const _LevelChip({required this.level, required this.locked});

  final SkinLevel level;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final video = level.streamedVideo;
    final muted = theme.colorScheme.onSurfaceVariant;
    final levelText = ContentStrings.level(level.levelNumber);
    return Semantics(
      button: video != null,
      label: [
        SkinDetailStrings.levelCaption(levelText, level.levelItemLabel),
        if (locked) SkinDetailStrings.locked,
        if (video != null) SkinDetailStrings.playVideo,
      ].join(', '),
      excludeSemantics: true,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: 100,
          maxWidth: 156,
          minHeight: 48,
        ),
        child: Material(
          color: theme.colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: video == null
                ? null
                : () => unawaited(openSkinVideo(context, videoUrl: video)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          levelText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: locked ? muted : null,
                          ),
                        ),
                      ),
                      if (video != null) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.play_circle_fill,
                          size: 16,
                          color: ValColors.red,
                        ),
                      ],
                      if (locked) ...[
                        const SizedBox(width: 6),
                        Icon(Icons.lock, size: 14, color: muted),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    level.levelItemLabel,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
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

class _WishlistButton extends StatelessWidget {
  const _WishlistButton({required this.active, required this.onPressed});

  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = AnimatedSwitcher(
      duration: ValMotion.fast,
      transitionBuilder: (child, animation) =>
          ScaleTransition(scale: animation, child: child),
      child: Icon(
        active ? Icons.favorite : Icons.favorite_border,
        key: ValueKey(active),
        color: active ? ValColors.red : null,
      ),
    );
    final label = Text(
      active ? SkinDetailStrings.inWishlist : SkinDetailStrings.addToWishlist,
    );
    return Semantics(
      toggled: active,
      hint: active ? SkinDetailStrings.removeFromWishlist : null,
      child: SizedBox(
        height: 48,
        child: active
            ? OutlinedButton.icon(
                onPressed: onPressed,
                icon: icon,
                label: label,
              )
            : FilledButton.icon(onPressed: onPressed, icon: icon, label: label),
      ),
    );
  }
}
