import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/common_strings.dart';
import '../settings_routes.dart';

/// The ⚙ button of the Home and Profile headers: opens "Cài đặt"
/// (`/settings`) on top of the current tab, so Back returns to it. Settings
/// is no longer a tab (docs/design/IA.md).
class SettingsGearButton extends StatelessWidget {
  const SettingsGearButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.settings_outlined),
    tooltip: CommonStrings.tabSettings,
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    onPressed: () =>
        unawaited(GoRouter.of(context).push<Object?>(SettingsRoutes.root)),
  );
}
