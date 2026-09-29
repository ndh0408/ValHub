import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/riot/riot_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/segmented_tabs.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../collection_strings.dart';
import '../data/collection_items.dart';
import '../data/collection_search.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/loadout_actions.dart';

/// What a wheel slot shows.
typedef _SlotView = ({String? image, String name, bool isEmpty});

_SlotView _slotView(Expression? e, ContentDb db) {
  if (e == null || e.isEmpty) {
    return (image: null, name: CollectionStrings.emptySlot, isEmpty: true);
  }
  return switch (e.type) {
    ExpressionType.flex => (
      image: db.flex(e.assetId)?.displayIcon,
      name: db.flex(e.assetId)?.displayName ?? CommonStrings.unknownItem,
      isEmpty: false,
    ),
    _ => (
      image: db.spray(e.assetId)?.image,
      name: db.spray(e.assetId)?.displayName ?? CommonStrings.unknownItem,
      isEmpty: false,
    ),
  };
}

/// S37 "Tổ hợp cảm xúc": wheel of 4 slots (top / right / bottom / left);
/// tap a slot → picker (Hình phun sơn | Flex). Route
/// `/collection/expressions`.
class ExpressionsScreen extends ConsumerWidget {
  const ExpressionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return const NoAccountPage(title: CollectionStrings.expressionsTitle);
    }
    final puuid = account.puuid;
    return SubPageScaffold(
      title: CollectionStrings.expressionsTitle,
      subtitle: CollectionStrings.expressionsHint,
      onRefresh: () => refreshCollection(ref, puuid),
      slivers: loadoutSlivers(
        ref,
        puuid: puuid,
        loading: const _WheelSkeleton(),
        data: (snapshot, owned, db) {
          final loadout = snapshot.loadout;
          void open(int slot) => unawaited(
            showExpressionPicker(context, puuid: puuid, slot: slot),
          );
          return [
            SliverToBoxAdapter(child: SavingBar(visible: snapshot.isPending)),
            if (snapshot.isFromCache)
              const SliverToBoxAdapter(child: CachedLoadoutBanner()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: LayoutBuilder(
                  builder: (context, c) => Center(
                    child: _Wheel(
                      size: math.min(c.maxWidth - 32, 320),
                      slots: [
                        for (var i = 0; i < kExpressionSlots; i++)
                          _slotView(loadout.expression(i), db),
                      ],
                      onTap: snapshot.isPending ? null : open,
                    ),
                  ),
                ),
              ),
            ),
            const SliverToBoxAdapter(
              child: SectionLabel(CollectionStrings.expressionsSlots),
            ),
            SliverToBoxAdapter(
              child: GroupedSection(
                children: [
                  for (var i = 0; i < kExpressionSlots; i++)
                    _SlotRow(
                      slot: i,
                      view: _slotView(loadout.expression(i), db),
                      onTap: snapshot.isPending ? null : () => open(i),
                    ),
                ],
              ),
            ),
          ];
        },
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({required this.size, required this.slots, required this.onTap});

  final double size;
  final List<_SlotView> slots;
  final void Function(int slot)? onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = scheme.primary;
    final tile = size * 0.3;
    // Top, right, bottom, left (slot = index, U7).
    final offsets = [
      Offset((size - tile) / 2, 0),
      Offset(size - tile, (size - tile) / 2),
      Offset((size - tile) / 2, size - tile),
      Offset(0, (size - tile) / 2),
    ];
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(tile / 2),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: accent.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.16),
                      accent.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Center(
            child: Icon(
              Icons.emoji_emotions_outlined,
              size: size * 0.14,
              color: scheme.onSurfaceVariant,
            ),
          ),
          for (var i = 0; i < slots.length && i < offsets.length; i++)
            Positioned(
              left: offsets[i].dx,
              top: offsets[i].dy,
              width: tile,
              height: tile,
              child: Semantics(
                button: true,
                label: '${CollectionStrings.slotTitle(i)}: ${slots[i].name}',
                excludeSemantics: true,
                child: Material(
                  color: scheme.surfaceContainerHigh,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ValRadius.small),
                    side: BorderSide(
                      color: slots[i].isEmpty
                          ? scheme.outlineVariant
                          : accent.withValues(alpha: 0.6),
                      width: slots[i].isEmpty ? 1 : 1.5,
                    ),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: onTap == null ? null : () => onTap!(i),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: slots[i].isEmpty
                          ? Icon(
                              Icons.add,
                              color: scheme.onSurfaceVariant,
                              size: tile * 0.35,
                            )
                          : NetImage(slots[i].image, fit: BoxFit.contain),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SlotRow extends StatelessWidget {
  const _SlotRow({required this.slot, required this.view, this.onTap});

  final int slot;
  final _SlotView view;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return ListTile(
      onTap: onTap,
      minTileHeight: 60,
      leading: SizedBox(
        width: 40,
        height: 40,
        child: view.isEmpty
            ? Icon(Icons.add_box_outlined, color: muted)
            : NetImage(view.image, fit: BoxFit.contain),
      ),
      title: Text(
        CollectionStrings.slotTitle(slot),
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        view.name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: muted),
      ),
      trailing: Icon(Icons.chevron_right, color: muted, size: 20),
    );
  }
}

class _WheelSkeleton extends StatelessWidget {
  const _WheelSkeleton();

