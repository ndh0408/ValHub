import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/filter_bar.dart';
import '../../data/skin_query.dart';
import '../../wishlist_strings.dart';
import 'weapon_picker_sheet.dart';

/// Pill search field + one horizontally scrolling row of chips: sort
/// button (adaptive action sheet), optional weapon picker, the edition
/// (content tier) multi-filter with rarity-colored dots, and "Bỏ lọc" while
/// a filter is active (VF §6.4 S39 / S3A / S3B). Scrolls sideways instead
/// of wrapping so it never overflows on 360 dp phones.
class SkinFilterBar extends StatefulWidget {
  const SkinFilterBar({
    super.key,
    required this.query,
    required this.onChanged,
    required this.tiers,
    this.weapons,
  });

  final SkinQuery query;
  final ValueChanged<SkinQuery> onChanged;
  final List<ContentTier> tiers;

  /// Weapons for the weapon filter; `null` hides it.
  final List<Weapon>? weapons;

  @override
  State<SkinFilterBar> createState() => _SkinFilterBarState();
}

class _SkinFilterBarState extends State<SkinFilterBar> {
  late final TextEditingController _search = TextEditingController(
    text: widget.query.text,
  );

  @override
  void didUpdateWidget(SkinFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // "Xóa bộ lọc" resets the query from outside.
    if (widget.query.text != _search.text) _search.text = widget.query.text;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _pickWeapon() async {
    final weapons = widget.weapons;
    if (weapons == null) return;
    final picked = await showWeaponPickerSheet(
      context,
      weapons: weapons,
      selected: widget.query.weaponUuid,
    );
    if (picked == null || !mounted) return;
    widget.onChanged(
      picked.weaponUuid == null
          ? widget.query.copyWith(clearWeapon: true)
          : widget.query.copyWith(weaponUuid: picked.weaponUuid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = widget.query;
    final weapons = widget.weapons;
    String? weaponName;
    if (weapons != null && query.weaponUuid != null) {
      for (final w in weapons) {
        if (w.uuid == query.weaponUuid) weaponName = w.displayName;
      }
    }
    final filtersOn = query.tiers.isNotEmpty || query.weaponUuid != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
          child: GlassSearchField(
            controller: _search,
            hintText: WishlistStrings.searchHint,
            onChanged: (t) => widget.onChanged(query.copyWith(text: t)),
          ),
        ),
        FilterChipBar(
          onClear: filtersOn
              ? () => widget.onChanged(
                  query.copyWith(tiers: const {}, clearWeapon: true),
                )
              : null,
          children: [
            SortButton<SkinSort>(
              options: [
                for (final s in SkinSort.values) (value: s, label: s.label),
              ],
              selected: query.sort,
              onSelected: (s) => widget.onChanged(query.copyWith(sort: s)),
            ),
            if (weapons != null)
              ValFilterChip(
                icon: Icons.filter_alt_outlined,
                label: weaponName ?? WishlistStrings.allWeapons,
                selected: weaponName != null,
                onSelected: (_) => unawaited(_pickWeapon()),
              ),
            for (final tier in widget.tiers)
              ValFilterChip(
                label: tier.shortName,
                dotColor: opaqueRgba(tier.highlightColor),
                selected: query.tiers.contains(tier.uuid),
                onSelected: (_) =>
                    widget.onChanged(query.toggleTier(tier.uuid)),
              ),
          ],
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}
