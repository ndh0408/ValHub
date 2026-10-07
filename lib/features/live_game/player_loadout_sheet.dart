import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/accounts/account_providers.dart';
import '../../core/content/content_db.dart';
import '../../core/content/content_repository.dart';
import '../../core/domain/loadout/loadout.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tier_colors.dart';
import '../../core/ui/adaptive.dart';
import '../../core/ui/empty_view.dart';
import '../../core/ui/error_view.dart';
import '../../core/ui/net_image.dart';
import '../../core/ui/section_header.dart';
import '../../core/ui/skeleton.dart';
import '../../core/ui/skin_art_card.dart';
import '../../core/ui/sub_page.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Opens S51 "Trang bị của người chơi" for [playerPuuid] in [matchId].
///
/// [pregame] reads the agent-select loadouts (G-7, allies only) instead of
/// the running match (G-10). [viewerPuuid] is the signed-in account whose
/// session is used (default: the active one). [playerName] is the label
/// already shown in the roster ("Ẩn danh" for hidden players).
Future<void> showPlayerLoadoutSheet(
  BuildContext context, {
  required String matchId,
  required String playerPuuid,
  bool pregame = false,
  String? viewerPuuid,
  String? playerName,
}) => showModalBottomSheet<void>(
  context: context,
  useRootNavigator: true,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => PlayerLoadoutSheet(
    matchId: matchId,
    playerPuuid: playerPuuid,
    pregame: pregame,
    viewerPuuid: viewerPuuid,
    playerName: playerName,
  ),
);

/// S51: equipped skins / chromas, buddies, card, title, sprays of a player,
/// under the shared sheet header (name, agent portrait, close button).
class PlayerLoadoutSheet extends ConsumerWidget {
  const PlayerLoadoutSheet({
    super.key,
    required this.matchId,
    required this.playerPuuid,
    this.pregame = false,
    this.viewerPuuid,
    this.playerName,
  });

  final String matchId;
  final String playerPuuid;
  final bool pregame;
  final String? viewerPuuid;
  final String? playerName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final height = MediaQuery.sizeOf(context).height * 0.85;
    final viewer = viewerPuuid ?? ref.watch(activePuuidProvider);
    final name = playerName;
    final title = name == null || name.trim().isEmpty
        ? context.l10n.liveGamePlayerLoadoutTitle
        : context.l10n.liveGamePlayerLoadoutOf(name);

