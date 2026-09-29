import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoAlertDialog, CupertinoDialogAction, CupertinoTextField;
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/riot/riot_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../collection_strings.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/loadout_actions.dart';

/// S38 "Bộ trang bị đã lưu" (local presets per account): large title with
/// the "only on this device" note, one card per preset (card art, name,
/// saved date, the Vandal / Phantom skins, "Áp dụng" behind a confirmation),
/// and "Lưu trang bị hiện tại" pinned at the bottom. Route
/// `/collection/presets`.
class LoadoutPresetsScreen extends ConsumerWidget {
  const LoadoutPresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return const NoAccountPage(title: CollectionStrings.presetsTitle);
    }
    return _PresetsBody(puuid: account.puuid);
  }
}

class _PresetsBody extends ConsumerWidget {
  const _PresetsBody({required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presets = ref.watch(loadoutPresetsProvider(puuid));
    final notifier = ref.read(loadoutPresetsProvider(puuid).notifier);
    final loadout = ref.watch(loadoutProvider(puuid));
    final snapshot = loadout.value;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final saving = snapshot?.isPending ?? false;
    final loading = snapshot == null && loadout.isLoading;

    Future<void> save() async {
      final messenger = ScaffoldMessenger.maybeOf(context);
      final name = await showPresetNameDialog(
        context,
        initial: notifier.suggestedName,
      );
      if (name == null) return;
      // Snapshot what is equipped right now (the game may have changed it).
      LoadoutSnapshot? current;
      try {
        current = await ref.refresh(loadoutProvider(puuid).future);
      } on Object {
        current = ref.read(loadoutProvider(puuid)).value;
      }
      if (current == null) return;
      final preset = await notifier.save(current.loadout, name: name);
      showCollectionSnack(
        messenger,
        CollectionStrings.presetSaved(preset.name),
      );
    }

    return SubPageScaffold(
      title: CollectionStrings.presetsTitle,
      subtitle: CollectionStrings.presetsNote,
      onRefresh: () => refreshCollection(ref, puuid),
      bottomBar: FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        onPressed: snapshot == null || notifier.isFull || saving
            ? null
            : () => unawaited(save()),
        icon: const Icon(Icons.bookmark_add_outlined),
        label: const Text(CollectionStrings.savePreset),
      ),
      slivers: [
        SliverToBoxAdapter(child: SavingBar(visible: saving || loading)),
        if (snapshot == null && loadout.hasError && !loadout.isLoading)
          SliverToBoxAdapter(
            child: ErrorView(
              error: loadout.error!,
              puuid: puuid,
              compact: true,
              onRetry: () => ref.invalidate(loadoutProvider(puuid)),
            ),
          ),
        if (notifier.isFull)
          const SliverToBoxAdapter(
            child: CollectionNotice(
              icon: Icons.inventory_2_outlined,
              text: CollectionStrings.presetsFull,
            ),
          ),
        if (presets.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              title: CollectionStrings.presetsEmptyTitle,
              message: CollectionStrings.presetsEmpty,
              icon: Icons.inventory_2_outlined,
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            sliver: SliverList.builder(
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final preset = presets[index];
                return Dismissible(
                  key: ValueKey(preset.id),
                  direction: DismissDirection.endToStart,
                  background: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.error,
                        borderRadius: BorderRadius.circular(ValRadius.card),
                      ),
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 24),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  onDismissed: (_) {
                    Haptics.medium();
                    unawaited(_delete(context, ref, preset, index));
                  },
                  child: PresetCard(
                    preset: preset,
                    db: db,
                    busy: saving || snapshot == null,
                    onApply: () => unawaited(_apply(context, ref, preset)),
                    onRename: () => unawaited(_rename(context, ref, preset)),
                    onDelete: () =>
                        unawaited(_delete(context, ref, preset, index)),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    LoadoutPreset preset,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final router = GoRouter.maybeOf(context);
    final confirmed = await showConfirmDialog(
      context,
      title: CollectionStrings.applyPresetTitle(preset.name),
      message: CollectionStrings.applyPresetBody,
      confirmLabel: CollectionStrings.applyPreset,
      icon: Icons.download_done,
    );
    if (!confirmed) return;
    OwnedItems? owned = ref.read(ownedItemsProvider(puuid)).value;
    if (owned == null) {
      try {
        owned = await ref.read(ownedItemsProvider(puuid).future);
      } on Object {
        owned = null; // Riot rejects unowned items; the save reports it.
      }
    }
    try {
      final skipped = await ref
          .read(loadoutProvider(puuid).notifier)
          .applyPreset(preset, owned: owned);
      Haptics.medium();
      showCollectionSnack(
        messenger,
        skipped == 0
            ? CollectionStrings.presetApplied(preset.name)
            : '${CollectionStrings.presetApplied(preset.name)}. '
                  '${CollectionStrings.presetSkipped(skipped)}',
      );
    } on LoadoutSaveException catch (e) {
      showLoadoutSaveError(messenger, router, e, puuid: puuid);
    }
  }

  Future<void> _rename(
    BuildContext context,
    WidgetRef ref,
    LoadoutPreset preset,
  ) async {
    final name = await showPresetNameDialog(context, initial: preset.name);
    if (name == null) return;
    await ref
        .read(loadoutPresetsProvider(puuid).notifier)
        .rename(preset.id, name);
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    LoadoutPreset preset,
    int index,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final notifier = ref.read(loadoutPresetsProvider(puuid).notifier);
    await notifier.delete(preset.id);
    showCollectionSnack(
      messenger,
      CollectionStrings.presetDeleted(preset.name),
      action: SnackBarAction(
        label: CollectionStrings.undo,
        onPressed: () => unawaited(notifier.restore(preset, index: index)),
      ),
    );
  }
}

/// "Tên bộ trang bị" dialog (Cupertino on iOS, Material elsewhere);
/// returns the trimmed name or `null`.
Future<String?> showPresetNameDialog(
  BuildContext context, {
  required String initial,
}) => showAdaptiveDialog<String>(
  context: context,
  barrierDismissible: true,
  builder: (context) => _PresetNameDialog(initial: initial),
);

class _PresetNameDialog extends StatefulWidget {
  const _PresetNameDialog({required this.initial});

  final String initial;

  @override
  State<_PresetNameDialog> createState() => _PresetNameDialogState();
}

class _PresetNameDialogState extends State<_PresetNameDialog> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.initial)
        ..selection = TextSelection(
          baseOffset: 0,
          extentOffset: widget.initial.length,
        );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = normalizePresetName(_controller.text);
    if (name == null) return;
    Navigator.of(context).pop(name);
  }

  @override
  Widget build(BuildContext context) {
    final valid = normalizePresetName(_controller.text) != null;
    if (isCupertino(context)) {
      return CupertinoAlertDialog(
        title: const Text(CollectionStrings.presetNameTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: _controller,
            autofocus: true,
            maxLength: kPresetNameMaxLength,
            placeholder: CollectionStrings.presetNameHint,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(CommonStrings.cancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: valid ? _submit : null,
            child: const Text(CommonStrings.save),
          ),
        ],
      );
    }
    return AlertDialog(
      title: const Text(CollectionStrings.presetNameTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: kPresetNameMaxLength,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
        decoration: const InputDecoration(
          hintText: CollectionStrings.presetNameHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(CommonStrings.cancel),
        ),
        FilledButton(
          onPressed: valid ? _submit : null,
          child: const Text(CommonStrings.save),
        ),
      ],
    );
  }
}

/// One preset: name, date, Vandal / Phantom skins, card; "Áp dụng".
class PresetCard extends StatelessWidget {
  const PresetCard({
    super.key,
    required this.preset,
    required this.db,
    required this.busy,
    required this.onApply,
    required this.onRename,
    required this.onDelete,
  });

