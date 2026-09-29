import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/riot/riot_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/util/format.dart';
import '../collection_strings.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/loadout_actions.dart';

/// S38 "Bộ trang bị đã lưu" (local presets per account). Route
/// `/collection/presets`.
class LoadoutPresetsScreen extends ConsumerWidget {
  const LoadoutPresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.presetsTitle)),
      body: CollectionAccountGate(
        builder: (context, account) => _PresetsBody(puuid: account.puuid),
      ),
    );
  }
}

class _PresetsBody extends ConsumerWidget {
  const _PresetsBody({required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final presets = ref.watch(loadoutPresetsProvider(puuid));
    final notifier = ref.read(loadoutPresetsProvider(puuid).notifier);
    final loadout = ref.watch(loadoutProvider(puuid));
    final snapshot = loadout.value;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final saving = snapshot?.isPending ?? false;

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

    return RefreshIndicator(
      onRefresh: () => refreshCollection(ref, puuid),
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          SavingBar(visible: saving),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: snapshot == null || notifier.isFull || saving
                  ? null
                  : () => unawaited(save()),
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text(CollectionStrings.savePreset),
            ),
          ),
          if (snapshot == null && loadout.hasError && !loadout.isLoading)
            ErrorView(
              error: loadout.error!,
              puuid: puuid,
              compact: true,
              onRetry: () => ref.invalidate(loadoutProvider(puuid)),
            )
          else if (snapshot == null)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Skeleton(height: 4),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Text(
              notifier.isFull
                  ? CollectionStrings.presetsFull
                  : CollectionStrings.presetsNote,
              style: theme.textTheme.bodySmall?.copyWith(
                color: notifier.isFull
                    ? valColorsOf(context).warning
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          if (presets.isEmpty)
            const EmptyView(
              message: CollectionStrings.presetsEmpty,
              icon: Icons.bookmarks_outlined,
            ),
          for (final (index, preset) in presets.indexed)
            Dismissible(
              key: ValueKey(preset.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                color: ValColors.red,
                child: const Icon(Icons.delete_outline, color: Colors.white),
              ),
              onDismissed: (_) =>
                  unawaited(_delete(context, ref, preset, index)),
              child: PresetCard(
                preset: preset,
                db: db,
                busy: saving || snapshot == null,
                onApply: () => unawaited(_apply(context, ref, preset)),
                onRename: () => unawaited(_rename(context, ref, preset)),
                onDelete: () => unawaited(_delete(context, ref, preset, index)),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _apply(
    BuildContext context,
    WidgetRef ref,
    LoadoutPreset preset,
  ) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final router = GoRouter.maybeOf(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(CollectionStrings.applyPresetTitle(preset.name)),
        content: const Text(CollectionStrings.applyPresetBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(CommonStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(CollectionStrings.applyPreset),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
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

/// "Tên bộ trang bị" dialog; returns the trimmed name or `null`.
Future<String?> showPresetNameDialog(
  BuildContext context, {
  required String initial,
}) => showDialog<String>(
  context: context,
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final card = preset.cardId == null ? null : db.card(preset.cardId!);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 4, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
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
                  PopupMenuButton<String>(
                    tooltip: CollectionStrings.presetActions,
                    onSelected: (v) => v == 'rename' ? onRename() : onDelete(),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'rename',
                        child: Text(CollectionStrings.renamePreset),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text(CollectionStrings.deletePreset),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Row(
                  children: [
                    for (final w in const [
                      SpecialIds.vandal,
                      SpecialIds.phantom,
                    ]) ...[
                      Expanded(
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: NetImage(_render(w), fit: BoxFit.contain),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    onPressed: busy ? null : onApply,
                    icon: const Icon(Icons.download_done),
                    label: const Text(CollectionStrings.applyPreset),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
