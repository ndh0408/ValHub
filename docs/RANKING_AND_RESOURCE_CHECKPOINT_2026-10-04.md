# ValHub — checkpoint 4019, 04/10/2026

This checkpoint preserves completed work; it is not acceptance of the whole
product or the subsequently requested global ranking / ownership / login gate.

Rank, account metadata and legacy format helpers now use the existing resource
system. Unknown competitive tiers remain unknown rather than becoming unranked.
Existing identifiers, calculations, sessions and stored account data are retained.
Ranking filters were consolidated and a searchable real-content catalog added;
the owner's subsequent request to remove geography/time filters is still open.

Verified against 852 matching source hashes on Windows and Mac:

- Windows analyzer: 0 issues; default and TEST_LOCALE=en: 4,354 tests each.
- Mac analyzer: 0 issues; full suite: 4,354 tests. An interrupted earlier run
  was rejected; the accepted retry includes the full completion marker.
- Backend: 900 tests, typecheck/build and dependency audit pass; codemod: 37 tests.
- Localization generation/check/extraction/parity pass. Global cutover verification
  still fails: 1 production reference, 762 literals and 52 structural members.
  English test mode exercises the documented Vietnamese fallback, not translated UI.
- Android debug-signed release APK 4019: 10 public-flow cases pass. Upgrade and
  Mobile MCP/real Riot cache checks preserve all six accounts, active account,
  wishlist and settings. All six account-switch/store checks pass; original active
  account restored. An obsolete four-account assertion in the proof harness was
  corrected against the actual six-account baseline, without changing app code.
- Unsigned iOS build on Mac succeeds; copied IPA hash, bundle metadata and privacy
  manifest verified. No signed build or physical iPhone acceptance is claimed.

APK SHA-256: F781C2DCCF649B65BFD71E170B7AF36246E931ACDC3832500BECC20114EBF33F.
IPA SHA-256: D3CA826FFB338656A7BF7DE0A2820AEEAAC51E4FA53FFFDC4BF3BFF72F54CE59.
Private/raw device proofs and CI logs remain outside git under dist/review/rank-4019.

Open work includes the latest explicit login consent, global/all-time rankings,
server-verified skin ownership, country-to-community wiring and match flow audit.
17 additional genuine UI translations, production infrastructure, signed store
release, domain links, moderation acceptance and physical-device checks remain
incomplete. No newly confirmed app regression is claimed at this checkpoint.
