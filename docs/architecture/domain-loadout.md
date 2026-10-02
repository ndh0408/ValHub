# Loadout domain: `lib/core/domain/loadout/`

Shared, UI-free layer for the **collection** feature (S30–S39) and the
**live game** feature (S51 "Trang bị của người chơi"). It sits on top of the
core APIs (`PvpApi` P-8 / G-3 / G-7 / G-9 / G-10, `Prefs`, `JsonFileCache`,
`clockProvider`, `RiotException`) and the economy domain (`OwnedItems`), and
changes none of them.

```dart
import 'package:valvn/core/domain/loadout/loadout.dart';   // everything below
```

References: SUMMARY §6.2 P-8, §6.4 G-7/G-10, §7.1 (socket ids), §8.3 C3/U6/U7,
§13 U8; EP §7.1–§7.4; VF §6.4, §8.6.

| File | Contents |
|---|---|
| `loadout_models.dart` | `Loadout`, `GunLoadout`, `Expression`/`ExpressionType`, `LoadoutIdentity`, `LoadoutSnapshot` (raw + typed), `LoadoutKeys`, `kExpressionSlots`, `deepCopyJsonMap` |
| `loadout_changes.dart` | `LoadoutChange` (sealed) and its edits, `LoadoutEditException` |
| `loadout_repository.dart` | `LoadoutRepository` (fetch / save with the U8 safety net), `LoadoutSaveException`, `LoadoutSaveFailure` |
| `loadout_presets.dart` | `LoadoutPreset`, `PresetGun`, `PresetApplication`, `LoadoutPresetStore`, `normalizePresetName` |
| `match_loadouts.dart` | `MatchLoadouts`, `MatchPlayerLoadout`, `MatchGun`, `MatchPlayerIdentity`, `MatchSocketIds` |
| `loadout_providers.dart` | `loadoutProvider` + `LoadoutController`, `loadoutPresetsProvider`, `matchLoadoutsProvider`, `loadoutRepositoryProvider` |
| `loadout_strings.dart` | `LoadoutStrings` ("Không thể lưu trang bị", …) |

All parsers are pure, never throw, lowercase every uuid and read numbers as
`num` (`"7"` → 7).

---

## 1. Providers at a glance

| Provider | Type | Notes |
|---|---|---|
| `loadoutProvider(puuid)` | `AsyncNotifierProvider.autoDispose.family<LoadoutController, LoadoutSnapshot, String>` | P-8 GET; kept 10 min (`kLoadoutTtl`); offline copy under `acct/<puuid>/loadout` on `TransientException` (`isFromCache`); refetches after a re-login; caches the equipped card on the `Account` (A4) |
| `loadoutPresetsProvider(puuid)` | `NotifierProvider.family<LoadoutPresetsNotifier, List<LoadoutPreset>, String>` | newest first; stored under `keep.<puuid>.loadoutPresets` (survives sign-out, like the wishlist) |
| `matchLoadoutsProvider((puuid:, matchId:, pregame:))` | `FutureProvider.autoDispose.family<MatchLoadouts, MatchLoadoutsQuery>` | G-7 (pregame) or G-10 + identities from G-3 / G-9 (best effort); not cached |
| `loadoutRepositoryProvider` | `Provider<LoadoutRepository>` | low level |
| `loadoutPresetStoreProvider` | `Provider<LoadoutPresetStore>` | low level |

---

## 2. Reading (`loadout_models.dart`)

`LoadoutSnapshot { raw, loadout, receivedAt, isFromCache, isPending, isValid }`
keeps the **raw map exactly as Riot sent it** (deep-copied, so unknown 13.06
keys such as Agent ID / Mastery cosmetics round-trip) next to the typed view:

```dart
class Loadout {
  String? subject; int? version;
  List<GunLoadout> guns;            // every weapon Riot sent, Riot's order (never hard-code 21)
  List<Expression?> expressions;    // ActiveExpressions, index = slot (0 top, 1 right, 2 bottom, 3 left)
  LoadoutIdentity identity;         // card, title, level border, hideAccountLevel, accountLevel (unreliable)
  bool incognito;
  GunLoadout? gun(weaponId); Expression? expression(slot);
  String? weaponWithBuddyInstance(instanceId); Set<String> get usedBuddyInstances;
}
class GunLoadout { weaponId, skinId, skinLevelId, chromaId, charmInstanceId, charmId, charmLevelId; hasBuddy; isMelee }
class Expression { typeId, assetId; type (spray|flex|unknown); isSpray; isFlex; isEmpty (null spray) }
class LoadoutIdentity { playerCardId, playerTitleId, preferredLevelBorderId, hideAccountLevel, accountLevel;
                        isAutoLevelBorder; titleOrNone }
```

