import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account_link_guard.dart';

void main() {
  test('unknown account stays put and login is deferred', () {
    expect(
      accountLinkDecision(
        accountPuuid: 'gone',
        signedIn: ['a'],
        currentPath: '/home',
      ),
      AccountLinkDecision.unknownAccount,
    );
    expect(
      accountLinkDecision(
        accountPuuid: 'a',
        signedIn: ['a'],
        currentPath: '/login',
      ),
      AccountLinkDecision.deferLogin,
    );
    expect(
      accountLinkDecision(
        accountPuuid: 'A',
        signedIn: ['a'],
        currentPath: '/home',
      ),
      AccountLinkDecision.open,
    );
  });
}
