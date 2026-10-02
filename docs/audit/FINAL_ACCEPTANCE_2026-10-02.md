# ValHub — final acceptance status, 2026-10-02

**Not production-ready.** No numerical readiness score or role sign-off is
asserted. The initial all-PASS report contained unsupported conclusions and
incorrect runbook commands; this file replaces those claims.

## 🟢 VERIFIED COMPLETE

Only the explicitly executed checks in
[Gemini change review](GEMINI_REVIEW_2026-10-02.md) and earlier dated checkpoints.
An automated suite result certifies that suite, not every product workflow.

## 🟡 PARTIAL

Global localization, whole-device accessibility/performance, moderation,
backend endpoint acceptance, native iOS behavior and production operations.
Current UI ships VI only; an English test define does not create translations.

## 🔴 RELEASE BLOCKER

Unfinished global cutover and unverified security/native/production acceptance.
Do not release with suppressed native checks or unresolved test regressions.

## ⚠️ EXTERNAL BLOCKER

Release signing/Apple/Play configuration, physical iPhone/native QA, live PC
propagation, HTTPS domain/association/web fallback, production restore/RPO/RTO,
alert destination, native-language/legal review and GitHub billing unlock.
Mac build access is available; unsigned build evidence is not store acceptance.

## ❌ REGRESSION

The incoming Gemini snapshot failed 38 Flutter cases and disabled native smoke.
The repaired snapshot passed both full suites (4,205 each), analyzer and five
native tests. These reproduced regressions are resolved in that snapshot;
the combined build 4009 subsequently passed 4,236 tests on Windows (both defines)
and Mac, analyzer, six Android native cases, ten public flows and APK/unsigned
iOS builds. See [combined checkpoint](../VALHUB_INTEGRATION_2026-10-03.md).
Untested workflows are not certified by this result.

## Actual operating instructions

Use [server/community/README.md](../../server/community/README.md) and
[build instructions](../BUILD.md). The healthcheck is `/healthz`. Backup is the
existing Compose service, not a nonexistent scripts/backup.sh. Restore is the
existing archive-based scripts/restore.sh with a separate explicit --yes for a
live restore. No production deployment, backup or destructive restore was
performed by this review. There is no verified requirement here to replace
Riot's existing login configuration with an invented production Client ID.
