/// "Trạng thái máy chủ" (docs/design/HOME.md §5.8): maintenance and incidents
/// of every region the user has an account in. Shown only when there is a
/// notice; pinned above everything when it blocks the active region. The
/// details open the "Trạng thái máy chủ" screen of the settings.
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/account_labels.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../settings/settings_routes.dart';
import '../../data/home_card.dart';
import '../../home_strings.dart';
import '../../providers/home_card_providers.dart';
import '../home_card_frame.dart';

class ServerStatusHomeCard extends ConsumerWidget {
  const ServerStatusHomeCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(homeServerStatusProvider);
    if (status == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final head = status.headline;
    final notice = head.notice;
    final region = context.l10n.riotRegionName(head.region);
    final title = notice.isMaintenance
        ? (head.isInProgress
              ? HomeStrings.statusMaintenanceNow(region)
              : HomeStrings.statusMaintenanceScheduled(region))
        : HomeStrings.statusIncident(region);
    final colors = valColorsOf(context);
    final tone = notice.isMaintenance
        ? colors.warning
        : theme.colorScheme.error;
    final more = status.notices.length - 1;
    return HomeCardFrame(
      card: HomeCardId.serverStatus,
      title: title,
      icon: notice.isMaintenance
          ? Icons.construction_outlined
          : Icons.warning_amber_rounded,
      iconColor: legibleAccent(context, tone, min: 3),
      semanticsLabel: '$title. ${notice.message ?? notice.title}',
      onTap: () => unawaited(context.push<Object?>(SettingsRoutes.status)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            notice.message ?? notice.title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.spaceBetween,
            children: [
              if (more > 0)
                Text(
                  HomeStrings.statusMore(more),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              TextButton.icon(
                onPressed: () =>
                    unawaited(context.push<Object?>(SettingsRoutes.status)),
                icon: const Icon(Icons.chevron_right),
                iconAlignment: IconAlignment.end,
                label: const Text(HomeStrings.statusDetails),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
