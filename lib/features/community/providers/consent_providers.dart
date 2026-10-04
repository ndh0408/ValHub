import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/storage/prefs.dart';
import '../data/consent_version.dart';
export '../data/consent_version.dart' show communityConsentVersion;

/// The user's decision about sharing their Riot ID with the community
/// server (explicit approval per account and policy version, after login).
enum CommunityConsent {
  /// Never asked.
  unknown,

  /// Agreed: transient Riot identity and review ownership checks are permitted.
  granted,

  /// Declined: no Community credentials are sent; the app requires approval
  /// or signing out before protected routes can resume.
  declined,
}

/// Pref key (wiped with the account: `acct.<puuid>.community.consent`).

String communityConsentVersionKey(String puuid) =>
    PrefKeys.account(puuid.toLowerCase(), 'community.consentVersion');
String communityConsentAtKey(String puuid) =>
    PrefKeys.account(puuid.toLowerCase(), 'community.consentAt');

String communityConsentKey(String puuid) =>
    PrefKeys.account(puuid.toLowerCase(), 'community.consent');

/// Consent of one account, persisted in [Prefs] under `acct.<puuid>.*` so
/// signing the account out wipes it.
final communityConsentProvider =
    NotifierProvider.family<CommunityConsentNotifier, CommunityConsent, String>(
      CommunityConsentNotifier.new,
    );

/// New login, existing-account upgrade, switching and withdrawal all use the
/// same versioned decision; no separate onboarding flag can drift out of sync.
final accountRequiresConsentProvider = Provider<bool>((ref) {
  final account = ref.watch(activeAccountProvider);
  return account != null &&
      ref.watch(communityConsentProvider(account.puuid)) !=
          CommunityConsent.granted;
});

class CommunityConsentNotifier extends Notifier<CommunityConsent> {
  CommunityConsentNotifier(this.puuid);

  final String puuid;
  Future<void> _writes = Future<void>.value();
  int _decision = 0;

  Future<void> _queue(Future<void> Function() write) {
    final result = _writes.then((_) => write());
    _writes = result.then<void>((_) {}, onError: (Object _) {});
    return result;
  }

  @override
  CommunityConsent build() {
    _decision++;
    // Removing / re-adding the account re-reads the (wiped) pref.
    ref.watch(accountProvider(puuid.toLowerCase()).select((a) => a != null));
    return switch (ref
        .read(prefsProvider)
        .getString(communityConsentKey(puuid))) {
      'granted' =>
        ref.read(prefsProvider).getString(communityConsentVersionKey(puuid)) ==
                communityConsentVersion
            ? CommunityConsent.granted
            : CommunityConsent.unknown,
      'declined' => CommunityConsent.declined,
      _ => CommunityConsent.unknown,
    };
  }

  Future<void> grant() => _set(CommunityConsent.granted, 'granted');

  Future<void> decline() => _set(CommunityConsent.declined, 'declined');

  /// Withdraws the decision altogether ("Rút lại đồng ý"): the account is
  /// back to "never asked" and the router requires explicit approval again.
  Future<void> revoke() async {
    _decision++;
    state = CommunityConsent.unknown;
    final prefs = ref.read(prefsProvider);
    await _queue(() async {
      await prefs.remove(communityConsentKey(puuid));
      await prefs.remove(communityConsentVersionKey(puuid));
      await prefs.remove(communityConsentAtKey(puuid));
    });
  }

  Future<void> _set(CommunityConsent value, String stored) async {
    final prefs = ref.read(prefsProvider);
    final decision = ++_decision;
    await _queue(() async {
      if (!ref.mounted || decision != _decision) return;
      if (value == CommunityConsent.granted) {
        await prefs.setString(
          communityConsentVersionKey(puuid),
          communityConsentVersion,
        );
        await prefs.setString(
          communityConsentAtKey(puuid),
          DateTime.now().toUtc().toIso8601String(),
        );
      }
      await prefs.setString(communityConsentKey(puuid), stored);
      if (ref.mounted && decision == _decision) state = value;
    });
  }
}
