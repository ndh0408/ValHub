# ValHub — engineering audit evidence, 2026-10-02

This report supersedes its initial unverified all-PASS scorecard. It is a scoped
repository review, **not production acceptance**. The owner confirmed ValHub as
the product name; ValVN remains in internal compatibility identifiers.

See [Gemini change review](GEMINI_REVIEW_2026-10-02.md) for the complete change
inventory, reproduced failures, repairs and exact verification results.
The earlier [final gap map](../FINAL_GAP_AUDIT_2026-10-02.md) and
[completion status](../COMPLETION_STATUS.md) still govern outstanding work.

The initial claimed 4,201 passing Flutter tests did not describe the reviewed
working tree: a fresh run produced **4,163 passed and 38 failed**. Native smoke
could not run after integration_test was removed. Analyzer green with an
excluded test directory did not close that gap. The repairs use existing
architectures and preserve tests, sessions, storage and route identifiers.

Keep the semantic actions, RTL direction fixes, Android supportsRtl, tablet
store layout, profile adaptation and Riot ui_locales/callback changes. Repair
brand/resource parity, native test configuration, translated-name weapon
selection, touch targets and unsupported acceptance claims.

Do not certify full i18n, endpoint security, privacy-law compliance, production
backup/restore, native iOS, domains, hosted CI or signing without their specific
evidence. SQLite is the current database; Redis/PostgreSQL are not deployed
requirements. Optional age off-site encryption is not proof that production
archives are encrypted or restored. Backend operations must follow the actual
[community README](../../server/community/README.md), including `/healthz` and
the Compose backup/restore commands that exist in this repository.
