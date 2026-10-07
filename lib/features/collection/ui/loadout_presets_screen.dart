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
import '../../../core/riot/riot_ids.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/loadout_actions.dart';

import 'package:valvn/core/l10n/l10n.dart';

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
      return NoAccountPage(title: context.l10n.collectionPresetsTitle);
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
      final messages = context.l10n;
      final messenger = ScaffoldMessenger.maybeOf(context);
      final proposedName = notifier.suggestedName;
      final name = await showPresetNameDialog(context, initial: proposedName);
      if (name == null) return;
      // Snapshot what is equipped right now (the game may have changed it).
      LoadoutSnapshot? current;
      try {
        current = await ref.refresh(loadoutProvider(puuid).future);
      } on Object {
        current = ref.read(loadoutProvider(puuid)).value;
      }
      if (current == null) return;
      final preset = await notifier.save(
        current.loadout,
        name: name,
        proposedName: proposedName,
        defaultName: messages.loadoutDefaultPresetName,
      );
      showCollectionSnack(
        messenger,
        messages.collectionPresetSaved(preset.name),
      );
    }

    return SubPageScaffold(
      title: context.l10n.collectionPresetsTitle,
      subtitle: context.l10n.collectionPresetsNote,
      onRefresh: () => refreshCollection(ref, puuid),
      bottomBar: FilledButton.icon(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        onPressed: snapshot == null || notifier.isFull || saving
            ? null
            : () => unawaited(save()),
        icon: const Icon(Icons.bookmark_add_outlined),
        label: Text(context.l10n.collectionSavePreset),
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
          SliverToBoxAdapter(
            child: CollectionNotice(
              icon: Icons.inventory_2_outlined,
              text: context.l10n.collectionPresetsFull,
            ),
          ),
        if (presets.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              title: context.l10n.collectionPresetsEmptyTitle,
              message: context.l10n.collectionPresetsEmpty,
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
    final l10nBeforeAwait = context.l10n;

    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final router = GoRouter.maybeOf(context);
    final confirmed = await showConfirmDialog(
      context,
      title: l10nBeforeAwait.collectionApplyPresetTitle(preset.name),
      message: l10nBeforeAwait.collectionApplyPresetBody,
      confirmLabel: l10nBeforeAwait.collectionApplyPreset,
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
            ? l10nBeforeAwait.collectionPresetApplied(preset.name)
            : '${l10nBeforeAwait.collectionPresetApplied(preset.name)}. '
                  '${l10nBeforeAwait.collectionPresetSkipped(skipped)}',
      );
    } on LoadoutSaveException catch (e) {
      showLoadoutSaveError(l10n, messenger, router, e, puuid: puuid);
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
    final l10nBeforeAwait2 = context.l10n;

    final messenger = ScaffoldMessenger.maybeOf(context);
    final notifier = ref.read(loadoutPresetsProvider(puuid).notifier);
    await notifier.delete(preset.id);
    showCollectionSnack(
      messenger,
      l10nBeforeAwait2.collectionPresetDeleted(preset.name),
      action: SnackBarAction(
        label: l10nBeforeAwait2.collectionUndo,
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
        title: Text(context.l10n.collectionPresetNameTitle),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(
            controller: _controller,
            autofocus: true,
            maxLength: kPresetNameMaxLength,
            placeholder: context.l10n.collectionPresetNameHint,
            textInputAction: TextInputAction.done,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.l10n.commonCancel),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: valid ? _submit : null,
            child: Text(context.l10n.commonSave),
          ),
        ],
      );
    }
    return AlertDialog(
      title: Text(context.l10n.collectionPresetNameTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: kPresetNameMaxLength,
        textInputAction: TextInputAction.done,
        onChanged: (_) => setState(() {}),
        onSubmitted: (_) => _submit(),
        decoration: InputDecoration(
          hintText: context.l10n.collectionPresetNameHint,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonCancel),
        ),
        FilledButton(
          onPressed: valid ? _submit : null,
          child: Text(context.l10n.commonSave),
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
    final l10nBeforeAwait3 = context.l10n;

    final picked = await showActionSheet<String>(
      context,
      title: preset.name,
      actions: [
        SheetAction(
          value: 'rename',
          label: l10nBeforeAwait3.collectionRenamePreset,
          icon: Icons.edit_outlined,
        ),
        SheetAction(
          value: 'delete',
          label: l10nBeforeAwait3.collectionDeletePreset,
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
                            context.l10n.collectionPresetSavedAt(
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
                      tooltip: context.l10n.collectionPresetActions,
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
                            db.weapon(w)?.displayName ??
                                context.l10n.commonDash,
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
          // Outlined, not the red fill: one per card made the list a stack
          // of red bars, and "Lưu trang bị hiện tại" is the page's primary
          // action. (The theme paints every FilledButton red, tonal too.)
          // Applying still asks first.
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(44),
              ),
              onPressed: busy ? null : onApply,
              icon: const Icon(Icons.download_done),
              label: Text(context.l10n.collectionApplyPreset),
            ),
          ),
        ],
      ),
    );
  }
}
