import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../collection_strings.dart';

/// S34 "Chọn skin" for one weapon. Route `/collection/weapons/:weaponId`.
class WeaponSkinsScreen extends StatelessWidget {
  const WeaponSkinsScreen({super.key, required this.weaponId});

  final String weaponId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.weaponSkinsTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
