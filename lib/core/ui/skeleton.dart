import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';

/// Animated shimmer applied to its skeleton descendants.
class SkeletonShimmer extends StatefulWidget {
  const SkeletonShimmer({super.key, required this.child});

  final Widget child;

  @override
  State<SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = valColorsOf(context);
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final t = _controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) => LinearGradient(
            begin: Alignment(-1 - 2 + 4 * t, 0),
            end: Alignment(1 - 2 + 4 * t, 0),
            colors: [
              colors.skeletonBase,
              colors.skeletonHighlight,
              colors.skeletonBase,
            ],
            stops: const [0.25, 0.5, 0.75],
          ).createShader(bounds),
          child: child,
        );
      },
    );
  }
}

/// A placeholder box. Wrap groups in [SkeletonShimmer] (single boxes shimmer
/// on their own when [shimmer] is true).
class Skeleton extends StatelessWidget {
  const Skeleton({
    super.key,
    this.width,
    this.height = 16,
    this.radius = 6,
    this.shimmer = true,
  });

  final double? width;
  final double? height;
  final double radius;
  final bool shimmer;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: valColorsOf(context).skeletonBase,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
    return shimmer ? SkeletonShimmer(child: box) : box;
  }
}

/// A generic list skeleton ([itemCount] rows of [itemHeight]).
class SkeletonList extends StatelessWidget {
  const SkeletonList({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 72,
    this.padding = const EdgeInsets.all(16),
    this.spacing = 12,
  });

  final int itemCount;
  final double itemHeight;
  final EdgeInsets padding;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: ListView.separated(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: itemCount,
        separatorBuilder: (_, _) => SizedBox(height: spacing),
        itemBuilder: (_, _) =>
            Skeleton(height: itemHeight, radius: 16, shimmer: false),
      ),
    );
  }
}

/// A grid skeleton for card layouts.
class SkeletonGrid extends StatelessWidget {
  const SkeletonGrid({
    super.key,
    this.itemCount = 4,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.4,
    this.padding = const EdgeInsets.all(16),
  });

  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: GridView.count(
        padding: padding,
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        children: [
          for (var i = 0; i < itemCount; i++) const Skeleton(shimmer: false),
        ],
      ),
    );
  }
}
