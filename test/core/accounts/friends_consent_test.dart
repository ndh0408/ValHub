import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/accounts/friends_consent.dart';
import 'package:valvn/core/storage/prefs.dart';

import '../../helpers/test_prefs.dart';

void main() {
  test('an app-wide consent never authorizes a second account', () async {
    final prefs = await createTestPrefs();
    await prefs.setBool('f.home.friendsLive', true);
    await prefs.setBool(PrefKeys.account('a', 'home.friendsLive'), true);
    final container = ProviderContainer.test(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        accountProvider('a').overrideWithValue(
          const Account(
            puuid: 'a',
            gameName: '',
            tagLine: '',
            region: 'ap',
            shard: 'ap',
          ),
        ),
        accountProvider('b').overrideWithValue(
          const Account(
            puuid: 'b',
            gameName: '',
            tagLine: '',
            region: 'ap',
            shard: 'ap',
          ),
        ),
      ],
    );
    expect(container.read(friendsLiveConsentProvider('a')), isTrue);
    expect(container.read(friendsLiveConsentProvider('b')), isFalse);
  });
}
