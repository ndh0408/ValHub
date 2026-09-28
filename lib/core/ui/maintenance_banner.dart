import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../accounts/account_providers.dart';
import '../l10n/common_strings.dart';
import '../riot/platform_status.dart';
import '../theme/app_theme.dart';

/// Maintenance / incident banner from the public status JSON (X-1), using
/// the `vi_VN` title. Renders nothing when there is no notice.
class MaintenanceBanner extends ConsumerWidget {
  const MaintenanceBanner({super.key, this.region});

  /// Region to check; defaults to the active account's region.
  final String? region;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r =
        region ?? ref.watch(activeAccountProvider.select((a) => a?.region));
    if (r == null) return const SizedBox.shrink();
    final notice = ref.watch(platformStatusProvider(r)).value?.headline;
    if (notice == null) return const SizedBox.shrink();
    final colors = valColorsOf(context);
    final color = notice.isMaintenance
        ? colors.warning
        : Theme.of(context).colorScheme.error;
    return Material(
      color: color.withValues(alpha: 0.14),
      child: ListTile(
        dense: true,
        leading: Icon(
          notice.isMaintenance
              ? Icons.construction_outlined
              : Icons.warning_amber_outlined,
          color: color,
        ),
        title: Text(
          notice.isMaintenance
              ? CommonStrings.maintenanceTitle
              : CommonStrings.incidentTitle,
          style: TextStyle(color: color, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          notice.message ?? notice.title,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
