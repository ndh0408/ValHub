import 'dart:async';
import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/filter_bar.dart';
import '../../data/skin_query.dart';
import 'weapon_picker_sheet.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Height of the pinned [SkinSearchField] strip for the current text size
/// (the field grows with the accessibility text scale).
double skinSearchHeaderHeight(BuildContext context) {
  final scale = MediaQuery.textScalerOf(context).scale(1);
  return 12 + math.max(48, 24 * scale + 26);
}

/// Pill search field of the wishlist / catalog (accent-insensitive: "vo cuc"
/// finds "Vô Cực"), meant for the pinned header of a `SubPageScaffold`.
/// Keeps its text in sync when the query is cleared from outside.
class SkinSearchField extends StatefulWidget {
  const SkinSearchField({
    super.key,
    required this.query,
    required this.onChanged,
  });

  final SkinQuery query;
  final ValueChanged<SkinQuery> onChanged;

  @override
  State<SkinSearchField> createState() => _SkinSearchFieldState();
}

class _SkinSearchFieldState extends State<SkinSearchField> {
  late final TextEditingController _search = TextEditingController(
    text: widget.query.text,
  );

  @override
  void didUpdateWidget(SkinSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // "Xóa bộ lọc" resets the query from outside.
    if (widget.query.text != _search.text) _search.text = widget.query.text;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
    child: GlassSearchField(
      controller: _search,
      hintText: context.l10n.wishlistSearchHint,
      onChanged: (t) => widget.onChanged(widget.query.copyWith(text: t)),
    ),
  );
}

/// One horizontally scrolling row of chips: sort button (adaptive action
/// sheet), optional weapon picker, the edition (content tier) multi-filter
/// with rarity-colored dots, and "Bỏ lọc" while a filter is active (VF §6.4
/// S39 / S3A / S3B). Scrolls sideways instead of wrapping so it never
/// overflows on 360 dp phones.
class SkinFilterChips extends StatelessWidget {
  const SkinFilterChips({
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

  Future<void> _pickWeapon(BuildContext context) async {
    final weapons = this.weapons;
    if (weapons == null) return;
    final picked = await showWeaponPickerSheet(
      context,
      weapons: weapons,
      selected: query.weaponUuid,
    );
    if (picked == null || !context.mounted) return;
    onChanged(
      picked.weaponUuid == null
          ? query.copyWith(clearWeapon: true)
          : query.copyWith(weaponUuid: picked.weaponUuid),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weapons = this.weapons;
    String? weaponName;
    if (weapons != null && query.weaponUuid != null) {
      for (final w in weapons) {
        if (w.uuid == query.weaponUuid) weaponName = w.displayName;
      }
    }
    final filtersOn = query.tiers.isNotEmpty || query.weaponUuid != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: FilterChipBar(
        onClear: filtersOn
            ? () =>
                  onChanged(query.copyWith(tiers: const {}, clearWeapon: true))
            : null,
        children: [
          SortButton<SkinSort>(
            options: [
              for (final s in SkinSort.values) (value: s, label: s.label),
            ],
            selected: query.sort,
            onSelected: (s) => onChanged(query.copyWith(sort: s)),
          ),
          if (weapons != null)
            ValFilterChip(
              icon: Icons.filter_alt_outlined,
              label: weaponName ?? context.l10n.wishlistAllWeapons,
              selected: weaponName != null,
              onSelected: (_) => unawaited(_pickWeapon(context)),
            ),
          for (final tier in tiers)
            ValFilterChip(
              label: tier.shortName,
              dotColor: opaqueRgba(tier.highlightColor),
              selected: query.tiers.contains(tier.uuid),
              onSelected: (_) => onChanged(query.toggleTier(tier.uuid)),
            ),
        ],
      ),
    );
  }
}
