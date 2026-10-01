import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../accounts/account_providers.dart';
import '../l10n/l10n.dart';
import '../storage/prefs.dart';
import '../util/format.dart';
import 'countries.dart';
import 'country_preference.dart';
import 'country_search.dart';
import 'regions.dart';

/// Both entry points share presentation. Short windows get a full page so
/// keyboard/header content can scroll without squeezing a nested sheet.
Future<T?> showCountrySelection<T>(
  BuildContext context, {
  required Widget Function(BuildContext, bool fullHeight) builder,
}) {
  if (MediaQuery.sizeOf(context).height < 480) {
    return Navigator.of(context, rootNavigator: true).push<T>(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(),
          body: SafeArea(child: builder(context, true)),
        ),
      ),
    );
  }
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    constraints: const BoxConstraints(maxWidth: 720),
    builder: (context) => builder(context, false),
  );
}

Future<CountryInfo?> showCountryPicker(BuildContext context) =>
    showCountrySelection<CountryInfo>(
      context,
      builder: (_, fullHeight) => CountryPicker(fullHeight: fullHeight),
    );

/// Public weekly activity, supplied by the Community adapter. No identity,
/// account country, or network authentication is inferred from these counts.
class CountryActivity {
  const CountryActivity({
    required this.code,
    this.posts = 0,
    this.authors = 0,
    this.lfg = 0,
  });
  final String code;
  final int posts;
  final int authors;
  final int lfg;
}

class CountryPicker extends ConsumerStatefulWidget {
  const CountryPicker({super.key, this.fullHeight = false})
    : activity = null,
      myCountry = null,
      selectedCountry = null,
      onRetryActivity = null;

  const CountryPicker.community({
    super.key,
    required this.activity,
    required this.onRetryActivity,
    this.myCountry,
    this.selectedCountry,
    this.fullHeight = false,
  });

  final bool fullHeight;
  final AsyncValue<List<CountryActivity>>? activity;
  final String? myCountry;
  final String? selectedCountry;
  final VoidCallback? onRetryActivity;

  @override
  ConsumerState<CountryPicker> createState() => _CountryPickerState();
}

class _CountryPickerState extends ConsumerState<CountryPicker> {
  final _search = TextEditingController();
  String _query = '';
  String? _region;
  bool _activeOnly = true;
  late bool _supportedOnly;
  bool get _community => widget.activity != null;

  @override
  void initState() {
    super.initState();
    _supportedOnly =
        !_community &&
        (ref.read(prefsProvider).getBool('geo.supportedOnly') ?? true);
    _search.addListener(_commitSearch);
  }

