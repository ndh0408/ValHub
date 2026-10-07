import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/community/ui/hidden_authors_sheet.dart';

import '../../../helpers/l10n.dart';
import '../community_test_env.dart';

void main() {
  testWidgets('hidden players: shared sheet chrome, unhide, close', (
    tester,
  ) async {
    final env = await CommunityTestEnv.create();
    await env.prefs.setJson(
      PrefKeys.account(mePuuid, 'community.hiddenAuthors'),
      [
        {'id': otherId, 'name': 'Người Chơi#VN2', 'rule': 'muted'},
      ],
    );
    await pumpCommunity(
      tester,
      env,
      const Scaffold(body: HiddenAuthorsRow(puuid: mePuuid)),
    );
    await settle(tester);
    expect(find.text(tl.communityHiddenAuthorsCount(1)), findsOneWidget);

    await tester.tap(find.text(tl.communityHiddenAuthors));
    await settle(tester);
    expect(find.text('Người Chơi#VN2'), findsOneWidget);
    expect(find.text(tl.communityHiddenAuthorsHint), findsOneWidget);

    await tester.tap(find.byTooltip(tl.communityUnhideAuthor));
    await settle(tester);
    expect(find.text('Người Chơi#VN2'), findsNothing);
    // The row behind the sheet and the sheet both say nobody is hidden.
    expect(find.text(tl.communityHiddenAuthorsEmpty), findsNWidgets(2));

    await tester.tap(find.byTooltip(tl.commonClose));
    await settle(tester, frames: 20);
    expect(find.text(tl.communityHiddenAuthorsHint), findsNothing);
    expect(tester.takeException(), isNull);
    await unmount(tester);
  });
}
