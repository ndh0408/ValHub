import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/account_xp.dart';
import '../../../../core/domain/loadout/loadout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/async_value_view.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/skeleton.dart';
import '../../collection_strings.dart';
import 'loadout_actions.dart';

/// Picker for `Identity.PreferredLevelBorderID`: "Tự động theo cấp" or a
/// border unlocked at the account's level (P-9).
Future<void> showLevelBorderSheet(
  BuildContext context, {
  required Account account,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => LevelBorderSheet(account: account),
);

class LevelBorderSheet extends ConsumerWidget {
  const LevelBorderSheet({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puuid = account.puuid;
    final theme = Theme.of(context);
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final snapshot = ref.watch(loadoutProvider(puuid)).value;
    final current = snapshot?.loadout.identity;
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.7,
      maxChildSize: 0.95,
      builder: (context, controller) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text(
              CollectionStrings.levelBorderTitle,
              style: theme.textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: AsyncValueView(
              value: ref.watch(accountXpProvider(puuid)),
              puuid: puuid,
              onRetry: () => ref.invalidate(accountXpProvider(puuid)),
              loading: const SkeletonList(itemHeight: 56),
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
                  children: [
                    _BorderTile(
                      border: db.levelBorderFor(level),
                      title: CollectionStrings.levelBorderAuto,
                      selected: current?.isAutoLevelBorder ?? false,
                      onTap: () => unawaited(pick(null)),
                    ),
                    for (final b in borders)
                      _BorderTile(
                        border: b,
                        title: b.displayName,
                        subtitle: CollectionStrings.levelBorderFrom(
                          b.startingLevel,
                        ),
                        selected:
                            !(current?.isAutoLevelBorder ?? true) &&
                            current?.preferredLevelBorderId == b.uuid,
                        onTap: () => unawaited(pick(b.uuid)),
                      ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
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
    onTap: onTap,
    selected: selected,
    leading: SizedBox(
      width: 56,
      height: 32,
      child: NetImage(border?.levelNumberAppearance, fit: BoxFit.contain),
    ),
    title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: selected
        ? const Icon(Icons.check_circle, color: ValColors.red)
        : null,
  );
}
