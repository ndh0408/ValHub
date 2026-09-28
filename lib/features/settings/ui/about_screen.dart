import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../settings_strings.dart';

/// S72 "Giới thiệu & pháp lý". Route `/settings/about`.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(SettingsStrings.aboutTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
