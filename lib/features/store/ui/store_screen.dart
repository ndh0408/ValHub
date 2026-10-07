import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/ui/saved_copy_notice.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/accounts/account_widgets.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/segmented_tabs.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../providers/night_market_seen.dart';
import 'widgets/accessory_section.dart';
import 'widgets/bundle_section.dart';
import 'widgets/daily_section.dart';
import 'widgets/night_market_section.dart';
import 'widgets/store_segment_bar.dart';
import 'widgets/store_skeletons.dart';
import 'widgets/wallet_pill.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Store segments (VF §6.2). The Night Market segment appears only while
/// `BonusStore` exists.
enum StoreSegment {
  daily,
  nightMarket,
  accessories,
  bundles;

  /// Parses the `?segment=` query value (`daily`, `nightmarket`,
  /// `accessories`, `bundles`).
  static StoreSegment parse(String? value) => switch (value?.toLowerCase()) {
    'nightmarket' => nightMarket,
    'accessories' => accessories,
    'bundles' => bundles,
    _ => daily,
  };

  String get queryValue => switch (this) {
    daily => 'daily',
    nightMarket => 'nightmarket',
    accessories => 'accessories',
    bundles => 'bundles',
  };
}

/// The segment actually shown: the Night Market falls back to the daily
/// shop once the storefront is known to have no `BonusStore`.
StoreSegment effectiveStoreSegment(StoreSegment wanted, Storefront? store) =>
    wanted == StoreSegment.nightMarket && store != null && !store.hasNightMarket
    ? StoreSegment.daily
    : wanted;

/// TAB 1 "Cửa hàng" (S10–S13). Route `/store[?segment=…]`.
///
/// Header: title, account chip, wallet pill, segmented control
/// "Hằng ngày · Chợ Đêm · Phụ kiện · Bundle" (Chợ Đêm only while active,
/// with a red dot until opened). Pull-to-refresh reloads the storefront and
/// the wallet. The "Cửa hàng đã làm mới" reminder (VF §6.9) is scheduled by
/// the always-mounted `StoreResetReminderHost`, not by this screen.
class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({
    super.key,
    this.initialSegment = StoreSegment.daily,
    this.linkNonce,
  });

  final StoreSegment initialSegment;

  /// Changes on every notification tap (see `AppConstants.linkNonceParam`):
  /// the segment is re-applied even when it equals the previous link's.
  final String? linkNonce;

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

/// [UiMemory] key of the last segment the user picked.
const storeSegmentMemoryKey = 'store.segment';

class _StoreScreenState extends ConsumerState<StoreScreen> {
  /// A deep link (`?segment=…` or a notification tap) wins; a plain visit to
  /// the tab reopens the segment the user last picked.
  late StoreSegment _segment = _hasExplicitSegment(widget)
      ? widget.initialSegment
      : ref
            .read(uiMemoryProvider)
            .readEnum(
              storeSegmentMemoryKey,
              StoreSegment.values,
              widget.initialSegment,
            );

  static bool _hasExplicitSegment(StoreScreen w) =>
      w.linkNonce != null || w.initialSegment != StoreSegment.daily;

  void _select(StoreSegment next) {
    setState(() => _segment = next);
    ref.read(uiMemoryProvider).writeEnum(storeSegmentMemoryKey, next);
  }

  /// Last storefront checked for content misses.
  Storefront? _missCheckedFor;

