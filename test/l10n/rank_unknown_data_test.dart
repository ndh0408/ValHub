import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/domain/competitive/rank_calc.dart';
import 'package:valvn/core/l10n/labels/rank_labels.dart';

import '../helpers/l10n.dart';

import 'package:valvn/core/domain/competitive/competitive_strings.dart';
import 'package:valvn/core/l10n/formats.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

class RankProbeMessages extends AppLocalizationsVi {
  @override
  String get competitiveRankUnknown => 'Unknown rank probe';
  @override
  String get competitiveDivisionIron => 'Iron probe';
}

void main() {
  test('unknown ranked tier is not presented as unranked', () {
    final rank = RankInfo.resolve(ContentDb.empty(), tier: 99, rr: 42);
    expect(rank.isUnranked, isFalse);
    expect(rank.tierName, isNot('Chưa xếp hạng'));
    expect(rank.tierName, isEmpty, reason: 'no API content name is fabricated');
    expect(rank.displayLabel(tf), 'Chưa rõ xếp hạng');
    expect(rank.tier, 99);
    expect(rank.rr, 42);
  });

  test('known numeric fallback names retain VI without touching tier data', () {
    for (var tier = 3; tier <= 27; tier++) {
      final rank = RankInfo.resolve(ContentDb.empty(), tier: tier, rr: 12);
      expect(rank.tierName, isEmpty);
      expect(rank.displayLabel(tf), CompetitiveStrings.fallbackTierName(tier));
      expect(rank.tier, tier);
      expect(rank.rr, 12);
    }
  });

  test('provided resources determine unknown and division labels', () {
    final formats = AppFormats.create(
      AppLocale.vi,
      'vi',
      messages: RankProbeMessages(),
    );
    expect(
      RankInfo.resolve(ContentDb.empty(), tier: 99).displayLabel(formats),
      'Unknown rank probe',
    );
    expect(
      RankInfo.resolve(ContentDb.empty(), tier: 3).displayLabel(formats),
      'Iron probe 1',
    );
    expect(
      RankInfo.resolve(ContentDb.empty(), tier: 0).displayLabel(formats),
      'Chưa xếp hạng',
    );
  });
}