    Widget? leading;
    Object? staleError;
    final Widget body;
    if (viewer == null) {
      body = EmptyView(
        message: context.l10n.commonErrorNoAccount,
        icon: Icons.person_off_outlined,
      );
    } else {
      final query = (
        puuid: viewer,
        matchId: matchId.trim().toLowerCase(),
        pregame: pregame,
      );
      final value = ref.watch(matchLoadoutsProvider(query));
      Future<void> refresh() =>
          ref.refresh(matchLoadoutsProvider(query).future);
      final loadouts = value.value;
      if (loadouts != null && value.hasError && !value.isLoading) {
        staleError = value.error;
      }
      final loadout = loadouts?.player(playerPuuid);
      if (loadout != null) {
        final db = ref.watch(contentProvider).value ?? ContentDb.empty();
        final icon = loadout.characterId == null
            ? null
            : db.agent(loadout.characterId!)?.displayIcon;
        if (icon != null) leading = _AgentDot(icon: icon);
      }
      if (loadouts == null) {
        body = value.hasError && !value.isLoading
            ? ErrorView(
                error: value.error!,
                puuid: viewer,
                onRetry: () => ref.invalidate(matchLoadoutsProvider(query)),
              )
            : const _LoadoutSkeleton();
      } else if (loadout == null) {
        body = AdaptiveRefresh(
          onRefresh: refresh,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: [
              EmptyView(
                message: context.l10n.liveGameNoLoadout,
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
        );
      } else {
        body = AdaptiveRefresh(
          onRefresh: refresh,
          child: PlayerLoadoutView(loadout: loadout),
        );
      }
    }

    return SizedBox(
      height: height,
      child: Column(
        children: [
          SheetHeader(
            title: title,
            subtitle: pregame
                ? context.l10n.liveGameLoadoutFromAgentSelect
                : context.l10n.liveGameLoadoutFromMatch,
            leading: leading,
            padding: const EdgeInsetsDirectional.fromSTEB(20, 0, 12, 10),
          ),
          // A failed refresh keeps the data and says so on top.
          if (staleError != null && viewer != null)
            ErrorView(
              error: staleError,
              puuid: viewer,
              compact: true,
              onRetry: () => ref.invalidate(
                matchLoadoutsProvider((
                  puuid: viewer,
                  matchId: matchId.trim().toLowerCase(),
                  pregame: pregame,
                )),
              ),
            ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Round agent portrait in the sheet header.
class _AgentDot extends StatelessWidget {
  const _AgentDot({required this.icon});

  final String icon;

  @override
  Widget build(BuildContext context) => Container(
    width: 40,
    height: 40,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    ),
    clipBehavior: Clip.antiAlias,
    child: NetImage(icon, width: 40, height: 40, fit: BoxFit.cover),
  );
}

/// Loading state mirroring the final layout: identity card, then the weapon
/// grid.
class _LoadoutSkeleton extends StatelessWidget {
  const _LoadoutSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Skeleton(height: 88, radius: 16, shimmer: false),
            const SizedBox(height: 20),
            const Skeleton(width: 80, height: 14, shimmer: false),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, c) {
                const gap = 10.0;
                final columns = c.maxWidth >= 520 ? 3 : 2;
                final width = (c.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (var i = 0; i < columns * 3; i++)
                      Skeleton(
                        width: width,
                        height: _tileExtent(context),
                        radius: ValRadius.card,
                        shimmer: false,
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Height of a weapon tile: the render plus a name (2 lines) and the weapon
/// line at the user's text size (no overflow up to 200 %).
double _tileExtent(BuildContext context) => 112 + _tileText(context);

double _tileText(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
  // Name: 2 lines × 14 × 1.25; weapon line ≈ 16; paddings 12 + 2.
  return 66 * scale + 12;
}

/// Card + title, weapon skins (with buddies), sprays and Flex of one match
/// loadout.
class PlayerLoadoutView extends ConsumerWidget {
  const PlayerLoadoutView({super.key, required this.loadout});

  final MatchPlayerLoadout loadout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final card = loadout.playerCardId == null
        ? null
        : db.card(loadout.playerCardId!);
    final titleText = loadout.playerTitleId == null
        ? null
        : db.title(loadout.playerTitleId!)?.text;
    final agent = loadout.characterId == null
        ? null
        : db.agent(loadout.characterId!);

    // Weapons in content order (category, then name); unknown ids last.
    final known = <String>{};
    final weapons = <(Weapon?, MatchGun)>[];
    for (final w in db.weapons) {
      final gun = loadout.gun(w.uuid);
      if (gun == null) continue;
      known.add(w.uuid);
      weapons.add((w, gun));
    }
    for (final gun in loadout.guns.values) {
      if (!known.contains(gun.weaponId)) weapons.add((null, gun));
    }
    final sprays = [for (final id in loadout.sprayIds) ?db.spray(id)];
    final flexItems = [for (final id in loadout.flexIds) ?db.flex(id)];
    final tile = _tileExtent(context);
    final text = _tileText(context);

    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        if (card != null || titleText != null || agent != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: _IdentityCard(
                wideArt: card?.wideArt,
                agentName: agent?.displayName,
                agentIcon: agent?.displayIcon,
                title: titleText,
              ),
            ),
          ),
        if (weapons.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: SectionHeader(context.l10n.liveGameWeapons),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 220,
                mainAxisExtent: tile,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
              ),
              delegate: SliverChildBuilderDelegate((context, i) {
                final (weapon, gun) = weapons[i];
                return _GunTile(
                  weapon: weapon,
                  gun: gun,
                  db: db,
                  imageFlex: (4 * 112 / text).floor().clamp(1, 8),
                );
              }, childCount: weapons.length),
            ),
          ),
        ],
        if (sprays.isNotEmpty) ...[
          SliverToBoxAdapter(child: SectionHeader(context.l10n.liveGameSprays)),
          SliverToBoxAdapter(
            child: _ImageStrip(
              items: [for (final s in sprays) (s.image, s.displayName)],
            ),
          ),
        ],
        if (flexItems.isNotEmpty) ...[
          SliverToBoxAdapter(child: SectionHeader(context.l10n.liveGameFlex)),
          SliverToBoxAdapter(
            child: _ImageStrip(
              items: [
                for (final f in flexItems) (f.displayIcon, f.displayName),
              ],
            ),
          ),
        ],
        SliverToBoxAdapter(
          child: SizedBox(height: 24 + MediaQuery.paddingOf(context).bottom),
        ),
      ],
    );
  }
}

/// The player's card art as a banner with the agent portrait, agent name and
/// title over a scrim. The base is always dark, so the white text stays
/// legible on both themes and when the art is missing.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({
    required this.wideArt,
    required this.agentName,
    required this.agentIcon,
    required this.title,
  });

  final String? wideArt;
  final String? agentName;
  final String? agentIcon;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(ValRadius.card),
      child: Container(
        color: ValColors.nearBlack,
        constraints: const BoxConstraints(minHeight: 88),
        child: Stack(
          children: [
            if (wideArt != null)
              Positioned.fill(
                child: NetImage(
                  wideArt,
                  fit: BoxFit.cover,
                  showSkeleton: false,
                ),
              ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withValues(alpha: 0.78),
                      Colors.black.withValues(alpha: 0.12),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  if (agentIcon != null) ...[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.5),
                          width: 1.5,
                        ),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: NetImage(
                        agentIcon,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (agentName != null)
                          Text(
                            agentName!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ValText.sectionTitle.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        if (title != null)
                          Text(
                            title!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.82),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One weapon: skin render on a rarity glow (the shared [SkinArtCard]),
/// skin and weapon names, and the buddy in the corner.
class _GunTile extends StatelessWidget {
  const _GunTile({
    required this.weapon,
    required this.gun,
    required this.db,
    required this.imageFlex,
  });

  final Weapon? weapon;
  final MatchGun gun;
  final ContentDb db;
  final int imageFlex;

  @override
  Widget build(BuildContext context) {
    final skin = gun.skinId == null ? null : db.skin(gun.skinId!);
    final chroma = gun.chromaId == null ? null : db.skinChroma(gun.chromaId!);
    final level = gun.skinLevelId == null
        ? null
        : db.skinLevel(gun.skinLevelId!);
    final image =
        chroma?.fullRender ??
        chroma?.displayIcon ??
        level?.displayIcon ??
        skin?.image ??
        weapon?.displayIcon;
    final buddy = gun.buddyLevelId != null
        ? db.buddyByLevelUuid(gun.buddyLevelId!)
        : (gun.buddyId == null ? null : db.buddy(gun.buddyId!));
    final skinName =
        skin?.displayName ??
        weapon?.displayName ??
        context.l10n.commonUnknownItem;
    final tierHex = skin == null
        ? null
        : db.contentTier(skin.contentTierUuid)?.highlightColor;
    final tint = tierHex == null ? null : opaqueRgba(tierHex);
    final buddyImage = buddy?.image;

    return SkinArtCard(
      imageUrl: image,
      name: skinName,
      subtitle: weapon?.displayName,
      tierColor: tint,
      imageFlex: imageFlex,
      topEnd: buddyImage == null
          ? null
          : Tooltip(
              message: buddy!.displayName,
              child: NetImage(
                buddyImage,
                width: 28,
                height: 28,
                showSkeleton: false,
              ),
            ),
    );
  }
}

class _ImageStrip extends StatelessWidget {
  const _ImageStrip({required this.items});

  final List<(String?, String)> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final (image, name) in items)
            Tooltip(
              message: name,
              child: Container(
                width: 72,
                height: 72,
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(ValRadius.small),
                ),
                child: NetImage(image, fit: BoxFit.contain),
              ),
            ),
        ],
      ),
    );
  }
}
