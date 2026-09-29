import 'package:material_ui/material_ui.dart';

import '../../../../core/theme/app_theme.dart';
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
            // Countdown pill.
            const Skeleton(width: 190, height: 30, radius: 15, shimmer: false),
            const SizedBox(height: 16),
            ...switch (kind) {
              StoreSkeletonKind.daily => [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  const _DailyCardSkeleton(),
                ],
              ],
              StoreSkeletonKind.nightMarket => [
                for (var r = 0; r < 3; r++) ...[
                  if (r > 0) const SizedBox(height: 12),
                  const Row(
                    children: [
                      Expanded(
                        child: Skeleton(
                          height: 210,
                          radius: 16,
                          shimmer: false,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Skeleton(
                          height: 210,
                          radius: 16,
                          shimmer: false,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
              StoreSkeletonKind.accessories => [
                for (var i = 0; i < 4; i++) ...[
                  if (i > 0) const SizedBox(height: 20),
                  const Row(
                    children: [
                      Skeleton(
                        width: 60,
                        height: 60,
                        radius: 12,
                        shimmer: false,
                      ),
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
                      Skeleton(
                        width: 72,
                        height: 28,
                        radius: 14,
                        shimmer: false,
                      ),
                    ],
                  ),
                ],
              ],
              StoreSkeletonKind.bundles => [
                for (var i = 0; i < 2; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Skeleton(shimmer: false, height: null, radius: 16),
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

/// Same shape as `DailyOfferCard`: a 2.2:1 card with a centered render and
/// the name / price row at the bottom.
class _DailyCardSkeleton extends StatelessWidget {
  const _DailyCardSkeleton();

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 2.8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: valColorsOf(context).skeletonBase,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
        child: const Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                child: Skeleton(height: null, radius: 12, shimmer: false),
              ),
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Skeleton(width: 18, height: 18, radius: 9, shimmer: false),
                SizedBox(width: 8),
                Expanded(child: Skeleton(height: 16, shimmer: false)),
                SizedBox(width: 40),
                Skeleton(width: 64, height: 16, shimmer: false),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
