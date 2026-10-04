import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../data/community_exception.dart';
import '../data/community_models.dart';
import 'community_providers.dart';
import 'consent_providers.dart';
import 'skin_review_providers.dart' show SkinKey;

/// Account-isolated plain discussion. Reading never requires skin ownership.
final skinCommentsProvider = AsyncNotifierProvider.autoDispose
    .family<SkinCommentsNotifier, PagedState<CommunityComment>, SkinKey>(
      SkinCommentsNotifier.new,
    );

class SkinCommentsNotifier extends AsyncNotifier<PagedState<CommunityComment>>
    with PagedLoader<CommunityComment> {
  SkinCommentsNotifier(this.key);
  final SkinKey key;

  @override
  Future<PagedState<CommunityComment>> build() async {
    final puuid = key.puuid;
    if (puuid != null) {
      ref.watch(communityConsentProvider(puuid));
      ref.watch(accountProvider(puuid).select((a) => a?.needsLogin));
    }
    return PagedState.fromPage(
      await ref.watch(communityApiProvider).skinComments(puuid, key.skinUuid),
    );
  }

  @override
  Future<CommunityPage<CommunityComment>> fetchPage(String? cursor) => ref
      .read(communityApiProvider)
      .skinComments(key.puuid, key.skinUuid, cursor: cursor);

  @override
  String idOf(CommunityComment item) => item.id;

  Future<void> add(String body, {String? idempotencyKey}) async {
    final puuid = key.puuid;
    if (puuid == null) {
      throw const CommunityException(CommunityException.unauthorized);
    }
    final comment = await ref
        .read(communityApiProvider)
        .addSkinComment(
          puuid,
          key.skinUuid,
          body,
          language: ref.read(communityAppLanguageProvider),
          idempotencyKey: idempotencyKey,
        );
    if (!ref.mounted) return;
    // Do not append beyond an unloaded oldest-first page: refetch to avoid
    // missing/reordering comments when the user subsequently loads the cursor.
    if (state.value?.hasMore ?? false) {
      ref.invalidateSelf();
    } else if (state.value case final s?) {
      state = AsyncData(
        s.copyWith(
          items: [...s.items.where((c) => c.id != comment.id), comment],
        ),
      );
    } else {
      ref.invalidateSelf();
    }
  }

  Future<void> delete(String id) async {
    final puuid = key.puuid;
    if (puuid == null) {
      throw const CommunityException(CommunityException.unauthorized);
    }
    await ref.read(communityApiProvider).deleteSkinComment(puuid, id);
    if (ref.mounted) removeLocal(id);
  }
}
