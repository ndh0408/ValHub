import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../collection_strings.dart';
import '../data/buddy_options.dart';
import '../data/collection_search.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/loadout_actions.dart';

/// Opens S36 "Chọn phụ kiện súng" for [weaponId].
Future<void> showBuddyPickerSheet(
  BuildContext context, {
  required String weaponId,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => BuddyPickerSheet(weaponId: weaponId),
);

/// S36 buddy grid with instance counts ("Còn 2/3") and "Gỡ phụ kiện".
class BuddyPickerSheet extends ConsumerStatefulWidget {
  const BuddyPickerSheet({super.key, required this.weaponId});

  final String weaponId;

  @override
  ConsumerState<BuddyPickerSheet> createState() => _BuddyPickerSheetState();
}

class _BuddyPickerSheetState extends ConsumerState<BuddyPickerSheet> {
  String _search = '';

  String get _weaponId => widget.weaponId.trim().toLowerCase();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final weapon = ref.watch(contentProvider).value?.weapon(_weaponId);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scroll) => CollectionAccountGate(
        builder: (context, account) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text(
                CollectionStrings.buddyPickerTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            if (weapon != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 2, 16, 0),
                child: Text(
                  CollectionStrings.buddyFor(weapon.displayName),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            CollectionSearchField(
              hint: CollectionStrings.searchBuddies,
              onChanged: (v) => setState(() => _search = v),
            ),
            Expanded(
              child: LoadoutDataBuilder(
                puuid: account.puuid,
                loading: const CollectionGridSkeleton(),
                builder: (context, snapshot, owned, db) {
                  final gun = snapshot.loadout.gun(_weaponId);
                  final options = [
                    for (final o in buddyOptions(owned, db, snapshot.loadout))
                      if (matchesSearch(_search, [o.buddy.displayName])) o,
                  ];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SavingBar(visible: snapshot.isPending),
                      if (gun?.hasBuddy ?? false)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: OutlinedButton.icon(
                            onPressed: snapshot.isPending
                                ? null
                                : () => unawaited(
                                    _remove(context, account.puuid),
                                  ),
                            icon: const Icon(Icons.link_off),
                            label: const Text(CollectionStrings.removeBuddy),
                          ),
                        ),
                      Expanded(
                        child: options.isEmpty
                            ? ListView(
                                controller: scroll,
                                children: [
                                  EmptyView(
                                    message: _search.trim().isEmpty
                                        ? CollectionStrings.noBuddies
                                        : CollectionStrings.noResults,
                                    icon: Icons.key_off_outlined,
                                  ),
                                ],
                              )
                            : GridView.builder(
                                controller: scroll,
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  4,
                                  16,
                                  24,
                                ),
                                gridDelegate:
                                    SliverGridDelegateWithMaxCrossAxisExtent(
                                      maxCrossAxisExtent: 120,
                                      mainAxisSpacing: 10,
                                      crossAxisSpacing: 10,
                                      mainAxisExtent: tileExtent(
                                        context,
                                        image: 64,
                                        footer: true,
                                      ),
                                    ),
                                itemCount: options.length,
                                itemBuilder: (context, i) {
                                  final o = options[i];
                                  final on = o.isOn(_weaponId);
                                  return ArtTile(
                                    image: o.buddy.image,
                                    label: o.buddy.displayName,
                                    selected: on,
                                    dimmed: !o.canEquip,
                                    semanticsLabel:
                                        '${o.buddy.displayName}, '
                                        '${CollectionStrings.buddyAvailable(o.free, o.total)}',
                                    footer: Text(
                                      CollectionStrings.buddyAvailable(
                                        o.free,
                                        o.total,
                                      ),
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: o.free > 0
                                                ? ValColors.teal
                                                : theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                          ),
                                    ),
                                    onTap: on || snapshot.isPending
                                        ? null
                                        : () => unawaited(
                                            _equip(
                                              context,
                                              account.puuid,
                                              o,
                                              db,
                                            ),
                                          ),
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _remove(BuildContext context, String puuid) async {
    final navigator = Navigator.of(context);
    final ok = await applyLoadoutChange(
      context,
      ref,
      puuid: puuid,
      change: RemoveBuddy(weaponId: _weaponId),
      successMessage: CollectionStrings.buddyRemoved,
    );
    if (ok && navigator.mounted) navigator.pop();
  }

  Future<void> _equip(
    BuildContext context,
    String puuid,
    BuddyOption option,
    ContentDb db,
  ) async {
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final copy = option.copyFor(_weaponId);
    if (copy == null) {
      showCollectionSnack(messenger, CollectionStrings.buddyUnavailable);
      return;
    }
    final from = copy.equippedOn;
    if (from != null && from != _weaponId) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(CollectionStrings.moveBuddyTitle),
          content: Text(
            CollectionStrings.moveBuddyBody(
              option.buddy.displayName,
              db.weapon(from)?.displayName ?? CommonStrings.unknownItem,
              db.weapon(_weaponId)?.displayName ?? CommonStrings.unknownItem,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(CommonStrings.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text(CollectionStrings.move),
            ),
          ],
        ),
      );
      if (confirmed != true || !context.mounted) return;
    }
    final ok = await applyLoadoutChange(
      context,
      ref,
      puuid: puuid,
      change: option.equipOn(_weaponId, copy),
      successMessage: CollectionStrings.equippedItem(option.buddy.displayName),
    );
    if (ok && navigator.mounted) navigator.pop();
  }
}
