import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../../core/storage/json_file_cache.dart';
import '../../../core/ui/net_image.dart' show clearMediaCache;
import '../../../core/util/format.dart';

/// Total size, in bytes, of every file under [dir] (`0` when it does not
/// exist). Files that disappear mid-scan are skipped rather than failing the
/// whole count.
Future<int> dirSizeBytes(Directory dir) async {
  if (!dir.existsSync()) return 0;
  var total = 0;
  try {
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) {
        try {
          total += await entity.length();
        } on FileSystemException {
          // Deleted mid-scan: not worth failing the whole count for.
        }
      }
    }
  } on FileSystemException {
    // The directory itself vanished mid-scan: report what was counted.
  }
  return total;
}

/// Size of the cached-image store: `flutter_cache_manager` keeps `valMedia`
/// (`core/ui/net_image.dart`) under `<temporaryDirectory>/valMedia`.
Future<int> mediaCacheSizeBytes() async {
  try {
    final base = await getTemporaryDirectory();
    return await dirSizeBytes(Directory('${base.path}/valMedia'));
  } on Object {
    return 0;
  }
}

/// `512 B`, `48 KB`, `3,2 MB`, `1,1 GB` (VF §8.12 "Xóa bộ nhớ đệm ({size})").
String formatBytes(int bytes) {
  if (bytes < 1024) return '${formatNumber(bytes < 0 ? 0 : bytes)} B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${formatNumber(kb.round())} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${_oneDecimal(mb)} MB';
  final gb = mb / 1024;
  return '${_oneDecimal(gb)} GB';
}

String _oneDecimal(double value) =>
    value.toStringAsFixed(1).replaceAll('.', ',');

/// "Xóa bộ nhớ đệm" (X2): the offline-response cache (`<appSupport>/cache`,
/// per-account `acct/<puuid>/…` copies and match details) plus the image
/// cache. Content data (valorant-api) and secrets are never touched.
class CacheService {
  CacheService({
    required this._responses,
    Future<int> Function()? mediaSizeBytes,
    Future<void> Function()? clearMedia,
  }) : _mediaSizeBytes = mediaSizeBytes ?? mediaCacheSizeBytes,
       _clearMedia = clearMedia ?? clearMediaCache;

  final JsonFileCache _responses;
  final Future<int> Function() _mediaSizeBytes;
  final Future<void> Function() _clearMedia;

  /// Combined size in bytes. A part that cannot be measured counts as `0`.
  Future<int> sizeBytes() async {
    final parts = await Future.wait([
      _safeSize(_responses.sizeBytes),
      _safeSize(_mediaSizeBytes),
    ]);
    return parts.fold<int>(0, (a, b) => a + b);
  }

  /// Clears both caches and returns how many bytes were freed. Throws only
  /// when neither cache could be cleared.
  Future<int> clear() async {
    final before = await sizeBytes();
    Object? firstError;
    var cleared = 0;
    for (final step in [_responses.clear, _clearMedia]) {
      try {
        await step();
        cleared++;
      } on Object catch (e) {
        firstError ??= e;
      }
    }
    if (cleared == 0 && firstError != null) throw firstError;
    final after = await sizeBytes();
    final freed = before - after;
    return freed < 0 ? 0 : freed;
  }

  static Future<int> _safeSize(Future<int> Function() measure) async {
    try {
      return await measure();
    } on Object {
      return 0;
    }
  }
}
