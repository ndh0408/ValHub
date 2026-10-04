# ValHub backend endpoint audit — checkpoint 4017

Scope: the **40 explicit registrations** in `server/community/src/app.ts` and `src/routes/*.ts`, their shared middleware, and the relevant SQLite operations. This records a source review and local adversarial tests, not production penetration testing. Implicit HEAD handling inherits the matching GET policy. Operator CLI commands are a separate surface.

## Gap found and fixed

Initial status: 🟡 PARTIAL. Session verification, epoch revocation and ownership guards existed, but authentication was cached for the whole request. A controlled catalog barrier proved a vote could commit after logout: logout 204, delayed vote 200, one stored vote. No real Riot account or production server was involved.

The shared context now revalidates the signed session against the current user row, creation time, epoch, expiry and sanctions immediately before synchronous commits following asynchronous validation/IO. The initial coarse request bucket is still charged once. Creates and retry responses use the same guard; media failures clean up their newly allocated blob. Non-create asynchronous writers also check the current session. Comments re-check parent visibility inside their commit. Vote rate limiting now precedes catalog lookups.

**33 new adversarial/control cases** cover vote, review, shared Store post, LFG and media; logout, erase/recreate (including the same second), restrictions and expiry; pending duplicate upload; the coarse bucket; and a parent hidden during comment validation. The first 25-case run had 20 failures and five valid controls before the fix. All 33 pass after the fix. The final complete backend suite has **900 passing tests in 35 files**, with typecheck/build successful and no production dependency audit vulnerabilities. Tests use isolated SQLite/fixtures. They do not establish live Riot capacity or production infrastructure safety.

## Policies used in every row

The table answers the requested ten questions: authentication; resource; owner; another user's access; server enforcement; rate limiting; input validation; idempotency; races; and privacy. Path identifies the resource, and the owner/access columns identify its authorization boundary.

* **S**: authenticated server context from a signed session, originally established through Riot userinfo. Client PUUID/account/user IDs never prove ownership. Present invalid tokens on optional-auth reads are rejected. Sanctions and session epochs apply.
* **O**: optional S or anonymous. Public content can be read by other users deliberately. Country/region/language scopes are discovery filters, **not private-content ACLs**. Own hidden content and personal flags remain specific to S.
* **R**: coarse authenticated-user request limit, plus the named action bucket where shown. **P**: anonymous IP read limit/cache (signed reads use R); media has its own IP limit, regardless of an Authorization header. Cache hits intentionally do not spend an anonymous bucket. Trusted-proxy/edge verification remains deployment work.
* **V**: bounded validated JSON (64 KiB), UUID/resource identifiers, enum/number/text bounds and cursor/limit validation as applicable. Media instead streams at most 2 MiB and uses magic bytes plus real decoding/dimension limits/metadata stripping.
* **C**: optional durable create idempotency key, payload fingerprint, per-user/route isolation, synchronous DB/content/retry-result transaction. **Set**: repeated PUT/DELETE preserves logical state, though counters/rate limits can change. **D**: repeated destructive delete may return 404; no claim of response idempotency. **N**: not guaranteed idempotent.
* **A**: current-session revalidation before a synchronous final write after awaits. **T**: existing SQLite transaction/unique/FK/conditional-update protection. No async IO is placed inside a SQLite transaction. Synchronous operations cannot interleave within one process; multi-process/edge behavior still requires production verification.
* Default response cache policy is **no-store**. Public media has immutable browser caching and configurable edge TTL: removal cannot revoke copies already downloaded/cached. No route returns Riot tokens, raw PUUIDs, cookies, report identities or private credentials; the auth route returns only its own Community session token.

## Endpoint matrix

