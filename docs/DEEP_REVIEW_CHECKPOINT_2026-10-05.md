# ValHub — deep review checkpoint, QA build 4023

This continues `b665a74` and the owner-supplied review. It is an evidence record,
not whole-product acceptance. Product name is ValHub; compatibility identifiers
remain ValVN. Existing free on-device ML Kit remains; no paid AI is added.

## Gap map and resulting changes

| Before | Finding and evidence | Result |
|---|---|---|
| 🟡 PARTIAL / correctness defect | Public status HTTP 200 containing HTML, null, missing arrays or arrays of the wrong type became `{}` and a healthy summary | `PvpApi.platformStatus` rejects these shapes with `content_unavailable`; valid empty arrays, JSON text and additive fields remain supported |
| 🟡 PARTIAL / correctness defect | A failed refresh retained the old report; the value-first UI branch hid the error and retry | Cached report/time remain visible with a compact error/retry row; successful retry removes it |
| ✅ VERIFIED COMPLETE, limited scope | Review proposed anonymous retry for public Community reads | Existing implementation already does this; added tests prove revoked cached-token fallback and prohibit anonymous downgrade for private reads/writes; no duplicate auth system |
| 🟡 PARTIAL | Test totals had no repeatable application line-coverage report | Added LCOV summary, parser tests and Android workflow artifact/summary; no invented percentage threshold |
| 🔴 MISSING | Root contribution/security/change/conduct/release guidance | Added documents describing actual authorization, reporting and open release gates; no branch/protection setting is claimed |
| 🟡 PARTIAL | LICENSE and manually maintained end-user license used VanHub | Corrected product names to ValHub; ownership, confidentiality and license restrictions are unchanged |
| ⚠️ BLOCKED | Review proposes approved public capabilities/RSO | Official policy checked; no ValHub approval evidence or RSO credentials established here; existing functionality is preserved pending an actual scope decision |
| 🟡 PARTIAL | OpenAPI, oversized-service extraction, startup/performance and all-device acceptance recommendations | Remain follow-up work; file length or another app's feature list is not sufficient reason to rewrite working systems |

Two new status regression tests failed before the production fix. The first
attempt at the refresh banner also failed while suppressing errors during the
provider's loading/retry state; the final banner uses the retained error and
matching region. Initial-load error/recovery and valid-response controls pass.
Validation here covers the top-level status response shape, not every possible
malformed nested Riot record. Existing notice parsing/fallback remains intact.

## Verification

- Windows analyzer: **0 issues**. Backend: **949 tests / 37 files**, typecheck and
  build pass; production dependency audit reports **0 vulnerabilities**. Backend
  source/runtime is unchanged in this checkpoint; API/backup/watchdog remain
  healthy on `afa7162`. Docker/restore evidence belongs to the deployment record.
- Windows full coverage and English-device fallback runs: **4,396 tests each
  pass**, with `--concurrency=2`. `gen-l10n` and ARB validation pass.
  The original default-concurrency run failed a real-time account-lock test
  with `lock_timeout` and left a profile test file incomplete. Both files then
  passed together (**11 tests**) and the full suite passed with two workers.
  No test, timeout or assertion was removed, skipped or weakened. This does not
  prove every loaded CI machine will avoid timing-sensitive failures.
- Mac: analyzer **0**, **165 Riot/Settings/Community API tests**, unsigned release
  iOS build **4023**, privacy plist lint and identifier/name/version checks pass.
  Six changed source/test/manifest inputs match Windows by SHA-256.
- Workflow YAML structure checks pass using Ruby/Psych on the Mac. Cloud Actions
  execution and branch protection remain unverified. English-device fallback
  tests are now required in the workflow instead of `continue-on-error`.
- `gen-l10n` and `l10n_check --ci` pass; `l10n ... verify --ci` still exits **1**:
  **1 production reference / 768 Vietnamese literals**, with **52 manual
  structural members** in the existing manifest. The gate is retained.
- Android native smoke: **6 tests pass** on the separate QA emulator, including
  Keystore isolation, notification-channel migration and the **60-slot** limit.
- Android release build **4023** and **10 public-flow cases** pass. Package
  `vn.valvn.app`, display name ValHub and debug certificate are verified.
- Owner emulator: install-over-existing-data preserves **six accounts**, original
  active account, wishlist and settings; six stored country values remain.
  Mobile MCP reads the real status report. Disable Wi-Fi/data, refresh: cached
  report/time remain alongside error/retry. Restore the original network settings
  and retry: error disappears and status reloads. Cache/log checks find **0 native
  fatal/unhandled exceptions**. No chat messages or new Community posts are sent.