  void _commitSearch() {
    final value = _search.value;
    if (value.composing.isValid && !value.composing.isCollapsed) return;
    if (_query != value.text) setState(() => _query = value.text);
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _setSupportedOnly(bool value) async {
    setState(() => _supportedOnly = value);
    try {
      await ref.read(prefsProvider).setBool('geo.supportedOnly', value);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          SnackBar(content: Text(context.l10n.settingsGeoSaveFailed)),
        );
      }
    }
  }

  void _clearFilters() {
    _search.clear();
    setState(() {
      _region = null;
      _activeOnly = false;
    });
    if (!_community) unawaited(_setSupportedOnly(false));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final countries = ref.watch(countriesProvider);
    final names = ref.watch(countryNamesProvider);
    final data = countries.value;
    final labels = names.value;
    final activity = {
      for (final row in widget.activity?.value ?? const <CountryActivity>[])
        row.code: row,
    };
    final pinned = _community
        ? <String>{?normalizeCountry(widget.myCountry)}
        : <String>{
            ?ref.watch(countryPreferenceProvider),
            ?normalizeCountry(ref.watch(activeAccountProvider)?.country),
            ?normalizeCountry(ref.watch(deviceCountryProvider)),
          };
    List<String> search(Iterable<String> codes) =>
        data == null || labels == null
        ? []
        : searchCountryCodes(
            codes,
            countries: data,
            names: labels,
            query: _query,
            isoOnly: _community,
          );
    final suggestions = search(pinned);
    final candidates = _community && _activeOnly
        ? activity.keys
        : labels?.order ?? const <String>[];
    final codes = search(
      candidates.where((code) {
        if (suggestions.contains(code)) return false;
        final country = data?[code];
        return country != null &&
            (_community || !_supportedOnly || country.isSupported) &&
            (_community || _region == null || country.regionHint == _region);
      }),
    );
    final activityPending =
        _community &&
        _activeOnly &&
        widget.activity!.isLoading &&
        !widget.activity!.hasValue;
    final activityFailed =
        _community && _activeOnly && widget.activity!.hasError;
    return FractionallySizedBox(
      heightFactor: widget.fullHeight ? 1 : 0.85,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: CustomScrollView(
          key: const ValueKey('country-picker-scroll'),
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
                      _community
                          ? l10n.communityCountriesTitle
                          : l10n.settingsGeoCountry,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _search,
                      decoration: InputDecoration(
                        labelText: l10n.settingsGeoSearchCountry,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  if (_community)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Wrap(
                        spacing: 8,
                        children: [
                          ChoiceChip(
                            key: const ValueKey('country-active'),
                            label: Text(l10n.settingsGeoActiveCountries),
                            selected: _activeOnly,
                            onSelected: (_) =>
                                setState(() => _activeOnly = true),
                          ),
                          ChoiceChip(
                            key: const ValueKey('country-all'),
                            label: Text(l10n.settingsGeoAllCountries),
                            selected: !_activeOnly,
                            onSelected: (_) =>
                                setState(() => _activeOnly = false),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    SwitchListTile(
                      title: Text(l10n.settingsGeoSupportedOnly),
                      value: _supportedOnly,
                      onChanged: _setSupportedOnly,
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
                              onSelected: (_) =>
                                  setState(() => _region = region),
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
                  if (data != null && labels != null && !activityPending)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: _ResultCount(
                        count: suggestions.length + codes.length,
                      ),
                    ),
                ],
              ),
            ),
            if (countries.hasError || names.hasError)
              SliverToBoxAdapter(
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
              const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              if (suggestions.isNotEmpty && !_community)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(l10n.settingsGeoSuggestions),
                  ),
                ),
              SliverList.builder(
                itemCount: suggestions.length,
                itemBuilder: (_, i) => _CountryRow(
                  country: data[suggestions[i]]!,
                  names: labels,
                  community: _community,
                  activity: activity[suggestions[i]],
                  isMine: suggestions[i] == widget.myCountry,
                  selected: suggestions[i] == widget.selectedCountry,
                ),
              ),
              if (activityPending)
                const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (activityFailed)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(l10n.settingsGeoActivityUnavailable),
                        TextButton(
                          onPressed: widget.onRetryActivity,
                          child: Text(l10n.commonRetry),
                        ),
                      ],
                    ),
                  ),
                )
              else if (codes.isEmpty && suggestions.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Text(l10n.settingsGeoNoCountries),
                        TextButton(
                          onPressed: _clearFilters,
                          child: Text(l10n.commonClearFilters),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList.builder(
                  itemCount: codes.length,
                  itemBuilder: (_, i) => _CountryRow(
                    country: data[codes[i]]!,
                    names: labels,
                    community: _community,
                    activity: activity[codes[i]],
                    isMine: false,
                    selected: codes[i] == widget.selectedCountry,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _CountryRow extends StatelessWidget {
  const _CountryRow({
    required this.country,
    required this.names,
    required this.community,
    this.activity,
    this.isMine = false,
    this.selected = false,
  });
  final CountryInfo country;
  final CountryNames names;
  final bool community;
  final CountryActivity? activity;
  final bool isMine;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
    final a = activity;
    final parts = <String>[
      if (a != null && (a.posts > 0 || a.authors > 0))
        l10n.communityCommunityActivity(
          formatNumber(a.posts),
          formatNumber(a.authors),
        ),
      if (a != null && a.lfg > 0)
        l10n.communityCommunityLfg(formatNumber(a.lfg)),
      if (isMine) l10n.communityYourCountry,
    ];
    return ListTile(
      key: ValueKey(community ? 'country-${country.code}' : country.code),
      selected: selected,
      leading: ExcludeSemantics(
        child: Text(
          countryFlag(country.code),
          style: const TextStyle(fontSize: 24),
        ),
      ),
      title: Text(names.name(country.code)),
      subtitle: community
          ? (parts.isEmpty ? null : Text(parts.join(' · ')))
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ExcludeSemantics(child: Icon(icon, size: 18)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '$status${country.regionHint == null ? '' : ' · ${country.regionHint!.toUpperCase()}'}',
                  ),
                ),
              ],
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(country.code, textDirection: TextDirection.ltr),
          if (selected) ...[
            const SizedBox(width: 8),
            const Icon(Icons.check_rounded),
          ],
        ],
      ),
      onTap: () => community
          ? Navigator.pop(context, country.code)
          : Navigator.pop(context, country),
    );
  }
}

/// Keep visual counts current, but debounce live-region announcements during
/// typing. Locale changes render the message afresh rather than capture text.
class _ResultCount extends StatefulWidget {
  const _ResultCount({required this.count});
  final int count;
  @override
  State<_ResultCount> createState() => _ResultCountState();
}

class _ResultCountState extends State<_ResultCount> {
  late int _announced = widget.count;
  Timer? _timer;
  @override
  void didUpdateWidget(_ResultCount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.count == widget.count) return;
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _announced = widget.count);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: context.l10n.settingsGeoResultCount(_announced),
    excludeSemantics: true,
    child: Text(context.l10n.settingsGeoResultCount(widget.count)),
  );
}
