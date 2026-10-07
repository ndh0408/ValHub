import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/domain/competitive/names.dart';
import '../../../../core/domain/competitive/rank.dart';
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
/// dot while Riot reports a maintenance or an incident), feedback, the bug
/// report for ValHub, and "Giới thiệu & pháp lý" (every legal document,
/// licences, contact) closing the settings.
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
        const _BugReportRow(),
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

/// "Gửi báo lỗi cho ValHub": a scrubbed file handed to the share sheet,
/// never shown on screen.
class _BugReportRow extends ConsumerStatefulWidget {
  const _BugReportRow();

  @override
  ConsumerState<_BugReportRow> createState() => _BugReportRowState();
}

class _BugReportRowState extends ConsumerState<_BugReportRow> {
  void _snack(String message) {
    ScaffoldMessenger.maybeOf(context)
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _sendReport() async {
    final l10n = context.l10n;
    final log = ref.read(sessionLogProvider);
    if (log.entries.isEmpty) {
      _snack(l10n.settingsExportLogEmpty);
      return;
    }
    final box = context.findRenderObject();
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
      messages: l10n,
    );
    try {
      await ref.read(bugReportSharerProvider)(report, origin: origin);
    } on Object {
      if (mounted) _snack(l10n.settingsLogShareFailed);
    }
  }

  @override
  Widget build(BuildContext context) => ListTile(
    leading: const SettingsIcon(Icons.bug_report_outlined),
    title: Text(context.l10n.settingsExportLog),
    subtitle: Text(context.l10n.settingsExportLogSubtitle),
    trailing: const SettingsChevron(icon: Icons.ios_share),
    onTap: () => unawaited(_sendReport()),
  );
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

/// "DỮ LIỆU TRÊN MÁY" (S70, X2): every clean-up in one place, from the
/// lightest to the widest: temporary data (with its size), the RR history
/// of the active account, then everything this device recorded (sign-ins,
/// wishlists and settings stay).
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

  Future<void> _clearRrHistory(String puuid) async {
    final l10n = context.l10n;
    final ok = await confirmSettingsAction(
      context,
      title: l10n.accountClearRrHistory,
      message: l10n.accountClearRrHistoryConfirm,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(deleteRrHistoryProvider(puuid))();
    if (mounted) _snack(l10n.accountRrHistoryCleared);
  }

  Future<void> _clearLocalData() async {
    final l10n = context.l10n;
    final ok = await confirmSettingsAction(
      context,
      title: l10n.accountClearLocalData,
      message: l10n.accountClearLocalDataConfirm,
      confirmLabel: l10n.commonDelete,
      destructive: true,
    );
    if (!ok || !mounted) return;
    await ref.read(accountsProvider.notifier).clearLocalData();
    if (mounted) _snack(l10n.accountLocalDataCleared);
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
    final active = ref.watch(activePuuidProvider);
    final hasAccounts = ref.watch(accountsProvider).isNotEmpty;
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return SettingsGroup(
      title: context.l10n.settingsDataHeader,
      children: [
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
        if (active != null)
          ListTile(
            leading: const SettingsIcon(Icons.history_outlined),
            title: Text(context.l10n.accountClearRrHistory),
            subtitle: Text(context.l10n.accountClearRrHistorySubtitle),
            onTap: () => unawaited(_clearRrHistory(active)),
          ),
        if (hasAccounts)
          ListTile(
            leading: const SettingsIcon(Icons.delete_sweep_outlined),
            title: Text(context.l10n.accountClearLocalData),
            subtitle: Text(context.l10n.accountClearLocalDataSubtitle),
            onTap: () => unawaited(_clearLocalData()),
          ),
      ],
    );
  }
}
