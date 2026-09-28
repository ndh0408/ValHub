import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../collection_strings.dart';

/// `:type` of `/collection/browse/:type` (S39).
enum CollectionBrowseType {
  skin('skin', CollectionStrings.browseSkins),
  buddy('buddy', CollectionStrings.browseBuddies),
  spray('spray', CollectionStrings.browseSprays),
  card('card', CollectionStrings.browseCards),
  title('title', CollectionStrings.browseTitles),
  flex('flex', CollectionStrings.browseFlex);

  const CollectionBrowseType(this.path, this.label);

  /// Path segment.
  final String path;
  final String label;

  static CollectionBrowseType parse(String? value) =>
      values.firstWhere((t) => t.path == value, orElse: () => skin);
}

/// S39 "Duyệt bộ sưu tập". Route `/collection/browse/:type`.
class BrowseCollectionScreen extends StatelessWidget {
  const BrowseCollectionScreen({super.key, required this.type});

  final CollectionBrowseType type;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(type.label)),
      body: const FeaturePlaceholder(),
    );
  }
}
