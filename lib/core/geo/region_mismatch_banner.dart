import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../accounts/account.dart';
import '../accounts/account_providers.dart';
import '../l10n/account_labels.dart';
import '../l10n/l10n.dart';
import 'region_picker.dart';
import 'regions.dart';

/// A persisted decision per account and exact manual/detected region pair.
/// Choosing automatic trusts riot-geo, never a country or device locale hint.
class RegionMismatchBanner extends ConsumerStatefulWidget {
  const RegionMismatchBanner({super.key, required this.puuid});
  final String puuid;

  @override
  ConsumerState<RegionMismatchBanner> createState() =>
      _RegionMismatchBannerState();
}

class _RegionMismatchBannerState extends ConsumerState<RegionMismatchBanner> {
  bool _saving = false;

  Future<void> _choose(Account account, {required bool automatic}) async {
    final failure = context.l10n.settingsGeoSaveFailed;
    setState(() => _saving = true);
    try {
      await ref.read(accountsProvider.notifier).updateAccount(account.puuid, (
        current,
      ) {
        // A newly discovered pair must get its own decision.
        if (current.regionMismatchKey != account.regionMismatchKey) {
          return current;
        }
        return automatic
            ? current.copyWith(regionMode: RegionMode.auto)
            : current.copyWith(
                dismissedRegionMismatch: account.regionMismatchKey,
              );
      });
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(failure)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(accountProvider(widget.puuid));
    if (account == null || !account.showRegionMismatch || account.needsLogin) {
      return const SizedBox.shrink();
    }
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final canUseAuto = RegionTable.normalize(account.autoRegion) != null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsGeoMismatch(
                  context.l10n.riotRegionName(account.autoRegion!),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  FilledButton(
                    key: const ValueKey('region-mismatch-auto'),
                    onPressed: _saving
                        ? null
                        : canUseAuto
                        ? () => _choose(account, automatic: true)
                        : () => showRegionPicker(context, account),
                    child: Text(
                      canUseAuto
                          ? l10n.settingsGeoUseAuto
                          : l10n.settingsGeoReviewConnection,
                    ),
                  ),
                  TextButton(
                    key: const ValueKey('region-mismatch-keep'),
                    onPressed: _saving
                        ? null
                        : () => _choose(account, automatic: false),
                    child: Text(l10n.settingsGeoKeepManual),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