  @override
  Widget build(BuildContext context) => const SkeletonShimmer(
    child: Padding(
      padding: EdgeInsets.all(32),
      child: Column(
        children: [
          SizedBox(
            width: 240,
            height: 240,
            child: Skeleton(shimmer: false, radius: 120),
          ),
          SizedBox(height: 24),
          Skeleton(height: 48, shimmer: false),
          SizedBox(height: 8),
          Skeleton(height: 48, shimmer: false),
        ],
      ),
    ),
  );
}

// ------------------------------------------------------------------ picker

enum _PickerTab { sprays, flex }

/// Picker of one wheel slot (tabs "Hình phun sơn | Flex", search) in the
/// shared sheet chrome.
Future<void> showExpressionPicker(
  BuildContext context, {
  required String puuid,
  required int slot,
}) => showValSheet<void>(
  context,
  title: CollectionStrings.slotTitle(slot),
  subtitle: CollectionStrings.expressionsTitle,
  scrollable: true,
  initialSize: 0.85,
  minSize: 0.5,
  builder: (context, controller) =>
      ExpressionPickerSheet(puuid: puuid, slot: slot, controller: controller),
);

class ExpressionPickerSheet extends ConsumerStatefulWidget {
  const ExpressionPickerSheet({
    super.key,
    required this.puuid,
    required this.slot,
    this.controller,
  });

  final String puuid;
  final int slot;

  /// Scroll controller of the draggable sheet.
  final ScrollController? controller;

  @override
  ConsumerState<ExpressionPickerSheet> createState() =>
      _ExpressionPickerSheetState();
}

class _ExpressionPickerSheetState extends ConsumerState<ExpressionPickerSheet> {
  static const _artHeight = 72.0;
  _PickerTab? _tab;
  String _search = '';

  Future<void> _pick(String id, String name, bool flex) async {
    final navigator = Navigator.of(context);
    final ok = await applyLoadoutChange(
      context,
      ref,
      puuid: widget.puuid,
      change: flex
          ? SetExpression.flex(widget.slot, id)
          : SetExpression.spray(widget.slot, id),
      successMessage: CollectionStrings.equippedItem(name),
    );
    if (ok) Haptics.medium();
    if (ok && navigator.mounted) navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = ref.watch(loadoutProvider(widget.puuid)).value;
    final current = snapshot?.loadout.expression(widget.slot);
    final tab =
        _tab ??
        (current?.isFlex ?? false ? _PickerTab.flex : _PickerTab.sprays);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SegmentedTabs<_PickerTab>(
            expand: true,
            tabs: const [
              SegmentedTab(
                value: _PickerTab.sprays,
                label: CollectionStrings.tabSprays,
              ),
              SegmentedTab(
                value: _PickerTab.flex,
                label: CollectionStrings.tabFlex,
              ),
            ],
            selected: tab,
            onChanged: (t) => setState(() => _tab = t),
          ),
        ),
        CollectionSearchField(
          key: ValueKey(tab),
          hint: tab == _PickerTab.sprays
              ? CollectionStrings.searchSprays
              : CollectionStrings.searchFlex,
          initialValue: _search,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          onChanged: (v) => setState(() => _search = v),
        ),
        Expanded(
          child: CustomScrollView(
            controller: widget.controller,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            slivers: loadoutSlivers(
              ref,
              puuid: widget.puuid,
              loading: SkeletonTileGrid(
                maxExtent: 120,
                tileHeight: tileExtent(context, image: _artHeight),
              ),
              data: (snapshot, owned, db) {
                final current = snapshot.loadout.expression(widget.slot);
                final items =
                    <({String id, String? image, String name, bool flex})>[
                      if (tab == _PickerTab.sprays) ...[
                        if (matchesSearch(_search, [
                          CollectionStrings.emptySlot,
                        ]))
                          (
                            id: SpecialIds.nullSpray,
                            image: null,
                            name: CollectionStrings.emptySlot,
                            flex: false,
                          ),
                        for (final s in ownedSprays(owned, db))
                          if (matchesSearch(_search, [s.displayName]))
                            (
                              id: s.uuid,
                              image: s.image,
                              name: s.displayName,
                              flex: false,
                            ),
                      ] else
                        for (final f in ownedFlex(owned, db))
                          if (matchesSearch(_search, [f.displayName]))
                            (
                              id: f.uuid,
                              image: f.displayIcon,
                              name: f.displayName,
                              flex: true,
                            ),
                    ];
                bool isCurrent(String id, bool flex) =>
                    current != null &&
                    current.assetId == id &&
                    current.isFlex == flex;
                final searching = _search.trim().isNotEmpty;
                return [
                  SliverToBoxAdapter(
                    child: SavingBar(visible: snapshot.isPending),
                  ),
                  if (items.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        icon: searching
                            ? Icons.search_off
                            : Icons.format_paint_outlined,
                        title: searching
                            ? CollectionStrings.noResultsTitle
                            : null,
                        message: searching
                            ? CollectionStrings.noResults
                            : (tab == _PickerTab.flex
                                  ? CollectionStrings.noFlex
                                  : CollectionStrings.noSprays),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      sliver: SliverGrid.builder(
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 120,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: tileExtent(
                            context,
                            image: _artHeight,
                          ),
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item = items[i];
                          final selected = isCurrent(item.id, item.flex);
                          return ArtTile(
                            key: ValueKey(item.id),
                            image: item.image,
                            icon: Icons.block,
                            label: item.name,
                            selected: selected,
                            onTap: selected || snapshot.isPending
                                ? null
                                : () => unawaited(
                                    _pick(item.id, item.name, item.flex),
                                  ),
                          );
                        },
                      ),
                    ),
                ];
              },
            ),
          ),
        ),
      ],
    );
  }
}
