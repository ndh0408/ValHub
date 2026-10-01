import 'package:dio/dio.dart' show CancelToken;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../accounts/account.dart';
import '../accounts/account_providers.dart';
import '../auth/auth_providers.dart';
import '../l10n/account_strings.dart';
import '../l10n/l10n.dart';
import '../network/riot_exception.dart';
import '../riot/pvp_api.dart';
import '../ui/error_view.dart';
import 'country_picker.dart';
import 'regions.dart';

Future<void> showRegionPicker(BuildContext context, Account account) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => RegionPicker(account: account),
    );

class RegionPicker extends ConsumerStatefulWidget {
  const RegionPicker({super.key, required this.account});
  final Account account;
  @override
  ConsumerState<RegionPicker> createState() => _RegionPickerState();
}

class _RegionPickerState extends ConsumerState<RegionPicker> {
  late RegionMode _mode = widget.account.regionMode;
  late String? _region = RegionTable.normalize(widget.account.region);
  String? _country;
  bool _busy = false;
  String? _error;
  CancelToken? _cancel;
  @override
  void dispose() {
    _cancel?.cancel();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final id = widget.account.puuid;
    final account = ref.read(accountProvider(id)) ?? widget.account;
    final candidate = _mode == RegionMode.auto
        ? RegionTable.normalize(account.autoRegion)
        : _region;
    if (candidate == null) {
      setState(() => _error = l10n.settingsGeoNoRegion);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final cancel = CancelToken();
    _cancel = cancel;
    try {
      if (_mode == RegionMode.manual &&
          account.autoRegion != null &&
          candidate != account.autoRegion) {
        final confirmed = await _confirm(
          l10n.settingsGeoManualConfirm(
            AccountStrings.regionName(candidate),
            AccountStrings.regionName(account.autoRegion!),
          ),
        );
        if (!confirmed || !mounted) return;
      }
      RegionValidation valid;
      try {
        valid = await ref
            .read(pvpApiProvider)
            .validateRegion(id, candidate, cancelToken: cancel);
      } on TransientException catch (e) {
        if (cancel.isCancelled || e.reason == 'tls') rethrow;
        valid = RegionValidation.unverified;
      }
      if (!mounted) return;
      if (valid == RegionValidation.rejected) {
        setState(() => _error = l10n.settingsGeoValidationFailed);
        return;
      }
      if (valid == RegionValidation.unverified) {
        final confirmed = await _confirm(l10n.settingsGeoUnverified);
        if (!confirmed || !mounted) return;
      }
      if (ref.read(accountProvider(id)) == null) return;
      await ref
          .read(accountsProvider.notifier)
          .updateAccount(
            id,
            (a) => a.copyWith(
              regionMode: _mode,
              manualRegion: _mode == RegionMode.manual ? candidate : null,
              dismissedRegionMismatch:
                  _mode == RegionMode.manual && account.autoRegion != null
                  ? '$candidate/${account.autoRegion!}'
                  : null,
            ),
          );
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.settingsGeoConnectionSaved)),
      );
    } on Object catch (e) {
      if (mounted && !cancel.isCancelled) {
        setState(() => _error = describeError(e).message);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<bool> _confirm(String message) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(context.l10n.settingsGeoConnection),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.l10n.settingsGeoCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(context.l10n.settingsGeoContinue),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _refreshRegion() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref
          .read(sessionManagerProvider)
          .refreshRegion(widget.account.puuid);
      if (mounted) ref.read(accountsProvider.notifier).reload();
    } on Object catch (e) {
      if (mounted) setState(() => _error = describeError(e).message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final account =
        ref.watch(accountProvider(widget.account.puuid)) ?? widget.account;
    final detected = RegionTable.normalize(account.autoRegion);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(
          20,
          24,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.settingsGeoConnection,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SegmentedButton<RegionMode>(
              segments: [
                ButtonSegment(
                  value: RegionMode.auto,
                  label: Text(l10n.settingsGeoAuto),
                ),
                ButtonSegment(
                  value: RegionMode.manual,
                  label: Text(l10n.settingsGeoManual),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: _busy
                  ? null
                  : (v) => setState(() => _mode = v.single),
            ),
            const SizedBox(height: 16),
            if (account.detectedAt != null)
              Text(
                l10n.settingsGeoCheckedAt(
                  context.fmt.dateTime(account.detectedAt!),
                ),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _busy ? null : _refreshRegion,
                icon: const Icon(Icons.refresh),
                label: Text(l10n.settingsGeoCheckAgain),
              ),
            ),
            if (_mode == RegionMode.auto)
              Text(
                detected == null
                    ? l10n.settingsGeoNoRegion
                    : AccountStrings.regionName(detected),
              )
            else ...[
              Text(l10n.settingsGeoManualWarning),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                key: ValueKey(_region),
                initialValue: _region,
                isExpanded: true,
                isDense: false,
                itemHeight: null,
                decoration: InputDecoration(
                  labelText: l10n.settingsGeoChooseRegion,
                ),
                items: [
                  for (final r in RegionTable.visibleRegions)
                    DropdownMenuItem(
                      value: r,
                      child: Text(
                        AccountStrings.regionName(r),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: _busy ? null : (v) => setState(() => _region = v),
              ),
            ],
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsGeoCountry),
              subtitle: Text(_country ?? l10n.settingsGeoHintOnly),
              trailing: const Icon(Icons.public),
              onTap: _busy
                  ? null
                  : () async {
                      final country = await showCountryPicker(context);
                      if (mounted && country != null) {
                        setState(() {
                          _country = country.code;
                          // A hint preselects only; saving still needs validation.
                          if (_mode == RegionMode.manual &&
                              country.regionHint != null) {
                            _region = country.regionHint;
                          }
                        });
                      }
                    },
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  _error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            FilledButton(
              onPressed: _busy ? null : _save,
              child: Text(
                _busy ? l10n.settingsGeoLoading : l10n.settingsGeoSave,
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.settingsGeoCancel),
            ),
          ],
        ),
      ),
    );
  }
}
