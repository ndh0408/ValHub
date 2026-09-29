import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/riot/riot_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/segmented_tabs.dart';
import '../../../core/ui/skeleton.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.expressionsTitle)),
      body: CollectionAccountGate(
        builder: (context, account) => LoadoutDataBuilder(
          puuid: account.puuid,
          loading: const _WheelSkeleton(),
          builder: (context, snapshot, owned, db) {
            final loadout = snapshot.loadout;
            void open(int slot) => unawaited(
              showExpressionPicker(context, puuid: account.puuid, slot: slot),
            );
            return RefreshIndicator(
              onRefresh: () => refreshCollection(ref, account.puuid),
              child: ListView(
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  SavingBar(visible: snapshot.isPending),
                  if (snapshot.isFromCache) const CachedLoadoutBanner(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Text(
                      CollectionStrings.expressionsHint,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  LayoutBuilder(
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
                  const SizedBox(height: 8),
                  for (var i = 0; i < kExpressionSlots; i++)
                    _SlotRow(
                      slot: i,
                      view: _slotView(loadout.expression(i), db),
                      onTap: snapshot.isPending ? null : () => open(i),
                    ),
                ],
              ),
            );
          },
        ),
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
                  border: Border.all(color: scheme.outlineVariant, width: 2),
                  gradient: RadialGradient(
                    colors: [
                      ValColors.red.withValues(alpha: 0.12),
                      Colors.transparent,
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
                    borderRadius: BorderRadius.circular(6),
                    side: BorderSide(color: scheme.outlineVariant),
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
    return ListTile(
      onTap: onTap,
      leading: SizedBox(
        width: 40,
        height: 40,
        child: view.isEmpty
            ? Icon(Icons.crop_square, color: theme.colorScheme.onSurfaceVariant)
            : NetImage(view.image, fit: BoxFit.contain),
      ),
      title: Text(CollectionStrings.slotTitle(slot)),
      subtitle: Text(view.name, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: const Icon(Icons.chevron_right),
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

/// Picker of one wheel slot (tabs "Hình phun sơn | Flex", search).
Future<void> showExpressionPicker(
  BuildContext context, {
  required String puuid,
  required int slot,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => ExpressionPickerSheet(puuid: puuid, slot: slot),
);

class ExpressionPickerSheet extends ConsumerStatefulWidget {
  const ExpressionPickerSheet({
    super.key,
    required this.puuid,
    required this.slot,
  });

  final String puuid;
  final int slot;

  @override
  ConsumerState<ExpressionPickerSheet> createState() =>
      _ExpressionPickerSheetState();
}

class _ExpressionPickerSheetState extends ConsumerState<ExpressionPickerSheet> {
  _PickerTab? _tab;
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scroll) => LoadoutDataBuilder(
        puuid: widget.puuid,
        loading: const CollectionGridSkeleton(),
        builder: (context, snapshot, owned, db) {
          final current = snapshot.loadout.expression(widget.slot);
          final tab =
              _tab ??
              (current?.isFlex ?? false ? _PickerTab.flex : _PickerTab.sprays);
          final items = <({String id, String? image, String name, bool flex})>[
            if (tab == _PickerTab.sprays) ...[
              if (matchesSearch(_search, [CollectionStrings.emptySlot]))
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

          Future<void> pick(String id, String name, bool flex) async {
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
            if (ok && navigator.mounted) navigator.pop();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  CollectionStrings.slotTitle(widget.slot),
                  style: theme.textTheme.titleLarge,
                ),
              ),
              SegmentedTabs<_PickerTab>(
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
              CollectionSearchField(
                key: ValueKey(tab),
                hint: tab == _PickerTab.sprays
                    ? CollectionStrings.searchSprays
                    : CollectionStrings.searchFlex,
                initialValue: _search,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                onChanged: (v) => setState(() => _search = v),
              ),
              SavingBar(visible: snapshot.isPending),
              Expanded(
                child: items.isEmpty
                    ? ListView(
                        controller: scroll,
                        children: [
                          EmptyView(
                            message: _search.trim().isNotEmpty
                                ? CollectionStrings.noResults
                                : (tab == _PickerTab.flex
                                      ? CollectionStrings.noFlex
                                      : CollectionStrings.noSprays),
                          ),
                        ],
                      )
                    : GridView.builder(
                        controller: scroll,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 120,
                          mainAxisSpacing: 10,
                          crossAxisSpacing: 10,
                          mainAxisExtent: tileExtent(context, image: 72),
                        ),
                        itemCount: items.length,
                        itemBuilder: (context, i) {
                          final item = items[i];
                          final selected = isCurrent(item.id, item.flex);
                          return ArtTile(
                            image: item.image,
                            icon: Icons.block,
                            label: item.name,
                            selected: selected,
                            onTap: selected || snapshot.isPending
                                ? null
                                : () => unawaited(
                                    pick(item.id, item.name, item.flex),
                                  ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
