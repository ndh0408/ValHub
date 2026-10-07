import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/config/local_price.dart';
import '../../../../core/geo/countries.dart';
import '../../../../core/geo/country_picker.dart';
import '../../../../core/geo/country_preference.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/l10n/labels/economy_labels.dart';
import '../../../../core/settings/app_settings.dart';
import '../../../../core/ui/price_estimate.dart';
import '../../../../core/util/format.dart';
import '../widgets/settings_widgets.dart';

/// "QUỐC GIA & GIÁ": the country the app uses for names, suggestions and
/// the local-currency estimate, then that estimate (when a verified price
/// table or the user's own pack price exists) and the user's own price.
class SettingsCountrySection extends ConsumerWidget {
  const SettingsCountrySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(selectedCountryProvider);
    final explicit = ref.watch(countryPreferenceProvider);
    final labels = ref.watch(countryNamesProvider).value;
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);
    // Estimates need a verified table for the device's country or the
    // user's own pack price.
    final price = ref.watch(localPriceSourceProvider);
    final hasPrices = price != null;
    final override = ref.watch(vpPriceOverrideProvider);
    return SettingsGroup(
      title: l10n.settingsCountryPriceHeader,
      footer: Text(l10n.settingsGeoCountryPreferenceHint),
      children: [
        ListTile(
          leading: const SettingsIcon(Icons.public),
          title: Text(l10n.settingsGeoCountry),
          subtitle: Text(
            selected == null
                ? l10n.settingsGeoUnknown
                : labels?.name(selected) ?? selected,
          ),
          trailing: const SettingsChevron(),
          onTap: () async {
            final countries = ref.read(countryPreferenceProvider.notifier);
            final chosen = await showCountryPicker(context);
            if (chosen == null || !context.mounted) return;
            try {
              await countries.set(chosen.code);
            } on Object {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.settingsGeoSaveFailed)),
                );
              }
            }
          },
        ),
        if (explicit != null)
          ListTile(
            leading: const SettingsIcon(Icons.restart_alt),
            title: Text(l10n.settingsGeoCountryAutomatic),
            onTap: () async {
              try {
                await ref.read(countryPreferenceProvider.notifier).set(null);
              } on Object {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.settingsGeoSaveFailed)),
                  );
                }
              }
            },
          ),
        SettingsSwitchTile(
          icon: Icons.payments_outlined,
          title: l10n.settingsOptionShowPrice,
          subtitle: price == null
              ? l10n.settingsOptionShowPriceUnavailable
              : l10n.settingsOptionShowPriceSubtitle(
                  context.fmt.vp(1775),
                  price.estimateText(context.fmt, 1775) ?? '',
                ),
          value: hasPrices && settings.showPriceEstimate,
          onChanged: hasPrices
              ? (v) => unawaited(
                  notifier.update((s) => s.copyWith(showPriceEstimate: v)),
                )
              : null,
          infoTooltip: l10n.settingsOptionShowPriceInfo,
          onInfo: () => unawaited(showPriceEstimateInfoSheet(context)),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.edit_note_outlined),
          title: Text(l10n.settingsOptionOwnPrice),
          subtitle: Text(
            override == null
                ? l10n.settingsOptionOwnPriceEmpty
                : l10n.settingsOptionOwnPriceValue(
                    context.fmt.vp(override.vp),
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
