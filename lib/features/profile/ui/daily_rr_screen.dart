import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../profile_strings.dart';

/// S42 "RR theo ngày". Route `/profile/daily-rr`.
class DailyRrScreen extends StatelessWidget {
  const DailyRrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(ProfileStrings.dailyRrTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
