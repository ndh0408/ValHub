import 'package:flutter/foundation.dart';

import '../config/app_constants.dart';
import '../riot/riot_hosts.dart';

/// Everything needed to call PD / GLZ / shared for one account.
///
/// Obtain it with `SessionManager.session(puuid)` (or `sessionProvider`);
/// never persist or log it. [toString] never prints tokens.
@immutable
class RiotSession {
  const RiotSession({
    required this.puuid,
    required this.accessToken,
    required this.idToken,
    required this.entitlementsToken,
    required this.expiresAt,
    required this.hosts,
    required this.clientVersion,
    required this.userAgent,
  });

  final String puuid;
  final String accessToken;
  final String idToken;
  final String entitlementsToken;
  final DateTime expiresAt;
  final RiotHosts hosts;

  /// `X-Riot-ClientVersion` value.
  final String clientVersion;

  /// API User-Agent (Riot client style).
  final String userAgent;

  String get region => hosts.region;
  String get shard => hosts.shard;

  /// True when the access token has less than 5 minutes left.
  bool isExpiringSoon(DateTime now) =>
      !now.isBefore(expiresAt.subtract(AuthConstants.refreshMargin));

  /// Headers for every PD / GLZ / shared call (SUMMARY §5.1).
  Map<String, String> get gameHeaders => {
    'Authorization': 'Bearer $accessToken',
    'X-Riot-Entitlements-JWT': entitlementsToken,
    'X-Riot-ClientVersion': clientVersion,
    'X-Riot-ClientPlatform': RiotClientConstants.clientPlatform,
    'User-Agent': userAgent,
  };

  RiotSession copyWith({
    String? clientVersion,
    String? userAgent,
    RiotHosts? hosts,
  }) => RiotSession(
    puuid: puuid,
    accessToken: accessToken,
    idToken: idToken,
    entitlementsToken: entitlementsToken,
    expiresAt: expiresAt,
    hosts: hosts ?? this.hosts,
    clientVersion: clientVersion ?? this.clientVersion,
    userAgent: userAgent ?? this.userAgent,
  );

  @override
  String toString() => 'RiotSession(${hosts.region}, expiresAt: $expiresAt)';
}
