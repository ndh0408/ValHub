import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/storage/ui_memory.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/segmented_tabs.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../community_strings.dart';
import '../providers/community_providers.dart';
import '../providers/consent_providers.dart';
import 'consent/consent_sheet.dart';
import '../providers/feed_providers.dart';
import '../providers/lfg_providers.dart';
import '../providers/scope_providers.dart';
import '../providers/skin_vote_providers.dart';
import 'feed/feed_section.dart';
import 'lfg/lfg_poster_sync.dart';
import 'lfg/lfg_section.dart';
import 'skins/top_skins_section.dart';
import 'widgets/community_widgets.dart';

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

  String get label => switch (this) {
    feed => CommunityStrings.sectionFeed,
    lfg => CommunityStrings.sectionLfg,
    skins => CommunityStrings.sectionSkins,
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
  late CommunitySection _section =
      widget.initialSection ??
      ref
          .read(uiMemoryProvider)
          .readEnum(
            kSectionMemoryKey,
            CommunitySection.values,
            CommunitySection.feed,
          );

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
    if (ref.watch(communityConsentProvider(account.puuid)) !=
        CommunityConsent.granted) {
      return _ConsentGate(
        key: ValueKey('consent-${account.puuid}'),
        account: account,
      );
    }
    return LfgPosterSync(
      account: account,
      child: TabPageScaffold(
        title: CommunityStrings.title,
        showMaintenanceBanner: false,
        header: SegmentedTabs<CommunitySection>(
          expand: true,
          tabs: [
            for (final s in CommunitySection.values)
              SegmentedTab(value: s, label: s.label),
          ],
          selected: _section,
          onChanged: (s) {
            setState(() => _section = s);
            ref.read(uiMemoryProvider).writeEnum(kSectionMemoryKey, s);
          },
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
      ),
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
          final scope = await ref.read(
            resolvedScopeProvider((puuid: puuid, section: ScopedSection.skins))
                .future,
          );
          final q = (
            puuid: puuid,
            weapon: f.weapon,
            period: f.period,
            sort: f.sort,
            scope: scope,
          );
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

/// Shown until the account agreed to share its Riot ID (asked once, before
/// any network call): the consent sheet opens by itself the first time; after
/// "Để sau" the user can reopen it from here. Nothing is loaded meanwhile.
class _ConsentGate extends StatefulWidget {
  const _ConsentGate({super.key, required this.account});

  final Account account;

  @override
  State<_ConsentGate> createState() => _ConsentGateState();
}

class _ConsentGateState extends State<_ConsentGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(ensureCommunityConsent(context, widget.account));
    });
  }

  @override
  Widget build(BuildContext context) {
    return TabPageScaffold(
      title: CommunityStrings.title,
      showMaintenanceBanner: false,
      body: Center(
        child: CommunityEmptyState(
          icon: Icons.verified_user_outlined,
          title: CommunityStrings.consentGateTitle,
          message: CommunityStrings.consentGateBody,
          action: FilledButton(
            key: const ValueKey('consent-gate-action'),
            onPressed: () => unawaited(
              ensureCommunityConsent(context, widget.account, askAgain: true),
            ),
            child: const Text(CommunityStrings.consentGateAction),
          ),
        ),
      ),
    );
  }
}
