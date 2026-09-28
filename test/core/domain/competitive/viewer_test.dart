import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/competitive/viewer.dart';

void main() {
  test('queueForPlatform adds the console prefix only when needed', () {
    expect(queueForPlatform('competitive', console: false), 'competitive');
    expect(
      queueForPlatform('Competitive', console: true),
      'console_competitive',
    );
    expect(
      queueForPlatform('console_unrated', console: true),
      'console_unrated',
    );
    expect(queueForPlatform(null, console: true), isNull);
    expect(queueForPlatform('', console: true), '');
  });

  test('baseQueueId strips the console prefix', () {
    expect(baseQueueId('console_deathmatch'), 'deathmatch');
    expect(baseQueueId(' HURM '), 'hurm');
    expect(baseQueueId(null), '');
  });
}
