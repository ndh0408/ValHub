# ValHub Community account isolation — 03/10/2026, build 4012

This extends [callback isolation, build 4011](I18N_CALLBACK_ISOLATION_2026-10-03.md).
This is an incremental implementation and verification checkpoint, not whole-product acceptance.
The audit focused on Community drafts, delayed operations, translation and their existing localization architecture.

## Gap map before implementation

| Area | Initial status | Evidence and gap |
|---|---|---|
| Composer account isolation | 🟡 PARTIAL | One State retained account A's text, photos and store attachment under account B. A delayed publish could close B's composer. |
| Upload/publish lifecycle | 🟡 PARTIAL | Closing a composer while an upload was pending still allowed the next upload and post request. |
| Post/comment account isolation | 🟡 PARTIAL | The comment draft remained across accounts; after fixing the provider response, A's completion cleared B's draft. |
| Post action/provider lifecycle | 🟡 PARTIAL | Like success/failure, delete and add-comment responses accessed disposed Refs. |
| LFG action lifecycle | 🟡 PARTIAL | Party-read/open/code generation and create/delete responses accessed closed WidgetRefs. Existing loaded own-post data also needs to follow a completed server write after the sheet closes. |
| Translation lifecycle | 🟡 PARTIAL | An old result could replace updated text, poison its cache key, or remain visible after the target language changed. |
| Composer consent/navigation | 🟡 PARTIAL | Switching accounts during the consent sheet still opened the predecessor's composer. |
| Community localization | 🟡 PARTIAL | Mode/shard/language labels and State action messages still called fixed legacy strings. Global baseline: 307 references / 762 literal hits / 52 structural definitions. |
| Existing API/backend | ✅ VERIFIED COMPLETE | Existing regression suite and ownership architecture retained; this status concerns existing tested behavior, not a new production endpoint security certification. |
| Global release | ⚠️ BLOCKED | Genuine translations, live production acceptance, signing/domain/store/infrastructure evidence remain separate requirements. |

## Implemented and reproduced

* Composer and post-detail internal State now have account keys; post detail also keys the post ID. Private text, photos and transient busy state reset when the account changes. Initial store/post attachments belong to the account that opened them; another account does not inherit them. Public constructors and routes remain compatible.
* Delayed responses cannot clear another account's new draft or close its composer. The consent-to-composer boundary checks the original active account before navigation. Consent storage remains per account.
* The existing `publishPost` helper accepts an optional continuation guard, checked before each upload and before the post request. A closed/switched composer stops subsequent steps. A request already sent may still commit on the server: this does not promise server cancellation or undo. Media cleanup architecture is retained.
* LFG code generation stops after a pending read/open/generation when the sheet closes. Completed create/delete requests update already-loaded own-post/list notifiers without retaining a WidgetRef. Disposed notifiers ignore local changes; removing an own post checks its ID. No automated party mutation was added.
* Delayed post likes apply the server's authoritative count to an existing feed, including after detail disposal; failed likes restore the original feed item. Post deletion updates an existing feed safely. Added comments return safely when their provider was disposed. Shared local replace/remove operations guard `ref.mounted`.
* Translation captures the original text and uses a revision to reject stale results, including text A → B → A. Target-language changes clear the prior displayed translation and busy state. Download checks immediately lock repeated taps; cancellation unlocks retry. Cache keys use captured text. Existing free on-device ML Kit and Google's required attribution remain; no paid AI/service was added.
* Migrated **45 production references**, **307 → 262**. Mode/shard names use two manual ICU selects with truthful unknown branches; native language names use existing resources. State action messages capture resources before awaits. Country, shard, language and API identifiers remain separate. Vietnamese parity is tested for every mode/shard/native-language branch, including unknown values.

There are **19 added tests**: 18 behavioral cases plus one manual-label parity test.
Negative runs reproduced the relevant old behavior: three composer cases, four LFG lifecycle cases, four translation cases, four disposed post actions, two comment UI cases, and the consent/account navigation case. Test harness timing/override errors were corrected before recording these negative reproductions; they are not counted as app regressions. The second comment UI reproduction used the fixed provider with the old UI, exposing the stale draft-clearing callback directly.

## Final local CI and artifacts

| Check on final source | Result |
|---|---|
| Windows `flutter analyze --no-pub` | **0 issues** |
| Windows `flutter test --no-pub --reporter expanded` | **4,265 passed** |
| Windows `flutter test --no-pub --dart-define=TEST_LOCALE=en --reporter expanded` | **4,265 passed**, VI fallback, not English translation acceptance |
| Community + render-label focused suite | **319 passed** |
| `flutter gen-l10n` / `dart run tool/l10n_check.dart --ci` | Pass / **0 errors, 0 warnings** |
| Existing `extract --check` / `parity --check` | Pass; 1,612 members / 1,754 mechanically generated messages / 52 structural definitions |
| `dart run tool/l10n_codemod/bin/l10n.dart verify --ci` | **Exit 1**; **262 references / 762 literal hits**, cutover **false** |
| Existing codemod `dart test` / `dart analyze` | **37 passed / 0 issues** |
| Backend `npm test` | **867 passed, 34 files** |
| Backend `npm run typecheck` / `npm run build` | Pass / pass |
| Backend `npm audit --omit=dev` | **0 vulnerabilities** in that audit output |
| Dart format check | **723 files, 0 changed** |
| Mac source verification | **834 input hashes** matched final Windows source; 25 changed files transferred from the previous checkpoint |
| Mac `flutter analyze` / full `flutter test --reporter expanded` | **0 issues / 4,265 passed** |
| Android `flutter build apk --release` | Pass; **119.4 MB**, version 4012, min SDK 24 / target 36, `vn.valvn.app`, ValHub |
| APK signer | Verified **Android Debug**, review artifact; not production signing |
| APK public-flow smoke, emulator 5582 | **10 passed**, including cold/warm deferred links, WebView/cancel, legal screens, landscape and 200% text |
| Mac `flutter build ios --release --no-codesign` | Pass; **82.8 MB** Runner.app, version 4012, min iOS 15.5, ValHub, `vn.valvn.app` |
| IPA packaging | Local copied SHA, bundle metadata and packaged privacy manifest verified; **unsigned**, no physical iPhone/App Store acceptance claim |

