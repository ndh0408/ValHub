import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../community_strings.dart';
import '../../data/community_api.dart';
import '../../providers/community_providers.dart';
import '../widgets/community_widgets.dart';

/// Overflow actions of a post / comment / LFG post.
enum ContentAction { delete, report }

/// "⋯" button: "Xóa" on the user's own content, "Báo cáo" on others'.
class ContentMenuButton extends StatelessWidget {
  const ContentMenuButton({
    super.key,
    required this.isMine,
    required this.onSelected,
    this.deleteLabel = CommunityStrings.delete,
  });

  final bool isMine;
  final ValueChanged<ContentAction> onSelected;
  final String deleteLabel;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return PopupMenuButton<ContentAction>(
      tooltip: CommunityStrings.moreActions,
      icon: Icon(Icons.more_horiz_rounded, color: muted),
      onSelected: onSelected,
      itemBuilder: (context) => [
        if (isMine)
          PopupMenuItem(
            value: ContentAction.delete,
            child: _MenuRow(
              icon: Icons.delete_outline_rounded,
              label: deleteLabel,
              color: ValColors.red,
            ),
          )
        else
          const PopupMenuItem(
            value: ContentAction.report,
            child: _MenuRow(
              icon: Icons.flag_outlined,
              label: CommunityStrings.report,
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
        Text(label, style: TextStyle(color: color)),
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
  final reason = await showModalBottomSheet<String>(
    context: context,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => const _ReasonPicker(),
  );
  if (reason == null || !context.mounted) return false;
  final ok = await confirmCommunityAction(
    context,
    title: CommunityStrings.reportConfirmTitle,
    body: CommunityStrings.reportConfirmBody,
    confirmLabel: CommunityStrings.send,
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
          const SnackBar(content: Text(CommunityStrings.reported)),
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
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
            child: Text(
              CommunityStrings.reportTitle,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              CommunityStrings.reportPrompt,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          for (final e in CommunityStrings.reportReasons.entries)
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
