import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../settings_strings.dart';

/// S71 "Nhật ký phiên" (export via share_plus; no tokens). Route `/settings/log`.
class SessionLogScreen extends StatelessWidget {
  const SessionLogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(SettingsStrings.sessionLogTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
