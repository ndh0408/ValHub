import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../collection_strings.dart';

/// S31 "Chọn thẻ người chơi". Route `/collection/card`.
class PlayerCardPickerScreen extends StatelessWidget {
  const PlayerCardPickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.playerCardTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
