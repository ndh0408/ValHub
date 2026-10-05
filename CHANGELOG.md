# ValHub change log

This records verified checkpoints, not promises or store releases. Internal
package/storage identifiers remain ValVN for compatibility.

## 2026-10-05 — QA build 4023

- Reject malformed public status responses instead of displaying a healthy
  server summary; failed refreshes retain cached data with an error/retry row.
- Correct the product name in the repository license to ValHub; license rights
  and restrictions are unchanged.
- Add contribution/security/release guidance and a coverage-reporting tool.
- Record Community public-session fallback and private/write guard tests.
- Publish instrumented line coverage from Android CI; English-device fallback
  tests become required instead of advisory. Cloud execution is not verified by
  local runs.
- Windows: 4,396 tests per configuration, analyzer clean; Mac: 165 relevant
  tests and unsigned iOS build. Android: six native and ten public cases.
  Coverage: 89.96% of instrumented lines, with 16 source files absent from LCOV.
- Preserve six real accounts/settings after upgrade and verify cached status /
  error / retry / recovery through Mobile MCP during actual network loss.
  See [deep review checkpoint](docs/DEEP_REVIEW_CHECKPOINT_2026-10-05.md).

## 2026-10-05 — QA build 4022

- Isolate chat drafts and queued sends by sender and recipient (`b665a74`).
- Windows: 4,389 tests per configuration; analyzer clean. Mac: 128 Social/XMPP
  tests and unsigned iOS build. Android: six native and ten public-flow tests.
- Preserve six real accounts, active selection, wishlist and settings after
  installing the APK update; see [audit reconciliation](docs/AUDIT_RECONCILIATION_2026-10-05.md).

## 2026-10-05 — Community production rollout

- Deploy `afa7162`, including correct Riot inventory kinds/grouped parsing and
  required game headers for owner-review verification; retain existing records.
- Verify real comment/review create/read/delete and SQLite backup restore drill;
  API, backup and watchdog healthy. See [rollout evidence](docs/PRODUCTION_DEPLOYMENT_2026-10-05.md).

Earlier checkpoints remain in [PROGRESS.md](docs/PROGRESS.md). Localization
cutover, full product/device acceptance and signed store release remain open.