| # | Method / resource | Authentication / owner | Other-user access and server guard | Rate | Validation | Idempotency / race | Privacy |
|---|---|---|---|---|---|---|---|
| 01 | OPTIONS `*` | anonymous / no owned row | public method response | load/body middleware; no action bucket | method/path routing | repeatable; no writes | no personal data |
| 02 | GET `/healthz` | anonymous / service | public DB ping only | load-shed exemption; no endpoint bucket | fixed path | read only | boolean health |
| 03 | GET `/healthz/deep` | actual loopback peer / service | refuses forwarded/public peers; dependency must exist | load/body middleware; no endpoint bucket | peer/address/header checks | read only | internal metrics; ingress remains external |
| 04 | GET `/v1/me/export` | S / self | no target-user parameter; own data | R + accountExport | own authenticated row | read only | own export, no-store; large export profiling pending |
| 05 | DELETE `/v1/me` | S / self | own rows/cascades only | R + accountDelete | authenticated row | D; rows removed synchronously, then file cleanup | erasure ledger/security retention disclosed |
| 06 | POST `/v1/auth/riot` | Riot access token / verified identity | Riot supplies identity/country; supplied PUUID ignored | IP attempts/failures | V, token bounds, region/cosmetic/language/consent fields | N; asynchronous Riot validation then atomic upsert | own Community token; cosmetic rank/region are client metadata |
| 07 | POST `/v1/auth/logout` | S / self | epoch bump for self across devices | R | authenticated row | old token becomes invalid; sync update | no token/body returned |
| 08 | GET `/v1/me` | S / self | no target-user parameter | R | authenticated row | read only | own public-profile fields |
| 09 | PATCH `/v1/me` | S / self | allowlisted cosmetic/region/language fields; identity/country not assigned | R | V | A; replacement of supplied fields | own response; region/rank not authoritative Riot proofs |
| 10 | GET `/v1/communities` | O / aggregate | public visible country activity | P/R | period enum | read only; bounded country set | public aggregate, no private membership |
| 11 | GET `/v1/lfg` | S / public authors | only open, active, visible rows; optional code-in-list policy | R | V, scope, rank/mic/mode/language/cursor/limit | read only; live party may change afterward | public LFG; hidden reasons only self |
| 12 | GET `/v1/lfg/mine` | S / self | own current post query | R | authenticated user | read only | own full/hidden state |
| 13 | POST `/v1/lfg` | S / self | owner/country from S | R + lfg before expensive work | V, code/rank/roles/agents/catalog/text | N; A + T replacement of own post | posted public requirements; code is not a seat reservation |
| 14 | PATCH `/v1/lfg/:id` | S / post owner | owner lookup plus owner/expiry conditional update | R + lfgPatch | V, bounded partial fields | A; TTL renewal means repeated PATCH changes expiry | own post only |
| 15 | POST `/v1/lfg/:id/join` | S / own intent, another public party | refuses self, hidden, expired/non-open post | R + lfgJoin | V, UUID/open-state checks | A + unique intent; repeated intent deduplicates | authoritative code returned to requester; Riot membership not proven |
| 16 | DELETE `/v1/lfg/:id` | S / post owner | server owner comparison | R | UUID/existence | D; sync delete/cascade | other users cannot delete |
| 17 | POST `/v1/media` | S / self | server-generated key, self owner, quota accounting | R + media before body/decode | bytes/type/decoder/dimensions/quotas | C; A before IO and commit, T quota triggers, cleanup on refusal | metadata stripped; active random-key URLs are public |
| 18 | GET `/v1/media/:key{.+}` | anonymous / public active blob | strict server-key regex; active row; hidden parent rejected | media IP limit even with header | key/status/parent checks | read/ETag; concurrent deletion and downloaded copies remain possible | public image, nosniff/CSP; not private storage |
| 19 | GET `/v1/posts` | O / public authors | visible feed; scope filters; personal liked flag from S | P/R | V, kind/languages/scope/cursor/limit | read only, bounded cache staleness | public country/region/global content |
| 20 | GET `/v1/me/posts` | S / self | ownOf authenticated ID, includes own hidden rows | R | V, cursor/limit | read only | hidden reasons only author |
| 21 | GET `/v1/posts/:id` | O / public author | visible post required; hidden returns 404 for everyone | P/R | UUID/existence | read only | public post; own hidden post uses own-list route |
| 22 | POST `/v1/posts` | S / self | owner/origin from S; media must be self-owned, active and unattached | R + posts before filtering/catalog | V, payload/media/catalog/text | C; A + T atomic attachment/ownership | public content; no private/friends mode implemented |
| 23 | DELETE `/v1/posts/:id` | S / post owner | server owner comparison before synchronous delete | R | UUID/existence | D; DB delete then async file cleanup | copies downloaded earlier cannot be revoked |
| 24 | PUT `/v1/posts/:id/like` | S / own like | visible target; liking public posts permitted | R + likes | UUID/visibility | Set + unique pair | public count; only viewer's own liked flag |
| 25 | DELETE `/v1/posts/:id/like` | S / own like | visible target, self like relation | R + likes | UUID/visibility | Set | other user's relation cannot be removed |
| 26 | GET `/v1/posts/:id/comments` | O / public authors | visible parent and visible comments | P/R | V, cursor/limit | read only | public comments |
| 27 | POST `/v1/posts/:id/comments` | S / self | visible parent rechecked at commit; owner/origin from S | R + comments before filtering | V, bounded nonempty text | C; A + T parent visibility/foreign key | public comment |
| 28 | DELETE `/v1/comments/:id` | S / comment owner | server owner comparison | R | UUID/existence | D; sync delete | other users cannot delete |
| 29 | POST `/v1/reports` | S / own report | target owner checked; self report not counted; no peer reporting data exposed | R + reports | V, target enum/UUID/reason bounds | A + T unique report, trust threshold; repeated response 204 | no reporter/count/hide result returned |
| 30 | PUT `/v1/skins/:skinUuid/review` | S / own review | canonical skin/user pair, origin from S | R + reviews before filtering/catalog | V, rating/catalog/text/language | A + T unique upsert; timestamps change | public review; own hidden reason only self |
| 31 | DELETE `/v1/skins/:skinUuid/review` | S / own review | user ID derived from S, canonical + legacy alias cleanup | R | UUID/canonical mapping | Set; sync | other review remains |
| 32 | GET `/v1/skins/:skinUuid/reviews` | O / public authors | visible scoped review list | P/R | V, sort/cursor consistency/languages/scope/limit | read only | public list with own flags |
| 33 | GET `/v1/skins/:skinUuid/summary` | O / aggregate, optional own review | public aggregates; myReview keyed by S | P/R | UUID/scope/canonical mapping | read only | hidden own review cannot be returned as someone else's |
| 34 | PUT `/v1/reviews/:id/like` | S / own relation | visible target; self-review like refused | R + likes | UUID/visibility/owner | Set + T unique relation | aggregate + own liked only |
| 35 | DELETE `/v1/reviews/:id/like` | S / own relation | visible target; self relation only | R + likes | UUID/visibility/owner | Set | other relation untouched |
| 36 | DELETE `/v1/reviews/:id` | S / review owner | server owner comparison | R | UUID/existence | D; sync | other users cannot delete |
| 37 | PUT `/v1/skins/:skinUuid/vote` | S / own vote | canonical user/skin pair; owner/origin from S | R + votes before catalog | V, UUID/catalog | A + T unique upsert | public aggregate, own vote flag only |
| 38 | DELETE `/v1/skins/:skinUuid/vote` | S / own vote | authenticated user + canonical/legacy alias | R + votes | UUID/canonical mapping | Set; sync | other vote untouched |
| 39 | GET `/v1/skins/top` | O / public aggregate | trusted-account/visible review filters, configured scope | P/R | V, sort/period/weapon/limit <=100 | read only; aggregate query profiling pending | deterministic counts/rating, no fabricated Riot metrics |
| 40 | GET `/v1/skins/votes` | O / aggregate, optional own flags | canonical bulk lookup; own votes keyed by S | P/R | 1..50 UUIDs, deduplicated, scope | read only, bounded bulk queries | no other user's private vote relation |

