import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../providers/community_providers.dart';
import '../data/community_models.dart';
import '../providers/consent_providers.dart';
import 'consent/consent_sheet.dart';
import '../providers/feed_providers.dart';
import '../providers/lfg_providers.dart';
import '../providers/skin_vote_providers.dart';
import 'feed/feed_section.dart';
import 'lfg/lfg_poster_sync.dart';
import 'lfg/lfg_section.dart';
import 'skins/top_skins_section.dart';
import 'skins/skin_catalog_sheet.dart';
import 'widgets/community_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// `UiMemory` key of the last community section.
const kSectionMemoryKey = 'community.section';

/// Sections of the "Cộng đồng" tab.
enum CommunitySection {
  feed,
  lfg,
  skins;

  /// `?section=` value.
  String get query => name;

  static CommunitySection parse(String? value) => tryParse(value) ?? feed;

  /// `null` when [value] names no section.
  static CommunitySection? tryParse(String? value) => switch (value) {
    'feed' => feed,
    'lfg' => lfg,
    'skins' => skins,
    _ => null,
  };

  String label(AppLocalizations l10n) => switch (this) {
    feed => l10n.communitySectionFeed,
    lfg => l10n.communitySectionLfg,
    skins => l10n.communitySectionSkins,
  };
}

/// TAB "Cộng đồng": glass segmented header (Bảng tin · Tìm đồng đội · Xếp
/// hạng skin), pull-to-refresh and a floating action per section.
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key, this.initialSection});

  /// Section to show (deep link); `null` = the one used last time.
  final CommunitySection? initialSection;

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen> {
  late CommunitySection _section = widget.initialSection ?? _remembered();

  /// The section used last time; without an account that joined, the LFG
  /// lists are not available, so the tab opens on the feed.
  CommunitySection _remembered() {
    final last = ref
        .read(uiMemoryProvider)
        .readEnum(
          kSectionMemoryKey,
          CommunitySection.values,
          CommunitySection.feed,
        );
    final account = ref.read(activeAccountProvider);
    final joined =
        account != null &&
        ref.read(communityConsentProvider(account.puuid)) ==
            CommunityConsent.granted;
    return last == CommunitySection.lfg && !joined
        ? CommunitySection.feed
        : last;
  }

  @override
  void didUpdateWidget(CommunityScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.initialSection;
    if (next != null && oldWidget.initialSection != next) _section = next;
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) {
      return TabPageScaffold(
        title: context.l10n.communityTitle,
        body: Center(
          child: CommunityEmptyState(
            icon: Icons.person_add_alt_1_rounded,
            title: context.l10n.communityNoAccountTitle,
            message: context.l10n.communityNoAccountBody,
          ),
        ),
      );
    }
    if (!ref.watch(communityEnabledProvider)) {
      return TabPageScaffold(
        title: context.l10n.communityTitle,
        body: Center(
          child: CommunityEmptyState(
            icon: Icons.cloud_off_rounded,
            title: context.l10n.communityUnavailableTitle,
            message: context.l10n.communityUnavailableBody,
          ),
        ),
      );
    }
    // Browsing never needs a session: only writes and the LFG lists do.
    final joined =
        ref.watch(communityConsentProvider(account.puuid)) ==
        CommunityConsent.granted;
    final page = TabPageScaffold(
      title: context.l10n.communityTitle,
      showMaintenanceBanner: false,
      headerHeight: MediaQuery.textScalerOf(context).scale(14) > 20 ? 100 : 56,
      header: _SectionTabs(
        selected: _section,
        onChanged: (s) {
          setState(() => _section = s);
          ref.read(uiMemoryProvider).writeEnum(kSectionMemoryKey, s);
        },
      ),
      onRefresh: () => _refresh(account, joined: joined),
      floatingActionButton: _fab(account, joined: joined),
      slivers: [
        switch (_section) {
          CommunitySection.feed => FeedSliver(
            key: ValueKey('feed-${account.puuid}'),
            puuid: account.puuid,
          ),
          CommunitySection.lfg when !joined => SliverToBoxAdapter(
            child: _LfgJoinGate(account: account),
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
        if (_section == CommunitySection.skins)
          SkinCatalogSliver(
            key: ValueKey('catalog-${account.puuid}'),
            puuid: account.puuid,
          ),
        const SliverToBoxAdapter(child: SizedBox(height: 96)),
      ],
    );
    return joined ? LfgPosterSync(account: account, child: page) : page;
  }

  Widget? _fab(Account account, {required bool joined}) {
    final (label, icon, onPressed) = switch (_section) {
      CommunitySection.feed => (
        context.l10n.communityNewPost,
        Icons.edit_rounded,
        () => unawaited(openComposer(context)),
      ),
      CommunitySection.lfg when !joined => (null, null, null),
      CommunitySection.lfg => (
        context.l10n.communityCreateLfgShort,
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
      backgroundColor: ValColors.actionRed,
      foregroundColor: Colors.white,
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Future<void> _refresh(Account account, {required bool joined}) async {
    final puuid = account.puuid;
    try {
      switch (_section) {
        case CommunitySection.feed:
          await ref.read(feedProvider(puuid).notifier).refresh();
        case CommunitySection.lfg:
          if (!joined) return;
          final q = lfgQueryFor(account, ref.read(lfgFilterProvider));
          await ref.read(lfgProvider(q).notifier).refresh();
        case CommunitySection.skins:
          final f = ref.read(topSkinsFilterProvider);
          final q = (
            puuid: puuid,
            weapon: f.weapon,
            period: TopPeriod.all,
            sort: f.sort,
            scope: ScopeFilter.global,
          );
          ref.invalidate(catalogStatsProvider);
          ref.invalidate(topSkinsProvider(q));
          await ref.read(topSkinsProvider(q).future);
      }
    } on Object {
      // Rendered by the section.
    }
  }
}

/// The LFG lists need a session: invite to join instead of loading them.
class _LfgJoinGate extends StatelessWidget {
  const _LfgJoinGate({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    return CommunityEmptyState(
      icon: Icons.groups_2_outlined,
      title: context.l10n.communityLfgGateTitle,
      message: context.l10n.communityLfgGateBody,
      action: FilledButton(
        key: const ValueKey('lfg-join-gate-action'),
        onPressed: () =>
            unawaited(ensureCommunityConsent(context, account, askAgain: true)),
        child: Text(context.l10n.communityConsentGateAction),
      ),
    );
  }
}

/// Content navigation stays distinct from the scope filter below it.
class _SectionTabs extends StatelessWidget {
  const _SectionTabs({required this.selected, required this.onChanged});
  final CommunitySection selected;
  final ValueChanged<CommunitySection> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final section in CommunitySection.values)
            Expanded(
              child: Semantics(
                selected: selected == section,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: selected == section
                            ? theme.colorScheme.primary
                            : theme.colorScheme.outlineVariant,
                        width: selected == section ? 2 : 1,
                      ),
                    ),
                  ),
                  child: TextButton(
                    onPressed: () => onChanged(section),
                    style: TextButton.styleFrom(
                      foregroundColor: selected == section
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurfaceVariant,
                      shape: const RoundedRectangleBorder(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 8,
                      ),
                    ),
                    child: Text(
                      section.label(context.l10n),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: selected == section
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
