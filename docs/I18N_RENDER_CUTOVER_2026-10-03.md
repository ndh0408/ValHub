# ValHub render-time cutover — 03/10/2026, build 4010

This follows [the combined Gemini review](VALHUB_INTEGRATION_2026-10-03.md).
It extends the existing localization architecture; it is not acceptance of the
whole product. The product name remains ValHub. Package IDs, persisted keys,
Riot IDs and `valvn://` routes retain compatibility.

## Gap map and implemented changes

The resolved inventory was 514 production references / 762 Vietnamese literal
hits. The current inventory is **339 references / 762 literal hits**, cutover
**false**. This phase converted **175 references**. The extractor still records
52 structural legacy definitions; keeping them for parity is not evidence that
their consumers are migrated. Only Vietnamese ships; 17 translations remain
incomplete. The English test define uses VI fallback.

| Area | Verified implementation | Remaining scope |
|---|---|---|
| Navigation | Destinations rebuilt from the ambient resource instance, preserving five branch IDs/order | Full translated/RTL device acceptance |
| Home | Card title/description and hide/undo/menu copy resolve at rendering; async hide captures resources | Other async Home/settings/content consumers |
| Match | Outcome, round result and team-role labels moved out of enums; player fallback names receive resources | Content/rank fallbacks and other models |
| Errors | Riot error renderer takes explicit resources; CommunityException retains codes/data while rendering moves into UI | Other exception/default/lifecycle captures |
| Social/live | Friend presence text moves into view helpers; relative activity uses existing AppFormats; queue-block/live status receive resources | Content queue/rank names and remaining party actions |
| Collection/LFG | Category/upgrade captions resolve outside content models; LFG role/rank/language labels use resources | Other content/model defaults and translated content policy |
| Async tool | Opt-in `--capture-async` captures once before await for a function's own explicit BuildContext; collision and nested-scope tests | State.context, lifecycle and outer closures remain manual |

No Riot/auth/cache/storage protocol was replaced. Parsers still retain raw
unknown upgrade codes; unknown category stays empty and the view supplies its
existing fallback. No localization is cached in a domain enum or account state.
Moderation reason copy never displays arbitrary server text. All existing test
expectations remain enforced; callers pass the resource instance explicitly.
The final review also added a mounted guard before reading localized login
errors after an authentication await, so a closed login screen is not accessed.
No paid AI/API integration was added; existing free on-device ML Kit is retained.

## Verification

| Check | Actual result |
|---|---|
| Windows full Flutter suite, default / TEST_LOCALE=en | **4,238 passed each**, EN uses VI fallback |
| Windows analyzer, including integration tests | **0 issues**, final pass after canonical regeneration and login guard |
| Mac SSH full suite / analyzer | **4,238 passed / 0 issues** |
| Final canonical resource tests, Windows / Mac | **2,054 passed each**, analyzer remains clean |
| Codemod package analyze / tests | **0 issues / 37 passed** |
| Backend tests / typecheck / build | **867 passed in 34 files / pass / pass** |
| Backend npm audit --omit=dev | **0 reported vulnerabilities** |
| Extract/parity checks / ARB validation | Pass / **0 errors, 0 warnings** |
| Dart format / git diff --check | **722 files, 0 changed / pass** |
| verify --ci | **Exit 1**, 339 references / 762 literal hits; never disabled |
| Android native integration, QA 5582 | **6 passed**, normal integration-test mode |
| Android release APK / public-flow smoke | **4010 built / 10 passed** |
| Mac final unsigned iOS release | **4010 built**, Runner.app 82.8 MB, privacy manifest lint passes |
| Owner visible emulator 5554 | Actual package version 4010; four accounts, active, wishlist/settings preserved |

An initial Android test invocation used unsupported `flutter test --release`;
it did not execute tests. The corrected invocation passed six native cases.
Release coverage comes separately from the normal APK and ten public-flow cases.

Mac verification uses the dedicated QA directory on macOS 26.6 / Xcode 26.5,
Flutter 3.47.5. **833 input files were hash-verified**. A deep JSON equality check proved all message values
and placeholder metadata identical; only ARB/generated method ordering changed.
Final inputs, including the login mounted guard, were hash-verified again and
the full Windows suites and Mac suite passed on those inputs. The first Mac
rerun was interrupted by a VM reboot at 3,613 tests; it is not counted as a pass.
The subsequent Mac rerun completed all 4,238 tests. An accidental QA
transfer `.dart` file was moved outside the Dart source extension before the
clean analyzer pass; no analyzer exclusions or test skips were added.
No owner Mac project or release-signing setup was replaced.

Android artifact: `dist/review/ValHub-1.0.0-4010.apk`, 119.4 MB.
SHA-256: `C4A4CC608B81758758E770E392438C8CBA9CD51C61C0B5FE01AFECB340B7811C`.
Package `vn.valvn.app`, min SDK 24 / target 36, ValHub label.
Signer **Android Debug**: this verifies a review APK, not Play signing.

