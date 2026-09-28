import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../battlepass_strings.dart';

/// S21 "Phần thưởng Battle Pass". Route `/battlepass/rewards`.
class BattlePassRewardsScreen extends StatelessWidget {
  const BattlePassRewardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(BattlePassStrings.rewardsTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
