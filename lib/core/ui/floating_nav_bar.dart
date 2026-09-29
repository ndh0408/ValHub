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
/// share the width equally.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
  });

  final List<NavigationDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

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
  });

  final NavigationDestination destination;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final accent = legibleAccent(context, scheme.primary, min: 3);
    final fg = selected ? accent : scheme.onSurfaceVariant;
    final icon = selected
        ? (destination.selectedIcon ?? destination.icon)
        : destination.icon;
    return Semantics(
      container: true,
      button: true,
      selected: selected,
      label: destination.label,
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
              IconTheme.merge(
                data: IconThemeData(color: fg, size: 22),
                child: icon,
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: fg,
                  fontSize: 10.5,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
