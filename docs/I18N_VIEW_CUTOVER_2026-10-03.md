# ValHub view labels and accessible language confirmation — build 4014

This extends [content/locale/RR checkpoint 4013](I18N_CONTENT_CUTOVER_2026-10-03.md). It is a verified implementation checkpoint, not whole-product or store acceptance.

## Gap map before implementation

| Area | Initial status | Actual gap |
|---|---|---|
| Enum/view captions | 🟡 PARTIAL | Collection types, rewards filters, Community tabs/sorts and live status held legacy captions. IDs and parsers already worked. |
| Default widget labels | 🟡 PARTIAL | Retained const widgets captured Vietnamese badge, scope, delete and reaction semantics defaults. |
| Async actions | 🟡 PARTIAL | Equipment, tickets, consent, comments, chat, live selection and share callbacks still used fixed success/failure strings. |
| Language confirmation | 🔴 MISSING | No successful-save screen-reader announcement; the picker/persistence architecture already existed. |
| Global cutover | 🟡 PARTIAL | Baseline 195 production refs / 762 literal hits / 52 structural definitions; only VI ships. |
| Production acceptance | ⚠️ BLOCKED | Signing, physical devices, domain associations and operational acceptance remain external. |

## Implemented

Existing generated resources now supply enum/view captions and nullable widget defaults at render time. Route/query IDs, filter behavior, retained reaction state and explicit caption overrides remain unchanged. Community rating words, report reasons and the compatibility country-name fallback use generated resources; the full localized CountryNames asset provider still takes precedence. Unknown country codes remain raw data. Server report codes/order are unchanged.

Callbacks capture resources before awaiting operations and retain existing confirmation, mounted and error behavior. Store sharing retains its compatibility filename prefix. Collection descriptions use a manual ICU select message; no copied Vietnamese translation files or second localization system were introduced.

After a changed UI-language preference is saved and the frame completes, the picker announces the effective language using the current view/direction. Cancel, same choice and save failure do not announce success. Speech-channel failure does not undo a successful save. `ui_locales` was already wired into the Riot authorize URL; this checkpoint does not claim all-language live authentication acceptance.

Seven meaningful tests cover enum/route/description parity, stable report codes/rating bounds, country asset precedence, retained const-widget text/semantics reload, successful announcement, cancellation/save failure and speech-channel failure. Existing assertions were preserved. The first new semantics test leaked its harness handle until teardown; it was corrected with immediate try/finally disposal. That negative run and initial analyzer cleanup are retained locally.

## Verification

| Check | Actual result |
|---|---|
| Windows analyze / default tests / device-en tests | 0 issues / 4,299 / 4,299 passed; device-en uses VI fallback |
| Mac analyze / tests | 0 issues / 4,299 passed (8m23s) |
| gen-l10n / l10n_check --ci | pass / 0 errors, 0 warnings |
| Existing extractor and parity checks | pass; 1,612 members / 1,754 mechanically generated messages |
| Codemod analyze / tests | 0 issues / 37 passed |
| Global verify --ci | **exit 1**, 129 production refs / 762 literal hits / 52 structural definitions; readyForCutover=false |
| Backend test / typecheck / build / production dependency audit | 867 tests in 34 files / pass / pass / 0 vulnerabilities |
| Android release build / public-flow QA | pass / 10 passed on emulator 5582 |
| Mac unsigned iOS release build / privacy manifest lint | pass, Runner.app 82.8 MB, Xcode 53.4s / pass |

All **839 source input hashes** matched Windows and Mac after CI/build. The copied IPA hash, bundle metadata, privacy manifest and absence of bundle code signing were independently verified on Windows. The expected failing localization gate is retained in `dist/review/view-4014/`; it does not become production acceptance because other checks pass.

Artifacts are retained beside earlier versions:

* `dist/review/ValHub-1.0.0-4014.apk`: SHA-256 `C802B1148265484D75FF7AB35EF6441F330C7B29AAB1B3003D1ECF0933A870B9`, 125,338,647 bytes, ValHub / `vn.valvn.app`, min 24 / target 36, **AndroidDebug signed**.
* `dist/review/ValHub-1.0.0-4014-unsigned.ipa`: SHA-256 `2EC1FA4CAFF208E0F138103CD2428B9FC4F4073F42A42B143B8DB6EF9A8E88A4`, 28,012,357 bytes, ValHub / `vn.valvn.app`, min 15.5, **unsigned**.

Owner emulator 5554 was upgraded with install -r and its window remains visible. Mobile MCP hierarchy and real Riot cache verify switching through all **four real accounts**: each displays four Store wishlist controls matching its own four cached daily offers; original active account was restored. Four-account identities, wishlists and settings survived upgrade. Twenty account cache JSONs were readable, with no corrupt entry or Subject/account mismatch. Five tabs and return to Store were exercised without a login/retry prompt.

A bounded **259-second** log window recorded HTTP 200=97, 404=25 and three successful reauth events; no current-process Flutter/fatal/ANR error line was found. A later **398-second** classification window identified game-session/party-resource GET 404s and Store storefront POST/name-service PUT 200s. These latter operations are reads, not purchases or profile mutations; the later counts are not substituted into the first window. An emulator latency sample is not a production performance acceptance test. No live public post/comment/like, purchase, loadout or party mutation was made in this checkpoint. Private hierarchy/account/cache/log proof remains ignored and uncommitted.

The existing 18-content-language picker was also inspected through native hierarchy, including Japanese/Korean/Thai/Arabic/Chinese names, and canceled without changing preferences. Announcement platform-channel tests do not substitute for actual TalkBack/VoiceOver acceptance.

## 🟢 VERIFIED COMPLETE

The captions/defaults/callback migrations and language-announcement behavior above are verified by focused and full tests. Android public flows, upgrade preservation, four authenticated account Store reads/switches and bounded successful reauth are verified within the exercised scope.

## 🟡 PARTIAL

W2–W7 and whole-product acceptance remain incomplete. Date/time helpers and statistics still require view-boundary work. First fresh login, full Community write/moderation acceptance, PC equipment behavior, all-screen accessibility and real-device performance are not proved here.

## 🔴 RELEASE BLOCKER

Global localization cutover remains false and 17 genuine additional UI translations are absent. Only VI UI ships; content locale choices do not represent shipped UI translations.

## ⚠️ EXTERNAL BLOCKER

Store signing/accounts, physical iPhone and active PC gameplay, production domain/App/Universal Links, server monitoring/restore, linguistic/legal review and GitHub billing remain external. GitHub jobs did not start because of its billing lock; local CI cannot unlock it.

## ❌ REGRESSION

No remaining regression was observed in the exercised scope after final checks. This does not certify every endpoint, device or business workflow.
