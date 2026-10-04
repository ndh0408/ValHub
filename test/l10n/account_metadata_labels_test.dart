import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/l10n/account_labels.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

class AccountProbeMessages extends AppLocalizationsVi {
  @override
  String get accountUnknownPlayer => 'Unknown player probe';
  @override
  String get accountPlatformPc => 'PC probe';
  @override
  String accountMaxAccounts(int max) => 'Limit probe $max';
}

void main() {
  const missing = Account(
    puuid: 'test-account',
    gameName: '',
    tagLine: '',
    region: '',
    shard: '',
  );

  test('unknown name stays empty in metadata and resolves at display time', () {
    expect(missing.riotId, isEmpty);
    expect(
      missing.displayRiotId(AccountProbeMessages()),
      'Unknown player probe',
    );
    expect(missing.toJson()['gameName'], '');
    expect(missing.toJson()['tagLine'], '');
  });

  test('known Unicode Riot IDs retain exact data and display values', () {
    final known = missing.copyWith(gameName: '旧玩家', tagLine: 'ไทย');
    expect(known.riotId, '旧玩家#ไทย');
    expect(known.displayRiotId(AccountProbeMessages()), '旧玩家#ไทย');
  });

  test(
    'platform and limit captions use supplied resources and keep neutral codes',
    () {
      final messages = AccountProbeMessages();
      expect(GamePlatform.pc.label(messages), 'PC probe');
      expect(GamePlatform.pc.name, 'pc');
      const error = MaxAccountsException(10);
      expect(error.message(messages), 'Limit probe 10');
      expect(error.max, 10);
      expect(error.toString(), 'MaxAccountsException(10)');
    },
  );
}
