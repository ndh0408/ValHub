import 'package:flutter/foundation.dart';

import '../../../core/domain/competitive/competitive.dart' show isUuid;
import '../../../core/riot/riot_ids.dart';
import '../../../core/util/json.dart';

/// The `Identity` block of the player's own loadout (P-8, EP §7.1): card,
/// title, level border and privacy flags. `AccountLevel` there is not
/// reliable, so the level comes from account XP (P-9).
@immutable
class PlayerIdentity {
  const PlayerIdentity({
    this.cardId,
    this.titleId,
    this.levelBorderId,
    this.hideAccountLevel = false,
    this.incognito = false,
  });

  /// Parses a whole P-8 response; never throws.
  static PlayerIdentity fromLoadout(Object? json) {
    final m = asMap(json);
    final id = m?.obj('Identity');
    String? nonZero(String? uuid) =>
        uuid == null || !isUuid(uuid) || uuid == SpecialIds.autoLevelBorder
        ? null
        : uuid;
    return PlayerIdentity(
      cardId: nonZero(id?.uuid('PlayerCardID')),
      titleId: nonZero(id?.uuid('PlayerTitleID')),
      levelBorderId: nonZero(id?.uuid('PreferredLevelBorderID')),
      hideAccountLevel: id?.boolean('HideAccountLevel') ?? false,
      incognito: m?.boolean('Incognito') ?? false,
    );
  }

  /// Player card uuid (lowercase) → `ContentDb.card`.
  final String? cardId;

  /// Player title uuid → `ContentDb.title`.
  final String? titleId;

  /// `null` = automatic border.
  final String? levelBorderId;
  final bool hideAccountLevel;
  final bool incognito;
}
