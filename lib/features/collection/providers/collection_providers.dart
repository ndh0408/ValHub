/// Refresh helpers of the collection tab.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/domain/economy/economy.dart';
import '../../../core/domain/loadout/loadout.dart';

/// Pull-to-refresh of every collection screen: refetches the loadout and the
/// entitlements (SUMMARY §10 "on focus"). Errors are rendered by the
/// screens' `AsyncValueView`s, so they are swallowed here.
Future<void> refreshCollection(WidgetRef ref, String puuid) async {
  final futures = <Future<Object?>>[
    ref.refresh(loadoutProvider(puuid).future),
    ref.refresh(entitlementsProvider(puuid).future),
  ];
  await Future.wait([
    for (final f in futures) f.then<void>((_) {}, onError: (Object _) {}),
  ]);
}
