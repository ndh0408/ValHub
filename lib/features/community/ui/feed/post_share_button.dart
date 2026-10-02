import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/l10n.dart';
import '../../data/community_models.dart';
import '../../providers/post_share.dart';

/// Sharing public content does not sign in or grant community consent.
class PostShareButton extends ConsumerStatefulWidget {
  const PostShareButton({super.key, required this.post});
  final CommunityPost post;

  @override
  ConsumerState<PostShareButton> createState() => _PostShareButtonState();
}

class _PostShareButtonState extends ConsumerState<PostShareButton> {
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    final l10n = context.l10n;
    final post = widget.post;
    final subject = l10n.communitySharePostTitle(
      post.author.gameName.isEmpty
          ? l10n.communityUnknownPlayer
          : post.author.gameName,
    );
    final body = post.body.trim().characters;
    final excerpt = body.take(160).toString() + (body.length > 160 ? '…' : '');
    final text = [
      subject,
      if (excerpt.isNotEmpty) excerpt,
      communityPostLink(post.id),
    ].join('\n\n');
    final box = context.findRenderObject();
    final origin = box is RenderBox && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    final share = ref.read(communityPostSharerProvider);
    setState(() => _sharing = true);
    try {
      await share(text: text, subject: subject, origin: origin);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)
          ?..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.communityErrorGeneric)));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) => IconButton(
    key: ValueKey('share-post-${widget.post.id}'),
    tooltip: context.l10n.commonShare,
    onPressed: _sharing ? null : _share,
    icon: _sharing
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Icon(
            Theme.of(context).platform == TargetPlatform.iOS
                ? Icons.ios_share_rounded
                : Icons.share_outlined,
            size: 20,
          ),
  );
}
