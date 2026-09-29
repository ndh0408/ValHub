import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/l10n/content_strings.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/json_file_cache.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/skin_detail/skin_detail_sheet.dart';
import 'package:valvn/features/skin_detail/skin_detail_strings.dart';
import 'package:valvn/features/skin_detail/skin_video_view.dart';

import '../../core/domain/economy/economy_fixtures.dart';
import '../../helpers/test_prefs.dart';
import '../store/store_test_harness.dart';

const _friend = Account(
  puuid: '11111111-1111-1111-1111-111111111111',
  gameName: 'Bạn Thân',
  tagLine: 'VN9',
  region: 'ap',
  shard: 'ap',
);

/// Opens the sheet from a button, the way the app does.
class _Harness extends StatelessWidget {
  const _Harness({required this.uuid, required this.mode});

  final String uuid;
  final SkinDetailMode mode;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Builder(
        builder: (context) => TextButton(
          onPressed: () =>
              showSkinDetailSheet(context, skinOrLevelUuid: uuid, mode: mode),
          child: const Text('open'),
        ),
      ),
    ),
  );
}

Future<void> _open(
  WidgetTester tester, {
  String uuid = Fx.reaverVandal,
  SkinDetailMode mode = SkinDetailMode.store,
  List<Override> Function(Prefs prefs)? overrides,
  Size size = const Size(360, 740),
}) async {
  usePhoneViewport(tester, size: size);
  final prefs = await createTestPrefs();
  await tester.pumpWidget(
    testApp(
      overrides:
          overrides?.call(prefs) ??
          storeOverrides(api: fixtureApi(), prefs: prefs),
      home: _Harness(uuid: uuid, mode: mode),
    ),
  );
  await settle(tester);
  await tester.tap(find.text('open'));
  await settle(tester, 12);
}

Future<void> _scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    150,
    scrollable: find
        .descendant(
          of: find.byType(SkinDetailSheet),
          matching: find.byType(Scrollable),
        )
        .first,
  );
  await tester.ensureVisible(finder);
  await tester.pump();
}

