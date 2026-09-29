import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/sub_page.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../wishlist_strings.dart';

/// Result of [showWeaponPickerSheet]: `weaponUuid == null` = "Tất cả vũ khí".
typedef WeaponChoice = ({String? weaponUuid});

/// Weapon filter sheet grouped by category (Súng lục … Cận chiến), in the
/// shared sheet chrome (title + close button). Returns `null` when
/// dismissed.
Future<WeaponChoice?> showWeaponPickerSheet(
  BuildContext context, {
  required List<Weapon> weapons,
  String? selected,
}) => showValSheet<WeaponChoice>(
  context,
  title: WishlistStrings.chooseWeapon,
  scrollable: true,
  builder: (context, controller) => WeaponPickerList(
    weapons: weapons,
    selected: selected,
    controller: controller,
    onPicked: (uuid) {
      Haptics.selection();
      Navigator.of(context).pop((weaponUuid: uuid));
    },
  ),
);

/// Body of the weapon picker: "Tất cả vũ khí", then one grouped card per
/// weapon category with the weapon silhouette, name and a check mark.
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
    final accent = legibleAccent(context, theme.colorScheme.primary);
    final byCategory = <WeaponCategory, List<Weapon>>{};
    for (final w in weapons) {
      (byCategory[w.category] ??= []).add(w);
    }
    final categories = [
      for (final c in WeaponCategory.values)
        if (byCategory[c] != null) c,
    ];
    Widget check(bool on) => on
        ? Icon(Icons.check_circle, color: accent)
        : const SizedBox(width: 24);

    ListTile tile({
      required bool picked,
      required Widget leading,
      required String title,
      required VoidCallback onTap,
    }) => ListTile(
      selected: picked,
      selectedColor: accent,
      leading: leading,
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontWeight: picked ? FontWeight.w700 : null),
      ),
      trailing: check(picked),
      onTap: onTap,
    );

    return ListView(
      controller: controller,
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        GroupedSection(
          children: [
            tile(
              picked: selected == null,
              leading: const Icon(Icons.apps),
              title: WishlistStrings.allWeapons,
              onTap: () => onPicked(null),
            ),
          ],
        ),
        for (final c in categories) ...[
          SectionLabel(c.label.isEmpty ? WishlistStrings.weapon : c.label),
          GroupedSection(
            children: [
              for (final w in byCategory[c]!)
                tile(
                  picked: selected == w.uuid,
                  leading: SizedBox(
                    width: 64,
                    height: 28,
                    child: NetImage(
                      w.displayIcon,
                      fit: BoxFit.contain,
                      showSkeleton: false,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  title: w.displayName,
                  onTap: () => onPicked(w.uuid),
                ),
            ],
          ),
        ],
      ],
    );
  }
}
