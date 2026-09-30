# ValVN — Global audit (Phase 0)

Date: 2026-09-30 · Baseline: branch `claude/jolly-hawking-23o2j8` at `009d1c1` (+ server `e7709ee`…`76f6a46`).
Method: four independent read-only audits with file:line evidence; nothing was modified while auditing.

| Report | Scope | Findings |
|---|---|---|
| [AUDIT_GLOBAL.md](audit/AUDIT_GLOBAL.md) (GL-) | i18n, locale, formatting, RTL, fonts, region/shard/country, legal, platform | 44 |
| [AUDIT_ACCOUNTS.md](audit/AUDIT_ACCOUNTS.md) (AR-) | Riot auth/session, account isolation, caches, background, notifications, deep links | 34 |
| [AUDIT_PRODUCT.md](audit/AUDIT_PRODUCT.md) (PR-) | match analytics, store/skin data, Home, UX/a11y, sharing, notification categories | 30 |
| [AUDIT_COMMUNITY.md](audit/AUDIT_COMMUNITY.md) (CS-) | community server + client: security, privacy, data model, media, ops | 41 |

Every finding row has: ID, severity, area, file:line, current behavior, problem, recommended fix, risk, effort, dependencies.

## 1. Executive summary

- **Architecture is sound; nothing needs rewriting.** Account isolation is correct end to end (secure-storage keys, prefs, file caches and every Riverpod family are keyed by PUUID); no token/cookie/PUUID logging or egress beyond the one documented community call; the community server has no injection, auth-bypass, traversal or SSRF path and every mutation route checks ownership.
- **Global readiness is 3/10 today** (design ≈ 8/10, shipped ≈ 2/10): UI text, login page, status notices, notifications, legal texts, iOS/Android platform config and server messages are Vietnamese-only; the i18n plan (docs/design/I18N.md) is being executed (W0 in flight).
- **Wrong data is shown today** (must-fix): Deathmatch turns "ACS" into thousands inside the 10-match recent form (PR-02); the Home store card says "đủ mua 4 skin" when at most 1 is affordable (PR-04); a semantics label reads "…, trong" (GL-10); Riot session `expiredTime` handling was fixed in `1c75247`.
- **Traffic toward Riot is not shaped** (AR-001/005/006): failed re-auth retries immediately with no cooldown, Cloudflare blocks are retried up to 12× per provider, several accounts re-auth in parallel; offline users wait ~30 s to see an error.
- **Sign-out is incomplete and not atomic** (AR-002/003/014/016/018) and contradicts the confirm dialog/privacy text.
- **Community server**: media is cached at Cloudflare's edge by file extension, so deleted/quarantined images stay downloadable (CS-01 — verified live); no ban/sanction or single-item takedown tooling although the published rules promise them (CS-02); moderation runs before rate limiting and signed-in reads are unlimited (CS-03); session tokens cannot be revoked and revive after account deletion (CS-04).
- **Gaps versus the product goals**: no cross-match analytics (agent/map/queue/side/trends), no store history, 3 of 7 notification categories, no external deep links, tablet/foldable/landscape run as stretched phones, RTL/a11y debt outside Home, only 2 verified VP price tables.

## 2. Decisions taken by the lead (owner delegated; revisit any)

| # | Decision | Why |
|---|---|---|
| D1 | Keep on-device ML Kit translation (opt-in); disclose Google model download in privacy policy and consent; no cloud/LLM AI anywhere | Owner: "không tích hợp AI, còn cái nào miễn phí thì càng tốt". Closes PR-30, AR-033, CS-10 (as disclosure fix). |
| D2 | No push notifications / no notification server: Community & LFG alerts are in-app badges; local notifications only | Free, private, matches privacy policy. Closes the open question in PR-05. |
| D3 | RR/store history only for the user's OWN accounts (never third-party PUUIDs), wiped on sign-out unless the user chooses "keep local data"; add "Xóa dữ liệu cục bộ" | Fixes PR-08, AR-002, AR-014, AR-016 consistently. Wishlist stays (VF W6) with the same choice. |
| D4 | Dark-theme filled buttons use a darker red for WCAG AA text; brand red stays for accents/icons | PR-10. |
| D5 | Redis: not adopted; SQLite stays. Add injected store interfaces only (CS-41); PostgreSQL only when multi-node/HA/size demands (CS-40) | Evidence from the audit; avoid over-engineering. |
| D6 | Token-receiving host is pinned in code (allow-list); community base URL removed from remote config | AR-009, CS-28. |

## 3. Work packages (Phases 1–6 of the brief)

Owners are disjoint by path so they can run in parallel worktrees; merge order = order listed inside a phase.

