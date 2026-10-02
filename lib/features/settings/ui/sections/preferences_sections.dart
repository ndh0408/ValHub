import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../../../core/config/local_price.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/price_estimate.dart';
import '../../../../core/ui/sub_page.dart';
import '../../../../core/util/format.dart';
import '../widgets/settings_widgets.dart';
import '../widgets/language_picker.dart';

import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/account_labels.dart';

/// "Tối" / "Sáng" / "Theo hệ thống".
String themeModeLabel(ThemeMode mode, AppLocalizations l10n) => switch (mode) {
  ThemeMode.dark => l10n.settingsThemeDark,
  ThemeMode.light => l10n.settingsThemeLight,
  ThemeMode.system => l10n.settingsThemeSystem,
};

/// "Tiếng Việt" / "Tiếng Anh".
String itemLanguageLabel(ItemLanguage language, AppLocalizations l10n) =>
    switch (language) {
      ItemLanguage.vi => l10n.settingsItemLanguageVi,
      ItemLanguage.en => l10n.settingsItemLanguageEn,
    };

/// "TÙY CHỌN" (S70, X1): live-game switches, the platform of the active
/// account, the local-currency estimate next to VP prices and the user's
/// own pack price (VanHub extras).
class SettingsOptionsSection extends ConsumerWidget {
  const SettingsOptionsSection({super.key});

  Future<void> _pickPlatform(
    BuildContext context,
    WidgetRef ref,
    Account account,
  ) async {
    final l10n = context.l10n;
    final accounts = ref.read(accountsProvider.notifier);
    final chosen = await showSettingsChoiceSheet<GamePlatform>(
      context: context,
      title: l10n.settingsPlatformPickerTitle,
      hint:
          '${l10n.settingsPlatformHint}\n'
          '${l10n.settingsPlatformAppliesTo(account.riotId)}',
      selected: account.platform,
      options: [
        for (final p in GamePlatform.values) (p, l10n.gamePlatformName(p)),
      ],
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
    // Estimates need a verified table for the device's country or the
    // user's own pack price.
    final price = ref.watch(localPriceSourceProvider);
    final hasPrices = price != null;
    final override = ref.watch(vpPriceOverrideProvider);
    return SettingsGroup(
      title: context.l10n.settingsOptionsHeader,
      children: [
        SettingsSwitchTile(
          icon: Icons.bolt_outlined,
          title: context.l10n.settingsOptionAutoOpenLiveGame,
          subtitle: context.l10n.settingsOptionAutoOpenLiveGameSubtitle,
          value: settings.autoOpenLiveGame,
          onChanged: (v) => unawaited(
            notifier.update((s) => s.copyWith(autoOpenLiveGame: v)),
          ),
        ),
        SettingsSwitchTile(
          icon: Icons.military_tech_outlined,
          title: context.l10n.settingsOptionShowPeakRank,
          value: settings.showPeakRankInGame,
          onChanged: (v) => unawaited(
            notifier.update((s) => s.copyWith(showPeakRankInGame: v)),
          ),
        ),
        SettingsSwitchTile(
          icon: Icons.scoreboard_outlined,
          title: context.l10n.settingsOptionShowLiveScore,
          value: settings.showLiveScore,
          onChanged: (v) =>
              unawaited(notifier.update((s) => s.copyWith(showLiveScore: v))),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.sports_esports_outlined),
          title: Text(context.l10n.settingsOptionPlatform),
          trailing: SettingsValue(
            context.l10n.gamePlatformName(account?.platform ?? GamePlatform.pc),
            icon: Icons.expand_more,
          ),
          enabled: account != null,
          onTap: account == null
              ? null
              : () => unawaited(_pickPlatform(context, ref, account)),
        ),
        SettingsSwitchTile(
          icon: Icons.payments_outlined,
          title: context.l10n.settingsOptionShowPrice,
          subtitle: price == null
              ? context.l10n.settingsOptionShowPriceUnavailable
              : context.l10n.settingsOptionShowPriceSubtitle(
                  formatVp(1775),
                  price.format(1775) ?? '',
                ),
          value: hasPrices && settings.showPriceEstimate,
          onChanged: hasPrices
              ? (v) => unawaited(
                  notifier.update((s) => s.copyWith(showPriceEstimate: v)),
                )
              : null,
          infoTooltip: context.l10n.settingsOptionShowPriceInfo,
          onInfo: () => unawaited(showPriceEstimateInfoSheet(context)),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.edit_note_outlined),
          title: Text(context.l10n.settingsOptionOwnPrice),
          subtitle: Text(
            override == null
                ? context.l10n.settingsOptionOwnPriceEmpty
                : context.l10n.settingsOptionOwnPriceValue(
                    formatVp(override.vp),
                    formatCurrency(override.price, override.currency),
                  ),
          ),
          trailing: const SettingsChevron(),
          onTap: () => unawaited(showVpPriceOverrideSheet(context)),
        ),
      ],
    );
  }
}

