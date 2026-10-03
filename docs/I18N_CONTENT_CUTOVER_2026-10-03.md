# ValHub content localization and RR loading — build 4013

This extends [Community account isolation / 4012](COMMUNITY_ACCOUNT_ISOLATION_2026-10-03.md).
It is an implementation checkpoint, not whole-product or store acceptance.

## Gap map before implementation

| Area | Initial status | Verified gap |
|---|---|---|
| Content fallback tables/models | 🟡 PARTIAL | Currency/tier/title/type/reward labels retained Vietnamese inside data built in an isolate. |
| Queue and price captions | 🟡 PARTIAL | UI consumers and a Home live snapshot retained app-owned fixed text. |
| Content-language preference | 🟡 PARTIAL | Runtime supported only legacy VI/EN, independently of the existing 18-locale table. |
| Settings persistence | 🟡 PARTIAL | Two tests reproduced simultaneous writes and missing rollback after disk failure. |
| RR loading | 🟡 PARTIAL | Mac full tests exposed a pending RR Future disposed when a history change invalidated the provider. Two controlled change-during-read tests reproduced the same failure locally. The change was not attributed to this localization patch without evidence. |
| Global cutover | 🟡 PARTIAL | Baseline 262 production legacy refs / 762 Vietnamese literal hits / 52 structural definitions; only VI ships. |
| Signing / production acceptance | ⚠️ BLOCKED | Store signing, actual iPhone/PC gameplay, domain associations and production operational acceptance remain external. |

## Implemented

* Existing `ContentLabels` and new view-only economy adapters take explicit current resources. Models preserve API names and IDs; fallback tables retain neutral IDs/icons/colors/ranks, without translated names. Currency, tier, item type, empty title, reward source, queue and price captions resolve at the view boundary. No locale global, replacement cache or translation system was added.
* API names retain their content language. Known fallback captions use current UI resources when content/UI differ. Matching non-VI content uses supplied API names; VI full tier names retain existing API spelling when present. Unknown real API names/queue IDs remain data, not fabricated translations. Tier price values and estimate flags are unchanged.
* Store/Collection/Battle Pass/Home/Profile/Live/Social/Wishlist consumers use the adapters. Home's transient live snapshot holds queue/mode IDs instead of a localized mode label. These snapshots are not persisted; account/storage/protocol compatibility identifiers remain unchanged.
* `AppSettings.contentLocale` supports `app` or any of the existing 18 canonical API tags. The picker uses 18 native language names plus Follow app. UI shipping remains VI; a content-language option does not assert that an app UI translation exists.
* Legacy `itemLanguage: vi` migrates to `app`, and `en` remains `en-US`. Existing UI upgrade pin is retained. Compatibility constructors/setters and the legacy JSON key remain available. Current choice is serialized separately; changing another preference retains it. Invalid content tags fail closed to `app`.
* The existing content repository, miss-refresh flow and effective-locale handoff use `contentLocaleProvider`. Follow app tracks effective UI language; manual content selection stays pinned. A background task reads an explicit fresh content setting ahead of a stale handoff. A legacy JSON setting without the new key preserves the prior handoff precedence and legacy fallback behavior.
* App settings writes are serialized. A failed write restores the last committed state when it is still the latest preview; the queue remains usable afterward. This is UI-isolate ordering, not a claim of cross-process transactional storage.
* RR history temporarily retains its provider while reading and coalesces history-change invalidation until the result/error has reached the caller. Existing observers then refresh. The retention/subscription/timer release after use; no continuous polling, extra permanent cache, history write or account-ownership rule was introduced.

## Verification

| Check | Actual result |
|---|---|
| Windows `flutter analyze` | 0 issues |
| Windows `flutter test` | 4,292 passed |
| Windows `flutter test --dart-define=TEST_LOCALE=en` | 4,292 passed; VI fallback, not an English UI translation |
| Mac `flutter analyze` / `flutter test` | 0 issues / 4,292 passed (13m06s) |
| `flutter gen-l10n` / `dart run tool/l10n_check.dart --ci` | pass / 0 errors, 0 warnings |
| Codemod extract/parity `--check` | pass; 1,612 members / 1,754 mechanically generated messages / 52 structural definitions |
| Codemod `dart test` / `dart analyze` | 37 passed / 0 issues |
| `dart run tool/l10n_codemod/bin/l10n.dart verify --ci` | exit 1; **195 references / 762 literal hits / readyForCutover=false** |
| Backend existing scripts `test`, `typecheck`, `build` | 867 passed in 34 files; typecheck/build pass |
| `npm audit --omit=dev` | 0 vulnerabilities |
| Android release build / public smoke | 119.5 MB / 10 passed, QA emulator 5582 |
| Mac unsigned iOS release build | 82.8 MB; Xcode build 56.9s; packaged privacy manifest lint passes |