```dart
final snapshot = ref.watch(loadoutProvider(puuid));
AsyncValueView(
  value: snapshot,
  puuid: puuid,
  onRetry: () => ref.invalidate(loadoutProvider(puuid)),
  data: (s) => Text(db.card(s.loadout.identity.playerCardId ?? '')?.displayName ?? '–'),
);
// pull-to-refresh: ref.refresh(loadoutProvider(puuid).future)
```

---

## 3. Changing (`loadout_changes.dart`)

Every edit is a `LoadoutChange` that mutates **only its own keys** of a deep
copy of a fresh GET (EP §7.2 recipes):

| Change | Keys |
|---|---|
| `EquipSkin(weaponId:, skinId:, skinLevelId:, chromaId:)` | `SkinID`, `SkinLevelID`, `ChromaID` of one gun (also for level-only / chroma-only edits) |
| `EquipBuddy(weaponId:, buddyId:, buddyLevelId:, instanceId:)` | `CharmInstanceID`, `CharmID`, `CharmLevelID`; the same instance is **removed from any other gun** (one copy = one gun); melee → `LoadoutEditError.meleeBuddy` |
| `RemoveBuddy(weaponId:)` | deletes the three `Charm*` keys |
| `SetPlayerCard(id)`, `SetPlayerTitle(id)` / `.none()` | `Identity.PlayerCardID`, `Identity.PlayerTitleID` (`SpecialIds.noTitle` = "Không có danh hiệu") |
| `SetLevelBorder(id)` / `.auto()` | `Identity.PreferredLevelBorderID` (all-zero uuid = automatic) |
| `SetHideAccountLevel(bool)`, `SetIncognito(bool)` | `Identity.HideAccountLevel`, `Incognito` |
| `SetExpression(slot:, expression:)`, `.spray(slot, id)`, `.flex(slot, id)` | `ActiveExpressions[slot] = {TypeID, AssetID}` (missing earlier slots padded with the null spray; slot ≥ 4 rejected) |
| `LoadoutChange.all([...], skipInapplicable:)` (`CompositeChange`) | several edits, one PUT; lenient mode skips edits that do not fit (preset for a weapon that no longer exists…) |

`applyTo(raw)` mutates in place (only on a deep copy), `appliedTo(raw)` returns
a mutated copy, `isReflectedIn(loadout)` checks the result. Unknown weapon,
empty ids, melee buddy and bad slots throw `LoadoutEditException`.

### 3.1 Saving (U8)

`LoadoutRepository.save(puuid, change)`:

1. GET a **fresh** loadout (never a cached one; a non-loadout body such as a
   Cloudflare page → `invalidLoadout`, nothing sent);
2. apply the change to a deep copy of the raw map (`invalidChange` on
   `LoadoutEditException`);
3. skip the PUT when the body did not change;
4. PUT the **whole** object (with `Subject` + `Version` from the GET);
5. re-GET (fallback: the PUT response) and require `Version` to increase —
   without versions, require `change.isReflectedIn(after)`; otherwise
   `notPersisted` ("rolled back").

Only `LoadoutSaveException { failure, cause, message, detail, needsLogin,
riotError }` is thrown; `message` is always **"Không thể lưu trang bị"**.

`LoadoutController.apply(change)` (via `ref.read(loadoutProvider(puuid).notifier)`):

- shows the change at once (`snapshot.isPending == true`), runs saves one after
  another (`isSaving`), then publishes the confirmed loadout;
- on failure restores the previous value and rethrows the
  `LoadoutSaveException`; on `notPersisted` it also refetches to show Riot's
  truth.

```dart
Future<void> equip(BuildContext context, WidgetRef ref, LoadoutChange change) async {
  final l10n = context.l10n;
  final messenger = ScaffoldMessenger.maybeOf(context);
  final router = GoRouter.maybeOf(context);
  try {
    await ref.read(loadoutProvider(puuid).notifier).apply(change);   // user tapped "Trang bị"
  } on LoadoutSaveException catch (e) {
    showLoadoutSaveError(l10n, messenger, router, e, puuid: puuid);
  }
}
```

**Rules:** only call `apply` from an explicit user action (button / tap);
only equip items `OwnedItems` says are owned (Riot rejects the whole PUT
otherwise); buddy copies come from `OwnedItems.buddyInstances(levelUuid)`.

---

## 4. Presets (`loadout_presets.dart`, U6)

