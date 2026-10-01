import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/util/clock.dart';

import '../../helpers/jwt.dart';

void main() {
  test('URIs become host + path templates without ids or secrets', () {
    expect(
      SessionLog.scrubUri(
        Uri.parse(
          'https://pd.ap.a.pvp.net/store/v3/storefront/41c322a1-b328-495b-a004-5ccd3e45eae8',
        ),
      ),
      'pd.ap.a.pvp.net/store/v3/storefront/{id}',
    );
    expect(
      SessionLog.scrubUri(
        Uri.parse(
          'https://pd.ap.a.pvp.net/match-history/v1/history/41C322A1-B328-495B-A004-5CCD3E45EAE8'
          '?startIndex=0&endIndex=20&queue=competitive&token=abc',
        ),
      ),
      'pd.ap.a.pvp.net/match-history/v1/history/{id}?startIndex=0&endIndex=20&queue=competitive',
    );
    expect(
      SessionLog.scrubUri(
        Uri.parse(
          'https://glz-ap-1.ap.a.pvp.net/parties/v1/parties/p/invites/name/T%C3%AAn/tag/VN1',
        ),
      ),
      'glz-ap-1.ap.a.pvp.net/parties/v1/parties/p/invites/name/{name}/tag/{tag}',
    );
    expect(
      SessionLog.scrubUri(
        Uri.parse('https://auth.riotgames.com/authorize?nonce=1&prompt=none'),
      ),
      'auth.riotgames.com/authorize',
    );
  });

  test('free text is scrubbed of JWTs, cookies, uuids and Riot IDs', () {
    final jwt = fakeJwt({'sub': 'x'});
    final text = SessionLog.scrubText(
      'token $jwt cookie ssid=abcdef; tdid=zzz puuid 41c322a1-b328-495b-a004-5ccd3e45eae8 player Tên#VN1 '
      'blob ${'A' * 40}',
    );
    expect(text, isNot(contains(jwt)));
    expect(text, isNot(contains('abcdef')));
    expect(text, isNot(contains('41c322a1')));
    expect(text, isNot(contains('Tên#VN1')));
    expect(text, isNot(contains('A' * 40)));
  });

  test('ring buffer keeps the newest entries and exports text', () {
    final log = SessionLog(
      capacity: 3,
      clock: FixedClock(DateTime(2026, 9, 28, 14, 5, 9)),
    );
    for (var i = 0; i < 5; i++) {
      log.add('e$i');
    }
    expect(log.entries.map((e) => e.event), ['e2', 'e3', 'e4']);
    log.http(
      'GET',
      Uri.parse('https://pd.ap.a.pvp.net/store/v1/wallet/abc'),
      status: 200,
      elapsed: const Duration(milliseconds: 312),
    );
    final text = log.exportText(header: 'VanHub');
    expect(text, startsWith('VanHub\n'));
    expect(
      text,
      contains(
        '2026-09-28 14:05:09  http.get  200  312ms  pd.ap.a.pvp.net/store/v1/wallet/abc',
      ),
    );
  });

  test('entries round-trip through JSON', () {
    final e = SessionLogEntry(
      time: DateTime(2026),
      event: 'x',
      target: 't',
      status: 1,
      ms: 2,
      detail: 'd',
    );
    final back = SessionLogEntry.fromJson(e.toJson())!;
    expect(back.toLine(), e.toLine());
    expect(SessionLogEntry.fromJson({'bad': true}), isNull);
  });
}
