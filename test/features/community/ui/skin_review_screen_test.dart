import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/ui/skins/skin_review_screen.dart';

import '../community_test_env.dart';
import '../data/skin_review_test.dart' show reviewJson, summaryJson;

Future<void> _pump(
  WidgetTester tester,
  CommunityTestEnv env, {
  Size size = const Size(360, 2200),
  double textScale = 1,
  ThemeData? theme,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...env.overrides,
        priceAssetLoaderProvider.overrideWithValue(() async => '{}'),
      ],
      retry: (_, _) => null,
      child: MaterialApp(
        theme: theme ?? buildDarkTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: const SkinReviewScreen(skinUuid: reaverSkin),
      ),
    ),
  );
  await settle(tester);
}

/// The viewer's review as the fake server currently stores it.
Map<String, Object?>? _stored;

void _serve(
  CommunityTestEnv env, {
  Map<String, Object?>? myReview,
  List<Map<String, Object?>>? reviews,
}) {
  _stored = myReview;
  env.server
    ..on(
      'GET /v1/skins/*/summary',
      (_) => FakeResponse(200, summaryJson(myReview: _stored)),
    )
    ..on('PUT /v1/skins/*/review', (r) {
      final body = r.json! as Map;
      _stored = reviewJson(
        'mine',
        rating: body['rating'] as int,
        body: (body['body'] as String?) ?? '',
        mine: true,
      );
      return FakeResponse(200, _stored);
    })
    ..on('DELETE /v1/skins/*/review', (_) {
      _stored = null;
      return const FakeResponse(204);
    })
    ..json(
      'GET /v1/skins/*/reviews',
      page(
        reviews ??
            [
              reviewJson('r1', body: 'Âm thanh bắn cực đã', likes: 4),
              reviewJson(
                'r2',
                rating: 3,
                body: 'Tạm ổn',
                author: authorJson(id: 'other2', name: 'Người Hai'),
              ),
            ],
      ),
    );
}

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create());

  testWidgets('hero, score, distribution, reviews and sort', (tester) async {
    _serve(env);
    await _pump(tester, env);

    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(find.text('4,6'), findsOneWidget);
    expect(find.text(CommunityStrings.ratingCount('128')), findsOneWidget);
    expect(find.text('ĐÁNH GIÁ · 57'), findsOneWidget);
    expect(find.text('Âm thanh bắn cực đã'), findsOneWidget);
    expect(find.text(CommunityStrings.helpfulCount('4')), findsOneWidget);
    expect(find.text(CommunityStrings.tapToRate), findsOneWidget);

    await tester.tap(find.text(CommunityStrings.sortHelpful));
    await settle(tester);
    expect(
      env.server.calls('GET /v1/skins/*/reviews').last.query['sort'],
      'top',
    );
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets('rate: tap a star → editor → validation → save', (tester) async {
    _serve(env);
    await _pump(tester, env);

    await tester.tap(find.byKey(const ValueKey('star-4')).first);
    await settle(tester);
    expect(find.text(CommunityStrings.ratingWords[3]), findsWidgets);
    FilledButton save() => tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, CommunityStrings.saveReview),
    );
    expect(save().onPressed, isNotNull);

    await tester.enterText(
      find.byKey(const ValueKey('review-body')),
      'x' * 501,
    );
    await tester.pump();
    expect(find.text(CommunityStrings.tooLong(500)), findsOneWidget);
    expect(save().onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('review-body')),
      'Rất đẹp',
    );
    await tester.pump();
    await tester.tap(find.text(CommunityStrings.saveReview));
    await settle(tester, frames: 30);

    expect(env.server.calls('PUT /v1/skins/*/review').single.json, {
      'weaponUuid': vandal,
      'rating': 4,
      'body': 'Rất đẹp',
      'language': 'vi',
    });
    expect(find.text(CommunityStrings.reviewSaved), findsOneWidget);
    expect(find.text(CommunityStrings.editReview), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('own review: edit prefilled, delete after confirmation', (
    tester,
  ) async {
    final mine = reviewJson(
      'mine',
      rating: 5,
      body: 'Skin đẹp nhất',
      mine: true,
      author: authorJson(id: meId),
    );
    _serve(env, myReview: mine, reviews: [mine]);
    await _pump(tester, env);

    expect(find.text('Skin đẹp nhất'), findsNWidgets(2));
    // Own review in the list: no "Hữu ích".
    expect(find.text(CommunityStrings.helpful), findsNothing);

    await tester.tap(find.text(CommunityStrings.editReview));
    await settle(tester);
    expect(
      tester
          .widget<TextField>(find.byKey(const ValueKey('review-body')))
          .controller
          ?.text,
      'Skin đẹp nhất',
    );
    await tester.tapAt(const Offset(10, 10));
    await settle(tester, frames: 30);

    await tester.tap(find.text(CommunityStrings.deleteReview).first);
    await settle(tester);
    expect(find.text(CommunityStrings.deleteReviewTitle), findsOneWidget);
    await tester.tap(find.text(CommunityStrings.delete));
    await settle(tester);

    expect(env.server.calls('DELETE /v1/skins/*/review'), hasLength(1));
    expect(find.text(CommunityStrings.reviewDeleted), findsOneWidget);
    expect(find.text(CommunityStrings.tapToRate), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('"Hữu ích" toggles optimistically', (tester) async {
    _serve(env);
    env.server.json('PUT /v1/reviews/r2/like', {'likes': 1, 'liked': true});
    await _pump(tester, env);

    await tester.tap(find.text(CommunityStrings.helpful));
    await tester.pump();
    expect(find.text(CommunityStrings.helpfulCount('1')), findsOneWidget);
    await settle(tester);
    expect(env.server.calls('PUT /v1/reviews/r2/like'), hasLength(1));
    await unmount(tester);
  });

  testWidgets('report a review: reason + confirmation', (tester) async {
    _serve(env);
    env.server.json('POST /v1/reports', null, status: 204);
    await _pump(tester, env);

    await tester.tap(find.byTooltip(CommunityStrings.moreActions).first);
    await settle(tester);
    await tester.tap(find.text(CommunityStrings.report));
    await settle(tester);
    await tester.tap(find.text('Quấy rối, xúc phạm'));
    await settle(tester);
    await tester.tap(find.text(CommunityStrings.send));
    await settle(tester);

    expect(env.server.calls('POST /v1/reports').single.json, {
      'targetType': 'review',
      'targetId': 'r1',
      'reason': 'harassment',
    });
    await unmount(tester);
  });

  testWidgets('no reviews: invite to be first', (tester) async {
    _serve(env, reviews: const []);
    await _pump(tester, env);
    expect(find.text(CommunityStrings.reviewsEmptyBody), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('heart vote on the page', (tester) async {
    _serve(env);
    env.server.json('PUT /v1/skins/*/vote', {
      'skinUuid': reaverSkin,
      'votes': 41,
      'voted': true,
    });
    await _pump(tester, env);
    expect(find.text('40'), findsOneWidget);
    await tester.tap(find.bySemanticsLabel(CommunityStrings.vote));
    await settle(tester);
    expect(find.text('41'), findsOneWidget);
    await unmount(tester);
  });

  for (final light in [false, true]) {
    testWidgets(
      'no overflow at 360 dp, text scale 2.0 (${light ? 'light' : 'dark'})',
      (tester) async {
        _serve(
          env,
          myReview: reviewJson(
            'mine',
            mine: true,
            author: authorJson(id: meId),
          ),
        );
        await _pump(
          tester,
          env,
          size: const Size(360, 3200),
          textScale: 2,
          theme: light ? buildLightTheme() : buildDarkTheme(),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Vandal Reaver'), findsOneWidget);
        await unmount(tester);
      },
    );
  }
}
