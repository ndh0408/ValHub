/// What the user's OWN storefronts contained on the days this device saw
/// them (PR-03). Riot exposes no past stores, so every unrecorded day is lost
/// forever: history only starts when ValVN first records it, and everything
/// derived from it must say so ("ghi nhận từ dd/MM").
///
/// Only the two personalised places are kept: the daily shop and the Night
/// Market. Featured bundles are the same for everybody and are not personal
/// history.
library;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../accounts/account_providers.dart';
import '../../storage/json_file_cache.dart';
import '../../util/json.dart';
import 'storefront.dart';

/// One daily-shop offer of a recorded rotation.
@immutable
class HistoryDailyOffer {
  const HistoryDailyOffer({required this.skinLevelUuid, this.vp});

  /// Level-1 skin uuid, as the store sells it.
  final String skinLevelUuid;

  /// VP price when Riot sent one.
  final int? vp;

  @override
  bool operator ==(Object other) =>
      other is HistoryDailyOffer &&
      other.skinLevelUuid == skinLevelUuid &&
      other.vp == vp;

  @override
  int get hashCode => Object.hash(skinLevelUuid, vp);
}

/// One Night Market offer of a recorded rotation.
@immutable
class HistoryNightOffer {
  const HistoryNightOffer({
    required this.skinLevelUuid,
    required this.bonusOfferId,
    this.basePrice,
    this.discountedPrice,
    this.percent = 0,
  });

  final String skinLevelUuid;

  /// Riot's `BonusOfferID`: unique per Night Market run and player, so it
  /// tells runs apart.
  final String bonusOfferId;
  final int? basePrice;
  final int? discountedPrice;

  /// Whole percent off (0 when unknown).
  final int percent;

  @override
  bool operator ==(Object other) =>
      other is HistoryNightOffer &&
      other.skinLevelUuid == skinLevelUuid &&
      other.bonusOfferId == bonusOfferId &&
      other.basePrice == basePrice &&
      other.discountedPrice == discountedPrice &&
      other.percent == percent;

  @override
  int get hashCode => Object.hash(
    skinLevelUuid,
    bonusOfferId,
    basePrice,
    discountedPrice,
    percent,
  );
}

/// One daily rotation as the device saw it.
@immutable
class StoreHistoryDay {
  const StoreHistoryDay({
    required this.key,
    required this.firstSeen,
    required this.lastSeen,
    this.resetsAt,
    this.daily = const [],
    this.nightMarket = const [],
  });

  /// UTC calendar day. Repeated fetches share an entry; identical offers on
  /// different days remain separate observations.
  final String key;

  /// First and last time (UTC) a fetch showed this rotation.
  final DateTime firstSeen;
  final DateTime lastSeen;

  /// The reset the fetch announced (`daily.expiresAt`), when known.
  final DateTime? resetsAt;
  final List<HistoryDailyOffer> daily;

  /// Empty while no Night Market runs.
  final List<HistoryNightOffer> nightMarket;

  /// The rotation of [store] first seen at [seenAt].
  factory StoreHistoryDay.of(Storefront store, DateTime seenAt) {
    final at = seenAt.toUtc();
    final daily = [
      for (final o in store.daily.offers)
        HistoryDailyOffer(skinLevelUuid: o.skinLevelUuid, vp: o.vpCost),
    ];
    final night = [
      for (final o in store.nightMarket?.offers ?? const <NightMarketOffer>[])
        HistoryNightOffer(
          skinLevelUuid: o.skinLevelUuid,
          bonusOfferId: o.bonusOfferId,
          basePrice: o.basePrice,
          discountedPrice: o.discountedPrice,
          percent: o.discountPercent,
        ),
    ];
    return StoreHistoryDay(
      key: rotationKey(daily, at),
      firstSeen: at,
      lastSeen: at,
      resetsAt: store.daily.expiresAt?.toUtc(),
      daily: List.unmodifiable(daily),
      nightMarket: List.unmodifiable(night),
    );
  }