All 838 source input hashes matched both machines after final CI/build. The final
Windows checks are in ignored `dist/review/content-4013/windows-ci-results.json`.
The expected nonzero cutover gate is preserved; local product acceptance is not green.
The second keyword audit scans tracked/new text, with protocol identifiers, fixtures
and historical documentation distinguished from actual unfinished production work.

Artifacts (kept beside older checkpoint files):

* `dist/review/ValHub-1.0.0-4013.apk`: SHA-256 `35A13F4CA5E8C686BC40484F348D8D640BFB9F629584310561E2FC1154FB5C03`, 125,256,727 bytes, `vn.valvn.app`, ValHub, min 24 / target 36, **AndroidDebug signed**.
* `dist/review/ValHub-1.0.0-4013-unsigned.ipa`: SHA-256 `D1FC58FF2B3413298ADC9A9C4DCF7DEE5AFA4D90B7C85CABC2FDE733B9E12C4E`, 28,003,275 bytes, `vn.valvn.app`, ValHub, min 15.5, **unsigned**. The copied ZIP hash, bundle/version/name and packaged privacy manifest were independently checked on Windows.

Owner emulator 5554 was upgraded with `install -r`; its window remains visible.
Original hashed preferences confirm four accounts, active account, wishlists and
four settings keys are preserved. Actual Mobile MCP verifies four Store wishlist
controls matching four real Riot cached daily offers, then five tabs and return
to Store. A bounded 291-second sample records HTTP 200=109 / 404=3, 20 readable
account cache JSONs, no Subject/account mismatch and no current-process Flutter/
fatal/ANR error line. This is a bounded authenticated read/navigation check, not
complete live business acceptance.

The first upgrade observation failed because it evaluated Home instead of a
verified Store destination. That failure is retained; Store was subsequently
selected through the current bottom-navigation reference and the original data
assertions passed. Later route classification identifies storefront POST and
name-service PUT as reads, and missing game-session/party resources as 404s;
counts from the later window are not substituted into the 291-second sample.
No live public post/comment/like, purchase, loadout or party mutation was made.
No account IDs, tokens/cookies or private device hierarchy/proofs were committed.

27 meaningful tests were added: nine content-boundary/isolate/resource-reload cases, seven content-setting/provider/background/write-order cases, eight picker width/direction cases at 200% text, and three RR change-during-loading/result/error/observer-refresh cases. Existing expectations were retained at the explicit view boundary; the deliberate new native-name picker behavior updates the former two-language UI assertion.

The picker matrix covers 320/360/393/600 dp, LTR/RTL, 200% text. It is not all-screen font/RTL/device acceptance. Synthetic resource reload tests do not constitute real translations. Negative settings and RR runs, the initial Mac RR failure, analyzer cleanup and extractor ordering-only correction are retained in ignored local evidence; none is counted as final success.

## 🟢 VERIFIED COMPLETE

Content/view isolation, the independent 18-tag content preference and compatibility/background handoff, ordered settings writes and RR change-during-read handling are verified within the tests above. Android public flow and bounded authenticated reads are verified; this does not certify all backend endpoints or production operation.

## 🟡 PARTIAL

W2–W7 and complete product acceptance remain incomplete. Live first-login/reauthentication, immediate PC equipment update, production Community writes/moderation and broader accessibility/performance acceptance are not proved by these tests.

## 🔴 RELEASE BLOCKER

Global localization cutover and 17 genuine additional UI translations remain unfinished; no unshipped locale was enabled or populated with copied Vietnamese.

## ⚠️ EXTERNAL BLOCKER

Owner signing/store setup, physical iPhone and active PC/gameplay acceptance, production domain/App/Universal Links, server operational monitoring/restore and legal/linguistic acceptance remain external. Local CI does not unlock GitHub billing.

## ❌ REGRESSION

Existing RR loading race is fixed; both full Windows runs and the final Mac run pass. No remaining regression was observed in the exercised scope; whole-product regression freedom is not asserted.
