# VanHub: background locale, language picker and local CI — 02/10/2026

This checkpoint follows [runtime locale](I18N_RUNTIME_2026-10-02.md) at
`bd69c5d`. It preserves the existing localization, authentication, account,
notification and storage architecture. **Global acceptance is still incomplete.**
The owner permits the existing free on-device ML Kit translator; no paid AI/API
or new AI feature was introduced.

## Gap map and implementation

| Gap established from the preceding implementation | Before | Verified change / remaining limit |
|---|---|---|
| Headless tasks initialized legacy locale rather than consuming the persisted handoff | 🟡 PARTIAL | `BackgroundLocale` defensively reads the existing versioned snapshot, filters UI languages through `kShippedLocales`, validates formatting tags, retains independent content language and does not write preferences. Background context and session/wishlist tasks use it. |
| Notification channel names and notification bodies read legacy Vietnamese tables | 🟡 PARTIAL | Existing generated resources now render channel metadata, privacy replacements, session/rank/Battle Pass/LFG/store/wishlist messages. Native Android rename uses the same channel IDs and retains importance/sound/vibration. Genuine translations remain missing. |
| No UI language selection on Welcome / Settings | 🔴 MISSING | The shared settings choice sheet now offers follow-device and genuinely shipped locales. Only Vietnamese ships. Choice writes are ordered, survive disposal and roll back on persistence failure. |
| Reset reminders kept text from the previous resource instance | 🟡 PARTIAL | Host observes resources, invalidates its scheduling memo and replaces reminders with the same IDs; stale frame callbacks are guarded. |
| Wishlist notification text composed nullable prices, discounts and lists outside resources | 🟡 PARTIAL | Manual ICU select/plural messages and explicit `AppFormats` cover daily/Night Market/bundle/summary branches. Unknown values retain the existing unavailable/unknown behavior. |
| Complete global cutover, translations and other W5–W7 work | 🟡 PARTIAL | Still unfinished; the cutover gate remains red. |

No account/session/storage keys, channel IDs, notification IDs, payload routes,
60-scheduled-notification cap, package ID or custom link scheme were renamed.
Channel updates do not delete channels or request notification permission.
Content names remain separate from UI language and from country/shard/currency.
The legacy VI/EN item-name setting is preserved; this is not the complete
18-language content preference migration.

Nine Vietnamese resource entries were added to the existing ARB. The new
wishlist notification messages have parity tests for the old VI behavior.
Synthetic test resource overrides prove handoff/replacement; they are **not**
English or other real translations, and are not shipped.

## Executed verification

| Check | Actual result |
|---|---|
| Windows `flutter analyze` | **0 issues** |
| Windows full `flutter test --reporter expanded` | **4,232 passed** |
| Windows full `flutter test --dart-define=TEST_LOCALE=en --reporter expanded` | **4,232 passed**, fallback VI; not proof of an English UI |
| Real SSH Mac `flutter pub get` / `flutter analyze` | Pass / **0 issues** |
| Real SSH Mac full `flutter test --reporter expanded` | **4,232 passed** |
| Real SSH Mac unsigned iOS release build | **Pass**, build **4007**, arm64 Runner.app **82.7 MB** |
| Android real plugin integration, isolated emulator 5582 | **6 passed**: two country/persistence/keyboard cases, Keystore isolation, channel rename, 60-slot scheduling/replacement, About |
| Android release build | **Pass**, build **4007**, universal **119.4 MB**, min SDK 24 / target SDK 36 |
| Release APK public-flow smoke, isolated emulator 5582 | **10 passed**, including native Riot WebView, deferred links, cancel/resume, cold start and landscape 200% text |
| Owner emulator 5580, APK 4007 install and initial read-only checks | Pass; two existing accounts retain their metadata, account sheet and Community checked; visible window confirmed |
| Backend `npm run typecheck`, `npm test`, `npm run build`, `npm audit --omit=dev` | Pass; **867 tests / 34 files**, **0 vulnerabilities** |
| `flutter gen-l10n`, ARB canonical format/check | Pass; **0 errors / 0 warnings** |
| Codemod `extract --check`, `parity --check` | Pass; **1,612 members / 1,754 mechanically extracted messages**, byte-stable |
| `dart format --output=none --set-exit-if-changed lib test tool` | **715 files, 0 changed** |
| Codemod `verify --ci` | **Exit 1**: **514 production references / 762 Vietnamese literal hits**, cutover false |
| Second keyword audit | 1,048 tracked text files / all 20 requested terms; triage rather than security certification |

The extraction inventory still contains **52 structural members**. It includes
retained legacy definitions; that number alone does not establish whether every
member still has a production caller. The resolved cutover reference count fell
from 560 to 514. It was not forced green or excluded from the report.