## Security and data limits

Ownership, session revocation, oversized bodies, upload decoding, path validation, idempotent creates, report trust, sanctions, canonical IDs and privacy/cache boundaries have regression coverage. SQL values use parameters; dynamic query fragments come from internal allowlists. Upload keys are server-generated, not user paths. Media is decoded/re-encoded and not fetched from client URLs; Riot/content fetch hosts are fixed. Public text is data; a future web fallback still needs its own escaping/security review. Profile rank/region/card are client-supplied cosmetic metadata and must not be advertised as independently verified Riot data.

SQLite is the actual database. Its FK/cascade/migration/unique/transaction protections are retained. No speculative indexes, PostgreSQL migration or Redis dependency were added. Aggregates and large account exports still require representative production profiling. Existing synchronous moderation is bounded/rate-limited but multilingual linguistic review, CPU load and operator audit acceptance remain partial. In-memory limits require correct single-replica/edge deployment; they are not distributed locks or Redis guarantees.

Public Community does not implement private-post or friends-only ACLs. Device-local hide/block is not server peer blocking. Request IDs/alert delivery, production restore/RPO/RTO, actual domain associations, edge deletion TTL and production penetration/load testing remain unfinished or external. No legal/privacy certification is asserted.

## Addendum — build 4021 skin comments

