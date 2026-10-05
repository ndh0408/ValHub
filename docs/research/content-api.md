# valorant-api.com — static content API (tiếng Việt / `vi-VN`)

> Research date: **2026-09-28**. Every response shape, count and size below was captured with `curl`
> against the live API on this date (not copied from docs), with `?language=vi-VN` and compared
> field-by-field with `en-US`.
> Game version at capture time (`/v1/version`): `release-13.06-shipping-13-5435758`,
> manifestId `67AF51413C6922AE`, buildDate `2026-09-03T00:14:05Z`.
>
> Anything not confirmed first-hand is marked **UNVERIFIED**.

Sources used:

- `[LIVE]`: live `curl` of `https://valorant-api.com/v1/*` and `https://media.valorant-api.com/*` on 2026-09-28
- `[VAD]`: https://valapidocs.techchrism.me (Prices, Storefront, Owned Items, Player Loadout, Match Details,
  Competitive Updates, Player MMR, Fetch Content pages). The GitHub markdown docs
  (`techchrism/valorant-api-docs/docs/*.md`) say they are deprecated and point to that site.
- `[SP]`: github.com/giorgi-o/SkinPeek `valorant/cache.js`, `valorant/shop.js`, `misc/util.js` (master)
- `[VS]`: github.com/VShopApp/mobile `utils/valorant-api.ts`, `utils/valorant-assets.ts`, `utils/misc.ts`
  (an open-source React Native store-checker app, the closest open-source analogue to ValBuddy)
- `[GH]`: GitHub code search for match `gameMode` path constants (valradar, Riot4J, Hako, MATCH_BE, Bifrost-screen)
- `[RIOT-SUP]`: https://support.riotgames.com/en-us/valorant/store/price-tiers-for-skins-in-valorant (last updated 2026-02-20)
- Sibling doc: `docs/research/riot-endpoints.md` (Riot PD/GLZ endpoints). This file only covers the
  **content** side and the UUID joins between the two.

---

## 0. TL;DR

- **Base:** `https://valorant-api.com/v1/...`, public, no key needed, served through Cloudflare. Every response is
  `{"status":200,"data":…}`. Errors come back as `{"status":404,"error":"the requested uuid was not found"}`.
- **Language:** `?language=vi-VN`. The value is **case-sensitive**: `vi-vn` and `vi` return 404
  `"the requested language was not found"`. 18 locales are supported (`en-GB` is not). `language=all` turns
  every localized string into a `{locale: text}` object, which is about 3x bigger.
- **Only one call per content type is needed.** `/v1/weapons` already contains the skins with their levels and
  chromas, plus the weapon↔skin relation that `/v1/weapons/skins` does not have. `/v1/buddies` and `/v1/sprays`
  already contain their levels. The flat `skinlevels`, `skinchromas`, `buddies/levels` and `sprays/levels`
  endpoints only make sense as one-off lookups by UUID.
- **Full vi-VN cache** (22 endpoints the app needs): **7.8 MB raw JSON, about 1.0 MB gzip on the wire**.
  `/v1/weapons` alone is 3.65 MB raw / 513 KB gzip / 418 KB brotli. Parse it in a background isolate.
- **Cache invalidation:** key the cache on `/v1/version.manifestId`, the language and your own schema version.
  Refetch everything when that key changes. Also refetch on a miss (a Riot UUID that is not in the cache) and
  fall back to the per-UUID endpoint. There is no ETag, and `Last-Modified` is only the edge-cache time.
- **Colors are `RRGGBBAA` hex** (competitive tiers, content tiers, agent gradients). Flutter's `Color(0xAARRGGBB)`
  expects the alpha byte first, so the value must be reordered.
- **Rank tables depend on the episode.** Tier numbers shifted in Episode 5 when Ascendant was added (tier 24 is
  Radiant before E5 and Immortal 1 from E5 on). Always resolve `seasonId` → `/v1/seasons/competitive` →
  `competitiveTiersUuid` → table. The current act (V26 Act V) uses `Episode5_CompetitiveTierDataTable`
  (`03621f52-342b-cf4e-4f86-9350a49c6d04`).
- **Prices are not in valorant-api.** Owned or wishlist skins use Riot `GET pd.{shard}.a.pvp.net/store/v1/offers/`
  (authenticated, status in 2026 **UNVERIFIED**), keyed by the skin's **level-1 UUID**. The fallback is Riot's
  official tier prices: Select 875, Deluxe 1275, Premium 1775 VP, with Ultra and Exclusive varying.
- **Localization:** most names are localized, but agent names, map names and many brand words stay English, and
  some strings leak raw loc keys, embedded `\n` or trailing spaces. Clean every string before display (§7.4).

---

## 1. API basics (verified `[LIVE]`)

| Property | Observed value |
|---|---|
| Envelope | `{"status":200,"data":<object or array>}` |
| Error envelope | `{"status":404,"error":"the requested uuid was not found"}` (HTTP 404), `{"status":404,"error":"the requested language was not found"}` |
| Single item | `/v1/<type>/{uuid}` works for weapons, weapons/skins, skinlevels, skinchromas, bundles, buddies, buddies/levels, sprays, playercards, playertitles, maps, agents, competitivetiers, contracts, … |
| UUID case | Path UUIDs are **case-insensitive** (`/v1/weapons/skinlevels/BA42FE63-…` returns 200). Response UUIDs are always lowercase. Lowercase every Riot UUID before looking it up in local maps. |
| Languages accepted | `ar-AE de-DE en-US es-ES es-MX fr-FR id-ID it-IT ja-JP ko-KR pl-PL pt-BR ru-RU th-TH tr-TR vi-VN zh-CN zh-TW`. `en-GB`, `vi`, `vi-vn` all return 404. The default (no param) is `en-US`. |
| `language=all` | Each localized string becomes `{"en-US": "...", "vi-VN": "...", ...}`. `/v1/weapons?language=all` is 10.8 MB raw / 1.33 MB gzip. Not worth it for a Vietnamese-only UI. |
| API cache headers | `cache-control: public, max-age=14400, stale-while-revalidate=60, stale-if-error=60` (4 h). `cf-cache-status: HIT`. `last-modified` is present but it is the edge fetch time, not a content timestamp. **No `ETag`.** `If-Modified-Since` returns 304 but tells you nothing about content changes. |
| Compression | `gzip` and `br` are supported. Dart `HttpClient` sends `Accept-Encoding: gzip` and decompresses by default. |
| Images | `https://media.valorant-api.com/<type>/<uuid>/<field>.png`, `cache-control: max-age=1209600` (14 days). The URLs follow a pattern, so they can be rebuilt from the UUID and field name. |
| Videos | `streamedVideo` points to `https://valorant.dyn.riotcdn.net/x/videos/release-13.06/<id>_default_universal.mp4` (Riot CDN). **The patch branch is part of the path**, so the URLs change every patch. A `HEAD` request returned **403** but `GET` with `Range: bytes=0-1000` returned **206**, so probe with a ranged GET and never with HEAD. |
| Rate limits | **UNVERIFIED.** None are documented or visible in the headers. Responses are Cloudflare-cached. Treat the service as best-effort: it is third-party, run by "Officer", and has no SLA. |
| Docs site | `https://dash.valorant-api.com` is a Blazor-server app and could not be scraped, so all field lists here come from live responses. |

### Languages: which fields actually change with `vi-VN`

Measured by diffing each string leaf of `vi-VN` against `en-US` for the same UUID. `n/m` means n of m values differ.

| Endpoint | Localized (vi-VN differs) | Stays English / not localized |
|---|---|---|
| weapons | `skins[].displayName` 1402/1415, `levels[].displayName` 2660/2692, `chromas[].displayName` 2862/2931, `shopData.categoryText` 20/20 | weapon `displayName` (only **Warden → "Quản Đốc"** and **Melee → "Cận Chiến"** change), `category`, `levelItem`, `weaponStats.*` enums |
| bundles | `displayName` 79/327, `description` 79/327, `displayNameSubText` 166/166, `extraDescription`, `promoDescription` | most bundle names (brand names such as "Reaver", "VCT x T1") |
| buddies | `displayName` 898/898 | `levels[].displayName` is mostly an **internal dev name** (e.g. `AggrobotSkateboard`, `Coin_EP2_A1`), so show the parent buddy name instead |
| sprays | `displayName` 920/921, `levels[].displayName` 357/921 | 106 level names are internal keys (`KAYO_Faces`, `NT_NT`), so show the parent spray name |
| playercards | `displayName` 986/1016 | |
| playertitles | `displayName` 419/443, `titleText` 353/442 | |
| levelborders | `displayName` 25/25 ("Khung Cấp 20") | |
| agents | `description`, `role.displayName`, `role.description`, `abilities[].displayName` 115/119, `abilities[].description`, `characterTags[]` | **agent `displayName`** and `developerName` |
| maps | `tacticalDescription` ("Khu A/B"), `callouts[].regionName` 345/346, `callouts[].superRegionName` 69/346 ("Bên Tấn Công") | **map `displayName`** (only "Basic Training → Tập Luyện Cơ Bản"), `mapUrl`, `coordinates` |
| gamemodes | `displayName` 14/18, `description`, `duration` ("30-40 PHÚT"), custom labels | "Knockout", "Retake", "Skirmish", "Gauntlet: Glitched" stay English |
| gamemodes/queues | `displayName` 22/31, `dropdownText`, `selectedText`, `description` | `queueId` |
| competitivetiers | `tierName` 121/126, `divisionName` | "RADIANT", `division` enum, colors |
| seasons | `displayName` ("PHẦN V"), `title` ("V26 // PHẦN V") | "V25", "V26", "Closed Beta" |
| contracts | `displayName` 86/87 | reward types/uuids |
| currencies | `displayName` 4/4 (but "VALORANT POINT", "RADIANITE Point", "Kingdom Credit" are just re-cased English; only "Huy Hiệu Đặc Vụ" is Vietnamese) | |
| contenttiers | `displayName` 5/5 | `devName` (use this for logic) |
| events | `displayName` 14/18, `shortDisplayName` 12/18 | |
| gear | `displayName`, `description`, `details[]`, `shopData.categoryText` | |
| ceremonies | `displayName` 6/6 | |
| themes | `displayName` 83/456 | |
| flex | `displayName`, `displayNameAllCaps` | |

---

## 2. Versioning and cache invalidation

### 2.1 `/v1/version` (no language parameter; about 363 bytes)

