import 'package:valvn/core/l10n/l10n.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/domain/economy/store_history.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/features/skin_detail/skin_detail_strings.dart';
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
  testWidgets(
    'only stored observations appear; deletion is confirmed and account-scoped',
    (tester) async {
      final skin = economyContent().skinByAnyUuid(Fx.reaverVandal)!;
      final now = DateTime.utc(2026, 9, 28);
      final store = RecordingHistory(
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
      expect(
        find.textContaining('Trong cửa hàng của bạn: 1 lần'),
        findsOneWidget,
      );
      await tester.tap(find.text(SkinDetailStrings.historyDelete));
      await tester.pumpAndSettle();
      expect(store.erasedAccount, isNull);
      await tester.tap(find.text(CommonStrings.delete));
      await tester.pumpAndSettle();
      expect(store.erasedAccount, 'me');
      expect(find.textContaining('Trong cửa hàng của bạn:'), findsNothing);
      await tester.pumpWidget(const SizedBox.shrink());
    },
  );

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
