import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/riot/riot_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/content_tier_badge.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/section_header.dart';
import '../../../core/ui/skeleton.dart';
import '../../skin_detail/skin_video_view.dart';
import '../collection_strings.dart';
import '../data/loadout_view.dart';
import '../providers/collection_providers.dart';
import 'buddy_picker_sheet.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/loadout_actions.dart';

/// S35 "Tùy chỉnh skin": preview / video, owned variants and levels (locked
/// ones greyed), buddy slot and "Trang bị". Route
/// `/collection/weapons/:weaponId/skin/:skinId`.
class SkinCustomizeScreen extends ConsumerStatefulWidget {
  const SkinCustomizeScreen({
    super.key,
    required this.weaponId,
    required this.skinId,
  });

  final String weaponId;

  final String skinId;

  @override
  ConsumerState<SkinCustomizeScreen> createState() =>
      _SkinCustomizeScreenState();
}

class _SkinCustomizeScreenState extends ConsumerState<SkinCustomizeScreen> {
  String? _levelUuid;
  String? _chromaUuid;

  String get _weaponId => widget.weaponId.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final skin = ref.watch(contentProvider).value?.skinByAnyUuid(widget.skinId);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          skin == null ? CollectionStrings.skinCustomizeTitle : skinLabel(skin),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: CollectionAccountGate(
        builder: (context, account) => LoadoutDataBuilder(
          puuid: account.puuid,
          loading: const _CustomizeSkeleton(),
          builder: (context, snapshot, owned, db) {
            final s = db.skinByAnyUuid(widget.skinId);
            if (s == null) {
              return const EmptyView(
                message: CollectionStrings.skinNotFound,
                icon: Icons.help_outline,
              );
            }
            return _buildBody(context, account.puuid, snapshot, owned, db, s);
          },
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    String puuid,
    LoadoutSnapshot snapshot,
    OwnedItems owned,
    ContentDb db,
    WeaponSkin skin,
  ) {
    final theme = Theme.of(context);
    final gun = snapshot.loadout.gun(_weaponId);
    final isOwned = owned.isSkinOwned(skin.uuid);
    final ownedLevels = owned.ownedLevels(skin);
    final wearing = gun?.skinId == skin.uuid;

    // Selection: what is equipped, else the best owned level + base chroma.
    var levelId = _levelUuid;
    if (levelId == null || !owned.isSkinLevelOwned(levelId)) {
      levelId = wearing && gun?.skinLevelId != null
          ? gun!.skinLevelId
          : (ownedLevels.lastOrNull ?? skin.levels.firstOrNull)?.uuid;
    }
    var chromaId = _chromaUuid;
    if (chromaId == null || !owned.isChromaOwned(chromaId)) {
      chromaId = wearing && gun?.chromaId != null
          ? gun!.chromaId
          : skin.chromas.firstOrNull?.uuid;
    }
    final level = levelId == null ? null : db.skinLevel(levelId);
    final chroma = chromaId == null ? null : db.skinChroma(chromaId);

    final render =
        chroma?.fullRender ??
        chroma?.displayIcon ??
        level?.displayIcon ??
        skin.render;
    final video =
        (level != null && level.index > 0 ? level.streamedVideo : null) ??
        chroma?.streamedVideo ??
        ((chroma?.isBase ?? true) ? skin.previewVideo : null);
    final isSelectionEquipped =
        wearing && gun?.skinLevelId == levelId && gun?.chromaId == chromaId;
    final canEquip =
        isOwned &&
        gun != null &&
        levelId != null &&
        chromaId != null &&
        !isSelectionEquipped &&
        !snapshot.isPending;
    final tint = contentTierTint(
      ref,
      skin.contentTierUuid,
      fallback: theme.colorScheme.surfaceContainerHigh,
    );
    final buddy = equippedBuddy(gun, db);
    final isMelee = gun?.isMelee ?? _weaponId == SpecialIds.melee;

    return Column(
      children: [
        SavingBar(visible: snapshot.isPending),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => refreshCollection(ref, puuid),
            child: ListView(
              padding: const EdgeInsets.only(bottom: 16),
              children: [
                _Preview(
                  render: render,
                  video: video,
                  tint: tint,
                  tierUuid: skin.contentTierUuid,
                ),
                if (!isOwned)
                  const _Notice(
                    icon: Icons.lock_outline,
                    text: CollectionStrings.skinNotOwned,
                  ),
                if (skin.chromas.length > 1) ...[
                  const SectionHeader(CollectionStrings.variants),
                  SizedBox(
                    height: 64,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: skin.chromas.length,
                      separatorBuilder: (_, _) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final c = skin.chromas[i];
                        final unlocked = owned.isChromaOwned(c.uuid);
                        return _ChromaSwatch(
                          image: c.swatch ?? c.displayIcon ?? c.fullRender,
                          label: c.label.isEmpty ? skin.displayName : c.label,
                          selected: c.uuid == chromaId,
                          locked: !unlocked,
                          onTap: unlocked
                              ? () => setState(() => _chromaUuid = c.uuid)
                              : null,
                        );
                      },
                    ),
                  ),
                  if (chroma != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        chroma.label.isEmpty ? skin.displayName : chroma.label,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
                if (skin.levels.length > 1) ...[
                  const SectionHeader(CollectionStrings.levels),
                  for (final l in skin.levels)
                    _LevelTile(
                      title: CollectionStrings.levelLabel(
                        l.levelNumber,
                        l.levelItemLabel,
                      ),
                      selected: l.uuid == levelId,
                      locked: !owned.isSkinLevelOwned(l.uuid),
                      onTap: () => setState(() => _levelUuid = l.uuid),
                    ),
                ],
                if (!isMelee && gun != null) ...[
                  const SectionHeader(CollectionStrings.buddySlot),
                  _BuddySlot(
                    name: buddy?.displayName,
                    image: buddy?.image,
                    onTap: snapshot.isPending
                        ? null
                        : () => unawaited(
                            showBuddyPickerSheet(context, weaponId: _weaponId),
                          ),
                  ),
                ],
              ],
            ),
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: canEquip
                  ? () => unawaited(
                      applyLoadoutChange(
                        context,
                        ref,
                        puuid: puuid,
                        change: EquipSkin(
                          weaponId: _weaponId,
                          skinId: skin.uuid,
                          skinLevelId: levelId!,
                          chromaId: chromaId!,
                        ),
                        successMessage: CollectionStrings.equippedItem(
                          skinLabel(skin),
                        ),
                      ),
                    )
                  : null,
              icon: Icon(isSelectionEquipped ? Icons.check : Icons.done_all),
              label: Text(
                snapshot.isPending
                    ? CollectionStrings.saving
                    : (isSelectionEquipped
                          ? CollectionStrings.equipped
                          : CollectionStrings.equip),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Preview extends StatelessWidget {
  const _Preview({
    required this.render,
    required this.video,
    required this.tint,
    required this.tierUuid,
  });

  final String? render;
  final String? video;
  final Color tint;
  final String? tierUuid;

  @override
  Widget build(BuildContext context) {
    final v = video;
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            radius: 1.1,
            colors: [
              tint.withValues(alpha: 0.45),
              tint.withValues(alpha: 0.02),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
              child: NetImage(render, fit: BoxFit.contain),
            ),
            if (tierUuid != null)
              Positioned(
                left: 16,
                top: 12,
                child: ContentTierBadge(
                  contentTierUuid: tierUuid,
                  showName: true,
                ),
              ),
            if (v != null)
              Positioned(
                right: 12,
                bottom: 12,
                child: FilledButton.tonalIcon(
                  onPressed: () =>
                      unawaited(openSkinVideo(context, videoUrl: v)),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text(CollectionStrings.playVideo),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final warning = valColorsOf(context).warning;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: warning),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

class _ChromaSwatch extends StatelessWidget {
  const _ChromaSwatch({
    required this.image,
    required this.label,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final String? image;
  final String label;
  final bool selected;
  final bool locked;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      enabled: !locked,
      label: locked ? '$label, ${CollectionStrings.locked}' : label,
      excludeSemantics: true,
      child: Tooltip(
        message: locked ? '$label · ${CollectionStrings.locked}' : label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 60,
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? ValColors.red : scheme.outlineVariant,
                width: selected ? 2 : 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Opacity(
                  opacity: locked ? 0.3 : 1,
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: NetImage(image, fit: BoxFit.contain),
                  ),
                ),
                if (locked)
                  Center(
                    child: Icon(
                      Icons.lock,
                      size: 18,
                      color: scheme.onSurfaceVariant,
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

class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.title,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final String title;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      enabled: !locked,
      selected: selected,
      onTap: locked ? null : onTap,
      leading: Icon(
        locked
            ? Icons.lock
            : (selected ? Icons.radio_button_checked : Icons.radio_button_off),
        color: locked
            ? scheme.onSurfaceVariant
            : (selected ? ValColors.red : scheme.onSurfaceVariant),
      ),
      title: Text(title),
      subtitle: locked ? const Text(CollectionStrings.locked) : null,
    );
  }
}

class _BuddySlot extends StatelessWidget {
  const _BuddySlot({required this.name, required this.image, this.onTap});

  final String? name;
  final String? image;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: name == null
                      ? Icon(
                          Icons.add,
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : NetImage(image, fit: BoxFit.contain),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name ?? CollectionStrings.noBuddy,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: name == null
                        ? theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          )
                        : theme.textTheme.bodyLarge,
                  ),
                ),
                Text(
                  CollectionStrings.changeBuddy,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: ValColors.red,
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

class _CustomizeSkeleton extends StatelessWidget {
  const _CustomizeSkeleton();

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Skeleton(shimmer: false, radius: 4),
          ),
          SizedBox(height: 20),
          Skeleton(width: 120, shimmer: false),
          SizedBox(height: 12),
          Skeleton(height: 56, shimmer: false),
          SizedBox(height: 20),
          Skeleton(width: 120, shimmer: false),
          SizedBox(height: 12),
          Skeleton(height: 48, shimmer: false),
          SizedBox(height: 8),
          Skeleton(height: 48, shimmer: false),
        ],
      ),
    ),
  );
}
