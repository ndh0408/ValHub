import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../community_strings.dart';
import '../providers/community_providers.dart';
import '../providers/feed_providers.dart';
import '../providers/lfg_providers.dart';
import '../providers/skin_vote_providers.dart';
import 'feed/feed_section.dart';
import 'lfg/lfg_section.dart';
import 'skins/top_skins_section.dart';
import 'widgets/community_widgets.dart';

/// Sections of the "Cộng đồng" tab.
enum CommunitySection {
  feed,
  lfg,
  skins;

  /// `?section=` value.
  String get query => name;

  static CommunitySection parse(String? value) => switch (value) {
    'lfg' => lfg,
    'skins' => skins,
    _ => feed,
  };

  String get label => switch (this) {
    feed => CommunityStrings.sectionFeed,
    lfg => CommunityStrings.sectionLfg,
    skins => CommunityStrings.sectionSkins,
  };
}

/// TAB "Cộng đồng": glass segmented header (Bảng tin · Tìm đồng đội · Xếp
/// hạng skin), pull-to-refresh and a floating action per section.
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({
    super.key,
    this.initialSection = CommunitySection.feed,
  });

  final CommunitySection initialSection;

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  late CommunitySection _section = widget.initialSection;

  @override
  void didUpdateWidget(CommunityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection) {
      _section = widget.initialSection;
    }
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return const TabPageScaffold(
        title: CommunityStrings.title,
        body: Center(
          child: CommunityEmptyState(
            icon: Icons.person_add_alt_1_rounded,
            title: CommunityStrings.noAccountTitle,
            message: CommunityStrings.noAccountBody,
          ),
        ),
      );
    }
    if (!ref.watch(communityEnabledProvider)) {
      return const TabPageScaffold(
        title: CommunityStrings.title,
        body: Center(
          child: CommunityEmptyState(
            icon: Icons.cloud_off_rounded,
            title: CommunityStrings.unavailableTitle,
            message: CommunityStrings.unavailableBody,
          ),
        ),
      );
    }
    return TabPageScaffold(
      title: CommunityStrings.title,
      showMaintenanceBanner: false,
      header: GlassSegmentedControl<CommunitySection>(
        segments: [
          for (final s in CommunitySection.values)
            GlassSegment(value: s, label: s.label),
        ],
        selected: _section,
        onChanged: (s) => setState(() => _section = s),
      ),
      onRefresh: () => _refresh(account),
      floatingActionButton: _fab(account),
      slivers: [
        switch (_section) {
          CommunitySection.feed => FeedSliver(
            key: ValueKey('feed-${account.puuid}'),
            puuid: account.puuid,
          ),
          CommunitySection.lfg => LfgSliver(
            key: ValueKey('lfg-${account.puuid}'),
            account: account,
          ),
          CommunitySection.skins => TopSkinsSliver(
            key: ValueKey('skins-${account.puuid}'),
            puuid: account.puuid,
          ),
        },
        const SliverToBoxAdapter(child: _PrivacyNote()),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
  }

  Widget? _fab(Account account) {
    final (label, icon, onPressed) = switch (_section) {
      CommunitySection.feed => (
        CommunityStrings.newPost,
        Icons.edit_rounded,
        () => unawaited(openComposer(context)),
      ),
      CommunitySection.lfg => (
        CommunityStrings.createLfgShort,
        Icons.group_add_rounded,
        () => unawaited(
          openCreateLfg(
            context,
            account,
            lfgQueryFor(account, ref.read(lfgFilterProvider)),
          ),
        ),
      ),
      CommunitySection.skins => (null, null, null),
    };
    if (label == null || icon == null || onPressed == null) return null;
    return FloatingActionButton.extended(
      heroTag: 'community-fab',
      backgroundColor: ValColors.red,
      foregroundColor: Colors.white,
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Future<void> _refresh(Account account) async {
    final puuid = account.puuid;
    try {
      switch (_section) {
        case CommunitySection.feed:
          await ref.read(feedProvider(puuid).notifier).refresh();
        case CommunitySection.lfg:
          final q = lfgQueryFor(account, ref.read(lfgFilterProvider));
          await ref.read(lfgProvider(q).notifier).refresh();
        case CommunitySection.skins:
          final f = ref.read(topSkinsFilterProvider);
          final q = (puuid: puuid, weapon: f.weapon, period: f.period);
          ref.invalidate(topSkinsProvider(q));
          await ref.read(topSkinsProvider(q).future);
      }
    } on Object {
      // Rendered by the section.
    }
  }
}

/// How the Riot ID is verified (the only data that leaves the device).
class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, size: 14, color: muted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              CommunityStrings.privacyNote,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(color: muted),
            ),
          ),
        ],
      ),
    );
  }
}
