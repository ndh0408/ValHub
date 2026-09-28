import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:material_ui/material_ui.dart';

import 'skeleton.dart';

/// Long-lived cache for valorant-api / Riot CDN media (URLs are
/// content-addressed by uuid, so they can be cached for weeks; B10).
final CacheManager valMediaCache = CacheManager(
  Config(
    'valMedia',
    stalePeriod: const Duration(days: 30),
    maxNrOfCacheObjects: 3000,
  ),
);

/// Clears the media cache ("Xóa bộ nhớ đệm").
Future<void> clearMediaCache() => valMediaCache.emptyCache();

/// Cached network image with a skeleton placeholder and a quiet error icon.
///
/// A `null` / empty [url] renders the error placeholder, so callers can pass
/// optional content fields straight through.
class NetImage extends StatelessWidget {
  const NetImage(
    this.url, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.borderRadius,
    this.placeholder,
    this.error,
    this.color,
    this.alignment = Alignment.center,
    this.showSkeleton = true,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  /// Replaces the default skeleton placeholder.
  final Widget? placeholder;

  /// Replaces the default error icon.
  final Widget? error;
  final Color? color;
  final Alignment alignment;
  final bool showSkeleton;

  @override
  Widget build(BuildContext context) {
    final u = url;
    Widget child;
    if (u == null || u.isEmpty) {
      child = _error(context);
    } else {
      final dpr = MediaQuery.maybeDevicePixelRatioOf(context) ?? 2;
      child = CachedNetworkImage(
        imageUrl: u,
        cacheManager: valMediaCache,
        width: width,
        height: height,
        fit: fit,
        color: color,
        alignment: alignment,
        memCacheWidth: width == null || !width!.isFinite
            ? null
            : (width! * dpr).round(),
        fadeInDuration: const Duration(milliseconds: 120),
        fadeOutDuration: const Duration(milliseconds: 80),
        placeholder: (context, _) =>
            placeholder ??
            (showSkeleton
                ? Skeleton(width: width, height: height)
                : SizedBox(width: width, height: height)),
        errorWidget: (context, _, _) => _error(context),
      );
    }
    final radius = borderRadius;
    return radius == null
        ? child
        : ClipRRect(borderRadius: radius, child: child);
  }

  Widget _error(BuildContext context) =>
      error ??
      SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Icon(
            Icons.image_not_supported_outlined,
            size: 20,
            color: Theme.of(context).colorScheme.onSurfaceVariant
                .withValues(alpha: 0.5),
          ),
        ),
      );
}
