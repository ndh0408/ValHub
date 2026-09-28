import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../../live_game/current_game_card.dart';
import '../profile_strings.dart';

/// TAB 4 "Hồ sơ" (S40). Route `/profile`. Hosts the live-game
/// [CurrentGameCard] (owned by the live_game feature).
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPageScaffold(
      title: ProfileStrings.title,
      slivers: [
        SliverToBoxAdapter(
          child: Padding(padding: EdgeInsets.all(16), child: CurrentGameCard()),
        ),
        SliverFillRemaining(hasScrollBody: false, child: FeaturePlaceholder()),
      ],
    );
  }
}
