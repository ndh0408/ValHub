import 'package:material_ui/material_ui.dart';

import '../../core/ui/empty_view.dart';

/// Context the sheet is opened from.
enum SkinDetailMode {
  /// From the store / Night Market / bundle: price + wishlist button.
  store,

  /// From the collection: owned levels / chromas, "Đã sở hữu".
  owned,

  /// From the wishlist or the all-skins catalog: wishlist toggle.
  catalog,
}

/// Opens S15 "Chi tiết skin" as a full-height modal sheet.
///
/// [skinOrLevelUuid] may be a skin, level or chroma uuid (resolved with
/// `ContentDb.skinByAnyUuid`).
Future<void> showSkinDetailSheet(
  BuildContext context, {
  required String skinOrLevelUuid,
  SkinDetailMode mode = SkinDetailMode.store,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => SkinDetailSheet(skinOrLevelUuid: skinOrLevelUuid, mode: mode),
);

/// S15 body (render / video, variants, upgrades, wishlist button).
class SkinDetailSheet extends StatelessWidget {
  const SkinDetailSheet({
    super.key,
    required this.skinOrLevelUuid,
    this.mode = SkinDetailMode.store,
  });

  final String skinOrLevelUuid;
  final SkinDetailMode mode;

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 480, child: FeaturePlaceholder());
  }
}
