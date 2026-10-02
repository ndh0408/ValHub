import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/domain/competitive/names.dart';
import '../../../../core/logging/session_log.dart';
import '../../../../core/riot/platform_status.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/util/clock.dart';
import '../../data/bug_report.dart';
import '../../data/cache_stats.dart';
import '../../providers/settings_providers.dart';
import '../../settings_routes.dart';
import '../../settings_strings.dart';
import '../widgets/settings_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Opens [uri] outside the app; a snackbar reports failures.
Future<void> openSettingsLink(
  BuildContext context,
  WidgetRef ref,
  Uri uri,
) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final ok = await ref.read(externalUrlOpenerProvider)(uri);
  if (!ok) {
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.settingsLinkOpenFailed)));
  }
}

/// "HỖ TRỢ": server status of the active account's region (with a colored
/// dot while Riot reports a maintenance or an incident) and feedback.
class SettingsSupportSection extends ConsumerWidget {
  const SettingsSupportSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SettingsGroup(
      title: context.l10n.settingsSupportHeader,
      children: [
        ListTile(
          leading: const SettingsIcon(Icons.dns_outlined),
          title: Text(context.l10n.settingsServerStatus),
          subtitle: Text(context.l10n.settingsServerStatusSubtitle),
          trailing: const _ServerStatusValue(),
          onTap: () => unawaited(context.push(SettingsRoutes.status)),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.forum_outlined),
          title: Text(context.l10n.settingsFeedback),
          subtitle: Text(context.l10n.settingsFeedbackSubtitle),
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
      badge = (context.l10n.settingsServerStatusMaintenance, colors.warning);
    } else {
      final count = status.maintenances.length + status.incidents.length;
      final critical = status.incidents.any((i) => i.severity == 'critical');
      badge = (
        context.l10n.settingsServerStatusNotices(count),
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

/// "NÂNG CAO" (S70, X2): the only two actions a player may ever need that
/// are not about the game: send a bug report to ValHub (a scrubbed file handed
/// to the share sheet, never shown on screen) and clear temporary data (with
/// its size). The app version lives on the About screen only.
class SettingsAppSection extends ConsumerStatefulWidget {
  const SettingsAppSection({super.key});

  @override
  ConsumerState<SettingsAppSection> createState() => _SettingsAppSectionState();
}

class _SettingsAppSectionState extends ConsumerState<SettingsAppSection> {
  bool _clearing = false;

  void _snack(String message) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendReport(BuildContext rowContext) async {
    final l10n = rowContext.l10n;
    final log = ref.read(sessionLogProvider);
    if (log.entries.isEmpty) {
      _snack(rowContext.l10n.settingsExportLogEmpty);
      return;
    }
    final box = rowContext.findRenderObject();
    final origin = box is RenderBox && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    String? version;
    try {
      version = (await ref.read(packageInfoProvider.future)).version;
    } on Object {
      // A report can still be shared when app information is unavailable.
    }
    if (!mounted) return;
    final report = buildBugReport(
      log,
      now: ref.read(clockProvider).now(),
      version: version,
    );
    try {
      await ref.read(bugReportSharerProvider)(report, origin: origin);
    } on Object {
      if (mounted) _snack(l10n.settingsLogShareFailed);
    }
  }

  /// Clears the image / offline-response caches and the recorded bug-report
  /// data; sign-in, wishlist and settings are never touched.
  Future<void> _clearCache() async {
    final l10n = context.l10n;
    setState(() => _clearing = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    String message;
    try {
      final freed = await ref.read(cacheServiceProvider).clear();
      await ref.read(nameResolverProvider).clear();
      await ref.read(sessionLogProvider).clear();
      message = l10n.settingsCacheCleared(formatBytes(freed));
    } on Object {
      message = l10n.settingsClearCacheFailed;
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
    final cacheSize = ref.watch(cacheSizeBytesProvider);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return SettingsGroup(
      title: context.l10n.settingsAppHeader,
      children: [
        Builder(
          builder: (rowContext) => ListTile(
            leading: const SettingsIcon(Icons.bug_report_outlined),
            title: Text(rowContext.l10n.settingsExportLog),
            subtitle: Text(rowContext.l10n.settingsExportLogSubtitle),
            trailing: const SettingsChevron(icon: Icons.ios_share),
            onTap: () => unawaited(_sendReport(rowContext)),
          ),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.cleaning_services_outlined),
          title: Text(context.l10n.settingsClearCache),
          subtitle: Text(context.l10n.settingsClearCacheSubtitle),
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
                    context.l10n.commonDash,
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
      title: context.l10n.settingsAboutHeader,
      children: [
        ListTile(
          leading: const SettingsIcon(Icons.shield_outlined),
          title: Text(context.l10n.settingsAboutTitle),
          subtitle: Text(context.l10n.settingsAboutRowSubtitle),
          trailing: const SettingsChevron(),
          onTap: () => unawaited(context.push(SettingsRoutes.about)),
        ),
      ],
    );
  }
}
