# ValHub — production deployment and real-account verification, 05/10/2026

This checkpoint deploys the existing Community backend and verifies the new skin
discussion/owner-review flows against real Riot data. It does **not** accept the
whole product or claim a signed Android/iOS store release.

## Gaps found before and during deployment

| Gap | Result |
|---|---|
| Production skin-comment GET returned 404 | Resolved: migration 0013 and current routes deployed; real phone read/create/delete verified |
| Production backup container unhealthy | Resolved: current backup loop, verification/drill stamps and healthcheck deployed using the existing backup directory |
| Owned-skin review save returned 503 | Resolved after two real-data checks: missing Riot game headers caused inventory HTTP 400; then the parser rejected Riot's distinct permanent-entitlement TypeID |
| Whole-product localization cutover | Still blocked: verification exits 1; only Vietnamese UI ships |

The real failure was investigated without logging tokens, subjects, URLs or Riot
response bodies. Diagnostics contain fixed operation names and HTTP statuses.
Review identity still comes from authenticated server context plus fresh Riot
userinfo; no client account ID, PUUID or ownership flag authorizes a write.

The inventory adapter now sends validated client version/platform/User-Agent
headers. Public `/v1/version` metadata uses the same source, formats and six-hour
refresh policy as the app, deduplicates concurrent fetches, bounds bodies/time and
uses a short failure cooldown. Missing metadata fails closed. No Riot credentials
go to the content host. Inventory supports both documented response shapes;
`ItemTypeID` identifies skin levels and row `TypeID` identifies entitlement kind.
Wrong buckets, ambiguous shapes and malformed rows cannot grant ownership.

## Deployment evidence

- Existing stack: `/home/huy/stacks/valvn-community`, public API
  `https://val.gianguyen.cloud`; existing edge network/tunnel retained.
- Final runtime source commit: `afa7162`; all three services use the immutable
  image `valvn-community:afa7162`.
- Image ID: `sha256:92646dec43bda49a764f97ae08d606e6bb87ca0e2ddb7f409803622bb2a7c44a`.
- The tested local image was transferred, SHA-256 checked and loaded on the
  production host. Staging used a real-data backup clone with separate random
  staging credentials and no published port. Health/comment read/unauthenticated
  write guards passed before rollout. Temporary staging containers were removed.
- API, backup and watchdog are **healthy**. Watchdog reports `ok`, with no fault
  codes. API runs as `node`, read-only, `no-new-privileges`, 512 MiB memory limit;
  port 8787 remains bound only to host loopback. Public HTTPS health returns 200.
- Existing `.env` content hash and permissions are preserved; PEPPER/session
  secrets and the live data volume were not replaced. No credentials are committed.
- Database now has 13 migrations. Original five user identities, original review
  content/rating/skin and original vote were compared with the pre-deploy snapshot
  and preserved. Final counts: five users, zero posts, one review, one vote,
  zero skin comments, zero media; integrity `ok`, zero foreign-key errors.
- Pre-deploy consistent snapshot and post-deploy backup were actually extracted
  and drilled using real production data. Restored counts match live counts.
  The old runtime also opened the migrated pre-deploy clone. This does not prove
  a destructive live rollback, full-host recovery or measured RPO/RTO.
- Task-owned raw snapshots/restore clones were removed after verification.
  The retained pre-deploy archive lives in the existing 14-day retention-managed,
  mode-0700 backup directory; archives are mode 0600. Protected rollback source,
  configuration and old image remain on the host.

Private logs and artifacts: ignored `dist/review/deploy-2026-10-05/`. Initial
failed diagnostic attempts are retained alongside successful final evidence.

## Real owner emulator evidence

Mobile MCP semantics/actions, API process logs, actual database reads and Android
preferences/cache were used together. No synthetic account or server token was
created to stand in for the owner.