The original 40-route matrix above is historical. Three additive registrations
bring the current inventory to 43. Build 4020 also strengthened row 30: fresh
Riot identity must match the authenticated author, and Riot inventory must prove
skin ownership; legacy unverified reviews do not contribute star aggregates.

| # | Method / resource | Authentication / owner | Other-user access and server guard | Rate | Validation | Idempotency / race | Privacy |
|---|---|---|---|---|---|---|---|
| 41 | GET `/v1/skins/:skinUuid/comments` | O / public authors | visible comments of canonical catalog skin; invalid supplied session rejected | P/R | V, UUID/catalog, cursor and limit <=50 | read only; indexed chronological query | public plain text; no individual comment response cache |
| 42 | POST `/v1/skins/:skinUuid/comments` | S / self | author/origin from S; nonowners may comment, never supply stars | R + shared comments before catalog/filter | V, 1..500 code points, content language, known skin | C + A + T; revocation checked after catalog await | no Riot proof/token needed; plain comments do not alter reviews |
| 43 | DELETE `/v1/skin-comments/:id` | S / comment owner | server author comparison; other author refused | R | UUID/existence | D + T; associated reports removed atomically | self deletion only |

Fourteen new adversarial/control tests exercise ownership separation, invalid
sessions, author-only deletion, cursor ties, shared rate limits, retry conflicts,
late revocation, sanctions, moderation/reporting, export/erasure and query indexes.
They use isolated local SQLite and controlled catalog/Riot responses. Production
deployment, edge limits, multilingual linguistic review and load acceptance are
not established by these tests.

## Final classification (historical checkpoint 4017)

* 🟢 VERIFIED COMPLETE: the exercised late-authorization fix and 900-test local backend suite; explicit endpoint inventory reviewed.
* 🟡 PARTIAL: production security, multilingual moderation, private/friends visibility, server peer blocking, profiling and observability acceptance.
* 🔴 RELEASE BLOCKER: whole-product i18n cutover remains false; production acceptance is not established by this audit.
* ⚠️ EXTERNAL BLOCKER: infrastructure/edge credentials, real domain/production restore and native legal/linguistic review.
* ❌ REGRESSION: the reproduced late writes were corrected in final tests; no remaining regression observed in this local test scope. This is not a guarantee of all live behavior.
