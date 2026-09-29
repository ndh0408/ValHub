import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../core/l10n/common_strings.dart';
import '../core/ui/floating_nav_bar.dart';
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
  /// tab shows its label (the others keep their semantics label).
  static const compactWidth = 420.0;

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < compactWidth;
    return Scaffold(
      body: LiveGameOverlayHost(child: navigationShell),
      // Floating frosted capsule; styling lives in FloatingNavBar.
      bottomNavigationBar: FloatingNavBar(
        selectedIndex: navigationShell.currentIndex,
        compact: compact,
        // Tapping the active tab pops that branch to its root.
        onDestinationSelected: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
        destinations: _destinations,
      ),
    );
  }
}
