import 'package:flutter/foundation.dart';

/// A notification payload resolved into a route and an optional account.
@immutable
class DeepLink {
  const DeepLink({required this.location, this.accountPuuid});

  /// App route location to `go` to.
  final String location;

  /// Account to switch to first (`?account=<puuid>`).
  final String? accountPuuid;

  @override
  bool operator ==(Object other) =>
      other is DeepLink &&
      other.location == location &&
      other.accountPuuid == accountPuuid;

  @override
  int get hashCode => Object.hash(location, accountPuuid);

  @override
  String toString() => 'DeepLink($location)';
}

/// Parses a notification payload (VF §6.9): a route location such as
/// `/store?account=<puuid>&segment=nightmarket`. The `account` parameter is
/// removed from the location. Anything that is not an absolute app path
/// falls back to `/store`.
DeepLink parseDeepLink(String payload) {
  final uri = Uri.tryParse(payload.trim());
  if (uri == null || uri.hasScheme || !uri.path.startsWith('/')) {
    return const DeepLink(location: '/store');
  }
  final account = uri.queryParameters['account']?.toLowerCase();
  final rest = Map.of(uri.queryParameters)..remove('account');
  final clean = Uri(
    path: uri.path,
    queryParameters: rest.isEmpty ? null : rest,
  );
  return DeepLink(
    location: clean.toString(),
    accountPuuid: (account == null || account.isEmpty) ? null : account,
  );
}
