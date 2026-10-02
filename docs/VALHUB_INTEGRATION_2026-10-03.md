# ValHub — Gemini review and combined-code verification, 2026-10-03

This checkpoint combines the owner's Gemini changes with the previously
verified Codex background-locale phase. **ValHub** is the owner's confirmed
product name. ValVN package/storage/deep-link identifiers remain compatible.
The earlier VanHub-named builds and reports are historical evidence.

## Scope and gap map

See [Gemini review](audit/GEMINI_REVIEW_2026-10-02.md) for the 87-file incoming
change inventory, reproduced failures and repairs. The incoming snapshot
disabled native integration checks and failed 38 Flutter cases. Its all-PASS /
98-of-100 production acceptance report was unsupported and has been replaced.

Repairs restore the SDK integration-test dependency and analyzer coverage,
complete ValHub branding through existing resources/native labels/legal export,
select popular weapons by stable UUID rather than translated names, preserve
48dp targets under large text and localize the new score separator. Useful
Gemini layout, semantics, RTL and Riot ui_locales/callback changes are retained.

The [background-locale phase](I18N_BACKGROUND_2026-10-02.md) supplies headless
locale handoff, generated notifications, stable-channel metadata refresh,
reminder replacement and a shipped-language picker. Only Vietnamese ships;
the 17 genuine translations and global cutover are still incomplete. Existing
free on-device ML Kit is retained; no paid AI integration is added.

Merge conflict: build number 4008 versus 4007. The combined version is
**1.0.0+4009**. Source merges preserved both phases; existing extraction/parity/
gen-l10n regenerated successfully, 1,612 members / 1,754 messages / 52 structural
members. No test assertion was removed or weakened.

## Verification

Pre-merge repaired Gemini snapshot: analyzer 0 issues, Windows full suites
4,205 passed each, five Android native tests and 867 backend tests passed.
The background phase's prior Windows/Mac 4,232 tests and build 4007 evidence
remain scoped to that phase. They are not combined-code results.

| Combined-code check | Actual result |
|---|---|
| Windows full suite / `TEST_LOCALE=en` | **4,236 passed each**, English define uses VI fallback |
| Windows analyzer | **0 issues** |
| Real SSH Mac analyzer / full suite | **0 issues / 4,236 passed** |
| Android native smoke, isolated 5582 | **6 passed** |
| Android release / public-flow smoke | **4009 built / 10 passed** |
| Real SSH Mac unsigned iOS release | **4009 built**, Runner.app 82.7 MB; privacy manifest lint passes |
| Owner emulator upgrade | Four account identities, active account, wishlist and settings preserved; actual APK 4009 confirmed |
| ARB validation / canonical format | **0 errors / 0 warnings** / pass |
| Final Dart format check | **718 files, 0 changed**; line-ending normalization leaves no tracked source diff |
| Extraction / parity byte stability | Pass; 1,612 members / 1,754 messages / 52 structural members |
| Codemod `verify --ci` | **Exit 1**, 514 references / 762 literal hits, cutover false |
| Backend | Source unchanged by merge; fresh repaired-snapshot typecheck/build and 867 tests pass; dependency audit 0 vulnerabilities |
| Second keyword inventory | 1,060 tracked text files / 21 terms including ValHub; triage, not security certification |

The first combined run exposed a new background test still expecting VanHub.
Its expectation was corrected to the owner's ValHub name; both Windows full
suites above then passed. Native country search also exposed a harness that
waited for an unbuilt lazy-sliver result while the real IME was open. It now
verifies the IME/query, scrolls the country list and retains selection,
persistence and reset assertions. The initial scroll selector included the
text field's internal scroller; the selector was corrected to the country
list, following the existing country widget tests. Final six cases pass.

