import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/section_header.dart';
import '../../wishlist_strings.dart';

/// Result of [showWeaponPickerSheet]: `weaponUuid == null` = "Tất cả vũ khí".
typedef WeaponChoice = ({String? weaponUuid});

/// Weapon filter sheet grouped by category (Súng phụ … Cận chiến). Returns
/// `null` when dismissed.
Future<WeaponChoice?> showWeaponPickerSheet(
  BuildContext context, {
  required List<Weapon> weapons,
  String? selected,
}) => showModalBottomSheet<WeaponChoice>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => DraggableScrollableSheet(
    expand: false,
    initialChildSize: 0.7,
    minChildSize: 0.4,
    maxChildSize: 0.95,
    builder: (context, controller) => WeaponPickerList(
      weapons: weapons,
      selected: selected,
      controller: controller,
      onPicked: (uuid) => Navigator.of(context).pop((weaponUuid: uuid)),
    ),
  ),
);

/// Body of the weapon picker.
class WeaponPickerList extends StatelessWidget {
  const WeaponPickerList({
    super.key,
    required this.weapons,
    required this.selected,
    required this.onPicked,
    this.controller,
  });

  final List<Weapon> weapons;
  final String? selected;
  final ValueChanged<String?> onPicked;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final byCategory = <WeaponCategory, List<Weapon>>{};
    for (final w in weapons) {
      (byCategory[w.category] ??= []).add(w);
    }
    final categories = [
      for (final c in WeaponCategory.values)
        if (byCategory[c] != null) c,
    ];
    Widget check(bool on) => on
        ? Icon(Icons.check, color: theme.colorScheme.primary)
        : const SizedBox(width: 24);

    return ListView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Text(
            WishlistStrings.chooseWeapon,
            style: theme.textTheme.titleLarge,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.apps),
          title: const Text(WishlistStrings.allWeapons),
          trailing: check(selected == null),
          onTap: () => onPicked(null),
        ),
        for (final c in categories) ...[
          SectionHeader(c.label.isEmpty ? WishlistStrings.weapon : c.label),
          for (final w in byCategory[c]!)
            ListTile(
              leading: SizedBox(
                width: 64,
                height: 28,
                child: NetImage(
                  w.displayIcon,
                  fit: BoxFit.contain,
                  showSkeleton: false,
                ),
              ),
              title: Text(
                w.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: check(selected == w.uuid),
              onTap: () => onPicked(w.uuid),
            ),
        ],
      ],
    );
  }
}