/// "GIAO DIỆN" (S70, VanHub extra): theme and item-name language.
class SettingsAppearanceSection extends ConsumerWidget {
  const SettingsAppearanceSection({super.key});

  Future<void> _pickTheme(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final current = ref.read(appSettingsProvider).themeMode;
    final settings = ref.read(appSettingsProvider.notifier);
    const modes = [ThemeMode.dark, ThemeMode.light, ThemeMode.system];
    final ThemeMode? chosen;
    if (isCupertino(context)) {
      chosen = await showSettingsChoiceSheet<ThemeMode>(
        context: context,
        title: l10n.settingsThemePickerTitle,
        selected: current,
        options: [for (final m in modes) (m, themeModeLabel(m, context.l10n))],
      );
    } else {
      // Material: a live preview of each theme above the list.
      chosen = await showValSheet<ThemeMode>(
        context,
        title: l10n.settingsThemePickerTitle,
        builder: (sheetContext, _) {
          void pick(ThemeMode m) => Navigator.of(sheetContext).pop(m);
          return SettingsChoiceList<ThemeMode>(
            selected: current,
            onPicked: pick,
            header: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
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
                (
                  value: m,
                  label: themeModeLabel(m, sheetContext.l10n),
                  leading: null,
                ),
            ],
          );
        },
      );
      if (chosen != null && chosen != current) Haptics.selection();
    }
    if (chosen != null) await settings.setThemeMode(chosen);
  }

  Future<void> _pickLanguage(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final current = ref.read(appSettingsProvider).itemLanguage;
    final settings = ref.read(appSettingsProvider.notifier);
    final chosen = await showSettingsChoiceSheet<ItemLanguage>(
      context: context,
      title: l10n.settingsItemLanguagePickerTitle,
      hint: l10n.settingsItemLanguageHint,
      selected: current,
      options: [
        for (final l in ItemLanguage.values)
          (l, itemLanguageLabel(l, context.l10n)),
      ],
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
      title: context.l10n.settingsAppearanceHeader,
      children: [
        ListTile(
          leading: SettingsIcon(switch (theme) {
            ThemeMode.light => Icons.light_mode_outlined,
            ThemeMode.dark => Icons.dark_mode_outlined,
            ThemeMode.system => Icons.brightness_auto_outlined,
          }),
          title: Text(context.l10n.settingsThemeLabel),
          trailing: SettingsValue(themeModeLabel(theme, context.l10n)),
          onTap: () => unawaited(_pickTheme(context, ref)),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.language),
          title: Text(context.l10n.settingsUiLanguageTitle),
          trailing: SettingsValue(uiLanguageLabel(ref, context.l10n)),
          onTap: () => unawaited(pickUiLanguage(context, ref)),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.translate_outlined),
          title: Text(context.l10n.settingsItemLanguageLabel),
          trailing: SettingsValue(itemLanguageLabel(language, context.l10n)),
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
      label: themeModeLabel(mode, context.l10n),
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
