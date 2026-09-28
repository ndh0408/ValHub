import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../settings_strings.dart';

/// TAB 5 "Cài đặt" (S70). Route `/settings`.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPageScaffold(
      title: SettingsStrings.title,
      body: FeaturePlaceholder(),
    );
  }
}