  /// `utc:2026-09-28`, independent of the offered skins.
  static String rotationKey(List<HistoryDailyOffer> daily, DateTime at) {
    final d = at.toUtc();
    return 'utc:${d.year}-${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  /// This rotation seen again at [seenAt]: the newest contents win (a Night
  /// Market may have started or been revealed since).
  StoreHistoryDay seenAgain(StoreHistoryDay incoming) {
    final newer = incoming.lastSeen.isBefore(lastSeen) ? this : incoming;
    final older = identical(newer, this) ? incoming : this;
    return StoreHistoryDay(
      key: key,
      firstSeen: firstSeen.isBefore(incoming.firstSeen)
          ? firstSeen
          : incoming.firstSeen,
      lastSeen: newer.lastSeen,
      resetsAt: newer.resetsAt ?? older.resetsAt,
      daily: newer.daily.isEmpty ? older.daily : newer.daily,
      nightMarket: newer.nightMarket.isEmpty
          ? older.nightMarket
          : newer.nightMarket,
    );
  }

  bool get hasNightMarket => nightMarket.isNotEmpty;

  @override
  bool operator ==(Object other) =>
      other is StoreHistoryDay &&
      other.key == key &&
      other.firstSeen == firstSeen &&
      other.lastSeen == lastSeen &&
      other.resetsAt == resetsAt &&
      listEquals(other.daily, daily) &&
      listEquals(other.nightMarket, nightMarket);

  @override
  int get hashCode => Object.hash(
    key,
    firstSeen,
    lastSeen,
    resetsAt,
    Object.hashAll(daily),
    Object.hashAll(nightMarket),
  );
}

/// The recorded days of one account, newest first.
@immutable
class StoreHistory {
  StoreHistory({List<StoreHistoryDay> days = const []})
    : days = List<StoreHistoryDay>.unmodifiable(
        <StoreHistoryDay>[...days]
          ..sort((a, b) => b.firstSeen.compareTo(a.firstSeen)),
      );

  final List<StoreHistoryDay> days;

  bool get isEmpty => days.isEmpty;

  /// Rotations recorded.
  int get daysRecorded => days.length;

  /// When the oldest recorded rotation was first seen ("ghi nhận từ …").
  DateTime? get recordingSince => days.isEmpty ? null : days.last.firstSeen;

  /// What the history says about a skin whose levels are [levelUuids]
  /// (lowercase): the store sells level 1, but any level uuid is accepted.
  SkinStoreHistory? forSkin(Iterable<String> levelUuids) =>
      isEmpty ? null : summarizeSkin(this, levelUuids);
}

/// How often and when one skin showed up in the user's own store.
@immutable
class SkinStoreHistory {
  const SkinStoreHistory({
    required this.dailyDays,
    required this.nightMarketRuns,
    required this.recordingSince,
    required this.daysRecorded,
    this.firstSeen,
    this.lastSeen,
    this.lastDaily,
    this.lastNightMarket,
    this.lastDailyVp,
    this.lastNightPercent,
    this.lastNightPrice,
  });

  /// Daily rotations the skin was in.
  final int dailyDays;

  /// Distinct Night Market runs the skin was in.
  final int nightMarketRuns;

  /// Start of the recording and how many rotations it holds: the skin's
  /// absence only means something inside this window.
  final DateTime? recordingSince;
  final int daysRecorded;
  final DateTime? firstSeen;
  final DateTime? lastSeen;
  final DateTime? lastDaily;
  final DateTime? lastNightMarket;
  final int? lastDailyVp;

  /// Percent off and discounted price in the newest Night Market run.
  final int? lastNightPercent;
  final int? lastNightPrice;

  /// Times the skin was offered: daily rotations plus Night Market runs.
  int get appearances => dailyDays + nightMarketRuns;

