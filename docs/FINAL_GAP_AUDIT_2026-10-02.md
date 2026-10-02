# VanHub — final gap audit, implementation and verification

Baseline: `8094ec3`, default branch `claude/jolly-hawking-23o2j8`.
This is a live gap map, **not product acceptance**. Existing checkpoint evidence is
identified separately from checks rerun in this audit. An inventory of all 1,150
tracked files is not a claim that every line or endpoint has received security review.
No production writes, account mutations, store submission or new AI integration.
Owner clarification during this audit: retain the existing free on-device ML Kit
translator; the restriction concerns paid AI/services. No paid translation API,
chatbot or AI recommendation is introduced.

## Initial gap map (before implementation)

| Area | Classification | Evidence and actual remaining gap |
|---|---|---|
| Existing Flutter behavior | 🟡 PARTIAL | Last checkpoint 4,195 tests/analyze clean; broad device/live coverage remains incomplete. |
| Backend regression suite | ✅ VERIFIED COMPLETE | Rerun `npm test`: 867/34 files pass on this checkout, 02/10. This verifies the suite, not production security. |
| I18N W1 tooling | ✅ VERIFIED COMPLETE | Extractor, manifest, generated vi resources and parity exist; checkpoint byte-stable. |
| I18N W2–W4 | 🟡 PARTIAL | Baseline documented 1,762 production references/52 structural members. Existing codemod can migrate context-bound UI; models/errors/async captures need explicit work. |
| I18N W5 | 🟡 PARTIAL | AppLocale/boot/providers/upgrade pin exist; app still fixes `locale: appLocale`, controller switch effects incomplete, auth uses fixed ui_locales. |
| I18N W6 | 🔴 MISSING | Only vi is shipped; 17 genuine translations, English fallback/status/glossary pipeline incomplete. A proposed paid model translation runner is not implemented or authorized. |
| I18N W7 | 🟡 PARTIAL | Formats and some RTL/adaptive tests exist; pseudo/stale-string/full-screen script/device gates unfinished. |
| Country infrastructure | 🟡 PARTIAL | 249 ISO+XK, CLDR names/search/shared picker/manual validation and 7-day refresh have tests; onboarding/provenance/status/remote refresh remain open. Country never proves shard/language/currency. |
| Riot region/shard | 🟡 PARTIAL | Fail-closed routing/manual-region safeguards exist; live account/platform/mismatch behavior needs device evidence. |
| Auth/multi-account | 🟡 PARTIAL | Existing session/secure storage/single-flight/isolation/10-account tests; real login/rotation/logout/cross-device not verified. Preserve identifiers and storage. |
| Data integrity/store/collection/match | 🟡 PARTIAL | Deterministic domain calculations and response fixtures tested; no live all-shard/PC loadout acceptance. Unavailable data must stay unavailable. |
| Cache/storage | 🟡 PARTIAL | Late-write/account cleanup/startup sweep protections already implemented; retain regression tests, extend corrupt/migration/native scenarios when gaps reproduced. |
| Community CRUD/reactions/share | 🟡 PARTIAL | Implemented; native Android share checkpoint verified. Server-writing E2E, unread/activity/web/iOS remain unverified. |
| Community privacy | 🟡 PARTIAL | Local per-account hide/block implemented and disclosed; not server peer blocking or private content authorization. |
| LFG | 🟡 PARTIAL | Existing authoritative join-code lookup, TTL/owner guards, unique join intent. `lfg_joins` counts intent, not a seat reservation; no claim of atomic final-slot allocation/leave membership until protocol is audited. |
| Moderation | 🟡 PARTIAL | Existing deterministic bounded filter and language wordlists; most lists explicitly `reviewed: false`, synchronous CPU execution, native language review/load evidence missing. Do not rebuild filter. |
| Paid AI/services | ✅ VERIFIED COMPLETE | No paid AI added. Existing free ML Kit explicitly retained by owner clarification; translation remains a user action. The obsolete design proposal for a Claude translation runner is not implemented or authorized. |
| Notifications/background | 🟡 PARTIAL | Rank/pass/category/60-slot/native scheduler protections implemented; isolate language/Community source/kill/Doze/reboot/iOS remain open. No continuous polling. |
| Deep links/sharing/web | 🟡 PARTIAL | Preserve valvn:// cold/warm/defer behavior; custom-scheme share needs installed app. |
| HTTPS associations/domain/web fallback | ⚠️ BLOCKED | Actual domain/DNS/TLS, Android certificate association and Apple team association need owner infrastructure; templates alone cannot verify. |
| Accessibility/devices | 🟡 PARTIAL | Existing rail/hinge/200%/contrast/picker tests; full 320/360/393/600+ matrix, screen readers/list-detail/fonts unfinished. |
| Performance | 🟡 PARTIAL | Local synthetic benchmark exists; real device profiles/query measurements remain needed. No speculative index/DB rewrite. |
| Backend endpoint security | 🟡 PARTIAL | Existing auth context/epoch/rate-limit/ownership tests; per-endpoint ten-question audit and adversarial verification still required. |
| Database | 🟡 PARTIAL | Actual engine is SQLite with transactions/migrations/quota triggers; PostgreSQL is a documented future option, not deployed code. |
| Redis | ✅ VERIFIED COMPLETE | Not required by current single-replica architecture; no Redis dependency introduced. Distributed deployment remains out of current verified scope. |
| Media | 🟡 PARTIAL | Native decoder/limits/metadata/quota/orphan cleanup tested; CDN/edge/real upload and operational verification incomplete. |
| Privacy/legal | 🟡 PARTIAL | Actual export/delete/revoke/consent implementations exist; technical support is not certification under GDPR/UK GDPR/CCPA/LGPD/Vietnam law. Legal review remains external. |
| Observability | 🟡 PARTIAL | Route-pattern logs, health/load/disk/WAL watchdog implemented; request correlation, production monitoring/alerts not accepted. |
| Backup/restore | 🟡 PARTIAL | Historical isolated SQLite/media restore smoke; no current production restore/RPO/RTO evidence. PostgreSQL backup is not applicable to present engine. |
| CI trigger | 🔴 MISSING | Android/iOS/l10n push filters target only main, while actual default is claude/jolly-hawking-23o2j8. Default pushes do not trigger those checks. This is a verified defect; no claim of a newly introduced regression. |
| CI test/release gates | 🟡 PARTIAL | Workflows exist; English metric is not proof of English UI, l10n cutover intentionally not green; unsigned/debug builds must not become signed releases. |
| Android release | ⚠️ BLOCKED | Review APK works; owner release keystore/Play configuration/store verification absent. Preserve app ID/version upgrade. |
| iOS release/native privacy | ⚠️ BLOCKED | No actual macOS/Xcode build/test or signing/Apple acceptance evidence. |
| Brand | 🟡 PARTIAL | VanHub product name integrated; ValVN compatibility identifiers intentionally retained. Classify remaining hits; do not global replace. |
| Hook runtime | 🟡 PARTIAL | Bridge tests/manual hooks pass; actual Orca full restart still unverified. |
| Documentation | 🟡 PARTIAL | Completion status truthful; historical snapshots/design plans must not be presented as current acceptance. |
| GitHub-hosted CI execution | ⚠️ BLOCKED | Read actual check annotations for runs 36880223379 and 36628078318: jobs never started because the GitHub account is locked due to a billing issue. Local checks do not resolve this. No billing/payment action taken. |

