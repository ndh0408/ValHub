# ValHub — legal assets and fallback, QA build 4024

This continues `41b90f1` using the existing i18n asset lane. It is a bounded
implementation/verification checkpoint, not whole-product acceptance. Product
name remains ValHub; ValVN package, bundle, scheme and stored identifiers remain
compatible. Existing free ML Kit is retained; no new or paid AI is added.

## Gap map

| Initial status | Actual finding | Implemented result |
|---|---|---|
| 🟡 PARTIAL | Legal prose remained in four Vietnamese Dart const trees; the final production legacy reference was the Riot disclaimer | Moved the existing documents to four VI JSON assets; every clause, version, date and contact remains unchanged |
| 🔴 MISSING | The documented legal asset loader and locale → en → vi chain did not exist | Pure-Dart `LegalRepository`, lazy Riverpod provider and stable document references reuse existing routes/reader/consent links |
| 🟡 PARTIAL | About/legal reader assumed synchronous const documents | Native loading, actual-source-language fallback caption and local legal-content error/retry; no misleading Riot-server error for bundled text |
| 🟡 PARTIAL | Markdown sync had no standalone check mode in the l10n workflow | Existing exporter extended with `--check`; required workflow step rejects stale/missing published text |
| 🔴 MISSING | EN and other translated legal assets | Still missing; no Vietnamese copies are represented as translations |
| ⚠️ BLOCKED | Native iPhone, signing and legal/translation acceptance | Mac unsigned build and widget fixtures cannot establish those external approvals |

The original 768 detected literals included 760 legal content fragments and
three legal-model/export captions. Fresh resolved verification now reports
**0 production legacy references / 5 detected literals**, no analysis errors or
unknown strings classes, and **cutover false**. The remaining five are three
language autonyms and publisher/copyright metadata, not five untranslated screen
flows. The unchanged manifest has **52 `manual` structural entries** describing
extraction limitations; this does not mean 52 unresolved production calls.

## Implementation and preservation

`assets/legal/vi/{privacy,terms,community,notice}.json` is the canonical long-form
content. The old const trees were exported once and removed after parity checks;
this relocates existing functionality and does not remove documents. Initial
Markdown was byte-identical for all four before updating only its generated-source
header. Final exported bodies still match the original baseline byte for byte.
Repository license rights and manually maintained license text are unchanged.

The existing model renders `p`, `sub`, `callout` and `list` blocks. The repository
requires the VI source, validates schema, identity, non-empty/bounded content and
export metadata, and shares cached reads per asset. Missing translations use
locale → en → vi; read failures or malformed present translations throw. A
translation must match source version/date, section/block/list counts and lead
presence. Structural checks do not prove semantic equivalence, preserved URLs or
legal approval; human review remains required. Failed asset reads are evicted so
retry can recover rather than retaining a failed Future.

Routes `/settings/about/{privacy,terms,community,notice}`, About order, consent
destinations, selectable text and table-of-contents navigation are preserved.
`LegalDocumentRef` identifies a document independently of its loaded language.
The screen reads the explicit current resources; the provider does not add a
second localization system or block app startup on loading all documents.
Fallback text identifies the actual language without inventing binding-text or
counsel-approval claims. UI captions remain in the existing ARB architecture.

Only **VI UI and VI legal assets ship**. The ARB template has **1,880 messages**;
17 UI translations, English legal text, translation status/stale handling and
the remaining W2–W7 acceptance are unfinished. Synthetic EN fixtures exercise
fallback and independence; English-device runs verify VI fallback. Neither is
evidence of a translated English release. Existing privacy clauses are preserved,
not newly certified for GDPR/CCPA/LGPD/Vietnam law.

## Verification and evidence limits

- Windows full default coverage and `TEST_LOCALE=en` runs: **4,411 tests each
  pass** with two workers; analyzer **0 issues**. Generated l10n, ARB formatting,
  ARB validation and legal Markdown check pass. Final Dart formatting checks
  **749 files, 0 changes**. Two files received formatter-only line wrapping after
  the full suites; no production behavior or assertions changed.