  @override
  void didUpdateWidget(StoreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A deep link (`/store?segment=nightmarket`) while the tab is alive.
    if (oldWidget.initialSegment != widget.initialSegment ||
        (widget.linkNonce != null && widget.linkNonce != oldWidget.linkNonce)) {
      _segment = widget.initialSegment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return TabPageScaffold(
        title: context.l10n.storeTitle,
        body: EmptyView(
          message: context.l10n.commonErrorNoAccount,
          icon: Icons.person_off_outlined,
        ),
      );
    }
    final puuid = account.puuid;
    final storeAsync = ref.watch(storefrontProvider(puuid));
    final store = storeAsync.value;
    final nm = store?.nightMarket;
    final seen = ref.watch(nightMarketSeenProvider(puuid));
    final nmIds = nm?.offers.map((o) => o.bonusOfferId) ?? const <String>[];
    // Cards already flipped in the game (Riot's `IsSeen`) need no dot.
    final hasUnseen =
        nm != null &&
        hasUnseenOffers(
          nm.offers.where((o) => !o.isSeen).map((o) => o.bonusOfferId),
          seen,
        );
    final segment = effectiveStoreSegment(_segment, store);
    // Rebuild once the content arrives, to check the offers against it.
    ref.watch(contentProvider.select((c) => c.hasValue));

    _afterBuild(
      account: account,
      store: store,
      markNightMarketSeen: segment == StoreSegment.nightMarket && hasUnseen
          ? nmIds.toList()
          : null,
    );

    final tabs = <SegmentedTab<StoreSegment>>[
      SegmentedTab(
        value: StoreSegment.daily,
        label: context.l10n.storeSegmentDaily,
      ),
      // While loading, keep a deep-linked Night Market tab visible.
      if (nm != null || (store == null && segment == StoreSegment.nightMarket))
        SegmentedTab(
          value: StoreSegment.nightMarket,
          label: context.l10n.storeSegmentNightMarket,
          showDot: hasUnseen && segment != StoreSegment.nightMarket,
        ),
      SegmentedTab(
        value: StoreSegment.accessories,
        label: context.l10n.storeSegmentAccessories,
      ),
      SegmentedTab(
        value: StoreSegment.bundles,
        label: context.l10n.storeSegmentBundles,
      ),
    ];

    // On narrow phones the chip shows only the avatar so the title fits.
    final roomy = MediaQuery.sizeOf(context).width >= 360;
    return TabPageScaffold(
      title: context.l10n.storeTitle,
      showAccountChip: false,
      actions: [AccountChip(showName: roomy)],
      onRefresh: () => _refresh(puuid),
      slivers: [
        SliverToBoxAdapter(child: WalletPill(puuid: puuid)),
        SliverPersistentHeader(
          pinned: true,
          delegate: GlassHeaderDelegate(
            height: 60,
            child: StoreSegmentBar<StoreSegment>(
              tabs: tabs,
              selected: segment,
              onChanged: _select,
            ),
          ),
        ),
        if (store != null && store.isFromCache)
          SliverToBoxAdapter(
            child: SavedCopyNotice(puuid: puuid, receivedAt: store.receivedAt),
          ),
        SliverToBoxAdapter(
          child: AnimatedSwitcher(
            duration: ValMotion.medium,
            // The old segment leaves at once; the new one fades in.
            reverseDuration: Duration.zero,
            switchInCurve: ValMotion.curve,
            child: KeyedSubtree(
              key: ValueKey(segment),
              child: _segmentBody(segment, puuid, storeAsync),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  Widget _segmentBody(
    StoreSegment segment,
    String puuid,
    AsyncValue<Storefront> storeAsync,
  ) {
    void retry() {
      ref
        ..retryContentIfFailed()
        ..invalidate(storefrontProvider(puuid));
    }

    return switch (segment) {
      StoreSegment.daily => AsyncValueView<Storefront>(
        value: storeAsync,
        puuid: puuid,
        onRetry: retry,
        loading: const StoreSkeleton(kind: StoreSkeletonKind.daily),
        data: (s) => DailySection(daily: s.daily, puuid: puuid),
      ),
      StoreSegment.nightMarket => AsyncValueView<Storefront>(
        value: storeAsync,
        puuid: puuid,
        onRetry: retry,
        loading: const StoreSkeleton(kind: StoreSkeletonKind.nightMarket),
        data: (s) =>
            NightMarketSection(nightMarket: s.nightMarket, puuid: puuid),
      ),
      StoreSegment.accessories => AsyncValueView<Storefront>(
        value: storeAsync,
        puuid: puuid,
        onRetry: retry,
        loading: const StoreSkeleton(kind: StoreSkeletonKind.accessories),
        data: (s) =>
            AccessorySection(accessoryStore: s.accessoryStore, puuid: puuid),
      ),
      StoreSegment.bundles => AsyncValueView<Storefront>(
        value: storeAsync,
        puuid: puuid,
        onRetry: retry,
        loading: const StoreSkeleton(kind: StoreSkeletonKind.bundles),
        data: (s) => BundleSection(bundles: s.bundles),
      ),
    };
  }

  Future<void> _refresh(String puuid) async {
    ref
      ..retryContentIfFailed()
      ..invalidate(walletProvider(puuid));
    try {
      ref.invalidate(storefrontProvider(puuid));
      await ref.read(storefrontProvider(puuid).future);
    } on Object {
      // The error is rendered by AsyncValueView ("Thử lại").
    }
  }

  /// Side effects that must not run during build: marking the Night Market
  /// seen and content-miss reports.
  void _afterBuild({
    required Account account,
    required Storefront? store,
    required List<String>? markNightMarketSeen,
  }) {
    final missesIn = store != null && !identical(store, _missCheckedFor)
        ? store
        : null;
    if (missesIn == null && markNightMarketSeen == null) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (markNightMarketSeen != null) {
        unawaited(
          ref
              .read(nightMarketSeenProvider(account.puuid).notifier)
              .markSeen(markNightMarketSeen),
        );
      }
      if (missesIn != null) _reportContentMisses(missesIn);
    });
  }

  /// A storefront uuid missing from the content (new patch) triggers a
  /// rate-limited content re-download (ARCHITECTURE §5.5).
  void _reportContentMisses(Storefront store) {
    final db = ref.read(contentProvider).value;
    if (db == null || db.isEmpty) return;
    _missCheckedFor = store;
    final levels = [
      ...store.daily.offers.map((o) => o.skinLevelUuid),
      ...?store.nightMarket?.offers.map((o) => o.skinLevelUuid),
    ];
    if (levels.any((id) => db.skinByLevelUuid(id) == null)) {
      unawaited(ref.read(contentMissReporterProvider).report());
    }
  }
}
