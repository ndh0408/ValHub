import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../settings_routes.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// The ⚙ button of the Home and Profile headers: opens "Cài đặt"
/// (`/settings`) on top of the current tab, so Back returns to it. Settings
/// is no longer a tab (docs/design/IA.md).
class SettingsGearButton extends StatelessWidget {
  const SettingsGearButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    icon: const Icon(Icons.settings_outlined),
    tooltip: context.l10n.commonTabSettings,
    constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
    onPressed: () =>
        unawaited(GoRouter.of(context).push<Object?>(SettingsRoutes.root)),
  );
}
