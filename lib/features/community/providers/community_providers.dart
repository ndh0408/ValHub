import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/config/app_constants.dart';
import '../../../core/config/remote_config.dart';
import '../../../core/l10n/locale.dart';
import '../../../core/logging/session_log.dart';
import '../../../core/network/dio_factory.dart';
import '../../../core/storage/secure_store.dart';
import '../../../core/util/clock.dart';
import '../data/community_api.dart';
import '../data/community_auth.dart';
import '../data/community_http.dart';
import '../data/community_models.dart';
import '../data/image_source.dart';
import 'consent_providers.dart';

/// Community server base URL: remote config `communityBaseUrl`, else
/// [AppConstants.communityBaseUrl].
final communityBaseUrlProvider = Provider<String>(
  (ref) =>
      ref.watch(remoteConfigProvider.select((c) => c.communityBaseUrl)) ??
      AppConstants.communityBaseUrl,
);

/// Whether the community features are available (usable base URL).
final communityEnabledProvider = Provider<bool>(
  (ref) => isUsableCommunityUrl(ref.watch(communityBaseUrlProvider)),
);

/// JSON transport (session-logged dio; never logs headers or bodies).
final communityHttpProvider = Provider<CommunityHttp>(
  (ref) => CommunityHttp(
    dio: createBaseDio(log: ref.watch(sessionLogProvider)),
    baseUrl: ref.watch(communityBaseUrlProvider),
  ),
);

/// The app language as a community language code (`vi` today; follows the
/// app locale once ValVN ships more languages).
final communityAppLanguageProvider = Provider<String>(
  (ref) => lfgLanguageForLocale(
    appLocale.languageCode,
    scriptOrCountry: appLocale.scriptCode ?? appLocale.countryCode,
  ),
);

/// Community sessions of the signed-in accounts.
final communityAuthProvider = Provider<CommunityAuth>(
  (ref) => CommunityAuth(
    http: ref.watch(communityHttpProvider),
    store: ref.watch(secureStoreProvider),
    sessions: ref.watch(sessionManagerProvider),
    account: (puuid) => ref.read(accountProvider(puuid.toLowerCase())),
    now: () => ref.read(clockProvider).now(),
    language: () => ref.read(communityAppLanguageProvider),
    hasConsent: (puuid) =>
        ref.read(communityConsentProvider(puuid.toLowerCase())) ==
        CommunityConsent.granted,
  ),
);

/// Every community endpoint.
final communityApiProvider = Provider<CommunityApi>(
  (ref) => CommunityApi(
    http: ref.watch(communityHttpProvider),
    auth: ref.watch(communityAuthProvider),
  ),
);

/// Photo-library picker (overridden in tests).
final communityImagePickerProvider = Provider<CommunityImagePicker>(
  (ref) => const DeviceImagePicker(),
);

/// The community user of an account (signs in on first use). Used to tell
/// the user's own posts apart.
final communityMeProvider = FutureProvider.autoDispose
    .family<CommunityAuthor, String>((ref, puuid) async {
      ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
      // Joining (or not) decides whether the profile can be read at all.
      ref.watch(communityConsentProvider(puuid));
      final session = await ref.watch(communityApiProvider).auth.session(puuid);
      return session.user;
    });

/// Items of a cursor-paged list plus its "load more" state.
@immutable
class PagedState<T> {
  const PagedState({
    this.items = const [],
    this.nextCursor,
    this.loadingMore = false,
    this.loadMoreError,
    this.tag,
  });

  factory PagedState.fromPage(CommunityPage<T> page, {Object? tag}) =>
      PagedState(items: page.items, nextCursor: page.nextCursor, tag: tag);

  final List<T> items;
  final String? nextCursor;
  final bool loadingMore;
  final Object? loadMoreError;

  /// What the list was loaded for (e.g. the [ScopeFilter]), so a screen can
  /// tell stale items of another scope from a plain refresh.
  final Object? tag;

  bool get hasMore => nextCursor != null;

  /// Whether reaching the end of the list should fetch the next page.
  bool get canLoadMore => hasMore && !loadingMore && loadMoreError == null;

  PagedState<T> copyWith({
    List<T>? items,
    String? Function()? nextCursor,
    bool? loadingMore,
    Object? Function()? loadMoreError,
  }) => PagedState(
    items: items ?? this.items,
    nextCursor: nextCursor == null ? this.nextCursor : nextCursor(),
    loadingMore: loadingMore ?? this.loadingMore,
    loadMoreError: loadMoreError == null ? this.loadMoreError : loadMoreError(),
    tag: tag,
  );

  /// Appends [page], skipping items already present (by [idOf]).
  PagedState<T> append(CommunityPage<T> page, String Function(T) idOf) {
    final ids = {for (final i in items) idOf(i)};
    return PagedState(
      items: [
        ...items,
        for (final i in page.items)
          if (ids.add(idOf(i))) i,
      ],
      nextCursor: page.nextCursor,
      tag: tag,
    );
  }
}

/// Shared "load the next page" logic of the paged notifiers.
mixin PagedLoader<T> on AsyncNotifier<PagedState<T>> {
  Future<CommunityPage<T>> fetchPage(String? cursor);

  String idOf(T item);

  /// Refetches the first page, keeping the list visible meanwhile.
  Future<void> refresh() async {
    ref.invalidateSelf();
    try {
      await future;
    } on Object {
      // Shown through `state` (the previous data stays visible).
    }
  }

  Future<void> loadMore() async {
    final s = state.value;
    if (s == null || !s.hasMore || s.loadingMore) return;
    state = AsyncData(s.copyWith(loadingMore: true, loadMoreError: () => null));
    try {
      final page = await fetchPage(s.nextCursor);
      if (!ref.mounted) return;
      state = AsyncData((state.value ?? s).append(page, idOf));
    } on Object catch (e) {
      if (!ref.mounted) return;
      state = AsyncData(
        (state.value ?? s).copyWith(loadingMore: false, loadMoreError: () => e),
      );
    }
  }

  /// Replaces the item with the same id (no-op when absent).
  void replace(T item) {
    final s = state.value;
    if (s == null) return;
    final id = idOf(item);
    state = AsyncData(
      s.copyWith(items: [for (final i in s.items) idOf(i) == id ? item : i]),
    );
  }

  /// Adds [item] at the top (replacing an older copy).
  void prepend(T item) {
    final s = state.value;
    if (s == null) return;
    final id = idOf(item);
    state = AsyncData(
      s.copyWith(items: [item, ...s.items.where((i) => idOf(i) != id)]),
    );
  }

  /// Drops the item with [id] locally.
  void removeLocal(String id) {
    final s = state.value;
    if (s == null) return;
    state = AsyncData(
      s.copyWith(items: s.items.where((i) => idOf(i) != id).toList()),
    );
  }
}
