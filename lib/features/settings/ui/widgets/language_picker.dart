import 'package:flutter/semantics.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/app_locale.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/locale_boot.dart';
import '../../../../core/l10n/locale_controller.dart';
import 'settings_widgets.dart';

String uiLanguageLabel(WidgetRef ref, AppLocalizations l10n) =>
    ref.watch(localeControllerProvider).isSystem
    ? l10n.settingsLanguageFollowDevice
    : ref.watch(appLocaleProvider).nativeName;

/// Shares the existing settings sheet; never offers an unshipped translation.
Future<void> pickUiLanguage(BuildContext context, WidgetRef ref) async {
  final l10n = context.l10n;
  final controller = ref.read(localeControllerProvider.notifier);
  final current = ref.read(localeControllerProvider);
  final selected =
      current.locale != null && !kShippedLocales.contains(current.locale)
      ? LocaleChoice.fixed(ref.read(appLocaleProvider))
      : current;
  final chosen = await showSettingsChoiceSheet<LocaleChoice>(
    context: context,
    title: l10n.settingsUiLanguageTitle,
    selected: selected,
    options: [
      (const LocaleChoice.system(), l10n.settingsLanguageFollowDevice),
      for (final locale in kShippedLocales)
        (LocaleChoice.fixed(locale), locale.nativeName),
    ],
  );
  if (chosen == null || chosen == current || !context.mounted) return;
  try {
    await controller.set(chosen);
    await WidgetsBinding.instance.endOfFrame;
    if (!context.mounted) return;
    // Speech failure cannot turn a persisted choice into a save-failure toast.
    unawaited(
      SemanticsService.sendAnnouncement(
        View.of(context),
        context.l10n.settingsLanguageChanged(
          ref.read(appLocaleProvider).nativeName,
        ),
        Directionality.of(context),
      ).catchError((Object _) {}),
    );
  } on Object {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsLanguageSaveFailed)),
      );
    }
  }
}

class AppLanguageButton extends ConsumerWidget {
  const AppLanguageButton({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) => TextButton.icon(
    icon: const Icon(Icons.language),
    label: Text(
      '${context.l10n.settingsUiLanguageTitle}: ${uiLanguageLabel(ref, context.l10n)}',
    ),
    onPressed: () => unawaited(pickUiLanguage(context, ref)),
  );
}