```json
{"status":200,"data":{
  "manifestId":"67AF51413C6922AE",
  "branch":"release-13.06",
  "mappingsUrl":"https://media.valorant-api.com/mappings/release-13.06_br.usmap",
  "version":"13.06.00.5435758",
  "buildVersion":"13",
  "engineVersion":"5.3.2.0",
  "riotClientVersion":"release-13.06-shipping-13-5435758",
  "riotClientBuild":"111.0.0.3261.5663",
  "buildDate":"2026-09-03T00:14:05Z"}}
```

- `riotClientVersion` is also the value for the Riot `X-Riot-ClientVersion` header (see `riot-endpoints.md`).
- `manifestId` identifies the game build that valorant-api extracted its data from. It is the best cache key:
  [SP] keys everything on `manifestId`, and [VS] keys on `riotClientVersion` plus language.

### 2.2 Recommended strategy (Flutter)

```
cacheKey = "${version.manifestId}|vi-VN|schema=<N>"    // N = our own parser/model version
```

1. On app start (and on resume if the last check was more than 6 h ago), `GET /v1/version`. It is tiny and edge-cached.
2. If `cacheKey` matches the stored key **and** the cache is younger than 7 days, use the disk cache. Otherwise
   download all endpoints in parallel (about 1 MB gzip), write them to temp files, parse and validate, then
   swap them in atomically and store the new key. The 7-day refresh is there because valorant-api sometimes
   adds or fixes data (new bundles, translations) without a manifest change (**UNVERIFIED how often**).
3. **On a miss:** when a Riot UUID from the store, loadout or match data is not in the cache:
   - call the per-UUID endpoint (`/v1/weapons/skinlevels/{id}?language=vi-VN`, `/v1/bundles/{id}?...`),
     keep the result in a small "overlay" cache, and
   - schedule a full refresh, debounced to at most once every 6 h.
   - If it is still missing, render a placeholder ("Vật phẩm không xác định") and do not crash. The sibling doc
     notes that new bundles may 404 on valorant-api for a few hours after a patch.
4. Bump `schema=<N>` whenever the model or slimming code changes, so older installs refetch.
5. Keep the **en-US** skin names optional. They are useful for search ("Prime" is "Hoàng Gia" in vi) but cost
   another about 505 KB gzip. Store only `uuid → englishName`.
6. Store the files in `getApplicationSupportDirectory()` (not the temp dir) so a cold start does not trigger
   a re-download. Use `cached_network_image` (or similar) for the media URLs, which have a 14-day CDN TTL.
7. Optionally **ship a snapshot** of the small tables in the app assets (competitivetiers, contenttiers,
   currencies, gamemodes, queues, seasons, seasons/competitive, maps without callouts; well under 300 KB raw).
   Rank names and colors then render even on a first launch without network or during a valorant-api outage.

### 2.3 Sizes (vi-VN, measured 2026-09-28)

| Endpoint | Items | Raw JSON | gzip transfer | Needed? |
|---|---:|---:|---:|---|
| `/v1/weapons` (includes skins, levels, chromas, stats) | 21 weapons / 1415 skins | 3,650,936 | 513,238 | **Yes (primary)** |
| `/v1/weapons/skins` | 1415 | 3,619,994 | 503,084 (br 418,443) | No, redundant (and has no weapon uuid) |
| `/v1/weapons/skinlevels` | 2692 | 1,164,900 | 184,293 | Per-uuid fallback only |
| `/v1/weapons/skinchromas` | 2931 | 1,736,453 | 211,169 | Per-uuid fallback only |
| `/v1/bundles` | 327 | 408,762 | 29,052 | Yes |
| `/v1/buddies` (includes levels) | 898 | 640,284 | 86,762 | Yes |
| `/v1/buddies/levels` | 898 | 303,288 | 43,568 | No |
| `/v1/sprays` (includes levels) | 921 | 965,345 | 112,811 | Yes |
| `/v1/sprays/levels` | 921 | 304,700 | 49,839 | No |
| `/v1/playercards` | 1016 | 706,912 | 78,747 | Yes |
| `/v1/playertitles` | 444 | 123,894 | 22,971 | Yes |
| `/v1/levelborders` | 25 | 12,280 | 1,501 | Yes |
| `/v1/agents?isPlayableCharacter=true` | 29 | 158,424 | 24,244 | Yes |
| `/v1/maps` | 27 | 95,511 | 11,173 | Yes |
| `/v1/gamemodes` | 18 | 23,406 | 3,923 | Yes |
| `/v1/gamemodes/queues` | 31 | 25,617 | 4,007 | Yes |
| `/v1/gamemodes/equippables` | 2 | 941 | 353 | Optional (Golden Gun / NPE Classic in kill feeds) |
| `/v1/competitivetiers` | 5 tables | 79,868 | 3,357 | Yes |
| `/v1/seasons` | 53 | 16,140 | 2,639 | Yes |
| `/v1/seasons/competitive` | 53 | 103,964 | 5,435 | Yes |
| `/v1/contracts` | 87 | 650,732 | 84,815 | Yes |
| `/v1/currencies` | 4 | 2,206 | 501 | Yes |
| `/v1/contenttiers` | 5 | 1,881 | 573 | Yes |
| `/v1/contenteditions` | 2 | 381 | 214 | Optional ("Limited Edition" badge) |
| `/v1/themes` | 458 | 114,093 | 20,210 | Optional (group skins by collection) |
| `/v1/events` | 18 | 5,467 | 1,531 | Yes |
| `/v1/gear` | 3 | 3,470 | 756 | Yes (match economy) |
| `/v1/ceremonies` | 6 | 1,001 | 422 | Yes (round ceremonies) |
| `/v1/flex` | 23 | 7,479 | 1,808 | Yes (store "Totem" rewards) |
| `/v1/missions` | 947 | 468,642 | 46,001 | Optional (missions screen) |
| `/v1/objectives` | 46 | 11,171 | 2,939 | Optional |
| **Total of the "Yes" rows** | | **≈ 7.80 MB** | **≈ 1.01 MB** | |

`en-US` sizes are within about 2–4% of `vi-VN`. Slimming `/v1/weapons` to only the fields we use still leaves
about 2.4 MB, because the URLs dominate. Rebuilding URLs from `uuid + field` (for example
`https://media.valorant-api.com/weaponskinlevels/{uuid}/displayicon.png`) with a "has icon" bit would shrink it much further.

**Parsing:** `jsonDecode` of 3.6 MB can take tens to hundreds of ms on mid-range phones. Do it inside
`Isolate.run(...)` and build the lookup maps there. **UNVERIFIED timing**, so benchmark it on a low-end Android device.

---

## 3. Weapons, skins, levels, chromas

### 3.1 `/v1/weapons` (trimmed; skins removed)

```json
{
  "uuid": "9c82e19d-4575-0200-1a81-3eacf00cf872",
  "displayName": "Vandal",
  "category": "EEquippableCategory::Rifle",
  "defaultSkinUuid": "27f21d97-4c4b-bd1c-1f08-31830ab0be84",
  "displayIcon": "https://media.valorant-api.com/weapons/9c82e19d-…/displayicon.png",
  "killStreamIcon": "https://media.valorant-api.com/weapons/9c82e19d-…/killstreamicon.png",
  "assetPath": "ShooterGame/Content/Equippables/Guns/Rifles/AK/AKPrimaryAsset",
  "weaponStats": {
    "fireRate": 9.75, "magazineSize": 25, "runSpeedMultiplier": 0.8, "equipTimeSeconds": 1,
    "reloadTimeSeconds": 2.5, "firstBulletAccuracy": 0.25, "shotgunPelletCount": 1,
    "wallPenetration": "EWallPenetrationDisplayType::Medium", "feature": null, "fireMode": null,
    "altFireType": "EWeaponAltFireDisplayType::ADS",
    "adsStats": {"zoomMultiplier": 1.25, "fireRate": 8.775, "runSpeedMultiplier": 0.76, "burstCount": 1, "firstBulletAccuracy": 0.1575},
    "altShotgunStats": null, "airBurstStats": null,
    "damageRanges": [{"rangeStartMeters": 0, "rangeEndMeters": 50, "headDamage": 160, "bodyDamage": 40, "legDamage": 34}]
  },
  "shopData": {
    "cost": 2900, "category": "Rifles", "shopOrderPriority": 0, "categoryText": "Súng Trường",
    "gridPosition": {"row": 2, "column": 3}, "canBeTrashed": true, "image": null,
    "newImage": "https://media.valorant-api.com/weapons/9c82e19d-…/shop/newimage.png", "newImage2": null,
    "assetPath": "…/AK47WeaponPurchase"
  },
  "skins": [ /* see 3.2 */ ]
}
```

There are 21 weapons as of 13.06, including **Bandit** (sidearm, 600 credits) and **Warden** (rifle, 2900, vi
name "Quản Đốc"). Melee (`2f59173c-…`, vi "Cận Chiến") has `shopData: null`.

| en | vi `displayName` | vi `shopData.categoryText` | category enum |
|---|---|---|---|
| Classic, Shorty, Frenzy, Ghost, Sheriff, Bandit | same | Súng phụ | Sidearm |
| Stinger, Spectre | same | SMG | SMG |
| Bucky, Judge | same | `"\nShotgun"` (**bug**: leading newline and not translated) | Shotgun |
| Bulldog, Guardian, Phantom, Vandal | same | Súng Trường | Rifle |
| Warden | **Quản Đốc** | Súng Trường | Rifle |
| Marshal, Outlaw, Operator | same | Súng bắn tỉa | Sniper |
| Ares, Odin | same | Vũ Khí Hạng Nặng | Heavy |
| Melee | **Cận Chiến** | `null` | Melee |

The vi category labels are inconsistently cased and the Shotgun one is broken. **Ship our own vi labels keyed by
the `category` enum** instead of `categoryText`.

### 3.2 Skin (nested in `/v1/weapons[].skins[]`; same shape in `/v1/weapons/skins`)