- Backend: **949 tests / 37 files**, typecheck/build pass, production dependency
  audit **0 vulnerabilities**. No backend source change or redeployment belongs
  to this checkpoint. The production API/backup/watchdog remain healthy on the
  existing runtime; previous production mutation/restore evidence remains in
  [the deployment record](PRODUCTION_DEPLOYMENT_2026-10-05.md).
- Coverage: **36,197 / 40,232 instrumented application lines (89.97%)**, **425
  files**, **12 source files absent from LCOV**, including `main.dart`. Generated
  code is excluded. This is line execution coverage, not branch/contract/privacy
  or whole-product acceptance; absent files are not marked covered.
- Legal regression checks cover full published-text parity, locale/English/VI
  fallback, concurrent read sharing, locale independence, corrupt-asset retry,
  schema/identity/version/date/clause mismatch, oversized/missing source and path
  traversal. Native-reader tests retain TOC/consent behavior and cover error/retry,
  fallback source caption, 320/393/600 dp at 200% text in LTR and RTL. Existing
  360 dp checks remain; this is VI text under layout stress, not Arabic/CJK or
  TalkBack/VoiceOver acceptance.
- Workflow YAML parses with Ruby/Psych; legal sync is required and the existing
  English fallback job is not optional. No cloud Actions run/protection setting
  is claimed. The strict cutover check still exits **1** and is retained.

Local evidence lives under `dist/review/legal-assets-4024/` and is not committed.
The earlier English run failed while generated code was being changed; it is
retained as `flutter-tests-en-before-final-copy.log`. The frozen-source rerun
above passed all 4,411 tests. No test was removed, skipped or weakened.

## Mac recovery and authorized cleanup

The owner authorized cleaning the Mac disk for checks. Cleanup removed **35
generated/staging directories, 2,616,148,185 bytes (about 2.44 GiB)**: old hashed
Flutter build caches whose files were older than two hours, and the old unpacked
4023 IPA staging copy. Resolved paths were restricted to the QA checkout and
symlinks were excluded. Source, user data, credentials, backups and Xcode were
preserved. The previous 4023 unsigned IPA was retained and its existing SHA-256
verified. Free space increased from roughly 235 MiB to 2.7 GiB; after reboot the
volume reported 2.9–3.2 GiB available.

One helper launch failed because Windows wrote CRLF into a bash script; the
script was corrected to LF and rerun. A later VMware guest kernel panic rebooted
the Mac during tests; that interrupted run is archived and is not an app crash or
a passing run. After the owner confirmed the Mac was up, SSH/source checks and
the native build pipeline resumed. The recovered Mac passed analyzer, legal
sync, **158 Settings/Community consent tests** and the unsigned build. Forty
source/test/legal inputs matched Windows by SHA-256. After the two formatter-only
changes, those final inputs were synced and the Mac analyzer/build rerun.

## Packaged and device checks

- Final Mac analyzer **0**, legal check and unsigned release build **4024** pass;
  privacy plist lint and bundle/name/version checks pass. All four legal JSON
  assets in `Runner.app` match source bytes. The downloaded IPA matches Mac's
  size/SHA-256. No codesigning or iPhone installation is claimed. Existing ML Kit
  Swift Package Manager and Android Kotlin migration warnings remain upstream
  dependency follow-up, not suppressed or fixed by this migration.
- Android native smoke **6/6**, release build **4024** and public smoke **10/10**
  pass on the separate QA emulator. Keystore/channel/60-slot scheduling guards
  remain covered. APK package is `vn.valvn.app`, name ValHub; it uses the existing
  **Android Debug certificate**, not an owner release key. Packaged JSON bytes
  match all four source assets.
