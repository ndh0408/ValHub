import 'dart:ui' show ImageFilter;

import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import 'adaptive.dart';

/// Floating translucent capsule tab bar (ValBuddy-style): detached from the
/// bottom edge, frosted, icons with small labels, the active item in a
/// red-tinted pill with red icon + label.
///
/// Takes the same [NavigationDestination]s as a Material [NavigationBar]
/// (icon / selectedIcon / label), so any number of tabs (5–6) works; items
/// share the width equally. Labels shrink to fit instead of ellipsizing.
/// One item can be [emphasizedIndex]ed (the middle "Cộng đồng" tab): its
/// icon sits in a filled circle.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.compact = false,
    this.emphasizedIndex,
  });

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Narrow screens with many tabs: unselected items show only their icon
  /// (label kept for semantics / tooltips), the selected one icon + label.
  final bool compact;

  /// Destination whose icon is drawn in a 32 dp circle: tinted red with a
  /// red icon when unselected, solid red with a white icon when selected.
  final int? emphasizedIndex;

  static const _barHeight = 64.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dark = theme.brightness == Brightness.dark;
    final navBg =
        theme.navigationBarTheme.backgroundColor ??
        theme.colorScheme.surfaceContainer;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return ColoredBox(
      color: theme.scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          12,
          6,
          12,
          bottomInset > 0 ? bottomInset : 10,
        ),
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.15,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ValRadius.pill),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: dark ? 0.5 : 0.10),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ValRadius.pill),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: _barHeight,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: navBg.withValues(alpha: dark ? 0.86 : 0.92),
                    borderRadius: BorderRadius.circular(ValRadius.pill),
                    border: Border.all(color: valColorsOf(context).hairline),
                  ),
                  child: Row(
                    children: [
                      for (var i = 0; i < destinations.length; i++)
                        Expanded(
                          child: _NavItem(
                            destination: destinations[i],
                            selected: i == selectedIndex,
                            emphasized: i == emphasizedIndex,
                            showLabel: !compact || i == selectedIndex,
                            onTap: () {
                              if (i != selectedIndex) Haptics.selection();
                              onDestinationSelected(i);
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.destination,
    required this.selected,
    required this.onTap,
    this.showLabel = true,
    this.emphasized = false,
  });

  final NavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;
  final bool showLabel;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = legibleAccent(context, scheme.primary, min: 4.0);
    final fg = selected ? accent : scheme.onSurfaceVariant;
    final icon = selected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: destination.label,
      onTap: onTap,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const StadiumBorder(),
        child: AnimatedContainer(
          duration: ValMotion.medium,
          curve: ValMotion.curve,
          decoration: BoxDecoration(
            color: selected
                ? scheme.primary.withValues(alpha: 0.16)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(ValRadius.pill),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (emphasized)
                _EmphasizedIcon(selected: selected, accent: accent, child: icon)
              else
                IconTheme.merge(
                  data: IconThemeData(color: fg, size: showLabel ? 22 : 24),
                  child: icon,
                ),
              if (showLabel) ...[
                const SizedBox(height: 2),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: fg,
                        fontSize: 10.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// The icon of the emphasized destination inside a 32 dp circle. Unselected:
/// primary at 16 % with a primary icon; selected: solid primary with an
/// `onPrimary` icon (≥ 3:1, a graphic object).
class _EmphasizedIcon extends StatelessWidget {
  const _EmphasizedIcon({
    required this.selected,
    required this.accent,
    required this.child,
  });

  final bool selected;
  final Color accent;
  final Widget child;

  static const size = 32.0;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AnimatedContainer(
      duration: ValMotion.medium,
      curve: ValMotion.curve,
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected
            ? scheme.primary
            : scheme.primary.withValues(alpha: 0.16),
      ),
      child: IconTheme.merge(
        data: IconThemeData(
          color: selected ? scheme.onPrimary : accent,
          size: 20,
        ),
        child: child,
      ),
    );
  }
}
