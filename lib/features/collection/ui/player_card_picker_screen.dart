import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/content/models/cosmetic_models.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../collection_strings.dart';
import '../data/collection_items.dart';
import '../data/collection_search.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/loadout_actions.dart';

/// S31 "Chọn thẻ người chơi". Route `/collection/card`.
class PlayerCardPickerScreen extends ConsumerStatefulWidget {
  const PlayerCardPickerScreen({super.key});

  @override
  ConsumerState<PlayerCardPickerScreen> createState() =>
      _PlayerCardPickerScreenState();
}

class _PlayerCardPickerScreenState
    extends ConsumerState<PlayerCardPickerScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.playerCardTitle)),
      body: CollectionAccountGate(
        builder: (context, account) => Column(
          children: [
            CollectionSearchField(
              hint: CollectionStrings.searchCards,
              onChanged: (v) => setState(() => _search = v),
            ),
            Expanded(
              child: LoadoutDataBuilder(
                puuid: account.puuid,
                loading: const CollectionGridSkeleton(childAspectRatio: 0.5),
                builder: (context, snapshot, owned, db) {
                  final equipped = snapshot.loadout.identity.playerCardId;
                  final cards = [
                    for (final c in ownedCards(owned, db))
                      if (matchesSearch(_search, [c.displayName])) c,
                  ];
                  return RefreshIndicator(
                    onRefresh: () => refreshCollection(ref, account.puuid),
                    child: Column(
                      children: [
                        SavingBar(visible: snapshot.isPending),
                        Expanded(
                          child: cards.isEmpty
                              ? ListView(
                                  children: const [
                                    EmptyView(
                                      message: CollectionStrings.noResults,
                                      icon: Icons.search_off,
                                    ),
                                  ],
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.fromLTRB(
                                    16,
                                    4,
                                    16,
                                    24,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithMaxCrossAxisExtent(
                                        maxCrossAxisExtent: 130,
                                        mainAxisSpacing: 10,
                                        crossAxisSpacing: 10,
                                        mainAxisExtent: tileExtent(
                                          context,
                                          image: 200,
                                        ),
                                      ),
                                  itemCount: cards.length,
                                  itemBuilder: (context, i) {
                                    final card = cards[i];
                                    return ArtTile(
                                      image: card.largeArt ?? card.smallArt,
                                      label: card.displayName,
                                      imageFit: BoxFit.cover,
                                      imagePadding: EdgeInsets.zero,
                                      selected: card.uuid == equipped,
                                      onTap: () => unawaited(
                                        showCardPreview(
                                          context,
                                          puuid: account.puuid,
                                          card: card,
                                        ),
                                      ),
                                    );
                                  },
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

/// Preview of a card with "Trang bị" (S31 tap → preview).
Future<void> showCardPreview(
  BuildContext context, {
  required String puuid,
  required PlayerCard card,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => _CardPreviewSheet(puuid: puuid, card: card),
);

class _CardPreviewSheet extends ConsumerWidget {
  const _CardPreviewSheet({required this.puuid, required this.card});

  final String puuid;
  final PlayerCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final snapshot = ref.watch(loadoutProvider(puuid)).value;
    final isEquipped = snapshot?.loadout.identity.playerCardId == card.uuid;
    final saving = snapshot?.isPending ?? false;
    final height = MediaQuery.sizeOf(context).height;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height * 0.5),
              child: AspectRatio(
                aspectRatio: 268 / 640,
                child: NetImage(
                  card.largeArt ?? card.smallArt,
                  fit: BoxFit.contain,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              card.displayName,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AspectRatio(
                aspectRatio: 452 / 128,
                child: NetImage(card.wideArt, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: isEquipped || saving || snapshot == null
                  ? null
                  : () async {
                      final navigator = Navigator.of(context);
                      final ok = await applyLoadoutChange(
                        context,
                        ref,
                        puuid: puuid,
                        change: SetPlayerCard(card.uuid),
                        successMessage: CollectionStrings.equippedItem(
                          card.displayName,
                        ),
                      );
                      if (ok && navigator.mounted) navigator.pop();
                    },
              icon: Icon(isEquipped ? Icons.check : Icons.style_outlined),
              label: Text(
                isEquipped
                    ? CollectionStrings.equipped
                    : (saving
                          ? CollectionStrings.saving
                          : CollectionStrings.equip),
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
                disabledBackgroundColor: isEquipped
                    ? ValColors.red.withValues(alpha: 0.35)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
