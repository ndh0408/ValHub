/// The only shapes `X-Riot-ClientVersion` and the Riot build number may have.
///
/// Kept in a tiny pure file so both the version repository and the
/// remote-config validator can use it (AR-010, AR-011).
library;

/// `release-13.06-shipping-13-5435758`: the only shape `X-Riot-ClientVersion`
/// may have. Anything else (third-party API glitch, CR/LF injection, a
/// remote-config typo) would break every PD / GLZ request.
final RegExp clientVersionPattern = RegExp(
  r'^release-\d{1,3}\.\d{1,3}-shipping-\d{1,4}-\d{4,9}$',
);

/// `111.0.0.3261.5663`: the Riot client build used in the API User-Agent.
final RegExp clientBuildPattern = RegExp(r'^\d{1,4}(\.\d{1,6}){2,5}$');

/// Whether [value] can be sent as `X-Riot-ClientVersion`.
bool isValidClientVersion(String? value) =>
    value != null && clientVersionPattern.hasMatch(value);

/// Whether [value] can be part of the API User-Agent.
bool isValidClientBuild(String? value) =>
    value != null && clientBuildPattern.hasMatch(value);

/// Printable ASCII, 20–300 characters, no CR/LF: the shape of a User-Agent we
/// are willing to put in a header.
final RegExp userAgentPattern = RegExp(r'^[\x20-\x7E]{20,300}$');

/// Whether [value] is a safe User-Agent header value.
bool isValidUserAgent(String? value) =>
    value != null && userAgentPattern.hasMatch(value);
