import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/riot/platform_status.dart';
import 'package:valvn/features/home/data/home_status.dart';

Map<String, dynamic> _notice(
  String id,
  String title, {
  String? status,
  String? severity,
  String update = 'Nội dung cập nhật',
}) => {
  'id': id,
  'titles': [
    {'locale': 'vi_VN', 'content': title},
  ],
  'updates': [
    {
      'translations': [
        {'locale': 'vi_VN', 'content': update},
      ],
    },
  ],
  'maintenance_status': ?status,
  'incident_severity': ?severity,
  'platforms': ['windows'],
  'created_at': '2026-09-28T01:00:00Z',
};

PlatformStatus _status({
  List<Map<String, dynamic>> maintenances = const [],
  List<Map<String, dynamic>> incidents = const [],
}) => PlatformStatus.fromJson({
  'maintenances': maintenances,
  'incidents': incidents,
});

void main() {
  test('nothing to show gives null', () {
    expect(buildHomeServerStatus(const {}, activeRegion: 'ap'), isNull);
    expect(
      buildHomeServerStatus({'ap': _status(), 'eu': null}, activeRegion: 'ap'),
      isNull,
    );
    // A finished maintenance is not a notice.
    expect(
      buildHomeServerStatus({
        'ap': _status(maintenances: [_notice('m', 'Xong', status: 'complete')]),
      }, activeRegion: 'ap'),
      isNull,
    );
  });

  test('the active region comes first, then the others', () {
    final s = buildHomeServerStatus({
      'eu': _status(incidents: [_notice('e1', 'Lỗi EU', severity: 'warning')]),
      'ap': _status(incidents: [_notice('a1', 'Lỗi AP', severity: 'info')]),
      'na': _status(incidents: [_notice('n1', 'Lỗi NA', severity: 'info')]),
    }, activeRegion: 'ap')!;
    expect(s.notices.map((n) => n.region), ['ap', 'eu', 'na']);
    expect(s.notices.first.isActiveRegion, isTrue);
    expect(s.notices.last.isActiveRegion, isFalse);
    expect(s.headline.region, 'ap');
  });

  test('notices are deduplicated by id inside a region', () {
    final s = buildHomeServerStatus({
      'ap': _status(
        maintenances: [
          _notice('x', 'Bảo trì', status: 'scheduled'),
          _notice('x', 'Bảo trì (bản sao)', status: 'scheduled'),
        ],
        incidents: [_notice('x', 'Trùng id', severity: 'info')],
      ),
    }, activeRegion: 'ap')!;
    expect(s.notices, hasLength(1));
    // The same id in another region is a different notice.
    final two = buildHomeServerStatus({
      'ap': _status(incidents: [_notice('x', 'A', severity: 'info')]),
      'eu': _status(incidents: [_notice('x', 'B', severity: 'info')]),
    }, activeRegion: 'ap')!;
    expect(two.notices, hasLength(2));
  });

  test(
    'blocking: maintenance in progress or a critical incident, active only',
    () {
      bool blocking(Map<String, PlatformStatus?> by, {String active = 'ap'}) =>
          buildHomeServerStatus(by, activeRegion: active)!.blocking;

      expect(
        blocking({
          'ap': _status(
            maintenances: [_notice('m', 'Đang', status: 'in_progress')],
          ),
        }),
        isTrue,
      );
      expect(
        blocking({
          'ap': _status(
            incidents: [_notice('i', 'Nặng', severity: 'critical')],
          ),
        }),
        isTrue,
      );
      // Scheduled maintenance and mild incidents do not block.
      expect(
        blocking({
          'ap': _status(
            maintenances: [_notice('m', 'Sắp', status: 'scheduled')],
            incidents: [_notice('i', 'Nhẹ', severity: 'warning')],
          ),
        }),
        isFalse,
      );
      // A problem in another region is visible but not blocking.
      final other = buildHomeServerStatus({
        'ap': _status(),
        'eu': _status(
          maintenances: [_notice('m', 'EU', status: 'in_progress')],
          incidents: [_notice('i', 'EU', severity: 'critical')],
        ),
      }, activeRegion: 'ap')!;
      expect(other.notices, hasLength(2));
      expect(other.blocking, isFalse);
    },
  );

  test('inside a region: in progress, critical, scheduled, then the rest', () {
    final s = buildHomeServerStatus({
      'ap': _status(
        maintenances: [
          _notice('sched', 'Sắp bảo trì', status: 'scheduled'),
          _notice('live', 'Đang bảo trì', status: 'in_progress'),
        ],
        incidents: [
          _notice('mild', 'Nhẹ', severity: 'info'),
          _notice('crit', 'Nặng', severity: 'critical'),
        ],
      ),
    }, activeRegion: 'ap')!;
    expect(s.notices.map((n) => n.notice.id), [
      'live',
      'crit',
      'sched',
      'mild',
    ]);
    expect(s.headline.isInProgress, isTrue);
  });

  test('region ids are compared without case', () {
    final s = buildHomeServerStatus({
      'AP': _status(incidents: [_notice('a', 'A', severity: 'info')]),
    }, activeRegion: 'ap')!;
    expect(s.notices.single.region, 'ap');
    expect(s.notices.single.isActiveRegion, isTrue);
  });
}
