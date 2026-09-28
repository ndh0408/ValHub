import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../collection_strings.dart';

/// S38 "Bộ trang bị đã lưu" (local presets per account). Route
/// `/collection/presets`.
class LoadoutPresetsScreen extends StatelessWidget {
  const LoadoutPresetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.presetsTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