void main() {
  final db = economyContent();

  test('skinMedia: base variant uses the best level video', () {
    final reaver = db.skin(Fx.reaverVandal)!;
    final base = skinMedia(reaver, reaver.chromas.first);
    expect(base.render, reaver.chromas.first.fullRender);
    expect(base.video, reaver.previewVideo);
    final second = skinMedia(reaver, reaver.chromas[1]);
    expect(second.render, reaver.chromas[1].fullRender);
    expect(second.video, reaver.chromas[1].streamedVideo);
    expect(skinMedia(reaver, null).render, reaver.render);
  });

  testWidgets('store mode: tier, estimated price, variants, levels, owned', (
    tester,
  ) async {
    await _open(tester);

    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(find.text('Phiên Bản Cao Cấp'), findsOneWidget);
    // No exact price known → tier fallback with "≈" and its caption.
    expect(find.text('≈ 1.775'), findsOneWidget);
    expect(find.text('Giá ước tính theo phiên bản'), findsOneWidget);
    // Reaver level 1 and 3 are owned in the entitlements fixture.
    expect(find.text(SkinDetailStrings.owned), findsOneWidget);
    expect(find.text(SkinDetailStrings.playVideo), findsOneWidget);

    await _scrollTo(tester, find.text(SkinDetailStrings.upgrades));
    expect(find.text(SkinDetailStrings.variants), findsOneWidget);
    for (var n = 1; n <= 4; n++) {
      expect(find.text(ContentStrings.level(n)), findsOneWidget);
    }
    // Owned skin: level 4 and the three non-base variants are locked.
    expect(find.byIcon(Icons.lock), findsNWidgets(4));

    await unmount(tester);
  });

  testWidgets('wishlist button toggles the wishlist', (tester) async {
    await _open(tester);

    await _scrollTo(tester, find.text(SkinDetailStrings.addToWishlist));
    await tester.tap(find.text(SkinDetailStrings.addToWishlist));
    await settle(tester, 3);
    expect(find.text(SkinDetailStrings.inWishlist), findsOneWidget);

    await tester.tap(find.text(SkinDetailStrings.inWishlist));
    await settle(tester, 3);
    expect(find.text(SkinDetailStrings.addToWishlist), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('tapping a variant switches the render', (tester) async {
    final second = db.skin(Fx.reaverVandal)!.chromas[1];
    await _open(tester);

    expect(find.byKey(ValueKey(second.fullRender)), findsNothing);
    await _scrollTo(tester, find.byTooltip(second.label));
    await tester.ensureVisible(find.byTooltip(second.label));
    await settle(tester, 3);
    await tester.tap(find.byTooltip(second.label));
    await settle(tester, 3);
    // Back to the top, where the render is built again.
    await tester.drag(
      find
          .descendant(
            of: find.byType(SkinDetailSheet),
            matching: find.byType(Scrollable),
          )
          .first,
      const Offset(0, 1200),
    );
    await settle(tester, 12);
    expect(find.byKey(ValueKey(second.fullRender)), findsOneWidget);
    // The selected variant's name is shown next to "Biến thể".
    expect(find.text(second.label), findsWidgets);

    await unmount(tester);
  });

  testWidgets('a chroma uuid preselects that variant', (tester) async {
    await _open(tester, uuid: Fx.reaverChroma2);

    final chroma = db.skinChroma(Fx.reaverChroma2)!;
    expect(find.byKey(ValueKey(chroma.fullRender)), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('a level with a video opens the full-screen player', (
    tester,
  ) async {
    await _open(tester);

    await _scrollTo(tester, find.text(ContentStrings.level(4)));
    await tester.tap(find.text(ContentStrings.level(4)));
    await settle(tester);
    expect(find.byType(SkinVideoView), findsOneWidget);

    await unmount(tester);
  });

  testWidgets('owned mode hides the wishlist button', (tester) async {
    await _open(tester, mode: SkinDetailMode.owned);

    expect(find.text(SkinDetailStrings.owned), findsOneWidget);
    await _scrollTo(tester, find.text(ContentStrings.level(4)));
    expect(find.text(SkinDetailStrings.addToWishlist), findsNothing);
    expect(find.text(SkinDetailStrings.inWishlist), findsNothing);

    await unmount(tester);
  });

  testWidgets('reward skins show the source instead of a price', (
    tester,
  ) async {
    await _open(tester, uuid: Fx.vandalCafe, mode: SkinDetailMode.catalog);

    expect(find.text(ContentStrings.rewardSourceBattlePass), findsOneWidget);
    expect(find.textContaining('Mùa 2026 // Phần V'), findsOneWidget);
    expect(find.textContaining('VP'), findsNothing);

    await unmount(tester);
  });

  testWidgets('"Có trong cửa hàng của" from another account\'s saved store', (
    tester,
  ) async {
    final cache = MemoryJsonCache();
    await cache.write(
      JsonFileCache.accountKey(_friend.puuid, 'economy_storefront'),
      economyFixture('storefront.json'),
      savedAt: t0,
    );
    await _open(
      tester,
      mode: SkinDetailMode.catalog,
      overrides: (prefs) => storeOverrides(
        api: fixtureApi(),
        prefs: prefs,
        cache: cache,
        accounts: const [testAccount, _friend],
      ),
    );

    expect(
      find.text(SkinDetailStrings.availableInStoreOf(_friend.riotId)),
      findsOneWidget,
    );
    await unmount(tester);
  });

  testWidgets('unknown uuid: not-found state and a content-miss report', (
    tester,
  ) async {
    final misses = MissCounter();
    await _open(
      tester,
      uuid: Fx.unknownLevel,
      overrides: (prefs) =>
          storeOverrides(api: fixtureApi(), prefs: prefs, misses: misses),
    );

    expect(find.text(SkinDetailStrings.notFound), findsOneWidget);
    expect(find.text(SkinDetailStrings.title), findsOneWidget);
    expect(misses.count, 1);

    await unmount(tester);
  });

  testWidgets('content failure: error with "Thử lại"', (tester) async {
    await _open(
      tester,
      overrides: (prefs) => storeOverrides(
        api: fixtureApi(),
        prefs: prefs,
        loadContent: () async => throw const TransientException(),
      ),
    );

    expect(find.text(CommonStrings.retry), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('close button dismisses the sheet', (tester) async {
    await _open(tester);

    await tester.tap(find.byTooltip(CommonStrings.close));
    await settle(tester, 20);
    expect(find.byType(SkinDetailSheet), findsNothing);

    await unmount(tester);
  });

  testWidgets('no overflow on a 320 dp phone with 130 % text', (tester) async {
    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await _open(tester, size: const Size(320, 640));

    await _scrollTo(tester, find.text(SkinDetailStrings.addToWishlist));
    expect(tester.takeException(), isNull);

    await unmount(tester);
  });
}
