# ValHub LFG serialization and late-session writes — build 4017

This extends [conditional-view checkpoint 4016](I18N_CONDITIONAL_VIEWS_2026-10-03.md). Whole-product acceptance is still incomplete. The [40-endpoint backend audit](BACKEND_ENDPOINT_AUDIT_2026-10-03.md) details server authorization and its limits.

## Gap map before implementation

| Area | Initial status | Evidence |
|---|---|---|
| LFG join serialization | 🔴 MISSING | With the first authorization response held, a second card still opened a join confirmation, permitting competing party changes. New behavior test failed before the fix. |
| LFG join counter | 🟡 PARTIAL | Server counts unique requests, including failed/cancelled Riot joins; UI said people had joined. |
| LFG account/view lifecycle | 🟡 PARTIAL | Disposal guards existed, but active-account checks, explicit completion status and immediate observed party refresh needed verification. |
| Backend delayed authorization | 🔴 MISSING | Isolated logout returned 204, but a pending catalog-validated vote returned 200 and wrote one vote after revocation. |
| Endpoint review | 🟡 PARTIAL | Existing suites did not prove late-session authorization at commit; ten-question inventory was unfinished. |
| Global i18n/release | 🟡 PARTIAL / ⚠️ BLOCKED | 62 refs / 762 literals / 52 structural definitions; translation and external release acceptance remain open. |

## Implemented and verified

LFG holds one join operation across the visible list, starting before confirmation. Other join buttons stay disabled until cancellation, error or completion. It captures the initiating account, stops before the Riot step when that account/view is no longer current, and reports success only for a current completed join. Successful joins invalidate an observed party cache. Seven new Flutter tests cover competing cards/recovery, cancelled confirmation, stale initial account, switching during authorization, disposal, switching during the Riot response and refreshing the cached party. Existing error, expiry, heartbeat, region and accessibility tests were retained.

The count now says users **requested** to join. Both the legacy source and generated resource were updated with the existing extractor; parity remains valid. Riot controls actual party membership/capacity. Community intent counts do not allocate seats, fill a slot or prove someone joined. Simultaneous final-slot/leave acceptance still needs live Riot/PC verification.

Backend commits/replays now re-check session expiry, current user existence/creation time, session epoch and sanctions after asynchronous validation/IO, using the existing shared context. Initial rate buckets remain charged once. Revoked uploads remove both their row and newly allocated blob. Comments re-check visible parent state at commit; vote rate limiting precedes catalog work. The first 25-case negative backend run had 20 failures and five valid controls. Final 33 adversarial/control cases include same-second erase/recreate, pending duplicate upload, no double coarse charge and concurrent parent hiding. No real account/server write was used for those tests.

## Verification

| Check | Actual result |
|---|---|
| Focused Flutter suite | 31 passed |
| Windows default / TEST_LOCALE=en / analyzer | 4,319 / 4,319 passed / 0 issues; en uses VI fallback |
| Mac default / analyzer | 4,319 passed (9m46s) / 0 issues |
| gen-l10n / l10n_check / extract / parity | pass; 0 l10n errors/warnings |
| Codemod tests / analyzer | 37 passed / 0 issues |
| verify --ci | **exit 1**: 62 refs / 762 literals / 52 structural definitions; readyForCutover=false |
| Final backend tests / typecheck / build / dependency audit | **900 in 35 files** / pass / pass / 0 vulnerabilities |
| Android release build / public QA | pass (116.0s) / 10 public cases passed on emulator 5582 |
| Mac unsigned iOS release build / privacy lint | pass / pass |

All **843 frozen Flutter/tool/content input hashes** match Windows and Mac after final CI/build; copied IPA hash, metadata, privacy manifest and absence of signing were checked independently. A separate **131-file backend manifest** matches after final backend CI. The initial Windows pipeline's 867 backend results precede the new fix; final backend evidence is the separate 900-test run. Backend changes do not alter the frozen Flutter inputs or packaged apps. Backend changes are committed here, **not deployed to a production server**.

* APK `dist/review/ValHub-1.0.0-4017.apk`: SHA-256 `7674609DE9D6A8D68C8CDE3689D92F040299075315779721DAED9FD4513839F9`, 125,355,031 bytes; ValHub / `vn.valvn.app`, **Android Debug signed**.
* IPA `dist/review/ValHub-1.0.0-4017-unsigned.ipa`: SHA-256 `04EB23A3AB382BFF5A8A0802CAC7DF0C7460349D264A367BA0DDBE61F1ADCEF8`, 28,010,847 bytes; ValHub / `vn.valvn.app`, min 15.5, **unsigned**.

Owner emulator 5554 is visibly open on Store, version 4017. Actual Mobile MCP hierarchy, preferences and cache verify four-account upgrade preservation, four separate real offer lists, restored original active account, wishlist and four settings keys. Four displayed VP prices match Riot Offer Cost. Five tabs and return to Store were exercised without login/retry prompts. A 409-second log window recorded HTTP 200=79 / 404=34 and three successful reauth events. Twenty cache JSONs had no corrupt entry or Subject/account mismatch; no current-process Flutter/fatal/ANR error line was found. These checks do not exercise real full-party joining or every account/business flow.

A new cancel-confirmation test initially used a nonexistent navigation back button. It was corrected to tap the actual Cancel action, retaining the cancellation/retry assertions. The real overlapping-join and backend authorization failures were fixed in implementation. All negative attempts remain local. No test was deleted, skipped or weakened.

Private device/account/cache/log evidence and isolated proofs remain ignored under `dist/review/lfg-4017/`. No credentials, private account identifiers or private files were committed. No public post, purchase, equipment or party mutation was made on the owner account in this checkpoint. Existing free ML Kit is retained; no paid AI/API was added.

## 🟢 VERIFIED COMPLETE

The exercised LFG serialization/lifecycle/cache fix, truthful intent counter and backend late-session commit protection are verified by the final tests above. Bounded Android real-data checks and Mac unit/widget/build verification passed.

## 🟡 PARTIAL

W2–W7, remaining model/provider/compatibility strings, content pruning, translations/status/fallback, all-screen accessibility/performance and complete live business acceptance remain unfinished. Community private/friends ACLs and server peer blocking are not implemented; local hide/block remains device-local. Native moderation review and production operations are not certified.

## 🔴 RELEASE BLOCKER

Global cutover remains false; 17 genuine additional UI translations are absent. Final-slot Riot behavior and whole-product production acceptance are not established. The newly reproduced late-session write defect is fixed in code/tests; production deployment of that fix has not been performed.

## ⚠️ EXTERNAL BLOCKER

Signing/store accounts, physical iPhone/PC gameplay, domain associations, production deployment/monitoring/restore and linguistic/legal review remain external. GitHub billing still prevents hosted checks starting. Local CI does not unlock GitHub.

## ❌ REGRESSION

No remaining regression was observed in the exercised final scope. The failed cancellation test was a harness error; the competing-join and late-write defects were corrected. This is not all-device/all-endpoint production acceptance.
