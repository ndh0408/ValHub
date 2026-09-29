import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../core/content/content_db.dart';
import '../../../../core/theme/tier_colors.dart';
import '../../../../core/ui/net_image.dart';
import '../../data/skin_query.dart';
import '../../wishlist_strings.dart';
import 'weapon_picker_sheet.dart';

/// Search field + one horizontally scrolling row of chips: sort menu,
/// optional weapon picker, and the edition (content tier) filters
/// (VF §6.4 S39 / S3A / S3B). Scrolls sideways instead of wrapping so it
/// never overflows on 360 dp phones.
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: TextField(
            controller: _search,
            onChanged: (t) => widget.onChanged(query.copyWith(text: t)),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: WishlistStrings.searchHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              suffixIcon: query.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: WishlistStrings.clearSearch,
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        _search.clear();
                        widget.onChanged(query.copyWith(text: ''));
                      },
                    ),
            ),
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _SortMenu(
                sort: query.sort,
                onSelected: (s) => widget.onChanged(query.copyWith(sort: s)),
              ),
              if (weapons != null) ...[
                const SizedBox(width: 8),
                _ChipButton(
                  icon: Icons.filter_alt_outlined,
                  label: weaponName ?? WishlistStrings.allWeapons,
                  selected: weaponName != null,
                  onTap: () => unawaited(_pickWeapon()),
                ),
              ],
              for (final tier in widget.tiers) ...[
                const SizedBox(width: 8),
                _TierChip(
                  tier: tier,
                  selected: query.tiers.contains(tier.uuid),
                  onTap: () => widget.onChanged(query.toggleTier(tier.uuid)),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.sort, required this.onSelected});

  final SkinSort sort;
  final ValueChanged<SkinSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SkinSort>(
      tooltip: WishlistStrings.sortBy,
      initialValue: sort,
      onSelected: onSelected,
      itemBuilder: (_) => [
        for (final s in SkinSort.values)
          CheckedPopupMenuItem<SkinSort>(
            value: s,
            checked: s == sort,
            child: Text(s.label),
          ),
      ],
      child: _ChipFace(
        icon: Icons.sort,
        label: WishlistStrings.sortLabel(sort.label),
        selected: false,
      ),
    );
  }
}

class _ChipButton extends StatelessWidget {
  const _ChipButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: _ChipFace(icon: icon, label: label, selected: selected),
      ),
    );
  }
}

class _TierChip extends StatelessWidget {
  const _TierChip({
    required this.tier,
    required this.selected,
    required this.onTap,
  });

  final ContentTier tier;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = opaqueRgba(tier.highlightColor);
    return Semantics(
      button: true,
      selected: selected,
      label: tier.displayName,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: _ChipFace(
          leading: NetImage(
            tier.displayIcon,
            width: 16,
            height: 16,
            showSkeleton: false,
          ),
          label: tier.shortName,
          selected: selected,
          accent: color,
        ),
      ),
    );
  }
}

/// The look shared by every chip in the bar.
class _ChipFace extends StatelessWidget {
  const _ChipFace({
    this.icon,
    this.leading,
    required this.label,
    required this.selected,
    this.accent,
  });

  final IconData? icon;
  final Widget? leading;
  final String label;
  final bool selected;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = this.accent ?? scheme.primary;
    final fg = selected ? accent : scheme.onSurface;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: selected
            ? accent.withValues(alpha: 0.16)
            : scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: selected ? accent : scheme.outlineVariant,
          width: selected ? 1.4 : 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          if (icon != null) ...[
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            maxLines: 1,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: fg,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
