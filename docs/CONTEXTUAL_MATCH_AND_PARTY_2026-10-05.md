# ValHub — contextual match and party, QA build 4030

This bounded change follows build 4025. Builds 4026–4029 were intermediate
implementation/verification builds. Final source and artifacts are 4030; this
checkpoint does not close the whole-product release gates.

## Gap map and implementation

Existing account-scoped live detection, party/queue, agent selection, team
rosters and post-match scoreboard are reused. Navigation and phase priorities
needed correction; no replacement service or scheduler was added.

| Audited gap | Initial status | Final bounded result |
|---|---|---|
| Separate Profile match/party entries | 🟡 PARTIAL | One contextual entry; `/profile/party` and `valvn://` retained |
| Active match entered through party controls | 🟡 PARTIAL | Match presentation takes priority; party utilities remain secondary |
| Party-player 404 treated as game stopped | ❌ REGRESSION | Confirm against game-session endpoint; preserve verified running phase |
| Match found while session still says MENUS | 🟡 PARTIAL | Match-found caption, no ready/queue bar; retained result cannot override new match |
| Unknown session allowed ready/queue | 🟡 PARTIAL | Actions require verified lobby; errors/retry remain visible |
| Narrow party status/ready row | ❌ REGRESSION | Wrapping layout passes 320 dp/200% text tests |
| Fast-poll close after provider disposal | ❌ REGRESSION | Mounted guard and balanced page lease pass teardown tests |
| Live per-player K/D/A | ⚠️ BLOCKED by current source | Explicit unavailable notice; existing published post-match reader retained |

| Verified state | Main presentation |
|---|---|
| Both party and game session missing | Existing open-game guidance and retry; no fake party |
| Lobby | Party members, readiness and eligible queue controls |
| Game session running, party missing | Real session phase; party-unavailable notice and retry |
| Queueing | Queue status/timer and eligible cancellation |
| Match found, session not yet transitioned | Match-found status; no ready/queue actions or previous scoreboard |
| Agent selection | Existing selector and own team; enemy roster remains hidden |
| In game | Own/enemy tabs, agents and fresh own-presence score when available |
| Ended | Published final scoreboard or waiting-for-data state |
| Unknown/error | Error/retry; ready/queue require a verified lobby |

Profile always opens the existing party route. It renders the existing live
sheet as a page during agent selection/play/results and returns to party
presentation for a new queue. A secondary menu opens the original party utility
without ready/queue controls during a match. Battle Pass, Friends, settings and
default standalone party behavior remain available.

The page balances the existing fast-poll lease; account-keyed presentation
disposes old forms/callbacks before showing another account. Existing polling
cadence, background behavior, score freshness/privacy and final-result retention
remain. No automatic invite, ready, queue, agent-lock or leave mutation was added.

## Final verification

- Windows analyzer: **0 issues**. Full suites: **4,442 pass** with default
  locale and **4,442 pass** with `--dart-define=TEST_LOCALE=en`. English-device
  testing proves fallback, not a shipped English translation.
- Windows **151 related tests pass**. The new **17-test** contextual-hub suite
  covers lobby → pregame → in-game → ended → new queue → match-found/session lag,
  missing party with confirmed lobby, optional utility, failed reads, retry,
  account switch with late response and teardown. Hub/live page tests cover
  **320/360/393/600 dp**, **200% text** and RTL. Profile tests enter the route in
  pregame/in-game and verify secondary utility reachability. These are widget
  tests, not device exercise of every phase.
- Mac analyzer: **0 issues**; **162 related tests pass**, including party,
  Profile entry and LFG creation. Release iOS **4030** builds with
  `--no-codesign`; privacy plist and identity (`ValHub`, `vn.valvn.app`, 4030)
  pass. **23 changed source/test/version inputs** match Windows after LF
  normalization; copied unsigned IPA SHA-256 matches Mac. No iPhone runtime or
  signing acceptance is inferred.
- Android release-mode **4030** builds; name/package/version and certificate
  checked. **10 public emulator smoke cases pass**, including legacy links,
  invalid destinations and landscape/200% login controls. APK retains the debug
  certificate, not a store key. Native plugin integration was not rerun; its last
  result remains the 4024 checkpoint.
