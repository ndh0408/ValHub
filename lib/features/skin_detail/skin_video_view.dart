import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:video_player/video_player.dart';

import '../../core/l10n/common_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui/adaptive.dart';
import 'skin_detail_strings.dart';

/// Opens S16 (full-screen looping skin video with a mute toggle) above
/// everything, on the root navigator.
Future<void> openSkinVideo(BuildContext context, {required String videoUrl}) =>
    Navigator.of(context, rootNavigator: true).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (_) => SkinVideoView(videoUrl: videoUrl),
      ),
    );

/// Creates the player for a video URL (injectable for tests).
typedef SkinVideoControllerFactory = VideoPlayerController Function(Uri uri);

VideoPlayerController _networkController(Uri uri) =>
    VideoPlayerController.networkUrl(uri);

/// S16 full-screen player: streams the Riot CDN mp4 (never pre-downloads),
/// loops, tap to pause / resume, mute toggle, "Thử lại" on failure.
class SkinVideoView extends StatefulWidget {
  const SkinVideoView({
    super.key,
    required this.videoUrl,
    this.controllerFactory = _networkController,
  });

  final String videoUrl;
  final SkinVideoControllerFactory controllerFactory;

  @override
  State<SkinVideoView> createState() => _SkinVideoViewState();
}

class _SkinVideoViewState extends State<SkinVideoView> {
  VideoPlayerController? _controller;
  Object? _error;
  bool _ready = false;
  bool _muted = false;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    unawaited(_start());
  }

  Future<void> _start() async {
    _disposeController();
    final uri = Uri.tryParse(widget.videoUrl.trim());
    if (uri == null || !uri.hasScheme) {
      setState(() => _error = const FormatException('video url'));
      return;
    }
    final VideoPlayerController c;
    try {
      c = widget.controllerFactory(uri);
    } on Object catch (e) {
      setState(() => _error = e);
      return;
    }
    _controller = c;
    c.addListener(_onControllerChanged);
    setState(() {
      _error = null;
      _ready = false;
    });
    try {
      await c.initialize();
      if (!mounted || !identical(_controller, c)) return;
      await c.setLooping(true);
      await c.setVolume(_muted ? 0 : 1);
      await c.play();
      if (mounted && identical(_controller, c)) setState(() => _ready = true);
    } on Object catch (e) {
      if (mounted && identical(_controller, c)) setState(() => _error = e);
    }
  }

  void _onControllerChanged() {
    final c = _controller;
    if (c == null || !mounted) return;
    final value = c.value;
    if (value.hasError && _error == null) {
      setState(() => _error = value.errorDescription ?? StateError('video'));
      return;
    }
    if (value.isPlaying != _playing) {
      setState(() => _playing = value.isPlaying);
    }
  }

  void _disposeController() {
    final old = _controller;
    _controller = null;
    if (old == null) return;
    old.removeListener(_onControllerChanged);
    unawaited(old.dispose().catchError((Object _) {}));
  }

  @override
  void dispose() {
    _disposeController();
    super.dispose();
  }

  void _toggleMute() {
    Haptics.selection();
    final next = !_muted;
    setState(() => _muted = next);
    final c = _controller;
    if (c != null && _ready) unawaited(c.setVolume(next ? 0 : 1));
  }

  void _togglePlay() {
    final c = _controller;
    if (c == null || !_ready) return;
    Haptics.light();
    unawaited(c.value.isPlaying ? c.pause() : c.play());
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final Widget body;
    if (_error != null) {
      body = _VideoError(onRetry: () => unawaited(_start()));
    } else if (!_ready || c == null) {
      body = const CircularProgressIndicator.adaptive(
        valueColor: AlwaysStoppedAnimation(Colors.white),
      );
    } else {
      final ratio = c.value.aspectRatio;
      body = Semantics(
        button: true,
        label: _playing ? SkinDetailStrings.pause : SkinDetailStrings.play,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _togglePlay,
          child: SizedBox.expand(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AspectRatio(
                    aspectRatio: ratio.isFinite && ratio > 0 ? ratio : 16 / 9,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        VideoPlayer(c),
                        // Thin scrubbable progress bar along the bottom edge.
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: VideoProgressIndicator(
                            c,
                            allowScrubbing: true,
                            padding: const EdgeInsets.only(top: 12),
                            colors: VideoProgressColors(
                              playedColor: ValColors.red,
                              bufferedColor: Colors.white.withValues(
                                alpha: 0.35,
                              ),
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.15,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedSwitcher(
                    duration: ValMotion.fast,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: _playing
                        ? const SizedBox.shrink()
                        : DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.black.withValues(alpha: 0.45),
                            ),
                            child: const Icon(
                              Icons.play_circle_fill,
                              size: 72,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text(SkinDetailStrings.playVideo),
        actions: [
          IconButton(
            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
            tooltip: _muted ? SkinDetailStrings.unmute : SkinDetailStrings.mute,
            onPressed: _toggleMute,
          ),
        ],
      ),
      body: SafeArea(child: Center(child: body)),
    );
  }
}

class _VideoError extends StatelessWidget {
  const _VideoError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.videocam_off_outlined,
            size: 40,
            color: Colors.white70,
          ),
          const SizedBox(height: 12),
          Text(
            SkinDetailStrings.videoError,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onRetry,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
            ),
            icon: const Icon(Icons.refresh),
            label: const Text(CommonStrings.retry),
          ),
        ],
      ),
    );
  }
}