```json
{
  "uuid": "30388628-42f0-606c-82c0-73ad43de997f",
  "displayName": "Vandal Reaver",
  "themeUuid": "4479eea8-4820-c69b-3912-f5ac678fcedc",
  "contentTierUuid": "60bca009-4182-7998-dee7-b8a2558dc369",
  "contentEditionUuid": null,
  "displayIcon": "https://media.valorant-api.com/weaponskins/30388628-…/displayicon.png",
  "wallpaper": null,
  "assetPath": "ShooterGame/Content/Equippables/Guns/Rifles/AK/SoulStealer/AK_Soulstealer_PrimaryAsset",
  "chromas": [
    {"uuid": "2bd28382-48c6-8579-83e8-e9b64b783de3", "displayName": "Vandal Reaver",
     "displayIcon": "…/weaponskinchromas/2bd28382-…/displayicon.png",
     "fullRender": "…/weaponskinchromas/2bd28382-…/fullrender.png",
     "swatch": "…/weaponskinchromas/2bd28382-…/swatch.png",
     "streamedVideo": null, "assetPath": "…/Chromas/Standard/AK_Soulstealer_Standard_PrimaryAsset"},
    {"uuid": "b2a065c0-4632-ccaa-f496-7681dc2a6185", "displayName": "Vandal Reaver Cấp 4\n(Dạng 1 Ánh Đỏ)", "…": "…"}
  ],
  "levels": [
    {"uuid": "ba42fe63-457a-78ce-4499-47950a698129", "displayName": "Vandal Reaver", "levelItem": null,
     "displayIcon": "…/weaponskinlevels/ba42fe63-…/displayicon.png",
     "streamedVideo": "https://valorant.dyn.riotcdn.net/x/videos/release-13.06/a6ee2555-…_default_universal.mp4",
     "assetPath": "…/Levels/AK_Soulstealer_Lv1_PrimaryAsset"},
    {"uuid": "6f9ba692-4618-d0e6-3099-42b4dc5fce89", "displayName": "Vandal Reaver Cấp 2",
     "levelItem": "EEquippableSkinLevelItem::VFX", "displayIcon": null, "streamedVideo": "…"}
  ]
}
```

Key facts:

- **The store sells skin levels, not skins.** Riot `SingleItemOffers[]`, `BonusStore…Rewards[0].ItemID`, bundle
  items with `ItemTypeID e7c63390-…` and `/store/v1/offers` `OfferID` values are all the **level-1 UUID**
  (`skin.levels[0].uuid`). [SP] and [VS] both index skins by `levels[0].uuid`. Build
  `Map<String, SkinRef> byLevelUuid` covering **all** levels, since owned entitlements include upgraded levels,
  plus `byChromaUuid` and `bySkinUuid`.
- `/v1/weapons/skins` has **no weapon UUID**, which is why `/v1/weapons` is the one to fetch.
- Special skins (`contentTierUuid == null`, 42 = 21×2):
  - Default "Standard" skins: `themeUuid = 5a629df4-4765-0214-bd40-fbb96542941f` ("Vandal Thông Thường").
    These are always owned and never listed in entitlements.
  - "Random Favorite Skin" (vi "Skin Yêu Thích Ngẫu Nhiên"): `themeUuid = 0d7a5bfb-4850-098e-1821-d989bbfd58a8`.
    **Filter these out** of collection and wishlist views.
- **Icon fallback:** the original sample had 47 skins with `displayIcon == null`.
  Update verified 2026-10-05: Prime Guardian / Guardian Hoàng Gia's parent
  `displayIcon` is non-null and returns HTTP 200 with a 512×512 missing-texture X;
  its base-level icon returns the actual 512×104 weapon artwork. Client card art
  now uses `levels.first.displayIcon ?? skin.displayIcon ??
  chromas.first.fullRender ?? chromas.first.displayIcon` (null-safe first lookup).
  Existing large-render selection still prefers the base chroma. HTTP success
  does not establish that an image depicts the item; this URL precedence fix
  does not validate every future CDN image. See
  [build 4025 evidence](../SKIN_IMAGE_FALLBACK_2026-10-05.md).
  [SP] uses `chromas[0].fullRender` for default skins and the first non-null level icon otherwise.
- `wallpaper` is non-null for 437 skins (a phone-style wallpaper PNG). This could become a "download wallpaper"
  feature (**UNVERIFIED** that ValBuddy has it).
- `contentEditionUuid`: `3d190ff8-49c2-2ae5-f8b1-a3b782fb4b79` = **LimitedEdition** (159 skins: Champions, VCT,
  Arcane, …), `dbf3bdc2-9f38-4545-a0f1-b0f78269ccaf` = StandardEdition (from `/v1/contenteditions`,
  `{"uuid","assetPath","editionType":"EContentEditionType::LimitedEdition"}`).
- **Level names.** vi uses "Cấp N" = Level N. 63 level names have a second line with a vi description of the
  upgrade (e.g. `"Vandal Champions 2023 Cấp 4\nHào quang chỉ kích hoạt khi người chơi đạt nhiều mạng hạ gục…"`).
  Split on `\n`: line 1 is the name, the rest is the description.
- **Chroma names** use the pattern `"<Skin> [Cấp 4]\n(Dạng 1 Ánh Đỏ)"` (1516 of 2931 contain `\n`). For a chroma
  label, take the last line and strip the parentheses ("Dạng 1 Ánh Đỏ" = "Variant 1 Red"). `chromas[0]` is the
  base (standard) chroma.
- `levelItem` enum counts (vi-VN; **not localized**, so ship our own labels):

| `levelItem` | count | Proposed vi label (app-authored) |
|---|---:|---|
| `null` (level 1 / base) | 1437 | — |
| `EEquippableSkinLevelItem::VFX` | 184 | Hiệu ứng hình ảnh |
| `::Animation` | 259 | Hoạt ảnh |
| `::Finisher` | 276 | Kết liễu |
| `::SoundEffects` | 300 | Âm thanh |
| `::KillBanner` | 147 | Biểu ngữ hạ gục |
| `::KillCounter` | 10 | Bộ đếm hạ gục |
| `::KillEffect` | 13 | Hiệu ứng hạ gục |
| `::TopFrag` | 15 | Hạ gục nhiều nhất |
| `::Transformation` | 13 | Biến hình |
| `::Randomizer` | 10 | Ngẫu nhiên |
| `::Voiceover` | 5 | Lồng tiếng |
| `::SongShuffle` | 5 | Đổi bài nhạc |
| `::InspectAndKill` | 6 | Kiểm tra & hạ gục |
| `::AttackerDefenderSwap` | 4 | Đổi theo phe |
| `::HeartbeatAndMapSensor` | 4 | Nhịp tim & cảm biến bản đồ |
| `::FishAnimation` | 4 | Hoạt ảnh cá |

Note that "Kết Liễu" is itself the game's own vi word for Finisher; it appears inside level descriptions.

### 3.3 `/v1/weapons/skinlevels`, `/v1/weapons/skinchromas` (flat)

These have the same objects as the nested ones, with no parent pointer. Use them only for per-UUID fallback,
e.g. `GET /v1/weapons/skinlevels/{uuid}?language=vi-VN` → `{"status":200,"data":{"uuid","displayName","levelItem","displayIcon","streamedVideo","assetPath"}}`.
The per-UUID result cannot tell you the parent skin, tier or weapon, so the cache still needs a refresh.

---

## 4. Content tiers (rarity), editions, themes

### 4.1 `/v1/contenttiers` (5 items)

| devName | uuid | rank | vi `displayName` | en | `highlightColor` (RRGGBBAA) | juiceValue / juiceCost |
|---|---|---:|---|---|---|---|
| Select | `12683d76-48d7-84a3-4e09-6985794f0445` | 0 | Phiên Bản Tuyển Chọn | Select Edition | `5a9fe233` | 10 / 30 |
| Deluxe | `0cebb8be-46d7-c12a-d306-e9907bfc5a25` | 1 | Phiên Bản Sang Chảnh | Deluxe Edition | `00958733` | 20 / 60 |
| Premium | `60bca009-4182-7998-dee7-b8a2558dc369` | 2 | Phiên Bản Cao Cấp | Premium Edition | `d1548d33` | 30 / 100 |
| Exclusive | `e046854e-406c-37f4-6607-19a9ba8426fc` | 3 | Phiên Bản Độc Quyền | Exclusive Edition | `f5955b33` | 40 / 140 |
| Ultra | `411e4a55-4e59-7757-41f0-86a53f101bb5` | 4 | Phiên Bản Siêu Cấp | Ultra Edition | `fad66333` | 50 / 160 |

- Item shape: `{uuid, displayName, devName, rank, juiceValue, juiceCost, highlightColor, displayIcon, assetPath}`.
  Icon: `https://media.valorant-api.com/contenttiers/{uuid}/displayicon.png`.
- `highlightColor` has alpha `0x33` (20%), meant as a tinted card background. For a solid accent, use the
  RGB with alpha `FF`.
- Use `devName` and `rank` for logic and sorting. The vi `displayName` is the full "Phiên Bản …"; for a compact
  badge, strip the "Phiên Bản " prefix.
- `juiceValue`/`juiceCost`: semantics **UNVERIFIED** (possibly an internal economy for recycling or night market). Ignore them.
- Distribution in 13.06 (skins by tier): Exclusive 471, Select 417, Deluxe 298, Premium 163, Ultra 24, none 42.
  Battle pass, agent-contract and VCT skins carry a tier too, so **the tier does not mean the skin is purchasable**.

### 4.2 `/v1/themes` (458)

`{uuid, displayName, displayIcon, storeFeaturedImage, assetPath}`. `skin.themeUuid`, `buddy.themeUuid`,
`playercard.themeUuid` and `spray.themeUuid` all point here, which allows a "Bộ sưu tập" (collection) grouping.
Only 83/456 names differ in vi.

---

## 5. Bundles

### 5.1 `/v1/bundles` (327)

```json
{
  "uuid": "2116a38e-4b71-f169-0d16-ce9289af4bfa",
  "contentEditionUuid": null,
  "displayName": "Hoàng Gia",
  "displayNameSubText": null,
  "description": "Hoàng Gia",
  "extraDescription": null,
  "promoDescription": null,
  "useAdditionalContext": false,
  "displayIcon": "https://media.valorant-api.com/bundles/2116a38e-…/displayicon.png",
  "displayIcon2": "https://media.valorant-api.com/bundles/2116a38e-…/displayicon2.png",
  "displayIcon3": null,
  "logoIcon": null,
  "verticalPromoImage": "https://media.valorant-api.com/bundles/2116a38e-…/verticalpromoimage.png",
  "assetPath": "ShooterGame/Content/UI/OutOfGame/MainMenu/Store/Bundles/StorefrontItem_HypebeastThemeBundle_DataAsset"
}
```

