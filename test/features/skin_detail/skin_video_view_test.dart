import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/features/skin_detail/skin_detail_strings.dart';
import 'package:valvn/features/skin_detail/skin_video_view.dart';
import 'package:video_player/video_player.dart';

/// A controller that never touches the platform plugin.
class _FakeController extends VideoPlayerController {
  _FakeController({this.fail = false})
    : super.networkUrl(Uri.parse('https://media.valorant-api.com/v.mp4'));

  final bool fail;

  @override
  Future<void> initialize() async {
    if (fail) throw StateError('no network');
    value = value.copyWith(
      isInitialized: true,
      size: const Size(1920, 1080),
      duration: const Duration(seconds: 12),
    );
  }

  @override
  Future<void> play() async => value = value.copyWith(isPlaying: true);

  @override
  Future<void> pause() async => value = value.copyWith(isPlaying: false);

  @override
  Future<void> setLooping(bool looping) async =>
      value = value.copyWith(isLooping: looping);

  @override
  Future<void> setVolume(double volume) async =>
      value = value.copyWith(volume: volume);
}

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 16));
  }
}

void main() {
  testWidgets('plays looping, tap pauses, mute toggles', (tester) async {
    final controllers = <_FakeController>[];
    await tester.pumpWidget(
      MaterialApp(
        home: SkinVideoView(
          videoUrl: 'https://media.valorant-api.com/v.mp4',
          controllerFactory: (_) {
            final c = _FakeController();
            controllers.add(c);
            return c;
          },
        ),
      ),
    );
    await _settle(tester);

    final c = controllers.single;
    expect(find.byType(VideoPlayer), findsOneWidget);
    expect(c.value.isPlaying, isTrue);
    expect(c.value.isLooping, isTrue);
    expect(c.value.volume, 1);
    expect(find.byIcon(Icons.play_circle_fill), findsNothing);

    // The tap-to-pause detector sits above the player.
    await tester.tapAt(tester.getCenter(find.byType(VideoPlayer)));
    await _settle(tester);
    expect(c.value.isPlaying, isFalse);
    expect(find.byIcon(Icons.play_circle_fill), findsOneWidget);

    await tester.tap(find.byTooltip(SkinDetailStrings.mute));
    await _settle(tester);
    expect(c.value.volume, 0);
    expect(find.byTooltip(SkinDetailStrings.unmute), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('a failure shows "Thử lại", which retries with a new player', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SkinVideoView(
          videoUrl: 'https://media.valorant-api.com/v.mp4',
          controllerFactory: (_) => _FakeController(fail: calls++ == 0),
        ),
      ),
    );
    await _settle(tester);

    expect(find.text(SkinDetailStrings.videoError), findsOneWidget);
    await tester.tap(find.text(CommonStrings.retry));
    await _settle(tester);
    expect(calls, 2);
    expect(find.byType(VideoPlayer), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an invalid URL never builds a player', (tester) async {
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: SkinVideoView(
          videoUrl: 'không phải url',
          controllerFactory: (_) {
            calls++;
            return _FakeController();
          },
        ),
      ),
    );
    await _settle(tester);

    expect(calls, 0);
    expect(find.text(SkinDetailStrings.videoError), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}
