import 'package:valvn/features/social/ui/friend_status_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/competitive/names.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../../../core/xmpp/friends.dart';
import '../../../core/xmpp/xmpp_models.dart';
import '../../../core/xmpp/xmpp_providers.dart';
import '../../profile/profile_routes.dart';
import '../data/friend_status.dart';
import '../social_strings.dart';
import 'widgets/friend_tile.dart';
import 'widgets/social_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Messages closer than this (same side, same day) form one group: one
/// avatar, one time label, tighter spacing.
const kChatGroupGap = Duration(minutes: 5);

/// S61 "Trò chuyện" with one friend. Route `/profile/friends/:puuid/chat`.
///
/// Header: card avatar (flies in from the friends list), Riot ID and live
/// status; tapping it opens the profile (S44). Messages are grouped by day
/// ("Hôm nay", "Hôm qua", "Thứ Hai, 22/09") and by sender, newest at the
/// bottom; history comes from Riot's chat archive, new messages live.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.friendPuuid});

  final String friendPuuid;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _input = TextEditingController();
  final _focus = FocusNode();
  bool _sending = false;

  String get _id => widget.friendPuuid.trim().toLowerCase();

  @override
  void dispose() {
    _input.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final messages = context.l10n;
    final text = _input.text.trim();
    final service = ref.read(xmppServiceProvider);
    if (text.isEmpty || service == null || _sending) return;
    setState(() => _sending = true);
    try {
      await service.sendMessage(_id, text);
      _input.clear();
    } on Object {
      if (mounted) showAppSnackBar(context, messages.socialSendFailed);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _reload() async {
    await ref.read(xmppServiceProvider)?.loadHistory(_id);
  }

  /// Fills the message box with a quick opener (never sends by itself).
  void _suggest(String text) {
    Haptics.selection();
    _input
      ..text = text
      ..selection = TextSelection.collapsed(offset: text.length);
    _focus.requestFocus();
  }

  void _openProfile() => unawaited(context.push(ProfileRoutes.player(_id)));

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
        : friendStatus(context.l10n, context.fmt, friend, db: db, now: now);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: _ChatHeader(
          puuid: _id,
          friend: friend,
          name: name,
          status: status,
          onTap: _openProfile,
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.socialViewProfile,
            icon: const Icon(Icons.person_outline),
            onPressed: _openProfile,
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Divider(
            height: 1,
            thickness: 1,
            color: valColorsOf(context).hairline,
          ),
        ),
      ),
      body: Column(
        children: [
          ConnectionBanner(
            state: connection,
            margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
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
                friend: friend,
                name: name,
                onRefresh: _reload,
                onSuggest: _suggest,
              ),
            ),
          ),
          _Composer(
            controller: _input,
            focusNode: _focus,
            enabled: connection.isConnected && !_sending,
            connected: connection.isConnected,
            onSend: () => unawaited(_send()),
          ),
        ],
      ),
    );
  }
}

