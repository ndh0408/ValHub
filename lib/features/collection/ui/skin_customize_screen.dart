import 'collection_labels.dart';

import 'package:valvn/core/l10n/labels/content_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/riot/riot_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/content_tier_badge.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../skin_detail/skin_video_view.dart';
import '../data/buddy_options.dart';
import '../data/loadout_view.dart';
import '../providers/collection_providers.dart';
import 'buddy_picker_sheet.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/gun_hero.dart';
import 'widgets/loadout_actions.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S35 "Tùy chỉnh skin": the chosen variant / level render as the header
/// art (flies in from the skin list; cross-fades on change) with "Xem
/// video", owned variants and levels (locked ones greyed, each level's
/// video playable), the buddy slot and a fixed "Trang bị" bar. Route
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

/// What the page shows for the current picks.
class _Selection {
  _Selection({
    required this.skin,
    required this.levelId,
    required this.chromaId,
    required this.level,
    required this.chroma,
    required this.wearing,
    required this.isEquipped,
  });

  factory _Selection.of(
    WeaponSkin skin,
    ContentDb db, {
    required GunLoadout? gun,
    required OwnedItems? owned,
    required String? pickedLevel,
    required String? pickedChroma,
  }) {
    final wearing = gun?.skinId == skin.uuid;
    final ownedLevels = owned?.ownedLevels(skin) ?? const <SkinLevel>[];
    // What is equipped, else the best owned level + the base variant.
    var levelId = pickedLevel;
    if (levelId == null || !(owned?.isSkinLevelOwned(levelId) ?? false)) {
      levelId = wearing && gun?.skinLevelId != null
          ? gun!.skinLevelId
          : (ownedLevels.lastOrNull ?? skin.levels.firstOrNull)?.uuid;
    }
    var chromaId = pickedChroma;
    if (chromaId == null || !(owned?.isChromaOwned(chromaId) ?? false)) {
      chromaId = wearing && gun?.chromaId != null
          ? gun!.chromaId
          : skin.chromas.firstOrNull?.uuid;
    }
    return _Selection(
      skin: skin,
      levelId: levelId,
      chromaId: chromaId,
      level: levelId == null ? null : db.skinLevel(levelId),
      chroma: chromaId == null ? null : db.skinChroma(chromaId),
      wearing: wearing,
      isEquipped:
          wearing && gun?.skinLevelId == levelId && gun?.chromaId == chromaId,
    );
  }

  final WeaponSkin skin;
  final String? levelId;
  final String? chromaId;
  final SkinLevel? level;
  final SkinChroma? chroma;
  final bool wearing;
  final bool isEquipped;

  String? get render =>
      chroma?.fullRender ??
      chroma?.displayIcon ??
      level?.displayIcon ??
      skin.render;

  String? get video =>
      (level != null && level!.index > 0 ? level!.streamedVideo : null) ??
      chroma?.streamedVideo ??
      ((chroma?.isBase ?? true) ? skin.previewVideo : null);
}

class _SkinCustomizeScreenState extends ConsumerState<SkinCustomizeScreen> {
  String? _levelUuid;
  String? _chromaUuid;

  /// Buddy picked in S36, saved with the variant and level by "Trang bị".
  BuddyPick? _buddyPick;

  String get _weaponId => widget.weaponId.trim().toLowerCase();

  Future<void> _pickBuddy(GunLoadout? gun) async {
    final pick = await showBuddyPickerSheet(
      context,
      weaponId: _weaponId,
      pending: _buddyPick,
    );
    if (pick == null || !mounted) return;
    // Picking what the gun already wears drops the pending change.
    setState(() => _buddyPick = pick.isSavedOn(gun) ? null : pick);
  }

