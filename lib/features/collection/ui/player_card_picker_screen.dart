import 'package:valvn/core/l10n/labels/content_labels.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/models/cosmetic_models.dart';
import '../../../core/domain/loadout/loadout.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/net_image.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/format.dart';
import '../collection_strings.dart';
import '../data/collection_items.dart';
import '../data/collection_search.dart';
import '../providers/collection_providers.dart';
import 'widgets/collection_widgets.dart';
import 'widgets/identity_preview.dart';
import 'widgets/loadout_actions.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Tall card art grid: tile width limit and art height.
const _cardMaxExtent = 130.0;
const _cardArtHeight = 200.0;

/// S31 "Đổi thẻ người chơi". Route `/collection/card`.
///
/// The equipped card as the in-game lobby banner (name + title over the
/// art; the hub banner flies into it), a pinned search and the grid of owned
/// cards. A tap opens the preview sheet with "Trang bị".
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
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return NoAccountPage(title: context.l10n.collectionPlayerCardTitle);
    }
    final puuid = account.puuid;
    final search = CollectionSearchField(
      hint: context.l10n.collectionSearchCards,
      initialValue: _search,
      onChanged: (v) => setState(() => _search = v),
    );
    return SubPageScaffold(
      title: context.l10n.collectionPlayerCardTitle,
      subtitle: context.l10n.collectionPlayerCardSubtitle,
      onRefresh: () => refreshCollection(ref, puuid),
      slivers: loadoutSlivers(
        ref,
        puuid: puuid,
        loading: const _CardPickerSkeleton(),
        data: (snapshot, owned, db) {
          final identity = snapshot.loadout.identity;
          final equippedId = identity.playerCardId;
          final equipped = equippedId == null ? null : db.card(equippedId);
          final title = db.title(identity.titleOrNone);
          final all = ownedCards(owned, db);
          final cards = [
            for (final c in all)
              if (matchesSearch(_search, [c.displayName])) c,
          ];
          final filtering = _search.trim().isNotEmpty;
          return [
            if (snapshot.isFromCache)
              const SliverToBoxAdapter(child: CachedLoadoutBanner()),
            SliverToBoxAdapter(child: SavingBar(visible: snapshot.isPending)),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: IdentityPreview(
                  heroTag: CollectionHeroTags.equippedCard,
                  cardArt: equipped?.wideArt,
                  name: account.gameName,
                  title: title == null || title.isNoTitle
                      ? null
                      : title.localizedText(context.l10n),
                  badge: ArtPill(
                    label: context.l10n.collectionEquipped,
                    icon: Icons.check,
                  ),
                  semanticsLabel: context.l10n.collectionEquippedCardLabel(
                    equipped?.displayName ?? context.l10n.collectionUnknownCard,
                  ),
                  onTap: equipped == null
                      ? null
                      : () => unawaited(
                          showCardPreview(
                            context,
                            puuid: puuid,
                            card: equipped,
                          ),
                        ),
                ),
              ),
            ),
            if (equipped != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 2, 24, 6),
                  child: Text(
                    equipped.displayName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            pinnedSearchSliver(
              context,
              key: const ValueKey('card-search'),
              search: search,
            ),
            SliverToBoxAdapter(
              child: SummaryStrip(
                text: filtering
                    ? context.l10n.collectionSummaryFilteredItems(
                        cards.length,
                        all.length,
                      )
                    : context.l10n.collectionCardsCount(
                        formatNumber(all.length),
                      ),
                highlighted: filtering,
              ),
            ),
            if (cards.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: all.isEmpty
                    ? EmptyView(
                        title: context.l10n.collectionBrowseEmptyTitle,
                        message: context.l10n.collectionBrowseEmpty,
                        icon: Icons.style_outlined,
                      )
                    : EmptyView(
                        title: context.l10n.collectionNoResultsTitle,
                        message: context.l10n.collectionNoResults,
                        icon: Icons.search_off,
                      ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                sliver: SliverGrid.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: _cardMaxExtent,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    mainAxisExtent: tileExtent(context, image: _cardArtHeight),
                  ),
                  itemCount: cards.length,
                  itemBuilder: (context, i) {
                    final card = cards[i];
                    return ArtTile(
                      key: ValueKey(card.uuid),
                      image: card.largeArt ?? card.smallArt,
                      label: card.displayName,
                      imageFit: BoxFit.cover,
                      imagePadding: EdgeInsets.zero,
                      selected: card.uuid == equippedId,
                      onTap: () {
                        Haptics.selection();
                        unawaited(
                          showCardPreview(context, puuid: puuid, card: card),
                        );
                      },
                    );
                  },
                ),
              ),
          ];
        },
      ),
    );
  }
}

class _CardPickerSkeleton extends StatelessWidget {
  const _CardPickerSkeleton();

  @override
  Widget build(BuildContext context) => SkeletonShimmer(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 6, 16, 12),
          child: AspectRatio(
            aspectRatio: kWideCardRatio,
            child: Skeleton(radius: ValRadius.card, shimmer: false),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: Skeleton(height: 44, radius: ValRadius.pill, shimmer: false),
        ),
        SkeletonTileGrid(
          maxExtent: _cardMaxExtent,
          tileHeight: tileExtent(context, image: _cardArtHeight),
          rows: 2,
          shimmer: false,
        ),
      ],
    ),
  );
}

/// Preview of a card with "Trang bị" (S31 tap → preview): the tall art,
/// the wide lobby banner and the equip button.
Future<void> showCardPreview(
  BuildContext context, {
  required String puuid,
  required PlayerCard card,
}) => showValSheet<void>(
  context,
  title: card.displayName,
  subtitle: context.l10n.contentItemCard,
  builder: (context, _) => _CardPreviewSheet(puuid: puuid, card: card),
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
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: height * 0.42),
              child: AspectRatio(
                aspectRatio: 268 / 640,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(ValRadius.small),
                    boxShadow: const [
                      BoxShadow(color: Color(0x44000000), blurRadius: 16),
                    ],
                  ),
                  child: NetImage(
                    card.largeArt ?? card.smallArt,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(ValRadius.small),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SectionLabel(
            context.l10n.collectionLobbyBanner,
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(ValRadius.card),
            child: AspectRatio(
              aspectRatio: kWideCardRatio,
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
                    if (ok) Haptics.medium();
                    if (ok && navigator.mounted) navigator.pop();
                  },
            icon: Icon(isEquipped ? Icons.check : Icons.style_outlined),
            label: Text(
              isEquipped
                  ? context.l10n.collectionEquipped
                  : (saving
                        ? context.l10n.collectionSaving
                        : context.l10n.collectionEquip),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              disabledBackgroundColor: isEquipped
                  ? theme.colorScheme.primary.withValues(alpha: 0.35)
                  : null,
              disabledForegroundColor: isEquipped ? Colors.white : null,
            ),
          ),
        ],
      ),
    );
  }
}
