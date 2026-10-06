import 'package:valvn/core/l10n/labels/content_labels.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/geo/countries.dart';
import '../../../../core/geo/country_preference.dart' show countryFlag;
import '../../../../core/content/content_repository.dart';
import '../../../../core/domain/competitive/competitive.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/net_image.dart';
import '../../../../core/ui/skeleton.dart';
import '../../../../core/ui/val_widgets.dart';
import '../../../../core/util/format.dart';
import '../../providers/profile_providers.dart';
import 'profile_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Player identity (S40.1, S44), ValBuddy-style: the wide player-card art
/// in a rounded banner, then the name (tap copies the Riot ID), title and
/// level on the left and the account-XP bar ("184 / 5.000 XP") on the
/// right.
class IdentityBanner extends ConsumerWidget {
  const IdentityBanner({
    super.key,
    required this.name,
    this.tagLine,
    this.cardId,
    this.titleId,
    this.level,
    this.levelHidden = false,
    this.xp,
    this.xpLoading = false,
    this.copyText,
  });

  /// Game name, or "Người chơi ẩn danh".
  final String name;

  /// Shown as "#TAG" after the name.
  final String? tagLine;
  final String? cardId;
  final String? titleId;
  final int? level;

  /// Show "Cấp ẩn" instead of a number.
  final bool levelHidden;
  final AccountXp? xp;

  /// Skeleton in place of the XP bar.
  final bool xpLoading;

  /// Riot ID copied on tap (`null` = not copyable).
  final String? copyText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    final db = ref.watch(contentProvider).value;
    final card = cardId == null ? null : db?.card(cardId!);
    final t = titleId == null ? null : db?.title(titleId!);
    final title = t == null || t.isNoTitle
        ? null
        : t.localizedText(context.l10n);
    final lvl = xp?.level ?? level;
    final tag = tagLine?.trim() ?? '';
    final copy = copyText;
    final x = levelHidden ? null : xp;
    final showXpSkeleton = xpLoading && !levelHidden && x == null;

    final nameBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: copy == null
              ? null
              : () => copyWithSnack(
                  context,
                  copy,
                  context.l10n.profileRiotIdCopied,
                ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: kMinInteractiveDimension,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: name),
                        if (tag.isNotEmpty)
                          TextSpan(
                            text: context.l10n.profileTagSuffix(tag),
                            style: TextStyle(
                              color: muted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (copy != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.copy_rounded,
                    size: 15,
                    semanticLabel: context.l10n.profileCopyRiotId,
                    color: muted,
                  ),
                ],
              ],
            ),
          ),
        ),
        if (title != null && title.isNotEmpty)
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.85),
              fontWeight: FontWeight.w600,
            ),
          ),
        if (levelHidden || lvl != null)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              levelHidden
                  ? context.l10n.profileLevelHidden
                  : context.l10n.profileLevel(lvl!),
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
      ],
    );

    Widget? xpBlock;
    if (x != null) {
      xpBlock = Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            context.l10n.profileXpProgress(
              formatNumber(x.xp),
              formatNumber(x.xpPerLevel),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              color: muted,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 6),
          ValProgressBar(
            value: x.progress,
            height: 5,
            semanticsLabel: context.l10n.profileLevel(x.level),
          ),
        ],
      );
    } else if (showXpSkeleton) {
      xpBlock = const Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Skeleton(width: 84, height: 10),
          SizedBox(height: 6),
          Skeleton(height: 5),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CardArt(url: card?.wideArt),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: nameBlock),
              if (xpBlock != null) ...[
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: xpBlock,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

/// Wide player-card art (452×128) in a rounded frame; a red gradient when
/// the card is unknown.
class _CardArt extends StatelessWidget {
  const _CardArt({required this.url});

  final String? url;

  static const _placeholder = DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFE8404F), Color(0xFF5C1A26)],
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final hairline = valColorsOf(context).hairline;
    return ExcludeSemantics(
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ValRadius.card),
          border: Border.all(color: hairline),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(ValRadius.card),
          child: AspectRatio(
            aspectRatio: 452 / 128,
            child: url == null
                ? _placeholder
                : NetImage(url, fit: BoxFit.cover, error: _placeholder),
          ),
        ),
      ),
    );
  }
}

/// Header of the signed-in account's profile tab: P-8 card (cached card as
/// fallback), Riot ID copy, P-9 level and XP.
class ProfileHeader extends ConsumerWidget {
  const ProfileHeader({super.key, required this.account});

  final Account account;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final identity = ref.watch(playerIdentityProvider(account.puuid)).value;
    final xp = ref.watch(accountXpProvider(account.puuid));
    final name = RiotName.of(account.gameName, account.tagLine);
    final country = normalizeCountry(account.country);
    final names = ref.watch(countryNamesProvider).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IdentityBanner(
          name: playerDisplayName(context.l10n, name, withTag: false),
          tagLine: account.tagLine,
          cardId: identity?.cardId ?? account.cardId,
          titleId: identity?.titleId,
          level: account.level,
          xp: xp.value,
          xpLoading: xp.isLoading,
          copyText: name?.riotId,
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: Text(
            country == null
                ? context.l10n.accountRiotCountryUnknown
                : context.l10n.accountRiotCountry(
                    '${countryFlag(country)} ${names?.name(country) ?? country}',
                  ),
            key: const ValueKey('profile-riot-country'),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
