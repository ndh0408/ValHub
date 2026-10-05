# ValHub — Guardian card image, QA build 4025

Bounded fix after `d20cf2f`; this does not close the whole-product release gates.

## Reproduced cause

Mobile MCP identified the third Home offer as **Guardian Hoàng Gia, 1,775 VP**.
The public skin UUID is `2a049f35-4bcd-af25-21fd-ec942e2d5007`; its English content
name is **Prime Guardian**. The parent display-icon URL returns HTTP 200/image/png
with a 512×512 black-background X. This is image content from the media source,
not `NetImage`'s small load-error icon. The owner's media cache contained those
same bytes. The matching base-level icon returns the actual 512×104 Guardian
artwork; base chroma/icon/full-render responses match that artwork by SHA-256.

Previously `WeaponSkin.image` selected the parent first because it was non-null.
It now selects the base-level icon first, retaining parent and chroma fallbacks
when absent. Home, Store and other consumers use the existing shared model;
no skin-specific UUID allowlist, replacement item, price alteration or second
image/cache system was added. Large-render priority is unchanged. Existing cache
files are preserved; the valid level URL uses its own cache entry.

## Verification

- A regression test failed on the old getter; three fallback/render controls
  passed. The fix passes all four. The fixture's English label was corrected
  against the live EN response; URL assertions and runtime behavior are unchanged.
- Windows analyzer: **0 issues**; **377 existing/new Content/Home/Store/Skin Detail
  tests pass**, including layout checks. The four regression tests were rerun
  after the test-label/comment correction. The entire Flutter suite was not rerun
  for this bounded image change; full-suite evidence remains the 4024 checkpoint.
- Android release-mode APK **4025** and **10 public smoke flows** pass. The APK
  retains `vn.valvn.app`/ValHub and the existing debug certificate; it is not a
  signed store release.
- Owner upgrade preserves **six accounts**, original active account, wishlist
  and settings. Mobile MCP still reads the same skin/price. The base-level image
  was absent from cache before upgrade; afterward it is cached at **512×104**,
  matching the public artwork byte for byte. Logs show **0 native fatal/unhandled
  exceptions**. No account, wishlist or media cache was erased.
- Mac: analyzer **0 issues**, **4 regression tests pass**, unsigned release iOS
  build **4025** and privacy-plist/identity checks pass. Runtime code matches the
  Android fix; only the explanatory comment and fixture English name were
  corrected afterward and the four tests rerun. No iPhone or signed-store
  verification is claimed.

| Artifact under `dist/review/` | Bytes | SHA-256 |
|---|---:|---|
| `ValHub-1.0.0-4025.apk` | 125587702 | `cb36f031350a3d06ef4e77607800d65df72e135d8f1e4e5633c0f13f5369bf29` |
| `ValHub-1.0.0-4025-unsigned.ipa` | 28002096 | `f8e1e97b8d17a37d43759ec24af93d619d6c45c2ac88dd7c8d3c733fe0049455` |

Local evidence: `dist/review/skin-x-2026-10-05/` (ignored), including public metadata,
media response probes, failed regression, passing checks and owner cache proof.
The source URLs are public content IDs; reports do not expose raw account IDs,
credentials or tokens.

This fixes the observed parent-image choice. It does not implement pixel-level
placeholder detection or establish that all remote level images will always be
valid. Localization, signing, physical-device and other release gates from
[4024](LEGAL_ASSETS_AND_FALLBACK_2026-10-05.md) remain open.
