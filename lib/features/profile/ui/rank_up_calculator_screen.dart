import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../profile_strings.dart';

/// S41 "Tính toán lên hạng". Route `/profile/rankup`.
class RankUpCalculatorScreen extends StatelessWidget {
  const RankUpCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ProfileStrings.rankUpTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
