import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
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
    const modes = [ThemeMode.dark, ThemeMode.light, ThemeMode.system];
    final ThemeMode? chosen;
    if (isCupertino(context)) {
      chosen = await showSettingsChoiceSheet<ThemeMode>(
        context: context,
        title: SettingsStrings.themePickerTitle,
        selected: current,
        options: [for (final m in modes) (m, themeModeLabel(m))],
      );
    } else {
      // Material: a live preview of each theme above the list.
      chosen = await showModalBottomSheet<ThemeMode>(
        context: context,
        useSafeArea: true,
        isScrollControlled: true,
        builder: (sheetContext) {
          void pick(ThemeMode m) => Navigator.of(sheetContext).pop(m);
          return SettingsChoiceList<ThemeMode>(
            title: SettingsStrings.themePickerTitle,
            selected: current,
            onPicked: pick,
            header: Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
              child: Row(
                children: [
                  for (final m in modes) ...[
                    if (m != modes.first) const SizedBox(width: 12),
                    Expanded(
                      child: ThemePreviewSwatch(
                        mode: m,
                        selected: m == current,
                        onTap: () => pick(m),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            options: [
              for (final m in modes)
                (value: m, label: themeModeLabel(m), leading: null),
            ],
          );
        },
      );
      if (chosen != null && chosen != current) Haptics.selection();
    }
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
          leading: SettingsIcon(switch (theme) {
            ThemeMode.light => Icons.light_mode_outlined,
            ThemeMode.dark => Icons.dark_mode_outlined,
            ThemeMode.system => Icons.brightness_auto_outlined,
          }),
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

/// Miniature of a theme (background, a card, a red pill) for the theme
/// picker; "Theo hệ thống" shows dark and light split diagonally.
class ThemePreviewSwatch extends StatelessWidget {
  const ThemePreviewSwatch({
    super.key,
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final ThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  // The real theme palettes, so the previews follow any theme change.
  static final _darkScheme = buildDarkTheme().colorScheme;
  static final _lightScheme = buildLightTheme().colorScheme;

  static Widget _mock({required bool dark}) {
    final scheme = dark ? _darkScheme : _lightScheme;
    final bg = scheme.surface;
    final card = scheme.surfaceContainer;
    final line = scheme.surfaceContainerHighest;
    return ColoredBox(
      color: bg,
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 28,
              height: 6,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.all(6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 4, width: 30, color: line),
                    const SizedBox(height: 4),
                    Container(height: 4, width: 20, color: line),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final Widget art = switch (mode) {
      ThemeMode.dark => _mock(dark: true),
      ThemeMode.light => _mock(dark: false),
      ThemeMode.system => Stack(
        fit: StackFit.expand,
        children: [
          _mock(dark: false),
          ClipPath(clipper: _DiagonalClipper(), child: _mock(dark: true)),
        ],
      ),
    };
    return Semantics(
      button: true,
      selected: selected,
      label: themeModeLabel(mode),
      excludeSemantics: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: ValMotion.fast,
          height: 84,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ValRadius.small),
            border: Border.all(
              color: selected ? scheme.primary : scheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(ValRadius.small - 2),
            child: art,
          ),
        ),
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) => Path()
    ..moveTo(0, 0)
    ..lineTo(size.width, 0)
    ..lineTo(0, size.height)
    ..close();

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => false;
}
