import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/logging/session_log.dart';

void main() {
  test(
    'two writer files merge; later flush does not erase background events',
    () async {
      final root = await Directory.systemTemp.createTemp('log_writers');
      final ui = SessionLog(file: () async => File('${root.path}/ui.jsonl'));
      final bg = SessionLog(file: () async => File('${root.path}/bg.jsonl'));
      addTearDown(() async {
        ui.dispose();
        bg.dispose();
        await root.delete(recursive: true);
      });
      ui.add('ui.first');
      bg.add('background');
      await Future.wait([ui.flush(), bg.flush()]);
      ui.add('ui.next');
      await ui.flush();
      await ui.load();
      expect(
        ui.entries.map((e) => e.event),
        containsAll(['ui.first', 'background', 'ui.next']),
      );
      expect(
        await File('${root.path}/bg.jsonl').readAsString(),
        contains('background'),
      );
    },
  );

  test('export removes non-ASCII Riot tags', () {
    expect(SessionLog.scrubText('player Tên#日本語'), 'player {riotId}');
    expect(SessionLog.scrubText('player Игрок#ТЕСТ'), 'player {riotId}');
  });
}
