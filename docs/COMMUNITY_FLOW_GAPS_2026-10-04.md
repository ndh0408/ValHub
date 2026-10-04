# Current flow audit — after checkpoint 4019

Latest owner requirements override the earlier scoped/weekly ranking design.

| Area | Before implementation | Evidence / intended correction |
| --- | --- | --- |
| Global, all-time skin ranking | 🟡 PARTIAL | Ranking exists, but scope/time controls contradict the latest request. Retain legacy backend compatibility; fix product query and controls. |
| Real skin discovery and reviews | 🟡 PARTIAL | Real searchable catalog and review detail exist; empty leaderboard does not show catalog items inline. Show real content without invented votes. |
| Owner-only star ratings/reviews | 🔴 MISSING | PUT review authenticates author but does not verify Riot inventory. Add server identity-bound ownership verification and fail closed. |
| Consent immediately after login | 🔴 MISSING | Per-account versioned consent exists; login does not require it. Add an explicit gate for new, existing and switched accounts; retain legal access and sign-out. |
| Country in Community | 🟡 PARTIAL | Authenticated Riot country is already stored locally; Community only asks its profile endpoint. Reuse verified local account country on profile failure, never device/manual hints as server identity. |
| Match experience | 🟡 PARTIAL | Match detail, timeline, ledger and deterministic agent/map/queue/side/trend analytics exist. Tracker comparison and fresh-account real-device behavior still require audit. |
| Country and UI language | 🟡 PARTIAL | Country/device/manual preferences and existing locale provider are distinct. Never infer language or shard from account country or force a language change. 17 genuine UI translations remain unshipped. |
| Production release | ⚠️ BLOCKED | Signed store accounts, domain/infrastructure and physical-device acceptance remain external; local CI/build does not prove production acceptance. |

No newly confirmed regression at this audit point. Implementation and verification
results will be added only after the relevant changes are tested.

## Checkpoint 4020 verification

See [verified results and limits](ACCOUNT_AND_OWNERSHIP_CHECKPOINT_2026-10-04.md).
The initial map above records the state before implementation. Global/all-time
queries, the explicit consent gate and identity-bound ownership enforcement are
now verified by code/tests; real production ownership writes remain unverified.
Country repair was observed for all six saved accounts on the owner emulator.

## New owner request after 4020

| Area | Gap | Next correction |
| --- | --- | --- |
| Full skin catalog as main content | 🟡 PARTIAL | Inline discovery exists but a large empty state and a 30-item manual limit obscure the full catalog. Use a lazy complete list, compact ranking notice and visible-page statistics. |
| Plain skin comments without ownership | 🔴 MISSING | Review bodies require a star rating/ownership. Add separate comments using existing pagination, moderation, rate limit, reporting, export and erasure systems; never count them as ratings. |
