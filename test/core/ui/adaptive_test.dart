import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoActionSheet, CupertinoAlertDialog;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/ui_memory.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/adaptive.dart';
import 'package:valvn/core/ui/empty_view.dart';
import 'package:valvn/core/ui/filter_bar.dart';
import 'package:valvn/core/ui/segmented_tabs.dart';

import '../../helpers/test_prefs.dart';

Widget _app(Widget home, {TargetPlatform? platform, ThemeData? theme}) =>
    MaterialApp(
      theme: (theme ?? buildDarkTheme()).copyWith(platform: platform),
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      home: home,
    );

class _ConfirmHost extends StatefulWidget {
  const _ConfirmHost({this.destructive = false});

  final bool destructive;

  @override
  State<_ConfirmHost> createState() => _ConfirmHostState();
}

class _ConfirmHostState extends State<_ConfirmHost> {
  bool? result;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () async {
          final ok = await showConfirmDialog(
            context,
            title: 'Rời trận?',
            message: 'Bạn có thể bị phạt.',
            confirmLabel: 'Rời trận',
            destructive: widget.destructive,
          );
          setState(() => result = ok);
        },
        child: Text('open ${result ?? '-'}'),
      ),
    ),
  );
}

void main() {
  group('showConfirmDialog', () {
    testWidgets('uses a Material AlertDialog on Android', (tester) async {
      await tester.pumpWidget(
        _app(const _ConfirmHost(), platform: TargetPlatform.android),
      );
      await tester.tap(find.text('open -'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.byType(CupertinoAlertDialog), findsNothing);
      await tester.tap(find.widgetWithText(FilledButton, 'Rời trận'));
      await tester.pumpAndSettle();
      expect(find.text('open true'), findsOneWidget);
    });

    testWidgets('uses a CupertinoAlertDialog on iOS', (tester) async {
      await tester.pumpWidget(
        _app(
          const _ConfirmHost(destructive: true),
          platform: TargetPlatform.iOS,
        ),
      );
      await tester.tap(find.text('open -'));
      await tester.pumpAndSettle();
      expect(find.byType(CupertinoAlertDialog), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      await tester.tap(find.text(CommonStrings.cancel));
      await tester.pumpAndSettle();
      expect(find.text('open false'), findsOneWidget);
    });
  });

  testWidgets('showActionSheet is a Cupertino action sheet on iOS', (
    tester,
  ) async {
    String? picked;
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () async {
                picked = await showActionSheet<String>(
                  context,
                  actions: const [
                    SheetAction(value: 'a', label: 'Đổi tên'),
                    SheetAction(value: 'b', label: 'Xóa', destructive: true),
                  ],
                );
              },
              child: const Text('go'),
            ),
          ),
        ),
        platform: TargetPlatform.iOS,
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
    expect(find.byType(CupertinoActionSheet), findsOneWidget);
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();
    expect(picked, 'b');
  });

  test('UiMemory round-trips enums and falls back on unknown values', () async {
    final prefs = await createTestPrefs({'ui.x.bad': 'nope'});
    final container = ProviderContainer(
      overrides: [prefsProvider.overrideWithValue(prefs)],
    );
    addTearDown(container.dispose);
    final memory = container.read(uiMemoryProvider);
    expect(
      memory.readEnum('x.seg', TargetPlatform.values, TargetPlatform.android),
      TargetPlatform.android,
    );
    memory.writeEnum('x.seg', TargetPlatform.iOS);
    await pumpEventQueue();
    expect(prefs.getString('ui.x.seg'), 'iOS');
    expect(
      memory.readEnum('x.seg', TargetPlatform.values, TargetPlatform.android),
      TargetPlatform.iOS,
    );
    expect(
      memory.readEnum('x.bad', TargetPlatform.values, TargetPlatform.linux),
      TargetPlatform.linux,
    );
  });

  group('SegmentedTabs', () {
    Future<void> pumpTabs(
      WidgetTester tester, {
      required ValueNotifier<int> value,
      bool expand = false,
    }) => tester.pumpWidget(
      _app(
        Scaffold(
          body: ValueListenableBuilder<int>(
            valueListenable: value,
            builder: (context, v, _) => SegmentedTabs<int>(
              expand: expand,
              tabs: const [
                SegmentedTab(value: 0, label: 'Hằng ngày'),
                SegmentedTab(value: 1, label: 'Chợ Đêm', showDot: true),
                SegmentedTab(value: 2, label: 'Phụ kiện'),
                SegmentedTab(value: 3, label: 'Bundle'),
              ],
              selected: v,
              onChanged: (n) => value.value = n,
            ),
          ),
        ),
      ),
    );

    for (final expand in [false, true]) {
      testWidgets('selects on tap with a haptic (expand: $expand)', (
        tester,
      ) async {
        final haptics = <String>[];
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          (call) async {
            if (call.method == 'HapticFeedback.vibrate') {
              haptics.add('${call.arguments}');
            }
            return null;
          },
        );
        final value = ValueNotifier(0);
        addTearDown(value.dispose);
        await pumpTabs(tester, value: value, expand: expand);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Phụ kiện'));
        await tester.pumpAndSettle();
        expect(value.value, 2);
        expect(haptics, contains('HapticFeedbackType.selectionClick'));
        // Re-tapping the selected segment is a no-op.
        haptics.clear();
        await tester.tap(find.text('Phụ kiện'));
        await tester.pump();
        expect(haptics, isEmpty);
        expect(
          tester.getSemantics(find.bySemanticsLabel('Phụ kiện')),
          isSemantics(isSelected: true, isButton: true),
        );
      });
    }

    testWidgets('does not overflow at 320 dp and 200 % text', (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final value = ValueNotifier(1);
      addTearDown(value.dispose);
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 640),
            textScaler: TextScaler.linear(2),
          ),
          child: _app(
            Scaffold(
              body: SizedBox(
                height: 60,
                child: SegmentedTabs<int>(
                  expand: true,
                  tabs: const [
                    SegmentedTab(value: 0, label: 'Hằng ngày'),
                    SegmentedTab(value: 1, label: 'Chợ Đêm'),
                    SegmentedTab(value: 2, label: 'Phụ kiện'),
                    SegmentedTab(value: 3, label: 'Bundle'),
                  ],
                  selected: value.value,
                  onChanged: (n) => value.value = n,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  });

  testWidgets('SortButton opens the options and reports the pick', (
    tester,
  ) async {
    var sort = 'rarity';
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => SortButton<String>(
              options: const [
                (value: 'rarity', label: CommonStrings.sortRarity),
                (value: 'name', label: CommonStrings.sortName),
              ],
              selected: sort,
              onSelected: (v) => setState(() => sort = v),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text(CommonStrings.sortRarity));
    await tester.pumpAndSettle();
    await tester.tap(find.text(CommonStrings.sortName).last);
    await tester.pumpAndSettle();
    expect(sort, 'name');
    expect(find.text(CommonStrings.sortName), findsOneWidget);
  });

  testWidgets('GlassSearchField shows a clear button while typing', (
    tester,
  ) async {
    final changes = <String>[];
    await tester.pumpWidget(
      _app(Scaffold(body: GlassSearchField(onChanged: changes.add))),
    );
    expect(find.byTooltip(CommonStrings.clearSearch), findsNothing);
    await tester.enterText(find.byType(TextField), 'vandal');
    await tester.pump();
    expect(find.byTooltip(CommonStrings.clearSearch), findsOneWidget);
    await tester.tap(find.byTooltip(CommonStrings.clearSearch));
    await tester.pump();
    expect(changes.last, '');
    expect(find.byTooltip(CommonStrings.clearSearch), findsNothing);
  });

  testWidgets('EmptyView fits a 360 dp phone at 200 % text in both themes', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    for (final theme in [buildDarkTheme(), buildLightTheme()]) {
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(
            size: Size(360, 640),
            textScaler: TextScaler.linear(2),
          ),
          child: _app(
            theme: theme,
            Scaffold(
              body: EmptyView(
                title: 'Chưa có skin nào',
                message: 'Thêm skin vào wishlist để được báo khi lên kệ.',
                action: FilledButton(
                  onPressed: () {},
                  child: const Text('Duyệt skin'),
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Chưa có skin nào'), findsOneWidget);
    }
  });
}