The first Android `--no-pub` attempt failed on a generated integration-test plugin registration. The standard release command regenerated the correct plugin list and passed. No registrant was edited by hand or plugin/test removed. An initial Mac analyzer run found two async-context lint findings; explicit mounted guards fixed them before the final full run. The earlier 4,258-test source checkpoint is retained as intermediate evidence, not mislabeled as final source.

Android artifact: `dist/review/ValHub-1.0.0-4012.apk`.
SHA-256: `B0BCBF61E39617F9432F15CA7E11E1800E854106B24218B7D50BD708EBC72874`.

iOS artifact: `dist/review/ValHub-1.0.0-4012-unsigned.ipa`.
SHA-256: `498446C31B609654E2D70FB567973DC7D226F0D95A879FB0D8B5F1F68CD6227A`.

Mac: SSH to the existing isolated QA directory, macOS 26.6 x86_64 / Xcode 26.5 / Flutter 3.47.5. No owner project or unrelated files were deleted. Native Android integration evidence (six cases) remains the earlier build-4010 checkpoint; it was not rerun or relabeled here.

## Actual owner device/data checks

The visible owner emulator **5554** now runs APK 4012. `install -r`, actual Mobile MCP semantics and real Android preference/cache reads verified:

* Four accounts, active account, wishlist and four account/app settings keys preserved across the upgrade.
* The store shows four wishlist controls matching four real cached daily offers; no login-error prompt.
* Mobile MCP navigated Home, Store, Community, Collection and Profile, then returned to Store. Active account unchanged, no reauthentication prompt or retry control in these observations.
* A bounded **124-second** window recorded 35 HTTP 200 and 13 HTTP 404 events; 20 account cache files were readable, with zero corrupted JSON or Subject/account mismatches and zero current-process Flutter/fatal/ANR lines.
* A later safe endpoint classification identified the 404s as the game-session endpoint while the PC game was offline. POST was the read-only storefront request; PUTs were player-name lookups. These method names do not imply loadout/party/community mutations.

No real public post/comment/like, purchase, equipment change or Riot party mutation was performed in this checkpoint. Community-writing regressions use the existing fake HTTP boundary; deterministic model translation results in tests do not claim native ML Kit translation quality. Live PC equipment propagation and authenticated production writing remain open acceptance items.

Logs, artifacts, raw account/cache evidence and negative runs stay ignored in `dist/review/community-4012/`. No passwords, tokens, cookies, raw account IDs or private screenshots are committed. The final keyword scan covered **1,070 non-ignored text files**, including the new test/report, and the requested terms plus ValHub. Exact uppercase marker hits were confined to historical audit reports; case-insensitive substring hits also include protocol names and fixtures. Counts are triage, not proof of security certification. Legacy compatibility identifiers, protocol names, test fixtures and historical documentation are retained.

## 🟢 VERIFIED COMPLETE

The fixes and bounded checks above: account-scoped composer/comment State; delayed operation safety; authoritative like rollback/count handling; translation revision/cache handling; 45-reference migration; local suites/builds/public flows and preserved owner account data.

## 🟡 PARTIAL

Whole-app business-flow/device/accessibility/performance acceptance, country provenance/refresh acceptance, full Riot login/session/PC/loadout/LFG behavior, native iOS interaction, Community production writing/privacy/moderation review, background/notifications, and production operations remain partial. Earlier reports retain evidence and limitations; green regression suites do not upgrade them to complete.

## 🔴 RELEASE BLOCKER

Global i18n cutover remains false: **262 production references / 52 structural definitions / 762 Vietnamese literal hits** and the genuine 17 additional UI translations, documented fallback/status/glossary/pseudo/stale-string and full RTL/font acceptance are unfinished. Only Vietnamese currently ships. An EN-device test passing with VI fallback is not an English release.

## ⚠️ EXTERNAL BLOCKER

Production domain/HTTPS associations/web fallback, real production server/restore/alerts, owner release signing and Google Play/Apple store configuration, physical/native acceptance, native-language/legal review and GitHub hosted CI billing lock remain external requirements. The Mac unsigned build resolves the former lack of a Mac build, not signing or iPhone acceptance. No billing/payment action was taken.

## ❌ REGRESSION

No remaining regression was observed by the final checks listed here. This is bounded verification, not a claim that every endpoint, device and production workflow has been accepted.
