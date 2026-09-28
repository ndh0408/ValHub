import 'package:material_ui/material_ui.dart';

import '../../core/ui/empty_view.dart';
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

/// S16 full-screen player (stream the Riot CDN mp4; never pre-download).
class SkinVideoView extends StatelessWidget {
  const SkinVideoView({super.key, required this.videoUrl});

  final String videoUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(SkinDetailStrings.playVideo)),
      body: const FeaturePlaceholder(),
    );
  }
}
