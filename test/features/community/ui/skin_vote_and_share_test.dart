import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/domain/economy/economy.dart';
import 'package:valvn/features/community/community_routes.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/data/compose_draft.dart';
import 'package:valvn/features/community/ui/share_to_community_button.dart';
import 'package:valvn/features/community/ui/skins/skin_vote_button.dart';
import 'package:valvn/features/community/ui/widgets/community_widgets.dart';

import '../community_test_env.dart';

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create());

  testWidgets('skin sheet heart: anonymous count, vote signs in', (
    tester,
  ) async {
    env.server
      ..json('GET /v1/skins/votes', {
        'items': [
          {'skinUuid': reaverSkin, 'votes': 41, 'voted': false},
        ],
      })
      ..json('PUT /v1/skins/*/vote', {
        'skinUuid': reaverSkin,
        'votes': 42,
        'voted': true,
      });
    await pumpCommunity(
      tester,
      env,
      const Scaffold(
        body: SkinVoteButton(skinUuid: reaverSkin, weaponUuid: vandal),
      ),
    );
    await settle(tester);

    expect(find.text('41'), findsOneWidget);
    expect(find.text(CommunityStrings.communityVotes), findsOneWidget);
    expect(
      env.server.calls('GET /v1/skins/votes').single.authorization,
      isNull,
    );
    expect(env.server.calls('POST /v1/auth/riot'), isEmpty);

    await tester.tap(find.bySemanticsLabel(CommunityStrings.vote));
    await settle(tester);

    expect(find.text('42'), findsOneWidget);
    expect(env.server.calls('POST /v1/auth/riot'), hasLength(1));
    expect(
      env.server.calls('PUT /v1/skins/*/vote').single.path,
      '/v1/skins/$reaverSkin/vote',
    );
    await unmount(tester);
  });

  testWidgets('skin sheet heart hides itself when the server fails', (
    tester,
  ) async {
    env.server.json('GET /v1/skins/votes', '<html>502</html>', status: 502);
    await pumpCommunity(
      tester,
      env,
      const Scaffold(body: SkinVoteButton(skinUuid: reaverSkin)),
    );
    await settle(tester);
    expect(find.byType(HeartButton), findsNothing);
    expect(find.text(CommunityStrings.communityVotes), findsNothing);
    await unmount(tester);
  });

  testWidgets('"Khoe lên Cộng đồng" opens the composer with the shop', (
    tester,
  ) async {
    Object? extra;
    final daily = DailyStore(
      offers: [
        DailyOffer(
          offer: const StoreOffer(
            offerId: reaverLevel,
            cost: {'85ad13f7-3d1b-5128-9eb2-7cd8ee0b5741': 1775},
          ),
          skinLevelUuid: reaverLevel,
        ),
      ],
    );
    await pumpCommunityRouter(
      tester,
      env,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              Scaffold(body: ShareToCommunityButton.daily(daily)),
        ),
        GoRoute(
          path: CommunityRoutes.compose,
          builder: (context, state) {
            extra = state.extra;
            return const Scaffold(body: Text('composer'));
          },
        ),
      ],
    );
    await settle(tester);
    expect(find.text(CommunityStrings.shareStore), findsOneWidget);

    await tester.tap(find.text(CommunityStrings.shareStore));
    await settle(tester, frames: 30);

    expect(find.text('composer'), findsOneWidget);
    final draft = extra! as ComposeDraft;
    expect(draft.kind, PostKind.store);
    expect(draft.payload!.offers.single.skinUuid, reaverSkin);
    expect(draft.payload!.offers.single.cost, 1775);
    await unmount(tester);
  });

  testWidgets('share button hides when the shop is empty', (tester) async {
    await pumpCommunity(
      tester,
      env,
      const Scaffold(body: ShareToCommunityButton.daily(DailyStore.empty)),
    );
    await settle(tester);
    expect(find.text(CommunityStrings.shareStore), findsNothing);
    await unmount(tester);
  });

  testWidgets('skin sheet: "★ 4,6 · 128 đánh giá" opens the review page', (
    tester,
  ) async {
    env.server.json('GET /v1/skins/votes', {
      'items': [
        {
          'skinUuid': reaverSkin,
          'votes': 41,
          'ratingAvg': 4.56,
          'ratingCount': 128,
        },
      ],
    });
    String? opened;
    await pumpCommunityRouter(
      tester,
      env,
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(
            body: SkinVoteButton(skinUuid: reaverSkin, weaponUuid: vandal),
          ),
        ),
        GoRoute(
          path: '/community/skin/:uuid',
          builder: (context, state) {
            opened = state.pathParameters['uuid'];
            return const Scaffold(body: Text('review page'));
          },
        ),
      ],
    );
    await settle(tester);

    expect(
      find.text(CommunityStrings.ratingSummary('4,6', '128')),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('skin-rating-link')));
    await settle(tester, frames: 30);
    expect(opened, reaverSkin);
    await unmount(tester);
  });

  testWidgets('skin sheet: no ratings yet invites the first review', (
    tester,
  ) async {
    env.server.json('GET /v1/skins/votes', {
      'items': [
        {'skinUuid': reaverSkin, 'votes': 0},
      ],
    });
    await pumpCommunity(
      tester,
      env,
      const Scaffold(body: SkinVoteButton(skinUuid: reaverSkin)),
    );
    await settle(tester);
    expect(find.text(CommunityStrings.writeFirstReview), findsOneWidget);
    await unmount(tester);
  });
}
