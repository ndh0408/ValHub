import 'dart:async';

import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/common_strings.dart';
import '../../../core/logging/session_log.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/filter_bar.dart';
import '../../../core/ui/segmented_tabs.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../../../core/util/search_text.dart';
import '../providers/settings_providers.dart';
import '../settings_strings.dart';
import 'widgets/settings_widgets.dart';

/// S71 "Nhật ký phiên": newest-first list of scrubbed session events
/// (timestamps, request templates, HTTP status; never tokens, cookies or
/// PUUIDs) on the shared sub-page chrome, with a pinned search field and
/// level filter (remembered), "Sao chép" / "Chia sẻ" (share_plus) at the
/// bottom and "Xóa nhật ký" (with confirmation) in the bar. Tapping a row
/// copies that line. Route `/settings/log`.
class SessionLogScreen extends ConsumerStatefulWidget {
  const SessionLogScreen({super.key});

  static String exportTextOf(SessionLog log, String? version) => log.exportText(
    header: SettingsStrings.logFileHeader(
      CommonStrings.appName,
      version ?? CommonStrings.dash,
    ),
  );

  @override
  ConsumerState<SessionLogScreen> createState() => _SessionLogScreenState();
}

class _SessionLogScreenState extends ConsumerState<SessionLogScreen> {
  late SessionLogFilter _filter = ref
      .read(uiMemoryProvider)
      .readEnum(
        SessionLogFilter.memoryKey,
        SessionLogFilter.values,
        SessionLogFilter.all,
      );
  String _query = '';

  void _setFilter(SessionLogFilter f) {
    setState(() => _filter = f);
    ref.read(uiMemoryProvider).writeEnum(SessionLogFilter.memoryKey, f);
  }

  Future<void> _copy(String text) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    await Clipboard.setData(ClipboardData(text: text));
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(CommonStrings.copied)));
  }

  Future<void> _share(BuildContext buttonContext, String text) async {
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

  Future<void> _clear(SessionLog log) async {
    final ok = await confirmSettingsAction(
      context,
      title: SettingsStrings.clearLog,
      message: SettingsStrings.clearLogConfirm,
      confirmLabel: CommonStrings.delete,
      destructive: true,
      icon: Icons.delete_sweep_outlined,
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    await log.clear();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(const SnackBar(content: Text(SettingsStrings.logCleared)));
  }

  bool _matches(SessionLogEntry e) =>
      _filter.matches(e) &&
      matchesSearch(_query, [e.event, e.target, e.detail, '${e.status ?? ''}']);

  @override
  Widget build(BuildContext context) {
    final log = ref.watch(sessionLogProvider);
    final version = ref.watch(packageInfoProvider).value?.version;
    final now = ref.watch(clockProvider).now();
    return ListenableBuilder(
      listenable: log,
      builder: (context, _) {
        final entries = log.entries;
        final hasEntries = entries.isNotEmpty;
        // Newest first, with a day header whenever the local day changes.
        final rows = <Object>[];
        DateTime? day;
        for (final e in entries.reversed) {
          if (!_matches(e)) continue;
          final local = e.time.toLocal();
          final d = DateTime(local.year, local.month, local.day);
          if (d != day) {
            day = d;
            rows.add(d);
          }
          rows.add(e);
        }
        final shown = rows.whereType<SessionLogEntry>().length;
        return SubPageScaffold(
          title: SettingsStrings.sessionLogTitle,
          subtitle: SettingsStrings.exportLogNote,
          actions: [
            if (hasEntries)
              IconButton(
                icon: const Icon(Icons.delete_sweep_outlined),
                tooltip: SettingsStrings.clearLog,
                onPressed: () => unawaited(_clear(log)),
              ),
          ],
          header: hasEntries
              ? _LogHeader(
                  filter: _filter,
                  onFilter: _setFilter,
                  onQuery: (q) => setState(() => _query = q),
                )
              : null,
          headerHeight: 112,
          bottomBar: hasEntries
              ? Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
                        icon: const Icon(Icons.copy_outlined),
                        label: const Text(CommonStrings.copy),
                        onPressed: () => unawaited(
                          _copy(SessionLogScreen.exportTextOf(log, version)),
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
                              SessionLogScreen.exportTextOf(log, version),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : null,
          body: hasEntries
              ? null
              : const EmptyView(
                  title: SettingsStrings.exportLogEmptyTitle,
                  message: SettingsStrings.exportLogEmpty,
                  icon: Icons.receipt_long_outlined,
                ),
          slivers: !hasEntries
              ? null
              : [
                  SliverToBoxAdapter(
                    child: _CountLine(
                      text: shown == entries.length
                          ? SettingsStrings.logEntryCount(entries.length)
                          : SettingsStrings.logEntryShown(
                              shown,
                              entries.length,
                            ),
                    ),
                  ),
                  if (rows.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyView(
                        message: _query.trim().isEmpty
                            ? SettingsStrings.logFilterEmpty
                            : SettingsStrings.logSearchEmpty,
                        icon: _query.trim().isEmpty
                            ? Icons.filter_alt_off_outlined
                            : Icons.search_off_outlined,
                      ),
                    )
                  else
                    SliverList.builder(
                      itemCount: rows.length,
                      itemBuilder: (context, i) => switch (rows[i]) {
                        final DateTime d => _DayHeader(
                          formatDayHeader(d, now),
                        ),
                        final SessionLogEntry e => _LogRow(
                          entry: e,
                          onTap: () => unawaited(_copy(e.toLine())),
                        ),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                ],
        );
      },
    );
  }
}

/// Pinned search field + level filter.
class _LogHeader extends StatelessWidget {
  const _LogHeader({
    required this.filter,
    required this.onFilter,
    required this.onQuery,
  });

  final SessionLogFilter filter;
  final ValueChanged<SessionLogFilter> onFilter;
  final ValueChanged<String> onQuery;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 2),
          child: GlassSearchField(
            hintText: SettingsStrings.logSearchHint,
            onChanged: onQuery,
          ),
        ),
        SegmentedTabs<SessionLogFilter>(
          tabs: [
            for (final f in SessionLogFilter.values)
              SegmentedTab(value: f, label: f.label),
          ],
          selected: filter,
          onChanged: onFilter,
        ),
      ],
    );
  }
}

class _CountLine extends StatelessWidget {
  const _CountLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Text(
        text,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
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

class _DayHeader extends StatelessWidget {
  const _DayHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return SectionLabel(label, padding: const EdgeInsets.fromLTRB(20, 18, 20, 6));
  }
}

class _LogRow extends StatelessWidget {
  const _LogRow({required this.entry, required this.onTap});

  final SessionLogEntry entry;

  /// Copies this line.
  final VoidCallback onTap;

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
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 3, 16, 3),
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ValRadius.small),
          side: theme.brightness == Brightness.light
              ? BorderSide(color: colors.hairline)
              : BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: level, width: 3)),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        _clock(entry.time),
                        style: mono.copyWith(color: muted),
                      ),
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
              ),
            ),
          ),
        ),
      ),
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
          color: legibleAccent(context, color),
        ),
      ),
    );
  }
}