  bool get everSeen => appearances > 0;
}

/// Aggregates [history] for a skin (pure; the caller formats the dates).
SkinStoreHistory summarizeSkin(StoreHistory history, Iterable<String> levels) {
  final ids = {for (final l in levels) l.toLowerCase()};
  var dailyDays = 0;
  final runs = <String>{};
  DateTime? first;
  DateTime? last;
  DateTime? lastDaily;
  DateTime? lastNight;
  int? lastVp;
  int? lastPercent;
  int? lastNightPrice;
  DateTime? lastNightRunAt;

  void touch(DateTime at) {
    if (first == null || at.isBefore(first!)) first = at;
    if (last == null || at.isAfter(last!)) last = at;
  }

  for (final day in history.days) {
    final d = day.daily.where((o) => ids.contains(o.skinLevelUuid));
    if (d.isNotEmpty) {
      dailyDays++;
      touch(day.firstSeen);
      touch(day.lastSeen);
      if (lastDaily == null || day.lastSeen.isAfter(lastDaily)) {
        lastDaily = day.lastSeen;
        lastVp = d.first.vp;
      }
    }
    for (final o in day.nightMarket) {
      if (!ids.contains(o.skinLevelUuid)) continue;
      runs.add(o.bonusOfferId);
      touch(day.firstSeen);
      touch(day.lastSeen);
      if (lastNight == null || day.lastSeen.isAfter(lastNight)) {
        lastNight = day.lastSeen;
      }
      if (lastNightRunAt == null || day.lastSeen.isAfter(lastNightRunAt)) {
        lastNightRunAt = day.lastSeen;
        lastPercent = o.percent > 0 ? o.percent : null;
        lastNightPrice = o.discountedPrice;
      }
    }
  }
  return SkinStoreHistory(
    dailyDays: dailyDays,
    nightMarketRuns: runs.length,
    recordingSince: history.recordingSince,
    daysRecorded: history.daysRecorded,
    firstSeen: first,
    lastSeen: last,
    lastDaily: lastDaily,
    lastNightMarket: lastNight,
    lastDailyVp: lastVp,
    lastNightPercent: lastPercent,
    lastNightPrice: lastNightPrice,
  );
}

/// Persists [StoreHistory] per PUUID, append-only.
///
/// Stored as `acct/<puuid>/store_history` in the `history` namespace: never
/// touched by "Xóa bộ nhớ đệm" (it is the user's own record, not a cache),
/// erased by [delete] (Settings "Xóa lịch sử", sign-out without keeping local
/// data). At most [maxDays] rotations are kept (oldest dropped: about a year).
/// Only own accounts are recorded: callers pass the PUUID of a signed-in
/// account.
///
/// Every [record] reads the file again before writing, so the UI isolate and
/// the background check (another isolate) do not overwrite each other's days.
class StoreHistoryStore {
  StoreHistoryStore(this._files, {this.maxDays = 365});

  /// The store on the app's history directory (usable from a background
  /// isolate, which has no Riverpod).
  factory StoreHistoryStore.onDevice() =>
      StoreHistoryStore(JsonFileCache.appSupport('history'));

  final JsonFileCache _files;
  final int maxDays;

  final Map<String, Future<void>> _locks = {};
  final StreamController<String> _changes = StreamController.broadcast();

  static const schema = 1;

  static String key(String puuid) =>
      'acct/${puuid.trim().toLowerCase()}/store_history';

  /// Emits the PUUID whose history changed.
  Stream<String> get changes => _changes.stream;

  static String _id(String puuid) => puuid.trim().toLowerCase();

  /// The recorded history of [puuid] (empty when nothing was recorded).
  Future<StoreHistory> read(String puuid) {
    final id = _id(puuid);
    return _locked(id, () => _load(id));
  }

