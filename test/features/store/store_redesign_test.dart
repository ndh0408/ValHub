import 'package:valvn/core/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/skin_detail/skin_detail_sheet.dart';
import 'package:valvn/features/store/store_strings.dart';
import 'package:valvn/features/store/ui/store_screen.dart';

import '../../core/domain/economy/economy_fixtures.dart';
import '../../helpers/test_prefs.dart';
import 'store_test_harness.dart';

Widget _app({
  required List<Override> overrides,
  required Widget home,
  ThemeData? theme,
  double textScale = 1,
}) => ProviderScope(
  overrides: overrides,
  retry: (_, _) => null,
  child: MaterialApp(
    localizationsDelegates: appLocalizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: theme ?? buildDarkTheme(),
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context)
          .copyWith(textScaler: TextScaler.linear(textScale)),
      child: child!,
    ),
    home: home,
  ),
);

Future<Prefs> _prefsWithSegment(String? segment) =>
    createTestPrefs({PrefKeys.ui(storeSegmentMemoryKey): ?segment});

void main() {
  testWidgets('reopens the last segment the user picked', (tester) async {
    final prefs = await _prefsWithSegment('bundles');
    usePhoneViewport(tester);
    await tester.pumpWidget(
      _app(
        overrides: storeOverrides(api: fixtureApi(), prefs: prefs),
        home: const StoreScreen(),
      ),
    );
    await settle(tester);

    expect(find.text('NEO FRONTIER'), findsOneWidget);
    expect(find.text('Ares Prism'), findsNothing);
    await unmount(tester);
  });

  testWidgets('picking a segment is remembered', (tester) async {
    final prefs = await _prefsWithSegment(null);
    usePhoneViewport(tester);
    await tester.pumpWidget(
      _app(
        overrides: storeOverrides(api: fixtureApi(), prefs: prefs),
        home: const StoreScreen(),
      ),
    );
    await settle(tester);
    await tester.tap(find.bySemanticsLabel(StoreStrings.segmentAccessories));
    await settle(tester);

    expect(prefs.getString(PrefKeys.ui(storeSegmentMemoryKey)), 'accessories');
    await unmount(tester);
  });

  testWidgets('a deep link wins over the remembered segment', (tester) async {
    final prefs = await _prefsWithSegment('bundles');
    usePhoneViewport(tester);
    await tester.pumpWidget(
      _app(
        overrides: storeOverrides(api: fixtureApi(), prefs: prefs),
        home: const StoreScreen(initialSegment: StoreSegment.nightMarket),
      ),
    );
    await settle(tester);
    expect(find.text(StoreStrings.nightMarketNote), findsOneWidget);
    await unmount(tester);

    // A notification tap on the daily shop ("Cửa hàng đã làm mới").
    await tester.pumpWidget(
      _app(
        overrides: storeOverrides(api: fixtureApi(), prefs: prefs),
        home: const StoreScreen(linkNonce: '42'),
      ),
    );
    await settle(tester);
    expect(find.text('Ares Prism'), findsOneWidget);
    await unmount(tester);
  });

  testWidgets('wishlisting a daily offer updates the summary', (tester) async {
    final prefs = await createTestPrefs();
    usePhoneViewport(tester);
    await tester.pumpWidget(
      _app(
        overrides: storeOverrides(api: fixtureApi(), prefs: prefs),
        home: const StoreScreen(),
      ),
    );
    await settle(tester);
    expect(find.text(StoreStrings.wishlistCount(1)), findsNothing);
    await tester.tap(find.bySemanticsLabel(StoreStrings.addToWishlist).first);
    await settle(tester, 3);
    expect(find.text(StoreStrings.wishlistCount(1)), findsOneWidget);
    await unmount(tester);
  });

  for (final (label, theme) in [
    ('dark', buildDarkTheme()),
    ('light', buildLightTheme()),
  ]) {
    testWidgets('daily + Night Market fit 360 dp at 200 % text ($label)', (
      tester,
    ) async {
      final prefs = await createTestPrefs();
      usePhoneViewport(tester);
      await tester.pumpWidget(
        _app(
          overrides: storeOverrides(api: fixtureApi(), prefs: prefs),
          home: const StoreScreen(),
          theme: theme,
          textScale: 2,
        ),
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('Ares Prism'), findsOneWidget);

      await tester.tap(find.bySemanticsLabel(StoreStrings.segmentNightMarket));
      await settle(tester);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });

    testWidgets('skin sheet fits 360 dp at 200 % text ($label)', (
      tester,
    ) async {
      final prefs = await createTestPrefs();
      usePhoneViewport(tester);
      await tester.pumpWidget(
        _app(
          overrides: storeOverrides(api: fixtureApi(), prefs: prefs),
          theme: theme,
          textScale: 2,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showSkinDetailSheet(
                  context,
                  skinOrLevelUuid: Fx.reaverVandal,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
      await settle(tester);
      await tester.tap(find.text('open'));
      await settle(tester, 12);
      expect(find.byType(SkinDetailSheet), findsOneWidget);
      await tester.drag(
        find
            .descendant(
              of: find.byType(SkinDetailSheet),
              matching: find.byType(Scrollable),
            )
            .first,
        const Offset(0, -1200),
      );
      await settle(tester);
      expect(tester.takeException(), isNull);
      await unmount(tester);
    });
  }
}