iOS artifact: `dist/review/ValHub-1.0.0-4010-unsigned.ipa`.
SHA-256: `8C0383287744CB201D97D57CB8387504627A0D9F0F019B2855E22ED2E9D3DA5D`.
Bundle `vn.valvn.app`, minimum iOS 15.5, display ValHub, version 4010.
`codesign` confirms the app is unsigned. No physical iPhone/store result is claimed.

## Live evidence and second audit

The owner emulator stays visible. Upgrade proof compares hashed account IDs,
active ID, wishlist and all four persisted `settings.*` keys without publishing
private account data. These checks were repeated after the final login guard
and APK rebuild, using the actual `settings.app` storage key.
Actual Mobile MCP semantics show all five tabs, daily Store and **four wishlist
buttons**, matching **four real cached Riot offers**. No account purchase,
equipment change or public Community write was performed in this phase.

Actual Mobile MCP switching selected each of the four accounts and restored
the original active account. All four had four cached offers and four rendered
wishlist controls; none became marked as needing login. Two store caches were
refetched during that switch run; the other two were reused. Persisted wishlist
and settings stayed unchanged. An initial test selector used a Riot-ID substring
and tapped the wrong row; the corrected selector compares the full first-line
Riot ID, and the repeated four-account run passed. Five-tab navigation also
preserved the active account and showed no observed reauthentication/retry prompt.

The approximately 7.6-minute observation window had **32 HTTP 200 / 24 HTTP 404**;
all observed 404s were the offline game-session endpoint. Cache inspection found
zero corrupt JSON files / zero Subject-to-account mismatches, and current-process
native logs showed zero observed Flutter/native fatal errors. This does not prove
that every cached account is freshly authenticated or that equipment propagates
to VALORANT PC instantly. Earlier unresolved card-restoration evidence remains
accurately recorded in the previous checkpoint.

A second approximately 11.9-minute window after the final APK install and live
switch/navigation checks recorded **94 HTTP 200 / 51 HTTP 404**. All observed
404s were again the offline game-session endpoint. Account-cache corruption,
Subject-to-account mismatches and current-process native/Flutter error-line
counts remained zero. These are bounded observations, not a release certificate.

The requested second search includes all 20 terms plus ValHub. Classification:
The initial case-insensitive substring inventory also matches `toDouble` as
`TODO`, theme-preview `_mock` widgets and the legal phrase "hack VP". Those are
not unfinished work or fake Riot data. Actual TODO/FIXME/HACK markers still need
contextual review. Other mock/stub matches occur in tests/support/docs;
placeholder includes ICU metadata; debug/print includes
bounded tooling and intentional test failure diagnostics; VND is pricing/source
and test data requiring market-specific acceptance; ValVN includes preserved
compatibility IDs; VanHub includes historical documents; token/cookie/PUUID are
protocol/test terms, not proof of disclosure; localhost/127.0.0.1/http:// include
local fixtures and operational configuration. No matches were blindly replaced.
The search and 867 tests are not a complete penetration test. A source spot-check
confirmed shared authenticated-request rate limiting, server-derived identity,
owner checks, bounded JSON/media requests and idempotency for existing create
routes; the full endpoint/production audit remains separate.

## 🟢 VERIFIED COMPLETE

The render-time changes above, unchanged VI behavior exercised by full suites,
local tooling/CI results, Android review build/public/native coverage, Mac unsigned
build and observed owner upgrade/data preservation are verified within their scope.

## 🟡 PARTIAL

W2–W7, other content/model/error captures, 18-language moderation review, complete
screen-reader/device/performance coverage, actual authenticated Community writes,
iOS native behavior and immediate PC equipment propagation remain incomplete or
insufficiently verified. Existing local block/hide remains per-account/device;
LFG join intents are not an atomic Riot party-seat reservation.

## 🔴 RELEASE BLOCKER

Global cutover is still red: **339 production references, 762 literal hits** and
17 genuine translations/fallback/acceptance remain. Do not ship the language
picker for unverified locales or declare whole-product production readiness.
Production security/privacy/moderation/restore/operational acceptance remains open
as specified in [the original gap map](FINAL_GAP_AUDIT_2026-10-02.md).

## ⚠️ EXTERNAL BLOCKER

Play release signing/account metadata, Apple signing/account and physical iPhone,
production domain/App Links/Universal Links/web fallback, production infrastructure
and restore/alert validation require external setup. GitHub-hosted jobs were
previously rejected for account billing lock; local CI does not unlock billing.
Push authorization does not mean a store publication or production deployment.

## ❌ REGRESSION

No regression was observed in the executed checks. This is scoped evidence, not
proof that every unexecuted feature/device is correct. No failing test was removed,
skipped, weakened or masked to make the results green.
