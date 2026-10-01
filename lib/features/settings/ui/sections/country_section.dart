import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/geo/countries.dart';
import '../../../../core/geo/country_picker.dart';
import '../../../../core/geo/country_preference.dart';
import '../../../../core/l10n/l10n.dart';
import '../widgets/settings_widgets.dart';

class SettingsCountrySection extends ConsumerWidget {
  const SettingsCountrySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(selectedCountryProvider);
    final explicit = ref.watch(countryPreferenceProvider);
    final labels = ref.watch(countryNamesProvider).value;
    return SettingsGroup(
      title: l10n.settingsGeoCountry,
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
            final notifier = ref.read(countryPreferenceProvider.notifier);
            final chosen = await showCountryPicker(context);
            if (chosen == null || !context.mounted) return;
            try {
              await notifier.set(chosen.code);
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
      ],
    );
  }
}
