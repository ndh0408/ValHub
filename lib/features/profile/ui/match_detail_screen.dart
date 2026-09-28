import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../profile_strings.dart';

/// S43 "Chi tiết trận đấu". Route `/profile/match/:id`.
class MatchDetailScreen extends StatelessWidget {
  const MatchDetailScreen({super.key, required this.matchId});

  final String matchId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ProfileStrings.matchDetailTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
