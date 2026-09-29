import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/accounts/account_widgets.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/ui/async_value_view.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/segmented_tabs.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../../../core/util/clock.dart';
import '../providers/night_market_seen.dart';
import '../providers/store_reset_reminder.dart';
import '../store_strings.dart';
import 'widgets/accessory_section.dart';
import 'widgets/bundle_section.dart';
import 'widgets/daily_section.dart';
import 'widgets/night_market_section.dart';
import 'widgets/store_segment_bar.dart';
import 'widgets/store_skeletons.dart';
import 'widgets/store_ui_bits.dart';
import 'widgets/wallet_pill.dart';

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
/// the wallet. Every new storefront (re)schedules the "Cửa hàng đã làm mới"
/// reminder when that setting is on (VF §6.9).
class StoreScreen extends ConsumerStatefulWidget {
  const StoreScreen({super.key, this.initialSegment = StoreSegment.daily});

  final StoreSegment initialSegment;

  @override
  ConsumerState<StoreScreen> createState() => _StoreScreenState();
}

class _StoreScreenState extends ConsumerState<StoreScreen> {
  late StoreSegment _segment = widget.initialSegment;

  /// Last storefront a reset reminder was scheduled for (one per fetch).
  Storefront? _remindedFor;

  /// Last storefront checked for content misses.
  Storefront? _missCheckedFor;

  @override
  void didUpdateWidget(StoreScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A deep link (`/store?segment=nightmarket`) while the tab is alive.
    if (oldWidget.initialSegment != widget.initialSegment) {
      _segment = widget.initialSegment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return const TabPageScaffold(
        title: StoreStrings.title,
        body: EmptyView(
          message: CommonStrings.errorNoAccount,
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
    final hasUnseen = nm != null && hasUnseenOffers(nmIds, seen);
    final segment = effectiveStoreSegment(_segment, store);
    // Rebuild once the content arrives, to check the offers against it.
    ref.watch(contentProvider.select((c) => c.hasValue));
    final remindersOn = ref.watch(
      appSettingsProvider.select((s) => s.storeResetNotifications),
    );

    _afterBuild(
      account: account,
      store: store,
      remindersOn: remindersOn,
      markNightMarketSeen: segment == StoreSegment.nightMarket && hasUnseen
          ? nmIds.toList()
          : null,
    );

    final tabs = <SegmentedTab<StoreSegment>>[
      const SegmentedTab(
        value: StoreSegment.daily,
        label: StoreStrings.segmentDaily,
      ),
      // While loading, keep a deep-linked Night Market tab visible.
      if (nm != null || (store == null && segment == StoreSegment.nightMarket))
        SegmentedTab(
          value: StoreSegment.nightMarket,
          label: StoreStrings.segmentNightMarket,
          showDot: hasUnseen && segment != StoreSegment.nightMarket,
        ),
      const SegmentedTab(
        value: StoreSegment.accessories,
        label: StoreStrings.segmentAccessories,
      ),
      const SegmentedTab(
        value: StoreSegment.bundles,
        label: StoreStrings.segmentBundles,
      ),
    ];

    // On narrow phones the chip shows only the avatar so the title fits.
    final roomy = MediaQuery.sizeOf(context).width >= 360;
    return TabPageScaffold(
      title: StoreStrings.title,
      showAccountChip: false,
      actions: [AccountChip(showName: roomy)],
      onRefresh: () => _refresh(puuid),
      slivers: [
        SliverToBoxAdapter(child: WalletPill(puuid: puuid)),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SegmentsHeader(
            StoreSegmentBar<StoreSegment>(
              tabs: tabs,
              selected: segment,
              onChanged: (next) => setState(() => _segment = next),
            ),
          ),
        ),
        if (store != null && store.isFromCache)
          SliverToBoxAdapter(
            child: OfflineNotice(receivedAt: store.receivedAt),
          ),
        SliverToBoxAdapter(
          child: KeyedSubtree(
            key: ValueKey(segment),
            child: _segmentBody(segment, puuid, storeAsync),
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
    void retry() => ref.invalidate(storefrontProvider(puuid));
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
    ref.invalidate(walletProvider(puuid));
    try {
      ref.invalidate(storefrontProvider(puuid));
      await ref.read(storefrontProvider(puuid).future);
    } on Object {
      // The error is rendered by AsyncValueView ("Thử lại").
    }
  }

  /// Side effects that must not run during build: marking the Night Market
  /// seen, the reset reminder and content-miss reports.
  void _afterBuild({
    required Account account,
    required Storefront? store,
    required bool remindersOn,
    required List<String>? markNightMarketSeen,
  }) {
    if (!remindersOn) _remindedFor = null;
    final remindFor =
        remindersOn && store != null && !identical(store, _remindedFor)
        ? store
        : null;
    if (remindFor != null) _remindedFor = remindFor;
    final missesIn = store != null && !identical(store, _missCheckedFor)
        ? store
        : null;
    if (remindFor == null && missesIn == null && markNightMarketSeen == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (markNightMarketSeen != null) {
        unawaited(
          ref
              .read(nightMarketSeenProvider(account.puuid).notifier)
              .markSeen(markNightMarketSeen),
        );
      }
      if (remindFor != null) {
        unawaited(
          scheduleStoreResetReminder(
            ref.read(notificationServiceProvider),
            account: account,
            store: remindFor,
            now: ref.read(clockProvider).now(),
          ),
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

/// Pinned segmented control under the wallet pill.
class _SegmentsHeader extends SliverPersistentHeaderDelegate {
  _SegmentsHeader(this.child);

  final Widget child;
  static const _height = 52.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) => ColoredBox(
    color: Theme.of(context).scaffoldBackgroundColor,
    child: SizedBox(
      height: _height,
      child: Align(alignment: Alignment.centerLeft, child: child),
    ),
  );

  @override
  bool shouldRebuild(_SegmentsHeader oldDelegate) => oldDelegate.child != child;
}
