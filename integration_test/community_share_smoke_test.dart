import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/features/community/data/community_models.dart';
import 'package:valvn/features/community/providers/post_share.dart';
import 'package:valvn/features/community/ui/feed/post_share_button.dart';

/// Run only on isolated emulator 5582. The native QA controller cancels the
/// chooser with Back; no destination is selected and no real post is created.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets('native public post share opens and returns after cancellation', (
    tester,
  ) async {
    final defaults = ProviderContainer();
    final nativeShare = defaults.read(communityPostSharerProvider);
    addTearDown(defaults.dispose);
    var completed = false;
    Object? failure;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          communityPostSharerProvider.overrideWithValue(({
            required text,
            required subject,
            origin,
          }) async {
            debugPrint('VANHUB_NATIVE_POST_SHARE_OPENING');
            try {
              await nativeShare(text: text, subject: subject, origin: origin);
            } catch (error) {
              failure = error;
              rethrow;
            } finally {
              completed = true;
            }
          }),
        ],
        child: MaterialApp(
          locale: const Locale('vi'),
          supportedLocales: const [Locale('vi')],
          localizationsDelegates: appLocalizationsDelegates,
          home: const Scaffold(
            body: Center(
              child: PostShareButton(
                post: CommunityPost(
                  id: 'vanhub-qa-public-post',
                  author: CommunityAuthor(
                    id: 'qa-author',
                    gameName: 'ValHub QA',
                    tagLine: 'QA',
                  ),
                  body:
                      'Synthetic native share fixture; no real community post.',
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Chia sẻ'));
    await tester.pump();
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey('share-post-vanhub-qa-public-post')),
          )
          .onPressed,
      isNull,
    );
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 90));
      while (!completed && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 100));
      }
    });
    expect(
      completed,
      isTrue,
      reason: 'Native QA controller must cancel the chooser',
    );
    expect(failure, isNull);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey('share-post-vanhub-qa-public-post')),
          )
          .onPressed,
      isNotNull,
    );
    expect(tester.takeException(), isNull);
    debugPrint('VANHUB_NATIVE_POST_SHARE_CANCELLED');
  });
}