/// Avatar + Riot ID + colored status line of the app bar.
class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.puuid,
    required this.friend,
    required this.name,
    required this.status,
    required this.onTap,
  });

  final String puuid;
  final Friend? friend;
  final RiotName? name;
  final FriendStatus? status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = status;
    final online = friend?.isOnline ?? false;
    return Semantics(
      button: true,
      label: context.l10n.socialViewProfile,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(ValRadius.small),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Row(
            children: [
              friendAvatarHero(
                friendAvatarHeroTag(puuid),
                FriendAvatar(
                  playerCardId: friend?.playerCardId,
                  name: name?.gameName,
                  tone: online ? s?.tone : null,
                  dimmed: friend != null && !online,
                  size: 38,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RiotIdText(
                      name,
                      fallback: context.l10n.competitiveUnknownPlayer,
                      style: theme.textTheme.titleMedium,
                    ),
                    if (s != null)
                      Text(
                        s.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: s.tone == StatusTone.offline
                              ? null
                              : FontWeight.w600,
                          color: s.tone == StatusTone.offline
                              ? theme.colorScheme.onSurfaceVariant
                              : legibleAccent(
                                  context,
                                  statusColor(context, s.tone),
                                  min: 3.5,
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConversationBody extends StatelessWidget {
  const _ConversationBody({
    required this.conversation,
    required this.now,
    required this.friend,
    required this.name,
    required this.onRefresh,
    required this.onSuggest,
  });

  final Conversation conversation;
  final DateTime now;
  final Friend? friend;
  final RiotName? name;
  final Future<void> Function() onRefresh;
  final ValueChanged<String> onSuggest;

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
          children: [
            const SizedBox(height: 32),
            EmptyView(
              title: context.l10n.socialEmptyChatTitle,
              message: context.l10n.socialEmptyChat,
              icon: Icons.waving_hand_outlined,
              action: Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in SocialStrings.suggestions)
                    ActionChip(
                      label: Text(s),
                      shape: const StadiumBorder(),
                      onPressed: () => onSuggest(s),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    final items = chatItems(c.messages, now);
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
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[items.length - 1 - i];
                return switch (item) {
                  ChatDayItem(:final label) => _DayHeader(label),
                  final ChatMessageItem m => _Bubble(
                    key: ValueKey(m.message.id),
                    item: m,
                    friend: friend,
                    name: name,
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

/// One entry of the conversation list (oldest first).
sealed class ChatItem {
  const ChatItem();
}

/// "Hôm nay" / "Hôm qua" / "Thứ Hai, 22/09" before a new local day.
final class ChatDayItem extends ChatItem {
  const ChatDayItem(this.label);

  final String label;
}

/// A message with its place in a run of messages from the same side.
final class ChatMessageItem extends ChatItem {
  const ChatMessageItem(
    this.message, {
    required this.firstInGroup,
    required this.lastInGroup,
  });

  final ChatMessage message;

  /// Starts a group (extra spacing above, tail corner).
  final bool firstInGroup;

  /// Ends a group (time label, the friend's avatar).
  final bool lastInGroup;
}

/// Oldest-first items: a day header before each new local day, and every
/// message marked as the first / last of its group (same side, same day,
/// less than [kChatGroupGap] apart).
List<ChatItem> chatItems(List<ChatMessage> messages, DateTime now) {
  bool sameGroup(ChatMessage a, ChatMessage b) {
    final la = a.at.toLocal();
    final lb = b.at.toLocal();
    return a.outgoing == b.outgoing &&
        la.year == lb.year &&
        la.month == lb.month &&
        la.day == lb.day &&
        b.at.difference(a.at).abs() <= kChatGroupGap;
  }

  final out = <ChatItem>[];
  DateTime? day;
  for (var i = 0; i < messages.length; i++) {
    final m = messages[i];
    final local = m.at.toLocal();
    final d = DateTime(local.year, local.month, local.day);
    if (day != d) {
      day = d;
      out.add(ChatDayItem(formatDayHeader(m.at, now)));
    }
    final previous = i > 0 ? messages[i - 1] : null;
    final next = i + 1 < messages.length ? messages[i + 1] : null;
    out.add(
      ChatMessageItem(
        m,
        firstInGroup: previous == null || !sameGroup(previous, m),
        lastInGroup: next == null || !sameGroup(m, next),
      ),
    );
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
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Center(
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: valColorsOf(context).surface2,
            borderRadius: BorderRadius.circular(ValRadius.pill),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    super.key,
    required this.item,
    required this.friend,
    required this.name,
  });

  final ChatMessageItem item;
  final Friend? friend;
  final RiotName? name;

  static const _avatar = 28.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = item.message;
    final mine = message.outgoing;
    final failed = message.status == ChatMessageStatus.failed;
    final bg = mine ? theme.colorScheme.primary : valColorsOf(context).surface2;
    final fg = mine ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;
    const big = Radius.circular(18);
    const small = Radius.circular(6);
    // iMessage-style runs: the inner corners of a group are tighter.
    final radius = mine
        ? BorderRadius.only(
            topLeft: big,
            bottomLeft: big,
            topRight: item.firstInGroup ? big : small,
            bottomRight: item.lastInGroup ? big : small,
          )
        : BorderRadius.only(
            topRight: big,
            bottomRight: big,
            topLeft: item.firstInGroup ? big : small,
            bottomLeft: item.lastInGroup ? big : small,
          );
    final muted = theme.colorScheme.onSurfaceVariant;

    final bubble = LayoutBuilder(
      builder: (context, constraints) => ConstrainedBox(
        constraints: BoxConstraints(maxWidth: constraints.maxWidth * 0.78),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: failed ? bg.withValues(alpha: 0.55) : bg,
            borderRadius: radius,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(13, 8, 13, 8),
            child: SelectableText(
              message.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: fg,
                height: 1.35,
              ),
            ),
          ),
        ),
      ),
    );

    // Incoming runs: the friend's avatar next to the last bubble, an
    // indent of the same width before the others.
    final Widget row;
    if (mine) {
      row = Align(alignment: Alignment.centerRight, child: bubble);
    } else {
      row = Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SizedBox(
            width: _avatar,
            child: item.lastInGroup
                ? FriendAvatar(
                    playerCardId: friend?.playerCardId,
                    name: name?.gameName,
                    size: _avatar,
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Align(alignment: Alignment.centerLeft, child: bubble),
          ),
        ],
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: item.firstInGroup ? 10 : 2),
      child: Column(
        crossAxisAlignment: mine
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          row,
          if (item.lastInGroup || failed)
            Padding(
              padding: EdgeInsets.fromLTRB(
                mine ? 0 : _avatar + 12,
                3,
                mine ? 4 : 0,
                0,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (failed) ...[
                    Icon(
                      Icons.error_outline,
                      size: 13,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        context.l10n.socialFailedBadge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                  Text(
                    formatTime(message.at),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: muted,
                      fontFeatures: const [FontFeature.tabularFigures()],
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

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.enabled,
    required this.connected,
    required this.onSend,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final bool connected;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hairline = valColorsOf(context).hairline;
    OutlineInputBorder border(Color c) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(22),
      borderSide: BorderSide(color: c),
    );
    return Material(
      color: theme.scaffoldBackgroundColor,
      shape: Border(top: BorderSide(color: hairline)),
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
                  focusNode: focusNode,
                  enabled: connected,
                  minLines: 1,
                  maxLines: 5,
                  maxLength: 1000,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: connected
                        ? context.l10n.socialMessageHint
                        : context.l10n.socialWaitingForConnection,
                    hintMaxLines: 2,
                    counterText: '',
                    isDense: true,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainer,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    border: border(hairline),
                    enabledBorder: border(hairline),
                    disabledBorder: border(hairline),
                    focusedBorder: border(theme.colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ListenableBuilder(
                listenable: controller,
                builder: (context, _) {
                  final canSend = enabled && controller.text.trim().isNotEmpty;
                  return AnimatedScale(
                    scale: canSend ? 1 : 0.9,
                    duration: ValMotion.fast,
                    curve: ValMotion.curve,
                    child: IconButton.filled(
                      tooltip: context.l10n.socialSend,
                      onPressed: canSend
                          ? () {
                              Haptics.light();
                              onSend();
                            }
                          : null,
                      icon: const Icon(Icons.send_rounded),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Mirrors a conversation: alternating bubbles of varied widths.
class _ChatSkeleton extends StatelessWidget {
  const _ChatSkeleton();

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          const Center(child: Skeleton(width: 72, height: 18, radius: 9)),
          const SizedBox(height: 8),
          for (var i = 0; i < 6; i++)
            Align(
              alignment: i.isEven
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
              child: Padding(
                padding: EdgeInsets.fromLTRB(i.isEven ? 36 : 0, 6, 0, 6),
                child: Skeleton(
                  width: 120.0 + (i * 37) % 110,
                  height: 38,
                  radius: 18,
                  shimmer: false,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
