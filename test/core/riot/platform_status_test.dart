import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/riot/platform_status.dart';

Map<String, Object?> _notice(String id, {String? status, String? severity}) => {
  'id': id,
  'maintenance_status': ?status,
  'incident_severity': ?severity,
  'titles': [
    {'locale': 'en_US', 'content': 'EN $id'},
    {'locale': 'ja_JP', 'content': 'JA $id'},
  ],
  'updates': [
    {
      'translations': [
        {'locale': 'en_US', 'content': 'EN update $id'},
      ],
    },
  ],
};

void main() {
  test('titles follow the app language, then English', () {
    final status = PlatformStatus.fromJson({
      'maintenances': [_notice('m', status: 'in_progress')],
    }, locale: 'ja_JP');
    final m = status.maintenances.single;
    expect(m.title, 'JA m');
    expect(m.message, 'EN update m', reason: 'no ja_JP update: English');
    expect(
      PlatformStatus.fromJson({
        'maintenances': [_notice('m', status: 'in_progress')],
      }, locale: 'vi_VN').maintenances.single.title,
      'EN m',
    );
  });

  test('the banner shows only work in progress or a serious incident', () {
    PlatformStatus parse(List<Object?> m, List<Object?> i) =>
        PlatformStatus.fromJson({'maintenances': m, 'incidents': i});

    expect(
      parse(
        [
          _notice('done', status: 'complete'),
          _notice('soon', status: 'scheduled'),
        ],
        [_notice('fyi', severity: 'info')],
      ).headline,
      isNull,
    );
    expect(parse([], [_notice('w', severity: 'warning')]).headline?.id, 'w');
    expect(
      parse(
        [_notice('now', status: 'in_progress')],
        [_notice('c', severity: 'critical')],
      ).headline?.id,
      'now',
    );
  });
}
