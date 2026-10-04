# ValHub — catalog and discussion checkpoint 4021

This checkpoint implements the owner's complete collectible catalog and plain
comments request on top of build 4020. It does not accept the whole product.

## Actual gaps and changes

The initial gaps are recorded in [the flow map](COMMUNITY_FLOW_GAPS_2026-10-04.md).
The inline catalog had a 30-item manual limit and was pushed below a large empty
ranking state. Review bodies also required ownership and stars, leaving nonowners
without a plain discussion route.

- The main catalog now has every collectible item in the existing content
  database, rendered lazily. Search covers the full catalog, including items never
  laid out. Standard/random-favorite exclusions retain the existing catalog policy.
  Aggregate reads request at most 30 IDs per visible page. Missing ratings remain
  unknown; no votes/reviews are invented. Empty/loading ranking notices are compact.
- Global/all-time rankings and existing weapon/sort controls are preserved.
- Separate skin comments are public to read and authenticated to write; skin
  ownership is not required. Stars/review text still use build 4020's identity-bound
  Riot inventory verification. Plain comments never change rating aggregates.
- Migration 0013, pagination, shared post/skin comment limits, CPU moderation,
  sanctions, reports, operator actions, export, erasure and alias maintenance use
  existing infrastructure. Drafts and pending actions remain account/skin scoped.
  Failed deliveries retain their draft/idempotency key; account switching cannot
  submit that draft as another author. Existing post comment rendering is reused.
- Community content language now follows the existing app locale provider; it
  remains separate from account country and Riot connection region.

## Verified evidence

Private logs/artifacts are retained under ignored `dist/review/catalog-4021/`.

| Check | Actual result |
|---|---|
| Windows Flutter analyzer | Zero issues |
| Full default / TEST_LOCALE=en suites | 4,386 tests each; English mode tests the existing fallback, not genuine English UI |
| Mac analyzer / Community suite | Zero issues / 361 tests; build 4020's full Mac suite had 4,369 tests, not a claim of 4,386 Mac tests here |
| Backend | 931 tests in 37 files; typecheck/build pass; production npm audit reports no vulnerabilities |
| Localization | Generation/check/extraction/parity and 37 codemod tests pass; cutover still fails |
| Android native / release public flow | Six / ten passing cases, including native storage/channels/60 notification slots and cold/warm links/200% landscape |
| Mac iOS | Unsigned release build; copied IPA, version, identifier, privacy manifest and absence of signing verified |
| Source comparison | 1,093 matching Windows/Mac inputs; post-runtime delta is exactly Dockerfile, server CI YAML and server README. Flutter/native inputs are unchanged. Docker checks were rerun after the image change |
| Real owner emulator | ADB install-r and Mobile MCP preserve six accounts, active selection, wishlist and four settings. All six countries remain known; current consent remains granted without autoapproval |
| Actual catalog / UI / logs | Real cache has 1,373 collectible skins. MCP observes catalog/search, matching Vandal items and a nonowned skin's rating restriction plus separate comment composer. No fatal/unhandled error detected in inspected process logs |

The actual phone logs show 200 for existing top/votes/reviews/summary routes, but
**404 for the new skin comment GET**. Production deployment is unverified; this
is not a successful real comment roundtrip. Direct probes from Windows had 403,
which must not be described as a global outage. SSH to the configured server
candidates timed out. No production server changes were made.

The final container builds and passes isolated native image decoding/watchdog,
encrypted backup/restore/erasure replay/retention/failure smoke. An additional
new-table restore check preserves the retained author's skin comment, removes
the erased author's comment and leaves the source database untouched. These are
local fixtures, not a production restore or measured production RPO/RTO.

The first image scan found 11 HIGH issues: runtime PCRE and packages shipped
inside npm. Runtime PCRE is now refreshed to `10.42-1+deb12u2`; npm/corepack are
removed from the runtime, with build-stage package installation retained.
All three shell files now receive their own syntax check. Trivy 0.56.1 (the
existing action's default), fresh DB, exits zero with zero HIGH/CRITICAL issues
having fixes and zero detected secrets. Existing `ignore-unfixed` policy remains;
no ignores, lowered thresholds or disabled scanners were added. Initial failed
scan evidence is retained. This is not a claim of zero possible vulnerabilities.

APK: `dist/review/ValHub-1.0.0-4021.apk`, 125,699,011 bytes, debug-signed.
SHA-256: `3A289A5DC226081B93D5D846EBFFAE26E4A6574631D3818ADA4E87C1976C5095`.

IPA: `dist/review/ValHub-1.0.0-4021-unsigned.ipa`, 28,045,919 bytes, unsigned.
SHA-256: `AF1FF0948EEF288685D38CA03CFE139296DA8819E31CD593317F34D1BD7349DA`.

Backend deployment source: `dist/review/ValHub-community-4021-source.tar.gz`,
137 source files, including migration 0013, without private environment files.
SHA-256: `6998D6833C4E1DB439BC6BBFCC46A2FF3589DA84BD6D234C6B08959403597E7E`.
Use the existing reviewed backup/update procedures in the server README; do not
replace PEPPER or session/storage compatibility identifiers during deployment.

## 🟢 VERIFIED COMPLETE

The exercised local catalog/comment implementation, ownership separation,
account draft isolation, backend protections, Flutter/backend tests, Android
smokes, unsigned iOS build and corrected container checks above.

## 🟡 PARTIAL

Live writing/owner verification, full-device accessibility/performance acceptance,
native linguistic moderation review, real fresh-login match warmup, production
restore/observability and whole-product acceptance remain incomplete.

## 🔴 RELEASE BLOCKER

Localization cutover still exits 1: one production reference, 768 Vietnamese
literals and 52 structural members; only Vietnamese UI ships. Seventeen genuine
translations are missing. Production must also receive migrations 0012/0013 and
current ownership/comment routes before these new server behaviors can be claimed.

## ⚠️ EXTERNAL BLOCKER

Reachable production server/credentials, domain associations, signed Play/Apple
release and physical-device acceptance. APK debug signing and an unsigned IPA
do not establish store release readiness.

## ❌ REGRESSION

No unresolved app regression observed in the exercised scope. The new comment
route's production 404 is a deployment mismatch, not verified working behavior.
The initially failing image scan was corrected and rerun without weakening CI.
