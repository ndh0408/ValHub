import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/settings/app_settings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/sub_page.dart';
import 'package:valvn/core/ui/vnd_estimate.dart';

import '../../helpers/test_prefs.dart';

Widget _app(Widget home) => MaterialApp(
  theme: buildDarkTheme(),
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: home,
);

final _config = RemoteConfig.fromJson({
  'vpPricesVnd': {
    'sourceName': 'Nguồn thử',
    'updatedAt': '2026-08-07',
    'packages': [
      {'vp': 13250, 'vnd': 2000000},
      {'vp': 610, 'vnd': 100000},
    ],
  },
});

void main() {
  testWidgets('SubPageScaffold shows the large title and hands over to the '
      'bar title on scroll', (tester) async {
    await tester.pumpWidget(
      _app(
        SubPageScaffold(
          title: 'Chi tiết trận',
          subtitle: 'Thi đấu xếp hạng',
          slivers: [
            SliverList.list(
              children: [
                for (var i = 0; i < 40; i++)
                  SizedBox(height: 60, child: Text('Dòng $i')),
              ],
            ),
          ],
        ),
      ),
    );
    expect(find.text('Chi tiết trận'), findsOneWidget);
    expect(find.text('Thi đấu xếp hạng'), findsOneWidget);

    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    // Bar title appears (the large one may be scrolled off-screen).
    expect(find.text('Chi tiết trận'), findsWidgets);
  });

  testWidgets('SubPageScaffold with a hero survives 360 dp and text 2.0', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360 * 3, 740 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: _app(
          const SubPageScaffold(
            title: 'Một tiêu đề rất dài để kiểm tra việc xuống dòng',
            subtitle: 'Phụ đề cũng khá dài để kiểm tra chữ phóng to',
            hero: HeroBackdrop(),
            body: Text('Nội dung'),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Nội dung'), findsOneWidget);
  });

  testWidgets('showValSheet renders a header with a close button', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showValSheet<void>(
                context,
                title: 'Chọn thẻ',
                builder: (_, _) => const Text('Nội dung sheet'),
              ),
              child: const Text('mở'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('mở'));
    await tester.pumpAndSettle();
    expect(find.text('Chọn thẻ'), findsOneWidget);
    expect(find.text('Nội dung sheet'), findsOneWidget);
    await tester.tap(find.byTooltip(CommonStrings.close));
    await tester.pumpAndSettle();
    expect(find.text('Nội dung sheet'), findsNothing);
  });

  group('VndEstimate', () {
    Future<ProviderContainer> pump(
      WidgetTester tester, {
      RemoteConfig? config,
    }) async {
      final prefs = await createTestPrefs();
      final container = ProviderContainer.test(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          remoteConfigProvider.overrideWithValue(config ?? _config),
        ],
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: _app(const Scaffold(body: Center(child: VndEstimate(1775)))),
        ),
      );
      return container;
    }

    testWidgets('shows the best-value estimate and explains it', (
      tester,
    ) async {
      await pump(tester);
      expect(find.text('≈ 268.000 ₫'), findsOneWidget);
      await tester.tap(find.text('≈ 268.000 ₫'));
      await tester.pumpAndSettle();
      expect(find.text(CommonStrings.vndEstimateTitle), findsOneWidget);
      expect(find.text(CommonStrings.vndSource('Nguồn thử')), findsOneWidget);
    });

    testWidgets('hidden without a verified table', (tester) async {
      await pump(tester, config: RemoteConfig.defaults);
      expect(find.textContaining('₫'), findsNothing);
    });

    testWidgets('hidden when the user turns it off', (tester) async {
      final container = await pump(tester);
      await container
          .read(appSettingsProvider.notifier)
          .update((s) => s.copyWith(showVndEstimate: false));
      await tester.pump();
      expect(find.textContaining('₫'), findsNothing);
    });
  });
}
