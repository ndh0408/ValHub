import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/features/settings/data/cache_stats.dart';

import '../settings_fakes.dart';

void main() {
  group('formatBytes', () {
    test('bytes, KB, MB, GB with Vietnamese separators', () {
      expect(formatBytes(-5), '0 B');
      expect(formatBytes(0), '0 B');
      expect(formatBytes(512), '512 B');
      expect(formatBytes(1024), '1 KB');
      expect(formatBytes(48 * 1024), '48 KB');
      expect(formatBytes(1023 * 1024), '1.023 KB');
      expect(formatBytes((3.2 * 1024 * 1024).round()), '3,2 MB');
      expect(formatBytes(32 * 1024 * 1024), '32,0 MB');
      expect(formatBytes((1.1 * 1024 * 1024 * 1024).round()), '1,1 GB');
    });

    test('other languages use their own separators', () {
      final mb = (130.5 * 1024 * 1024).round();
      expect(formatBytes(mb, locale: 'en'), '130.5 MB');
      expect(formatBytes(mb, locale: 'ja'), '130.5 MB');
      expect(formatBytes(mb, locale: 'de'), '130,5 MB');
      expect(formatBytes(1023 * 1024, locale: 'en'), '1,023 KB');
    });
  });

  group('dirSizeBytes', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('valvn_cache_stats_test');
    });

    tearDown(() async {
      if (tmp.existsSync()) await tmp.delete(recursive: true);
    });

    test('a missing directory is zero', () async {
      expect(await dirSizeBytes(Directory('${tmp.path}/nope')), 0);
    });

    test('sums every file recursively', () async {
      await File('${tmp.path}/a.json').writeAsString('123456789'); // 9 bytes
      final sub = Directory('${tmp.path}/sub')..createSync();
      await File('${sub.path}/b.json').writeAsString('12345'); // 5 bytes
      expect(await dirSizeBytes(tmp), 14);
    });
  });

  group('CacheService', () {
    test('adds the response cache and the media cache', () async {
      final files = FakeJsonFileCache()..size = 300;
      final service = CacheService(
        responses: files,
        mediaSizeBytes: () async => 700,
        clearMedia: () async {},
      );
      expect(await service.sizeBytes(), 1000);
    });

    test('a cache that cannot be measured counts as zero', () async {
      final files = FakeJsonFileCache()..size = 300;
      final service = CacheService(
        responses: files,
        mediaSizeBytes: () async => throw const FileSystemException('gone'),
        clearMedia: () async {},
      );
      expect(await service.sizeBytes(), 300);
    });

    test('clear empties both caches and returns the freed bytes', () async {
      var media = 700;
      final files = FakeJsonFileCache()..size = 300;
      final service = CacheService(
        responses: files,
        mediaSizeBytes: () async => media,
        clearMedia: () async => media = 0,
      );
      expect(await service.clear(), 1000);
      expect(files.size, 0);
      expect(media, 0);
    });

    test('clear still clears the other cache when one step fails', () async {
      final files = FakeJsonFileCache()..size = 300;
      final service = CacheService(
        responses: files,
        mediaSizeBytes: () async => 700,
        clearMedia: () async => throw const FileSystemException('locked'),
      );
      expect(await service.clear(), 300);
      expect(files.size, 0);
    });

    test('clear throws only when nothing could be cleared', () async {
      final service = CacheService(
        responses: _BrokenCache(),
        mediaSizeBytes: () async => 1,
        clearMedia: () async => throw const FileSystemException('locked'),
      );
      await expectLater(service.clear(), throwsA(isA<FileSystemException>()));
    });

    test('works on a real directory-backed cache', () async {
      final tmp = await Directory.systemTemp.createTemp('valvn_cache_svc');
      addTearDown(() => tmp.delete(recursive: true));
      final files = JsonFileCache(() async => tmp);
      await files.write('acct/p/storefront', {'a': 1});
      final service = CacheService(
        responses: files,
        mediaSizeBytes: () async => 0,
        clearMedia: () async {},
      );
      final before = await service.sizeBytes();
      expect(before, greaterThan(0));
      expect(await service.clear(), before);
      expect(await service.sizeBytes(), 0);
    });
  });
}

class _BrokenCache extends FakeJsonFileCache {
  @override
  Future<void> clear() async => throw const FileSystemException('locked');
}
