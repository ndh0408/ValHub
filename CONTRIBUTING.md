# Working on ValHub

This repository is proprietary. Visibility and this guide do not grant a license
to modify, copy or distribute it; see [LICENSE](LICENSE). Contributions require
the owner's authorization. Existing authorization for a task remains valid.

Read [CLAUDE.md](CLAUDE.md), [architecture](docs/ARCHITECTURE.md), the latest
[completion checkpoint](docs/COMPLETION_STATUS.md) and relevant feature/design
documents before editing. Search for the implementation first. Preserve existing
behavior, tests and stored data; extend the current architecture.

Use **ValHub** for product text. Keep compatibility identifiers such as `valvn`,
`vn.valvn.app`, `vn.valvn.valvn`, `valvn://` and storage keys unless a reviewed
migration exists. Use real game data; report unknown/unavailable fields honestly.
Existing free on-device ML Kit is authorized; do not add paid AI integrations.

Make reviewable changes with the problem, resulting behavior, validation and
limitations in the description. Prefer a PR when repository access permits it.
Direct owner-authorized commits may use the same checks and evidence. The current
default branch is `claude/jolly-hawking-23o2j8`; this guide does not rename it or
claim branch protection is configured. Do not force-push shared history.

Run appropriate checks from the repository root:

```sh
flutter analyze
flutter test --coverage
python3 tool/qa/flutter_coverage.py
flutter test --dart-define=TEST_LOCALE=en
flutter gen-l10n
dart run tool/l10n_check.dart --ci
dart run tool/l10n_codemod/bin/l10n.dart verify --ci
```

Coverage reports instrumented lines, excludes generated localization and lists
uninstrumented files. It is not a completeness score. The cutover command still
fails at the current checkpoint; disclose this release blocker rather than
weakening its assertions or gate. See [build instructions](docs/BUILD.md) for
toolchains and [release gates](docs/RELEASE_GATES.md) for acceptance.

For backend changes, run the existing `npm test`, `npm run typecheck` and
`npm run build` in `server/community`, plus relevant isolated Docker/security/
restore checks documented in its README. Never run preference-seeding integration
fixtures on an emulator holding real accounts. Never commit tokens, cookies,
credentials, account exports, private logs or signing material. Report security
issues privately using [SECURITY.md](SECURITY.md).
