/// P-8 v3 GET / PUT with the SUMMARY U8 safety net: fresh GET before every
/// PUT, raw-map round-trip, re-GET and `Version` comparison afterwards.
library;

import 'package:collection/collection.dart';

import '../../network/riot_exception.dart';
import '../../riot/pvp_api.dart';
import '../../util/clock.dart';
import '../../util/json.dart';
import 'loadout_changes.dart';
import 'loadout_models.dart';
import 'loadout_strings.dart';

/// What went wrong while saving.
enum LoadoutSaveFailure {
  /// A GET or the PUT failed ([LoadoutSaveException.cause] is the
  /// `RiotException`).
  request,

  /// The GET did not return a loadout (no `Guns`), so nothing was sent.
  invalidLoadout,

  /// The change does not fit the fresh loadout ([LoadoutEditException]).
  invalidChange,

  /// Riot answered 200 but the re-GET shows no new `Version` (or the change
  /// is missing): treated as rolled back (U8).
  notPersisted,
}

/// A failed loadout save. The UI shows [message] ("Không thể lưu trang
/// bị") plus the cause's description.
class LoadoutSaveException implements Exception {
  const LoadoutSaveException(this.failure, {this.cause});

  final LoadoutSaveFailure failure;

  /// `RiotException` for [LoadoutSaveFailure.request],
  /// [LoadoutEditException] for [LoadoutSaveFailure.invalidChange].
  final Object? cause;

  String get message => LoadoutStrings.saveFailed;

  /// Secondary line for the UI (null when the cause should be described by
  /// the generic error mapper, i.e. a `RiotException`).
  String? get detail => switch (failure) {
    LoadoutSaveFailure.notPersisted => LoadoutStrings.notPersisted,
    LoadoutSaveFailure.invalidChange ||
    LoadoutSaveFailure.invalidLoadout => LoadoutStrings.invalidChange,
    LoadoutSaveFailure.request => null,
  };

  /// The session is dead: offer "Đăng nhập lại".
  bool get needsLogin => cause is NeedsLoginException;

  RiotException? get riotError =>
      cause is RiotException ? cause! as RiotException : null;

  @override
  String toString() => 'LoadoutSaveException(${failure.name}, $cause)';
}

/// Reads and writes the signed-in account's loadout (P-8).
///
/// Every save:
/// 1. GETs a fresh loadout (never trusts a cached one);
/// 2. applies the [LoadoutChange] to a deep copy of the RAW map (unknown
///    keys round-trip);
/// 3. skips the PUT when nothing changed;
/// 4. PUTs the whole object;
/// 5. re-GETs and requires a higher `Version` (or, without versions, that
///    the change is visible).
class LoadoutRepository {
  LoadoutRepository(this._api, {this._clock = const Clock()});

  final PvpApi _api;
  final Clock _clock;

  /// P-8 GET. Throws `RiotException`.
  Future<LoadoutSnapshot> fetch(String puuid) async {
    final json = await _api.playerLoadout(puuid);
    return LoadoutSnapshot.fromJson(json, receivedAt: _clock.now());
  }

  /// Applies [change] (must come from an explicit user action). Returns the
  /// confirmed loadout; throws [LoadoutSaveException] only.
  Future<LoadoutSnapshot> save(String puuid, LoadoutChange change) async {
    final LoadoutSnapshot before;
    try {
      before = await fetch(puuid);
    } on RiotException catch (e) {
      throw LoadoutSaveException(LoadoutSaveFailure.request, cause: e);
    }
    if (!before.isValid) {
      throw const LoadoutSaveException(LoadoutSaveFailure.invalidLoadout);
    }

    final JsonMap body;
    try {
      body = change.appliedTo(before.raw);
    } on LoadoutEditException catch (e) {
      throw LoadoutSaveException(LoadoutSaveFailure.invalidChange, cause: e);
    }
    if (const DeepCollectionEquality().equals(body, before.raw)) return before;

    final JsonMap putResponse;
    try {
      putResponse = await _api.putPlayerLoadout(puuid, body);
    } on RiotException catch (e) {
      throw LoadoutSaveException(LoadoutSaveFailure.request, cause: e);
    }

    LoadoutSnapshot? after;
    try {
      after = await fetch(puuid);
    } on RiotException {
      after = null;
    }
    if (after == null || !after.isValid) {
      final fromPut = LoadoutSnapshot.fromJson(
        putResponse,
        receivedAt: _clock.now(),
      );
      after = fromPut.isValid ? fromPut : null;
    }
    if (after == null || !isPersisted(before.loadout, after.loadout, change)) {
      throw const LoadoutSaveException(LoadoutSaveFailure.notPersisted);
    }
    return after;
  }

  /// U8 check: a higher `Version` when both are known, else the change must
  /// be visible in [after].
  static bool isPersisted(Loadout before, Loadout after, LoadoutChange change) {
    final v0 = before.version;
    final v1 = after.version;
    if (v0 != null && v1 != null) return v1 > v0;
    return change.isReflectedIn(after);
  }
}
