import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/storage/prefs.dart';

/// The user's decision about sharing their Riot ID with the community
/// server (asked once per account, before the first `POST /v1/auth/riot`).
enum CommunityConsent {
  /// Never asked.
  unknown,

  /// Agreed: the Riot access token may be sent once to verify the Riot ID.
  granted,

  /// Asked and declined ("Để sau"): nothing is sent; the Community tab
  /// offers to review the terms again.
  declined,
}

/// Pref key (wiped with the account: `acct.<puuid>.community.consent`).
String communityConsentKey(String puuid) =>
    PrefKeys.account(puuid.toLowerCase(), 'community.consent');

/// Consent of one account, persisted in [Prefs] under `acct.<puuid>.*` so
/// signing the account out wipes it.
final communityConsentProvider =
    NotifierProvider.family<CommunityConsentNotifier, CommunityConsent, String>(
      CommunityConsentNotifier.new,
    );

class CommunityConsentNotifier extends Notifier<CommunityConsent> {
  CommunityConsentNotifier(this.puuid);

  final String puuid;

  @override
  CommunityConsent build() {
    // Removing / re-adding the account re-reads the (wiped) pref.
    ref.watch(accountProvider(puuid.toLowerCase()).select((a) => a != null));
    return switch (ref
        .read(prefsProvider)
        .getString(communityConsentKey(puuid))) {
      'granted' => CommunityConsent.granted,
      'declined' => CommunityConsent.declined,
      _ => CommunityConsent.unknown,
    };
  }

  Future<void> grant() => _set(CommunityConsent.granted, 'granted');

  Future<void> decline() => _set(CommunityConsent.declined, 'declined');

  Future<void> _set(CommunityConsent value, String stored) async {
    state = value;
    await ref.read(prefsProvider).setString(communityConsentKey(puuid), stored);
  }
}