| Actual exercise | Result |
|---|---|
| Nonowned collectible skin | Owner-only star restriction visible; separate plain-comment composer remains usable |
| Plain comment | Known test text entered, created on production, visible immediately, deleted through the own-comment menu and confirmation; database count 1 → 0 |
| Owned collectible skin | Selected by resolving real cached skin-level entitlements against the real catalog; no previous review on that skin was overwritten |
| Owner review | Fresh Riot identity/inventory checks passed; PUT 200, stored verification timestamp and visible review |
| Global summary | One verified test rating, average 4, scope global; these are temporary test inputs, not a quality claim |
| Review cleanup | UI confirmation → DELETE 204; that skin's rating/review counts return to zero; original unrelated review/vote retained |
| Account preservation | Six accounts, active account, wishlist and four settings unchanged; all six saved countries remain known |
| Native logs | No fatal/unhandled exception detected in inspected app-process logs |
| Final screen | Owner emulator left open on Community with empty search and full lazy collectible catalog |

The earlier 503 responses are preserved as failure evidence; final successful
verification does not erase their history. This is not evidence for fresh-login
prefetch, live PC loadout refresh, actual LFG party membership or all account flows.

## Local CI after implementation

| Check | Result |
|---|---|
| Flutter analyze | Zero issues |
| Flutter full suite / TEST_LOCALE=en | 4,386 tests passed each; English mode verifies existing fallback, not translated English UI |
| Backend | 949 tests in 37 files; typecheck/build pass; production npm audit: zero vulnerabilities |
| Docker | Build and isolated native decoder/watchdog/backup/encryption/restore/erasure/retention/failure smoke pass |
| Trivy 0.56.1 | Fresh DB, exit 0: zero HIGH/CRITICAL vulnerabilities with fixes, zero detected secrets; existing ignore-unfixed policy unchanged |
| flutter gen-l10n / l10n_check --ci | Pass; l10n_check has zero errors/warnings |
| l10n codemod verify --ci | **Exit 1**: one production reference, 768 Vietnamese literals; 52 structural members remain documented open |

App/native source is unchanged from build 4021. Its prior Android native/public
smokes and Mac Community/unsigned iOS build remain historical evidence, not new
device or signed-release results from this backend deployment.

## Rollback and operational limits

The host retains `valvn-community:rollback-pre-7df03bd` and the protected original
stack archive under `.deploy-20261005-7df03bd`. The prepared rollback script restores
that source/config/image and starts the old services while retaining the additive
database. It was syntax checked; **a live rollback was not executed**. Do not erase
the live volume or regenerate secrets. For data recovery use the existing reviewed
[server restore runbook](../server/community/README.md).

Backup/restore verification covers this existing SQLite database, with zero actual
media files. It is not PostgreSQL/object-storage recovery evidence. Off-site backup
upload, independent erasure-ledger retention and alert delivery need actual operator
destinations/credentials; none are invented or sent to unspecified recipients.

## 🟢 VERIFIED COMPLETE

The deployed routes/migrations, real plain-comment lifecycle, real owned-skin review
lifecycle, global rating aggregation/cleanup, original-record preservation, current
healthy services, real-data backup clone/drill and checks above.

## 🟡 PARTIAL

Whole-product UX/accessibility/performance and privacy acceptance; multilingual
moderation review; fresh-login match prefetch; other real Riot/LFG/account workflows;
complete restore/alert operational acceptance. Device-local block is not server-side
peer blocking. Existing free ML Kit is retained; no new or paid AI was introduced.

## 🔴 RELEASE BLOCKER

P0 localization cutover remains incomplete: only VI UI ships, seventeen genuine
translations and structural/legal migration work remain. A deployed backend and
green unit tests do not establish complete product acceptance.

## ⚠️ EXTERNAL BLOCKER

Play/Apple signing and store access, physical-device acceptance, HTTPS App Link /
Universal Link association and public web fallback, off-site backup/erasure-ledger
destination, alert destination and full-host restore/RPO/RTO exercise. Existing APK
is debug-signed and IPA unsigned; neither is a store-ready release artifact.

## ❌ REGRESSION

No unresolved regression was observed in the exercised scope. The deployment
mismatch, backup health failure and real ownership-adapter failures found here
were corrected and verified again. Unexercised flows are not certified working.
