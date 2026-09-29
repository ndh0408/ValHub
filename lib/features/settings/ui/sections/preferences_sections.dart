import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../../../core/settings/app_settings.dart';
import '../../settings_strings.dart';
import '../widgets/settings_widgets.dart';

/// "Tối" / "Sáng" / "Theo hệ thống".
String themeModeLabel(ThemeMode mode) => switch (mode) {
  ThemeMode.dark => SettingsStrings.themeDark,
  ThemeMode.light => SettingsStrings.themeLight,
  ThemeMode.system => SettingsStrings.themeSystem,
};

/// "Tiếng Việt" / "Tiếng Anh".
String itemLanguageLabel(ItemLanguage language) => switch (language) {
  ItemLanguage.vi => SettingsStrings.itemLanguageVi,
  ItemLanguage.en => SettingsStrings.itemLanguageEn,
};

/// "TÙY CHỌN" (S70, X1): live-game switches and the platform of the
/// active account.
class SettingsOptionsSection extends ConsumerWidget {
  const SettingsOptionsSection({super.key});

  Future<void> _pickPlatform(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final accounts = ref.read(accountsProvider.notifier);
    final chosen = await showSettingsChoiceSheet<GamePlatform>(
      context: context,
      title: SettingsStrings.platformPickerTitle,
      hint:
          '${SettingsStrings.platformHint}\n'
          '${SettingsStrings.platformAppliesTo(account.riotId)}',
      selected: account.platform,
      options: [for (final p in GamePlatform.values) (p, p.label)],
    );
    if (chosen == null || chosen == account.platform) return;
    await accounts.updateAccount(
      account.puuid,
      (a) => a.copyWith(platform: chosen),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final account = ref.watch(activeAccountProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    return SettingsGroup(
      title: SettingsStrings.optionsHeader,
      children: [
        SettingsSwitchTile(
          icon: Icons.bolt_outlined,
          title: SettingsStrings.optionAutoOpenLiveGame,
          subtitle: SettingsStrings.optionAutoOpenLiveGameSubtitle,
          value: settings.autoOpenLiveGame,
          onChanged: (v) => unawaited(
            notifier.update((s) => s.copyWith(autoOpenLiveGame: v)),
          ),
        ),
        SettingsSwitchTile(
          icon: Icons.military_tech_outlined,
          title: SettingsStrings.optionShowPeakRank,
          value: settings.showPeakRankInGame,
          onChanged: (v) => unawaited(
            notifier.update((s) => s.copyWith(showPeakRankInGame: v)),
          ),
        ),
        SettingsSwitchTile(
          icon: Icons.scoreboard_outlined,
          title: SettingsStrings.optionShowLiveScore,
          value: settings.showLiveScore,
          onChanged: (v) =>
              unawaited(notifier.update((s) => s.copyWith(showLiveScore: v))),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.sports_esports_outlined),
          title: const Text(SettingsStrings.optionPlatform),
          trailing: SettingsValue(
            (account?.platform ?? GamePlatform.pc).label,
            icon: Icons.expand_more,
          ),
          enabled: account != null,
          onTap: account == null
              ? null
              : () => unawaited(_pickPlatform(context, ref, account)),
        ),
      ],
    );
  }
}

/// "GIAO DIỆN" (S70, ValVN extra): theme and item-name language.
class SettingsAppearanceSection extends ConsumerWidget {
  const SettingsAppearanceSection({super.key});

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final current = ref.read(appSettingsProvider).themeMode;
    final settings = ref.read(appSettingsProvider.notifier);
    final chosen = await showSettingsChoiceSheet<ThemeMode>(
      context: context,
      title: SettingsStrings.themePickerTitle,
      selected: current,
      options: [
        for (final m in const [
          ThemeMode.dark,
          ThemeMode.light,
          ThemeMode.system,
        ])
          (m, themeModeLabel(m)),
      ],
    );
    if (chosen != null) await settings.setThemeMode(chosen);
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final current = ref.read(appSettingsProvider).itemLanguage;
    final settings = ref.read(appSettingsProvider.notifier);
    final chosen = await showSettingsChoiceSheet<ItemLanguage>(
      context: context,
      title: SettingsStrings.itemLanguagePickerTitle,
      hint: SettingsStrings.itemLanguageHint,
      selected: current,
      options: [for (final l in ItemLanguage.values) (l, itemLanguageLabel(l))],
    );
    if (chosen != null) await settings.setItemLanguage(chosen);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(appSettingsProvider.select((s) => s.themeMode));
    final language = ref.watch(
      appSettingsProvider.select((s) => s.itemLanguage),
    );
    return SettingsGroup(
      title: SettingsStrings.appearanceHeader,
      children: [
        ListTile(
          leading: const SettingsIcon(Icons.dark_mode_outlined),
          title: const Text(SettingsStrings.themeLabel),
          trailing: SettingsValue(themeModeLabel(theme)),
          onTap: () => unawaited(_pickTheme(context, ref)),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.translate_outlined),
          title: const Text(SettingsStrings.itemLanguageLabel),
          trailing: SettingsValue(itemLanguageLabel(language)),
          onTap: () => unawaited(_pickLanguage(context, ref)),
        ),
      ],
    );
  }
}
