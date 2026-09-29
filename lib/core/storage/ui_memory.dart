import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'prefs.dart';

/// Remembers small per-screen UI choices across launches (last selected
/// segment, filter, sort order), so every screen reopens the way the user
/// left it.
///
/// Keys are `ui.<screen>.<name>` (see [PrefKeys.ui]); they are app-wide (not
/// per account) and survive sign-out. Values are plain strings; enums are
/// stored by `name`, so renaming an enum value just falls back to the
/// default.
///
/// ```dart
/// final memory = ref.read(uiMemoryProvider);
/// late var _segment = memory.readEnum('store.segment', StoreSegment.values,
///     StoreSegment.daily);
/// ...
/// memory.writeEnum('store.segment', next);
/// ```
class UiMemory {
  UiMemory(this._prefs);

  final Prefs _prefs;

  static String _key(String key) => PrefKeys.ui(key);

  String? read(String key) => _prefs.getString(_key(key));

  void write(String key, String? value) => unawaited(
    value == null
        ? _prefs.remove(_key(key))
        : _prefs.setString(_key(key), value),
  );

  /// The stored enum value, or [fallback] when absent/unknown.
  T readEnum<T extends Enum>(String key, List<T> values, T fallback) {
    final name = read(key);
    if (name == null) return fallback;
    for (final v in values) {
      if (v.name == name) return v;
    }
    return fallback;
  }

  void writeEnum(String key, Enum? value) => write(key, value?.name);

  bool readBool(String key, {bool fallback = false}) =>
      _prefs.getBool(_key(key)) ?? fallback;

  void writeBool(String key, bool value) =>
      unawaited(_prefs.setBool(_key(key), value));
}

/// App-wide [UiMemory] (reads [prefsProvider]).
final uiMemoryProvider = Provider<UiMemory>(
  (ref) => UiMemory(ref.watch(prefsProvider)),
);