- **Riot `FeaturedBundle.Bundles[].DataAssetID` = `/v1/bundles` `uuid`** ([SP] `formatBundle`, [VS]
  `fetchBundle(bundle.DataAssetID)`). The Riot `Bundle.ID` is a separate storefront instance id and is **not** this uuid.
- **The bundle item list and prices are not in valorant-api.** They come only from Riot
  `Bundles[].Items[]` (`Item.ItemTypeID`, `Item.ItemID`, `Amount`, `BasePrice`, `DiscountedPrice`, `DiscountPercent`).
  Resolve each item by type (§11).
- Image sizes: `displayIcon` is a wide banner (the Prime one is 641 KB PNG), so prefer `displayIcon2` or
  `verticalPromoImage` for cards and resize client-side.
- 51 bundles are LimitedEdition (`contentEditionUuid = 3d190ff8-…`), for example "Champions 2026", "VCT x T1".
- vi strings: `displayNameSubText` is often "BỘ SƯU TẬP". Two bundles leak raw keys
  (`CNRerelease_2022Champions_Bundle_Store_Description`).

---

## 6. Buddies, sprays, cards, titles, level borders, flex

### 6.1 `/v1/buddies` (898, levels included)

```json
{"uuid":"8a431014-470c-d11f-24e0-35a992e427d2","displayName":"Phụ Kiện Ván Trượt Gekko",
 "isHiddenIfNotOwned":false,"themeUuid":null,
 "displayIcon":"https://media.valorant-api.com/buddies/8a431014-…/displayicon.png",
 "assetPath":"…/GunBuddy_AggrobotSkateboard_PrimaryAsset",
 "levels":[{"uuid":"cdfc181f-4e27-3bb0-633c-4f8e52348cd0","charmLevel":1,"hideIfNotOwned":false,
            "displayName":"AggrobotSkateboard",
            "displayIcon":"https://media.valorant-api.com/buddylevels/cdfc181f-…/displayicon.png",
            "assetPath":"…"}]}
```

- Riot uses the **buddy level uuid** for store accessory offers, bundle items (`ItemTypeID dd3bf334-…`),
  entitlements and `Loadout.Guns[].CharmLevelID`. `Loadout.Guns[].CharmID` is the buddy uuid.
  [VS]: `buddies.find(b => b.levels[0].uuid === Rewards[0].ItemID)`.
- **Always show the parent `displayName`.** Level names are internal (320 look like `Coin_EP2_A1`).
- 292 buddies have `isHiddenIfNotOwned: true`. Hide them in "all items" browsing unless owned.

### 6.2 `/v1/sprays` (921, levels included)

```json
{"uuid":"b13c2ff5-4059-c411-1cf1-d5827375024d","displayName":"Hình Phun Sơn Hổ Truy Dấu",
 "category":"EAresSprayCategory::Contextual","themeUuid":null,"isNullSpray":false,"hideIfNotOwned":false,
 "displayIcon":"…/sprays/b13c2ff5-…/displayicon.png","fullIcon":"…/fullicon.png",
 "fullTransparentIcon":"…/fulltransparenticon.png","animationPng":null,"animationGif":null,
 "assetPath":"…","levels":[{"uuid":"c7c6c83a-…","sprayLevel":1,"displayName":"Hình Phun Sơn Hổ Truy Dấu","displayIcon":"…","assetPath":"…"}]}
```

- Riot uses the **spray uuid** (not the level) in store, entitlements (`d5f120f8-…`) and loadout v3 `ActiveExpressions[].AssetID` (with `TypeID d5f120f8-…`). *(SUMMARY review: `Loadout.Sprays[].SprayID` is the legacy v2 shape; see `riot-endpoints.md` §7.)*
- `category`: `null` (429) or `EAresSprayCategory::Contextual` (492). The null spray is
  `d7efbdd5-4a77-f858-a133-cfb8956ca1fe` ("Không có"). 51 sprays have `hideIfNotOwned`.
- Display: `fullTransparentIcon` (as [VS] does), or `animationGif` when present.

### 6.3 `/v1/playercards` (1016)

`{uuid, displayName ("Thẻ …"), isHiddenIfNotOwned, themeUuid, displayIcon, smallArt, wideArt, largeArt, assetPath}`.
Riot uses the card uuid (`3f296c07-…`, `Identity.PlayerCardID`, match `playerCard`). Use `wideArt` for
profile headers, `smallArt` for list avatars and `largeArt` for the full card. 104 are hidden if not owned.
One vi name leaks a key (`Playercard_CNYear3_DisplayName`).

### 6.4 `/v1/playertitles` (444)

`{uuid, displayName ("Wunderkind Title"), titleText ("Wunderkind"), isHiddenIfNotOwned, assetPath}`. **Display
`titleText`**, since `displayName` has a "Title"/"Danh hiệu" suffix. The default "no title" entry is
`d13e579c-435e-44d4-cec2-6eae5a3c5ed4`, where both names are `null`. Riot `de7caa6b-…`,
`Identity.PlayerTitleID`, match `playerTitle`. 207 are hidden if not owned. 4 `titleText` values have trailing spaces.

### 6.5 `/v1/levelborders` (25)

```json
{"uuid":"ebc736cd-4b6a-137b-e2b0-1486e31312c9","displayName":"Khung Cấp 1","startingLevel":1,"levelNumber":1,
 "levelNumberAppearance":"…/levelborders/ebc736cd-…/levelnumberappearance.png",
 "smallPlayerCardAppearance":"…/smallplayercardappearance.png","assetPath":"…/BorderLevel01Tier01_PrimaryAsset"}
```

`startingLevel` ∈ {1, 20, 40, …, 480} in steps of 20. Default border = the one with the largest
`startingLevel <= accountLevel`. If `Identity.PreferredLevelBorderID` or match `preferredLevelBorder` is
non-empty, use that uuid instead. `levelNumberAppearance` is the badge behind the level number.

### 6.6 `/v1/flex` (23): Riot "Totem"

`{uuid, displayName ("Flex Gấu Chiến Thuật"), displayNameAllCaps, displayIcon, assetPath (…/Equippables/Totems/…)}`.
Riot's item type for these is `03a572de-4234-31ed-d344-ababa488f981`, confirmed from several repos ([GH]:
RadiantConnect, valpal, primordium). Contracts call the reward type `"Totem"`, and all 8 Totem rewards resolve in `/v1/flex`.

---

## 7. Agents

`GET /v1/agents?isPlayableCharacter=true&language=vi-VN` returns 29 agents. **Always pass the filter.** Without
it there are 30 entries, including a non-playable duplicate **KAY/O** (`773f0c78-4486-752b-68ef-4585d7f4b848`).

```json
{
  "uuid": "add6443a-41bd-e414-f6ad-e58d267f4e95",
  "displayName": "Jett",
  "description": "Đến từ Hàn Quốc, với phong cách chiến đấu nhanh nhẹn và huyền ảo, …",
  "developerName": "Wushu",
  "releaseDate": "1970-01-01T00:00:00Z",
  "characterTags": ["Né tránh", "Di chuyển"],
  "displayIcon": "…/agents/add6443a-…/displayicon.png",
  "displayIconSmall": "…", "bustPortrait": "…", "fullPortrait": "…/fullportrait.png", "fullPortraitV2": "…",
  "killfeedPortrait": "…", "minimapPortrait": "…", "homeScreenPromoTileImage": null,
  "background": "…/background.png",
  "backgroundGradientColors": ["25607aff", "0f1923ff", "0f1923ff", "25607aff"],
  "assetPath": "ShooterGame/Content/Characters/Wushu/Wushu_PrimaryAsset",
  "isFullPortraitRightFacing": false, "isPlayableCharacter": true, "isAvailableForTest": true, "isBaseContent": true,
  "role": {"uuid": "dbe8757e-9e92-4ed4-b39f-9dfc589691d4", "displayName": "Đối đầu", "description": "…", "displayIcon": "…", "assetPath": "…"},
  "recruitmentData": null,
  "abilities": [{"slot": "Ability1", "displayName": "Tùy Phong", "description": "Jett bật nhảy NGAY LẬP TỨC lên không trung.", "displayIcon": "…"}],
  "voiceLine": null
}
```

- **Roles (vi):** Duelist = **Đối đầu** (`dbe8757e-…`), Initiator = **Khởi tranh** (`1b47567f-8f7b-444b-aae3-b0c634622d10`),
  Controller = **Kiểm soát** (`4ee40330-ecdd-4f2f-98a8-eb1243428373`), Sentinel = **Hộ vệ** (`5fc02f99-4091-4486-a531-98459a3e95e9`).
- Agent names stay English. `releaseDate` is `1970-01-01` for older agents. The newest are Tejo (2025-01-08),
  Waylay (2025-03-04), Veto (2025-10-07) and **Miks** (2026-03-18, Controller, uuid `7c8a4701-4de6-9355-b254-e09bc2a34b72`).
- `isBaseContent: true` marks the 5 free starters: Jett, Phoenix, Sova, Brimstone, Sage. They are always owned
  and do not appear in entitlements `01bb38e1-…`.
- Riot `characterId` (match details) and `ItemTypeID 01bb38e1-da47-4e6a-9b3d-945fe4655707` items are agent uuids.
- `abilities[].slot` values seen: `Ability1`, `Ability2`, `Grenade`, `Ultimate`, `Passive`. Match `damageItem`
  uses `Ability1/Ability2/GrenadeAbility/Ultimate` ([VAD]), so map `GrenadeAbility` to `Grenade`.
- `recruitmentData` (for recruit events) has `counterId`, `milestoneId`, `milestoneThreshold`, `startDate`, `endDate`.

---

## 8. Maps

`/v1/maps` (27). **`mapUrl` equals Riot's `matchInfo.mapId`, and also `MapID` in competitive updates, pregame and core-game.**

```json
{
  "uuid": "7eaecc1b-4337-bbf6-6ab9-04b8f06b3319",
  "displayName": "Ascent", "narrativeDescription": null, "tacticalDescription": "Khu A/B",
  "coordinates": "45°26'BF'N,12°20'Q'E",
  "displayIcon": "…/maps/7eaecc1b-…/displayicon.png", "listViewIcon": "…", "listViewIconTall": "…",
  "splash": "…/splash.png", "backgroundImage": "…", "stylizedBackgroundImage": "…", "premierBackgroundImage": "…",
  "assetPath": "ShooterGame/Content/Maps/Ascent/Ascent_PrimaryAsset",
  "mapUrl": "/Game/Maps/Ascent/Ascent",
  "xMultiplier": 0.00007, "yMultiplier": -0.00007, "xScalarToAdd": 0.813895, "yScalarToAdd": 0.573242,
  "callouts": [
    {"regionName": "Cây", "superRegion": "ECalloutSuperRegion::A", "superRegionName": "A",
     "location": {"x": 3980.9062, "y": -5938.758, "z": 400.00003}, "scale3D": null, "rotation": null}
  ]
}
```

