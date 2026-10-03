import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_fallbacks.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/domain/economy/prices.dart';
import 'package:valvn/core/domain/economy/reward_sources.dart';
import 'package:valvn/core/l10n/labels/content_labels.dart';
import 'package:valvn/core/l10n/labels/economy_labels.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/riot/riot_ids.dart';
import 'package:valvn/core/ui/content_tier_badge.dart';
import 'package:valvn/core/ui/currency_amount.dart';
import 'package:valvn/features/battlepass/data/battlepass_models.dart';
import 'package:valvn/features/battlepass/ui/widgets/reward_tile.dart';
import 'package:valvn/features/home/data/home_live.dart';
import 'package:valvn/features/live_game/data/live_game_logic.dart';
import 'package:valvn/features/live_game/data/live_game_models.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

// Synthetic resources exercise reload/fallback; they are not shipped locales.
class _Messages extends AppLocalizationsVi {
  _Messages(this.marker, [super.locale]);
  final String marker;
  @override
  String get contentCurrencyAgentTokens => 'tokens-$marker';
  @override
  String get contentCurrencyVpFull => 'vp-$marker';
  @override
  String get contentTierPremium => 'tier-$marker';
  @override
  String contentTierFull(String shortName) => 'full-$shortName';
  @override
  String get contentNoTitle => 'no-title-$marker';
  @override
  String get contentItemTitle => 'title-type-$marker';
  @override
  String get contentQueueNamesCompetitive => 'queue-$marker';
  @override
  String get contentQueueNames => 'custom-$marker';
  @override
  String get contentRewardSourceBattlePass => 'pass-$marker';
  @override
  String get commonUnknownItem => 'unknown-$marker';
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate(this.marker);
  final String marker;
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'vi';
  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(_Messages(marker));
  @override
  bool shouldReload(_Delegate old) => marker != old.marker;
}

ContentDb _content(String language) => ContentDb.parse({
  ContentEndpoints.queues: jsonEncode({
    'data': [
      {
        'uuid': '00000000-0000-0000-0000-000000000001',
        'queueId': 'competitive',
        'dropdownText': 'API ranked',
      },
    ],
  }),
}, language: language);