## Implementation order

1. Extend the existing l10n codemod cutover, starting with mechanically safe UI
   references; resolve structural/async/test-harness failures without weakening tests.
2. Fix the verified default-branch CI trigger gap.
3. Continue render-time domain/error/runtime locale work and genuine translations;
   no AI translation runner or duplicated Vietnamese locales.
4. Finish remaining technical audits/device checks; external evidence remains explicit.

Results, remaining counts and exact rerun commands are appended only after execution.

## Implemented and rerun in this audit

1. Used the existing resolved codemod, then fixed imports and root-provider
   access. Removed **1,202** direct production string references: **1,762 → 560**.
   No second localization system or duplicated locale files. The verifier still
   fails correctly: **560 references / 762 Vietnamese literals / 52 structural
   members** remain. Most literal hits are legal documents, not newly added UI.
   Only Vietnamese is currently shipped; an English-device test is fallback
   regression evidence, not an English translation acceptance test.
2. Android/iOS/l10n workflows now also trigger on the actual default branch.
   Build numbers derive from the pubspec base plus run number, preventing a
   low Actions run number from downgrading an installed 400x review build.
   Executed the actual version shell blocks for branch/tag paths: four cases
   passed at base 4005, expected output 4047 for run 42. An unsigned iOS artifact
   cannot become a tag release; successful signing is required.
