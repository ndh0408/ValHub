/// "Tùy chỉnh Trang chủ": reorder the cards and switch them on or off
/// (docs/design/HOME.md §7.4).
library;

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/sub_page.dart' show showValSheet;
import '../data/home_card.dart';
import '../home_strings.dart';
import '../providers/home_layout_provider.dart';
import 'home_card_frame.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Opens the customize sheet: every card (also those with no data now) with
/// a drag handle, its description and a switch, plus "Khôi phục mặc định".
/// The Material reorder semantics (move up / down / start / end) let screen
/// readers and switch access reorder without dragging.
Future<void> showCustomizeHomeSheet(BuildContext context) => showValSheet<void>(
  context,
  title: context.l10n.homeCustomize,
  subtitle: context.l10n.homeCustomizeHint,
  builder: (context, _) => const CustomizeHomeList(),
);

/// The list of cards inside the sheet.
class CustomizeHomeList extends ConsumerWidget {
  const CustomizeHomeList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final layout = ref.watch(homeLayoutProvider);
    final consent = ref.watch(homeFriendsConsentProvider);
    final notifier = ref.read(homeLayoutProvider.notifier);

    Future<void> toggle(HomeCardId card, bool on) async {
      if (card == HomeCardId.friends && on && consent != true) {
        // Connecting to chat makes the user look online to friends.
        final ok = await showConfirmDialog(
          context,
          title: HomeStrings.friendsConsentTitle,
          message: HomeStrings.friendsConsentBody,
          confirmLabel: HomeStrings.friendsConsentAllow,
          icon: Icons.group_outlined,
        );
        if (!ok) return;
        await ref.read(homeFriendsConsentProvider.notifier).set(allowed: true);
      }
      await notifier.setHidden(card, hidden: !on);
    }

    return ReorderableListView.builder(
      shrinkWrap: true,
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      itemCount: layout.order.length,
      onReorderItem: (from, to) =>
          unawaited(notifier.move(from, to > from ? to + 1 : to)),
      itemBuilder: (context, i) {
        final card = layout.order[i];
        final on =
            !layout.isHidden(card) &&
            !(card == HomeCardId.friends && consent == false);
        return _CardTile(
          key: ValueKey(card),
          index: i,
          card: card,
          on: on,
          onChanged: (v) => unawaited(toggle(card, v)),
        );
      },
      footer: Padding(
        padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: () => unawaited(notifier.reset()),
            icon: const Icon(Icons.restart_alt_rounded),
            label: Text(context.l10n.homeResetLayout),
          ),
        ),
      ),
    );
  }
}

class _CardTile extends StatelessWidget {
  const _CardTile({
    super.key,
    required this.index,
    required this.card,
    required this.on,
    required this.onChanged,
  });

  final int index;
  final HomeCardId card;
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 64),
      child: Row(
        children: [
          ReorderableDragStartListener(
            index: index,
            child: const SizedBox(
              width: 48,
              height: 48,
              child: Icon(Icons.drag_indicator_rounded),
            ),
          ),
          Icon(
            card.icon,
            size: 24,
            color: on
                ? legibleAccent(context, theme.colorScheme.primary, min: 3)
                : theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  card.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Semantics(
            label: card.title,
            child: Switch.adaptive(value: on, onChanged: onChanged),
          ),
        ],
      ),
    );
  }
}
