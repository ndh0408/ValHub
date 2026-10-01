import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class ProgressObserved {
  const ProgressObserved(this.puuid);
  final String puuid;
}

final class RankObserved extends ProgressObserved {
  const RankObserved(super.puuid, this.season, this.tier);
  final String season;
  final int tier;
}

final class PassObserved extends ProgressObserved {
  const PassObserved(
    super.puuid,
    this.passId,
    this.level,
    this.total,
    this.endsAt,
  );
  final String passId;
  final int level;
  final int total;
  final DateTime? endsAt;
}

class ProgressEvents {
  final _events = StreamController<ProgressObserved>.broadcast();
  Stream<ProgressObserved> get events => _events.stream;
  void emit(ProgressObserved event) {
    if (!_events.isClosed) _events.add(event);
  }

  void dispose() => unawaited(_events.close());
}

final progressEventsProvider = Provider<ProgressEvents>((ref) {
  final events = ProgressEvents();
  ref.onDispose(events.dispose);
  return events;
});
