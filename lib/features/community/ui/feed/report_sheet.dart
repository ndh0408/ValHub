import 'package:valvn/core/l10n/labels/community_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/sub_page.dart';
import '../../data/community_api.dart';
import '../../data/community_models.dart';
import '../../providers/hidden_authors.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../providers/community_providers.dart';
import '../consent/consent_sheet.dart';
import '../widgets/community_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Overflow actions of a post / comment / LFG post.
enum ContentAction { delete, report }

enum _MenuAction { delete, report, mute }

/// "⋯" button: "Xóa" on the user's own content, "Báo cáo" and "Ẩn người
/// này" (device-only, undone in Settings) on others'.
class ContentMenuButton extends ConsumerWidget {
  const ContentMenuButton({
    super.key,
    required this.isMine,
    required this.onSelected,
    this.deleteLabel,
    this.author,
  });

  final bool isMine;
  final CommunityAuthor? author;
  final ValueChanged<ContentAction> onSelected;
  final String? deleteLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return PopupMenuButton<_MenuAction>(
      tooltip: context.l10n.communityMoreActions,
      icon: Icon(Icons.more_horiz_rounded, color: muted),
      onSelected: (action) {
        if (action == _MenuAction.mute) {
          final target = author;
          if (account != null && target != null) {
            unawaited(
              ref
                  .read(hiddenAuthorsProvider(account.puuid).notifier)
                  .hide(
                    target.id,
                    target.riotId ?? target.id,
                    AuthorVisibilityRule.muted,
                  ),
            );
          }
        } else {
          onSelected(
            action == _MenuAction.delete
                ? ContentAction.delete
                : ContentAction.report,
          );
        }
      },
      itemBuilder: (context) => [
        if (isMine)
          PopupMenuItem(
            value: _MenuAction.delete,
            child: _MenuRow(
              icon: Icons.delete_outline_rounded,
              label: deleteLabel ?? context.l10n.communityDelete,
              color: ValColors.red,
            ),
          )
        else
          PopupMenuItem(
            value: _MenuAction.report,
            child: _MenuRow(
              icon: Icons.flag_outlined,
              label: context.l10n.communityReport,
            ),
          ),
        if (!isMine && author != null && account != null)
          PopupMenuItem(
            value: _MenuAction.mute,
            child: _MenuRow(
              icon: Icons.visibility_off_outlined,
              label: context.l10n.communityMuteAuthor,
            ),
          ),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label, this.color});

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(label, style: TextStyle(color: color)),
        ),
      ],
    );
  }
}

/// Asks for a reason, confirms, then reports [targetId]. Returns whether a
/// report was sent.
Future<bool> reportContent(
  BuildContext context,
  WidgetRef ref, {
  required String puuid,
  required ReportTarget targetType,
  required String targetId,
}) async {
  final l10nBeforeAwait = context.l10n;

  // Reporting needs a session: ask to join first, then continue.
  if (!await promptConsentFromContext(context) || !context.mounted) {
    return false;
  }
  final reason = await showValSheet<String>(
    context,
    title: l10nBeforeAwait.communityReportTitle,
    builder: (_, _) => const _ReasonPicker(),
  );
  if (reason == null || !context.mounted) return false;
  final ok = await confirmCommunityAction(
    context,
    title: l10nBeforeAwait.communityReportConfirmTitle,
    body: l10nBeforeAwait.communityReportConfirmBody,
    confirmLabel: l10nBeforeAwait.communitySend,
  );
  if (!ok || !context.mounted) return false;
  try {
    await ref
        .read(communityApiProvider)
        .report(
          puuid,
          targetType: targetType,
          targetId: targetId,
          reason: reason,
        );
    if (context.mounted) {
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(l10nBeforeAwait.communityReported)),
        );
    }
    return true;
  } on Object catch (e) {
    if (context.mounted) showCommunityError(context, e);
    return false;
  }
}

class _ReasonPicker extends StatelessWidget {
  const _ReasonPicker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              context.l10n.communityReportPrompt,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final e in context.l10n.communityReportReasonLabels.entries)
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(ValRadius.small),
              ),
              leading: const Icon(Icons.flag_outlined),
              title: Text(e.value),
              onTap: () => Navigator.of(context).pop(e.key),
            ),
        ],
      ),
    );
  }
}
