import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../collection_strings.dart';

/// S35 "Tùy chỉnh skin" (chroma, level, buddy). Route
/// `/collection/weapons/:weaponId/skin/:skinId`.
class SkinCustomizeScreen extends StatelessWidget {
  const SkinCustomizeScreen({
    super.key,
    required this.weaponId,
    required this.skinId,
  });

  final String weaponId;

  final String skinId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.skinCustomizeTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
