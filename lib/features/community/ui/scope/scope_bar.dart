import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/ui/filter_bar.dart';
import '../../../../core/ui/segmented_tabs.dart';
import '../../community_strings.dart';
import '../../data/community_models.dart';
import '../../providers/scope_providers.dart';
import '../widgets/community_widgets.dart';
import 'countries_sheet.dart';
import 'language_filter_sheet.dart';

/// Label of the "country" segment: flag + name of the chosen country, else
/// "Nước bạn".
String countrySegmentLabel(String? country) => country == null
    ? CommunityStrings.scopeCountry
    : '${flagEmoji(country)} ${CommunityStrings.countryName(country)}';

/// Summary of the language filter ("Mọi ngôn ngữ", "Tiếng Việt", "3 ngôn
/// ngữ").
String languageFilterLabel(Set<String> languages) => switch (languages.length) {
  0 => CommunityStrings.anyLanguage,
  1 => CommunityStrings.languageLabel(languages.first),
  final n => CommunityStrings.languagesSelected(n),
};

/// Scope switcher of a section: "Nước bạn · Khu vực · Quốc tế" pills plus
/// the country picker ("Cộng đồng các nước"), a shard menu (region scope)
/// and the language filter (international scope). The choice is remembered
/// per section.
class ScopeBar extends ConsumerWidget {
  const ScopeBar({
    super.key,
    required this.section,
    required this.puuid,
    this.globalLabel = CommunityStrings.scopeGlobal,
  });

  final ScopedSection section;
  final String puuid;

  /// Label of the international segment ("Quốc tế" / "Toàn cầu").
  final String globalLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(communityScopeProvider(section).notifier);
    final chosen = ref.watch(communityScopeProvider(section));
    final myCountry = ref.watch(myCountryProvider(puuid)).value;
    final myRegion = communityRegion(
      ref.watch(accountProvider(puuid).select((a) => a?.region)),
    );
    final country = chosen.country ?? myCountry;
    final region = chosen.region ?? myRegion;

    Future<void> pickCountry() async {
      final picked = await showCountriesSheet(
        context,
        myCountry: myCountry,
        selected: country,
      );
      if (picked != null) {
        notifier.set(
          chosen.copyWith(
            scope: CommunityScope.country,
            country: () => picked == myCountry ? null : picked,
          ),
        );
      }
    }

    Future<void> pickLanguages() async {
      final picked = await showLanguageFilterSheet(
        context,
        initial: chosen.languages,
      );
      if (picked != null) notifier.set(chosen.copyWith(languages: picked));
    }

    return Column(
      children: [
        SegmentedTabs<CommunityScope>(
          expand: true,
          tabs: [
            SegmentedTab(
              value: CommunityScope.country,
              label: countrySegmentLabel(country),
            ),
            const SegmentedTab(
              value: CommunityScope.region,
              label: CommunityStrings.scopeRegion,
            ),
            SegmentedTab(value: CommunityScope.global, label: globalLabel),
          ],
          selected: chosen.scope,
          onChanged: (s) => notifier.set(chosen.copyWith(scope: s)),
        ),
        SizedBox(
          height: 50,
          child: ListView(
            key: ValueKey('scope-actions-${section.name}'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            children: [
              ValFilterChip(
                key: ValueKey('scope-countries-${section.name}'),
                icon: Icons.public_rounded,
                label: CommunityStrings.countriesTitle,
                selected: false,
                onSelected: (_) => unawaited(pickCountry()),
              ),
              if (chosen.scope == CommunityScope.country &&
                  myCountry != null &&
                  chosen.country != null &&
                  chosen.country != myCountry) ...[
                const SizedBox(width: 8),
                ValFilterChip(
                  icon: Icons.home_rounded,
                  label: CommunityStrings.backToMyCountry,
                  selected: false,
                  onSelected: (_) =>
                      notifier.set(chosen.copyWith(country: () => null)),
                ),
              ],
              if (chosen.scope == CommunityScope.region) ...[
                const SizedBox(width: 8),
                CommunityMenuChip<String>(
                  icon: Icons.dns_rounded,
                  label: CommunityStrings.regionLabel(region),
                  tooltip: CommunityStrings.region,
                  items: [
                    for (final r in kCommunityRegions)
                      (r, CommunityStrings.regionLabel(r)),
                  ],
                  onSelected: (r) => notifier.set(
                    chosen.copyWith(region: () => r == myRegion ? null : r),
                  ),
                ),
              ],
              if (chosen.scope == CommunityScope.global) ...[
                const SizedBox(width: 8),
                ValFilterChip(
                  key: ValueKey('scope-languages-${section.name}'),
                  icon: Icons.translate_rounded,
                  label: languageFilterLabel(chosen.languages),
                  selected: chosen.languages.isNotEmpty,
                  onSelected: (_) => unawaited(pickLanguages()),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
