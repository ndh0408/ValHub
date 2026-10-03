import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/domain/economy/wishlist.dart';
import 'package:valvn/core/domain/loadout/loadout_repository.dart';
import 'package:valvn/core/l10n/labels/economy_labels.dart';
import 'package:valvn/core/l10n/labels/loadout_labels.dart';
import 'package:valvn/features/collection/data/skin_query.dart' as collection;
import 'package:valvn/features/collection/ui/collection_labels.dart';
import 'package:valvn/features/wishlist/data/skin_query.dart' as wishlist;
import 'package:valvn/features/wishlist/ui/wishlist_labels.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

// Test-only resources prove these adapters use their supplied messages.
// This is not a shipped English translation or a new localization system.
class ProbeMessages extends AppLocalizationsVi {
  @override
  String get collectionSortName => 'Collection name probe';
  @override
  String get wishlistSortName => 'Wishlist name probe';
  @override
  String get economyPlaceDaily => 'Daily shop probe';
  @override
  String get economyPlaceBundleGeneric => 'Bundle probe';
  @override
  String get loadoutNotPersisted => 'Save not confirmed probe';
}

void main() {
  test('neutral sort models use supplied display resources', () {
    final messages = ProbeMessages();
    expect(collection.SkinSort.name.label(messages), 'Collection name probe');
    expect(wishlist.SkinSort.name.label(messages), 'Wishlist name probe');
    expect(collection.SkinSort.name.name, 'name');
    expect(wishlist.SkinSort.name.name, 'name');
  });

  test(
    'places and save failures use supplied resources without changing data',
    () {
      final messages = ProbeMessages();
      expect(WishlistPlace.daily.label(messages), 'Daily shop probe');
      expect(WishlistPlace.bundle.label(messages), 'Bundle probe');
      const failure = LoadoutSaveException(LoadoutSaveFailure.notPersisted);
      expect(failure.detail(messages), 'Save not confirmed probe');
      expect(failure.failure, LoadoutSaveFailure.notPersisted);
      expect(
        const LoadoutSaveException(LoadoutSaveFailure.request).detail(messages),
        isNull,
      );
    },
  );
}