Full `mapUrl` table (13.06):

| mapUrl (= Riot mapId) | Name | Notes |
|---|---|---|
| `/Game/Maps/Ascent/Ascent` | Ascent | |
| `/Game/Maps/Bonsai/Bonsai` | Split | |
| `/Game/Maps/Canyon/Canyon` | Fracture | |
| `/Game/Maps/Duality/Duality` | Bind | |
| `/Game/Maps/Foxtrot/Foxtrot` | Breeze | |
| `/Game/Maps/Infinity/Infinity` | Abyss | |
| `/Game/Maps/Jam/Jam` | Lotus | Khu A/B/C |
| `/Game/Maps/Juliett/Juliett` | Sunset | |
| `/Game/Maps/Pitt/Pitt` | Pearl | |
| `/Game/Maps/Plummet/Plummet` | **Summit** | new in 2026 (uuid `756da597-416b-c0f2-f47b-afbdf28670bc`); also queue `newmap` |
| `/Game/Maps/Port/Port` | Icebox | |
| `/Game/Maps/Rook/Rook` | Corrode | |
| `/Game/Maps/Triad/Triad` | Haven | Khu A/B/C |
| `/Game/Maps/HURM/HURM_Alley/HURM_Alley` | District | TDM |
| `/Game/Maps/HURM/HURM_Bowl/HURM_Bowl` | Kasbah | TDM |
| `/Game/Maps/HURM/HURM_Helix/HURM_Helix` | Drift | TDM |
| `/Game/Maps/HURM/HURM_HighTide/HURM_HighTide` | Glitch | TDM |
| `/Game/Maps/HURM/HURM_Yard/HURM_Yard` | Piazza | TDM |
| `/Game/Maps/Duel/Duel_1/Skirmish_A` … `Duel_Platform/Skirmish_D`, `Duel_Heady/Skirmish_E` | Skirmish A–E | 1v1/2v2 |
| `/Game/Maps/AbilityDraft/AbilityDraft` | Gauntlet | |
| `/Game/Maps/NPEV2/NPEV2` | Tập Luyện Cơ Bản | only vi-translated map name |
| `/Game/Maps/Poveglia/Range`, `/Game/Maps/PovegliaV2/RangeV2` | The Range | two entries |

- Match with an **exact, case-insensitive** string compare on `mapUrl`. TDM and Skirmish map ids have an extra
  path segment, so do not truncate paths.
- **Minimap coordinates** (for kill or plant markers, if implemented): `u = gameY * xMultiplier + xScalarToAdd`,
  `v = gameX * yMultiplier + yScalarToAdd`, then multiply by the rendered size of `displayIcon`. **UNVERIFIED**:
  this is the widely used community formula (note the X/Y swap), and I did not test it here. TDM, Skirmish and
  other side maps have multipliers of 0, so no minimap projection is possible for them.
- Callout `superRegionName` vi values: `A`, `B`, `C`, `Mid` (not translated), `Bên Tấn Công` (Attacker side), `Bên Phòng Thủ` (Defender side).

---

## 9. Game modes and queues

### 9.1 `/v1/gamemodes/queues` (31): **use this for match-history labels**

Riot `matchInfo.queueID` and competitive-updates / match-history `QueueID` equal `queueId`.

```json
{"uuid":"d2faff85-4964-f52e-b6b5-73a5d66ccad6","queueId":"competitive","displayName":"Thi đấu xếp hạng",
 "description":"Chế độ đặt/gỡ Spike. Trận đấu xếp hạng, …","dropdownText":"Thi đấu xếp hạng",
 "selectedText":"THI ĐẤU XẾP HẠNG","isBeta":false,
 "displayIcon":"…/gamemodequeues/d2faff85-…/displayicon.png","listViewIconTall":"…",
 "assetPath":"ShooterGame/Content/GameModes/Queues/CompetitiveQueue_DataAsset"}
```

| queueId | en | vi `displayName` |
|---|---|---|
| `competitive` | Competitive | **Thi đấu xếp hạng** |
| `unrated` | Unrated | **Đấu thường** |
| `swiftplay` | Swiftplay | **Siêu Tốc** |
| `spikerush` | Spike Rush | **Đặt Spike Nhanh** |
| `deathmatch` | Deathmatch | **Sinh Tử** |
| `hurm` | Team Deathmatch | **Sinh Tử Đội** |
| `ggteam` | Escalation | **Tăng Tiến** |
| `onefa` | Replication | **Nhân bản** |
| `snowball` | Snowball Fight | **Trận Chiến Cầu Tuyết** |
| `premier` | Premier | Premier |
| `custom` | Custom Game | **Chơi tự do** |
| `valaram` | All Random One Site | **Tất Cả Ngẫu Nhiên Một Khu Đặt Spike** |
| `fortcollins` | Retake | Retake |
| `dodgeball` | Knockout | Knockout |
| `skirmish2v2` | Skirmish: 2v2 | Skirmish: 2v2 |
| `skirmishascension1v1` / `2v2` | Skirmish: Ascension 1v1/2v2 | Skirmish: **Thăng Hoa** 1v1/2v2 |
| `abilitydraftarena` | Gauntlet: Glitched | Gauntlet: Glitched |
| `newmap` | Summit | Summit |
| `console_*` | console variants of the above (competitive, unrated, swiftplay, deathmatch, hurm, dodgeball, snowball, valaram, abilitydraftarena, skirmish*) | same vi names |

- Custom games: match-details `queueID` is `""` with `provisioningFlowID == "CustomGame"` (seen in real 2026-09 responses by KaiC5504/DailyStore; SUMMARY review). Still map both `""` and `"custom"` to "Chơi tự do".
- `newmap` is re-pointed to a different map every season, so never hard-code its label; always take it from the vi-VN queue list.
- Unknown future queue ids should fall back to the game-mode lookup (§9.2), then to the raw id.

### 9.2 `/v1/gamemodes` (18)

```json
{"uuid":"96bd3920-4f36-d026-2b28-c683eb0bcac5","displayName":"Thông thường",
 "description":"Chế độ đặt/gỡ Spike. …","duration":"30-40 PHÚT",
 "customTimerLabel":null,"customVictoryMessage":null,"customDefeatMessage":null,"economyType":null,
 "allowsMatchTimeouts":true,"allowsCustomGameReplays":true,"isTeamVoiceAllowed":true,"isMinimapHidden":false,
 "orbCount":1,"roundsPerHalf":-1,"teamRoles":null,"gameFeatureOverrides":null,
 "gameRuleBoolOverrides":[{"ruleName":"EGameRuleBoolName::AccoladesEnabled","state":true}],
 "displayIcon":"…/gamemodes/96bd3920-…/displayicon.png","listViewIconTall":"…",
 "assetPath":"ShooterGame/Content/GameModes/Bomb/BombGameMode_PrimaryAsset"}
```

**Mapping Riot `matchInfo.gameMode`** (e.g. `/Game/GameModes/Bomb/BombGameMode.BombGameMode_C`): the file name
differs between the Riot class path and valorant-api's `assetPath`, and open-source repos disagree on the exact
class names ([GH]: `HURM/HURM.HURM_C` vs `HURM/HURMGameMode.HURMGameMode_C` vs `HURM/HURM_GameMode.HURM_GameMode_C`;
`Swiftplay_EoRCredits_GameMode` vs `SwiftPlay_GameMode`). **Match on the directory after `GameModes/` instead:**

```dart
/// "/Game/GameModes/Bomb/BombGameMode.BombGameMode_C"                    -> "bomb"
/// "ShooterGame/Content/GameModes/Bomb/BombGameMode_PrimaryAsset"         -> "bomb"
/// ".../GameModes/_Development/Swiftplay_EndOfRoundCredits/X.X_C"         -> "_development/swiftplay_endofroundcredits"
String? gameModeKey(String path) {
  final i = path.indexOf('GameModes/');
  if (i < 0) return null;
  final rest = path.substring(i + 'GameModes/'.length);
  final j = rest.lastIndexOf('/');
  return j < 0 ? null : rest.substring(0, j).toLowerCase();
}
```

The keys are unique across all 18 modes:

| dir key | vi displayName (en) | duration (vi) |
|---|---|---|
| `bomb` | Thông thường (Standard). Used by competitive, unrated and premier, so **prefer the queue label** | 30-40 PHÚT |
| `quickbomb` | Đặt Spike Nhanh (Spike Rush) | 8-12 PHÚT |
| `_development/swiftplay_endofroundcredits` | Siêu Tốc (Swiftplay) | 10 - 15 PHÚT |
| `deathmatch` | Sinh Tử (Deathmatch) | 7 - 9 PHÚT |
| `hurm` | Sinh Tử Đội (Team Deathmatch) | 8 - 10 PHÚT |
| `gungame` | Tăng Tiến (Escalation) | 7 - 9 PHÚT |
| `oneforall` | Nhân bản (Replication) | 10 - 15 PHÚT |
| `snowballfight` | Trận Chiến Cầu Tuyết (Snowball Fight) | 5 - 7 PHÚT |
| `aros` | Tất Cả Ngẫu Nhiên Một Khu Đặt Spike (All Random One Site) | 10 - 15 PHÚT |
| `fortcollins` | Retake | 8-12 PHÚT |
| `dodgeball` | Knockout | 10 - 15 PHÚT |
| `skirmish` / `skirmishascension` | Skirmish / Skirmish: Thăng Hoa | 5 - 10 PHÚT |
| `abilitydraftarena` | Gauntlet: Glitched | "10-15 MINS" (not translated) |
| `exampleplayertestbot` | Đấu Với Máy (Bot Match) | — |
| `npev2` / `newplayerexperience` | Tập Luyện Cơ Bản / Tân Thủ | — |
| `shootingrange` | Trường Bắn (The Range) | — |

### 9.3 `/v1/gamemodes/equippables` (2)

