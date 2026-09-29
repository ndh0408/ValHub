import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/l10n/common_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/live_game/live_game_overlay_host.dart';

/// Tab shell: the six tabs (the five ValBuddy tabs of VF §6 plus "Cộng đồng"
/// in the middle) and the live-game overlay hook.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.storefront_outlined),
      selectedIcon: Icon(Icons.storefront),
      label: CommonStrings.tabStore,
    ),
    NavigationDestination(
      icon: Icon(Icons.military_tech_outlined),
      selectedIcon: Icon(Icons.military_tech),
      label: CommonStrings.tabBattlePass,
    ),
    NavigationDestination(
      icon: Icon(Icons.forum_outlined),
      selectedIcon: Icon(Icons.forum),
      label: CommonStrings.tabCommunity,
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2),
      label: CommonStrings.tabCollection,
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outline),
      selectedIcon: Icon(Icons.person),
      label: CommonStrings.tabProfile,
    ),
    NavigationDestination(
      icon: Icon(Icons.settings_outlined),
      selectedIcon: Icon(Icons.settings),
      label: CommonStrings.tabSettings,
    ),
  ];

  /// Below this width six labels do not fit side by side: only the selected
  /// tab shows its label (the others keep their tooltip / semantics label).
  static const _compactWidth = 420.0;

  /// Horizontal room kept free around a label inside its destination.
  static const _labelPadding = 6.0;

  /// Label font size (≤ 12, ≥ 8) at which the widest label fits one
  /// destination slot of [slotWidth] on one line. Tab labels never wrap into
  /// the icon row, and like iOS tab bars they do not grow with the system
  /// text size (the bar has a fixed height).
  static double fittedLabelSize(
    double slotWidth,
    TextStyle style,
    Iterable<String> labels,
  ) {
    const base = 12.0;
    var widest = 0.0;
    for (final label in labels) {
      final painter = TextPainter(
        text: TextSpan(
          text: label,
          style: style.copyWith(fontSize: base, fontWeight: FontWeight.w700),
        ),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      if (painter.width > widest) widest = painter.width;
      painter.dispose();
    }
    final room = slotWidth - _labelPadding;
    if (widest <= 0 || widest <= room) return base;
    return (base * room / widest).clamp(8.0, base);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final compact = width < _compactWidth;
    final theme = Theme.of(context);
    final labelStyle = theme.navigationBarTheme.labelTextStyle;
    final fontSize = labelStyle == null
        ? null
        : fittedLabelSize(
            width / _destinations.length,
            labelStyle.resolve(const {WidgetState.selected}) ??
                const TextStyle(),
            [for (final d in _destinations) d.label],
          );
    return Scaffold(
      body: LiveGameOverlayHost(child: navigationShell),
      bottomNavigationBar: DecoratedBox(
        // Figma: 6% white hairline above the bar.
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: valColorsOf(context).hairline)),
        ),
        child: NavigationBarTheme(
          data: theme.navigationBarTheme.copyWith(
            labelTextStyle: labelStyle == null
                ? null
                : WidgetStateProperty.resolveWith(
                    (s) => labelStyle.resolve(s)?.copyWith(fontSize: fontSize),
                  ),
          ),
          child: MediaQuery.withNoTextScaling(
            child: NavigationBar(
              selectedIndex: navigationShell.currentIndex,
              labelBehavior: compact
                  ? NavigationDestinationLabelBehavior.onlyShowSelected
                  : NavigationDestinationLabelBehavior.alwaysShow,
              // Tapping the active tab pops that branch to its root.
              onDestinationSelected: (i) => navigationShell.goBranch(
                i,
                initialLocation: i == navigationShell.currentIndex,
              ),
              destinations: _destinations,
            ),
          ),
        ),
      ),
    );
  }
}
