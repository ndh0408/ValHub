import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/common_strings.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/util/format.dart';
import '../../community_strings.dart';
import '../../data/community_models.dart';

/// Hero tag of image [index] of post [postId].
String mediaHeroTag(String postId, int index) => 'community-$postId-$index';

/// 1–4 post images: one wide, two side by side, one large + two stacked, or
/// a 2 × 2 grid. Tapping opens the full-screen viewer.
class MediaGrid extends StatelessWidget {
  const MediaGrid({super.key, required this.postId, required this.media});

  final String postId;
  final List<PostMedia> media;

  @override
  Widget build(BuildContext context) {
    final items = media.take(4).toList();
    if (items.isEmpty) return const SizedBox.shrink();
    Widget tile(int i) => _MediaTile(
      url: items[i].url,
      heroTag: mediaHeroTag(postId, i),
      label: CommunityStrings.imageOf(i + 1, items.length),
      onTap: () => unawaited(
        openImageViewer(
          context,
          urls: [for (final m in items) m.url],
          initialIndex: i,
          heroTags: [
            for (var j = 0; j < items.length; j++) mediaHeroTag(postId, j),
          ],
        ),
      ),
    );
    const gap = 4.0;
    final Widget grid = switch (items.length) {
      1 => AspectRatio(aspectRatio: 16 / 10, child: tile(0)),
      2 => AspectRatio(
        aspectRatio: 2,
        child: Row(
          children: [
            Expanded(child: tile(0)),
            const SizedBox(width: gap),
            Expanded(child: tile(1)),
          ],
        ),
      ),
      3 => AspectRatio(
        aspectRatio: 1.5,
        child: Row(
          children: [
            Expanded(flex: 2, child: tile(0)),
            const SizedBox(width: gap),
            Expanded(
              child: Column(
                children: [
                  Expanded(child: tile(1)),
                  const SizedBox(height: gap),
                  Expanded(child: tile(2)),
                ],
              ),
            ),
          ],
        ),
      ),
      _ => AspectRatio(
        aspectRatio: 1.25,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(child: tile(0)),
                  const SizedBox(width: gap),
                  Expanded(child: tile(1)),
                ],
              ),
            ),
            const SizedBox(height: gap),
            Expanded(
              child: Row(
                children: [
                  Expanded(child: tile(2)),
                  const SizedBox(width: gap),
                  Expanded(child: tile(3)),
                ],
              ),
            ),
          ],
        ),
      ),
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(ValRadius.small),
      child: grid,
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({
    required this.url,
    required this.heroTag,
    required this.label,
    required this.onTap,
  });

  final String url;
  final String heroTag;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      image: true,
      label: label,
      excludeSemantics: true,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ColoredBox(
            color: Theme.of(context).colorScheme.surfaceContainerHigh,
            child: Hero(
              tag: heroTag,
              child: NetImage(url, fit: BoxFit.cover),
            ),
          ),
          Material(
            type: MaterialType.transparency,
            child: InkWell(onTap: onTap),
          ),
        ],
      ),
    );
  }
}

/// Full-screen image viewer: swipe between images, pinch to zoom, hero
/// transition from the grid. A normal page route, so the iOS back-swipe and
/// the Android back gesture close it.
Future<void> openImageViewer(
  BuildContext context, {
  required List<String> urls,
  int initialIndex = 0,
  List<String>? heroTags,
}) => Navigator.of(context, rootNavigator: true).push(
  MaterialPageRoute<void>(
    builder: (_) => ImageViewerScreen(
      urls: urls,
      initialIndex: initialIndex,
      heroTags: heroTags,
    ),
  ),
);

class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({
    super.key,
    required this.urls,
    this.initialIndex = 0,
    this.heroTags,
  });

  final List<String> urls;
  final int initialIndex;
  final List<String>? heroTags;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  late final PageController _pages = PageController(
    initialPage: widget.initialIndex,
  );
  late int _index = widget.initialIndex;

  /// Paging is locked while an image is zoomed in.
  bool _zoomed = false;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tags = widget.heroTags;
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pages,
            physics: _zoomed
                ? const NeverScrollableScrollPhysics()
                : const PageScrollPhysics(),
            itemCount: widget.urls.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) {
              final image = NetImage(
                widget.urls[i],
                fit: BoxFit.contain,
                showSkeleton: false,
              );
              return _ZoomablePage(
                key: ValueKey(widget.urls[i]),
                onZoomChanged: (z) {
                  if (z != _zoomed) setState(() => _zoomed = z);
                },
                child: tags != null && i < tags.length
                    ? Hero(tag: tags[i], child: image)
                    : image,
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  IconButton(
                    tooltip: CommonStrings.close,
                    color: Colors.white,
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const Spacer(),
                  if (widget.urls.length > 1)
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(ValRadius.pill),
                      ),
                      child: Text(
                        CommunityStrings.pageOf(
                          formatNumber(_index + 1),
                          formatNumber(widget.urls.length),
                        ),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// One pinch-zoomable page; double tap toggles 2.5× zoom.
class _ZoomablePage extends StatefulWidget {
  const _ZoomablePage({
    super.key,
    required this.child,
    required this.onZoomChanged,
  });

  final Widget child;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<_ZoomablePage> createState() => _ZoomablePageState();
}

class _ZoomablePageState extends State<_ZoomablePage> {
  final TransformationController _transform = TransformationController();
  TapDownDetails? _doubleTapAt;

  @override
  void dispose() {
    _transform.dispose();
    super.dispose();
  }

  void _report() =>
      widget.onZoomChanged(_transform.value.getMaxScaleOnAxis() > 1.01);

  void _toggleZoom() {
    if (_transform.value.getMaxScaleOnAxis() > 1.01) {
      _transform.value = Matrix4.identity();
    } else {
      final p = _doubleTapAt?.localPosition ?? Offset.zero;
      const s = 2.5;
      _transform.value = Matrix4.identity()
        ..translateByDouble(-p.dx * (s - 1), -p.dy * (s - 1), 0, 1)
        ..scaleByDouble(s, s, 1, 1);
    }
    _report();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTapDown: (d) => _doubleTapAt = d,
      onDoubleTap: _toggleZoom,
      child: InteractiveViewer(
        transformationController: _transform,
        minScale: 1,
        maxScale: 4,
        onInteractionEnd: (_) => _report(),
        child: Center(child: widget.child),
      ),
    );
  }
}
