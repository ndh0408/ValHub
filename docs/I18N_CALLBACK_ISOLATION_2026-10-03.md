# ValHub callback and account isolation — 03/10/2026, build 4011

This extends [render-time cutover, build 4010](I18N_RENDER_CUTOVER_2026-10-03.md).
It is a verified incremental checkpoint, not whole-product acceptance.

## Actual gaps and changes

The resolved inventory decreased from **339 to 307 production references**;
**762 Vietnamese literal hits / 52 structural legacy definitions** remain.
This checkpoint migrated 32 references, bringing this day's reduction from
514 to 307 (207 references). Cutover remains **false**. Only Vietnamese ships;
the English test define still exercises the documented VI fallback.

Two existing defects were reproduced before their fixes:

* Five delayed party operations (ready, join, accept, kick, leave) failed after
  provider disposal with `Cannot use the Ref ... after it has been disposed`.
  `refresh` and response application now check `ref.mounted` before reading
  state or starting the follow-up fetch. The same five regression tests pass.
* When a join from account A completed after switching to account B, B's newly
  entered party code was cleared (expected `NEW789`, actual empty). The party
  screen now keys its internal state by active account. Old pending actions,
  code fields and invite ticks are disposed; completion cannot clear B's code
  or show A's success there. The reproducing widget test passes with the fix.

The screen also guards code-field access after an async join and captures
localization resources before action awaits. Its external constructor, route,
poll interval, Riot calls and confirmation requirements remain compatible.
No party operation was automated against a live Riot account in this checkpoint.

Login callbacks capture resources before suspension, reject callbacks against
a disposed screen and avoid entering account completion through a disposed
widget ref. Delayed cookie capture stops when its login screen has closed and
does not initiate the final shared WebView cleanup from that closed screen.
The cookie/token protocol, secure-store keys and server identity checks remain
unchanged. Native Riot login/cookie cancellation races require further live
acceptance; source guards and guest release smoke are not proof of every race.

The party summary uses a manual ICU `select` resource. Tests preserve all prior
Vietnamese open/invite-only summaries and the unknown-state fallback. No fake
translation, paid AI integration, skipped test or weakened assertion was added.

## Verification

| Check | Actual result |
|---|---|
| Old disposal behavior, targeted reproduction | **5 failed**, expected; final source restored with fixes |
| Old shared party state, targeted reproduction | **1 failed**, expected; next account's code was cleared |
| Focused social/auth/render-label tests after fixes | **190 passed** |
| Windows full default / TEST_LOCALE=en | **4,246 passed each**, VI fallback for EN |
| Windows analyzer | **0 issues** |
| Mac SSH full suite / analyzer | **4,246 passed / 0 issues** |
| ARB validation / extract --check / parity --check | **0 errors, 0 warnings / pass / pass** |
| Dart format / git diff --check | **722 files, 0 changed / pass** |
| verify --ci | **Exit 1**, 307 references / 762 literals; gate not disabled |
| Android release build / public-flow smoke | **4011 built / 10 passed**, QA emulator 5582 |
| Visible owner emulator 5554 | **4011 installed**, four accounts/active/wishlist and four settings keys preserved |
| Mac unsigned iOS release / privacy manifest | **4011 built**, 82.8 MB Runner.app / lint passes |
| Local IPA validation | Hash, version, bundle ID, display name and packaged privacy manifest verified |

Mac inputs were verified against **833 file hashes**, including all ten changed
source/build-input files, in the existing dedicated QA directory. No owner Mac
project was overwritten. Backend source and native plugin integration were not
changed: their preceding checkpoint remains **867 backend tests**, typecheck,
build and npm audit pass; **37 codemod tests** and **6 Android native tests**
passed at build 4010. Those counts are retained evidence, not new 4011 reruns.

Android: `dist/review/ValHub-1.0.0-4011.apk`, 119.4 MB.
SHA-256: `1A8F0234CEB782F1076A29F920EAFAEE5E82400CEC09850F0319A1ED44D919ED`.
Package `vn.valvn.app`, min SDK 24 / target 36, **Android Debug** signer.

iOS: `dist/review/ValHub-1.0.0-4011-unsigned.ipa`.
SHA-256: `74AFFC8868178ECBA29ACCB5B6A5B9B83097CD1CAE6FD125C75646D4FD496074`.
Bundle `vn.valvn.app`, minimum iOS 15.5, display ValHub, version 4011.
`codesign` confirms unsigned. Neither artifact establishes store signing or
physical iPhone acceptance.

Actual Mobile MCP semantics after the owner upgrade showed daily Store and four
wishlist controls, matching four real cached offers, without an observed login
error. Hash-based comparison verified preserved account IDs, active ID, wishlist
and every persisted `settings.*` key. No private account data is published.
The four-account switching and five-tab observations from build 4010 remain
separately recorded; they are not relabeled as a complete 4011 authenticated E2E.

The requested second search covers all 20 terms plus ValHub in **1,068 tracked
text files**, with file/count results retained locally. Exact uppercase marker
matches are four TODO, two FIXME and two HACK, all outside production `lib/`.
Substring matches are classified rather than replaced:
`toDouble` matches TODO case-insensitively, theme-preview `_mock` is intentional,
and legal warnings about hacks are not unfinished code. Protocol identifiers,
legacy compatibility names, ICU placeholders, test fixtures, bounded diagnostics
and local operational URLs remain as documented. Keyword counts are not a
security or production acceptance certificate.

GitHub's Android check on commit `f4f0539` explicitly reported that its job was
not started because the account is locked due to billing. Local success does
not change that hosted-CI state; no billing or store publication action was taken.

## 🟢 VERIFIED COMPLETE

The two reproduced party defects, resource migration and scoped local checks
above are verified. ValHub branding and existing package/storage/deep-link
compatibility remain preserved.

## 🟡 PARTIAL

Other async/model/content consumers, complete W2–W7 cutover, translated and RTL
acceptance, 18-language moderation review, full endpoint/performance/privacy
acceptance, live authenticated Community writes, native iOS behavior and immediate
VALORANT PC equipment propagation remain incomplete or insufficiently verified.
The earlier unresolved real-account card-restoration evidence remains unchanged.

## 🔴 RELEASE BLOCKER

**307 references / 762 literal hits**, 17 genuine translations and the remaining
fallback/content/locale acceptance gates prevent global release. Production
moderation, security, restore and operations acceptance remain open as specified
in [the gap audit](FINAL_GAP_AUDIT_2026-10-02.md). No whole-product completion or
production readiness is claimed.

## ⚠️ EXTERNAL BLOCKER

Release signing/store accounts, physical iPhone and live game acceptance,
production domain/associations/web fallback, production infrastructure and
restore/alert validation need external setup. Hosted GitHub billing remains
blocked; the local Windows/Mac checks do not unlock it.

## ❌ REGRESSION

No unresolved regression was observed in the executed final checks. The
reproduced defects were fixed and covered by retained tests. Unexecuted devices
and features are not assumed correct.
