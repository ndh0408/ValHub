import 'dart:math' as math;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/domain/competitive/competitive.dart';

/// Matches one "Phân tích thêm trận cũ" tap adds at most.
const kBackfillBatch = 20;

/// History pages one tap may read while looking for matches the ledger lacks
/// (the newest page is usually stored already by the sign-in warm-up).
const kBackfillMaxPages = 3;

/// Progress of [ledgerBackfillProvider].
@immutable
class LedgerBackfillState {
  const LedgerBackfillState({
    this.running = false,
    this.done = 0,
    this.target = 0,
    this.lastAdded,
    this.exhausted = false,
    this.error,
  });

  final bool running;

  /// Matches handled / to handle in the running batch.
  final int done;
  final int target;

  /// Matches the last finished run added to the analysis (`null` before the
  /// first run).
  final int? lastAdded;

  /// Riot keeps no older match for this account.
  final bool exhausted;

  /// Why the last run stopped early (shown with a retry).
  final Object? error;

  LedgerBackfillState copyWith({
    bool? running,
    int? done,
    int? target,
    int? lastAdded,
    bool? exhausted,
    Object? error,
    bool clearError = false,
  }) => LedgerBackfillState(
    running: running ?? this.running,
    done: done ?? this.done,
    target: target ?? this.target,
    lastAdded: lastAdded ?? this.lastAdded,
    exhausted: exhausted ?? this.exhausted,
    error: clearError ? null : error ?? this.error,
  );
}

/// "Phân tích thêm trận cũ" of an own account: reads the match history
/// beyond what the on-device ledger holds and opens the missing matches,
/// which records their stat lines (the same side effect as opening a match;
/// [viewerMatchDetailsProvider] keeps the ledger own-accounts-only).
///
/// Only on a tap, at most [kBackfillBatch] matches and two at a time (the
/// sign-in warm-up's pacing); disk-cached matches cost no request. Leaving
/// the screen cancels the run.
final ledgerBackfillProvider = NotifierProvider.autoDispose
    .family<LedgerBackfill, LedgerBackfillState, String>(LedgerBackfill.new);

class LedgerBackfill extends Notifier<LedgerBackfillState> {
  LedgerBackfill(String puuid) : _puuid = puuid.trim().toLowerCase();

  final String _puuid;

  /// History index the next run continues from (this screen visit).
  int _nextIndex = 0;
  CancelToken? _cancel;

  @override
  LedgerBackfillState build() {
    ref.onDispose(() => _cancel?.cancel());
    return const LedgerBackfillState();
  }

  bool get _usable =>
      ref.mounted &&
      !(_cancel?.isCancelled ?? true) &&
      ref.read(accountProvider(_puuid)) != null;

  /// Runs one batch; a second call while one runs is ignored.
  Future<void> run() async {
    if (state.running || state.exhausted) return;
    if (ref.read(accountProvider(_puuid)) == null) return;
    final cancel = _cancel = CancelToken();
    state = state.copyWith(running: true, done: 0, target: 0, clearError: true);
    try {
      final ledger = await ref.read(matchLedgerProvider(_puuid).future);
      final repo = ref.read(matchRepositoryProvider);
      final missing = <String>[];
      var exhausted = false;
      for (var page = 0; page < kBackfillMaxPages; page++) {
        if (!_usable) return;
        final start = _nextIndex;
        final MatchHistoryPage history;
        try {
          history = await repo.history(
            _puuid,
            startIndex: start,
            endIndex: start + kRiotPageSize,
            cancelToken: cancel,
          );
        } on Object catch (e) {
          if (!isPastEndError(e)) rethrow;
          exhausted = true;
          break;
        }
        var consumed = 0;
        for (final entry in history.entries) {
          if (missing.length >= kBackfillBatch) break;
          consumed++;
          if (ledger.byMatch(entry.matchId) == null) missing.add(entry.matchId);
        }
        _nextIndex = start + consumed;
        final pageDone = consumed == history.entries.length;
        if (pageDone && !history.hasMoreAfter(start)) {
          exhausted = true;
          break;
        }
        if (missing.length >= kBackfillBatch) break;
      }
      if (!_usable) return;
      state = state.copyWith(target: missing.length);
      var added = 0;
      for (var i = 0; i < missing.length; i += 2) {
        if (!_usable) return;
        final results = await Future.wait([
          for (final id in missing.skip(i).take(2)) _open(id),
        ]);
        added += results.where((ok) => ok).length;
        if (!ref.mounted) return;
        state = state.copyWith(done: math.min(i + 2, missing.length));
      }
      if (!ref.mounted) return;
      state = state.copyWith(
        running: false,
        lastAdded: added,
        exhausted: exhausted,
      );
    } on Object catch (e) {
      if (!ref.mounted) return;
      state = state.copyWith(running: false, error: e);
    }
  }

  /// Opens one match as this account (recording its ledger line); `false`
  /// when Riot has no details for it yet or the request failed.
  Future<bool> _open(String matchId) async {
    final provider = viewerMatchDetailsProvider((
      viewer: _puuid,
      matchId: matchId,
    ));
    final sub = ref.listen(provider, (_, _) {});
    try {
      await ref.read(provider.future);
      return true;
    } on Object {
      return false;
    } finally {
      sub.close();
    }
  }
}