3. A real first Mac test run found three failures (4,192 passed, three failed).
   Fixed POSIX same-isolate store-history writers with a shared canonical-path
   queue, retaining the OS lock. Added concurrent-writer and separate-root
   regressions. Settings widget tests now fake the native WorkManager boundary
   like their other plugins and assert cancellation of the last account's work.
   Existing account/consent deletion assertions were retained. No account data
   cleanup was bypassed. **41 focused tests passed on Windows and Mac.**
   POSIX same-process, different-isolate behavior still needs native verification.
4. Added the missing Runner required-reason API privacy manifest and resource
   membership: app-container file metadata (`C617.1`) and own preferences
   (`CA92.1`). Uses correspond to cache/history/log pruning and app settings.
   Reasons checked against [Apple's API reason documentation](https://developer.apple.com/documentation/bundleresources/app-privacy-configuration/nsprivacyaccessedapitypes/nsprivacyaccessedapitype).
   This intentionally does not assert zero Community data collection or a
   completed App Store privacy label. Mac `plutil -lint` passed for Info.plist,
   the new manifest and the Xcode project. CocoaPods xcconfig includes retained.

| Check run on this implementation | Result |
|---|---|
| Windows `flutter test --reporter expanded` | **4,197 passed** |
| Windows `flutter test --dart-define=TEST_LOCALE=en --reporter expanded` | **4,197 passed**, Vietnamese fallback |
| Windows `flutter analyze` | **0 issues** |
| `flutter gen-l10n` / `dart run tool/l10n_check.dart --ci` | Pass / **0 errors, 0 warnings** |
| Generated resource diff / Dart format check | No generated ARB/Dart diff; **709 files, 0 changed** |
| Existing codemod `dart test` / `dart analyze` | **35 passed / 0 issues** |
| `dart run tool/l10n_codemod/bin/l10n.dart verify --ci` | **Exit 1**, 560 refs / 762 literals, cutover **false** |
| Backend `npm test` / `npm run typecheck` / `npm run build` | **867 passed, 34 files / pass / pass** |
| Backend `npm audit --omit=dev` | **0 vulnerabilities** in the audit output |
| Actual Linux Docker image build | Pass, `valvn-community:finalgap-20261002` |
| Existing `test/ops-smoke.sh` in isolated native container | Pass: Sharp, watchdog, backup, encryption, restore, erasure replay, retention and failure cases |
| Hook compatibility regression tests | **14 passed**; real Orca restart remains unverified |
| Android release APK 1.0.0+4005 | Built, **119.3 MB**, min 24 / target 36, debug review signer verified |
| Latest APK public-flow smoke on QA emulator 5582 | **10 passed** |
| Latest APK installed on visible owner emulator 5580 | Read-only Settings/account sheet/Community checks passed; two current accounts, no account mutations |
| Mac `flutter pub get` / `flutter analyze` | Pass / **0 issues** |
| Mac full `flutter test --reporter expanded` after fixes | **4,197 passed**, no skipped failing tests |
| Mac `flutter build ios --release --no-codesign` | **Pass**, arm64 Runner.app **82.7 MB**, version 4005 / minimum iOS 15.5 |
| iOS review packaging and bundle inspection | Unsigned IPA packaged; identifier `vn.valvn.app`, brand VanHub, bundled privacy manifest passes `plutil -lint` |

Android review artifact: `dist/review/VanHub-final-gap-20261002-4005.apk`.
SHA-256: `0A03A0D8F2E7210998EC960B4F767A0068A1C6ED00FADF98B7080ADD85D06D12`.
Signer: Android Debug; this is not a Play release signing verification.

iOS review artifact: `dist/review/VanHub-1.0.0-4005-unsigned.ipa`.
SHA-256: `34DBC03BE2BBBF5E17F6A6374FE797EB7A12BF710132663B667D61A34F992515`.
The IPA is unsigned; packaging is not device installation, signing or App Store acceptance.

Mac verification used SSH to a dedicated QA directory, macOS 26.6 x86_64,
Xcode 26.5, Flutter 3.47.5 / Dart 3.13.4. Existing owner projects were untouched.
The initial 1,151-file transfer was hash-verified. The later native manifest was
included in the Xcode project before building. Current input comparison matches
all other files, with four expected native configuration changes from CocoaPods
integration (Debug/Release xcconfig, project, workspace). No different Dart
feature implementation was substituted. Store signing, physical iPhone/native
acceptance and the hosted macos-26 arm64/Xcode 26.6 matrix remain separate gates.

Logs and private device captures remain git-ignored under `.vanhub-final-gap-*`
and `dist/review/`; backend logs are under `server/community/`, tool logs under
`tool/l10n_codemod/`. Private account screenshots/XML are not published or committed.

## Remaining acceptance gates

**This is not a finished global product.** W2–W7 still require structural/domain/
async string migration, locale cutover and switch effects, genuine translations,
fallback/status/glossary/pseudo/stale-string tools and whole-screen RTL/font QA.
Country onboarding/provenance, server moderation native-language review/CPU load,
endpoint-by-endpoint security acceptance, device accessibility/performance,
cross-isolate history concurrency, real Riot/auth/loadout/LFG behavior, iOS native
acceptance and operational production restore/alerts remain partial.

No PostgreSQL or Redis was introduced: the implementation uses SQLite, and the
restore smoke verifies the isolated SQLite/media system, not a production
PostgreSQL deployment, off-site retention or agreed production RPO/RTO.
Production domain/HTTPS associations/web fallback, signing/accounts, deployment,
native-speaker/legal review and GitHub billing remain external requirements.
The keyword search is triage, not security certification. Standalone TODO/FIXME/
HACK search in production lib/server/native source found none; protocol names,
test fixtures, compatibility ValVN identifiers, official currency examples and
legal strings are retained rather than blindly removed.

## Final classification for this checkpoint

### 🟢 VERIFIED COMPLETE

The executed checks above: Windows vi/device-en and Mac suites, analyzers, ARB
generation/checks, existing backend/typecheck/build/dependency audit, native Docker
restore smoke, Android review build/public flows/read-only install, Mac unsigned
iOS build/packaging and required-reason manifest presence. Workflow version blocks
and default-branch trigger configuration are verified locally. These are verified
checks, not acceptance of every feature or hosted Actions execution.

### 🟡 PARTIAL

Country/onboarding, auth/live Riot/device behavior, Community/LFG/moderation,
privacy disclosures, accessibility/performance, background/native notifications,
cross-isolate writes, whole endpoint security review and production operations.
iOS native/physical-device tests are pending despite the successful Mac compile.
Existing free ML Kit remains; it uses CocoaPods and emits an SPM compatibility
warning for a future Flutter version, not a failure of this build.

### 🔴 RELEASE BLOCKER

Global i18n cutover is still red (560 references, 52 structural members, 762
literal hits), only vi ships, W2–W7 and genuine translation/font/device gates
remain. Community language moderation review and full production/native acceptance
are unfinished. Store privacy collection labels must be audited before submission.

### ⚠️ EXTERNAL BLOCKER

GitHub billing unlock; release credentials/Apple/Play accounts; physical iPhone
and live Riot/PC acceptance; production domain/HTTPS association/web deployment;
production restore/RPO/RTO/alerts; native-speaker/legal acceptance. Mac access is
now available and was used; do not continue marking all macOS verification blocked.

### ❌ REGRESSION

No unresolved failures in the rerun suites/public smoke scope. Initial Mac
store-write and Settings harness failures were fixed and rerun. This does not
prove absence of regressions outside the exercised scope or resolve the remaining
POSIX cross-isolate gate.

## Publication verification

Implementation checkpoint [`1fd5825`](https://github.com/ndh0408/ValVN/commit/1fd5825c4d92ea8baa1f84a7f7b3e57425994f54)
was pushed to both `ndh0408/codex-complete` and the default branch
`claude/jolly-hawking-23o2j8`; `git ls-remote` confirmed matching heads.
Default-branch push actually created [i18n run 36971013057](https://github.com/ndh0408/ValVN/actions/runs/36971013057),
[Android run 36971013080](https://github.com/ndh0408/ValVN/actions/runs/36971013080)
and [iOS run 36971013008](https://github.com/ndh0408/ValVN/actions/runs/36971013008).
All six jobs had zero executed steps. Their failure annotations say the account
is locked due to a billing issue; iOS also has an informational arm64 capacity
notice. Do not label these as a compile/test failure or claim hosted CI passed.
The main workspace retains the owner's four untracked design images; private
captures, logs and APK/IPA binaries were not committed.
