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
    this.applied,
    this.globalLabel = CommunityStrings.scopeGlobal,
  });

  final ScopedSection section;
  final String puuid;

  /// The scope the server applied to the list on screen (`appliedScope`).
  /// It wins over the client's own guess: the segment shown as selected is
  /// the one that really filters the list (e.g. the server knows the
  /// viewer's country when the app could not read it).
  final AppliedScope? applied;

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
    final appliedNow = applied;
    final country =
        chosen.country ??
        myCountry ??
        (appliedNow?.scope == CommunityScope.country
            ? appliedNow?.country
            : null);
    final region = appliedNow?.scope == CommunityScope.region
        ? (appliedNow?.region ?? chosen.region ?? myRegion)
        : (chosen.region ?? myRegion);
    // What is really shown (a missing country falls back to the shard, or to
    // the world for a reader who has not joined): highlight that segment.
    final shown = ref
        .watch(resolvedScopeProvider((puuid: puuid, section: section)))
        .value
        ?.scope;
    final selected =
        appliedNow?.scope ??
        shown ??
        (chosen.scope == CommunityScope.country && country == null
            ? CommunityScope.global
            : chosen.scope);

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
            // Without a known country there is no "nước bạn" to show.
            if (country != null)
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
          selected: selected,
          onChanged: (s) => notifier.set(chosen.copyWith(scope: s)),
        ),
        SizedBox(
          height: 50,
          child: ListView(
            key: ValueKey('scope-actions-${section.name}'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
            children: [
              // The chip that belongs to the chosen scope comes first, the
              // country picker last.
              if (chosen.scope == CommunityScope.country &&
                  myCountry != null &&
                  chosen.country != null &&
                  chosen.country != myCountry) ...[
                ValFilterChip(
                  key: ValueKey('scope-home-${section.name}'),
                  icon: Icons.home_rounded,
                  label: CommunityStrings.backToMyCountry,
                  selected: false,
                  onSelected: (_) =>
                      notifier.set(chosen.copyWith(country: () => null)),
                ),
                const SizedBox(width: 8),
              ],
              if (chosen.scope == CommunityScope.region) ...[
                CommunityMenuChip<String>(
                  key: ValueKey('scope-region-${section.name}'),
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
                const SizedBox(width: 8),
              ],
              if (chosen.scope == CommunityScope.global) ...[
                ValFilterChip(
                  key: ValueKey('scope-languages-${section.name}'),
                  icon: Icons.translate_rounded,
                  label: languageFilterLabel(chosen.languages),
                  selected: chosen.languages.isNotEmpty,
                  onSelected: (_) => unawaited(pickLanguages()),
                ),
                const SizedBox(width: 8),
              ],
              ValFilterChip(
                key: ValueKey('scope-countries-${section.name}'),
                icon: Icons.public_rounded,
                label: CommunityStrings.countriesTitle,
                selected: false,
                onSelected: (_) => unawaited(pickCountry()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
