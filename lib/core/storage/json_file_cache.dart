import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../util/json.dart';

/// A JSON document read from [JsonFileCache].
class CachedJson {
  const CachedJson(this.data, this.savedAt);

  final Object? data;
  final DateTime savedAt;

  JsonMap? get map => asMap(data);
  List<Object?> get list => asList(data);
}

/// JSON files in the app-support directory (never the temp dir, so a cold
/// start does not re-download). Used for the content cache and for "last
/// successful response" offline caches (X4).
///
/// Keys may contain `/` to form sub-directories; every segment is sanitised.
/// Per-account data MUST live under `acct/<puuid>/…` so sign-out can wipe it
/// with [deletePrefix] (see [accountKey]).
class JsonFileCache {
  JsonFileCache(this._root);

  /// A cache rooted at `<appSupport>/<namespace>`.
  factory JsonFileCache.appSupport(String namespace) => JsonFileCache(() async {
    final base = await getApplicationSupportDirectory();
    return Directory('${base.path}/$namespace');
  });

  final Future<Directory> Function() _root;
  Directory? _resolved;

  /// Relative key prefixes whose writes are dropped (sign-out tombstones):
  /// a fetch that finishes after the account was wiped must not re-create
  /// `acct/<puuid>/…`. Lifted when the account is added back
  /// ([allowWrites]). Reads and deletions are never blocked.
  final Set<String> _blockedPrefixes = {};

  void blockWrites(String prefix) => _blockedPrefixes.add(_relative(prefix));

  void allowWrites(String prefix) => _blockedPrefixes.remove(_relative(prefix));

  bool _blocked(String relativeKey) {
    for (final prefix in _blockedPrefixes) {
      if (relativeKey == prefix || relativeKey.startsWith('$prefix/')) {
        return true;
      }
    }
    return false;
  }

  static int _tmpCounter = 0;

  /// Key for per-account data: `acct/<puuid>/<name>`.
  static String accountKey(String puuid, String name) => 'acct/$puuid/$name';

  /// Prefix of all per-account data for [puuid].
  static String accountPrefix(String puuid) => 'acct/$puuid';

  Future<Directory> _dir() async {
    final dir = _resolved ??= await _root();
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  static String _sanitize(String segment) =>
      segment.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');

  String _relative(String key) => key
      .split('/')
      .where((s) => s.isNotEmpty && s != '.' && s != '..')
      .map(_sanitize)
      .join('/');

  /// The file backing [key] (`.json` appended).
  Future<File> fileFor(String key) async {
    final dir = await _dir();
    return File('${dir.path}/${_relative(key)}.json');
  }

  /// Reads a document written with [write]. Corrupt files read as `null`.
  Future<CachedJson?> read(String key) async {
    try {
      final file = await fileFor(key);
      if (!file.existsSync()) return null;
      final envelope = asMap(tryDecodeJson(await file.readAsString()));
      if (envelope == null) return null;
      final savedAt = asInt(envelope['savedAt']);
      return CachedJson(
        envelope['data'],
        savedAt == null
            ? (await file.lastModified())
            : DateTime.fromMillisecondsSinceEpoch(savedAt),
      );
    } on FileSystemException {
      return null;
    } on FormatException {
      // Invalid UTF-8 (a torn or corrupt file) reads as "not cached".
      return null;
    }
  }

  /// Writes [data] atomically with a `savedAt` timestamp.
  Future<void> write(String key, Object? data, {DateTime? savedAt}) async {
    final at = savedAt ?? DateTime.now();
    await writeRaw(
      key,
      jsonEncode({'savedAt': at.millisecondsSinceEpoch, 'data': data}),
    );
  }

  /// Reads a raw string written with [writeRaw].
  Future<String?> readRaw(String key) async {
    try {
      final file = await fileFor(key);
      return file.existsSync() ? await file.readAsString() : null;
    } on FileSystemException {
      return null;
    } on FormatException {
      return null;
    }
  }

  /// Writes of one key run one after another (in this isolate), each through
  /// its own temp file + rename, so two writes of the same key never share
  /// (and corrupt) a temp file nor race on the rename. A write to a blocked
  /// prefix ([blockWrites]) is dropped.
  final Map<String, Future<void>> _writing = {};

  /// Writes a raw string atomically (temp file + rename).
  Future<void> writeRaw(String key, String contents) async {
    final rel = _relative(key);
    if (_blocked(rel)) return;
    final previous = _writing[rel];
    final done = Completer<void>();
    _writing[rel] = done.future;
    try {
      if (previous != null) {
        try {
          await previous;
        } on Object {
          // The earlier write failed for its own caller.
        }
      }
      // Blocked while it waited (the account was signed out meanwhile).
      if (_blocked(rel)) return;
      await _writeAtomically(key, contents);
    } finally {
      done.complete();
      if (identical(_writing[rel], done.future)) _writing.remove(rel);
    }
  }

  Future<void> _writeAtomically(String key, String contents) async {
    final file = await fileFor(key);
    await file.parent.create(recursive: true);
    final tmp = File(
      '${file.path}.${DateTime.now().microsecondsSinceEpoch}.'
      '${_tmpCounter++}.tmp',
    );
    try {
      await tmp.writeAsString(contents, flush: true);
      await tmp.rename(file.path);
    } on Object {
      try {
        if (tmp.existsSync()) await tmp.delete();
      } on Object {
        // Nothing more to clean up.
      }
      rethrow;
    }
  }

  /// Names of the sub-directories directly under [prefix] (e.g. the PUUIDs
  /// under `acct`); empty when [prefix] does not exist.
  Future<List<String>> listDirectories(String prefix) async {
    try {
      final dir = Directory('${(await _dir()).path}/${_relative(prefix)}');
      if (!dir.existsSync()) return const [];
      return [
        await for (final entity in dir.list())
          if (entity is Directory)
            entity.uri.pathSegments.lastWhere(
              (segment) => segment.isNotEmpty,
              orElse: () => '',
            ),
      ]..removeWhere((name) => name.isEmpty);
    } on FileSystemException {
      return const [];
    }
  }

  Future<bool> exists(String key) async => (await fileFor(key)).existsSync();

  Future<void> delete(String key) async {
    final file = await fileFor(key);
    if (file.existsSync()) await file.delete();
  }

  /// Deletes every entry whose key starts with [prefix] (a directory prefix
  /// such as `acct/<puuid>`, or a file prefix).
  Future<void> deletePrefix(String prefix) async {
    final dir = await _dir();
    final rel = _relative(prefix);
    final asDir = Directory('${dir.path}/$rel');
    if (asDir.existsSync()) await asDir.delete(recursive: true);
    final parent = File('${dir.path}/$rel').parent;
    if (!parent.existsSync()) return;
    final base = rel.split('/').last;
    await for (final entity in parent.list()) {
      if (entity is File && entity.uri.pathSegments.last.startsWith(base)) {
        await entity.delete();
      }
    }
  }

  /// Deletes everything in this cache.
  Future<void> clear() async {
    final dir = await _dir();
    if (dir.existsSync()) await dir.delete(recursive: true);
    await dir.create(recursive: true);
  }

  /// Total size of the cache in bytes.
  Future<int> sizeBytes() async {
    final dir = await _dir();
    var total = 0;
    await for (final entity in dir.list(recursive: true)) {
      if (entity is File) total += await entity.length();
    }
    return total;
  }
}

/// General-purpose cache (`<appSupport>/cache`). Content data uses its own
/// instance inside the content repository.
final jsonFileCacheProvider = Provider<JsonFileCache>(
  (ref) => JsonFileCache.appSupport('cache'),
);
