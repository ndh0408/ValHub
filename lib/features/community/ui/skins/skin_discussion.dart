import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account_providers.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/ui/adaptive.dart';
import '../../data/community_api.dart';
import '../../data/community_models.dart';
import '../../providers/community_providers.dart';
import '../../providers/hidden_authors.dart';
import '../../providers/skin_comment_providers.dart';
import '../../providers/skin_review_providers.dart' show SkinKey;
import '../consent/consent_sheet.dart';
import '../feed/report_sheet.dart';
import '../widgets/comment_tile.dart';
import '../widgets/community_widgets.dart';

/// Key this widget by viewer and skin so drafts/pending actions never switch authors.
class SkinDiscussionSliver extends ConsumerStatefulWidget {
  const SkinDiscussionSliver({super.key, required this.skinKey});
  final SkinKey skinKey;
  @override
  ConsumerState<SkinDiscussionSliver> createState() =>
      _SkinDiscussionSliverState();
}

class _SkinDiscussionSliverState extends ConsumerState<SkinDiscussionSliver> {
  final _text = TextEditingController();
  bool _sending = false;
  String? _retryBody;
  String? _retryKey;
  bool get _current =>
      mounted && ref.read(activePuuidProvider) == widget.skinKey.puuid;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final key = widget.skinKey;
    final async = ref.watch(skinCommentsProvider(key));
    final puuid = key.puuid;
    final me = puuid == null
        ? null
        : ref.watch(communityMeProvider(puuid)).value?.id;
    final hidden = puuid == null
        ? <String, HiddenAuthor>{}
        : ref.watch(hiddenAuthorsProvider(puuid));
    final items =
        async.value?.items
            .where((c) => !hidden.containsKey(c.author.id))
            .toList() ??
        [];
    final tooLong = _text.text.trim().runes.length > 500;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  context.l10n.communityCommentsTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(context.l10n.communitySkinDiscussionHint),
                const SizedBox(height: 12),
                TextField(
                  key: const ValueKey('skin-comment-input'),
                  controller: _text,
                  enabled: !_sending && puuid != null,
                  minLines: 1,
                  maxLines: 5,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: context.l10n.communityCommentHint,
                    errorText: tooLong
                        ? context.l10n.communityTooLong(500)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: AlignmentDirectional.centerEnd,
                  child: FilledButton.icon(
                    key: const ValueKey('skin-comment-send'),
                    onPressed:
                        _sending ||
                            puuid == null ||
                            tooLong ||
                            _text.text.trim().isEmpty
                        ? null
                        : () => unawaited(_send()),
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(context.l10n.communitySendComment),
                  ),
                ),
                if (async.hasValue && async.requireValue.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(context.l10n.communityNoComments),
                  ),
              ],
            ),
          ),
        ),
        if (!async.hasValue)
          SliverToBoxAdapter(
            child: async.hasError && !async.isLoading
                ? CommunityErrorState(
                    error: async.error!,
                    puuid: puuid,
                    onRetry: () => ref.invalidate(skinCommentsProvider(key)),
                  )
                : const Padding(
                    padding: EdgeInsets.all(16),
                    child: LinearProgressIndicator(),
                  ),
          ),
        SliverList.builder(
          itemCount: async.hasValue ? items.length + 1 : 0,
          itemBuilder: (_, i) {
            if (i == items.length) {
              final state = async.requireValue;
              return PagedFooter(
                hasMore: state.hasMore,
                loading: state.loadingMore,
                error: state.loadMoreError,
                onLoadMore: () => unawaited(
                  ref.read(skinCommentsProvider(key).notifier).loadMore(),
                ),
              );
            }
            final c = items[i];
            return CommunityCommentTile(
              key: ValueKey('skin-comment-${c.id}'),
              comment: c,
              isMine: me != null && c.author.id == me,
              onAction: (a) => unawaited(_action(c, a)),
            );
          },
        ),
      ],
    );
  }

  Future<void> _send() async {
    if (_sending || !_current) return;
    setState(() => _sending = true);
    final draft = _text.text.trim();
    if (_retryBody != draft || _retryKey == null) {
      _retryBody = draft;
      final random = Random.secure();
      _retryKey = List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join();
    }
    try {
      if (!await promptConsentFromContext(context) || !_current) return;
      await ref
          .read(skinCommentsProvider(widget.skinKey).notifier)
          .add(draft, idempotencyKey: _retryKey);
      if (_current) {
        _text.clear();
        _retryKey = null;
        _retryBody = null;
      }
    } on Object catch (e) {
      if (mounted && _current) showCommunityError(context, e);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _action(CommunityComment c, ContentAction action) async {
    final puuid = widget.skinKey.puuid;
    if (!_current || puuid == null) return;
    switch (action) {
      case ContentAction.report:
        await reportContent(
          context,
          ref,
          puuid: puuid,
          targetType: ReportTarget.skinComment,
          targetId: c.id,
        );
      case ContentAction.delete:
        final ok = await showConfirmDialog(
          context,
          title: context.l10n.communityDeleteCommentTitle,
          message: context.l10n.communityDeleteCommentBody,
          confirmLabel: context.l10n.communityDelete,
          destructive: true,
        );
        if (!ok || !_current) return;
        try {
          await ref
              .read(skinCommentsProvider(widget.skinKey).notifier)
              .delete(c.id);
        } on Object catch (e) {
          if (mounted && _current) showCommunityError(context, e);
        }
    }
  }
}
