import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account_status.dart';
import 'package:valvn/core/l10n/account_labels.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/adaptive.dart';
import 'package:valvn/core/ui/async_value_view.dart';
import 'package:valvn/core/ui/empty_view.dart';
import 'package:valvn/core/ui/filter_bar.dart';
import 'package:valvn/core/ui/release_error_view.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

class _Resources extends AppLocalizationsVi {
  _Resources(this.marker);
  final String marker;
  @override
  String get commonNoData => 'empty-$marker';
  @override
  String get commonSearch => 'search-$marker';
  @override
  String get commonSort => 'sort-$marker';
  @override
  String get commonCancel => 'cancel-$marker';
  @override
  String get commonErrorGeneric => 'error-$marker';
  @override
  String get accountStatusOnline => 'activity-$marker';
}

class _Delegate extends LocalizationsDelegate<AppLocalizations> {
  const _Delegate(this.marker);
  final String marker;
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'vi';
  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture(_Resources(marker));
  @override
  bool shouldReload(_Delegate old) => marker != old.marker;
}

Widget _app(Widget home, String marker, {TargetPlatform? platform}) =>
    MaterialApp(
      theme: buildDarkTheme().copyWith(platform: platform),
      locale: const Locale('vi'),
      supportedLocales: const [Locale('vi')],
      localizationsDelegates: [
        _Delegate(marker),
        ...appLocalizationsDelegates.skip(1),
      ],
      home: home,
    );

class _Defaults extends StatelessWidget {
  const _Defaults();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(
      children: [
        const EmptyView(),
        AsyncValueView<int>(
          value: const AsyncData(0),
          isEmpty: (value) => value == 0,
          data: (_) => const SizedBox.shrink(),
        ),
        const GlassSearchField(),
        SortButton<int>(options: const [], selected: 0, onSelected: (_) {}),
        Text(context.l10n.accountActivityName(AccountActivity.online)),
      ],
    ),
  );
}

class _Confirm extends StatelessWidget {
  const _Confirm();
  @override
  Widget build(BuildContext context) => Scaffold(
    body: TextButton(
      onPressed: () => showConfirmDialog(
        context,
        title: 'confirm-title',
        message: 'confirm-body',
        confirmLabel: 'confirm-button',
      ),
      child: const Text('open'),
    ),
  );
}

void main() {
  testWidgets('shared defaults update on the same existing subtree', (
    tester,
  ) async {
    await tester.pumpWidget(_app(const _Defaults(), 'first'));
    await tester.pumpAndSettle();
    final before = tester.element(find.byType(_Defaults));
    expect(find.text('empty-first'), findsNWidgets(2));
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration!.hintText,
      'search-first',
    );
    await tester.pumpWidget(_app(const _Defaults(), 'second'));
    await tester.pumpAndSettle();
    expect(tester.element(find.byType(_Defaults)), same(before));
    expect(find.text('empty-first'), findsNothing);
    expect(find.text('empty-second'), findsNWidgets(2));
    expect(find.text('sort-second'), findsOneWidget);
    expect(find.text('activity-second'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration!.hintText,
      'search-second',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('explicit shared text overrides survive resource replacement', (
    tester,
  ) async {
    const home = Scaffold(
      body: Column(
        children: [
          EmptyView(message: 'custom-empty'),
          GlassSearchField(hintText: 'custom-search'),
        ],
      ),
    );
    await tester.pumpWidget(_app(home, 'first'));
    await tester.pumpAndSettle();
    await tester.pumpWidget(_app(home, 'second'));
    await tester.pumpAndSettle();
    expect(find.text('custom-empty'), findsOneWidget);
    expect(
      tester.widget<TextField>(find.byType(TextField)).decoration!.hintText,
      'custom-search',
    );
    expect(find.text('empty-second'), findsNothing);
  });

  for (final platform in [TargetPlatform.android, TargetPlatform.iOS]) {
    testWidgets('an open $platform confirmation updates its cancel default', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const _Confirm(), 'first', platform: platform),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('cancel-first'), findsOneWidget);
      await tester.pumpWidget(
        _app(const _Confirm(), 'second', platform: platform),
      );
      await tester.pumpAndSettle();
      expect(find.text('cancel-first'), findsNothing);
      expect(find.text('cancel-second'), findsOneWidget);
      await tester.tap(find.text('cancel-second'));
      await tester.pumpAndSettle();
      expect(find.text('confirm-title'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'release error works without an app root or inherited resources',
    (tester) async {
      await tester.pumpWidget(
        ReleaseErrorView(fallbackResources: _Resources('boot')),
      );
      expect(find.text('error-boot'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('release error follows ambient resources instead of boot copy', (
    tester,
  ) async {
    final error = ReleaseErrorView(fallbackResources: _Resources('boot'));
    await tester.pumpWidget(_app(error, 'first'));
    await tester.pumpAndSettle();
    expect(find.text('error-first'), findsOneWidget);
    await tester.pumpWidget(_app(error, 'second'));
    await tester.pumpAndSettle();
    expect(find.text('error-first'), findsNothing);
    expect(find.text('error-boot'), findsNothing);
    expect(find.text('error-second'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