- Backend is unchanged. Defined tests reran with **949 pass**; typecheck/build
  pass. An earlier concurrent run had one timeout/948 pass and is archived;
  unchanged separate rerun passes. No timeout/assertion was weakened. No backend
  redeployment is required for this UI change.
- Fresh hashed baseline immediately before owner-emulator installation proves
  **six accounts**, current selection, wishlist and settings preserved. User
  selection changed during the earlier shared 4026 session; it was not forcibly
  restored. Final 4030 Mobile MCP reads one Profile entry and current
  **not-in-game** presentation; read-only retry retains correct guidance and no
  ready/queue buttons. Bounded log aggregates: game session **36 HTTP 404**,
  party-player **16 HTTP 404**, **0 native fatal/unhandled** exceptions in the
  app process at the recorded check.
- Intermediate **4027** Mobile MCP read real **Split 13–12**, both team tabs,
  enemy navigation, legacy party link and secondary utility. In **4028**, real
  game-session **200/MENUS** alongside party-player **404** exposed the wrong
  open-game message; final provider tests reproduce and fix it. The final device
  had already left the game, so earlier live reads are not relabeled as final
  4030 in-game evidence. No chat/invite/queue/agent/leave mutation was used.
- `flutter gen-l10n`, `l10n_check --ci` (**0 errors/0 warnings**), ARB canonical
  format and legal Markdown sync pass. Strict codemod verify exits **1**:
  **0 production references / 5 detected literals / cutover false**. Existing
  VI resources now contain **1,884 messages**; no second localization system.

Initial failures remain archived, not counted as passes. Tests exposed unsafe
teardown and lost party utility access. New missing-party confirmation requires
no-game/LFG fixtures to explicitly return session 404; session-failure tests
disable framework retry to assert the original exception. The match-found test
expects its existing caption in both badge and banner. Assertions remain; no
test was deleted/skipped and no analyzer rule disabled. Final Android build ran
after Flutter tests/generation to avoid the observed concurrent generator clash.

| Artifact under `dist/review/` | Bytes | SHA-256 |
|---|---:|---|
| `ValHub-1.0.0-4030.apk` | 125440198 | `b3b2233ca27e47e9a091e8b8da847bf8bfaace8c337d54d749f91c5465907f1f` |
| `ValHub-1.0.0-4030-unsigned.ipa` | 28002511 | `81068b4792ee0800132c99559f77a64784f6c4a52482856a8bb3f42e94aef008` |

Final ignored evidence: `dist/review/play-context-4030/`. Intermediate
`play-hub-4026` and `play-context-4027`–`4029` retain earlier reads/failures/reruns;
backend final logs are in `play-context-4028`. Keyword inventory was refreshed
without emitting secret-bearing matches. Legacy IDs/storage, credential handling,
fixtures, configured currencies and loopback QA references retain their roles;
no blind rename/removal.

## VERIFIED COMPLETE

The bounded entry, contextual phase priority, match-found guard, missing-party
confirmation, narrow layout and teardown fixes have the evidence above. Android
installation and unsigned Mac identity are verified separately from signed
release or physical-device acceptance.

## PARTIAL

Live K/D/A is unavailable from the current source. Real agent-selection,
completed-match and final 4030 in-game device acceptance remain unforced; their
transitions have widget evidence. All-screen accessibility, performance, API
contract and whole-product acceptance remain incomplete.

## RELEASE BLOCKER

Only VI UI/legal assets ship. Full 18-language/W2–W7 acceptance, strict cutover
and signed store release remain open. Five detected literals and **52 historical
manual extraction entries** are not claimed complete. See
[release gates](RELEASE_GATES.md) and [4024](LEGAL_ASSETS_AND_FALLBACK_2026-10-05.md).

## ⚠️ EXTERNAL BLOCKER

Apple/Play accounts/signing, physical-device/TalkBack/VoiceOver acceptance,
Riot approval/RSO/capability decisions and production HTTPS association/fallback
gates remain separate. Local CI does not establish that GitHub billing/protected
cloud checks are unlocked.

## ❌ REGRESSION

Reproduced false stopped-game state, lost utility access, narrow overflow and
unsafe teardown were fixed and verified. No remaining regression was reproduced
by these final checks; this is not exhaustive bug absence or production readiness.
