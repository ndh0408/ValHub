import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/auth/bootstrap_client.dart';
import 'package:valvn/core/riot/riot_hosts.dart';
import 'package:valvn/core/network/riot_exception.dart';

void main() {
  test('region → shard (SUMMARY §4)', () {
    expect(shardForRegion('ap'), 'ap');
    expect(shardForRegion('na'), 'na');
    expect(shardForRegion('latam'), 'na');
    expect(shardForRegion('br'), 'na');
    expect(shardForRegion('eu'), 'eu');
    expect(shardForRegion('kr'), 'kr');
    expect(shardForRegion('AP'), 'ap');
    expect(shardForRegion('pbe'), '');
    expect(shardForRegion(''), '');
  });

  test('hosts keep region and shard separate', () {
    final latam = RiotHosts.forRegion('latam');
    expect(latam.pd, 'https://pd.na.a.pvp.net');
    expect(latam.glz, 'https://glz-latam-1.na.a.pvp.net');
    expect(latam.shared, 'https://shared.na.a.pvp.net');
    final ap = RiotHosts.forRegion('ap');
    expect(ap.pd, 'https://pd.ap.a.pvp.net');
    expect(ap.glz, 'https://glz-ap-1.ap.a.pvp.net');
  });

  test('unknown or inconsistent routing never constructs a Riot host', () {
    for (final hosts in [
      RiotHosts.forRegion('pbe'),
      RiotHosts.forRegion(''),
      const RiotHosts(region: 'ap', shard: 'na'),
    ]) {
      expect(() => hosts.pd, throwsA(isA<UnsupportedRegionException>()));
      expect(() => hosts.glz, throwsA(isA<UnsupportedRegionException>()));
      expect(() => hosts.shared, throwsA(isA<UnsupportedRegionException>()));
    }
  });

  test('riot-geo affinities.live parsing', () {
    expect(
      regionFromGeo({
        'token': 'x',
        'affinities': {'pbe': 'na', 'live': 'AP'},
      }),
      'ap',
    );
    expect(regionFromGeo({'affinities': null}), isNull);
    expect(regionFromGeo('<html>'), isNull);
  });

  test('userinfo parsing', () {
    final info = RiotUserInfo.fromJson({
      'sub': 'ABC',
      'country': 'vnm',
      'acct': {'game_name': 'Tên', 'tag_line': 'VN1'},
    })!;
    expect(info.puuid, 'abc');
    expect(info.gameName, 'Tên');
    expect(info.tagLine, 'VN1');
    expect(RiotUserInfo.fromJson({'acct': <String, dynamic>{}}), isNull);
  });
}
