import '../../helpers/l10n.dart';

import 'package:valvn/core/l10n/l10n.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/domain/economy/store_history.dart';
import 'package:valvn/features/skin_detail/store_history_line.dart';

import '../../core/domain/economy/economy_fixtures.dart';
import '../profile/profile_test_env.dart' show MemoryJsonFileCache;

class RecordingHistory extends StoreHistoryStore {
  RecordingHistory(this.history) : super(MemoryJsonFileCache());
  StoreHistory history;
  String? erasedAccount;
  int reads = 0;
  final events = StreamController<String>.broadcast();
  @override
  Stream<String> get changes => events.stream;
  @override
  Future<StoreHistory> read(String puuid) async {
    reads++;
    return history;
  }

  @override
  Future<void> delete(String puuid) async {
    erasedAccount = puuid;
    history = StoreHistory();
    events.add(puuid);
  }
}

void main() {
  Future<RecordingHistory> pumpLine(WidgetTester tester, StoreHistory h) async {
    final skin = economyContent().skinByAnyUuid(Fx.reaverVandal)!;
    final store = RecordingHistory(h);
    addTearDown(store.events.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          storeHistoryStoreProvider.overrideWithValue(store),
          accountProvider.overrideWith(
            (ref, id) => id == 'me'
                ? const Account(
                    puuid: 'me',
                    gameName: 'Tôi',
                    tagLine: '1',
                    region: 'ap',
                    shard: 'ap',
                  )
                : null,
          ),
        ],
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: StoreHistoryLine(puuid: 'me', skin: skin),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    return store;
  }

  testWidgets("one quiet line when the skin was in the account's shops", (
    tester,
  ) async {
    final skin = economyContent().skinByAnyUuid(Fx.reaverVandal)!;
    final now = DateTime.utc(2026, 9, 28);
    await pumpLine(
      tester,
      StoreHistory(
        days: [
          StoreHistoryDay(
            key: 'utc:2026-09-28',
            firstSeen: now,
            lastSeen: now,
            daily: [HistoryDailyOffer(skinLevelUuid: skin.levels.first.uuid)],
          ),
        ],
      ),
    );
    expect(find.text(tl.skinDetailSeenDaily(1)), findsOneWidget);
    // No clean-up from a skin sheet: it lives on the history page.
    expect(find.text(tl.skinDetailHistoryDelete), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('nothing at all when the skin never showed up', (tester) async {
    await pumpLine(tester, StoreHistory());
    expect(find.byType(InkWell), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('another player cannot read a retained store history file', () async {
    final store = RecordingHistory(StoreHistory());
    addTearDown(store.events.close);
    final container = ProviderContainer.test(
      overrides: [
        storeHistoryStoreProvider.overrideWithValue(store),
        accountProvider.overrideWith((ref, id) => null),
      ],
    );
    final history = await container.read(
      storeHistoryProvider('foreign').future,
    );
    expect(history.isEmpty, isTrue);
    expect(store.reads, 0);
  });
}
