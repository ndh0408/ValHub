import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/account_xp.dart';
import '../../../../core/domain/loadout/loadout.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/async_value_view.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/ui/sub_page.dart';
import '../../../../core/ui/val_widgets.dart';
import 'loadout_actions.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Picker for `Identity.PreferredLevelBorderID`: "Tự động theo cấp" or a
/// border unlocked at the account's level (P-9), in the shared sheet chrome.
Future<void> showLevelBorderSheet(
  BuildContext context, {
  required Account account,
}) => showValSheet<void>(
  context,
  title: context.l10n.collectionLevelBorderTitle,
  subtitle: account.level == null
      ? null
      : context.l10n.collectionLevelBorderSubtitle(account.level!),
  scrollable: true,
  initialSize: 0.7,
  minSize: 0.45,
  builder: (context, controller) =>
      LevelBorderSheet(account: account, controller: controller),
);

/// Body of [showLevelBorderSheet]: the automatic option, then every border
/// unlocked at the account's level (newest first), the current one ticked.
class LevelBorderSheet extends ConsumerWidget {
  const LevelBorderSheet({super.key, required this.account, this.controller});

  final Account account;

  /// Scroll controller of the draggable sheet.
  final ScrollController? controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puuid = account.puuid;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final snapshot = ref.watch(loadoutProvider(puuid)).value;
    final current = snapshot?.loadout.identity;
    return AsyncValueView(
      value: ref.watch(accountXpProvider(puuid)),
      puuid: puuid,
      onRetry: () => ref.invalidate(accountXpProvider(puuid)),
      loading: const SkeletonList(itemCount: 5, itemHeight: 60, spacing: 8),
      data: (xp) {
        final level = xp.level > 0 ? xp.level : (account.level ?? 0);
        final borders = [
          for (final b in db.levelBorders)
            if (b.startingLevel <= level) b,
        ]..sort((a, b) => b.startingLevel.compareTo(a.startingLevel));
        Future<void> pick(String? id) async {
          final navigator = Navigator.of(context);
          final ok = await applyLoadoutChange(
            context,
            ref,
            puuid: puuid,
            change: SetLevelBorder(id),
          );
          if (ok && navigator.mounted) navigator.pop();
        }

        return ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(0, 0, 0, 24),
          children: [
            GroupedSection(
              children: [
                _BorderTile(
                  border: db.levelBorderFor(level),
                  title: context.l10n.collectionLevelBorderAuto,
                  selected: current?.isAutoLevelBorder ?? false,
                  onTap: () => unawaited(pick(null)),
                ),
                for (final b in borders)
                  _BorderTile(
                    border: b,
                    title: b.displayName,
                    subtitle: context.l10n.collectionLevelBorderFrom(
                      b.startingLevel,
                    ),
                    selected:
                        !(current?.isAutoLevelBorder ?? true) &&
                        current?.preferredLevelBorderId == b.uuid,
                    onTap: () => unawaited(pick(b.uuid)),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _BorderTile extends StatelessWidget {
  const _BorderTile({
    required this.border,
    required this.title,
    required this.selected,
    required this.onTap,
    this.subtitle,
  });

  final LevelBorder? border;
  final String title;
  final String? subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => ListTile(
    onTap: () {
      if (!selected) Haptics.selection();
      onTap();
    },
    selected: selected,
    selectedColor: Theme.of(context).colorScheme.onSurface,
    selectedTileColor: Theme.of(context).colorScheme.primary
        .withValues(alpha: 0.08),
    minTileHeight: 56,
    leading: SizedBox(
      width: 56,
      height: 32,
      child: NetImage(border?.levelNumberAppearance, fit: BoxFit.contain),
    ),
    title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: selected
        ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
        : null,
  );
}
