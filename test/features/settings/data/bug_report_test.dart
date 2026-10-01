import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/features/settings/data/bug_report.dart';

void main() {
  test(
    'share boundary hides Unicode Riot IDs and unfiltered event secrets',
    () {
      final log = SessionLog()
        ..add('http.get')
        ..add('旧玩家#ไทย password=short token=access-secret cookie=ssid-secret')
        ..add('account=41c322a1-b328-495b-a004-5ccd3e45eae8');
      addTearDown(log.dispose);
      final file = buildBugReport(
        log,
        now: DateTime(2026, 9, 30),
        version: '1.2.3',
      );
      expect(file.text, contains('http.get'));
      for (final value in [
        '旧玩家#ไทย',
        'short',
        'access-secret',
        'ssid-secret',
        '41c322a1-b328',
      ]) {
        expect(file.text, isNot(contains(value)));
      }
      expect(utf8.decode(file.bytes), file.text);
      expect(file.fileName, 'valvn-bug-report-2026-09-30.txt');
    },
  );
}
