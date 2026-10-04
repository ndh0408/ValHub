# ValHub — checkpoint 4020, 04/10/2026

This checkpoint covers explicit account consent, authenticated country repair,
global/all-time rankings, inventory-verified reviews and bounded match warmup.
It does not accept the whole product or the subsequently requested full catalog
presentation and separate comments by people who do not own a skin.

Implemented using existing systems:

- A versioned consent gate protects saved/new/switched accounts. Approval is
  explicit; declining removes the shown account and retains local history.
  Legal pages and account management remain reachable. Pending grants cannot
  overwrite revocation. Normal Community browsing has no anonymous join banner.
- Missing older account countries are repaired from authenticated Riot userinfo,
  with subject/session guards and a 15-minute retry window. Country, UI language
  and connection region remain independent; manual settings are preserved.
- Product rankings request global/all-time data. Real skin discovery remains
  available without invented votes. Full catalog presentation is the next gap.
- Star reviews require a fresh Riot token resolving to the authenticated server
  author, then inventory verification on fixed Riot hosts. Client PUUID/owned
  flags are not proof. Migration 0012 preserves legacy reviews and labels them;
  only verified reviews contribute to rating totals and star rankings.
- Account warmup fetches one history page, up to 20 details, two concurrently;
  account switching stops subsequent requests. Existing ledger/late-write guards
  and deterministic analytics are retained. These are stored samples, not lifetime
  Tracker scores. A real fresh-login twenty-detail run is still unverified.

Verified evidence (private logs/artifacts kept outside git in dist/review/flow-4020):

- Windows analyzer: zero issues; default and TEST_LOCALE=en: 4,369 tests each.
- Mac analyzer: zero issues; full suite: 4,369 tests. Unsigned iOS release build
  succeeds; copied bundle/version/privacy manifest/IPA hash verified.
- Backend: 917 tests; typecheck, build and production dependency audit pass.
  Codemod: 37 tests; localization generation/check/extraction/parity pass.
- Cutover verification still fails: one production reference, 768 literals and
  52 structural members. English test mode checks Vietnamese fallback, not an
  English translation. Additional genuine UI translations remain a release gap.
- Android native suite: six tests pass. Release public-flow: ten cases pass,
  including cold/warm links and landscape at 200% text. The interrupted seven-case
  attempt and obsolete privacy-version expectation are not accepted results.
- Actual ADB upgrade and Mobile MCP preserve six accounts, active selection,
  wishlist and four settings. Countries known locally increase from two to six;
  active Riot country is visible in Profile. The new consent gate was observed.
  Current real cache has 62 compact match-stat rows; inspected Subject fields
  match the active account. This does not prove a fresh-login prefetch run.
- 1,085 source hashes match Windows/Mac after verification. The only source delta
  after runtime CI is the QA helper's strict privacy expectation from 1.1 to 1.2;
  its affected ten-case suite was rerun. CocoaPods-generated workspace/project
  edits were restored to the frozen inputs for source comparison after build.

APK SHA-256: 0A5EFF654BEDFBE15604E037535878ED32E187BDF84EBB750416FE80DE8BA873.
IPA SHA-256: A6C2149825DCAB62DAA9D5D118CD5A1CE318B4DF0636ADB99D32BBD9149E7042.
APK is debug-signed; IPA is unsigned. Neither is a store-signed release.

Remaining: full catalog as primary content and separate skin comments, real
Community ownership write roundtrip, server deployment/physical-device acceptance,
translation cutover, moderation acceptance, domain links and signed store release.
No newly confirmed app regression. Production readiness is not claimed.
