# ValHub release gates

Status as of 2026-10-05. These gates describe evidence required for a public store
release; adding this file does not make them pass. Existing development/QA
functionality and compatibility identifiers are preserved.

| Gate | Current evidence | Still required |
|---|---|---|
| Riot product registration / capability decision | Official policy checked; no project approval evidence in this audit | Portal registration/access and documented decisions for actual auth/data/features |
| RSO / personal-data opt-in | Riot-client auth and account-specific Community consent exist | Approved RSO client/production access and its own integration/acceptance; present consent is not RSO approval |
| Public feature boundary | Existing functions and flags remain | Owner-selected release scope and server/client enforcement against that approved scope; do not assume all stats or LFG already approved |
| Localization | Existing locale architecture; VI UI; cutover gate fails | W2–W7/translation/RTL/device acceptance for the owner-approved launch scope; 18-language objective remains unchanged |
| Automated checks | Local Flutter/backend/tool checks and workflows exist | Successful cloud checks and enforced review/protection settings, or an explicitly documented local release process |
| Signing | Debug-signed release-mode APK and unsigned iOS QA build | Stable release keys/certificates/profiles and verified store artifacts |
| Real-device acceptance | Android emulator/native/public/account flows; Mac build | Android and iPhone physical-device matrix, live Riot/PC/account/session/privacy flows |
| App/Universal Links | Custom scheme routing and native tests | HTTPS association, domain ownership, public fallback and cold/warm acceptance |
| Operations | Healthy deployed SQLite API/backup/watchdog; restore clone/drill | Off-site backup/erasure-ledger and alert destinations; full-host restore, measured RPO/RTO; media recovery with actual media |
| Performance/accessibility | Tests and design requirements; partial device checks | Measured startup/scroll/API baseline and TalkBack/VoiceOver/all-screen/layout acceptance |

The checked [VALORANT Developer Policy](https://developer.riotgames.com/docs/valorant)
requires registration and RSO-based personal-data opt-in; it lists store tracking
and pre-match opponent scouting as unapproved use cases. The
[General Policy](https://developer.riotgames.com/policies/general) requires product
and feature audits. The current WebView/client API stack must not be described as
an approved RSO integration. Other apps offering similar utilities is not evidence
of ValHub approval.

Rank Progress uses visible RR and rule-based estimates in existing code; no hidden
MMR/ELO replacement is implemented or approved by this audit. Approval cannot be
inferred from a class name, a disclaimer, a consent checkbox or a compile-time
flag. A future capability layer needs an explicit scope and must guard network,
background and mutation paths as well as UI. No submission to Riot is made by
this work; the owner must provide portal access and product decisions.

Package/bundle ID is `vn.valvn.app`, Android namespace `vn.valvn.valvn`, Dart
package `valvn`, deep-link scheme `valvn://`. Keep these and stored keys compatible.
Product branding is ValHub; repository rights remain governed by LICENSE.
Changing default branch, license rights or launch markets requires an explicit
owner decision; an external review's suggestion does not override accepted scope.

## Review record before distribution

- Record the exact commit, backend image, migration state and artifact hashes.
- Run existing checks without deleting/skipping tests; retain failed gates.
- Validate release signing and install-over-existing-data behavior.
- Record each real-device/account flow, mutations and cleanup; distinguish fixtures.
- Verify backup/restore on an isolated clone before migration/deployment.
- Verify opt-in, export/delete/revocation and privacy boundaries for approved scope.
- Identify rollback artifacts and operators without exposing credentials.
- Mark unresolved gates above as blockers rather than signing off the whole app.
