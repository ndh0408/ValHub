import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/l10n.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/store_history.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/content_tier_badge.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/error_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/skin_art_card.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/val_widgets.dart';
import '../../../core/util/clock.dart';
import '../../../core/util/format.dart';
import '../../skin_detail/skin_detail_sheet.dart';
import '../data/store_history_view.dart';
import '../store_routes.dart';
import 'widgets/store_ui_bits.dart';

/// "Lịch sử cửa hàng": the daily shops (and Night Market runs) of the
/// active account as this device recorded them, newest first, plus the
/// skins offered most often. Riot keeps no past stores, so it only holds
/// the days the app saw; the header says since when. Local only.
class StoreHistoryScreen extends ConsumerWidget {
  const StoreHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final puuid = ref.watch(activeAccountProvider)?.puuid;
    if (puuid == null) {
      return SubPageScaffold(
        title: context.l10n.storeHistoryTitle,
        body: EmptyView(message: context.l10n.commonErrorNoAccount),
      );
    }
    final async = ref.watch(storeHistoryProvider(puuid));
    final history = async.value;
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final since = history?.recordingSince;
    return SubPageScaffold(
      title: context.l10n.storeHistoryTitle,
      subtitle: since == null
          ? null
          : context.l10n.storeHistorySince(
              formatDate(since.toLocal()),
              history!.daysRecorded,
            ),
      actions: [
        if (history != null && !history.isEmpty)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: context.l10n.skinDetailHistoryDelete,
            onPressed: () => unawaited(_delete(context, ref, puuid)),
          ),
      ],
      onRefresh: () => ref
          .refresh(storeHistoryProvider(puuid).future)
          .then<void>((_) {}, onError: (Object _) {}),
      slivers: [
        if (history == null && async.hasError)
          SliverFillRemaining(
            hasScrollBody: false,
            child: ErrorView(
              error: async.error!,
              puuid: puuid,
              onRetry: () => ref.invalidate(storeHistoryProvider(puuid)),
            ),
          )
        else if (history == null)
          // A day header and two rows of skin tiles, not a bare spinner.
          const SliverToBoxAdapter(
            child: SkeletonShimmer(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(width: 120, height: 12, shimmer: false),
                    SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Skeleton(
                            height: 156,
                            radius: 16,
                            shimmer: false,
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Skeleton(
                            height: 156,
                            radius: 16,
                            shimmer: false,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        else if (history.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyView(
              icon: Icons.history_rounded,
              message: context.l10n.storeHistoryEmpty,
            ),
          )
        else ...[
          if (mostOfferedSkins(history, db) case final top when top.isNotEmpty)
            SliverToBoxAdapter(
              child: _MostOffered(skins: top, db: db),
            ),
          SliverList.builder(
            itemCount: history.days.length,
            itemBuilder: (context, i) =>
                _Day(day: history.days[i], db: db, key: ValueKey(i)),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ],
    );
  }
}

/// "Xóa lịch sử cửa hàng": every recorded day of [puuid] on this device,
/// after a confirmation.
Future<void> _delete(BuildContext context, WidgetRef ref, String puuid) async {
  final l10n = context.l10n;
  final store = ref.read(storeHistoryStoreProvider);
  final confirmed = await showConfirmDialog(
    context,
    title: l10n.skinDetailHistoryDelete,
    message: l10n.skinDetailHistoryDeleteBody,
    confirmLabel: l10n.commonDelete,
    destructive: true,
  );
  if (!confirmed) return;
  await store.delete(puuid);
  ref.invalidate(storeHistoryProvider(puuid));
}

void _openSkin(BuildContext context, String levelUuid) => unawaited(
  showSkinDetailSheet(
    context,
    skinOrLevelUuid: levelUuid,
    mode: SkinDetailMode.catalog,
  ),
);

class _MostOffered extends StatelessWidget {
  const _MostOffered({required this.skins, required this.db});

  final List<OfferedSkin> skins;
  final ContentDb db;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(context.l10n.storeHistoryMostOffered),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ValCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                for (var i = 0; i < skins.length; i++) ...[
                  if (i > 0)
                    Divider(height: 1, color: valColorsOf(context).hairline),
                  _OfferedRow(skin: skins[i], db: db),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OfferedRow extends StatelessWidget {
  const _OfferedRow({required this.skin, required this.db});

  final OfferedSkin skin;
  final ContentDb db;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = db.skinByLevelUuid(skin.levelUuid);
    final name = content?.displayName ?? context.l10n.commonUnknownItem;
    return InkWell(
      onTap: () => _openSkin(context, skin.levelUuid),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 56),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              ContentTierBadge(
                contentTierUuid: content?.contentTierUuid,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.storeHistoryTimes(skin.times),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Day extends ConsumerWidget {
  const _Day({super.key, required this.day, required this.db});

  final StoreHistoryDay day;
  final ContentDb db;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final now = ref.watch(clockProvider).now();
    final total = dailyTotalVp(day);
    final best = bestNightDiscount(day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(
          context.fmt.dayHeader(rotationStart(day).toLocal(), now),
          trailing: total == null
              ? null
              : Text(
                  context.l10n.homeStoreTotal(context.fmt.vp(total)),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
        TwoColumnGrid(
          children: [
            for (final offer in day.daily) _OfferTile(offer: offer, db: db),
          ],
        ),
        if (day.hasNightMarket)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                Icon(
                  Icons.nightlight_outlined,
                  size: 16,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    context.fmt.inlineFacts([
                      context.l10n.storeHistoryNightMarket(
                        day.nightMarket.length,
                      ),
                      if (best != null) formatDiscountPercent(best),
                    ]),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _OfferTile extends ConsumerWidget {
  const _OfferTile({required this.offer, required this.db});

  final HistoryDailyOffer offer;
  final ContentDb db;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skin = db.skinByLevelUuid(offer.skinLevelUuid);
    final name = skin?.displayName ?? context.l10n.commonUnknownItem;
    final vp = offer.vp;
    // Room for the art plus a two-line name and the price at any text size:
    // the text block takes 4 shares, the art the rest.
    final scale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.0);
    const image = 84.0;
    final text = 72 * scale;
    return SizedBox(
      height: image + text,
      child: SkinArtCard(
        imageFlex: (4 * image / text).floor().clamp(1, 6),
        imageUrl: skin?.image,
        name: name,
        tierColor: contentTierTint(
          ref,
          skin?.contentTierUuid,
          fallback: valColorsOf(context).muted,
        ),
        subtitle: vp == null ? null : context.fmt.vp(vp),
        semanticsLabel: context.fmt.inlineFacts([
          name,
          if (vp != null) context.fmt.vp(vp),
        ]),
        onTap: () => _openSkin(context, offer.skinLevelUuid),
      ),
    );
  }
}

/// The row under the daily shop that opens [StoreHistoryScreen], with how
/// many days this device has recorded.
class StoreHistoryEntry extends ConsumerWidget {
  const StoreHistoryEntry({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(storeHistoryProvider(puuid)).value?.daysRecorded;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: GroupedSection(
        children: [
          GroupedRow(
            icon: Icons.history_rounded,
            title: context.l10n.storeHistoryTitle,
            subtitle: days == null
                ? null
                : context.l10n.storeHistoryEntrySubtitle(days),
            onTap: () => unawaited(context.push(StoreRoutes.history)),
          ),
        ],
      ),
    );
  }
}
