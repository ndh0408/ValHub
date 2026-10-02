import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../data/buddy_options.dart';
import '../data/collection_search.dart';
import '../data/loadout_view.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/loadout_actions.dart';

import 'package:valvn/core/l10n/l10n.dart';

const _buddyMaxExtent = 120.0;
const _buddyArtHeight = 64.0;

/// Opens S36 "Chọn phụ kiện súng" for [weaponId].
Future<void> showBuddyPickerSheet(
  BuildContext context, {
  required String weaponId,
}) {
  final id = weaponId.trim().toLowerCase();
  final weapon = ProviderScope.containerOf(
    context,
    listen: false,
  ).read(contentProvider).value?.weapon(id);
  return showValSheet<void>(
    context,
    title: context.l10n.collectionBuddyPickerTitle,
    subtitle: weapon == null
        ? null
        : context.l10n.collectionBuddyFor(weapon.displayName),
    scrollable: true,
    initialSize: 0.85,
    minSize: 0.5,
    builder: (context, controller) =>
        BuddyPickerSheet(weaponId: weaponId, controller: controller),
  );
}

/// S36 body: search, the buddy on this gun with "Gỡ phụ kiện", then the
/// owned buddies with their free copies ("Còn 2/3"). Taking the last copy
/// from another gun asks first.
class BuddyPickerSheet extends ConsumerStatefulWidget {
  const BuddyPickerSheet({super.key, required this.weaponId, this.controller});

  final String weaponId;

  /// Scroll controller of the draggable sheet.
  final ScrollController? controller;

  @override
  ConsumerState<BuddyPickerSheet> createState() => _BuddyPickerSheetState();
}

class _BuddyPickerSheetState extends ConsumerState<BuddyPickerSheet> {
  String _search = '';

  String get _weaponId => widget.weaponId.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CollectionAccountGate(
      builder: (context, account) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CollectionSearchField(
            hint: context.l10n.collectionSearchBuddies,
            initialValue: _search,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            onChanged: (v) => setState(() => _search = v),
          ),
          Expanded(
            child: CustomScrollView(
              controller: widget.controller,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              slivers: loadoutSlivers(
                ref,
                puuid: account.puuid,
                loading: SkeletonTileGrid(
                  maxExtent: _buddyMaxExtent,
                  tileHeight: tileExtent(
                    context,
                    image: _buddyArtHeight,
                    footer: true,
                  ),
                ),
                data: (snapshot, owned, db) {
                  final gun = snapshot.loadout.gun(_weaponId);
                  final current = equippedBuddy(gun, db);
                  final all = buddyOptions(owned, db, snapshot.loadout);
                  final options = [
                    for (final o in all)
                      if (matchesSearch(_search, [o.buddy.displayName])) o,
                  ];
                  final searching = _search.trim().isNotEmpty;
                  return [
                    SliverToBoxAdapter(
                      child: SavingBar(visible: snapshot.isPending),
                    ),
                    if (gun?.hasBuddy ?? false)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GroupedSection(
                            children: [
                              HubRow(
                                icon: Icons.link,
                                leading: _Thumb(image: current?.image),
                                title:
                                    current?.displayName ??
                                    context.l10n.commonUnknownItem,
                                trailing: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: theme.colorScheme.error,
                                  ),
                                  onPressed: snapshot.isPending
                                      ? null
                                      : () => unawaited(
                                          _remove(context, account.puuid),
                                        ),
                                  icon: const Icon(Icons.link_off, size: 18),
                                  label: Text(
                                    context.l10n.collectionRemoveBuddy,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    if (options.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: EmptyView(
                          title: searching
                              ? context.l10n.collectionNoResultsTitle
                              : null,
                          message: searching
                              ? context.l10n.collectionNoResults
                              : context.l10n.collectionNoBuddies,
                          icon: searching
                              ? Icons.search_off
                              : Icons.key_off_outlined,
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        sliver: SliverGrid.builder(
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: _buddyMaxExtent,
                                mainAxisSpacing: 10,
                                crossAxisSpacing: 10,
                                mainAxisExtent: tileExtent(
                                  context,
                                  image: _buddyArtHeight,
                                  footer: true,
                                ),
                              ),
                          itemCount: options.length,
                          itemBuilder: (context, i) {
                            final o = options[i];
                            final on = o.isOn(_weaponId);
                            final available = context.l10n
                                .collectionBuddyAvailable(o.free, o.total);
                            return ArtTile(
                              key: ValueKey(o.buddy.uuid),
                              image: o.buddy.image,
                              label: o.buddy.displayName,
                              selected: on,
                              dimmed: !o.canEquip,
                              semanticsLabel:
                                  '${o.buddy.displayName}, $available',
                              footer: Text(
                                available,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: o.free > 0
                                      ? valColorsOf(context).win
                                      : theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              onTap: on || snapshot.isPending
                                  ? null
                                  : () => unawaited(
                                      _equip(context, account.puuid, o, db),
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
      ),
    );
  }

  Future<void> _remove(BuildContext context, String puuid) async {
    final l10nBeforeAwait = context.l10n;

    final navigator = Navigator.of(context);
    final ok = await applyLoadoutChange(
      context,
      ref,
      puuid: puuid,
      change: RemoveBuddy(weaponId: _weaponId),
      successMessage: l10nBeforeAwait.collectionBuddyRemoved,
    );
    if (ok) Haptics.light();
    if (ok && navigator.mounted) navigator.pop();
  }

  Future<void> _equip(
    BuildContext context,
    String puuid,
    BuddyOption option,
    ContentDb db,
  ) async {
    final l10nBeforeAwait2 = context.l10n;

    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final copy = option.copyFor(_weaponId);
    if (copy == null) {
      showCollectionSnack(messenger, context.l10n.collectionBuddyUnavailable);
      return;
    }
    Haptics.selection();
    final from = copy.equippedOn;
    if (from != null && from != _weaponId) {
      final confirmed = await showConfirmDialog(
        context,
        title: l10nBeforeAwait2.collectionMoveBuddyTitle,
        message: l10nBeforeAwait2.collectionMoveBuddyBody(
          option.buddy.displayName,
          db.weapon(from)?.displayName ?? l10nBeforeAwait2.commonUnknownItem,
          db.weapon(_weaponId)?.displayName ??
              l10nBeforeAwait2.commonUnknownItem,
        ),
        confirmLabel: l10nBeforeAwait2.collectionMove,
        icon: Icons.swap_horiz,
      );
      if (!confirmed || !context.mounted) return;
    }
    final ok = await applyLoadoutChange(
      context,
      ref,
      puuid: puuid,
      change: option.equipOn(_weaponId, copy),
      successMessage: l10nBeforeAwait2.collectionEquippedItem(
        option.buddy.displayName,
      ),
    );
    if (ok) Haptics.medium();
    if (ok && navigator.mounted) navigator.pop();
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.image});

  final String? image;

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(ValRadius.small),
    ),
    child: NetImage(image, fit: BoxFit.contain),
  );
}
