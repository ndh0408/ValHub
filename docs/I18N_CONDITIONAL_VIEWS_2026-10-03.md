# ValHub conditional captions and semantics — build 4016

This extends [format checkpoint 4015](I18N_FORMAT_CUTOVER_2026-10-03.md). Whole-product acceptance remains incomplete.

## Gap map before implementation

| Area | Initial status | Actual gap |
|---|---|---|
| Conditional UI captions | 🟡 PARTIAL | 29 feature-UI references, Community previews and two skin-detail references still composed legacy captions. |
| Semantics and optional fields | 🟡 PARTIAL | Wishlist, offers, rank results, slots and nullable live statistics needed explicit resources and branch parity. |
| Global cutover | 🟡 PARTIAL | 94 production references / 762 literal hits / 52 structural definitions; only VI UI ships. |
| Release acceptance | ⚠️ BLOCKED | Signing, physical iPhone/PC gameplay, domain associations and production operations remain unverified. |

## Implemented

Existing AppLocalizations/AppFormats now supply conditional offer/wishlist semantics, signed RR/results, Battle Pass summaries, loadout slots, optional live statistics, skin ratings and reward facts. UI consumers use explicit resources at render time. New ViewLabels adapters use the existing architecture; there is no second localization system or global current-language state.

Null versus empty optional fields, Home versus Profile punctuation, invalid slot numbers, positive/zero/negative RR and absent result categories preserve existing VI behavior. AppFormats supplies filtered inline facts, bounded unread badges, Unicode first-rune sentence case and RR formatting. Console captions use existing generated platform resources. LFG short language tags use the existing neutral language-code allowlist, independently of country, shard and UI language.

The view-only formatRr helper was retired into AppFormats. Its two former test callers retain independent assertions for the same strings. No storage/protocol identifier, metric, price, session or route was changed. Five new tests exercise branch parity, null/empty handling, invalid indices, unread bounds, platform aliases and Turkish/emoji case behavior.

## Verification

| Check | Actual result |
|---|---|
| Focused tests | 517 passed |
| Windows default / TEST_LOCALE=en / analyzer | 4,312 / 4,312 passed / 0 issues; en uses VI fallback |
| Mac default / analyzer | 4,312 passed (7m45s) / 0 issues |
| gen-l10n / l10n_check / extract / parity | pass; 0 l10n errors/warnings |
| Codemod tests / analyzer | 37 passed / 0 issues |
| verify --ci | **exit 1**: 62 references / 762 literal hits / 52 structural definitions; readyForCutover=false |
| Backend tests / typecheck / build / dependency audit | 867 in 34 files / pass / pass / 0 vulnerabilities |
| Android release build / public emulator QA | pass (70.7s) / 10 cases passed on emulator 5582 |
| Mac unsigned iOS release build / privacy lint | pass (Xcode 52.8s, app 82.8 MB) / pass |

All **842 frozen source hashes** match Windows and Mac after CI/build. Copied IPA hash, bundle metadata, privacy manifest and absence of signing were independently checked. The resolved legacy-reference inventory has zero feature-UI references; this does **not** mean every production string or all W2–W7 work is complete.

Artifacts remain local beside earlier versions:

* APK `dist/review/ValHub-1.0.0-4016.apk`: SHA-256 `CA128E24B735E23EB6D1CD9279F3C2B338AFE326A2CEF48EEE96FD37047396D0`, 125,338,647 bytes; ValHub / `vn.valvn.app`, **Android Debug signed**.
* IPA `dist/review/ValHub-1.0.0-4016-unsigned.ipa`: SHA-256 `26E851DCB045A5F9D13A71333B57F38B5C46FB474544080A1463C127331423E3`, 28,010,310 bytes; ValHub / `vn.valvn.app`, min 15.5, **unsigned**.

Owner emulator 5554 is visibly open on Store, version 4016. Mobile MCP hierarchy plus actual preferences/cache prove four-account upgrade preservation, separate four-offer Store data for every account and restoration of the original active account. Wishlist and four settings keys are preserved. Four displayed VP prices match real Riot daily Offer Cost values. All five tabs and return to Store were exercised without a login/retry prompt. A 129-second sample recorded HTTP 200=77 / 404=20; 20 cache files had no corrupt JSON or Subject/account mismatch. No current-process Flutter/fatal/ANR error line was found. These bounded checks are not acceptance of every live workflow.

Full tests caught two newly added ARB messages using unrecognized namespaces. They were corrected to liveGame and skinDetail; the existing structure validator was retained. Final CI above is the corrected rerun; failed/partial Windows and Mac attempts are preserved locally and are not counted as passes. Initial public QA stopped when uiautomator exited 137 after three cases. A direct hierarchy read succeeded; app exit history contained package-update/force-stop events rather than evidence of an app crash. The separate final public rerun passed all ten cases. No failed test was skipped or weakened.

Private account/hierarchy/cache/log proofs remain ignored under `dist/review/view-4016/`. No credentials, PUUIDs or private account evidence were committed. No public post, purchase, equipment or party mutation was made during this checkpoint. Existing free ML Kit remains; no paid AI/API was added.

## 🟢 VERIFIED COMPLETE

The conditional-caption migrations and tested compatibility branches above are verified. Windows/Mac unit and widget tests, Android public flows and bounded four-account real-data checks passed.

## 🟡 PARTIAL

Remaining model/provider/compatibility references, content pruning, translations/status/fallback, all-screen accessibility/performance and live business workflows need further work. Screen-reader semantics tests do not establish real TalkBack/VoiceOver acceptance.

## 🔴 RELEASE BLOCKER

Global cutover remains false. Seventeen genuine additional UI translations are absent; no unshipped language was enabled using copied Vietnamese.

## ⚠️ EXTERNAL BLOCKER

Signing/store accounts, physical iPhone/PC gameplay, domain associations, production monitoring/restore and linguistic/legal acceptance remain external. GitHub billing prevents hosted checks starting; local CI does not unlock GitHub.

## ❌ REGRESSION

The new ARB namespace errors were fixed before final tests/build. No remaining regression was observed in the exercised scope; this is not all-device/all-endpoint acceptance.