Mac QA was initially offline; the existing VM was started and SSH became
reachable. An initial Mac suite was interrupted by
a reboot (SSH reset, new uptime, runner gone) after 3,431 passes and the old-name
assertion failure; that is not a completed suite. The final rerun passed all
4,236 tests, analyzer and unsigned iOS build. All 121 changed source/test/legal
inputs were hash-verified; final native-test selector changes were also copied
and `dart analyze integration_test` passed on Mac. Native iPhone tests were not
performed. The first Android release build after native tests used a stale
generated registrant containing the integration plugin; explicit `flutter pub
get` regenerated it and the normal release build passed. The SDK test dependency
was retained; generated native files were not manually patched.
Owner emulator ValVN_Pixel was reopened visibly; QA uses the isolated 5582 AVD.

Artifacts, git-ignored and for review:

- `dist/review/ValHub-1.0.0-4009.apk`: SHA-256
  `D212842BC56810C4226B36E0CB4065E32AC61AE10F9006364FC70BA403BC6084`,
  119.4 MB, Android Debug signer, min SDK 24 / target SDK 36, package vn.valvn.app.
- `dist/review/ValHub-1.0.0-4009-unsigned.ipa`: SHA-256
  `42B9BD8F0641E48A67DAFC49431AFA32BB9DEC95E60C5A8F9095DA10CD1F3FBE`,
  27,980,935 bytes, min iOS 15.5, bundle vn.valvn.app, display name ValHub.
  `codesign` confirms the app is not signed.

Both default and integration branches were pushed at `0347613` after merging.
GitHub billing did not prevent this push; hosted CI remains a separate gate.

Keyword triage retained ValVN package/storage/routes and repository redirects;
historical VanHub checkpoint names remain dated evidence. VND hits are currency
examples and old comments, not a global price rule. HTTP hits include XML/XMPP
namespace identifiers. Placeholder/mock hits include loading UI, theme previews,
and test fixtures. Token/cookie/PUUID identifiers are not by themselves evidence
of a secret leak. This inventory does not certify endpoint authorization or
legal compliance, and no broad search result was blindly removed.

## Live account evidence and limitations

Earlier owner-assisted login on build 4007 succeeded. Mobile MCP, persisted
preferences/cache and redacted Riot request statuses confirmed real metadata,
wallet, loadout, contracts and recent matches. Wishlist add/restart/remove and
three-account switching passed and restored initial state. This is scoped
runtime evidence, not certification of every workflow.

On build 4009, real MCP semantics showed four daily wishlist actions matching
four daily offers in the active account's actual cache. Post-upgrade inspection
recorded 31 HTTP 200 and 18 HTTP 404 responses in its four-minute window; the
404s were the session/v1/sessions endpoint's existing offline behavior. Cache
subject mismatches, corrupt cache files and native errors were zero in that
observed scope. This is not proof that every account/session/endpoint is healthy.

A temporary owned player card was confirmed by fresh Riot GET/PUT/GET, Version
523→524, and restart persistence. Original-card restoration was interrupted
when the owner emulator/session changed and that test account was no longer
saved. Restoration and immediate VALORANT PC propagation remain unverified.
No different account was mutated, no purchase/public post made, and no account
credentials, screenshots or private payloads are committed.

## 🟢 VERIFIED COMPLETE

The scoped repairs, combined Windows/Mac suites, Android native/public cases,
builds, resource tooling and upgrade-preservation checks above.

## 🟡 PARTIAL

Global i18n/content-locale effects, country/security/moderation acceptance,
whole-product devices/accessibility/performance, owner workflows, native iOS
and production operations. Passing unit tests do not certify these areas.

## 🔴 RELEASE BLOCKER

Unfinished global cutover/genuine translations and remaining security/native/
production/store privacy acceptance. The application is not production-ready.

## ⚠️ EXTERNAL BLOCKER

Production domain/associations/web fallback/server/restore/alerts; signing and
Apple/Play accounts; physical iPhone and live PC acceptance; native-speaker/
legal review; GitHub billing unlock. Mac access is available and used locally.

## ❌ REGRESSION

Incoming 38 Flutter failures and disabled native smoke are fixed and verified.
The final Windows/Mac suites, analyzer, Android native/public cases and release
builds have no unresolved failure in their executed scope. Untested behavior
is not asserted complete.
