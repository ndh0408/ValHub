import 'dart:async';

import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/common_strings.dart';
import '../../../core/logging/session_log.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/segmented_tabs.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../providers/settings_providers.dart';
import '../settings_strings.dart';
import 'widgets/settings_widgets.dart';

/// S71 "Nhật ký phiên": newest-first list of scrubbed session events
/// (timestamps, request templates, HTTP status; never tokens, cookies or
/// PUUIDs) with "Sao chép" / "Chia sẻ" (share_plus) and "Xóa nhật ký".
/// Route `/settings/log`.
class SessionLogScreen extends ConsumerWidget {
  const SessionLogScreen({super.key});

  static String exportTextOf(SessionLog log, String? version) => log.exportText(
    header: SettingsStrings.logFileHeader(
      CommonStrings.appName,
      version ?? CommonStrings.dash,
    ),
  );

  Future<void> _copy(BuildContext context, String text) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(CommonStrings.copied)));
  }

  Future<void> _share(
    BuildContext buttonContext,
    WidgetRef ref,
    String text,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(buttonContext);
    final box = buttonContext.findRenderObject();
    final origin = box is RenderBox && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    try {
      await ref.read(textSharerProvider)(
        text,
        subject: SettingsStrings.sessionLogTitle,
        origin: origin,
      );
    } on Object {
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(SettingsStrings.logShareFailed)),
        );
    }
  }

  Future<void> _clear(BuildContext context, SessionLog log) async {
    final ok = await confirmSettingsAction(
      context,
      title: SettingsStrings.clearLog,
      message: SettingsStrings.clearLogConfirm,
      confirmLabel: CommonStrings.delete,
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    await log.clear();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(SettingsStrings.logCleared)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final log = ref.watch(sessionLogProvider);
    final version = ref.watch(packageInfoProvider).value?.version;
    return ListenableBuilder(
      listenable: log,
      builder: (context, _) {
        final entries = log.entries;
        final hasEntries = entries.isNotEmpty;
        return Scaffold(
          appBar: AppBar(
            title: const Text(SettingsStrings.sessionLogTitle),
            actions: [
              if (hasEntries)
                IconButton(
                  icon: const Icon(Icons.delete_sweep_outlined),
                  tooltip: SettingsStrings.clearLog,
                  onPressed: () => unawaited(_clear(context, log)),
                ),
            ],
          ),
          body: hasEntries
              ? _LogList(entries: entries)
              : const EmptyView(
                  message: SettingsStrings.exportLogEmpty,
                  icon: Icons.receipt_long_outlined,
                ),
          bottomNavigationBar: hasEntries
              ? SafeArea(
                  minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(48),
                          ),
                          icon: const Icon(Icons.copy_outlined),
                          label: const Text(CommonStrings.copy),
                          onPressed: () => unawaited(
                            _copy(context, exportTextOf(log, version)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Builder(
                          builder: (buttonContext) => FilledButton.icon(
                            style: FilledButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            icon: const Icon(Icons.share_outlined),
                            label: const Text(CommonStrings.share),
                            onPressed: () => unawaited(
                              _share(
                                buttonContext,
                                ref,
                                exportTextOf(log, version),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : null,
        );
      },
    );
  }
}

/// `monospace` resolves on Android; iOS needs a named face.
const _monoFallback = ['Menlo', 'Courier', 'RobotoMono'];

/// Session-log filter chips; the choice is remembered on the device
/// (`UiMemory` key `settings.log.level`).
enum SessionLogFilter {
  all,
  errors,
  http,
  auth;

  static const memoryKey = 'settings.log.level';

  String get label => switch (this) {
    all => SettingsStrings.logFilterAll,
    errors => SettingsStrings.logFilterErrors,
    http => SettingsStrings.logFilterHttp,
    auth => SettingsStrings.logFilterAuth,
  };

  bool matches(SessionLogEntry e) => switch (this) {
    all => true,
    errors => isErrorEntry(e),
    http => e.event.startsWith('http'),
    auth => _authPrefixes.any(e.event.startsWith),
  };

  static const _authPrefixes = ['reauth', 'login', 'auth', 'session'];

  /// HTTP ≥ 400 or an event named like a failure.
  static bool isErrorEntry(SessionLogEntry e) {
    final status = e.status;
    if (status != null && status >= 400) return true;
    final name = e.event.toLowerCase();
    return const [
      'fail',
      'error',
      'needslogin',
      'mismatch',
      'denied',
    ].any(name.contains);
  }
}

class _LogList extends ConsumerStatefulWidget {
  const _LogList({required this.entries});

  final List<SessionLogEntry> entries;

  @override
  ConsumerState<_LogList> createState() => _LogListState();
}

class _LogListState extends ConsumerState<_LogList> {
  late SessionLogFilter _filter = ref
      .read(uiMemoryProvider)
      .readEnum(
        SessionLogFilter.memoryKey,
        SessionLogFilter.values,
        SessionLogFilter.all,
      );

  void _setFilter(SessionLogFilter f) {
    setState(() => _filter = f);
    ref.read(uiMemoryProvider).writeEnum(SessionLogFilter.memoryKey, f);
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(clockProvider).now();
    final entries = widget.entries;
    // Newest first, with a day header whenever the local day changes.
    final rows = <Object>[];
    DateTime? day;
    for (final e in entries.reversed) {
      if (!_filter.matches(e)) continue;
      final local = e.time.toLocal();
      final d = DateTime(local.year, local.month, local.day);
      if (d != day) {
        day = d;
        rows.add(d);
      }
      rows.add(e);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _NoteBanner(count: entries.length),
        SegmentedTabs<SessionLogFilter>(
          tabs: [
            for (final f in SessionLogFilter.values)
              SegmentedTab(value: f, label: f.label),
          ],
          selected: _filter,
          onChanged: _setFilter,
        ),
        const Divider(height: 1),
        Expanded(
          child: AnimatedSwitcher(
            duration: ValMotion.fast,
            child: rows.isEmpty
                ? const EmptyView(
                    key: ValueKey('empty'),
                    message: SettingsStrings.logFilterEmpty,
                    icon: Icons.filter_alt_off_outlined,
                  )
                : ListView.builder(
                    key: ValueKey(_filter),
                    padding: const EdgeInsets.only(bottom: 24),
                    itemCount: rows.length,
                    itemBuilder: (context, i) => switch (rows[i]) {
                      final DateTime d => _DayHeader(formatDayHeader(d, now)),
                      final SessionLogEntry e => _LogRow(entry: e),
                      _ => const SizedBox.shrink(),
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _NoteBanner extends StatelessWidget {
  const _NoteBanner({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 18, color: muted),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              SettingsStrings.exportLogNote,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            SettingsStrings.logEntryCount(count),
            style: theme.textTheme.labelMedium?.copyWith(color: muted),
          ),
        ],
      ),
    );
  }
}

class _DayHeader extends StatelessWidget {
  const _DayHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          letterSpacing: 1.1,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry});

  final SessionLogEntry entry;

  static String _clock(DateTime t) {
    final l = t.toLocal();
    return '${formatTime(l)}:${l.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    const mono = TextStyle(
      fontFamily: 'monospace',
      fontFamilyFallback: _monoFallback,
      fontSize: 12,
      height: 1.3,
    );
    final target = entry.target;
    final detail = entry.detail;
    final colors = valColorsOf(context);
    final level = SessionLogFilter.isErrorEntry(entry)
        ? colors.loss
        : (entry.status != null && entry.status! < 300)
        ? colors.win
        : colors.track;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 3, 12, 3),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(10),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ColoredBox(color: level, child: const SizedBox(width: 3)),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: _body(theme, muted, mono, target, detail),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(
    ThemeData theme,
    Color muted,
    TextStyle mono,
    String? target,
    String? detail,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(_clock(entry.time), style: mono.copyWith(color: muted)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                entry.event,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge,
              ),
            ),
            if (entry.ms != null) ...[
              Text(
                '${formatNumber(entry.ms!)} ms',
                style: mono.copyWith(color: muted),
              ),
              const SizedBox(width: 8),
            ],
            if (entry.status != null) _StatusChip(entry.status!),
          ],
        ),
        if (target != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              target,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: mono,
            ),
          ),
        if (detail != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              detail,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: mono.copyWith(color: muted),
            ),
          ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip(this.status);

  final int status;

  @override
  Widget build(BuildContext context) {
    final colors = valColorsOf(context);
    final color = switch (status) {
      >= 200 && < 300 => colors.win,
      >= 500 => colors.loss,
      >= 400 => colors.warning,
      _ => colors.muted,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$status',
        style: TextStyle(
          fontFamily: 'monospace',
          fontFamilyFallback: _monoFallback,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