`LoadoutPreset { id, name, createdAt, guns (PresetGun), expressions, cardId,
titleId, levelBorderId }` — a snapshot of guns, wheel and identity
(`hideAccountLevel` and `incognito` are not part of presets).

```dart
final presets = ref.watch(loadoutPresetsProvider(puuid));
final n = ref.read(loadoutPresetsProvider(puuid).notifier);
await n.save(snapshot.loadout, name: input);    // name → normalizePresetName, default "Bộ trang bị 3" (n.suggestedName)
await n.rename(id, 'Rank');  await n.delete(id);  await n.restore(preset);   // undo
final skipped = await ref.read(loadoutProvider(puuid).notifier)
    .applyPreset(preset, owned: ownedItems);    // ONE PUT; items no longer owned are left out
```

`LoadoutPreset.toChange(owned:)` builds the lenient composite: skins (skipped
unless skin, level and chroma are owned), then buddy removals, then buddy
equips (instance must still be owned), wheel slots (spray / flex ownership),
card, title and level border; `PresetApplication.skipped` counts what was left
out. At most `kMaxLoadoutPresets` (50), names ≤ `kPresetNameMaxLength` (40).

---

## 5. Live-match loadouts (`match_loadouts.dart`, G8)

```dart
final q = (puuid: account.puuid, matchId: matchId, pregame: false);
final loadouts = ref.watch(matchLoadoutsProvider(q));            // AsyncValue<MatchLoadouts>
final p = loadouts.value?.player(playerPuuid);
p?.gun(SpecialIds.vandal)?.skinId;   // chromaId, skinLevelId, buddyId, buddyLevelId
p?.sprayIds; p?.flexIds; p?.playerCardId; p?.playerTitleId; p?.incognito; p?.characterId;
```

Or parse payloads you already have: `MatchLoadouts.parse(g10Json, matchJson:
g9Json)`, `MatchLoadouts.parseIdentities(g3OrG9Json)`. Both shapes are
handled (core-game `Loadouts[].{CharacterID, Loadout}`, pregame `Loadouts[]` =
loadout objects), as are `Expressions.AESSelections` (10.00+) and the old
`Sprays.SpraySelections`. Socket ids (`MatchSocketIds`): skin
`bcef87d6-…`, skin level `e7c63390-…`, chroma `3ad1b2b2-…`, buddy
`77258665-…`, buddy level `dd3bf334-…`. Honour `incognito` (SUMMARY U16).

---

## 6. Testing

Build containers with `ProviderContainer.test(retry: (_, _) => null, …)` and
override `pvpApiProvider` (mocktail `MockPvpApi` answering `playerLoadout` /
`putPlayerLoadout`), `prefsProvider` (`createTestPrefs()`),
`jsonFileCacheProvider` (in-memory subclass), `clockProvider` and
`accountProvider.overrideWith((ref, puuid) => null)`. Fixtures and helpers:
`test/core/domain/loadout/loadout_fixtures.dart` (`loadoutJson()` — a real v3
body with an unknown 13.06 key that must round-trip —, `entitlementsFor(type)`,
ids in `Lx`). Widget tests keep the real controller and fake Riot instead:
`test/features/collection/collection_test_harness.dart` (`FakeRiot` serves the
loadout, records every PUT body and bumps `Version`).

---

## 7. Screens built on this domain (collection feature)

| Route / helper | Screen |
|---|---|
| `CollectionRoutes.root` `/collection` | S30 hub: equipped card, loadout rows, level border / hide level / incognito, browse rows, collection value |
| `CollectionRoutes.card`, `.title` | S31 / S32 pickers (`SetPlayerCard`, `SetPlayerTitle`) |
| `CollectionRoutes.weapons`, `.weapon(id)`, `.weaponSkin(w, s)` | S33 weapons by category → S34 skin picker → S35 customize (`EquipSkin`) |
| `showBuddyPickerSheet(context, weaponId:)` | S36 buddies "Còn n/m", "Gỡ phụ kiện" (`EquipBuddy`, `RemoveBuddy`) |
| `CollectionRoutes.expressions` | S37 wheel (`SetExpression`) |
| `CollectionRoutes.presets` | S38 presets (`loadoutPresetsProvider`, `applyPreset`) |
| `CollectionRoutes.browse(type)` | S39 browse skins / buddies / sprays / cards / titles / Flex |

Search / tier filter / sort for skin lists (`SkinQuery`, `querySkins`,
accent-insensitive `matchesSearch`) live in
`lib/features/collection/data/` and can be imported by other features
(wishlist, catalog) that need the same C7 behaviour.
