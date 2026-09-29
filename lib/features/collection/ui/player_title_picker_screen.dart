import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/domain/loadout/loadout.dart';
import '../../../core/riot/riot_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/val_widgets.dart';
import '../collection_strings.dart';
import '../data/collection_items.dart';
import '../data/collection_search.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/loadout_actions.dart';

/// S32 "Chọn danh hiệu" (+ "Không có danh hiệu"). Route `/collection/title`.
class PlayerTitlePickerScreen extends ConsumerStatefulWidget {
  const PlayerTitlePickerScreen({super.key});

  @override
  ConsumerState<PlayerTitlePickerScreen> createState() =>
      _PlayerTitlePickerScreenState();
}

class _PlayerTitlePickerScreenState
    extends ConsumerState<PlayerTitlePickerScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.playerTitleTitle)),
      body: CollectionAccountGate(
        builder: (context, account) => Column(
          children: [
            CollectionSearchField(
              hint: CollectionStrings.searchTitles,
              onChanged: (v) => setState(() => _search = v),
            ),
            Expanded(
              child: LoadoutDataBuilder(
                puuid: account.puuid,
                loading: const SkeletonList(itemHeight: 48),
                builder: (context, snapshot, owned, db) {
                  final equipped = snapshot.loadout.identity.titleOrNone;
                  final showNone = matchesSearch(_search, [
                    CollectionStrings.noTitle,
                  ]);
                  final titles = [
                    for (final t in ownedTitles(owned, db))
                      if (matchesSearch(_search, [t.text, t.displayName])) t,
                  ];
                  final saving = snapshot.isPending;

                  Future<void> pick(String id, String label) async {
                    if (id == equipped || saving) return;
                    await applyLoadoutChange(
                      context,
                      ref,
                      puuid: account.puuid,
                      change: SetPlayerTitle(id),
                      successMessage: CollectionStrings.equippedItem(label),
                    );
                  }

                  Widget tile(String id, String label, {bool muted = false}) {
                    final selected = id == equipped;
                    final scheme = Theme.of(context).colorScheme;
                    return ListTile(
                      key: ValueKey(id),
                      selected: selected,
                      selectedColor: scheme.onSurface,
                      selectedTileColor: scheme.primary.withValues(alpha: 0.08),
                      enabled: !saving || selected,
                      minTileHeight: 52,
                      leading: HubIcon(muted ? Icons.block : Icons.text_fields),
                      title: Text(
                        label,
                        style: muted
                            ? TextStyle(
                                fontStyle: FontStyle.italic,
                                color: scheme.onSurfaceVariant,
                              )
                            : TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                      ),
                      trailing: AnimatedSwitcher(
                        duration: ValMotion.fast,
                        child: selected
                            ? Icon(
                                Icons.check_circle,
                                key: const ValueKey('on'),
                                color: scheme.primary,
                              )
                            : const SizedBox(key: ValueKey('off'), width: 24),
                      ),
                      onTap: () {
                        if (id != equipped && !saving) Haptics.selection();
                        unawaited(pick(id, label));
                      },
                    );
                  }

                  return AdaptiveRefresh(
                    onRefresh: () => refreshCollection(ref, account.puuid),
                    child: Column(
                      children: [
                        SavingBar(visible: saving),
                        Expanded(
                          child: ListView(
                            keyboardDismissBehavior:
                                ScrollViewKeyboardDismissBehavior.onDrag,
                            padding: const EdgeInsets.only(top: 4, bottom: 24),
                            children: [
                              if (showNone || titles.isNotEmpty)
                                GroupedSection(
                                  children: [
                                    if (showNone)
                                      tile(
                                        SpecialIds.noTitle,
                                        CollectionStrings.noTitle,
                                        muted: true,
                                      ),
                                    for (final t in titles)
                                      tile(t.uuid, t.text),
                                  ],
                                ),
                              if (!showNone && titles.isEmpty)
                                const EmptyView(
                                  title: CollectionStrings.noResultsTitle,
                                  message: CollectionStrings.noResults,
                                  icon: Icons.search_off,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
