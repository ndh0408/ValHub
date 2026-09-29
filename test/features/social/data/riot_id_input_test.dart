import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/names.dart';
import 'package:valvn/features/social/data/riot_id_input.dart';

void main() {
  test('valid Riot IDs (Vietnamese names, spaces, digits)', () {
    expect(
      parseRiotIdInput('Bạn Online#VN2'),
      const RiotName(gameName: 'Bạn Online', tagLine: 'VN2'),
    );
    expect(
      parseRiotIdInput('  Cú   Đêm  # 0001 '),
      const RiotName(gameName: 'Cú Đêm', tagLine: '0001'),
    );
    expect(parseRiotIdInput('abc#12345')?.riotId, 'abc#12345');
  });

  test('rejects missing parts and bad lengths', () {
    for (final bad in [
      '',
      'NoTag',
      '#VN1',
      'Tên#',
      'ab#VN1',
      'Tên quá dài quá dài quá#VN1',
      'Tên#VN',
      'Tên#VN1234',
      'Tên#V N1',
      'a#b#VN1',
    ]) {
      expect(parseRiotIdInput(bad), isNull, reason: bad);
    }
  });
}
