import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/features/community/ui/skins/skin_catalog_sheet.dart';

import '../community_test_env.dart';

String _id(int i) =>
    '${i.toRadixString(16).padLeft(8, '0')}-1111-4111-8111-111111111111';
final _db = ContentDb.parse({
  'weapons': [
    {
      'uuid': vandal,
      'displayName': 'Vandal',
      'category': 'EEquippableCategory::Rifle',
      'skins': [
        for (var i = 0; i < 99; i++)
          {
            'uuid': _id(i),
            'displayName': 'Skin ${i.toString().padLeft(3, '0')}',
          },
      ],
    },
  ],
});

void main() {
  late CommunityTestEnv env;
  setUp(() async {
    env = await CommunityTestEnv.create();
    env.content = _db;
    env.server.json('GET /v1/skins/votes', {'items': <Object?>[]});
  });

  Future<void> open(WidgetTester tester) async {
    await pumpCommunity(
      tester,
      env,
      Scaffold(
        body: CustomScrollView(
          slivers: [const SkinCatalogSliver(puuid: mePuuid)],
        ),
      ),
      size: const Size(360, 800),
    );
    await settle(tester);
  }

  testWidgets(
    'complete catalog is lazy, no manual 30-item limit; scroll reaches final skin',
    (tester) async {
      await open(tester);
      expect(find.byKey(const ValueKey('skins-catalog-more')), findsNothing);
      expect(find.byKey(ValueKey('inline-catalog-${_id(98)}')), findsNothing);
      final initial = env.server.calls('GET /v1/skins/votes');
      expect(initial, hasLength(1));
      expect(initial.single.query['ids']!.split(','), hasLength(30));
      await tester.scrollUntilVisible(
        find.byKey(ValueKey('inline-catalog-${_id(98)}')),
        500,
        scrollable: find
            .descendant(
              of: find.byType(CustomScrollView),
              matching: find.byType(Scrollable),
            )
            .first,
        maxScrolls: 30,
      );
      await settle(tester);
      expect(find.text('Skin 098'), findsOneWidget);
      for (final r in env.server.calls('GET /v1/skins/votes')) {
        expect(r.query['ids']!.split(',').length, lessThanOrEqualTo(30));
      }
      expect(env.server.calls('PUT /v1/skins/*/review'), isEmpty);
      await unmount(tester);
    },
  );

  testWidgets('search includes skins whose original page was never requested', (
    tester,
  ) async {
    await open(tester);
    await tester.enterText(
      find.byKey(const ValueKey('skins-inline-search')),
      'skin 098',
    );
    await settle(tester);
    expect(find.byKey(ValueKey('inline-catalog-${_id(98)}')), findsOneWidget);
    expect(find.text('Skin 000'), findsNothing);
    expect(env.server.calls('GET /v1/skins/votes').last.query['ids'], _id(98));
    await unmount(tester);
  });

  testWidgets(
    'Community outage keeps actual catalog without manufactured ratings',
    (tester) async {
      env.server.json('GET /v1/skins/votes', {
        'error': {'code': 'server_error'},
      }, status: 503);
      await open(tester);
      expect(find.text('Skin 000'), findsOneWidget);
      expect(find.text('5,0'), findsNothing);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );
}
