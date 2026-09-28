import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../collection_strings.dart';

/// S32 "Chọn danh hiệu". Route `/collection/title`.
class PlayerTitlePickerScreen extends StatelessWidget {
  const PlayerTitlePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.playerTitleTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
