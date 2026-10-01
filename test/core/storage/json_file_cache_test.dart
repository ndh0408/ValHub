import 'dart:io';
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/storage/json_file_cache.dart';

import '../../helpers/temp_dir.dart';

void main() {
  late Directory tmp;
  late JsonFileCache cache;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('valvn_jfc');
    cache = JsonFileCache(() async => tmp);
  });

  tearDown(() => deleteTempDir(tmp));

  List<String> leftovers() => [
    for (final e in tmp.listSync(recursive: true))
      if (e is File && e.path.endsWith('.tmp')) e.path,
  ];

  test('write / read round trip keeps the timestamp', () async {
    final at = DateTime(2026, 9, 30, 12);
    await cache.write('a/b', {'x': 1}, savedAt: at);
    final read = await cache.read('a/b');
    expect(read!.map, {'x': 1});
    expect(read.savedAt, at);
  });

  group('atomic writes (AR-029)', () {
    test('concurrent writes of one key never share a temp file', () async {
      await Future.wait([
        for (var i = 0; i < 25; i++) cache.write('k', {'n': i}),
      ]);
      final read = await cache.read('k');
      expect(read, isNotNull, reason: 'the file is intact JSON');
      expect(read!.map!['n'], isA<int>());
      expect(leftovers(), isEmpty);
    });

    test('a failed write leaves no temp file behind', () async {
      await cache.write('dir/k', {'ok': true});
      // A directory where the target file should go makes the rename fail.
      final blocker = Directory('${tmp.path}/blocked.json')..createSync();
      addTearDown(() => blocker.deleteSync(recursive: true));
      await expectLater(cache.writeRaw('blocked', 'x'), throwsA(anything));
      expect(leftovers(), isEmpty);
    });
  });

  group('corrupt files read as absent', () {
    test('invalid JSON', () async {
      await cache.writeRaw('bad', '{not json');
      expect(await cache.read('bad'), isNull);
    });

    test('invalid UTF-8 (FormatException)', () async {
      final file = await cache.fileFor('utf8');
      await file.parent.create(recursive: true);
      await file.writeAsBytes([0x7b, 0xff, 0xfe, 0x7d]);
      expect(await cache.read('utf8'), isNull);
      expect(await cache.readRaw('utf8'), isNull);
    });
  });

  group('blocked prefixes (sign-out tombstones)', () {
    test('a wipe drains a write already waiting for its directory', () async {
      final root = Completer<Directory>();
      cache = JsonFileCache(() => root.future);
      final writing = cache.write('acct/p1/wallet', {'vp': 1});
      cache.blockWrites('acct/p1');
      final wiping = cache.deletePrefix('acct/p1');
      root.complete(tmp);
      await Future.wait([writing, wiping]);
      expect(await cache.exists('acct/p1/wallet'), isFalse);
      expect(leftovers(), isEmpty);
    });

    test('writes under a blocked prefix are dropped', () async {
      cache.blockWrites('acct/p1');
      await cache.write('acct/p1/wallet', {'vp': 1});
      await cache.writeRaw('acct/p1/x', 'x');
      await cache.write('acct/p2/wallet', {'vp': 2});
      expect(await cache.exists('acct/p1/wallet'), isFalse);
      expect(await cache.exists('acct/p1/x'), isFalse);
      expect(await cache.exists('acct/p2/wallet'), isTrue);
    });

    test('a similar prefix is not blocked; allowWrites lifts it', () async {
      cache.blockWrites('acct/p1');
      await cache.write('acct/p10/wallet', {'vp': 1});
      expect(await cache.exists('acct/p10/wallet'), isTrue);
      cache.allowWrites('acct/p1');
      await cache.write('acct/p1/wallet', {'vp': 1});
      expect(await cache.exists('acct/p1/wallet'), isTrue);
    });

    test('deleting still works while blocked', () async {
      await cache.write('acct/p1/a', {'x': 1});
      cache.blockWrites('acct/p1');
      await cache.deletePrefix('acct/p1');
      expect(await cache.exists('acct/p1/a'), isFalse);
    });
  });

  group('listDirectories', () {
    test('lists only the sub-directories', () async {
      await cache.write('acct/p1/a', {'x': 1});
      await cache.write('acct/p2/a', {'x': 1});
      await cache.write('acct/loose', {'x': 1}); // a file, not a directory
      expect((await cache.listDirectories('acct'))..sort(), ['p1', 'p2']);
    });

    test('a missing prefix is empty', () async {
      expect(await cache.listDirectories('nope'), isEmpty);
    });
  });
}
