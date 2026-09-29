import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/l10n/common_strings.dart';
import '../core/theme/app_theme.dart';
import '../features/live_game/live_game_overlay_host.dart';

/// Tab shell: the five ValBuddy tabs (VF §6) and the live-game overlay hook.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LiveGameOverlayHost(child: navigationShell),
      bottomNavigationBar: DecoratedBox(
        // Figma: 6% white hairline above the bar.
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: valColorsOf(context).hairline)),
        ),
        child: NavigationBar(
          selectedIndex: navigationShell.currentIndex,
          // Tapping the active tab pops that branch to its root.
          onDestinationSelected: (i) => navigationShell.goBranch(
            i,
            initialLocation: i == navigationShell.currentIndex,
          ),
          destinations: _destinations,
        ),
      ),
    );
  }
}
