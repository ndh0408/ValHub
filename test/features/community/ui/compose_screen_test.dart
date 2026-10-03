import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/data/compose_draft.dart';
import 'package:valvn/features/community/data/image_source.dart';
import 'package:valvn/features/community/providers/consent_providers.dart';
import 'package:valvn/features/community/ui/compose_screen.dart';

import '../community_test_env.dart';

FilledButton _publishButton(WidgetTester tester) => tester.widget<FilledButton>(
  find.ancestor(
    of: find.text(CommunityStrings.publish),
    matching: find.byType(FilledButton),
  ),
);

/// Opens the composer from a button so it can be popped.
class _Launcher extends StatelessWidget {
  const _Launcher({this.draft});

  final ComposeDraft? draft;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => ComposeScreen(draft: draft)),
        ),
        child: const Text('mở'),
      ),
    ),
  );
}

void main() {
  late CommunityTestEnv env;
  setUp(() async => env = await CommunityTestEnv.create());

  Future<ProviderContainer> addSecondAccount(WidgetTester tester) async {
    final second = Account.fromJson({
      ...meAccount.toJson(),
      'puuid': 'bbbbbbbb-0000-0000-0000-00000000000b',
      'gameName': 'Second',
    })!;
    await env.prefs.setJson(PrefKeys.accounts, [
      meAccount.toJson(),
      second.toJson(),
    ]);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(ComposeScreen)),
    );
    container.read(accountsProvider.notifier).reload();
    container.read(activePuuidProvider.notifier).select(second.puuid);
    await settle(tester);
    return container;
  }

  testWidgets(
    'account switch clears private text, photos and store attachment',
    (tester) async {
      const draft = ComposeDraft(
        kind: PostKind.store,
        body: 'Private draft A',
        payload: PostPayload(
          offers: [PayloadOffer(skinUuid: reaverSkin, cost: 1775)],
        ),
      );
      env.picker.next = [PickedImage(bytes: jpegBytes(), name: 'a.jpg')];
      await pumpCommunity(tester, env, const ComposeScreen(draft: draft));
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.addPhotos));
      await settle(tester);
      expect(find.byTooltip(CommunityStrings.removeAttachment), findsOneWidget);
      expect(find.byTooltip(CommunityStrings.removePhoto), findsOneWidget);

      await addSecondAccount(tester);
      expect(find.text('Private draft A'), findsNothing);
      expect(find.byTooltip(CommunityStrings.removeAttachment), findsNothing);
      expect(find.byTooltip(CommunityStrings.removePhoto), findsNothing);
      expect(_publishButton(tester).onPressed, isNull);
      expect(env.server.calls('POST /v1/posts'), isEmpty);
      await unmount(tester);
    },
  );

  testWidgets(
    'old publish response cannot close or clear the next account draft',
    (tester) async {
      final gate = Completer<void>();
      env.server
        ..json('POST /v1/posts', postJson('new'))
        ..hold('POST /v1/posts', gate);
      await pumpCommunity(tester, env, const _Launcher());
      await tester.tap(find.text('mở'));
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Draft A');
      await tester.pump();
      await tester.tap(find.text(CommunityStrings.publish));
      await settle(tester);
      expect(env.server.calls('POST /v1/posts'), hasLength(1));

      await addSecondAccount(tester);
      await tester.enterText(find.byType(TextField), 'Draft B');
      gate.complete();
      await settle(tester, frames: 25);
      expect(find.byType(ComposeScreen), findsOneWidget);
      expect(find.text('Draft B'), findsOneWidget);
      expect(find.text(CommunityStrings.posted), findsNothing);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    },
  );

  testWidgets('closing during an upload stops subsequent uploads and posting', (
    tester,
  ) async {
    final gate = Completer<void>();
    env.picker.next = [
      PickedImage(bytes: jpegBytes(), name: 'a.jpg'),
      PickedImage(bytes: jpegBytes(), name: 'b.jpg'),
    ];
    env.server
      ..json('POST /v1/media', {'key': 'm1', 'url': 'https://val.test/m1.jpg'})
      ..hold('POST /v1/media', gate)
      ..json('POST /v1/posts', postJson('new'));
    await pumpCommunity(tester, env, const _Launcher());
    await tester.tap(find.text('mở'));
    await settle(tester);
    await tester.tap(find.text(CommunityStrings.addPhotos));
    await settle(tester);
    await tester.tap(find.text(CommunityStrings.publish));
    await settle(tester);
    expect(env.server.calls('POST /v1/media'), hasLength(1));
    Navigator.of(tester.element(find.byType(ComposeScreen))).pop();
    await settle(tester, frames: 30);
    expect(find.byType(ComposeScreen), findsNothing);
    gate.complete();
    await settle(tester);
    expect(env.server.calls('POST /v1/media'), hasLength(1));
    expect(env.server.calls('POST /v1/posts'), isEmpty);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });

  test('validation rules', () {
    expect(
      validateCompose(body: '  ', images: 0, hasAttachment: false),
      ComposeProblem.empty,
    );
    expect(validateCompose(body: '', images: 1, hasAttachment: false), isNull);
    expect(validateCompose(body: '', images: 0, hasAttachment: true), isNull);
    expect(
      validateCompose(
        body: 'a' * (kMaxPostLength + 1),
        images: 0,
        hasAttachment: false,
      ),
      ComposeProblem.tooLong,
    );
    expect(
      validateCompose(
        body: 'á' * kMaxPostLength,
        images: 0,
        hasAttachment: false,
      ),
      isNull,
    );
  });

  testWidgets('empty or too long posts cannot be published', (tester) async {
    await pumpCommunity(tester, env, const ComposeScreen());
    await settle(tester);
    expect(find.text(CommunityStrings.composerTitle), findsOneWidget);
    expect(_publishButton(tester).onPressed, isNull);
    expect(find.text('0/1.000'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Xin chào anh em');
    await tester.pump();
    expect(_publishButton(tester).onPressed, isNotNull);

    await tester.enterText(find.byType(TextField), 'x' * 1001);
    await tester.pump();
    expect(find.text('1.001/1.000'), findsOneWidget);
    expect(find.text(CommunityStrings.tooLong(1000)), findsOneWidget);
    expect(_publishButton(tester).onPressed, isNull);
    await unmount(tester);
  });

  testWidgets('images: pick up to 4, remove, upload then publish', (
    tester,
  ) async {
    env.picker.next = [
      PickedImage(bytes: jpegBytes(), name: 'a.jpg'),
      PickedImage(bytes: jpegBytes(8), name: 'b.jpg'),
    ];
    var n = 0;
    env.server
      ..on('POST /v1/media', (_) {
        n++;
        return FakeResponse(200, {
          'key': 'm$n',
          'url': 'https://val.test/m$n.jpg',
        });
      })
      ..json('POST /v1/posts', postJson('new', body: ''));
    await tester.pumpWidget(const SizedBox());
    await pumpCommunity(tester, env, const _Launcher());
    await tester.tap(find.text('mở'));
    await settle(tester);

    await tester.tap(find.text(CommunityStrings.addPhotos));
    await settle(tester);
    expect(find.text(CommunityStrings.photoCount(2, 4)), findsOneWidget);
    expect(find.byTooltip(CommunityStrings.removePhoto), findsNWidgets(2));
    expect(_publishButton(tester).onPressed, isNotNull);

    await tester.tap(find.byTooltip(CommunityStrings.removePhoto).first);
    await tester.pump();
    expect(find.text(CommunityStrings.photoCount(1, 4)), findsOneWidget);

    await tester.tap(find.text(CommunityStrings.publish));
    await settle(tester, frames: 30);

    expect(env.server.calls('POST /v1/media'), hasLength(1));
    expect(env.server.calls('POST /v1/posts').single.json, {
      'kind': 'text',
      'body': '',
      'language': 'vi',
      'media': ['m1'],
    });
    expect(find.byType(ComposeScreen), findsNothing);
    expect(find.text(CommunityStrings.posted), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('non-image files are rejected with a message', (tester) async {
    env.picker.next = [
      PickedImage(bytes: jpegBytes()..[0] = 0x00, name: 'doc.pdf'),
    ];
    await pumpCommunity(tester, env, const ComposeScreen());
    await settle(tester);
    await tester.tap(find.text(CommunityStrings.addPhotos));
    await settle(tester);
    expect(find.text(CommunityStrings.errorImageType), findsOneWidget);
    expect(find.text(CommunityStrings.photoCount(0, 4)), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('store draft is attached and published as a store post', (
    tester,
  ) async {
    env.server.json('POST /v1/posts', postJson('s1', kind: 'store'));
    const draft = ComposeDraft(
      kind: PostKind.store,
      payload: PostPayload(
        date: '2026-09-28',
        offers: [
          PayloadOffer(skinUuid: reaverSkin, cost: 1775),
          PayloadOffer(skinUuid: knifeSkin, cost: 4350),
        ],
      ),
    );
    await pumpCommunity(tester, env, const _Launcher(draft: draft));
    await tester.tap(find.text('mở'));
    await settle(tester);

    expect(find.text('Cửa hàng ngày 28/09'), findsOneWidget);
    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(_publishButton(tester).onPressed, isNotNull);

    await tester.enterText(find.byType(TextField), 'Shop xịn');
    await tester.tap(find.text(CommunityStrings.publish));
    await settle(tester);

    final body = env.server.calls('POST /v1/posts').single.json! as Map;
    expect(body['kind'], 'store');
    expect(body['body'], 'Shop xịn');
    expect((body['payload'] as Map)['offers'], hasLength(2));
    await unmount(tester);
  });

  testWidgets('leaving with a draft asks for confirmation', (tester) async {
    await pumpCommunity(tester, env, const _Launcher());
    await tester.tap(find.text('mở'));
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Nháp');
    await tester.pump();

    await tester.tap(find.byTooltip('Đóng'));
    await settle(tester);
    expect(find.text(CommunityStrings.discardTitle), findsOneWidget);
    await tester.tap(find.text(CommunityStrings.discard));
    await settle(tester, frames: 30);
    expect(find.byType(ComposeScreen), findsNothing);
    await unmount(tester);
  });

  testWidgets('server errors keep the draft and explain', (tester) async {
    env.server.json('POST /v1/posts', {
      'error': {'code': 'rate_limited', 'retryAfter': 600},
    }, status: 429);
    await pumpCommunity(tester, env, const ComposeScreen());
    await settle(tester);
    await tester.enterText(find.byType(TextField), 'Thử đăng');
    await tester.pump();
    await tester.tap(find.text(CommunityStrings.publish));
    await settle(tester);
    expect(
      find.text(CommunityStrings.errorRateLimitedIn('10 phút')),
      findsOneWidget,
    );
    expect(find.text('Thử đăng'), findsOneWidget);
    await unmount(tester);
  });

  group('new server errors', () {
    Future<void> publishWithPhoto(WidgetTester tester) async {
      env.picker.next = [PickedImage(bytes: jpegBytes(), name: 'a.jpg')];
      await pumpCommunity(tester, env, const ComposeScreen());
      await settle(tester);
      await tester.enterText(find.byType(TextField), 'Có ảnh nè');
      await tester.tap(find.text(CommunityStrings.addPhotos));
      await settle(tester);
      await tester.tap(find.text(CommunityStrings.publish));
      await settle(tester, frames: 20);
    }

    testWidgets('storage_full (507): says photos cannot be added, keeps all', (
      tester,
    ) async {
      env.server.json('POST /v1/media', {
        'error': {'code': 'storage_full', 'message': 'disk full'},
      }, status: 507);
      await publishWithPhoto(tester);

      expect(find.text(CommunityStrings.errorStorageFull), findsOneWidget);
      // Nothing was posted; the text and the photo are still there to retry
      // (or to post without the photo).
      expect(env.server.calls('POST /v1/posts'), isEmpty);
      expect(find.text('Có ảnh nè'), findsOneWidget);
      expect(find.text(CommunityStrings.photoCount(1, 4)), findsOneWidget);
      await unmount(tester);
    });

    testWidgets('legacy validation keeps the draft and hides server text', (
      tester,
    ) async {
      const quota =
          'Bạn đã dùng hết 50 MB dung lượng ảnh. Hãy xóa bớt bài có ảnh.';
      env.server.json('POST /v1/media', {
        'error': {'code': 'invalid_input', 'message': quota},
      }, status: 400);
      await publishWithPhoto(tester);

      expect(find.text(quota), findsNothing);
      expect(find.text(CommunityStrings.errorInvalid), findsOneWidget);
      expect(find.text('Có ảnh nè'), findsOneWidget);
      await unmount(tester);
    });

    testWidgets(
      'riot_unavailable while signing in: retry later, the post is kept',
      (tester) async {
        env.server.on(
          'POST /v1/auth/riot',
          (_) => const FakeResponse(
            503,
            {
              'error': {'code': 'riot_unavailable', 'retryAfter': 45},
            },
            {
              'retry-after': ['45'],
            },
          ),
        );
        await pumpCommunity(tester, env, const ComposeScreen());
        await settle(tester);
        await tester.enterText(find.byType(TextField), 'Thử đăng');
        await tester.pump();
        await tester.tap(find.text(CommunityStrings.publish));
        await settle(tester, frames: 20);

        expect(
          find.text(CommunityStrings.errorRiotUnavailableIn('45 giây')),
          findsOneWidget,
        );
        expect(find.text('Thử đăng'), findsOneWidget);
        // Not a refusal: no second attempt, the consent stays, and once
        // Riot is back the same button works.
        expect(env.server.calls('POST /v1/auth/riot'), hasLength(1));
        expect(env.server.calls('POST /v1/posts'), isEmpty);
        expect(env.prefs.getString(communityConsentKey(mePuuid)), 'granted');
        env.server
          ..json('POST /v1/auth/riot', sessionJson())
          ..json('POST /v1/posts', postJson('new', body: 'Thử đăng'));
        await tester.tap(find.text(CommunityStrings.publish));
        await settle(tester, frames: 30);
        expect(env.server.calls('POST /v1/posts'), hasLength(1));
        await unmount(tester);
      },
    );
  });
}
