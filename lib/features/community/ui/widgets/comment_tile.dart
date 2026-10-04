import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../data/community_models.dart';
import '../feed/report_sheet.dart';
import 'community_widgets.dart';
import 'translatable_text.dart';

class CommunityCommentTile extends StatelessWidget {
  const CommunityCommentTile({
    super.key,
    required this.comment,
    required this.isMine,
    required this.onAction,
  });

  final CommunityComment comment;
  final bool isMine;
  final ValueChanged<ContentAction> onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthorRow(
            author: comment.author,
            createdAt: comment.createdAt,
            isMe: isMine,
            avatarSize: 32,
            trailing: ContentMenuButton(
              author: comment.author,
              isMine: isMine,
              deleteLabel: context.l10n.communityDeleteComment,
              onSelected: onAction,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 44, right: 8),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainer,
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(14),
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14),
                  topLeft: Radius.circular(4),
                ),
              ),
              child: TranslatableText(
                comment.body,
                language: comment.language ?? comment.author.language,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
