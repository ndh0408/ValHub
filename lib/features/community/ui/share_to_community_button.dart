import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/content/content_db.dart';
import '../../../core/content/content_repository.dart';
import '../../../core/domain/economy/economy.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/util/clock.dart';
import '../data/compose_draft.dart';
import '../providers/community_providers.dart';
import 'feed/feed_section.dart' show openComposer;

import 'package:valvn/core/l10n/l10n.dart';

/// "Khoe lên Cộng đồng" for the store's daily offers or Night Market: opens
/// the composer prefilled with a store / Night Market attachment. Renders
/// nothing when the community is unavailable or there is nothing to show.
class ShareToCommunityButton extends ConsumerWidget {
  const ShareToCommunityButton.daily(
    DailyStore this.daily, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
  }) : nightMarket = null;

  const ShareToCommunityButton.nightMarket(
    NightMarket this.nightMarket, {
    super.key,
    this.padding = const EdgeInsets.fromLTRB(16, 16, 16, 0),
  }) : daily = null;

  final DailyStore? daily;
  final NightMarket? nightMarket;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(communityEnabledProvider) ||
        ref.watch(activeAccountProvider) == null) {
      return const SizedBox.shrink();
    }
    final d = daily;
    final nm = nightMarket;
    if ((d == null || d.isEmpty) && (nm == null || nm.offers.isEmpty)) {
      return const SizedBox.shrink();
    }
    // Keeps the content alive so the draft resolves skin uuids.
    ref.watch(contentProvider.select((c) => c.hasValue));
    final theme = Theme.of(context);
    final isNightMarket = nm != null;
    final accent = isNightMarket ? const Color(0xFFB57BFF) : ValColors.red;
    return Padding(
      padding: padding,
      child: Material(
        color: theme.colorScheme.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(ValRadius.card),
          side: BorderSide(color: accent.withValues(alpha: 0.35)),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _open(context, ref),
          child: Ink(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accent.withValues(alpha: 0.2),
                  accent.withValues(alpha: 0.02),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 12, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accent.withValues(alpha: 0.2),
                    ),
                    child: Icon(Icons.campaign_rounded, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.communityShareStore,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isNightMarket
                              ? context.l10n.communityShareNightMarketHint
                              : context.l10n.communityShareStoreHint,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: accent),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref) => shareStoreToCommunity(
    context,
    ref,
    daily: daily,
    nightMarket: nightMarket,
  );
}

/// Whether the store can be posted to the Community right now (it is on and
/// an account is signed in).
bool canShareStoreToCommunity(WidgetRef ref) =>
    ref.read(communityEnabledProvider) &&
    ref.read(activeAccountProvider) != null;

/// Opens the composer with the daily shop or the Night Market as a draft
/// (the consent sheet comes first when needed).
void shareStoreToCommunity(
  BuildContext context,
  WidgetRef ref, {
  DailyStore? daily,
  NightMarket? nightMarket,
}) {
  final db = ref.read(contentProvider).value ?? ContentDb.empty();
  final now = ref.read(clockProvider).now();
  final draft = nightMarket != null
      ? ComposeDraft.fromNightMarket(nightMarket, db: db, now: now)
      : (daily == null
            ? null
            : ComposeDraft.fromDaily(daily, db: db, now: now));
  if (draft == null) return;
  // Writing needs a session: the consent sheet comes first when needed.
  unawaited(openComposer(context, draft: draft));
}
