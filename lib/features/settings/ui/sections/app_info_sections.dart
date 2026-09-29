import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/l10n/common_strings.dart';
import '../../../../core/riot/platform_status.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/skeleton.dart';
import '../../data/cache_stats.dart';
import '../../providers/settings_providers.dart';
import '../../settings_routes.dart';
import '../../settings_strings.dart';
import '../widgets/settings_widgets.dart';

/// Opens [uri] outside the app; a snackbar reports failures.
Future<void> openSettingsLink(
  BuildContext context,
  WidgetRef ref,
  Uri uri,
) async {
  final messenger = ScaffoldMessenger.maybeOf(context);
  final ok = await ref.read(externalUrlOpenerProvider)(uri);
  if (!ok) {
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(SettingsStrings.linkOpenFailed)),
      );
  }
}

/// "HỖ TRỢ": server status of the active account's region (with a colored
/// dot while Riot reports a maintenance or an incident), the session log
/// and feedback.
class SettingsSupportSection extends ConsumerWidget {
  const SettingsSupportSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsGroup(
      title: SettingsStrings.supportHeader,
      children: [
        ListTile(
          leading: const SettingsIcon(Icons.dns_outlined),
          title: const Text(SettingsStrings.serverStatus),
          subtitle: const Text(SettingsStrings.serverStatusSubtitle),
          trailing: const _ServerStatusValue(),
          onTap: () => unawaited(context.push(SettingsRoutes.status)),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.receipt_long_outlined),
          title: const Text(SettingsStrings.exportLog),
          subtitle: const Text(SettingsStrings.exportLogSubtitle),
          trailing: const SettingsChevron(),
          onTap: () => unawaited(context.push(SettingsRoutes.log)),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.forum_outlined),
          title: const Text(SettingsStrings.feedback),
          subtitle: const Text(SettingsStrings.feedbackSubtitle),
          trailing: const SettingsChevron(icon: Icons.open_in_new),
          onTap: () =>
              unawaited(openSettingsLink(context, ref, SettingsLinks.feedback)),
        ),
      ],
    );
  }
}

/// "● Đang bảo trì" / "● 2 thông báo" from the (cached) X-1 status of the
/// active region; only a chevron while nothing is reported (a failed
/// download never claims that everything is fine).
class _ServerStatusValue extends ConsumerWidget {
  const _ServerStatusValue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(activeAccountProvider.select((a) => a?.region));
    final status = region == null
        ? null
        : ref.watch(platformStatusProvider(region)).value;
    final colors = valColorsOf(context);
    final scheme = Theme.of(context).colorScheme;
    final (String, Color)? badge;
    if (status == null || status.isEmpty) {
      badge = null;
    } else if (status.activeMaintenances.isNotEmpty) {
      badge = (SettingsStrings.serverStatusMaintenance, colors.warning);
    } else {
      final count = status.maintenances.length + status.incidents.length;
      final critical = status.incidents.any((i) => i.severity == 'critical');
      badge = (
        SettingsStrings.serverStatusNotices(count),
        critical ? scheme.error : colors.warning,
      );
    }
    if (badge == null) return const SettingsChevron();
    final (label, color) = badge;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 150),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: legibleAccent(context, color),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 2),
          const SettingsChevron(),
        ],
      ),
    );
  }
}

/// "ỨNG DỤNG" (S70, X2): version and clear cache (with its size).
class SettingsAppSection extends ConsumerStatefulWidget {
  const SettingsAppSection({super.key});

  @override
  ConsumerState<SettingsAppSection> createState() => _SettingsAppSectionState();
}

class _SettingsAppSectionState extends ConsumerState<SettingsAppSection> {
  bool _clearing = false;

  Future<void> _clearCache() async {
    setState(() => _clearing = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    String message;
    try {
      final freed = await ref.read(cacheServiceProvider).clear();
      message = SettingsStrings.cacheCleared(formatBytes(freed));
    } on Object {
      message = SettingsStrings.clearCacheFailed;
    }
    if (!mounted) return;
    ref.invalidate(cacheSizeBytesProvider);
    setState(() => _clearing = false);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final packageInfo = ref.watch(packageInfoProvider);
    final cacheSize = ref.watch(cacheSizeBytesProvider);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return SettingsGroup(
      title: SettingsStrings.appHeader,
      children: [
        ListTile(
          leading: const SettingsIcon(Icons.info_outline),
          title: switch (packageInfo) {
            AsyncData(:final value) => Text(
              SettingsStrings.version(value.version),
            ),
            AsyncError() => Text(SettingsStrings.version(CommonStrings.dash)),
            _ => const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Skeleton(width: 120, height: 14),
            ),
          },
          subtitle: switch (packageInfo) {
            AsyncData(:final value) when value.buildNumber.isNotEmpty => Text(
              SettingsStrings.buildNumber(value.buildNumber),
            ),
            _ => null,
          },
        ),
        ListTile(
          leading: const SettingsIcon(Icons.cleaning_services_outlined),
          title: const Text(SettingsStrings.clearCache),
          subtitle: const Text(SettingsStrings.clearCacheSubtitle),
          enabled: !_clearing,
          trailing: _clearing
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : switch (cacheSize) {
                  AsyncData(:final value) => Text(
                    formatBytes(value),
                    style: TextStyle(color: muted),
                  ),
                  AsyncError() => Text(
                    CommonStrings.dash,
                    style: TextStyle(color: muted),
                  ),
                  _ => const Skeleton(width: 48, height: 14),
                },
          onTap: _clearing ? null : () => unawaited(_clearCache()),
        ),
      ],
    );
  }
}

/// "THÔNG TIN": the single "Giới thiệu & pháp lý" row that closes the
/// settings (docs/design/IA.md "Pháp lý"); every legal document, the
/// licences of third-party libraries, contact and the copyright line live in
/// that hub (S72).
class SettingsAboutSection extends StatelessWidget {
  const SettingsAboutSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsGroup(
      title: SettingsStrings.aboutHeader,
      children: [
        ListTile(
          leading: const SettingsIcon(Icons.shield_outlined),
          title: const Text(SettingsStrings.aboutTitle),
          subtitle: const Text(SettingsStrings.aboutRowSubtitle),
          trailing: const SettingsChevron(),
          onTap: () => unawaited(context.push(SettingsRoutes.about)),
        ),
      ],
    );
  }
}
