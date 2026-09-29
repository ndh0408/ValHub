/// Owned cosmetics resolved with content, sorted for the pickers and the
/// browser (S31, S32, S37, S39). Items unknown to the content (new patch)
/// are left out; defaults are included (CA §6).
library;

import '../../../core/content/content_db.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/riot/riot_ids.dart';
import 'collection_search.dart';

/// Owned player cards, A → Z.
List<PlayerCard> ownedCards(OwnedItems owned, ContentDb db) =>
    [for (final id in owned.playerCardUuids) ?db.card(id)]
      ..sort((a, b) => compareNames(a.displayName, b.displayName));

/// Owned titles, A → Z, without the empty "no title".
List<PlayerTitle> ownedTitles(OwnedItems owned, ContentDb db) => [
  for (final id in owned.titleUuids)
    if (db.title(id) case final t? when !t.isNoTitle) t,
]..sort((a, b) => compareNames(a.text, b.text));

/// Owned sprays, A → Z, without the null spray.
List<Spray> ownedSprays(OwnedItems owned, ContentDb db) => [
  for (final id in owned.sprayUuids)
    if (db.spray(id) case final s?
        when !s.isNullSpray && s.uuid != SpecialIds.nullSpray)
      s,
]..sort((a, b) => compareNames(a.displayName, b.displayName));

/// Owned Flex items, A → Z.
List<FlexItem> ownedFlex(OwnedItems owned, ContentDb db) =>
    [for (final id in owned.flexUuids) ?db.flex(id)]
      ..sort((a, b) => compareNames(a.displayName, b.displayName));
