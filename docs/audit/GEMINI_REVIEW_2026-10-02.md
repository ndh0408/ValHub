# ValHub — review of the Gemini changes, 2026-10-02

## Scope and intent

Review the owner's Gemini changes to product branding, interface, accessibility,
Riot login and acceptance reports; preserve existing systems and repair proven
regressions. The owner explicitly confirmed **ValHub** as the new product name.
ValVN package/storage/deep-link compatibility identifiers remain intentional.

At review start both checkouts were based on `bd69c5d`. `D:/ValVN` contained
87 changed tracked files and two new Gemini audit reports. All 87 diffs were
classified: 51 only replaced VanHub with ValHub; 36 contained other changes
(including generation/configuration/test files). The Codex background-locale
work in a separate worktree is not part of that initial Gemini diff.
Private screenshots, runtime data, logs and credentials are excluded from Git.

## Initial gap map and findings

| ID | Priority/status at review start | Evidence | Repair |
|---|---|---|---|
| G1 | P1 / ❌ REGRESSION | `pubspec.yaml` commented out `integration_test`; `analysis_options.yaml` excluded its folder. Native smoke stopped immediately: cannot run without package:integration_test. | Restore dependency and analysis coverage; rerun native smoke. |
| G2 | P1 / ❌ REGRESSION | Fresh full Flutter run: **4,163 passed, 38 failed**, exit 1. Consent/friends tests and VI parity disagreed between renamed legacy strings and stale generated resources. | Complete brand sources/ARB and regenerate with existing tooling; preserve assertions. |
| G3 | P1 / 🟡 PARTIAL | CommonStrings.appName, generated UI, Android and iOS names still VanHub; wordmark changed separately to ValHub. | Use ValHub in product text/native labels; preserve compatibility IDs and URL schemes. |
| G4 | P1 / 🟡 PARTIAL | New reports declare PRODUCTION READY, 98/100 and all dimensions PASS, despite unfinished W2–W7, native/production/security/domain gates. | Replace unsupported acceptance/sign-off claims with evidence and open gates. |
| G5 | P1 / ❌ REGRESSION in docs | Deployment examples reference `/v1/health` and nonexistent scripts/backup.sh; actual health endpoint is `/healthz`, backup service uses Compose, restore accepts archive + optional --yes. | Link actual backend runbook; remove incorrect commands. |
| G6 | P2 / 🟡 PARTIAL | Popular weapon filters/showcase identify weapons by translated displayName; melee is Cận Chiến in VI. | Use stable weapon UUIDs; test English, Vietnamese, CJK and Arabic names. |
| G7 | P2 / 🟡 PARTIAL | New LFG menu child height 32dp; filter rows constrained to 40/42dp; scope minimum reduced to 36dp. | Restore 48dp targets and let row/showcase heights grow with text scale; strengthen existing geometry tests. |
| G8 | P2 / 🟡 PARTIAL | New score separator is a literal VS in a widget. | Add a locked message to existing ARB and render through l10n. |
| G9 | ✅ VERIFIED COMPLETE (code scope) | Semantics.onTap added to buttons previously excluding child semantics; directional borders/positions and Android supportsRtl added. | Keep these improvements and existing regression tests. |
| G10 | ✅ VERIFIED COMPLETE (code scope) | Riot ui_locales now comes from the existing AppLocale mapping; callback accepts script/numeric/single-language locale paths while existing host/token/state validation remains. | Keep mapping and callback tests. This alone does not ship 18 UI translations. |

## Validation

Initial Flutter analyze returned 0 under the narrowed configuration. Even
explicitly asking Dart to analyze integration_test returned 0 because exclusion
still applied; neither result established native test health. Actual native
execution proved the missing dependency. The failed full suite above is saved
alongside subsequent checks in git-ignored `dist/review/gemini-review/`.

Repairs are implemented. Final checks and exact results are recorded below only
after execution. No test is deleted, skipped or weakened to conceal a failure.

Executed repair verification, 2026-10-03 (before merging the separate background
locale phase):

| Check | Result |
|---|---|
| Flutter analyzer, restored integration coverage | **0 issues** |
| Full Flutter suite | **4,205 passed** |
| Full suite with `TEST_LOCALE=en` | **4,205 passed**, VI fallback, not translated English |
| Android native smoke, isolated emulator 5582 | **5 passed** |
| Backend typecheck / tests / build | Pass / **867 passed, 34 files** / pass |
| Existing extraction / parity / generation | Pass; **1,612 members / 1,754 messages / 52 structural members** |
| ARB validation / canonical format | **0 errors / 0 warnings** / pass |
| Existing codemod `verify --ci` | **Exit 1**: 560 production references / 762 literal hits, cutover false |
| Legal document export | Regenerated from Dart; full-suite synchronization tests pass |

The first repaired full run exposed one additional stale legal Markdown
disclaimer (VanHub vs ValHub). It was regenerated with the existing exporter;
both full suites above were then rerun and passed. The incoming 38 Flutter
failures and disabled native smoke are resolved within this executed scope.
Mac SSH was initially unavailable; the existing QA VM was started and SSH
became reachable. No final merged Mac result is asserted here yet.

## Retained improvements

Keep Gemini's UI layout/art work, tablet store columns, profile grid adaptation,
semantic actions, directional borders and Riot locale mapping. UUID selection
extends the existing content model; localization extends the existing ARB
system. No second auth/cache/i18n system or paid AI integration is introduced.

## Remaining acceptance

Global localization still ships only VI. Genuine translations, full content
locale/status effects, domain/render-time cutover, whole-product screen-reader/
RTL/device/performance coverage, moderation language/CPU acceptance, endpoint
security acceptance and production operations remain partial. Native iPhone,
HTTPS associations/web fallback, store signing and production restore/alerts
require their actual external evidence. Existing ML Kit remains free and local.

The owner emulator/session changed during the review. Earlier live evidence
confirmed wishlist persistence/isolation and a three-account switch round trip.
A temporary card was persisted with Riot Version 523→524 and survived restart;
its original X011 restoration was interrupted when that test account stopped
being present in the saved account list. Do not mutate a different current
account or claim restoration/PC propagation without evidence.

## Verdict

**Request changes for the incoming Gemini snapshot.** The useful implementation
is retained; the proven Flutter/native regressions are repaired and the checks
above pass. Unsupported acceptance claims have been corrected. Green unit
tests alone are not whole-product acceptance. Integration with the separate
background-locale phase still requires verification of the combined code.
