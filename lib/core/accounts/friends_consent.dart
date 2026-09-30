import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/prefs.dart';
import 'account_providers.dart';

/// Home must ask each account before connecting to Riot chat. The old
/// app-wide preference deliberately grants no consent to a new account.
final friendsLiveConsentProvider = NotifierProvider.autoDispose
    .family<FriendsLiveConsent, bool, String>(FriendsLiveConsent.new);

class FriendsLiveConsent extends Notifier<bool> {
  FriendsLiveConsent(String puuid) : _puuid = puuid.toLowerCase();
  final String _puuid;
  String get _key => PrefKeys.account(_puuid, 'home.friendsLive');

  @override
  bool build() =>
      ref.watch(accountProvider(_puuid)) != null &&
      (ref.watch(prefsProvider).getBool(_key) ?? false);

  Future<void> setConsent(bool allowed) async {
    if (await ref.read(accountRepositoryProvider).findFresh(_puuid) == null) {
      return;
    }
    await ref.read(prefsProvider).setBool(_key, allowed);
    if (ref.mounted) state = allowed;
  }
}
