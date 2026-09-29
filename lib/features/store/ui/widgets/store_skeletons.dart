import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/skeleton.dart';

/// Loading placeholders shaped like the store segments (VF §6: every screen
/// has a skeleton).
enum StoreSkeletonKind { daily, nightMarket, accessories, bundles }

class StoreSkeleton extends StatelessWidget {
  const StoreSkeleton({super.key, required this.kind});

  final StoreSkeletonKind kind;

  @override
  Widget build(BuildContext context) {
    return SkeletonShimmer(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Skeleton(width: 190, height: 16, shimmer: false),
            const SizedBox(height: 16),
            ...switch (kind) {
              StoreSkeletonKind.daily => [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  const Skeleton(height: 176, shimmer: false),
                ],
              ],
              StoreSkeletonKind.nightMarket => [
                for (var r = 0; r < 3; r++) ...[
                  if (r > 0) const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(child: Skeleton(height: 210, shimmer: false)),
                      SizedBox(width: 12),
                      Expanded(child: Skeleton(height: 210, shimmer: false)),
                    ],
                  ),
                ],
              ],
              StoreSkeletonKind.accessories => [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  const Row(
                    children: [
                      Skeleton(width: 56, height: 56, shimmer: false),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Skeleton(height: 16, shimmer: false),
                            SizedBox(height: 8),
                            Skeleton(width: 120, height: 12, shimmer: false),
                          ],
                        ),
                      ),
                      SizedBox(width: 12),
                      Skeleton(width: 56, height: 16, shimmer: false),
                    ],
                  ),
                ],
              ],
              StoreSkeletonKind.bundles => [
                for (var i = 0; i < 2; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Skeleton(shimmer: false, height: null),
                  ),
                ],
              ],
            },
          ],
        ),
      ),
    );
  }
}
