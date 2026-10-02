import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/l10n/app_locale.dart';
import 'package:valvn/core/l10n/formats.dart';
import 'package:valvn/features/wishlist/wishlist_strings.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

class ProbeFormatMessages extends AppLocalizationsVi {
  ProbeFormatMessages() : super('qa');
  @override
  String commonHours(int n) => 'QA hours $n';
  @override
  String get commonListSeparator => ' | ';
  @override
  String get contentCurrencyVp => 'QA-VP';
}

void main() {
  final formats = AppFormats.create(AppLocale.vi, 'vi');
  final l10n = formats.l10n;

  test(
    'word formatters use their supplied messages rather than a fixed locale',
    () {
      final probe = AppFormats.create(
        AppLocale.vi,
        'vi',
        messages: ProbeFormatMessages(),
      );
      expect(probe.durationCoarse(const Duration(hours: 2)), 'QA hours 2');
      expect(probe.listJoin(['A', 'B']), 'A | B');
      expect(probe.vp(1275), '1.275 QA-VP');
    },
  );

  test('daily expiry branches preserve Vietnamese notification content', () {
    for (final left in [null, '2 giờ', '38 phút']) {
      expect(
        l10n.wishlistNotifDailyBody(
          'Skin',
          'Tên#TAG',
          left == null ? 'no' : 'yes',
          left ?? '',
        ),
        WishlistStrings.notifDailyBody('Skin', 'Tên#TAG', left),
      );
    }
  });
  test('unavailable prices/discounts never become fabricated values', () {
    for (final percent in [null, -5, 0, 32]) {
      for (final price in [null, '1.275 VP']) {
        expect(
          l10n.wishlistNotifNightMarketBody(
            'Skin',
            price == null
                ? 'unknown'
                : percent != null && percent > 0
                ? 'discount'
                : 'price',
            percent == null ? '' : formats.number(percent),
            price ?? '',
            'Tên#TAG',
          ),
          WishlistStrings.notifNightMarketBody(
            'Skin',
            percent,
            price,
            'Tên#TAG',
          ),
        );
      }
    }
  });
  test('bundle name absence remains explicit', () {
    for (final bundle in [null, 'Bundle']) {
      expect(
        l10n.wishlistNotifBundleBody(
          'Skin',
          bundle == null ? 'no' : 'yes',
          bundle ?? '',
          'Tên#TAG',
        ),
        WishlistStrings.notifBundleBody('Skin', bundle, 'Tên#TAG'),
      );
    }
  });
  test('summary plural branches retain the existing Vietnamese wording', () {
    for (final more in [0, 1, 2, 5, 11, 100]) {
      expect(
        l10n.wishlistNotifSummaryBody(
          formats.listJoin(['Skin A', 'Skin B']),
          more,
          'Tên#TAG',
        ),
        WishlistStrings.notifSummaryBody(['Skin A', 'Skin B'], more, 'Tên#TAG'),
      );
    }
  });
}
