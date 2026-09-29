import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/ui/segmented_tabs.dart';
import 'package:valvn/features/community/community_routes.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_models.dart';

import '../community_test_env.dart';

Future<void> _open(
  WidgetTester tester,
  CommunityTestEnv env, {
  String location = CommunityRoutes.root,
}) async {
  await pumpCommunityRouter(
    tester,
    env,
    routes: [...communityBranchRoutes, ...communityTopLevelRoutes],
    initialLocation: location,
  );
  await settle(tester);
}

/// The scope segment that is highlighted.
CommunityScope _selected(WidgetTester tester) => tester
    .widget<SegmentedTabs<CommunityScope>>(
      find.byType(SegmentedTabs<CommunityScope>),
    )
    .selected;

Map<String, Object?> _applied(
  String scope, {
  String? country,
  String? region,
}) => {'scope': scope, 'country': country, 'region': region};

void main() {
  late CommunityTestEnv env;
  setUp(() async {
    env = await CommunityTestEnv.create();
    env.server.json('POST /v1/auth/riot', sessionJson(country: 'VN'));
  });

  group('Bảng tin', () {
    testWidgets('highlights the scope the server applied', (tester) async {
      env.server.json('GET /v1/posts', {
        ...page([postJson('p1')]),
        'appliedScope': _applied('country', country: 'VN'),
      });
      await _open(tester, env);

      expect(_selected(tester), CommunityScope.country);
      expect(env.server.calls('GET /v1/posts').last.query['scope'], 'country');
      await unmount(tester);
    });

    testWidgets('a fallback of the server wins over what the app asked', (
      tester,
    ) async {
      // Asked: the viewer's country. The server could not, and used the shard.
      env.server.json('GET /v1/posts', {
        ...page([postJson('p1')]),
        'appliedScope': _applied('region', region: 'ap'),
      });
      await _open(tester, env);

      expect(env.server.calls('GET /v1/posts').last.query['scope'], 'country');
      expect(_selected(tester), CommunityScope.region);
      expect(find.text('p1'), findsNothing);
      await unmount(tester);
    });

    testWidgets('without appliedScope the app keeps its own resolution', (
      tester,
    ) async {
      env.server.json('GET /v1/posts', page([postJson('p1')]));
      await _open(tester, env);
      expect(_selected(tester), CommunityScope.country);
      await unmount(tester);
    });

    testWidgets('picking Khu vực follows the applied region', (tester) async {
      env.server.on('GET /v1/posts', (r) {
        final scope = r.query['scope'];
        return FakeResponse(200, {
          ...page([postJson('p1')]),
          'appliedScope': scope == 'region'
              ? _applied('region', region: r.query['region'])
              : _applied('country', country: 'VN'),
        });
      });
      await _open(tester, env);
      expect(_selected(tester), CommunityScope.country);

      await tester.tap(find.text(CommunityStrings.scopeRegion));
      await settle(tester);

      expect(_selected(tester), CommunityScope.region);
      // The shard chip names the applied shard.
      expect(find.text(CommunityStrings.regionLabel('ap')), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('the previous list applied scope does not stay highlighted', (
      tester,
    ) async {
      env.server.on(
        'GET /v1/posts',
        (r) => FakeResponse(200, {
          ...page([postJson('p1')]),
          'appliedScope': r.query['scope'] == 'global'
              ? _applied('global')
              : _applied('country', country: 'VN'),
        }),
      );
      await _open(tester, env);
      expect(_selected(tester), CommunityScope.country);

      // The next list is still loading when the user has already switched.
      final gate = Completer<void>();
      env.server.hold('GET /v1/posts', gate);
      await tester.tap(find.text(CommunityStrings.scopeGlobal));
      await settle(tester);
      expect(_selected(tester), CommunityScope.global);

      gate.complete();
      await settle(tester);
      expect(_selected(tester), CommunityScope.global);
      await unmount(tester);
    });
  });

  group('Xếp hạng skin', () {
    Map<String, Object?> top(Map<String, Object?> appliedScope) => {
      'items': [
        {'rank': 1, 'skinUuid': reaverSkin, 'votes': 12},
      ],
      'appliedScope': appliedScope,
    };

    testWidgets('highlights the applied scope', (tester) async {
      env.server.json('GET /v1/skins/top', top(_applied('global')));
      await _open(tester, env, location: '/community?section=skins');

      // Asked: the viewer's country (spec default); the server used the world.
      expect(
        env.server.calls('GET /v1/skins/top').last.query['scope'],
        'country',
      );
      expect(_selected(tester), CommunityScope.global);
      expect(find.text('Vandal Reaver'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('country as asked', (tester) async {
      env.server.json(
        'GET /v1/skins/top',
        top(_applied('country', country: 'VN')),
      );
      await _open(tester, env, location: '/community?section=skins');
      expect(_selected(tester), CommunityScope.country);
      await unmount(tester);
    });

    testWidgets('an empty leaderboard still shows the applied scope', (
      tester,
    ) async {
      env.server.json('GET /v1/skins/top', {
        'items': <Object>[],
        'appliedScope': _applied('region', region: 'ap'),
      });
      await _open(tester, env, location: '/community?section=skins');
      expect(find.text(CommunityStrings.skinsEmptyTitle), findsOneWidget);
      expect(_selected(tester), CommunityScope.region);
      await unmount(tester);
    });
  });

  group('Tìm đồng đội', () {
    testWidgets('the shard chip shows the shard the server listed', (
      tester,
    ) async {
      env.server.json('GET /v1/lfg', {
        ...page([]),
        'appliedScope': _applied('region', region: 'ap'),
      });
      await _open(tester, env, location: '/community?section=lfg');
      expect(env.server.calls('GET /v1/lfg').last.query['region'], 'ap');
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('lfg-region')),
          matching: find.text(CommunityStrings.regionLabel('ap')),
        ),
        findsOneWidget,
      );
      await unmount(tester);
    });
  });
}
