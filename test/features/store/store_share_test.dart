import 'package:flutter_riverpod/misc.dart' show Override;

import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart' show RenderRepaintBoundary;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/config/local_price.dart';
import 'package:valvn/core/config/remote_config.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/store/providers/store_share.dart';
import 'package:valvn/features/store/store_strings.dart';
import 'package:valvn/features/store/ui/share/store_share_card.dart';
import 'package:valvn/features/store/ui/share/store_share_sheet.dart';

import '../../helpers/test_prefs.dart';

const _account = Account(
  puuid: '11111111-1111-1111-1111-111111111111',
  gameName: 'Người Chơi',
  tagLine: 'VN2',
  region: 'ap',
  shard: 'ap',
);

final _now = DateTime(2026, 9, 30, 10);

StoreShareData _daily() => StoreShareData(
  kind: StoreShareKind.daily,
  createdAt: _now,
  expiresAt: DateTime(2026, 10, 1, 6, 59, 41),
  totalVp: 1775 + 2175,
  items: const [
    ShareOfferItem(
      name: 'Vandal Reaver',
      tierColor: Color(0xFFD1548D),
      price: 1775,
    ),
    ShareOfferItem(
      name: 'Phantom Thượng Giới',
      tierColor: Color(0xFF5A9FE2),
      price: 2175,
    ),
  ],
);

final _remote = RemoteConfig.fromJson({
  'vpPrices': {
    'US': {
      'currency': 'USD',
      'packs': [
        {'vp': 11000, 'price': 99.99},
      ],
    },
  },
});

Widget _app(
  Widget child, {
  ThemeData? theme,
  List<Override> overrides = const [],
  bool scroll = true,
}) => ProviderScope(
  overrides: overrides,
  child: MaterialApp(
    theme: theme ?? buildLightTheme(),
    localizationsDelegates: GlobalMaterialLocalizations.delegates,
    home: Scaffold(body: scroll ? SingleChildScrollView(child: child) : child),
  ),
);

Future<List<Override>> _overrides({StoreImageSharer? sharer}) async {
  final prefs = await createTestPrefs();
  return [
    prefsProvider.overrideWithValue(prefs),
    activeAccountProvider.overrideWithValue(_account),
    remoteConfigProvider.overrideWithValue(_remote),
    deviceCountryProvider.overrideWithValue('US'),
    shareImageProviderFactoryProvider.overrideWithValue((_) => null),
    if (sharer != null) storeImageSharerProvider.overrideWithValue(sharer),
  ];
}

void main() {
  testWidgets('the card shows the date, skins, prices and no account id', (
    tester,
  ) async {
    await tester.pumpWidget(_app(StoreShareCard(data: _daily())));
    expect(
      find.text(StoreStrings.shareCardDaily.toUpperCase()),
      findsOneWidget,
    );
    expect(find.text('Vandal Reaver'), findsOneWidget);
    expect(find.text('Phantom Thượng Giới'), findsOneWidget);
    expect(find.textContaining('1.775'), findsWidgets);
    // No Riot ID unless the user turns it on.
    expect(find.textContaining('VN2'), findsNothing);
    expect(find.textContaining('Người Chơi'), findsNothing);
  });

  testWidgets('the Riot ID appears only when given', (tester) async {
    await tester.pumpWidget(
      _app(StoreShareCard(data: _daily(), riotId: 'Người Chơi#VN2')),
    );
    expect(find.text('Người Chơi#VN2'), findsOneWidget);
  });

  testWidgets('the picture is opaque and dark whatever the app theme', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      _app(
        RepaintBoundary(
          key: key,
          child: StoreShareCard(data: _daily()),
        ),
      ),
    );
    Uint8List? rgba;
    var width = 0;
    await tester.runAsync(() async {
      final boundary =
          key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
      final image = await boundary.toImage();
      width = image.width;
      final data = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      rgba = data!.buffer.asUint8List();
      image.dispose();
    });
    final bytes = rgba!;
    // Bottom-right area (away from the red glow in the top-left corner).
    final x = width - 4;
    final y = (bytes.length ~/ 4 ~/ width) - 4;
    final i = (y * width + x) * 4;
    expect(bytes[i + 3], 255, reason: 'fully opaque');
    expect(bytes[i], lessThan(60), reason: 'dark background');
    expect(bytes[i + 1], lessThan(60));
    expect(bytes[i + 2], lessThan(60));
  });

  testWidgets('the sheet hides the Riot ID by default and shares a PNG', (
    tester,
  ) async {
    Uint8List? png;
    String? sharedName;
    final overrides = await _overrides(
      sharer: (bytes, {required fileName, subject, origin}) async {
        png = bytes;
        sharedName = fileName;
      },
    );
    tester.view.physicalSize = const Size(360, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      _app(
        StoreShareSheetBody(data: _daily()),
        overrides: overrides,
        scroll: false,
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Người Chơi#VN2'), findsNothing, reason: 'off by default');
    expect(find.text(StoreStrings.shareShowRiotId), findsOneWidget);
    // The local-currency estimate is offered when a table exists.
    expect(find.text(StoreStrings.shareShowPrice), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(find.text('Người Chơi#VN2'), findsOneWidget);
    await tester.tap(find.byType(Switch).first);
    await tester.pump();
    expect(find.text('Người Chơi#VN2'), findsNothing);

    await tester.tap(find.text(StoreStrings.shareButton));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 600)),
    );
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 600)),
    );
    await tester.pump();
    expect(png, isNotNull, reason: 'the native share sheet was called');
    expect(png!.sublist(0, 4), [0x89, 0x50, 0x4E, 0x47]);
    expect(
      sharedName,
      matches(RegExp(r'^valvn-cua-hang-\d{4}-\d{2}-\d{2}\.png$')),
    );
  });
}
