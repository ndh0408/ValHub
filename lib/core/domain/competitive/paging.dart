import 'package:flutter/foundation.dart';

import '../../config/app_constants.dart';
import '../../network/riot_exception.dart';

/// Riot's page size limit for P-12 / P-13 (SUMMARY §1 #9).
const kRiotPageSize = RiotClientConstants.maxPageSize;

/// State of an infinitely scrolled list ("Tải thêm" footer).
///
/// The first page's errors surface as the provider's `AsyncError`; errors of
/// later pages are kept in [loadMoreError] next to the items already
/// loaded.
@immutable
class PagedState<T> {
  const PagedState({
    this.items = const [],
    this.hasMore = true,
    this.isLoadingMore = false,
    this.loadMoreError,
    this.total,
  });

  final List<T> items;
  final bool hasMore;
  final bool isLoadingMore;
  final Object? loadMoreError;

  /// Total count reported by Riot (P-13 `Total`), when known.
  final int? total;

  bool get isEmpty => items.isEmpty;

  PagedState<T> copyWith({
    List<T>? items,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError,
    bool clearError = false,
    int? total,
  }) => PagedState<T>(
    items: items ?? this.items,
    hasMore: hasMore ?? this.hasMore,
    isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    loadMoreError: clearError ? null : (loadMoreError ?? this.loadMoreError),
    total: total ?? this.total,
  );
}

/// `400 BAD_PARAMETER`: the page starts past the end of the list
/// (SUMMARY §7.8). A normal end of pagination, not an error.
bool isPastEndError(Object error) =>
    error is RiotApiException &&
    error.status == 400 &&
    (error.errorCode ?? '').toUpperCase() == 'BAD_PARAMETER';
