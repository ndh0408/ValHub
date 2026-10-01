import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/util/clock.dart';
import 'package:valvn/features/community/data/community_api.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/skin_detail/providers/community_skin_stats.dart';

class MockCommunityApi extends Mock implements CommunityApi {}

void main() {
  setUpAll(() => registerFallbackValue(<String>[]));
  test(
    'batches anonymous requests, shares inflight results and caches 30 minutes',
    () async {
      final api = MockCommunityApi();
      final clock = FixedClock(DateTime.utc(2026, 9, 30));
      final calls = <List<String>>[];
      when(() => api.skinVotes(any())).thenAnswer((inv) async {
        final ids = (inv.positionalArguments[0] as Iterable<String>).toList();
        calls.add(ids);
        return {
          for (final id in ids)
            id: SkinStats(vote: SkinVote(skinUuid: id, votes: 12)),
        };
      });
      final store = CommunitySkinStats(api, clock);
      final futures = [for (var i = 0; i < 55; i++) store.get('skin$i')];
      futures.add(store.get('SKIN1'));
      final results = await Future.wait(futures);
      expect(calls.map((c) => c.length), [50, 5]);
      expect(results.last!.vote.votes, 12);
      expect(await store.get('skin1'), same(results[1]));
      expect(calls.length, 2);
      clock.advance(const Duration(minutes: 27));
      expect(await store.get('skin1'), same(results[1]));
      expect(store.expiresIn('SKIN1'), const Duration(minutes: 3));
      expect(calls.length, 2);
      clock.advance(const Duration(minutes: 4));
      await store.get('skin1');
      expect(calls.length, 3);
      store.dispose();
    },
  );
  test(
    'network failure is hidden and pending requests complete on dispose',
    () async {
      final api = MockCommunityApi();
      when(() => api.skinVotes(any())).thenThrow(StateError('offline'));
      final store = CommunitySkinStats(api, const Clock());
      expect(await store.get('a'), isNull);
      final pending = store.get('b');
      store.dispose();
      expect(await pending, isNull);
    },
  );
}
