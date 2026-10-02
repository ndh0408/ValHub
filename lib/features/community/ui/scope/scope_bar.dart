import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/geo/countries.dart';
import '../../../../core/ui/filter_bar.dart';
import '../../community_strings.dart';
import '../../data/community_models.dart';
import '../../providers/scope_providers.dart';
import 'countries_sheet.dart';
import 'language_filter_sheet.dart';

/// Label of the "country" segment: flag + name of the chosen country, else
/// "Nước bạn".
String countrySegmentLabel(String? country, {String? localizedName}) =>
    country == null
    ? CommunityStrings.scopeCountry
    : '${flagEmoji(country)} ${localizedName ?? CommunityStrings.countryName(country)}';

/// Summary of the language filter ("Mọi ngôn ngữ", "Tiếng Việt", "3 ngôn
/// ngữ").
String languageFilterLabel(Set<String> languages) => switch (languages.length) {
  0 => CommunityStrings.anyLanguage,
  1 => CommunityStrings.languageLabel(languages.first),
  final n => CommunityStrings.languagesSelected(n),
};

/// One scope selector on the page; country and region choices live in a
/// scrollable sheet. The applied scope and per-section preferences are retained.
class ScopeBar extends ConsumerWidget {
  const ScopeBar({
    super.key,
    required this.section,
    required this.puuid,
    this.applied,
    this.globalLabel = CommunityStrings.scopeGlobal,
    this.trailing,
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

  /// Optional trailing widget aligned on the same row (e.g. period tabs).
  final Widget? trailing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(communityScopeProvider(section).notifier);
    final chosen = ref.watch(communityScopeProvider(section));
    final myCountry = ref.watch(myCountryProvider(puuid)).value;
    final myRegion = communityAccountRegion(ref.watch(accountProvider(puuid)));
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
      if (picked != null) {
        notifier.set(
          chosen.copyWith(scope: CommunityScope.global, languages: picked),
        );
      }
    }

    final names = ref.watch(countryNamesProvider).value;
    final displayedCountry = selected == CommunityScope.country
        ? (appliedNow?.country ?? country)
        : country;
    final label = switch (selected) {
      CommunityScope.country => countrySegmentLabel(
        displayedCountry,
        localizedName: displayedCountry == null
            ? null
            : names?.name(displayedCountry),
      ),
      CommunityScope.region => CommunityStrings.regionLabel(region),
      CommunityScope.global => globalLabel,
    };

    Future<void> pickScope() async {
      final choice = await showModalBottomSheet<String>(
        context: context,
        useRootNavigator: true,
        isScrollControlled: true,
        useSafeArea: true,
        showDragHandle: true,
        builder: (sheetContext) => SizedBox(
          height: (MediaQuery.sizeOf(sheetContext).height * 0.8).clamp(0, 600),
          child: ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(8, 0, 8, 24),
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  CommunityStrings.title,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              if (myCountry != null)
                ListTile(
                  key: ValueKey('scope-home-${section.name}'),
                  leading: Text(flagEmoji(myCountry)),
                  title: Text(
                    names?.name(myCountry) ??
                        CommunityStrings.countryName(myCountry),
                  ),
                  subtitle: Text(
                    displayedCountry != myCountry &&
                            selected == CommunityScope.country
                        ? CommunityStrings.backToMyCountry
                        : CommunityStrings.yourCountry,
                  ),
                  trailing:
                      selected == CommunityScope.country &&
                          displayedCountry == myCountry
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, 'home'),
                ),
              ListTile(
                key: ValueKey('scope-global-${section.name}'),
                leading: const Icon(Icons.public_rounded),
                title: Text(globalLabel),
                trailing: selected == CommunityScope.global
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.pop(sheetContext, 'global'),
              ),
              ListTile(
                key: ValueKey('scope-countries-${section.name}'),
                leading: const Icon(Icons.travel_explore_rounded),
                title: const Text(CommunityStrings.countriesTitle),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => Navigator.pop(sheetContext, 'countries'),
              ),
              const Divider(),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(CommunityStrings.scopeRegion),
              ),
              for (final r in kCommunityRegions)
                ListTile(
                  key: ValueKey('scope-region-$r-${section.name}'),
                  leading: const Icon(Icons.dns_rounded),
                  title: Text(CommunityStrings.regionLabel(r)),
                  trailing: selected == CommunityScope.region && region == r
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.pop(sheetContext, r),
                ),
            ],
          ),
        ),
      );
      if (!context.mounted || choice == null) return;
      if (choice == 'countries') {
        await pickCountry();
      } else if (choice == 'home') {
        notifier.set(
          chosen.copyWith(scope: CommunityScope.country, country: () => null),
        );
      } else if (choice == 'global') {
        notifier.set(chosen.copyWith(scope: CommunityScope.global));
      } else if (kCommunityRegions.contains(choice)) {
        notifier.set(
          chosen.copyWith(
            scope: CommunityScope.region,
            region: () => choice == myRegion ? null : choice,
          ),
        );
      }
    }

    return SizedBox(
      width: double.infinity,
      child: Padding(
        key: ValueKey('scope-actions-${section.name}'),
        padding: const EdgeInsetsDirectional.fromSTEB(16, 6, 16, 4),
        child: Wrap(
          spacing: 8,
          runSpacing: 6,
          alignment: trailing != null
              ? WrapAlignment.spaceBetween
              : WrapAlignment.start,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Semantics(
              key: ValueKey('scope-selected-${selected.name}'),
              child: OutlinedButton(
                key: ValueKey('scope-selector-${section.name}'),
                onPressed: () => unawaited(pickScope()),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(48, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  foregroundColor: Theme.of(context).colorScheme.onSurface,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surfaceContainer
                      .withValues(alpha: 0.55),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outlineVariant
                        .withValues(alpha: 0.7),
                  ),
                  shape: const StadiumBorder(),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.expand_more_rounded, size: 18),
                  ],
                ),
              ),
            ),
            if (selected == CommunityScope.global)
              ValFilterChip(
                key: ValueKey('scope-languages-${section.name}'),
                icon: Icons.translate_rounded,
                label: languageFilterLabel(chosen.languages),
                selected: chosen.languages.isNotEmpty,
                onSelected: (_) => unawaited(pickLanguages()),
              ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
