# Security reporting

Report suspected vulnerabilities privately to the owner at
[ndh0408@gmail.com](mailto:ndh0408@gmail.com), the contact already published in
[LICENSE](LICENSE). Do not post credentials or exploit details in a public issue.
No response-time SLA or bug-bounty payment is promised.

Include the commit/build, affected route or feature, expected and observed
behavior, a minimal reproduction using synthetic accounts/data, and the impact.
Redact Riot/Community tokens, cookies, passwords, raw account identifiers, private
messages and exports. Use isolated environments; coordinate any production
security testing with the owner before it affects other users or data.

ValHub has not published a signed store release. Maintained scope is the latest
owner-approved default-branch code and deployed Community build identified in
the [completion checkpoint](docs/COMPLETION_STATUS.md). Historical APK/IPA files
are QA artifacts; this is not a support guarantee for every old build.

Relevant controls and limitations are recorded in the
[backend endpoint audit](docs/BACKEND_ENDPOINT_AUDIT_2026-10-03.md),
[production rollout](docs/PRODUCTION_DEPLOYMENT_2026-10-05.md) and
[release gates](docs/RELEASE_GATES.md). Green tests or a vulnerability scan do not
constitute independent penetration testing or regulatory certification.