- Owner emulator upgrade via install-over-existing-data preserves **six real
  accounts**, original active account, wishlist and settings; six stored country
  values remain. Mobile MCP hierarchy reads all four legal pages, their original
  dates/versions and all four About rows. Privacy TOC jumps to section 3 and Back
  to top returns to the version header. Cache/log checks report **0 native fatal
  or unhandled exceptions**. The screen was returned to Server Status. No real
  chat message/post or Riot mutation was sent by these checks.
- Post-format Windows analyzer/gen-l10n pass; **90 existing Settings UI tests**
  pass. An initial follow-up command also named a nonexistent route-test file;
  its load failure is archived, and the corrected invocation uses the existing
  UI directory. This is an invocation correction, not a deleted or skipped test.

| Local artifact under `dist/review/` | Bytes | SHA-256 |
|---|---:|---|
| `ValHub-1.0.0-4024.apk` — release mode, debug certificate | 125587702 | `c6698048ac3e519c5366589d06e703bc3f795c800a8f67df33cf74cae1861721` |
| `ValHub-1.0.0-4024-unsigned.ipa` | 28002159 | `6adf7cda4625cbd3ecf2d2b705ca9d1d4cd40737165cb791c4f08d9ec2e4f317` |

## Second audit

The requested keyword scan was repeated over tracked UTF-8 files and new legal
inputs, including ValVN/VanHub/ValHub, TODO/FIXME/HACK, mock/stub/placeholder,
currency/timezone, tokens/cookies/PUUID and network addresses. Evidence stores
paths/line numbers and counts, not raw account or secret values. Whole-word
TODO/FIXME/HACK in Flutter/backend runtime returned none; substring TODO hits
include `toDouble`. Counts are not vulnerability findings.

Image/skeleton placeholders and test fixtures are not invented Riot data.
Autonyms/publisher names stay stable rather than being translated indiscriminately.
ValVN package/storage/custom-scheme names remain compatibility identifiers;
historical VanHub checkpoints are not globally renamed. Existing configured
currency handling, XMPP namespace and local health/watchdog addresses remain
as classified in the preceding audit. No secret, penetration, legal or full
production-performance acceptance follows from a keyword scan.

## 🟢 VERIFIED COMPLETE

The bounded legal asset migration preserves all existing clauses; source-aware
loading/fallback/validation/retry, native reader/consent routes and required
Markdown sync check are implemented and verified within the tests/device scope
above. Local Android/Mac checks, artifacts, account preservation and authorized
generated-cache cleanup are evidenced. Existing deployed Community functionality
is retained; no duplicate backend/auth/localization system was introduced.

## 🟡 PARTIAL

Legal translation/native review, complete W2–W7/global locale acceptance,
all-screen/device accessibility, OpenAPI/contract gates, performance profiling
and broader release acceptance remain incomplete. Existing legacy classes and
manual extraction inventory still require W4 cleanup; zero runtime references
alone is not a completed cutover. Current SQLite/local-media/in-memory server
architecture remains unchanged.

## 🔴 RELEASE BLOCKER

Only VI UI/legal assets ship. The 18-language objective, remaining strict
cutover/translation/stale/locale-status acceptance and signed store release are
not complete. The strict verifier still exits 1; tests were not weakened to
change that result. See [release gates](RELEASE_GATES.md).

## ⚠️ EXTERNAL BLOCKER

Approved Riot registration/RSO/capability decisions, Apple/Play accounts and
release signing, physical Android/iPhone/TalkBack/VoiceOver acceptance, production
HTTPS association/fallback, and remaining off-site/alert/full-host restore
acceptance. Legal/translation review is separate from moving text into assets.
Local CI does not unlock GitHub billing or establish protected cloud checks.

## ❌ REGRESSION

No new product regression was reproduced by the listed full suites, native
smokes or owner checks. Generated-code concurrency, CRLF helper launch, invalid
test-path invocation and VM panic interruptions are retained in evidence and
were corrected or rerun; they are not fabricated passing runs. This checkpoint
does not claim exhaustive absence of bugs or whole-product readiness.
