# ValHub model display and private export guard — build 4018

This extends [4017](LFG_AND_SESSION_COMMIT_2026-10-03.md). Whole-product acceptance remains incomplete. The existing localization, account, storage, sharing and backend architectures are preserved.

## Gap map before implementation

| Area | Initial status | Evidence |
|---|---|---|
| Sort/equipped/wishlist labels | 🟡 PARTIAL | Model enums/helpers retained Vietnamese captions despite the migrated widgets. |
| Bug report/export sharing | 🟡 PARTIAL | Native subjects and report headers still read legacy string tables. |
| Private export account lifecycle | 🔴 MISSING | With export GET held, switching away still opened the old account's share sheet. The new regression test failed before the fix. |
| Preset names/save errors | 🟡 PARTIAL | New automatic names and failure details were baked into domain code; a pending unchanged proposal could collide with another save. |
| Store share missing content | 🟡 PARTIAL | Data retained a UI-language fallback instead of resolving unknown content when rendering. |
| Global cutover/release | 🟡 PARTIAL / ⚠️ BLOCKED | 62 legacy refs at the start; missing translations and external release acceptance remain open. |

## Implemented and verified

Sort enums, wishlist places and loadout failure models now retain neutral data. Display adapters take the existing generated resources explicitly. Standard skin captions resolve at render time; actual API skin/bundle names stay intact. Both wishlist consumers and every equipped-skin consumer were migrated. Independent Vietnamese expectations in existing tests remain intact.

Bug reports use messages captured before the asynchronous operation, including their header and native subject/title. The sharing scrubber still removes Unicode Riot IDs, passwords, tokens, cookies and account identifiers. Export files likewise capture the initiating resource title, clock and sharing callback before awaiting; compatibility filenames and JSON format are unchanged.

`exportAndShare` requires the current account and granted Community consent. Its pending operation latches changes to active account, account existence and consent. Switching away and back, removing the account, withdrawing consent or disposing the provider prevents the late share. Subscriptions close in `finally`; no private export is persisted on disk by this flow. The pure `export` method still returns account-scoped data to its caller; this guard specifically protects the user-facing share action. A native chooser already opened cannot be recalled by this guard.

New automatic preset names use the active resources; the dialog captures its resource builder and original proposal. If another preset was saved while waiting, an unchanged proposal receives the new unique number. Stored custom/automatic names retain their original language. The Vietnamese matcher is retained explicitly for old persisted presets without `dn`, as a data compatibility rule. No account, wishlist, history, preset or notification key was renamed.

Unknown Store share content remains neutral/empty in data and renders the existing localized unknown-item message. Missing Riot prices remain null. Test-only probe resources demonstrate supplied-message use; they are **not** a shipped English translation.

Thirteen new cases cover six export lifecycle paths, two resource adapter checks, three preset cases and two missing-content share cards. The focused suite passed **347** cases. An initial test incorrectly expected the next preset number to equal the largest legacy number plus one; the fixture was corrected to exercise collision with the actual next candidate, preserving the collision/persistence assertions. Temporary import placement errors were corrected before freezing. Negative attempts remain local; no failing test was deleted, skipped or weakened.

## Verification

| Check | Actual result |
|---|---|
| Windows default / TEST_LOCALE=en / analyzer | **4,332 / 4,332 passed / 0 issues**; en uses VI fallback |
| Mac default / analyzer | **4,332 passed (13m12s) / 0 issues** |
| gen-l10n / l10n_check / extract / parity | pass; 0 l10n errors/warnings |
| Codemod tests / analyzer | **37 passed / 0 issues** |
| verify --ci | **exit 1**: **35 refs / 762 Vietnamese literals / 52 structural members**, readyForCutover=false |
| Backend tests / typecheck / build / dependency audit | **900 / pass / pass / 0 vulnerabilities** |
| Android release build / public QA | pass (107.9s) / **10 public cases passed** on emulator 5582 |
| Mac unsigned iOS release build / privacy lint | pass / pass |

The local runner records the known failing cutover gate explicitly; it is not evidence of a fully green release pipeline. All **847 frozen Flutter/tool/content input hashes** match on Windows and Mac after final CI/build. Copied IPA hash, bundle metadata, privacy manifest and absence of signing were independently verified. All **131 unchanged backend input hashes** from 4017 still match after backend CI. No backend deployment occurred here.

* APK `dist/review/ValHub-1.0.0-4018.apk`: SHA-256 `92FE1375A217515E9F74297FF00FBAC962457CE28FDCC187B66710BA9FEEFEB1`, 125,420,567 bytes; ValHub / `vn.valvn.app`, **Android Debug signed**.
* IPA `dist/review/ValHub-1.0.0-4018-unsigned.ipa`: SHA-256 `D16FB0763BDAAA19DB030BDEA8F7005CB2B8900DFC47D78513BF86BC5CB2EDDD`, 28,011,155 bytes; ValHub / `vn.valvn.app`, min 15.5, **unsigned**.

Owner emulator 5554 is visibly open on Store, version 4018. Actual Mobile MCP hierarchy, preferences/cache and current-process logs verify preservation of four real accounts, wishlist and four settings keys. All four accounts have four separate real offers and five account cache files; the original account was restored. Four displayed VP prices match actual Riot Offer Cost. Five tabs and return to Store were exercised without re-login/retry prompts. A 143-second observation recorded HTTP 200=77 / 404=21 and one successful reauth event; all requests are not claimed successful. Twenty cache JSONs were readable without Subject/account mismatch, and no current-process Flutter/fatal/ANR error line appeared. These checks do not prove every live business flow.

Unit/widget logs retain caught `NotificationService.init failed: LateError` messages from desktop tests without a native notification plugin; the same messages are present in 4017 logs. They were not hidden or treated as an iOS device result. Android/iOS build logs retain plugin migration warnings for future Flutter versions; present builds succeeded. Physical notification acceptance remains separate.

Private device/account evidence and proofs remain ignored under `dist/review/model-4018/`. No credentials, private account identifiers, private exports or user screenshots were committed. No public post, purchase, equipment or party mutation was performed in this checkpoint. Existing free ML Kit is retained; no paid AI/API was added.

## 🟢 VERIFIED COMPLETE

The model/display migrations, exercised private export guard, preset naming fixes and unknown-content rendering are verified by the final evidence above. Bounded Android real-data checks and Mac unit/widget/build verification passed.

## 🟡 PARTIAL

W2–W7, remaining account/rank/format/legal strings, content fallback, translations/status, all-screen accessibility/performance and full live business acceptance remain incomplete. Community private/friends ACLs and server peer blocking remain absent; hide/block is device-local. Native moderation and production operations are not certified.

## 🔴 RELEASE BLOCKER

Global cutover is still false. Seventeen additional genuine UI translations are absent. Whole-product acceptance and live final-slot Riot behavior are not established. The 4017 backend security fix is committed/tested but has not been deployed to production.

## ⚠️ EXTERNAL BLOCKER

Signing/store accounts, physical iPhone/PC gameplay, HTTPS domain associations, production deployment/monitoring/restore and linguistic/legal review remain external. GitHub billing still prevents hosted checks starting; local CI does not unlock GitHub.

## ❌ REGRESSION

No remaining regression was observed in the final exercised scope. The reproduced late private share is fixed. This is not all-device/all-business production acceptance.