  Future<void> _equip({
    required String puuid,
    required WeaponSkin skin,
    required _Selection sel,
  }) async {
    Haptics.light();
    final l10n = context.l10n;
    final buddy = _buddyPick;
    final changes = <LoadoutChange>[
      if (!sel.isEquipped)
        EquipSkin(
          weaponId: _weaponId,
          skinId: skin.uuid,
          skinLevelId: sel.levelId!,
          chromaId: sel.chromaId!,
        ),
      ?buddy?.changeFor(_weaponId),
    ];
    if (changes.isEmpty) return;
    final ok = await applyLoadoutChange(
      context,
      ref,
      puuid: puuid,
      change: changes.length == 1 ? changes.single : LoadoutChange.all(changes),
      successMessage: switch (buddy) {
        _ when !sel.isEquipped => l10n.collectionEquippedItem(
          skin.equippedLabel(l10n),
        ),
        BuddyPickEquip(:final option) => l10n.collectionEquippedItem(
          option.buddy.displayName,
        ),
        _ => l10n.collectionBuddyRemoved,
      },
    );
    if (!ok) return;
    Haptics.medium();
    if (mounted && identical(_buddyPick, buddy)) {
      setState(() => _buddyPick = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final skin = db.skinByAnyUuid(widget.skinId);
    final title = skin == null
        ? context.l10n.collectionSkinCustomizeTitle
        : skin.equippedLabel(context.l10n);
    final account = ref.watch(activeAccountProvider);
    if (account == null) return NoAccountPage(title: title);
    final puuid = account.puuid;
    if (skin == null) {
      return SubPageScaffold(
        title: title,
        body: db.isEmpty
            ? const _CustomizeSkeleton()
            : EmptyView(
                message: context.l10n.collectionSkinNotFound,
                icon: Icons.help_outline,
              ),
      );
    }

    final snapshot = ref.watch(loadoutProvider(puuid)).value;
    final owned = ref.watch(ownedItemsProvider(puuid)).value;
    final gun = snapshot?.loadout.gun(_weaponId);
    final sel = _Selection.of(
      skin,
      db,
      gun: gun,
      owned: owned,
      pickedLevel: _levelUuid,
      pickedChroma: _chromaUuid,
    );
    final isOwned = owned?.isSkinOwned(skin.uuid) ?? false;
    final pending = snapshot?.isPending ?? false;
    final unsaved = !sel.isEquipped || _buddyPick != null;
    final canEquip =
        snapshot != null &&
        isOwned &&
        gun != null &&
        sel.levelId != null &&
        sel.chromaId != null &&
        unsaved &&
        !pending;
    final hasTier = !skin.isStandard && skin.contentTierUuid != null;
    final weapon = db.weapon(skin.weaponUuid) ?? db.weapon(_weaponId);
    final video = sel.video;
    final facts = [
      ?weapon?.displayName,
      ?skinTierName(ref, context, hasTier ? skin.contentTierUuid : null),
    ];

    return SubPageScaffold(
      title: title,
      subtitle: facts.isEmpty ? null : facts.join(' · '),
      hero: GunHero(
        render: sel.render,
        tint: hasTier
            ? skinTierColor(ref, context, skin.contentTierUuid)
            : null,
        heroTag: CollectionHeroTags.skin(skin.uuid),
        bottomStart: hasTier
            ? ContentTierBadge(
                contentTierUuid: skin.contentTierUuid,
                showName: true,
              )
            : null,
        bottomEnd: video == null
            ? null
            : FilledButton.tonalIcon(
                // Over the artwork: stays a solid button to be readable.
                style: FilledButton.styleFrom(
                  minimumSize: const Size(48, 40),
                  shape: const StadiumBorder(),
                ),
                onPressed: () =>
                    unawaited(openSkinVideo(context, videoUrl: video)),
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(context.l10n.collectionPlayVideo),
              ),
      ),
      heroHeight: 250,
      onRefresh: () => refreshCollection(ref, puuid),
      bottomBar: FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
        onPressed: canEquip
            ? () => unawaited(_equip(puuid: puuid, skin: skin, sel: sel))
            : null,
        icon: Icon(unsaved ? Icons.done_all : Icons.check),
        label: Text(
          pending
              ? context.l10n.collectionSaving
              : (unsaved
                    ? context.l10n.collectionEquip
                    : context.l10n.collectionEquipped),
        ),
      ),
      slivers: loadoutSlivers(
        ref,
        puuid: puuid,
        loading: const _CustomizeSkeleton(),
        data: (snapshot, owned, db) => [
          if (snapshot.isFromCache)
            const SliverToBoxAdapter(child: CachedLoadoutBanner()),
          SliverToBoxAdapter(child: SavingBar(visible: snapshot.isPending)),
          if (!isOwned)
            SliverToBoxAdapter(
              child: CollectionNotice(
                icon: Icons.lock_outline,
                text: context.l10n.collectionSkinNotOwned,
                margin: EdgeInsets.fromLTRB(16, 4, 16, 0),
              ),
            ),
          ..._body(
            context,
            sel,
            owned,
            gun,
            pending: snapshot.isPending,
            isOwned: isOwned,
          ),
        ],
      ),
    );
  }

  List<Widget> _body(
    BuildContext context,
    _Selection sel,
    OwnedItems owned,
    GunLoadout? gun, {
    required bool pending,
    required bool isOwned,
  }) {
    final theme = Theme.of(context);
    final skin = sel.skin;
    final ownedLevels = owned.ownedLevels(skin);
    final ownedChromas = owned.ownedChromas(skin);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    // The picked buddy until "Trang bị" saves it, else what the gun wears.
    final buddy = switch (_buddyPick) {
      BuddyPickEquip(:final option) => option.buddy,
      BuddyPickRemove() => null,
      null => equippedBuddy(gun, db),
    };
    final isMelee = gun?.isMelee ?? _weaponId == SpecialIds.melee;
    final chroma = sel.chroma;
    return [
      if (skin.chromas.length > 1) ...[
        SliverToBoxAdapter(
          child: CollectionSectionTitle(
            context.l10n.collectionVariants,
            trailing: context.l10n.collectionChromaCount(
              ownedChromas.length,
              skin.chromas.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 72,
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
                  selected: c.uuid == sel.chromaId,
                  locked: !unlocked,
                  onTap: unlocked
                      ? () {
                          Haptics.selection();
                          setState(() => _chromaUuid = c.uuid);
                        }
                      : null,
                );
              },
            ),
          ),
        ),
        if (chroma != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: AnimatedSwitcher(
                duration: ValMotion.fast,
                child: Text(
                  chroma.label.isEmpty ? skin.displayName : chroma.label,
                  key: ValueKey(chroma.uuid),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
      ],
      if (skin.levels.length > 1) ...[
        SliverToBoxAdapter(
          child: CollectionSectionTitle(
            context.l10n.collectionLevels,
            trailing: context.l10n.collectionLevelsUnlocked(
              ownedLevels.length,
              skin.levels.length,
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: GroupedSection(
            children: [
              for (final l in skin.levels)
                _LevelTile(
                  title: context.l10n.collectionLevelLabel(
                    l.levelNumber,
                    context.l10n.skinLevelItem(l),
                  ),
                  selected: l.uuid == sel.levelId,
                  locked: !owned.isSkinLevelOwned(l.uuid),
                  video: l.streamedVideo,
                  onTap: () {
                    Haptics.selection();
                    setState(() => _levelUuid = l.uuid);
                  },
                ),
            ],
          ),
        ),
      ],
      if (gun != null) ...[
        SliverToBoxAdapter(
          child: CollectionSectionTitle(context.l10n.collectionBuddySlot),
        ),
        SliverToBoxAdapter(
          child: isMelee
              ? CollectionNotice(
                  icon: Icons.info_outline,
                  text: context.l10n.collectionMeleeNoBuddy,
                  margin: EdgeInsets.symmetric(horizontal: 16),
                )
              : GroupedSection(
                  children: [
                    HubRow(
                      icon: Icons.link,
                      leading: _BuddyThumb(image: buddy?.image),
                      title:
                          buddy?.displayName ?? context.l10n.collectionNoBuddy,
                      value: context.l10n.collectionChangeBuddy,
                      // Saved with the skin by "Trang bị", so only for a
                      // skin the account owns.
                      onTap: pending || !isOwned
                          ? null
                          : () => unawaited(_pickBuddy(gun)),
                    ),
                  ],
                ),
        ),
      ],
    ];
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
      label: locked ? '$label, ${context.l10n.collectionLocked}' : label,
      excludeSemantics: true,
      child: Tooltip(
        message: locked ? '$label · ${context.l10n.collectionLocked}' : label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: ValMotion.fast,
            curve: ValMotion.curve,
            width: 72,
            decoration: BoxDecoration(
              color: selected
                  ? scheme.primary.withValues(alpha: 0.12)
                  : scheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? scheme.primary
                    : valColorsOf(context).hairline,
                width: selected ? 2 : 1,
              ),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: NetImage(
                    image,
                    fit: BoxFit.contain,
                    opacity: locked ? 0.3 : null,
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

/// One upgrade level: radio / lock, "Cấp 2 · Hiệu ứng hình ảnh", and its
/// video (playable even while locked, to preview an upgrade).
class _LevelTile extends StatelessWidget {
  const _LevelTile({
    required this.title,
    required this.selected,
    required this.locked,
    required this.onTap,
    this.video,
  });

  final String title;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;
  final String? video;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final icon = locked
        ? Icons.lock
        : (selected ? Icons.radio_button_checked : Icons.radio_button_off);
    final v = video;
    return Semantics(
      button: !locked,
      selected: selected,
      enabled: !locked,
      child: Material(
        color: selected && !locked
            ? scheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        child: InkWell(
          onTap: locked ? null : onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 6, 4, 6),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: ValMotion.fast,
                    transitionBuilder: (child, a) =>
                        ScaleTransition(scale: a, child: child),
                    child: Icon(
                      icon,
                      key: ValueKey(icon),
                      color: selected && !locked
                          ? legibleAccent(context, scheme.primary, min: 3)
                          : scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: selected
                                ? FontWeight.w700
                                : FontWeight.w500,
                            color: locked ? scheme.onSurfaceVariant : null,
                          ),
                        ),
                        if (locked)
                          Text(
                            context.l10n.collectionLocked,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (v != null)
                    IconButton(
                      tooltip: context.l10n.collectionPlayLevelVideo,
                      icon: const Icon(Icons.play_circle_outline),
                      color: scheme.onSurfaceVariant,
                      onPressed: () =>
                          unawaited(openSkinVideo(context, videoUrl: v)),
                    )
                  else
                    const SizedBox(width: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BuddyThumb extends StatelessWidget {
  const _BuddyThumb({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(ValRadius.small),
      ),
      padding: const EdgeInsets.all(6),
      child: image == null
          ? Icon(Icons.add, color: scheme.onSurfaceVariant)
          : NetImage(image, fit: BoxFit.contain),
    );
  }
}

class _CustomizeSkeleton extends StatelessWidget {
  const _CustomizeSkeleton();

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Skeleton(width: 120, shimmer: false),
          SizedBox(height: 12),
          Row(
            children: [
              Skeleton(width: 72, height: 72, radius: 14, shimmer: false),
              SizedBox(width: 10),
              Skeleton(width: 72, height: 72, radius: 14, shimmer: false),
              SizedBox(width: 10),
              Skeleton(width: 72, height: 72, radius: 14, shimmer: false),
            ],
          ),
          SizedBox(height: 24),
          Skeleton(width: 120, shimmer: false),
          SizedBox(height: 12),
          Skeleton(height: 168, radius: ValRadius.card, shimmer: false),
          SizedBox(height: 24),
          Skeleton(width: 120, shimmer: false),
          SizedBox(height: 12),
          Skeleton(height: 64, radius: ValRadius.card, shimmer: false),
        ],
      ),
    ),
  );
}
