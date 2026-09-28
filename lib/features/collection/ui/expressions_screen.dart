import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../collection_strings.dart';

/// S37 "Tổ hợp cảm xúc". Route `/collection/expressions`.
class ExpressionsScreen extends StatelessWidget {
  const ExpressionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(CollectionStrings.expressionsTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