Local evidence is under `dist/review/deep-audit-2026-10-05/` (not committed).
Artifacts are QA outputs, not signed store releases or verified iPhone installs:

| Local artifact under `dist/review/` | Bytes | SHA-256 |
|---|---:|---|
| `ValHub-1.0.0-4023.apk` — debug-signed, release mode | 125600707 | `3f5641f435ce880da1e53545c71518273ca74dce8a9440bc7eb9d3c205f83ba2` |
| `ValHub-1.0.0-4023-unsigned.ipa` | 28045346 | `1bf2c8b9049fcd6f3190a4608d4109b298eb8d1622fcef228132864737481580` |

## Coverage and its limits

Successful full-suite LCOV reports **36,075 / 40,103 instrumented application
lines (89.96%)**, **423 files**, with **16 source files absent from LCOV**.
Generated l10n, `.g.dart` and `.freezed.dart` files are excluded. The summary
lists missing files and per-file counts; it never marks absent files covered.
`main.dart` is among the absent files, so startup/native acceptance is still a
separate gap. Some other absent files are constant or export-only modules.

The tool rejects missing/empty/malformed coverage input and merges duplicate
records without inflating the denominator. Four parser tests pass. CI retains
LCOV/JSON/Markdown evidence; no arbitrary coverage percentage is enforced.
Executed lines do not establish branch coverage, mutation resistance, privacy,
native behavior or whole-product completeness.

## Second audit interpretation

The requested keyword scan was repeated over tracked UTF-8 source and stored
locally without raw secret/account values. Matches are classified by runtime,
tests, resources, documentation or tooling. They are not vulnerability counts.

- Whole-word TODO/FIXME/HACK search in Flutter/backend runtime found none. Raw
  case-insensitive substring scanning also matches `toDouble`, which is not TODO.
- Runtime `mock` matches are miniature theme previews, not fabricated Riot data.
  `placeholder` includes image/skeleton widgets and ARB metadata.
- Runtime VND matches are formatter examples, currency-picker examples and old
  comments; price formatting uses the existing configured-currency system.
- ValVN names in packages, storage and custom links are compatibility identifiers.
  Historical VanHub document/checkpoint names are not renamed indiscriminately.
- `http://etherx.jabber.org/streams` is an XMPP namespace; backend loopback URLs
  are local deep-health/watchdog traffic with existing host/peer restrictions.
- Inspected background/notification diagnostics print exception types or a fixed
  status, not raw tokens/cookies/PUUIDs. A keyword scan is not a secret or penetration
  audit; existing security controls still require regression/device verification.

No OpenAPI file was found. Current Community API contracts remain Markdown/manual
types plus existing tests; this checkpoint does not claim generated contract
validation. Default branch and license rights are not changed by review advice.

## 🟢 VERIFIED COMPLETE

The bounded status fixes, Community fallback/private guard tests, coverage tool
and local/Mac checks listed above are verified within their stated scope.
Existing production Community flows remain evidenced by the separate
[deployment record](PRODUCTION_DEPLOYMENT_2026-10-05.md), not re-created here.

## 🟡 PARTIAL

Whole-product, startup/performance, all-screen accessibility/device acceptance,
OpenAPI/contract gates, service extraction and full regional/locale behavior.
Current SQLite/local-media/in-memory architecture is retained; no unsupported
horizontal-scaling or PostgreSQL/Redis migration claim is made.

## 🔴 RELEASE BLOCKER

Global i18n cutover/18-language translation and acceptance remain incomplete.
English-device fallback is not an English UI translation. Cloud execution,
release-scope acceptance and signed store artifacts are not established here.

## ⚠️ EXTERNAL BLOCKER

Riot registration/capability decisions and approved RSO access, store signing and
developer accounts, physical Android/iPhone acceptance, HTTPS associations/web
fallback and remaining off-site/alert/full-host restore acceptance. See
[release gates](RELEASE_GATES.md) for evidence required; another app offering a
feature is not evidence of ValHub approval.

## ❌ REGRESSION

The two existing status defects above were reproduced and repaired; this audit
does not establish when they were introduced. No newly introduced product
regression was reproduced by the checks listed here. The timing-sensitive first
full test failure is retained in the evidence rather than concealed.
