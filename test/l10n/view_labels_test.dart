import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/l10n/labels/community_labels.dart';
import 'package:valvn/features/battlepass/ui/battlepass_rewards_screen.dart';
import 'package:valvn/features/battlepass/battlepass_strings.dart';
import 'package:valvn/features/collection/ui/browse_collection_screen.dart';
import 'package:valvn/features/collection/ui/widgets/collection_widgets.dart';
import 'package:valvn/features/collection/collection_strings.dart';
import 'package:valvn/features/community/ui/community_screen.dart';
import 'package:valvn/features/community/ui/scope/scope_bar.dart';
import 'package:valvn/features/community/ui/widgets/community_widgets.dart';
import 'package:valvn/features/community/community_strings.dart';
import 'package:valvn/features/live_game/ui/live_widgets.dart';
import 'package:valvn/features/store/ui/widgets/store_ui_bits.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

// Resource markers exercise reload; they are not real/shipped translations.
class _Messages extends AppLocalizationsVi {
  _Messages(this.marker);
  final String marker;
  @override
  String get storeOwnedBadge => 'owned-$marker';
  @override
  String get collectionEquipped => 'equipped-$marker';
  @override
  String get communityUnlike => 'unlike-$marker';
  @override
  String get communityLike => 'like-$marker';
  @override
  String get communitySectionFeed => 'feed-$marker';
  @override
  String get battlePassFilterAll => 'all-$marker';
  @override
  String get liveGameStatusEnded => 'ended-$marker';
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate(this.marker);
  final String marker;
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'vi';
  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(_Messages(marker));
  @override
  bool shouldReload(_Delegate old) => marker != old.marker;
}

void main() {
  final messages = AppLocalizationsVi();
  test('browse IDs and descriptions retain all existing VI behavior', () {
    for (final type in CollectionBrowseType.values) {
      expect(CollectionBrowseType.parse(type.path), type);
      expect(
        messages.collectionBrowseDescription(type.path),
        CollectionStrings.browseSubtitle(type.path),
      );
    }
    expect(CollectionBrowseType.parse('bad'), CollectionBrowseType.skin);
    expect(
      messages.collectionBrowseDescription('bad'),
      CollectionStrings.browseTitle,
    );
    expect(
      CollectionBrowseType.title.label(messages),
      CollectionStrings.browseTitles,
    );
    expect(RewardsFilter.all.label(messages), BattlePassStrings.filterAll);
    expect(CommunitySection.feed.query, 'feed');
    expect(CommunitySection.parse('bad'), CommunitySection.feed);
  });
  test(
    'reports retain server codes/order and ratings preserve bounds/fallback',
    () {
      expect(
        messages.communityReportReasonLabels,
        CommunityStrings.reportReasons,
      );
      expect(
        messages.communityReportReasonLabels.keys.toList(),
        CommunityStrings.reportReasons.keys.toList(),
      );
      for (var rating = 1; rating <= 5; rating++) {
        expect(
          messages.communityRatingWord(rating),
          CommunityStrings.ratingWords[rating - 1],
        );
      }
      expect(messages.communityRatingWord(0), messages.commonDash);
      expect(messages.communityRatingWord(6), messages.commonDash);
    },
  );
  test('country asset name wins; fallback resolves resources without inventing a country', () {
    for (final entry in CommunityStrings.countryNames.entries) {
      expect(messages.communityCountryName(entry.key), entry.value);
    }
    expect(countrySegmentLabel(messages, 'VN'), '🇻🇳 Việt Nam');
    expect(
      countrySegmentLabel(messages, 'VN', localizedName: 'asset-name'),
      '🇻🇳 asset-name',
    );
    expect(countrySegmentLabel(messages, null), messages.communityScopeCountry);
    expect(messages.communityCountryName('ZZ'), 'ZZ');
  });
  testWidgets(
    'retained const defaults and state resolve new text and semantics',
    (tester) async {
      final handle = tester.ensureSemantics();
      try {
        const body = Column(
          children: [
            OwnedBadge(),
            EquippedBadge(),
            OwnedBadge(label: 'custom'),
            HeartButton(
              key: ValueKey('heart'),
              active: false,
              count: 7,
              onTap: _noop,
            ),
            _EnumLabels(),
          ],
        );
        Widget app(String marker) => MaterialApp(
          locale: const Locale('vi'),
          supportedLocales: const [Locale('vi')],
          localizationsDelegates: [
            _Delegate(marker),
            ...appLocalizationsDelegates.skip(1),
          ],
          home: const Scaffold(body: body),
        );
        await tester.pumpWidget(app('first'));
        await tester.pump();
        final retained = tester.state(find.byType(HeartButton));
        expect(find.text('owned-first'), findsOneWidget);
        expect(
          tester.getSemantics(find.byKey(const ValueKey('heart'))).label,
          contains('like-first'),
        );
        await tester.pumpWidget(app('second'));
        await tester.pump();
        expect(find.text('owned-first'), findsNothing);
        for (final text in [
          'owned-second',
          'equipped-second',
          'feed-second',
          'all-second',
          'ended-second',
          'custom',
          '7',
        ]) {
          expect(find.text(text), findsOneWidget);
        }
        expect(
          tester.getSemantics(find.byKey(const ValueKey('heart'))).label,
          contains('like-second'),
        );
        expect(tester.state(find.byType(HeartButton)), same(retained));
        expect(tester.takeException(), isNull);
      } finally {
        handle.dispose();
      }
    },
  );
}

void _noop() {}

class _EnumLabels extends StatelessWidget {
  const _EnumLabels();
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(CommunitySection.feed.label(context.l10n)),
      Text(RewardsFilter.all.label(context.l10n)),
      Text(LiveStatus.ended.label(context.l10n)),
    ],
  );
}
