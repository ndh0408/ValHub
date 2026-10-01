# Query verification — 2026-10-01

Synthetic data only: 1,000 accounts, 100,000 rows each in media/votes/reviews, 31 measured repetitions after five
warmups. Node v24.19.0, Windows x64; local filesystem, no HTTP/cache/tunnel. Run `npm run build` then
`node dist/benchmark.js 100000`. The runner creates and removes its own temporary database and refuses a caller DB path.
Raw results are in `benchmark-before.json` and `benchmark-after.json`.

| Query | Before median / p95 (ms) | After median / p95 (ms) |
|---|---:|---:|
| Global media quota | 3.219 / 3.806 | 0.011 / 0.022 |
| Account media quota | 0.032 / 0.055 | 0.008 / 0.012 |
| Top 20 voted skins | 176.859 / 207.662 | 24.285 / 27.406 |
| Rating stats for 20 skins | 31.914 / 38.022 | 16.515 / 17.943 |

The old global quota plan is `SCAN media`. Migration 0011 replaces that SUM with a single-row lookup and
maintains exact byte totals through SQL triggers. Unit tests compare both counters to SUM after quarantine,
resize/transfer, rollback and account erasure, and backfill a real pre-0011 schema. Existing media quota, restore,
rights and moderation tests remain enabled. Counters include quarantined images, as the original quota did.

Top/rating queries previously repeated the trusted-user predicate for each content row. The new IN subquery
computes eligible users once per statement without storing eligibility that can go stale when account age passes
24 hours or a sanction expires. Existing tests cover new/established/sanctioned accounts and scope/period filters.

These timings establish local regression evidence, not capacity or latency guarantees. They do not measure
production skew, concurrent writes, edge cache, decoded image CPU, or the one-CPU Docker deployment. A `skin_stats`
table must preserve country/region/time filters, hidden reviews, account eligibility, sanctions, canonicalization
and erasure; it is not justified by inventing a production workload. No index was removed.