`Classic` (`c5de005c-4bdc-26a7-a47d-c295eaaae9d8`, NPE pistol) and **Súng Hoàng Kim** / Golden Gun
(`3de32920-4a8f-0499-7740-648a5bf95470`). Shape: `{uuid, displayName, category, displayIcon, killStreamIcon, assetPath}`.
Include it in the weapon lookup for kill feeds, because these UUIDs are not in `/v1/weapons` (**UNVERIFIED** that
they appear in match `damageItem`).

---

## 10. Ranks: competitive tiers, seasons, competitive seasons

### 10.1 `/v1/competitivetiers` (5 tables)

| uuid | assetObjectName | tiers | Used by (per `/v1/seasons/competitive`) |
|---|---|---:|---|
| `564d8e28-c226-3180-6285-e48a390db8b1` | Episode1_CompetitiveTierDataTable | 25 | Closed Beta, E1 A1–A3 |
| `23eb970e-6408-bc0b-3f20-d8fb0e0354ea` | Episode2_CompetitiveTierDataTable | 23 | E2 A1–A3, **E3 A1** |
| `edb72a72-7e6d-6010-9591-7c053bbdbf48` | Episode3_CompetitiveTierDataTable | 25 | E3 A2–A3 |
| `e4e9a692-288f-63ca-7835-16fbf6234fda` | Episode4_CompetitiveTierDataTable | 25 | E4 A1–A3 |
| `03621f52-342b-cf4e-4f86-9350a49c6d04` | Episode5_CompetitiveTierDataTable | 28 | **E5 A1 through V26 Act VI** (current act = V26 Act V; Act VI is already in the data) |

Tier object:

```json
{"tier":27,"tierName":"RADIANT","division":"ECompetitiveDivision::RADIANT","divisionName":"RADIANT",
 "color":"ffffaaff","backgroundColor":"ffedaaff",
 "smallIcon":"https://media.valorant-api.com/competitivetiers/03621f52-…/27/smallicon.png",
 "largeIcon":"https://media.valorant-api.com/competitivetiers/03621f52-…/27/largeicon.png",
 "rankTriangleDownIcon":"…/27/ranktriangledownicon.png","rankTriangleUpIcon":"…/27/ranktriangleupicon.png"}
```

**Current table (Episode5, used since June 2022), vi-VN:**

| tier | en tierName | **vi tierName** | vi divisionName | color | backgroundColor |
|---:|---|---|---|---|---|
| 0 | UNRANKED | **CHƯA XẾP HẠNG** | CHƯA XẾP HẠNG | ffffffff | 00000000 |
| 1 | Unused1 | Chưa sử dụng | — (INVALID, no icons) | ffffffff | 00000000 |
| 2 | Unused2 | Chưa sử dụng2 | — (INVALID, no icons) | ffffffff | 00000000 |
| 3–5 | IRON 1–3 | **SẮT 1–3** | SẮT | 868986ff | 828282ff |
| 6–8 | BRONZE 1–3 | **ĐỒNG 1–3** | ĐỒNG | a5855dff | 7c5522ff |
| 9–11 | SILVER 1–3 | **BẠC 1–3** | BẠC | bbc2c2ff | d1d1d1ff |
| 12–14 | GOLD 1–3 | **VÀNG 1–3** | VÀNG | eccf56ff | eec56aff |
| 15–17 | PLATINUM 1–3 | **BẠCH KIM 1–3** | BẠCH KIM | 59a9b6ff | 00c7c0ff |
| 18–20 | DIAMOND 1–3 | **KIM CƯƠNG 1–3** | KIM CƯƠNG | b489c4ff | 763bafff |
| 21–23 | ASCENDANT 1–3 | **THƯỢNG NHÂN 1–3** | THƯỢNG NHÂN | 6ae2afff | 1c7245ff |
| 24–26 | IMMORTAL 1–3 | **BẤT TỬ 1–3** | BẤT TỬ | bb3d65ff | ff5551ff |
| 27 | RADIANT | **RADIANT** (not translated) | RADIANT | ffffaaff | ffedaaff |

Older tables (vi):
- Episode1: 0 CHƯA XẾP HẠNG, 1–2 unused, 3–20 Iron→Diamond as above, **21–23 BẤT TỬ 1–3, 24 RADIANT**.
- Episode2: same, but **21 = BẤT TỬ (single tier), 22–23 absent, 24 RADIANT**.
- Episode3 and Episode4: 21–23 BẤT TỬ 1–3, 24 RADIANT.

So **tier 21–24 means different ranks before and after E5.** Never hard-code the tier names.

The names are all caps. For sentence-case UI ("Kim Cương 2"), apply a Vietnamese-aware title-case. Dart's
`toLowerCase()` handles `Đ→đ` and precomposed vowels correctly; still verify with a unit test. Tiers 1–2
("Chưa sử dụng") must never be displayed; treat them as unranked.

### 10.2 `/v1/seasons` (53)

```json
{"uuid":"8102cd81-43a0-d0d7-bd59-47b8fe9bed1b","displayName":"PHẦN V","title":"V26 // PHẦN V",
 "type":"EAresSeasonType::Act","startTime":"2026-08-19T00:00:00Z","endTime":"2026-10-14T00:00:00Z",
 "parentUuid":"3737c391-497a-6e82-aeb5-cc9f701f72e2",
 "assetPath":"ShooterGame/Content/Seasons/Season_EpisodeV26-2_Act5_DataAsset"}
{"uuid":"3737c391-497a-6e82-aeb5-cc9f701f72e2","displayName":"V26","title":null,"type":null,
 "startTime":"2026-06-24T00:00:00Z","endTime":"2027-01-06T00:00:00Z","parentUuid":null,"assetPath":"…/Season_EpisodeV26-2_DataAsset"}
```

- `type` is either `"EAresSeasonType::Act"` (39) or **`null`** (14: episodes and Closed Beta). There is **no
  `…::Episode` value**, so treat `parentUuid == null` as an episode.
- Naming in vi: E1–E9 episodes are **"HỒI 1…HỒI 9"** (en "EPISODE n"), acts are **"PHẦN I…VI"** (en "ACT I").
  Since 2025 the "episode" is the year: `V25`, `V26`. Each year has **two** parent records (`V26-1` with acts
  I–III and `V26-2` with acts IV–VI), both named "V26". **Display `title`** ("V26 // PHẦN V") when it is
  non-null. Pre-2025 acts have `title: null`, so compose "HỒI 5 // PHẦN II" from parent and child.
