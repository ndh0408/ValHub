import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../collection_strings.dart';

/// S33 "Trang bị vũ khí". Route `/collection/weapons`.
class WeaponLoadoutScreen extends StatelessWidget {
  const WeaponLoadoutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.weaponLoadoutTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
