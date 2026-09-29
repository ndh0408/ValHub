import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_status.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/features/home/data/home_accounts.dart';

import '../../../core/domain/economy/economy_fixtures.dart';

final _t0 = DateTime.utc(2026, 9, 28, 12);

Account _acc(int n, {bool needsLogin = false}) => Account(
  puuid: 'aaaaaaaa-0000-4000-8000-${n.toString().padLeft(12, '0')}',
  gameName: 'Alt$n',
  tagLine: 'VN$n',
  region: 'ap',
  shard: 'ap',
  needsLogin: needsLogin,
);

Storefront _store({DateTime? at}) => Storefront.fromJson(
  economyFixture('storefront.json'),
  receivedAt: at ?? _t0,
  isFromCache: true,
);

HomeOtherAccounts? _build(
  List<Account> accounts, {
  Map<String, Storefront?> stores = const {},
  Map<String, Set<String>> wishlists = const {},
  AccountActivity? Function(String)? activityOf,
  DateTime? now,
  String? active,
  int max = kHomeMaxOtherAccounts,
}) => buildOtherAccountSummaries(
  accounts: accounts,
  activePuuid: active ?? accounts.firstOrNull?.puuid,
  savedStores: stores,
  wishlists: wishlists,
  db: economyContent(),
  now: now ?? _t0,
  activityOf: activityOf,
  max: max,
);

void main() {
  test('fewer than two accounts: no card', () {
    expect(_build([_acc(1)]), isNull);
    expect(_build(const []), isNull);
  });

  test('the active account is not listed', () {
    final accounts = [_acc(1), _acc(2), _acc(3)];
    final r = _build(accounts, active: accounts[1].puuid)!;
    expect(r.rows.map((s) => s.account.gameName), ['Alt1', 'Alt3']);
    expect(r.more, 0);
  });

  test('hits come from the saved storefront while it is live', () {
    final a = [_acc(1), _acc(2), _acc(3)];
    final r = _build(
      a,
      stores: {a[1].puuid: _store(), a[2].puuid: _store()},
      wishlists: {
        a[1].puuid: {Fx.aresPrism},
        a[2].puuid: {Fx.vandalCafe}, // not on sale
      },
    )!;
    final alt2 = r.rows.firstWhere((s) => s.account.gameName == 'Alt2');
    final alt3 = r.rows.firstWhere((s) => s.account.gameName == 'Alt3');
    expect(alt2.liveHits.map((h) => h.skinUuid), [Fx.aresPrism]);
    expect(alt2.storeKnown, isTrue);
    expect(alt3.liveHits, isEmpty);
    expect(alt3.storeKnown, isTrue);
  });

  test('an expired saved store gives no hints', () {
    final a = [_acc(1), _acc(2)];
    final r = _build(
      a,
      stores: {a[1].puuid: _store()},
      wishlists: {
        a[1].puuid: {Fx.aresPrism},
      },
      // Past the daily reset (17.401 s) but before the Night Market ends:
      // only the Night Market and bundle hits could remain.
      now: _t0.add(const Duration(hours: 6)),
    )!;
    final alt2 = r.rows.single;
    expect(alt2.liveHits, isEmpty, reason: 'the daily skin is gone');
    expect(alt2.storeKnown, isFalse);

    // No saved store at all.
    final none = _build(
      a,
      wishlists: {
        a[1].puuid: {Fx.aresPrism},
      },
    )!;
    expect(none.rows.single.liveHits, isEmpty);
    expect(none.rows.single.storeKnown, isFalse);
  });

  test('order uses local signals: hits, then sign-in again, then the rest', () {
    final a = [
      _acc(1),
      _acc(2), // plain
      _acc(3, needsLogin: true),
      _acc(4), // has a hit
      _acc(5), // plain
    ];
    final r = _build(
      a,
      stores: {a[3].puuid: _store()},
      wishlists: {
        a[3].puuid: {Fx.aresPrism},
      },
    )!;
    expect(r.rows.map((s) => s.account.gameName), ['Alt4', 'Alt3', 'Alt2']);
    expect(r.more, 1);
  });

  test('activity decorates rows but never reorders them', () {
    final a = [_acc(1), _acc(2), _acc(3)];
    final quiet = _build(a)!;
    final busy = _build(
      a,
      activityOf: (p) =>
          p == a[2].puuid ? AccountActivity.inMatch : AccountActivity.offline,
    )!;
    expect(
      busy.rows.map((s) => s.account.puuid),
      quiet.rows.map((s) => s.account.puuid),
    );
    expect(busy.rows.last.activity, AccountActivity.inMatch);
    expect(quiet.rows.first.activity, isNull);
  });

  test('activity is asked only for the rows shown, never for sign-in ones', () {
    final a = [
      _acc(1),
      _acc(2, needsLogin: true),
      _acc(3),
      _acc(4),
      _acc(5),
      _acc(6),
    ];
    final asked = <String>[];
    final r = _build(
      a,
      activityOf: (p) {
        asked.add(p);
        return AccountActivity.online;
      },
    )!;
    // Rows: the sign-in account first, then Alt3 and Alt4.
    expect(r.rows.map((s) => s.account.gameName), ['Alt2', 'Alt3', 'Alt4']);
    expect(asked, [a[2].puuid, a[3].puuid]);
    expect(r.rows.first.activity, AccountActivity.needsLogin);
    expect(r.more, 2);
  });

  test('at most three rows plus a "more" count', () {
    final a = [for (var i = 1; i <= 10; i++) _acc(i)];
    final r = _build(a)!;
    expect(kHomeMaxOtherAccounts, 3);
    expect(r.rows, hasLength(3));
    expect(r.more, 6);
    expect(_build(a, max: 2)!.rows, hasLength(2));
  });
}