- **Current act on 2026-09-28:** `8102cd81-43a0-d0d7-bd59-47b8fe9bed1b` (V26 // PHẦN V, 2026-08-19 → 2026-10-14).
  Next: `d816f426-48ea-f052-117f-9697a155b319` (PHẦN VI, 2026-10-14 → 2027-01-06), already present in the data.
- Current act = the entry with `type == Act` and `startTime <= now < endTime`. The Riot-side alternative is
  `GET https://shared.{shard}.a.pvp.net/content-service/v3/content` → `Seasons[] {ID, Name, Type:"episode"|"act", StartTime, EndTime, IsActive}` ([VAD]).
  Its `ID` equals the valorant-api season `uuid` (**UNVERIFIED** in 2026, but it is the documented behavior).

### 10.3 `/v1/seasons/competitive` (53)

```json
{"uuid":"5567c17f-41aa-71fe-9097-1ea50c14134f","startTime":"2026-08-19T00:00:00Z","endTime":"2026-10-14T00:00:00Z",
 "seasonUuid":"8102cd81-43a0-d0d7-bd59-47b8fe9bed1b",
 "competitiveTiersUuid":"03621f52-342b-cf4e-4f86-9350a49c6d04",
 "borders":[
   {"uuid":"06289abe-489d-690b-edf1-51b9c063f3da","level":0,"winsRequired":0,"displayIcon":"…/seasonborders/06289abe-…/displayicon.png","smallIcon":null,"assetPath":"…/Border_Level0_DataAsset"},
   {"uuid":"d3b30fbf-445e-0bce-bf98-b2b58e5807c6","level":1,"winsRequired":9,  "displayIcon":"…","smallIcon":"…"},
   {"uuid":"48bfd197-49c0-59bd-5833-ad9feff49516","level":2,"winsRequired":25, "…":"…"},
   {"uuid":"dc20c281-4086-c7aa-8420-9f851d0e44ed","level":3,"winsRequired":50, "…":"…"},
   {"uuid":"19165f95-4367-9123-d52b-bc8b05b47247","level":4,"winsRequired":75, "…":"…"},
   {"uuid":"ba974f74-4131-a4ba-378a-c9993b9edef0","level":5,"winsRequired":100,"…":"…"}],
 "assetPath":"…/CompetitiveSeason_EpisodeV26-2_Act5_DataAsset"}
```

**How to pick the tier table:**

```dart
String tierTableFor(String? seasonId) {
  // seasonId from match details matchInfo.seasonId, MMR SeasonalInfoBySeasonID key, competitive updates SeasonID
  final cs = competitiveSeasonBySeasonUuid[seasonId?.toLowerCase()];
  if (cs != null) return cs.competitiveTiersUuid;
  // unknown or new act not yet in valorant-api -> newest table by startTime
  return latestCompetitiveSeason.competitiveTiersUuid;   // currently 03621f52-…
}
```

- The episode-level records (e.g. "V26", 0 borders) also appear here and map to a table. Riot data refers to
  **acts**, so look up by the act uuid.
- Data quirk: E3 Act 1 (`2a27e5d2-…`) maps to the **Episode2** table, while E3 A2/A3 map to Episode3. Follow the
  data and do not "fix" it.
- **Act rank badge (triangle):** the border level is the highest `borders[].level` whose
  `winsRequired <= NumberOfWinsWithPlacements`. The triangle shape comes from `WinsByTier` (the top 9 wins by
  tier) in Player MMR ([VAD]), using `rankTriangleUpIcon`/`rankTriangleDownIcon` from the tier table. **UNVERIFIED**
  exact algorithm; confirm against the game client.

### 10.4 Color parsing (Flutter)

```dart
/// valorant-api colors are "RRGGBBAA"; Flutter wants ARGB.
Color vapiColor(String rrggbbaa) {
  final v = int.parse(rrggbbaa, radix: 16);
  return Color.fromARGB(v & 0xFF, (v >> 24) & 0xFF, (v >> 16) & 0xFF, (v >> 8) & 0xFF);
}
```

This applies to `competitivetiers.tiers[].color/backgroundColor`, `contenttiers.highlightColor` and `agents.backgroundGradientColors[]`.

---

## 11. Riot UUID → valorant-api join table

Item type IDs come from [VAD] Owned Items, [SP] `itemTypes` and [VS] `VItemTypes`. Flex is from [GH].

| ItemTypeID | Type | Riot `ItemID` is… | valorant-api lookup |
|---|---|---|---|
| `e7c63390-eda7-46e0-bb7a-a6abdacd2433` | Skin level | skin **level** uuid (store: always level 1) | `/v1/weapons` → `skins[].levels[].uuid` |
| `3ad1b2b2-acdb-4524-852f-954a76ddae0a` | Skin variant (chroma) | chroma uuid | `skins[].chromas[].uuid` |
| `dd3bf334-87f3-40bd-b043-682a57a8dc3a` | Gun buddy | buddy **level** uuid | `/v1/buddies` → `levels[].uuid` |
| `d5f120f8-ff8c-4aac-92ea-f2b5acbe9475` | Spray | spray uuid | `/v1/sprays` `uuid` |
| `3f296c07-64c3-494c-923b-fe692a4fa1bd` | Player card | card uuid | `/v1/playercards` |
| `de7caa6b-adf7-4588-bbd1-143831e786c6` | Player title | title uuid | `/v1/playertitles` |
| `03a572de-4234-31ed-d344-ababa488f981` | Flex (Totem) | flex uuid | `/v1/flex` |
| `01bb38e1-da47-4e6a-9b3d-945fe4655707` | Agent | agent uuid | `/v1/agents` |
| `f85cb6f7-33e5-4dc8-b609-ec7212301948` | Premium contract (ownership of a paid battle/event pass) | contract uuid | `/v1/contracts` |

| Riot field | valorant-api |
|---|---|
| Storefront `SkinsPanelLayout.SingleItemOffers[]` / `SingleItemStoreOffers[].OfferID` | skin level-1 uuid |
| `FeaturedBundle.Bundles[].DataAssetID` | `/v1/bundles` `uuid` |
| `Bundles[].Items[].Item.{ItemTypeID,ItemID}` | by ItemTypeID table |
| `BonusStore.BonusStoreOffers[].Offer.Rewards[0].ItemID` (night market) | skin level-1 uuid |
| `AccessoryStore.AccessoryStoreOffers[].Offer.Rewards[0]` | buddy level / spray / card / title / flex by type. `ContractID` → `/v1/contracts` |
| Wallet `Balances` keys, `Cost` keys | `/v1/currencies` uuid (§14) |
| Loadout `Guns[].ID` / `SkinID` / `SkinLevelID` / `ChromaID` | weapon uuid / skin uuid / level uuid / chroma uuid |
| Loadout `Guns[].CharmID` / `CharmLevelID` | buddy uuid / buddy level uuid |
| Loadout v3 `ActiveExpressions[].AssetID` (`TypeID` = spray `d5f120f8-…` or flex `03a572de-…`) | spray uuid / flex uuid (legacy v2: `Sprays[].SprayID`) |
| Loadout `Identity.PlayerCardID` / `PlayerTitleID` / `PreferredLevelBorderID` | playercard / playertitle / levelborder |
| Match `matchInfo.mapId` | `maps.mapUrl` (exact) |
| Match `matchInfo.gameMode` | `gamemodes.assetPath` via directory key (§9.2) |
| Match `matchInfo.queueID` | `gamemodes/queues.queueId` |
| Match `matchInfo.seasonId` | `seasons.uuid` and `seasons/competitive.seasonUuid` → tier table |
| Match `players[].characterId` | `agents.uuid` |
| Match `players[].competitiveTier` | tier number inside the season's table |
| Match `players[].playerCard`, `playerTitle`, `preferredLevelBorder` | cards / titles / levelborders |
| Match `roundResults[].roundCeremony` (`CeremonyAce`, `CeremonyTeamAce`, `CeremonyFlawless`, `CeremonyCloser`, `CeremonyClutch`, `CeremonyThrifty`, `CeremonyDefault`) | `/v1/ceremonies`: `"Ceremony"+X` ↔ assetPath `…/XCeremony_PrimaryAsset`. `CeremonyDefault` or `""` means none |
| Match `playerEconomy.weapon` / `armor` | `/v1/weapons` uuid / `/v1/gear` uuid |
| Match kill `finishingDamage.damageItem` when `damageType == "Weapon"` | weapon uuid (or gamemode equippable). Arrives UPPERCASE in real responses: lowercase it first |
| MMR / competitive updates `SeasonID`, `TierAfterUpdate` | seasons + tier table |
| Contracts `ContractDefinitionID` | `/v1/contracts` uuid |

---

## 12. Contracts (battle pass, agent gear, event passes)

`/v1/contracts` (87 items): 39 `relationType:"Season"` (battle passes), 29 `"Agent"` (agent gear, "Trang Bị <Agent>"),
18 `"Event"` (event passes), and 1 with `null` ("CHƠI ĐỂ MỞ KHÓA CÁC ĐẶC VỤ", the new-player agent unlock).

**Current battle pass (2026-09-28):** `3f04583c-4c7a-6bdf-65ce-d4b6ff53c5e9` "Mùa 2026 // Phần V",
`content.relationUuid = 8102cd81-…` (current act), `premiumVPCost 1000`.
**Current event pass:** `d70f2a95-4682-5216-984f-ddaaa14436a7` "Champions 2026: Shanghai" (event
`e7049ebc-491a-454d-3ed6-12beca2aa0ec`, 2026-09-24 → 2026-10-19).

```json
{
  "uuid": "3f04583c-4c7a-6bdf-65ce-d4b6ff53c5e9",
  "displayName": "Mùa 2026 // Phần V",
  "displayIcon": null, "shipIt": false,
  "useLevelVPCostOverride": true, "levelVPCostOverride": -1,
  "freeRewardScheduleUuid": "113b0fa5-4da6-71e6-ef40-10b18a6137c4",
  "content": {
    "relationType": "Season",
    "relationUuid": "8102cd81-43a0-d0d7-bd59-47b8fe9bed1b",
    "premiumRewardScheduleUuid": "935acea9-4885-5514-f19c-71b76d00b143",
    "premiumVPCost": 1000,
    "chapters": [
      {"isEpilogue": false,
       "levels": [
         {"reward": {"type": "EquippableSkinLevel", "uuid": "d538eac0-4990-f84d-93bf-4d9ce09bf75a", "amount": 1, "isHighlighted": false},
          "xp": 0, "vpCost": 0, "isPurchasableWithVP": true, "doughCost": 0, "isPurchasableWithDough": false},
         {"reward": {"type": "EquippableCharmLevel", "uuid": "86cc0f4b-…", "amount": 1, "isHighlighted": false}, "xp": 2000, "…": "…"},
         {"reward": {"type": "Currency", "uuid": "e59aa87c-4cbf-517a-5983-6e81511be9b7", "amount": 1, "isHighlighted": false}, "xp": 2750, "…": "…"}
       ],
       "freeRewards": [{"type": "PlayerCard", "uuid": "3b8a10d9-…", "amount": 1, "isHighlighted": false},
                       {"type": "Title", "uuid": "6b20e6b1-…", "amount": 1, "isHighlighted": false}]},
      {"isEpilogue": true, "levels": ["… 5 levels, xp 36500 each …"], "freeRewards": null}
    ]
  }
}
```

- **Structure of current battle passes:** 11 chapters × 5 levels = 55 levels (10 normal chapters plus 1
  epilogue). `freeRewards` belong to the chapter (the free track). `levels[]` is the premium track.
- **XP per level (V26 Act V):** `0, 2000, 2750, 3500, …` (+750 each level) up to `38000` at level 50, then
  epilogue levels at `36500` each. Total 1,162,500 XP (980,000 for levels 1–50). The `xp` value is the XP needed
  **for that level**. Alignment with Riot `ProgressionLevelReached` (SUMMARY review, resolved by arithmetic on
  ValBuddy screenshot SS-1 "Level 46 / 55 · 7.966 / 35.750 XP" and SkinPeek `getNextReward`): let
  `flat = chapters.flatMap(c => c.levels)`; current level = `ProgressionLevelReached`; XP needed for the next level
  = `flat[ProgressionLevelReached].xp` (46 → `flat[46].xp` = 2000 + 45×750 = 35,750 ✓); bar =
  `ProgressionTowardsNextLevel / that`; total bar = `TotalProgressionEarned / Σ flat[].xp`. At level 55 the pass is complete.
- **Reward type → endpoint.** All 3,089 rewards in 87 contracts resolve (checked):
  `EquippableSkinLevel` → skin level, `EquippableCharmLevel` → buddy level, `Currency` → currencies,
  `PlayerCard`, `Spray`, `Title` → playertitles, `Totem` → `/v1/flex`.
- `Currency` rewards: Radianite (`e59aa87c-…`) almost always has `amount: 1` (636 of 638). **UNVERIFIED** whether
  that is the real in-game quantity; battle pass Radianite tiers are commonly believed to grant 10 RP, so do not
  display the amount. Kingdom Credits (`85ca954a-…`) rewards carry `amount: 2000` (24 rewards).
- **Agent contracts** (1 chapter, 10 levels): `xp` 20000 → 250000, `vpCost` 200 for the first 5, `doughCost`
  (Kingdom Credits) 2000 → 8000 with `isPurchasableWithDough: true`. `premiumVPCost: -1`.
- Level-skip VP price: `vpCost` is 0 with `useLevelVPCostOverride: true, levelVPCostOverride: -1`, so the real
  tier-skip price is **not available here (UNVERIFIED)**.
- **Current battle pass algorithm** (from [SP] `fetchBattlepassInfo`): list acts (`type == Act`) sorted by
  `startTime` descending, and take the first one that has a contract with `relationType == "Season"` and
  `relationUuid == act.uuid`. Between acts, the new act can start before its contract is published.

---

## 13. Pricing: getting a price when the store does not give one

valorant-api has **no prices at all**. Options, in order:

1. **Riot price list** (authenticated, same tokens as the storefront):
   `GET https://pd.{shard}.a.pvp.net/store/v1/offers/` ([VAD] "Prices")

   ```ts
   { Offers: { OfferID: string; IsDirectPurchase: boolean; StartDate: string;
               Cost: { [currencyUuid: string]: number };
               Rewards: { ItemTypeID: string; ItemID: string; Quantity: number }[] }[] }
   ```

   `OfferID == Rewards[0].ItemID == skin level-1 uuid`. VP price = `Cost["85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741"]`.
   [SP] builds `prices[OfferID] = first value of Cost` and refreshes it every 24 h or on a manifest change.
   [VS] (mobile, 2025) uses it too. **Status in 2026 is UNVERIFIED**: the sibling doc notes the game client no
   longer calls it. The response is the same for everyone, so cache it app-wide for 24 h (not per user) and
   degrade gracefully. Items missing from the offers list (battle pass, agent gear, VCT capsule, event rewards,
   default skins) should show a "Không bán" (not for sale) or source label instead of a price.
2. **Prices seen in the live store:** remember `Cost` from storefront, bundle and night-market offers the user has
   seen (bundle `BasePrice` per item, night market `Offer.Cost` = full price). [SP] does this with `addBundleData`.
3. **Tier fallback** ([RIOT-SUP], updated 2026-02-20): Select **875**, Deluxe **1275**, Premium **1775** VP;
   Ultra and Exclusive "vary". Community-reported typical values, **UNVERIFIED**: Ultra 2475, Exclusive 2175
   (often higher), and melee around 2× the gun price. Always label fallback prices as estimates ("≈").

Third-party price APIs such as HenrikDev `/valorant/v2/store-offers` now return **401 without an API key**
(checked live), so they are not usable anonymously.

---

## 14. Currencies

| uuid | vi displayName | Meaning | assetPath |
|---|---|---|---|
| `85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741` | VALORANT POINT | VP | `Currency_AresPoints_DataAsset` |
| `e59aa87c-4cbf-517a-5983-6e81511be9b7` | RADIANITE Point | Radianite (RP) | `Currency_UpgradeToken_DataAsset` |
| `85ca954a-41f2-ce94-9b45-8ca3dd39a00d` | Kingdom Credit | Kingdom Credits (KC); "Dough" internally | `Currency_Dough_DataAsset` |
| `f08d4ae3-939c-4576-ab26-09ce1f23bb37` | Huy Hiệu Đặc Vụ | Agent recruitment token | `Currency_RecruitmentToken_DataAsset` |

Shape: `{uuid, displayName, displayNameSingular, displayIcon, largeIcon, rewardPreviewIcon, assetPath}`. The vi names
are just English, so the app should use its own strings ("VP", "Radianite", "Kingdom Credits") and keep only
the icons from the API.

---

## 15. Events, gear, ceremonies, missions

### 15.1 `/v1/events` (18)

`{uuid, displayName, shortDisplayName, startTime, endTime, assetPath}`. Examples (vi): "Vé Sự Kiện Tết Nguyên Đán
2026", "Champions 2026: Shanghai" (active now), "Vé Sự Kiện VALORANT FC". One entry leaks keys
(`Event_CNLaborDay_DisplayName` / `Event_CNLaborDay_Shortened`), so fall back to en-US or hide it.
Event contracts point here via `content.relationUuid`.

### 15.2 `/v1/gear` (3)

| uuid | vi | cost |
|---|---|---:|
| `822bcab2-40a2-324e-c137-e09195ad7692` | Giáp Hạng Nặng (Heavy Armor) | 1000 |
| `4dec83d5-4902-9ab3-bed6-a7a390761157` | Giáp Hạng Nhẹ (Light Armor) | 400 |
| `b1b9086d-41bd-a516-5d29-e3b34a6f1644` | Khiên Hồi Phục (Regen Shield) | 650 |

Shape: `{uuid, displayName, description, descriptions[], details[{name,value}], displayIcon, assetPath, shopData{cost, category:"Armor", categoryText:"Khiên", …}}`.

### 15.3 `/v1/ceremonies` (6)

| uuid | assetPath stem | en | **vi** | Riot `roundCeremony` |
|---|---|---|---|---|
| `1e71c55c-476e-24ac-0687-e48b547dbb35` | AceCeremony | ACE | **QUÉT SẠCH** | CeremonyAce |
| `87c91747-4de4-635e-a64b-6ba4faeeae78` | TeamAceCeremony | TEAM ACE | **QUÉT SẠCH TOÀN ĐỘI** | CeremonyTeamAce |
| `eb651c62-421f-98fc-8008-68bee9ec942d` | FlawlessCeremony | FLAWLESS | **HOÀN HẢO** | CeremonyFlawless |
| `a6100421-4ecb-bd55-7c23-e4899643f230` | ClutchCeremony | CLUTCH | **XUẤT THẦN** | CeremonyClutch |
| `b41f4d69-4f9d-ffa9-2be8-e2878cf7f03b` | CloserCeremony | CLOSER | **NGƯỜI HẠ MÀN** | CeremonyCloser |
| `bf94f35e-4794-8add-dc7d-fb90a08d3d04` | ThriftyCeremony | THRIFTY | **CẦN KIỆM** | CeremonyThrifty |

Shape: `{uuid, displayName, assetPath}`, with no icons.

### 15.4 `/v1/missions` (947), `/v1/objectives` (optional)

`{uuid, displayName, title (vi), type: "EAresMissionType::Weekly|Daily|BTE|NPE|Tutorial"|null, xpGrant,
progressToComplete, activationDate, expirationDate, tags, objectives[{objectiveUuid, value}], assetPath}`.
This joins with Riot `GET /contracts/v1/contracts/{puuid}` → `Missions[]` (see sibling doc) for a
missions/XP screen. Objectives only carry `{uuid, directive, assetPath}`, so the text is in `mission.title`.

---

## 16. vi-VN data-quality issues to sanitize

| Issue | Where | Handling |
|---|---|---|
| Embedded `\n` | 1516 chroma names, 63 level names, 6 ability texts, Shotgun `categoryText` | Split into name and sub-label. `trim()` everything |
| Leading or trailing spaces | 7 buddy names, 11 spray names, 6 card names, 4 titles, 3 skin names, 15 level names | `trim()` |
| Raw localization keys | 320 buddy-level names (`Coin_EP2_A1`), 106 spray-level names, 1 card, 1 event, 2 bundle descriptions | Detect `^[A-Za-z0-9]+(_[A-Za-z0-9]+)+$` and fall back to the parent name or en-US |
| Untranslated "vi" strings | "Kingdom Credit", "RADIANITE Point", "RADIANT", "Gauntlet: Glitched" (and "10-15 MINS"), "Knockout", "Retake", "Premier", "\nShotgun" | App-owned vi overrides for enums and currencies |
| Inconsistent casing | Ranks and ceremonies in ALL CAPS, weapon categories mixed | Normalize in the UI layer |
| `null` names | default title `d13e579c-…` | Show "Không có danh hiệu" |

**Recommended app-owned vi glossary** (keep it in `lib/l10n`, keyed by enum or devName and not by API text):
weapon-category labels keyed by the `category` enum (use the in-game vi strings where they exist, such as
"Súng phụ", "Súng Trường", "Súng bắn tỉa", "Vũ Khí Hạng Nặng"; the product owner picks the Shotgun label because
the API has none), `levelItem` labels (§3.2), currency labels, and "Phiên bản giới hạn" for LimitedEdition.

---

## 17. Suggested Dart model / index layout

```
ContentDb (built in an isolate from the cached JSON)
  version: VapiVersion(manifestId, riotClientVersion, buildDate)
  weapons:        Map<uuid, Weapon>
  skinByLevel:    Map<levelUuid, (Skin, Weapon, levelIndex)>    // store, entitlements, loadout
  skinByChroma:   Map<chromaUuid, (Skin, chromaIndex)>
  skinByUuid:     Map<skinUuid, Skin>
  contentTiers:   Map<uuid, ContentTier>   (+ by devName)
  bundles:        Map<uuid, Bundle>                              // DataAssetID
  buddyByLevel:   Map<levelUuid, Buddy>; buddies: Map<uuid, Buddy>
  sprays, cards, titles, flex, levelBorders(sorted by startingLevel)
  agents:         Map<uuid, Agent>
  mapsByUrl:      Map<mapUrl.toLowerCase(), GameMap>
  queues:         Map<queueId, Queue>;  gameModesByDir: Map<dirKey, GameMode>
  tierTables:     Map<uuid, List<Tier>>;  compSeasonBySeason: Map<seasonUuid, CompSeason>
  seasons:        Map<uuid, Season>;  contracts: Map<uuid, Contract>
  currencies, gear, ceremoniesByKey("Ace"→…), events
```

Look up with `uuid.toLowerCase()`. Every accessor returns a nullable value, and the UI shows placeholders.

---

## 18. Open risks / UNVERIFIED

1. **`/store/v1/offers` availability in 2026** is unconfirmed (the sibling doc marks it legacy). Without it,
   collection and wishlist prices are estimates. The tier fallback is exact only for Select, Deluxe and Premium.
2. **valorant-api.com is a third-party service** with no SLA, no documented rate limits and unknown terms. An
   outage breaks every name and image. Mitigate with a persistent disk cache, a bundled snapshot of the small
   tables, and possibly our own mirror (Cloudflare R2 or Workers) later.
3. **Lag after patches:** new store bundles or skins may be missing for hours after a Riot patch. Needs the
   per-UUID fallback and a placeholder UI.
4. **Change frequency without a manifest bump** is unknown, which is why the 7-day TTL and refresh-on-miss exist.
5. ~~Contract XP indexing~~ resolved (see §12). The real Radianite reward `amount` still needs testing with a real account.
6. **Game-mode path mapping:** the class filenames differ between sources, and the directory-key approach is an
   inference. Unit-test it with real match JSON from each queue, including Swiftplay, TDM, Premier and custom.
7. Custom game `queueID` is `""` (resolved, §9.1). `damageItem` weapon UUIDs arrive UPPERCASE in real 2026 responses (DailyStore); lowercase before lookup.
8. **Minimap projection formula** and the **act rank triangle algorithm** are community knowledge that I did not test.
9. **Video URLs** embed the patch branch (`release-13.06`), so cached URLs go stale each patch, and HEAD returns 403
   (use GET or Range). Riot CDN hotlinking policy is **UNVERIFIED**.
10. **Parsing cost** of the 3.6 MB `/v1/weapons` on low-end Android needs a benchmark. Consider slimming the stored
    JSON and deriving URLs.
11. **Vietnamese text quality** (keys, `\n`, English leftovers) needs app-side overrides. Rank names are ALL CAPS
    and "RADIANT" is not translated; confirm the product preference ("Radiant" vs "Tỏa Sáng").
12. **Legal:** Riot's fan-content policy covers use of the game assets that valorant-api re-hosts. An App Store
    review may question the Riot branding. Out of scope here, but flag it for the product owner.
