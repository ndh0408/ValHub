import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/l10n/account_labels.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/formats.dart';
import 'package:valvn/core/l10n/labels/view_labels.dart';
import 'package:valvn/features/battlepass/battlepass_strings.dart';
import 'package:valvn/features/collection/collection_strings.dart';
import 'package:valvn/features/home/home_strings.dart';
import 'package:valvn/features/live_game/live_game_strings.dart';
import 'package:valvn/features/skin_detail/skin_detail_strings.dart';
import 'package:valvn/features/social/social_strings.dart';
import 'package:valvn/features/wishlist/wishlist_strings.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

void main() {
  final l10n = AppLocalizationsVi();
  final formats = AppFormats.create(AppLocale.vi, 'vi', messages: l10n);

  test(
    'wishlist and Home semantics retain both complete conditional messages',
    () {
      for (final wished in [false, true]) {
        expect(
          l10n.homeOfferLabel('Vandal', '1.775 VP', 'Cao cấp', wished),
          HomeStrings.skinTileSemantics(
            'Vandal',
            '1.775 VP',
            'Cao cấp',
            wished,
          ),
        );
        expect(
          l10n.homeTrendingLabel('Vandal', '20 lượt thích', wished),
          HomeStrings.trendingSkinSemantics('Vandal', '20 lượt thích', wished),
        );
        expect(
          l10n.wishlistItemLabel('Vandal', '1.775 VP', wished),
          WishlistStrings.tileSemantics('Vandal', '1.775 VP', wished),
        );
      }
    },
  );

  test('Home zero, gains, losses, draws and unknowns retain distinct VI punctuation', () {
    for (final net in [-123, -1, 0, 1, 123]) {
      expect(
        l10n.homeTodayRankLabel(net, 3, 2),
        HomeStrings.rrTodaySemantics(net, 3, 2),
      );
    }
    for (final draws in [-1, 0, 1, 7]) {
      for (final unknown in [-1, 0, 1, 7]) {
        expect(
          l10n.homeResults(3, 2, draws, unknown),
          HomeStrings.winsLosses(3, 2, draws, unknown),
        );
      }
    }
  });

  test(
    'optional ACS, ratings and reward level retain null/empty distinction',
    () {
      for (final acs in <String?>[null, '', '245']) {
        expect(
          l10n.liveStatisticsLabel('12/8/3', acs),
          LiveGameStrings.yourStats('12/8/3', acs),
        );
      }
      for (final rating in <String?>[null, '', '4,5']) {
        expect(
          l10n.skinCommunityLabel(rating, '3', '20'),
          SkinDetailStrings.communityScore(rating, '3', '20'),
        );
      }
      for (final level in <String?>[null, '', 'Cấp 25']) {
        expect(
          l10n.rewardFacts('Phần V', level),
          SkinDetailStrings.rewardDetail('Phần V', level),
        );
      }
    },
  );

  test('slot, pass-summary and suggestions preserve existing VI and invalid-slot fallback', () {
    for (final slot in [-10, -1, 0, 1, 2, 3, 4, 999]) {
      expect(
        l10n.slotCaption(formats, slot),
        CollectionStrings.slotTitle(slot),
      );
    }
    expect(
      l10n.battlePassSummary('46', '55', '46'),
      BattlePassStrings.levelSummary('46', '55', '46'),
    );
    expect(l10n.chatSuggestions, SocialStrings.suggestions);
  });

  test('inline filtering, unread bounds and console brands preserve neutral behavior', () {
    final parts = ['a', ' ', '', ' b '];
    expect(formats.nonEmptyFacts(parts), LiveGameStrings.joinParts(parts));
    for (final n in [-5, 0, 1, 99, 100, 1000]) {
      expect(formats.unreadBadge(n), SocialStrings.unreadBadge(n));
    }
    for (final type in <String?>[
      null,
      '',
      'pc',
      'PS4',
      'ps5',
      'ps',
      'playstation',
      'Xbox',
      'xbone',
      'xsx',
      'other',
    ]) {
      expect(
        l10n.consolePlatformName(type),
        SocialStrings.consolePlatform(type),
      );
    }
    expect(formats.sentence(''), '');
    expect(
      formats.sentence('chênh lệch rank'),
      SocialStrings.sentence('chênh lệch rank'),
    );
    final tr = AppFormats.create(AppLocale.tr, 'tr', messages: l10n);
    expect(tr.sentence('istanbul'), 'İstanbul');
    expect(tr.sentence('😀 hello'), '😀 hello');
  });
}
