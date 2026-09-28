import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/common_strings.dart';
import 'empty_view.dart';
import 'error_view.dart';
import 'skeleton.dart';

/// Renders an [AsyncValue] with the standard states (VF §6: skeleton, empty,
/// error with "Thử lại", data).
///
/// ```dart
/// AsyncValueView(
///   value: ref.watch(storefrontProvider(puuid)),
///   onRetry: () => ref.invalidate(storefrontProvider(puuid)),
///   isEmpty: (s) => s.offers.isEmpty,
///   data: (s) => StoreGrid(s),
/// )
/// ```
///
/// When a refresh fails but older data exists, the data stays visible with a
/// compact error row above it.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.data,
    this.onRetry,
    this.loading,
    this.isEmpty,
    this.empty,
    this.emptyMessage = CommonStrings.noData,
    this.puuid,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final VoidCallback? onRetry;

  /// Replaces the default [SkeletonList].
  final Widget? loading;
  final bool Function(T data)? isEmpty;

  /// Replaces the default [EmptyView].
  final Widget? empty;
  final String emptyMessage;

  /// Account to re-login for `NeedsLoginException`.
  final String? puuid;

  @override
  Widget build(BuildContext context) {
    final v = value;
    if (v.hasValue) {
      final d = v.requireValue;
      final content = (isEmpty?.call(d) ?? false)
          ? (empty ?? EmptyView(message: emptyMessage))
          : data(d);
      if (v.hasError && !v.isLoading) {
        final banner = ErrorView(
          error: v.error!,
          onRetry: onRetry,
          puuid: puuid,
          compact: true,
        );
        return LayoutBuilder(
          builder: (context, constraints) => constraints.hasBoundedHeight
              ? Column(
                  children: [
                    banner,
                    Expanded(child: content),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [banner, content],
                ),
        );
      }
      return content;
    }
    if (v.hasError && !v.isLoading) {
      return ErrorView(error: v.error!, onRetry: onRetry, puuid: puuid);
    }
    return loading ?? const SkeletonList();
  }
}
