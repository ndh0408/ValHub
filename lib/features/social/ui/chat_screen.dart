import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/competitive_strings.dart';
import '../../../core/domain/competitive/names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../../../core/xmpp/xmpp_models.dart';
import '../../../core/xmpp/xmpp_providers.dart';
import '../../profile/profile_routes.dart';
import '../data/friend_status.dart';
import '../social_strings.dart';
import 'widgets/friend_tile.dart';
import 'widgets/social_widgets.dart';

/// S61 "Trò chuyện" with one friend. Route `/profile/friends/:puuid/chat`.
///
/// Header: name + live status, profile button (→ S44). Messages grouped by
/// day, newest at the bottom; history from Riot's chat archive, new
/// messages live.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.friendPuuid});

  final String friendPuuid;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  bool _sending = false;

  String get _id => widget.friendPuuid.trim().toLowerCase();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _input.text.trim();
    final service = ref.read(xmppServiceProvider);
    if (text.isEmpty || service == null || _sending) return;
    setState(() => _sending = true);
    try {
      await service.sendMessage(_id, text);
      _input.clear();
    } on Object {
      if (mounted) showAppSnackBar(context, SocialStrings.sendFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _reload() async {
    await ref.read(xmppServiceProvider)?.loadHistory(_id);
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(conversationProvider(_id));
    final connection = ref.watch(xmppConnectionProvider);
    final friend = ref.watch(
      friendsProvider.select((f) => f.value?.byPuuid(_id)),
    );
    final RiotName? name =
        friend?.name ?? ref.watch(playerNameProvider(_id)).value;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final now = ref.watch(clockProvider).now();
    final status = friend == null
        ? null
        : friendStatus(friend, db: db, now: now);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Row(
          children: [
            FriendAvatar(
              playerCardId: friend?.playerCardId,
              name: name?.gameName,
              tone: (friend?.isOnline ?? false) ? status?.tone : null,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  RiotIdText(
                    name,
                    fallback: CompetitiveStrings.unknownPlayer,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (status != null)
                    Text(
                      status.text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: status.tone == StatusTone.offline
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : statusColor(context, status.tone),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: SocialStrings.viewProfile,
            icon: const Icon(Icons.person_outline),
            onPressed: () => unawaited(context.push(ProfileRoutes.player(_id))),
          ),
        ],
      ),
      body: Column(
        children: [
          ConnectionBanner(
            state: connection,
            onRetry: () => unawaited(
              ref.read(xmppServiceProvider)?.retryNow() ?? Future.value(),
            ),
          ),
          Expanded(
            child: AsyncValueView<Conversation>(
              value: conversation,
              puuid: ref.watch(activePuuidProvider),
              onRetry: _reload,
              loading: const _ChatSkeleton(),
              data: (c) => _ConversationBody(
                conversation: c,
                now: now,
                onRefresh: _reload,
              ),
            ),
          ),
          _Composer(
            controller: _input,
            enabled: connection.isConnected && !_sending,
            connected: connection.isConnected,
            onSend: () => unawaited(_send()),
          ),
        ],
      ),
    );
  }
}

class _ConversationBody extends StatelessWidget {
  const _ConversationBody({
    required this.conversation,
    required this.now,
    required this.onRefresh,
  });

  final Conversation conversation;
  final DateTime now;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final c = conversation;
    final error = c.historyError;
    if (c.messages.isEmpty) {
      if (c.loadingHistory || (!c.historyLoaded && error == null)) {
        return const _ChatSkeleton();
      }
      if (error != null) {
        return ErrorView(error: error, onRetry: () => unawaited(onRefresh()));
      }
      return AdaptiveRefresh(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: const [
            SizedBox(height: 48),
            EmptyView(
              message: SocialStrings.emptyChat,
              icon: Icons.waving_hand_outlined,
            ),
          ],
        ),
      );
    }
    final items = _chatItems(c.messages, now);
    return Column(
      children: [
        if (error != null)
          ErrorView(
            error: error,
            compact: true,
            onRetry: () => unawaited(onRefresh()),
          ),
        Expanded(
          child: AdaptiveRefresh(
            onRefresh: onRefresh,
            child: ListView.builder(
              reverse: true,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[items.length - 1 - i];
                return switch (item) {
                  _DayItem(:final label) => _DayHeader(label),
                  _MessageItem(:final message, :final first) => _Bubble(
                    key: ValueKey(message.id),
                    message: message,
                    firstOfGroup: first,
                  ),
                };
              },
            ),
          ),
        ),
      ],
    );
  }
}

