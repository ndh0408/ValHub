import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../community_strings.dart';
import '../../data/community_models.dart';
import '../widgets/community_widgets.dart';
import '../widgets/translatable_text.dart';
import 'media_grid.dart';
import 'offers_grid.dart';
import 'report_sheet.dart';

/// A feed post: author row, text, store / Night Market skins, images and
/// the like / comment bar. [onOpen] opens the detail (null inside it).
class PostCard extends StatelessWidget {
  const PostCard({
    super.key,
    required this.post,
    required this.isMine,
    required this.onLike,
    required this.onAction,
    this.onOpen,
    this.expanded = false,
  });

  final CommunityPost post;
  final bool isMine;
  final VoidCallback onLike;
  final ValueChanged<ContentAction> onAction;
  final VoidCallback? onOpen;

  /// Full text (detail screen) instead of the first lines.
  final bool expanded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final payload = post.payload;
    final kindBadge = switch (post.kind) {
      PostKind.store => CommunityStrings.kindStore,
      PostKind.nightmarket => CommunityStrings.kindNightMarket,
      PostKind.text => null,
    };
    return ValCard(
      padding: EdgeInsets.zero,
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 4, 0),
            child: AuthorRow(
              author: post.author,
              createdAt: post.createdAt,
              isMe: isMine,
              trailing: ContentMenuButton(
                isMine: isMine,
                deleteLabel: CommunityStrings.deletePost,
                onSelected: onAction,
              ),
            ),
          ),
          if (kindBadge != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: ValBadge(
                  kindBadge,
                  color: post.kind == PostKind.nightmarket
                      ? const Color(0xFFB57BFF)
                      : ValColors.red,
                  soft: true,
                ),
              ),
            ),
          if (post.body.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: TranslatableText(
                post.body,
                language: post.language ?? post.author.language,
                maxLines: expanded ? null : 6,
                overflow: expanded ? null : TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          if (payload != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: OffersGrid(kind: post.kind, payload: payload),
            ),
          if (post.media.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: MediaGrid(postId: post.id, media: post.media),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
            child: Row(
              children: [
                HeartButton(
                  active: post.liked,
                  count: post.likes,
                  onTap: onLike,
                ),
                const SizedBox(width: 4),
                Semantics(
                  button: onOpen != null,
                  label: CommunityStrings.comments(formatNumber(post.comments)),
                  excludeSemantics: true,
                  child: InkWell(
                    onTap: onOpen,
                    borderRadius: BorderRadius.circular(ValRadius.pill),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 20,
                            color: muted,
                          ),
                          const SizedBox(width: 6),
                          AnimatedCount(
                            value: post.comments,
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: muted,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
