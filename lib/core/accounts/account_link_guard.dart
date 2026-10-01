/// Shared navigation gate; the router can defer links during Riot login.
enum AccountLinkDecision { open, unknownAccount, deferLogin }

AccountLinkDecision accountLinkDecision({
  required String? accountPuuid,
  required Iterable<String> signedIn,
  required String currentPath,
}) {
  if (currentPath == '/login') return AccountLinkDecision.deferLogin;
  if (accountPuuid != null &&
      !signedIn.any((id) => id.toLowerCase() == accountPuuid.toLowerCase())) {
    return AccountLinkDecision.unknownAccount;
  }
  return AccountLinkDecision.open;
}