sealed class _ChatItem {
  const _ChatItem();
}

final class _DayItem extends _ChatItem {
  const _DayItem(this.label);

  final String label;
}

final class _MessageItem extends _ChatItem {
  const _MessageItem(this.message, {required this.first});

  final ChatMessage message;

  /// First of a run of messages from the same side (extra spacing).
  final bool first;
}

/// Oldest-first items with a day header before each new local day.
List<_ChatItem> _chatItems(List<ChatMessage> messages, DateTime now) {
  final out = <_ChatItem>[];
  DateTime? day;
  ChatMessage? previous;
  for (final m in messages) {
    final local = m.at.toLocal();
    final d = DateTime(local.year, local.month, local.day);
    var newDay = false;
    if (day != d) {
      day = d;
      newDay = true;
      out.add(_DayItem(formatDayHeader(m.at, now)));
    }
    final first =
        newDay ||
        previous == null ||
        previous.outgoing != m.outgoing ||
        m.at.difference(previous.at) > const Duration(minutes: 5);
    out.add(_MessageItem(m, first: first));
    previous = m;
  }
  return out;
}

class _DayHeader extends StatelessWidget {
  const _DayHeader(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(label, style: theme.textTheme.labelSmall),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({super.key, required this.message, required this.firstOfGroup});

  final ChatMessage message;
  final bool firstOfGroup;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mine = message.outgoing;
    final failed = message.status == ChatMessageStatus.failed;
    final bg = mine
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceContainerHigh;
    final fg = mine ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    const r = Radius.circular(18);
    // Only the first bubble of a run gets the tail corner.
    final tail = firstOfGroup ? const Radius.circular(4) : r;
    return Padding(
      padding: EdgeInsets.only(top: firstOfGroup ? 8 : 2),
      child: Align(
        alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
        child: LayoutBuilder(
          builder: (context, constraints) => ConstrainedBox(
            constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: mine ? r : tail,
                  topRight: mine ? tail : r,
                  bottomLeft: r,
                  bottomRight: r,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
                child: Column(
                  crossAxisAlignment: mine
                      ? CrossAxisAlignment.end
                      : CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SelectableText(
                      message.body,
                      style: theme.textTheme.bodyMedium?.copyWith(color: fg),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (failed) ...[
                          Icon(
                            Icons.error_outline,
                            size: 12,
                            color: mine ? fg : theme.colorScheme.error,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            SocialStrings.failedBadge,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: mine ? fg : theme.colorScheme.error,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                        ],
                        Text(
                          formatTime(message.at),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: fg.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.enabled,
    required this.connected,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool enabled;
  final bool connected;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.scaffoldBackgroundColor,
      shape: Border(top: BorderSide(color: valColorsOf(context).hairline)),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: connected,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 1000,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: connected
                        ? SocialStrings.messageHint
                        : SocialStrings.waitingForConnection,
                    hintMaxLines: 2,
                    counterText: '',
                    isDense: true,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainer,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(22),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) => IconButton.filled(
                  tooltip: SocialStrings.send,
                  onPressed: enabled && controller.text.trim().isNotEmpty
                      ? () {
                          Haptics.light();
                          onSend();
                        }
                      : null,
                  icon: const Icon(Icons.send_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChatSkeleton extends StatelessWidget {
  const _ChatSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < 6; i++)
            Align(
              alignment: i.isEven
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Skeleton(
                  width: 120.0 + (i * 37) % 110,
                  height: 38,
                  radius: 16,
                  shimmer: false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
