# ValHub locale-aware time, prices and statistics — build 4015

This extends [view checkpoint 4014](I18N_VIEW_CUTOVER_2026-10-03.md). Whole-product acceptance is still incomplete.

## Gap map before implementation

| Area | Initial status | Actual gap |
|---|---|---|
| Time/expiry captions | 🟡 PARTIAL | UI consumers called legacy relative/day/wall/countdown formatters; const countdown defaults retained VI text. |
| Price captions | 🟡 PARTIAL | VP and local-price estimate views bypassed the existing AppFormats provider/scope. Price tables/conversion already worked. |
| Statistics/semantics | 🟡 PARTIAL | Result summaries, timezone/weekday badges, performance enums and several screen-reader descriptions retained legacy strings. |
| Global cutover | 🟡 PARTIAL | 129 production refs / 762 literal hits / 52 structural definitions; only VI UI ships. |
| Release acceptance | ⚠️ BLOCKED | Signing, physical iPhone/PC gameplay, domain associations and production operations remain unverified. |

## Implemented

The existing AppFormats now supplies calendar headers, rounded wall/absolute times, status-event times, updated-at captions, full countdowns, estimated VP/local prices and device timezone/weekday badges. It receives an explicit language/format tag/clock setting and resources. UI callers in Store, Collection, Wishlist, Battle Pass, Home, Community, Profile, Settings and chat use current formats; no global current-language accessor or replacement formatting system was added. Legacy compatibility helpers remain pending their final cutover.

Date grouping uses local calendar days, not elapsed 24-hour periods, and preserves expiry rounding. CLDR supplies non-VI dates/clocks/weekdays; VI remains byte-identical in tested cases. Device offsets preserve fractional/negative values. Price adapters use the actual configured ISO/VP table and existing estimate rounding; currency is not inferred from country or hardcoded to VND. No price, availability or match metric was fabricated.

Countdown defaults resolve during build, preserve explicit formatter overrides and retain their expiry state. AppFormats scope equality includes explicitly supplied resources, so retained consumers refresh when those resources change. Existing item-list commas and inline-fact dot separators remain distinct. Profile result summaries retain absent draw/unknown branches; ICU plural/select messages cover summaries, kill descriptions and performance enums. Parsers, metric calculations and stored query IDs are unchanged.

Eight new tests cover year/midnight/rounding boundaries, duration thresholds and non-finite prices, optional/unknown statistics and semantics, fractional zones/weekday badges, explicit fallback resources/12–24h clocks, configured currency estimates, retained countdown reload/expiry and explicit overrides. Existing assertions were retained. The first run caught a dot/comma separator regression introduced during migration; implementation was fixed. An incorrect ordinary-space expectation was corrected to CLDR's actual narrow no-break space. Negative runs remain local.

## Verification

| Check | Actual result |
|---|---|
| Focused suite / analyzer | 311 passed / 0 issues |
| Windows default / TEST_LOCALE=en / analyzer | 4,307 / 4,307 passed / 0 issues; en uses VI fallback |
| Mac default / analyzer | 4,307 passed (5m53s) / 0 issues |
| gen-l10n / l10n_check / extract / parity | pass; l10n_check 0 errors/warnings |
| Codemod tests / analyzer | 37 passed / 0 issues |
| verify --ci | **exit 1**, 94 refs / 762 literal hits / 52 structural definitions; readyForCutover=false |
| Backend tests / typecheck / build / production dependency audit | 867 in 34 files / pass / pass / 0 vulnerabilities |
| Final Android release build / public QA | pass (Gradle 75.8s) / 10 passed on emulator 5582 |
| Mac unsigned iOS release build / privacy lint | pass (Xcode 61.8s, Runner.app 82.8 MB) / pass |

All **840 frozen source hashes** matched Windows and Mac after final CI/build. Copied IPA hash, metadata, privacy manifest and lack of signing were independently verified on Windows. The keyword audit distinguishes compatibility identifiers, fixtures and historical markers; it is not a security certification.

Artifacts are retained beside older versions:

* APK `dist/review/ValHub-1.0.0-4015.apk`: SHA-256 `C1F5723646B3413EC03A1872269477922A707C28A6E043DED0C83F2CBEF57161`, 125,338,647 bytes; ValHub / `vn.valvn.app`, min 24 / target 36, **AndroidDebug signed**. All three packaged AOT architecture binaries differ from 4014.
* IPA `dist/review/ValHub-1.0.0-4015-unsigned.ipa`: SHA-256 `FC665DA47C5217F7EBB0B7AC9FE9366BC97CBECC4454B45A0CA732562A29960B`, 28,002,106 bytes; ValHub / `vn.valvn.app`, min 15.5, **unsigned**.

Owner emulator 5554 is visibly open on Store, version 4015. Mobile MCP/native hierarchy, preferences and real cache prove four-account upgrade preservation, four-account Store switches and restoration of the original active account. Each account shows its own four daily offers. The original account's four displayed VP prices also match the actual Riot Offer Cost values. Five tabs and return to Store were checked without a login/retry prompt. A **144-second** log window recorded HTTP 200=71 / 404=23 and four successful reauth events; 20 cache JSONs had no corrupt entry or Subject/account mismatch, and no current-process Flutter/fatal/ANR error line was found. Missing party/session resources are not used to invent game state. These bounded checks do not certify every live business workflow.

Initial Android build ran concurrently with Flutter tests, then retained a generated dev-plugin registrant and failed compilation. A no-pub retry also failed; the final standard build regenerated the correct release registrant and passed. No plugin/test was removed or SDK modified. Mac SSH was reset during the first test attempt; that partial run was not counted. The detached rerun completed tests/build with recorded exit 0. Emulators had disappeared from ADB and were restarted using existing data; the release emulator needed its previous root inspection mode restored before cache checks. All final preservation assertions pass. Initial price-inspection assumptions about the response schema/currency ID were corrected against actual schema before comparing values. No failed attempt is counted as success.

Private hierarchy/account/cache/log evidence stays ignored under `dist/review/format-4015/`. No credentials, PUUIDs or private proofs were committed; no public post/comment/like, purchase, equipment or party mutation was made in this checkpoint. Existing free ML Kit remains; no paid AI/API was added.

## 🟢 VERIFIED COMPLETE

The formatting/view migrations, preserved VI behavior, tested statistics/semantics and retained countdown behavior above are verified. Android public flows and bounded four-account real-data checks passed; Mac build/unit/widget verification passed.

## 🟡 PARTIAL

W2–W7 and whole-product acceptance remain unfinished. Legacy compatibility helpers/models, remaining view strings, content-cache pruning, translations/status/fallback and all-screen accessibility/performance acceptance still need work. No claim is made for full fresh-login, Community live writes/moderation or PC equipment behavior.

## 🔴 RELEASE BLOCKER

Global cutover remains false; 17 genuine additional UI translations are absent. No unshipped language was enabled or populated with copied Vietnamese.

## ⚠️ EXTERNAL BLOCKER

Signing/store accounts, physical iPhone/PC gameplay, domain/App/Universal Links, production monitoring/restore and linguistic/legal acceptance remain external. GitHub billing prevents hosted jobs starting; local CI does not unlock the account.

## ❌ REGRESSION

The migration separator regression was fixed before final tests/build. No remaining regression was observed in the exercised scope; this is not all-device/all-endpoint acceptance.
