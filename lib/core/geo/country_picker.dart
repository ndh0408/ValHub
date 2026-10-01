import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../accounts/account_providers.dart';
import '../l10n/l10n.dart';
import '../storage/prefs.dart';
import '../util/search_text.dart';
import 'countries.dart';
import 'country_preference.dart';
import 'regions.dart';

Future<CountryInfo?> showCountryPicker(BuildContext context) =>
    showModalBottomSheet<CountryInfo>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const CountryPicker(),
    );

class CountryPicker extends ConsumerStatefulWidget {
  const CountryPicker({super.key});
  @override
  ConsumerState<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends ConsumerState<CountryPicker> {
  String _query = '';
  String? _region;
  late bool _supportedOnly;
  @override
  void initState() {
    super.initState();
    _supportedOnly =
        ref.read(prefsProvider).getBool('geo.supportedOnly') ?? true;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final countries = ref.watch(countriesProvider);
    final names = ref.watch(countryNamesProvider);
    final data = countries.value;
    final labels = names.value;
    final tokens = searchTokens(_query);
    bool matches(String code) =>
        data != null &&
        labels != null &&
        data.containsKey(code) &&
        matchesTokens(
          foldForSearch(
            '${labels.name(code)} ${labels.english[code] ?? ''} $code ${data[code]!.alpha3}',
          ),
          tokens,
        );
    // Suggestions remain visible even when a support/region filter would hide them.
    final suggestions = <String>{
      ?ref.watch(countryPreferenceProvider),
      ?normalizeCountry(ref.watch(activeAccountProvider)?.country),
      ?normalizeCountry(ref.watch(deviceCountryProvider)),
    }.where(matches).toList();
    final codes = data == null || labels == null
        ? <String>[]
        : [
            for (final code in labels.order)
              if (!suggestions.contains(code) &&
                  matches(code) &&
                  (!_supportedOnly || data[code]!.isSupported) &&
                  (_region == null || data[code]!.regionHint == _region))
                code,
          ];
    Widget row(String code) {
      final country = data![code]!;
      final status = switch (country.availability) {
        CountryAvailability.available => l10n.settingsGeoAvailable,
        CountryAvailability.restricted => l10n.settingsGeoRestricted,
        CountryAvailability.separate => l10n.settingsGeoSeparate,
        CountryAvailability.unknown => l10n.settingsGeoUnknown,
        CountryAvailability.na => l10n.settingsGeoNotApplicable,
      };
      final icon = switch (country.availability) {
        CountryAvailability.available => Icons.check_circle_outline,
        CountryAvailability.restricted => Icons.warning_amber_rounded,
        CountryAvailability.separate => Icons.dns_outlined,
        CountryAvailability.unknown => Icons.help_outline,
        CountryAvailability.na => Icons.remove_circle_outline,
      };
      return ListTile(
        key: ValueKey(country.code),
        leading: ExcludeSemantics(
          child: Text(countryFlag(code), style: const TextStyle(fontSize: 24)),
        ),
        title: Text(labels!.name(country.code)),
        subtitle: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ExcludeSemantics(child: Icon(icon, size: 18)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '$status${country.shardHint == null ? '' : ' · ${country.shardHint!.toUpperCase()}'}',
              ),
            ),
          ],
        ),
        trailing: Text(country.code, textDirection: TextDirection.ltr),
        onTap: () => Navigator.pop(context, country),
      );
    }

    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                      16,
                      20,
                      16,
                      12,
                    ),
                    child: Text(
                      l10n.settingsGeoCountry,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: l10n.settingsGeoSearchCountry,
                        prefixIcon: const Icon(Icons.search),
                      ),
                      onChanged: (v) => setState(() => _query = v),
                    ),
                  ),
                  SwitchListTile(
                    title: Text(l10n.settingsGeoSupportedOnly),
                    value: _supportedOnly,
                    onChanged: (value) async {
                      setState(() => _supportedOnly = value);
                      try {
                        await ref
                            .read(prefsProvider)
                            .setBool('geo.supportedOnly', value);
                      } on Object {
                        if (context.mounted) {
                          ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                            SnackBar(content: Text(l10n.settingsGeoSaveFailed)),
                          );
                        }
                      }
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(l10n.settingsGeoAllRegions),
                          selected: _region == null,
                          onSelected: (_) => setState(() => _region = null),
                        ),
                        for (final region in RegionTable.visibleRegions)
                          ChoiceChip(
                            label: Text(
                              region.toUpperCase(),
                              textDirection: TextDirection.ltr,
                            ),
                            selected: _region == region,
                            onSelected: (_) => setState(() => _region = region),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      l10n.settingsGeoHintOnly,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            if (countries.hasError || names.hasError)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.refresh),
                    tooltip: l10n.commonRetry,
                    onPressed: () {
                      ref.invalidate(countriesProvider);
                      ref.invalidate(countryNamesProvider);
                    },
                  ),
                ),
              )
            else if (data == null || labels == null)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (suggestions.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.settingsGeoSuggestions),
                  ),
                ),
                SliverList.builder(
                  itemCount: suggestions.length,
                  itemBuilder: (_, i) => row(suggestions[i]),
                ),
              ],
              if (codes.isEmpty && suggestions.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(child: Text(l10n.settingsGeoNoCountries)),
                )
              else
                SliverList.builder(
                  itemCount: codes.length,
                  itemBuilder: (_, i) => row(codes[i]),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