  /// Records what [store] contained when it was fetched (at [seenAt]).
  ///
  /// - A rotation already recorded is updated in place (one day, however
  ///   many fetches); a new one is added.
  /// - A store served from the offline cache is never recorded: it says
  ///   nothing about today.
  /// - An empty store (no daily offers, no Night Market) is not recorded.
  ///
  /// Returns whether anything changed.
  Future<bool> record(String puuid, Storefront store, DateTime seenAt) {
    final id = _id(puuid);
    if (id.isEmpty || store.isFromCache) return Future.value(false);
    final incoming = StoreHistoryDay.of(store, seenAt);
    if (incoming.daily.isEmpty && incoming.nightMarket.isEmpty) {
      return Future.value(false);
    }
    return _locked(id, () async {
      final current = await _load(id);
      final days = [...current.days];
      final i = days.indexWhere((d) => d.key == incoming.key);
      if (i >= 0) {
        final merged = days[i].seenAgain(incoming);
        if (merged == days[i]) return false;
        days[i] = merged;
      } else {
        days.add(incoming);
      }
      days.sort((a, b) => b.firstSeen.compareTo(a.firstSeen));
      final kept = days.length > maxDays ? days.sublist(0, maxDays) : days;
      await _save(id, StoreHistory(days: kept));
      return true;
    });
  }

  /// Erases the history of [puuid].
  Future<void> delete(String puuid) {
    final id = _id(puuid);
    return _locked(id, () async {
      try {
        await _files.delete(key(id));
      } on Object {
        // Nothing stored or storage unavailable.
      }
      _emit(id);
    });
  }

  void dispose() => unawaited(_changes.close());

  // ---------------------------------------------------------------- internals

  Future<T> _locked<T>(String id, Future<T> Function() body) async {
    final previous = _locks[id];
    final done = Completer<void>();
    _locks[id] = done.future;
    try {
      if (previous != null) await previous;
      final path = await _files.fileFor(key(id));
      await path.parent.create(recursive: true);
      final lock = await File('${path.path}.lock').open(mode: FileMode.append);
      try {
        for (var attempt = 0; ; attempt++) {
          try {
            await lock.lock(FileLock.exclusive);
            break;
          } on FileSystemException {
            if (attempt >= 100) rethrow;
            await Future<void>.delayed(const Duration(milliseconds: 20));
          }
        }
        try {
          return await body();
        } finally {
          await lock.unlock();
        }
      } finally {
        await lock.close();
      }
    } finally {
      done.complete();
      _locks.removeWhere((k, f) => k == id && identical(f, done.future));
    }
  }

  Future<StoreHistory> _load(String id) async {
    try {
      return decode((await _files.read(key(id)))?.data);
    } on Object {
      return StoreHistory();
    }
  }

  Future<void> _save(String id, StoreHistory history) async {
    try {
      await _files.write(key(id), encode(history));
    } on Object {
      // Storage unavailable: this rotation is simply not remembered.
    }
    _emit(id);
  }

  void _emit(String id) {
    if (!_changes.isClosed) _changes.add(id);
  }

  // ------------------------------------------------------------------ codec

  static const _none = -1;

  /// `{"v":1,"days":[{"k":key,"t":firstSeenMs,"u":lastSeenMs,"r":resetMs,
  /// "d":[[uuid, vp], …],"n":[[uuid, bonusId, base, discounted, percent], …]},
  /// …]}`, newest first; `-1` stands for an unknown price.
  @visibleForTesting
  static JsonMap encode(StoreHistory h) => {
    'v': schema,
    'days': [
      for (final d in h.days)
        {
          'k': d.key,
          't': d.firstSeen.millisecondsSinceEpoch,
          'u': d.lastSeen.millisecondsSinceEpoch,
          'r': ?d.resetsAt?.millisecondsSinceEpoch,
          'd': [
            for (final o in d.daily) [o.skinLevelUuid, o.vp ?? _none],
          ],
          if (d.nightMarket.isNotEmpty)
            'n': [
              for (final o in d.nightMarket)
                [
                  o.skinLevelUuid,
                  o.bonusOfferId,
                  o.basePrice ?? _none,
                  o.discountedPrice ?? _none,
                  o.percent,
                ],
            ],
        },
    ],
  };

