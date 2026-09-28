import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../battlepass_strings.dart';

/// TAB 2 "Battle Pass" (S20). Route `/battlepass`.
class BattlePassScreen extends StatelessWidget {
  const BattlePassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPageScaffold(
      title: BattlePassStrings.title,
      body: FeaturePlaceholder(),
    );
  }
}
