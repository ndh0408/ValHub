import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/accounts/account_providers.dart';
import '../../core/content/content_db.dart';
import '../../core/content/content_repository.dart';
import '../../core/domain/loadout/loadout.dart';
import '../../core/l10n/common_strings.dart';
import '../../core/theme/tier_colors.dart';
import '../../core/ui/async_value_view.dart';
import '../../core/ui/empty_view.dart';
import '../../core/ui/net_image.dart';
import '../../core/ui/section_header.dart';
import '../../core/ui/skeleton.dart';
import 'live_game_strings.dart';

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
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => PlayerLoadoutSheet(
    matchId: matchId,
    playerPuuid: playerPuuid,
    pregame: pregame,
    viewerPuuid: viewerPuuid,
    playerName: playerName,
  ),
);

/// S51: equipped skins / chromas, buddies, card, title, sprays of a player.
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
    final theme = Theme.of(context);
    final height = MediaQuery.sizeOf(context).height * 0.85;
    final viewer = viewerPuuid ?? ref.watch(activePuuidProvider);
    final name = playerName;
    final title = name == null || name.trim().isEmpty
        ? LiveGameStrings.playerLoadoutTitle
        : LiveGameStrings.playerLoadoutOf(name);

    final Widget body;
    if (viewer == null) {
      body = const EmptyView(message: CommonStrings.errorNoAccount);
    } else {
      final query = (
        puuid: viewer,
        matchId: matchId.trim().toLowerCase(),
        pregame: pregame,
      );
      body = AsyncValueView<MatchLoadouts>(
        value: ref.watch(matchLoadoutsProvider(query)),
        puuid: viewer,
        onRetry: () => ref.invalidate(matchLoadoutsProvider(query)),
        loading: const SkeletonGrid(itemCount: 6),
        isEmpty: (l) => l.player(playerPuuid) == null,
        empty: RefreshIndicator(
          onRefresh: () => ref.refresh(matchLoadoutsProvider(query).future),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            children: const [
              EmptyView(
                message: LiveGameStrings.noLoadout,
                icon: Icons.inventory_2_outlined,
              ),
            ],
          ),
        ),
        data: (loadouts) => RefreshIndicator(
          onRefresh: () => ref.refresh(matchLoadoutsProvider(query).future),
          child: PlayerLoadoutView(loadout: loadouts.player(playerPuuid)!),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: LiveGameStrings.close,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(context).maybePop(),
                ),
              ],
            ),
          ),
          Expanded(child: body),
        ],
      ),
    );
  }
}

/// Card + title, weapon skins (with buddies), sprays and Flex of one match
/// loadout.
class PlayerLoadoutView extends ConsumerWidget {
  const PlayerLoadoutView({super.key, required this.loadout});

  final MatchPlayerLoadout loadout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (card != null || titleText != null || agent != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: theme.colorScheme.surfaceContainerHigh,
                constraints: const BoxConstraints(minHeight: 72),
                child: Stack(
                  children: [
                    if (card?.wideArt != null)
                      Positioned.fill(
                        child: NetImage(
                          card!.wideArt,
                          fit: BoxFit.cover,
                          showSkeleton: false,
                        ),
                      ),
                    Positioned.fill(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.black.withValues(alpha: 0.75),
                              Colors.black.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          if (agent?.displayIcon != null) ...[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: NetImage(
                                agent!.displayIcon,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (agent != null)
                                  Text(
                                    agent.displayName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(color: Colors.white),
                                  ),
                                if (titleText != null)
                                  Text(
                                    titleText,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: Colors.white70,
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
            ),
          ),
        if (weapons.isNotEmpty) ...[
          const SectionHeader(LiveGameStrings.weapons),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                const gap = 8.0;
                final columns = constraints.maxWidth >= 520 ? 3 : 2;
                final width =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final (weapon, gun) in weapons)
                      SizedBox(
                        width: width,
                        child: _GunTile(weapon: weapon, gun: gun, db: db),
                      ),
                  ],
                );
              },
            ),
          ),
        ],
        if (sprays.isNotEmpty) ...[
          const SectionHeader(LiveGameStrings.sprays),
          _ImageStrip(
            items: [for (final s in sprays) (s.image, s.displayName)],
          ),
        ],
        if (flexItems.isNotEmpty) ...[
          const SectionHeader(LiveGameStrings.flex),
          _ImageStrip(
            items: [for (final f in flexItems) (f.displayIcon, f.displayName)],
          ),
        ],
      ],
    );
  }
}

class _GunTile extends StatelessWidget {
  const _GunTile({required this.weapon, required this.gun, required this.db});

  final Weapon? weapon;
  final MatchGun gun;
  final ContentDb db;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        skin?.displayName ?? weapon?.displayName ?? CommonStrings.unknownItem;
    final tierHex = skin == null
        ? null
        : db.contentTier(skin.contentTierUuid)?.highlightColor;
    final tint = tierHex == null ? null : opaqueRgba(tierHex);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(12),
        border: tint == null
            ? null
            : Border(bottom: BorderSide(color: tint, width: 2)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 56,
            child: Stack(
              children: [
                Positioned.fill(child: NetImage(image, fit: BoxFit.contain)),
                if (buddy?.image != null)
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: Tooltip(
                      message: buddy!.displayName,
                      child: NetImage(
                        buddy.image,
                        width: 24,
                        height: 24,
                        showSkeleton: false,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            skinName,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          if (weapon != null)
            Text(
              weapon!.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
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
                  color: theme.colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: NetImage(image, fit: BoxFit.contain),
              ),
            ),
        ],
      ),
    );
  }
}
