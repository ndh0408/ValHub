import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../collection_strings.dart';

/// TAB 3 "Bộ sưu tập" hub (S30). Route `/collection`.
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const TabPageScaffold(
      title: CollectionStrings.title,
      body: FeaturePlaceholder(),
    );
  }
}
