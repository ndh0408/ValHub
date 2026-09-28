import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../profile_strings.dart';

/// S44 "Hồ sơ người chơi" (any player). Top-level route `/player/:puuid`.
class PlayerProfileScreen extends StatelessWidget {
  const PlayerProfileScreen({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ProfileStrings.playerProfileTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
