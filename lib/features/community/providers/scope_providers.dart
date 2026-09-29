import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/storage/ui_memory.dart';
import '../data/community_models.dart';
import 'community_providers.dart';

/// Sections whose content scope the viewer chooses (LFG always shows one
/// region: only players on the same shard can party).
enum ScopedSection {
  feed,
  skins;

  /// Default: the viewer's country (docs/community-api.md v3).
  ScopeFilter get defaultScope => ScopeFilter.mineCountry;
}

/// `UiMemory` keys of a section's scope.
abstract final class ScopeMemoryKeys {
  static String scope(ScopedSection s) => 'community.${s.name}.scope';
  static String country(ScopedSection s) => 'community.${s.name}.country';
  static String region(ScopedSection s) => 'community.${s.name}.region';
  static String languages(ScopedSection s) => 'community.${s.name}.languages';
}

/// The scope chosen for a section, remembered across launches.
final communityScopeProvider =
    NotifierProvider.family<CommunityScopeNotifier, ScopeFilter, ScopedSection>(
      CommunityScopeNotifier.new,
    );

class CommunityScopeNotifier extends Notifier<ScopeFilter> {
  CommunityScopeNotifier(this.section);

  final ScopedSection section;

  @override
  ScopeFilter build() {
    final m = ref.watch(uiMemoryProvider);
    final scope = CommunityScope.tryParse(
      m.read(ScopeMemoryKeys.scope(section)),
    );
    if (scope == null) return section.defaultScope;
    final region = m.read(ScopeMemoryKeys.region(section));
    return ScopeFilter(
      scope: scope,
      country: countryCode(m.read(ScopeMemoryKeys.country(section))),
      region: region != null && kCommunityRegions.contains(region)
          ? region
          : null,
      languages: {
        for (final l
            in (m.read(ScopeMemoryKeys.languages(section)) ?? '').split(','))
          if (lfgLanguageCode(l) case final code? when code != kLfgAnyLanguage)
            code,
      },
    );
  }

  void set(ScopeFilter filter) {
    state = filter;
    final m = ref.read(uiMemoryProvider)
      ..write(ScopeMemoryKeys.scope(section), filter.scope.name)
      ..write(ScopeMemoryKeys.country(section), filter.country)
      ..write(ScopeMemoryKeys.region(section), filter.region);
    m.write(
      ScopeMemoryKeys.languages(section),
      filter.languages.isEmpty
          ? null
          : ([...filter.languages]..sort()).join(','),
    );
  }
}

/// Replaces "the viewer's own" country / region with real values (pure):
/// a missing country falls back to the viewer's region (spec v3).
ScopeFilter resolveScope(
  ScopeFilter chosen, {
  required String? myCountry,
  required String myRegion,
}) {
  switch (chosen.scope) {
    case CommunityScope.country:
      final country = chosen.country ?? myCountry;
      return country == null
          ? ScopeFilter(scope: CommunityScope.region, region: myRegion)
          : ScopeFilter(scope: CommunityScope.country, country: country);
    case CommunityScope.region:
      return ScopeFilter(
        scope: CommunityScope.region,
        region: chosen.region ?? myRegion,
      );
    case CommunityScope.global:
      return ScopeFilter(
        scope: CommunityScope.global,
        languages: chosen.languages,
      );
  }
}

/// Key of [resolvedScopeProvider].
typedef ResolvedScopeKey = ({String puuid, ScopedSection section});

/// The section's scope with the viewer's country / region filled in. The
/// country comes from the community profile (Riot account); when it cannot
/// be read the viewer's region is used.
final resolvedScopeProvider = FutureProvider.autoDispose
    .family<ScopeFilter, ResolvedScopeKey>((ref, key) async {
      final chosen = ref.watch(communityScopeProvider(key.section));
      final account = ref.watch(accountProvider(key.puuid));
      final myRegion = communityRegion(account?.region);
      String? myCountry;
      if (chosen.scope == CommunityScope.country && chosen.country == null) {
        try {
          myCountry = (await ref.watch(communityMeProvider(key.puuid).future))
              .country;
        } on Object {
          myCountry = null;
        }
      }
      return resolveScope(chosen, myCountry: myCountry, myRegion: myRegion);
    });

/// The viewer's own country (from the community profile), `null` when
/// unknown or not signed in yet.
final myCountryProvider = FutureProvider.autoDispose.family<String?, String>((
  ref,
  puuid,
) async {
  try {
    return (await ref.watch(communityMeProvider(puuid).future)).country;
  } on Object {
    return null;
  }
});

/// Countries with community activity this week (`GET /v1/communities`).
final communitiesProvider = FutureProvider.autoDispose<List<CountryCommunity>>((
  ref,
) {
  final puuid = ref.watch(activeAccountProvider)?.puuid;
  return ref.watch(communityApiProvider).communities(puuid: puuid);
});