  final LoadoutPreset preset;
  final ContentDb db;
  final bool busy;
  final VoidCallback onApply;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  String? _render(String weaponId) {
    final g = preset.gun(weaponId);
    if (g == null) return null;
    final chroma = g.chromaId == null ? null : db.skinChroma(g.chromaId!);
    return chroma?.fullRender ??
        chroma?.displayIcon ??
        (g.skinId == null ? null : db.skinByAnyUuid(g.skinId!)?.image);
  }

  Future<void> _actions(BuildContext context) async {
    final picked = await showActionSheet<String>(
      context,
      title: preset.name,
      actions: const [
        SheetAction(
          value: 'rename',
          label: CollectionStrings.renamePreset,
          icon: Icons.edit_outlined,
        ),
        SheetAction(
          value: 'delete',
          label: CollectionStrings.deletePreset,
          icon: Icons.delete_outline,
          destructive: true,
        ),
      ],
    );
    switch (picked) {
      case 'rename':
        onRename();
      case 'delete':
        onDelete();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final card = preset.cardId == null ? null : db.card(preset.cardId!);
    final muted = scheme.onSurfaceVariant;
    return ValCard(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: the preset's wide card art, faded under the name.
          Stack(
            children: [
              Positioned.fill(
                child: NetImage(
                  card?.wideArt,
                  fit: BoxFit.cover,
                  showSkeleton: false,
                  opacity: 0.28,
                  error: const SizedBox.shrink(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: NetImage(
                        card?.smallArt,
                        width: 44,
                        height: 44,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            preset.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            CollectionStrings.presetSavedAt(
                              formatDate(preset.createdAt),
                            ),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: CollectionStrings.presetActions,
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () => unawaited(_actions(context)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
            child: Row(
              children: [
                for (final (i, w) in const [
                  SpecialIds.vandal,
                  SpecialIds.phantom,
                ].indexed) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(8, 8, 8, 6),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 44,
                            child: NetImage(_render(w), fit: BoxFit.contain),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            db.weapon(w)?.displayName ?? CommonStrings.dash,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: busy ? null : onApply,
              icon: const Icon(Icons.download_done),
              label: const Text(CollectionStrings.applyPreset),
            ),
          ),
        ],
      ),
    );
  }
}