New tests cover corrupt/missing/future snapshots, invalid/cross-language format
tags, content/UI separation, queue/failure/disposal behavior, resource handoff,
channel-update recovery, reminder replacement and language picker at
320/360/393/600 dp with 200% text. Initial full-suite failures exposed two
Welcome test harnesses lacking `ProviderScope` after the new consumer button;
the harnesses were fixed while preserving their overflow assertions. Final
full suites above passed. No failing test was removed, skipped or weakened.

Mac inputs were hash-verified for all 32 changed/new source and test files in
the dedicated QA directory. The host is x86_64 macOS 26.6 / Xcode 26.5 with
Flutter 3.47.5 / Dart 3.13.4; this is not a hosted arm64 matrix or physical
iPhone run. The earlier Docker restore/tool/hook checks remain historical;
they were not rerun or represented as fresh in this checkpoint.

Android review artifact, git-ignored:
`dist/review/VanHub-background-locale-20261002-4007.apk`.
SHA-256: `F75E6552F2A3A76C91463737A9CDCE5C5B81BBC65654ACC2FF31AE9C0E63DA89`.
Signer: Android Debug, verified with `apksigner`; not Play signing acceptance.

iOS review artifact, git-ignored: `dist/review/VanHub-1.0.0-4007-unsigned.ipa`.
SHA-256: `B71B82585214367218BF3D66E4B4A88F0978014613AC1C135CF6AF11F8A3C6DA`.
Bundle ID `vn.valvn.app`, display name VanHub, build 4007, minimum iOS 15.5;
bundled privacy manifest passes `plutil -lint`. The IPA is unsigned.

Logs, private account captures and credentials are not committed. Reproduction
logs use `.vanhub-background-*` and `dist/review/`. Test binaries above are for
review and cannot establish store release readiness.

## Live login / owner testing

After the initial read-only checks, the owner explicitly authorized account
mutations and supplied a login for a fresh-login test. One form submission on
Riot's official WebView returned **“Oops! Something went wrong”** before the
VanHub callback. This observation does not establish an incorrect password,
Riot outage or an app regression. The owner subsequently completed manual login.
Post-login inspection through Mobile MCP, persisted preferences/cache and
redacted request-status logs confirmed the fresh account's metadata, wallet,
loadout, contracts and recent matches. Riot requests returned HTTP 200 in the
observed window; this is not certification of every endpoint.

Wishlist add → restart → remove and a three-account switching round trip passed;
the initial wishlist and active account were restored, with other accounts'
wishlist data unchanged. A temporary owned player card was saved and confirmed
by fresh Riot GET/PUT/GET responses, Version 523→524, and restart persistence.
Restoration of the original card was interrupted when the emulator was restarted
and that test account disappeared from the saved account list. Restoration and
live VALORANT PC propagation remain unverified. No different current account was
mutated to compensate; no purchase or public post was made.

## Remaining acceptance gates

W2–W4 domain/enum/error/content fallback and render-time migration; W5 complete
contentLocale preference/migration, Riot `ui_locales`/status, screen-reader
announcement and content pruning; W6 genuine translations, English fallback,
plural/select/glossary/status gates; W7 fonts/pseudo/stale-string and whole-screen
RTL/accessibility are unfinished. Only VI ships.

The preceding [final gap audit](FINAL_GAP_AUDIT_2026-10-02.md) still governs the
other open gates: country onboarding/provenance, whole endpoint authorization
acceptance, moderation language/CPU acceptance, cross-isolate history writes,
whole-product performance/devices, live Riot/PC equipment propagation, Community/
LFG multi-device behavior, iPhone/native QA, HTTPS domain/web fallback, store
signing/disclosures and actual production restore/RPO/RTO/alert destinations.
Existing SQLite remains; no PostgreSQL/Redis or second localization system was
introduced. GitHub billing prevents hosted jobs from starting; local execution
does not unlock that account.

## 🟢 VERIFIED COMPLETE

The specific runtime/background/picker/notification behaviors, suites, native
Android cases and builds listed above. This is scoped evidence, not acceptance
of every feature or every language.

## 🟡 PARTIAL

Global localization, full owner-account workflows, country/security/moderation/
performance/accessibility acceptance and production operations remain partial.
Native iOS behavior still requires device tests despite the successful build.

## 🔴 RELEASE BLOCKER

Global cutover remains red and genuine translations are missing. Remaining
production/native/security and store privacy acceptance gates are not closed.

## ⚠️ EXTERNAL BLOCKER

GitHub billing unlock; production domain/server/HTTPS/web configuration; release
signing and Apple/Play accounts; physical iPhone and live Riot/PC acceptance;
native-speaker/legal review and production restore/alerts. The observed initial
Riot login-page failure has an undetermined cause; subsequent manual login and
the scoped live checks above succeeded. Mac access was used for this checkpoint.

## ❌ REGRESSION

No unresolved failure in the final executed test/build/public-smoke scope.
The real-login failure has an undetermined cause and is not classified as a
proven regression. Untested behavior is not certified by this statement.