  /// Parses [encode]'s output; corrupt input gives an empty history and
  /// entries that do not parse are dropped (never throws).
  @visibleForTesting
  static StoreHistory decode(Object? json) {
    final m = asMap(json);
    if (m == null || asInt(m['v']) != schema) return StoreHistory();
    final seen = <String>{};
    final days = <StoreHistoryDay>[];
    for (final raw in asList(m['days'])) {
      final e = asMap(raw);
      final key = asNonEmptyString(e?['k']);
      final first = asInt(e?['t']);
      final last = asInt(e?['u']);
      if (e == null ||
          key == null ||
          first == null ||
          first <= 0 ||
          !seen.add(key)) {
        continue;
      }
      DateTime at(int ms) =>
          DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
      int? price(Object? v) {
        final n = asInt(v);
        return n == null || n < 0 ? null : n;
      }

      final daily = <HistoryDailyOffer>[];
      for (final o in asList(e['d'])) {
        final row = asList(o);
        final id = row.isEmpty ? null : lowerUuid(row[0]);
        if (id == null) continue;
        daily.add(
          HistoryDailyOffer(
            skinLevelUuid: id,
            vp: row.length > 1 ? price(row[1]) : null,
          ),
        );
      }
      final night = <HistoryNightOffer>[];
      for (final o in asList(e['n'])) {
        final row = asList(o);
        final id = row.isEmpty ? null : lowerUuid(row[0]);
        final bonus = row.length > 1 ? asNonEmptyString(row[1]) : null;
        if (id == null || bonus == null) continue;
        night.add(
          HistoryNightOffer(
            skinLevelUuid: id,
            bonusOfferId: bonus,
            basePrice: row.length > 2 ? price(row[2]) : null,
            discountedPrice: row.length > 3 ? price(row[3]) : null,
            percent: row.length > 4 ? (asInt(row[4]) ?? 0).clamp(0, 100) : 0,
          ),
        );
      }
      final reset = asInt(e['r']);
      days.add(
        StoreHistoryDay(
          key: key,
          firstSeen: at(first),
          lastSeen: at(last == null || last < first ? first : last),
          resetsAt: reset == null || reset <= 0 ? null : at(reset),
          daily: List.unmodifiable(daily),
          nightMarket: List.unmodifiable(night),
        ),
      );
    }
    return StoreHistory(days: days);
  }
}

/// The app-wide [StoreHistoryStore] (`<appSupport>/history`).
final storeHistoryStoreProvider = Provider<StoreHistoryStore>((ref) {
  final store = StoreHistoryStore.onDevice();
  ref.onDispose(store.dispose);
  return store;
});

/// The recorded store history of an own account (family key = PUUID).
/// Refreshes whenever a rotation is recorded or the history is deleted.
/// Never calls Riot.
final storeHistoryProvider = FutureProvider.autoDispose
    .family<StoreHistory, String>((ref, puuid) {
      final id = puuid.trim().toLowerCase();
      final store = ref.watch(storeHistoryStoreProvider);
      final sub = store.changes
          .where((changed) => changed == id)
          .listen((_) => ref.invalidateSelf());
      ref.onDispose(sub.cancel);
      return store.read(id);
    });

/// Records a live storefront of [puuid] (called after every fetch): only for
/// signed-in accounts, never from an offline copy, never throws.
Future<void> recordStoreHistoryFor(
  Ref ref,
  String puuid,
  Storefront store,
  DateTime seenAt,
) async {
  try {
    if (store.isFromCache || ref.read(accountProvider(puuid)) == null) return;
    await ref.read(storeHistoryStoreProvider).record(puuid, store, seenAt);
  } on Object {
    // History is a bonus: a failure never breaks the store screen.
  }
}
