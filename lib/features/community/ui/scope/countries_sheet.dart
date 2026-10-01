import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/geo/country_picker.dart';
import '../../providers/scope_providers.dart';

Future<String?> showCountriesSheet(
  BuildContext context, {
  String? myCountry,
  String? selected,
}) => showCountrySelection<String>(
  context,
  builder: (_, fullHeight) => CountriesSheet(
    myCountry: myCountry,
    selected: selected,
    fullHeight: fullHeight,
  ),
);

/// Community supplies real weekly counts; the shared picker owns the CLDR
/// names, ISO search, IME behavior, presentation and all-country tab.
class CountriesSheet extends ConsumerWidget {
  const CountriesSheet({
    super.key,
    this.myCountry,
    this.selected,
    this.fullHeight = false,
  });
  final String? myCountry;
  final String? selected;
  final bool fullHeight;

  @override
  Widget build(BuildContext context, WidgetRef ref) => CountryPicker.community(
    fullHeight: fullHeight,
    myCountry: myCountry,
    selectedCountry: selected,
    activity: ref
        .watch(communitiesProvider)
        .whenData(
          (items) => [
            for (final c in items)
              CountryActivity(
                code: c.country,
                posts: c.posts,
                authors: c.authors,
                lfg: c.lfg,
              ),
          ],
        ),
    onRetryActivity: () => ref.invalidate(communitiesProvider),
  );
}
