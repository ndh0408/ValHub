import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/filter_bar.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/util/format.dart';
import '../../../wishlist/data/vi_search.dart';
import '../../community_strings.dart';
import '../../data/community_models.dart';
import '../../providers/scope_providers.dart';
import '../widgets/community_widgets.dart';

/// Countries shown by the picker: [active] communities (server order: most
/// posts first) with the viewer's own country pinned first, even when it
/// has no activity yet. Filtered by an accent-folding search over the
/// localized name and the ISO code.
List<CountryCommunity> filterCountries(
  List<CountryCommunity> active, {
  String? myCountry,
  String query = '',
}) {
  final all = [...active];
  if (myCountry != null && !all.any((c) => c.country == myCountry)) {
    all.add(CountryCommunity(country: myCountry));
  }
  if (myCountry != null) {
    all.sort((a, b) {
      if (a.country == myCountry) return -1;
      if (b.country == myCountry) return 1;
      return 0;
    });
  }
  final tokens = searchTokens(query);
  if (tokens.isEmpty) return all;
  return [
    for (final c in all)
      if (matchesTokens(
        foldForSearch(
          '${CommunityStrings.countryName(c.country)} ${c.country}',
        ),
        tokens,
      ))
        c,
  ];
}

/// Opens "Cộng đồng các nước"; resolves to the picked alpha-2 country.
Future<String?> showCountriesSheet(
  BuildContext context, {
  String? myCountry,
  String? selected,
}) => showModalBottomSheet<String>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) => CountriesSheet(myCountry: myCountry, selected: selected),
);

/// Searchable list of the countries with community activity (flag, name,
/// this week's posts / authors / LFG posts).
class CountriesSheet extends ConsumerStatefulWidget {
  const CountriesSheet({super.key, this.myCountry, this.selected});

  final String? myCountry;
  final String? selected;

  @override
  ConsumerState<CountriesSheet> createState() => _CountriesSheetState();
}

class _CountriesSheetState extends ConsumerState<CountriesSheet> {
  final _search = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(communitiesProvider);
    final height = MediaQuery.sizeOf(context).height * 0.85;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SizedBox(
        height: height,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Text(
                CommunityStrings.countriesTitle,
                style: theme.textTheme.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: GlassSearchField(
                controller: _search,
                hintText: CommunityStrings.countriesSearchHint,
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: async.when(
                loading: () => SkeletonColumn(
                  count: 6,
                  spacing: 8,
                  item: (_) => const _CountryRowSkeleton(),
                ),
                error: (e, _) => CommunityErrorState(
                  error: e,
                  onRetry: () => ref.invalidate(communitiesProvider),
                ),
                data: (active) {
                  final rows = filterCountries(
                    active,
                    myCountry: widget.myCountry,
                    query: _query,
                  );
                  if (rows.isEmpty) {
                    return Center(
                      child: Text(
                        CommunityStrings.countriesEmpty,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
                    itemCount: rows.length,
                    itemBuilder: (context, i) => _CountryRow(
                      key: ValueKey('country-${rows[i].country}'),
                      community: rows[i],
                      isMine: rows[i].country == widget.myCountry,
                      selected: rows[i].country == widget.selected,
                      onTap: () => Navigator.of(context).pop(rows[i].country),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow({
    super.key,
    required this.community,
    required this.isMine,
    required this.selected,
    required this.onTap,
  });

  final CountryCommunity community;
  final bool isMine;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final c = community;
    final parts = <String>[
      if (c.posts > 0 || c.authors > 0)
        CommunityStrings.communityActivity(
          formatNumber(c.posts),
          formatNumber(c.authors),
        ),
      if (c.lfg > 0) CommunityStrings.communityLfg(formatNumber(c.lfg)),
      if (isMine) CommunityStrings.yourCountry,
    ];
    return ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Text(
        flagEmoji(c.country),
        style: const TextStyle(fontSize: 28),
        semanticsLabel: '',
      ),
      title: Text(
        CommunityStrings.countryName(c.country),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      subtitle: parts.isEmpty
          ? null
          : Text(
              CommunityStrings.dotJoin(parts),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
      trailing: selected
          ? Icon(Icons.check_rounded, color: theme.colorScheme.primary)
          : null,
      onTap: onTap,
    );
  }
}

class _CountryRowSkeleton extends StatelessWidget {
  const _CountryRowSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: [
          Skeleton(width: 36, height: 28, radius: 6, shimmer: false),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 140, height: 14, shimmer: false),
                SizedBox(height: 6),
                Skeleton(width: 90, height: 10, shimmer: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