void main() {
  test(
    'isolate fallback data retains IDs, colors and icons without UI text',
    () async {
      final db = await Isolate.run(() => ContentDb.empty(language: 'en-US'));
      expect(db.language, 'en-US');
      expect(db.currencies, hasLength(4));
      expect(db.contentTiers, hasLength(5));
      expect(db.currencies.every((c) => c.displayName.isEmpty), isTrue);
      expect(db.contentTiers.every((t) => t.displayName.isEmpty), isTrue);
      expect(
        db.currency(CurrencyIds.vp)!.displayIcon,
        contains(CurrencyIds.vp),
      );
      final tier = db.contentTier(ContentTierIds.premium)!;
      expect(tier.highlightColor, 'd1548d33');
      expect(tier.rank, 2);
      expect(tier.fallbackPrice, 1775);
      expect(tier.fallbackPriceIsEstimate, isFalse);
      expect(
        db.contentTier(ContentTierIds.ultra)!.fallbackPriceIsEstimate,
        isTrue,
      );
    },
  );

  test('one retained DB resolves current resources without changing data', () {
    final db = ContentDb.empty();
    final currency = db.currency(CurrencyIds.agentTokens)!;
    final tier = db.contentTier(ContentTierIds.premium)!;
    final first = _Messages('first');
    final second = _Messages('second');
    expect(currency.label(first), 'tokens-first');
    expect(currency.label(second), 'tokens-second');
    expect(tier.shortName(first), 'tier-first');
    expect(tier.fullName(second), 'full-tier-second');
    expect(currency.displayName, isEmpty);
    expect(tier.displayName, isEmpty);
    expect(
      identical(currency, ContentFallbacks.currency(currency.uuid)),
      isTrue,
    );
  });

  test(
    'matching API content is preferred; mismatched UI uses owned fallback',
    () {
      const currency = Currency(
        uuid: CurrencyIds.vp,
        displayName: 'API points',
      );
      const tier = ContentTier(
        uuid: ContentTierIds.premium,
        devName: 'Premium',
        rank: 2,
        displayName: 'API premium',
      );
      final english = _Messages('en', 'en');
      final french = _Messages('fr', 'fr');
      expect(
        currency.fullLabel(english, contentLanguage: 'en-US'),
        'API points',
      );
      expect(currency.fullLabel(french, contentLanguage: 'en-US'), 'vp-fr');
      expect(tier.shortName(english, contentLanguage: 'en-US'), 'API premium');
      expect(tier.shortName(french, contentLanguage: 'en-US'), 'tier-fr');
      expect(tier.fullName(french, contentLanguage: 'en-US'), 'full-tier-fr');
      expect(
        tier.shortName(_Messages('zh', 'zh_Hant'), contentLanguage: 'zh-TW'),
        'API premium',
      );
      expect(
        tier.shortName(_Messages('zh', 'zh_Hant'), contentLanguage: 'zh-CN'),
        'tier-zh',
      );
    },
  );

  test(
    'queue aliases, unknown IDs and API language do not cross UI fallback',
    () {
      final db = _content('en-US');
      final english = _Messages('en', 'en');
      final vi = _Messages('vi');
      expect(db.queueName(english, 'console_competitive'), 'API ranked');
      expect(db.queueName(vi, 'console_competitive'), 'queue-vi');
      expect(db.queueName(vi, 'future-queue'), 'future-queue');
      expect(db.queueName(vi, null), 'custom-vi');
      expect(ContentDb.empty().queueName(vi, 'swiftplay'), 'Siêu Tốc');
      expect(db.queueShortName(vi, 'console_competitive'), 'Xếp hạng');
    },
  );

  test(
    'title sentinel and item type use UI resources; real titles stay API data',
    () {
      const title = PlayerTitle(
        uuid: SpecialIds.noTitle,
        displayName: 'internal',
      );
      const real = PlayerTitle(
        uuid: 'real-title',
        displayName: 'API',
        titleText: 'API title',
      );
      final first = _Messages('first');
      final second = _Messages('second');
      expect(title.text, isEmpty);
      expect(title.localizedText(first), 'no-title-first');
      expect(title.localizedText(second), 'no-title-second');
      expect(real.localizedText(second), 'API title');
      expect(ContractRewardType.title.label(second), 'title-type-second');
      expect(ContractRewardType.unknown.label(second), isEmpty);
    },
  );

  test(
    'price captions switch without altering provenance, amount or estimates',
    () {
      const contract = Contract(
        uuid: 'pass',
        displayName: 'API pass',
        relation: ContractRelation.season,
        chapters: [],
      );
      const entry = RewardSourceEntry(
        contract: contract,
        itemUuid: 'skin',
        rewardType: ContractRewardType.skinLevel,
        chapterIndex: 0,
        isFreeReward: false,
      );
      const quote = PriceQuote.reward(entry);
      expect(quote.caption(_Messages('first')), 'pass-first');
      expect(quote.caption(_Messages('second')), 'pass-second');
      expect(quote.source, PriceSource.reward);
      expect(quote.vp, isNull);
      const estimated = PriceQuote(
        vp: 2475,
        source: PriceSource.tierFallback,
        isEstimate: true,
      );
      expect(estimated.caption(_Messages('second')), isNull);
      expect(estimated.vp, 2475);
      expect(estimated.isEstimate, isTrue);
    },
  );

  test(
    'Battle Pass missing reward names are resolved with explicit resources',
    () {
      const tier = RewardTier(
        level: 1,
        reward: null,
        state: RewardState.locked,
      );
      final db = ContentDb.empty();
      expect(
        ResolvedReward.resolve(tier, db, _Messages('first')).name,
        'unknown-first',
      );
      final next = ResolvedReward.resolve(tier, db, _Messages('second'));
      expect(next.name, 'unknown-second');
      expect(next.isKnown, isFalse);
      expect(next.tier, same(tier));
    },
  );

  test(
    'Home live snapshot retains queue IDs, so view text can change later',
    () {
      const snapshot = HomeLiveSnapshot(
        phase: LivePhase.queueing,
        queueId: 'competitive',
      );
      final db = ContentDb.empty();
      expect(
        liveModeLabel(_Messages('first'), db, queueId: snapshot.queueId),
        'queue-first',
      );
      expect(
        liveModeLabel(_Messages('second'), db, queueId: snapshot.queueId),
        'queue-second',
      );
      expect(snapshot.queueId, 'competitive');
    },
  );

  testWidgets('same widgets and cached fallback update when resources reload', (
    tester,
  ) async {
    final db = ContentDb.empty();
    final container = ProviderContainer(
      overrides: [contentProvider.overrideWith((ref) async => db)],
    );
    addTearDown(container.dispose);
    await container.read(contentProvider.future);
    Widget app(String marker) => UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('vi'),
        supportedLocales: const [Locale('vi')],
        localizationsDelegates: [
          _Delegate(marker),
          ...appLocalizationsDelegates.skip(1),
        ],
        home: const Scaffold(
          body: Column(
            children: [
              CurrencyAmount(
                currencyId: CurrencyIds.agentTokens,
                amount: 2,
                showLabel: true,
              ),
              ContentTierBadge(
                contentTierUuid: ContentTierIds.premium,
                showName: true,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpWidget(app('first'));
    await tester.pump();
    expect(find.text('2 tokens-first'), findsOneWidget);
    expect(find.text('tier-first'), findsOneWidget);
    await tester.pumpWidget(app('second'));
    await tester.pump();
    expect(find.text('2 tokens-first'), findsNothing);
    expect(find.text('tier-first'), findsNothing);
    expect(find.text('2 tokens-second'), findsOneWidget);
    expect(find.text('tier-second'), findsOneWidget);
    expect(container.read(contentProvider).value, same(db));
    expect(tester.takeException(), isNull);
  });
}
