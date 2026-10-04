import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/community/ui/skins/skin_discussion.dart';
import 'package:valvn/features/community/providers/skin_comment_providers.dart';

import '../community_test_env.dart';
import '../../../helpers/l10n.dart';

class _Host extends ConsumerWidget {
  const _Host();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puuid = ref.watch(activePuuidProvider);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SkinDiscussionSliver(
            key: ValueKey(puuid),
            skinKey: (puuid: puuid, skinUuid: reaverSkin),
          ),
        ],
      ),
    );
  }
}

Map<String, Object?> _comment(
  String id, {
  String body = 'Comment',
  bool mine = false,
}) => {
  ...commentJson(id, body: body),
  'skinUuid': reaverSkin,
  'author': authorJson(id: mine ? meId : otherId),
}..remove('postId');

void main() {
  late CommunityTestEnv env;
  setUp(() async {
    env = await CommunityTestEnv.create();
    env.server.json('GET /v1/skins/*/comments', page([]));
  });

  Future<void> open(WidgetTester tester) async {
    await pumpCommunity(tester, env, const _Host());
    await settle(tester);
  }

  Future<void> switchAccount(WidgetTester tester) async {
    final second = Account.fromJson({
      ...meAccount.toJson(),
      'puuid': 'bbbbbbbb-0000-0000-0000-00000000000b',
      'gameName': 'Second',
    })!;
    await env.prefs.setJson(PrefKeys.accounts, [
      meAccount.toJson(),
      second.toJson(),
    ]);
    final ref = ProviderScope.containerOf(tester.element(find.byType(_Host)));
    ref.read(accountsProvider.notifier).reload();
    ref.read(activePuuidProvider.notifier).select(second.puuid);
    await settle(tester);
  }

  testWidgets('plain comments do not call ownership, ratings or votes', (
    tester,
  ) async {
    env.server.json('POST /v1/skins/*/comments', _comment('new', mine: true));
    await open(tester);
    await tester.enterText(
      find.byKey(const ValueKey('skin-comment-input')),
      'A question about effects',
    );
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('skin-comment-send')));
    await settle(tester);
    final request = env.server.calls('POST /v1/skins/*/comments').single;
    expect(request.json, {
      'body': 'A question about effects',
      'language': 'vi',
    });
    expect(request.headers['Idempotency-Key'], isNotEmpty);
    expect(env.server.calls('PUT /v1/skins/*/review'), isEmpty);
    expect(env.server.calls('PUT /v1/skins/*/vote'), isEmpty);
    expect(find.byKey(const ValueKey('skin-comment-new')), findsOneWidget);
    await unmount(tester);
  });

  testWidgets(
    'failed delivery preserves draft and retry key; duplicate taps send once',
    (tester) async {
      final gate = Completer<void>();
      env.server
        ..json('POST /v1/skins/*/comments', {
          'error': {'code': 'server_error'},
        }, status: 503)
        ..hold('POST /v1/skins/*/comments', gate);
      await open(tester);
      await tester.enterText(
        find.byKey(const ValueKey('skin-comment-input')),
        'Retry this',
      );
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('skin-comment-send')));
      await settle(tester);
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('skin-comment-send')));
      await settle(tester);
      expect(env.server.calls('POST /v1/skins/*/comments'), hasLength(1));
      gate.complete();
      await settle(tester);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        'Retry this',
      );
      env.server.json('POST /v1/skins/*/comments', _comment('new', mine: true));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('skin-comment-send')));
      await settle(tester);
      final calls = env.server.calls('POST /v1/skins/*/comments');
      expect(calls, hasLength(2));
      expect(
        calls[0].headers['Idempotency-Key'],
        calls[1].headers['Idempotency-Key'],
      );
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await unmount(tester);
    },
  );

  testWidgets('account switch isolates drafts and late responses', (
    tester,
  ) async {
    final gate = Completer<void>();
    env.server
      ..json('POST /v1/skins/*/comments', _comment('late', mine: true))
      ..hold('POST /v1/skins/*/comments', gate);
    await open(tester);
    await tester.enterText(find.byType(TextField), 'Draft A');
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('skin-comment-send')));
    await settle(tester);
    await switchAccount(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    await tester.enterText(find.byType(TextField), 'Draft B');
    gate.complete();
    await settle(tester);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      'Draft B',
    );
    expect(find.byKey(const ValueKey('skin-comment-late')), findsNothing);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  testWidgets(
    'plain comment supports existing report flow with correct target',
    (tester) async {
      env.server
        ..json('GET /v1/skins/*/comments', page([_comment('c1')]))
        ..json('POST /v1/reports', null, status: 204);
      await open(tester);
      await tester.tap(find.byTooltip(tl.communityMoreActions));
      await settle(tester);
      await tester.tap(find.text(tl.communityReport));
      await settle(tester);
      await tester.tap(find.text('Quấy rối, xúc phạm'));
      await settle(tester);
      await tester.tap(find.text(tl.communitySend));
      await settle(tester);
      expect(env.server.calls('POST /v1/reports').single.json, {
        'targetType': 'skin_comment',
        'targetId': 'c1',
        'reason': 'harassment',
      });
      await unmount(tester);
    },
  );

  testWidgets('own comment deletes after confirmation', (tester) async {
    env.server
      ..json('GET /v1/skins/*/comments', page([_comment('c1', mine: true)]))
      ..json('DELETE /v1/skin-comments/c1', null, status: 204);
    await open(tester);
    await tester.tap(find.byTooltip(tl.communityMoreActions));
    await settle(tester);
    await tester.tap(find.text(tl.communityDeleteComment));
    await settle(tester);
    await tester.tap(find.text(tl.communityDelete));
    await settle(tester);
    expect(env.server.calls('DELETE /v1/skin-comments/c1'), hasLength(1));
    expect(find.byKey(const ValueKey('skin-comment-c1')), findsNothing);
    await unmount(tester);
  });

  test(
    'appending while an older page is incomplete refetches without reordering',
    () async {
      // Test the shared provider directly: no viewport can eagerly load the cursor.
      env.server
        ..json(
          'GET /v1/skins/*/comments',
          page([_comment('old')], next: 'cursor'),
        )
        ..json('POST /v1/skins/*/comments', _comment('new', mine: true));
      final c = env.container();
      addTearDown(c.dispose);
      final p = skinCommentsProvider((puuid: mePuuid, skinUuid: reaverSkin));
      c.listen(p, (_, _) {});
      await c.read(p.future);
      await c.read(p.notifier).add('New comment');
      await c.read(p.future);
      expect(c.read(p).requireValue.items.map((c) => c.id), ['old']);
      expect(env.server.calls('GET /v1/skins/*/comments'), hasLength(2));
    },
  );
  for (final width in [320.0, 360.0, 393.0, 600.0]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('skin discussion accessible at $width dp, $scale text, RTL', (
        tester,
      ) async {
        env.server.json(
          'GET /v1/skins/*/comments',
          page([
            _comment(
              'rtl',
              body: 'A long public discussion with effects and animation',
            ),
          ]),
        );
        await pumpCommunity(
          tester,
          env,
          Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: TextScaler.linear(scale)),
              child: const Directionality(
                textDirection: TextDirection.rtl,
                child: _Host(),
              ),
            ),
          ),
          size: Size(width, 1500),
        );
        await settle(tester);
        expect(tester.takeException(), isNull);
        final send = find.byKey(const ValueKey('skin-comment-send'));
        expect(send, findsOneWidget);
        expect(tester.getSize(send).height, greaterThanOrEqualTo(48));
        await unmount(tester);
      });
    }
  }
}