### Phase 1 — Global foundation
- **I18N program** (docs/design/I18N.md): W0 foundation (running) → W1 extract+parity → W2 core → W3 features → W4 cutover → W5 runtime (settings language UI, ItemLanguage→contentLocale, Riot `ui_locales`, status locale) → W6 translations (18 locales) → W7 layout/RTL/font QA. Covers GL-01…10, 13, 14, 16–18, 22, 27, 29, 31–33, 35, 36, 38, 42.
- **COUNTRIES P0–P3** (docs/design/COUNTRIES.md): separate country / region / shard / language / timezone / currency in `Account` and prefs (GL-11, GL-12, GL-19, GL-29); country picker + manual region override.
- **Small global fixes needing no i18n** (do first): GL-10 label bug, GL-24 `normalizeTier` from ids, GL-25 DST day math, GL-26 tz fallback UTC + "giờ Việt Nam" copy, GL-37 log scrubber, GL-38, GL-39 ping thresholds, GL-40 LFG language default.

### Phase 1b — Security & correctness hardening (parallel, before the i18n core round)
- **WP-SRV** `server/community/**`: CS-01, 02, 03, 04, 05, 09(text via client), 11, 13, 15(server half), 16, 17, 18, 19, 20, 21, 22, 27, 28(server), 30, 33/GL-15 (reason codes), 34, 36, 37, 38, 39, 40(GL-40), 41; add server CI.
- **WP-CORE** client core (`lib/core/{auth,network,accounts,storage,config,background,notifications,xmpp,logging}/**`, `lib/features/store/providers/store_reset_reminder*`, notifications section in settings): AR-001, 005, 006, 007, 008, 009, 010(pin+validation), 011, 017, 019, 020, 021, 022, 023, 024, 025, 026, 027, 028, 029, 030, 031(tz part), 032, 034; PR-05 (channels battlePass/rank/community/lfg + toggles), PR-06, PR-29; sign-out completeness AR-002/003/018 (+ orphan sweeper) per D3.
- **WP-DOMAIN** `lib/core/domain/**`, `lib/features/{profile,home,store,battlepass,skin_detail}/**`: PR-01 (pure performance module + own-account match ledger), PR-02, PR-03 (store history), PR-04, PR-08 (own-only RR history + delete control), PR-09, PR-15, PR-17, PR-18, PR-19, PR-26; AR-013, AR-014, AR-015, AR-016.

### Phase 2 — Product core / Phase 3 — Analytics
Delivered by WP-DOMAIN plus UI on top: agent / map / queue / attack-defense / recent-form / trends screens, Home “Recent performance” upgrades, store history and skin intelligence, notification categories.

### Phase 4 — Community
Reviews/votes/LFG/country scopes are live. Remaining: sanctions & takedown tooling (CS-02), vote/rating integrity (CS-05, CS-07), report weighting (CS-06), party code exposure (CS-15), client block/mute list, consent version record (CS-34).

### Phase 5 — Production hardening
CS-11/12 (erasure ledger, encrypted off-host backup + restore drill), CS-29–32, server CI, crash/error reporting **without** third-party SDKs (local session log + optional user-initiated export; no analytics SDK), performance items PR-22/25, AR-028.

### Phase 6 — Release
Adaptive layouts (PR-12/24, DEVICES.md), RTL codemod + a11y (PR-10/11/13/16/20/21/27/28, GL-16/17/22/33/34), deep links/share (PR-07), iOS platform config (GL-13, AR-027/032), store metadata (GL-44), release signing, CI (billing-locked GitHub Actions must be unlocked by the owner).

## 4. Corrections to existing docs (from the audit)
- I18N.md §2.1: ~27 fragment-composition sites exist outside the strings files (GL-10); §2.2: default preset name is persisted (GL-38); §8.1: only `Icons.logout` needs mirroring.
- DEVICES.md §1.8: `logout` does not auto-mirror in material_ui 1.4.0.
- COUNTRIES.md Q14: the 18 `language` codes are already documented as accepted (content-api.md:32,65).
- README/pubspec/settings copy still call the app Vietnamese-only (GL-21).

## 5. What must not be broken (verified correct)
PUUID-scoped secrets and caches; sign-out ordering (metadata first, `_stillExists` guards); cross-isolate re-auth lock; cookie/token rotation order; needsLogin classification; auth interceptor single retry; PvpApi contract (only RiotException, mutations never retried); SessionLog scrubbing; community consent gate and anonymous reads; deep-link parsing; local-only notifications; per-account wishlist migration. Full lists are at the end of each audit report.

## 6. Unverified (needs a device, real accounts or host access)
See section 4/6 of each report. Highlights: real Riot session payloads for the online status; iOS behaviour of `CFBundleLocalizations`; Riot login callback shapes for zh/es-419; `ui_locales` for non-Latin locales; Cloudflare cache rules/edge behaviour for media 200s; host state of `coolify-dev` (SSH was unreachable during the audit); ML Kit telemetry; store reset time on non-AP shards.
