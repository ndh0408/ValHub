import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../collection_strings.dart';

/// Opens S36 "Chọn phụ kiện súng" for [weaponId].
Future<void> showBuddyPickerSheet(
  BuildContext context, {
  required String weaponId,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) => BuddyPickerSheet(weaponId: weaponId),
);

/// S36 buddy grid with instance counts ("Còn 2/3") and "Gỡ phụ kiện".
class BuddyPickerSheet extends StatelessWidget {
  const BuddyPickerSheet({super.key, required this.weaponId});

  final String weaponId;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 420,
      child: Column(
        children: [
          Text(
            CollectionStrings.buddyPickerTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const Expanded(child: FeaturePlaceholder()),
        ],
      ),
    );
  }
}
