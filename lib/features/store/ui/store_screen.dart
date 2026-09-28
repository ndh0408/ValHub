import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../../../core/ui/tab_page_scaffold.dart';
import '../store_strings.dart';

/// Store segments (VF §6.2). The Night Market segment appears only while
/// `BonusStore` exists.
enum StoreSegment {
  daily,
  nightMarket,
  accessories,
  bundles;

  /// Parses the `?segment=` query value (`daily`, `nightmarket`,
  /// `accessories`, `bundles`).
  static StoreSegment parse(String? value) => switch (value?.toLowerCase()) {
    'nightmarket' => nightMarket,
    'accessories' => accessories,
    'bundles' => bundles,
    _ => daily,
  };

  String get queryValue => switch (this) {
    daily => 'daily',
    nightMarket => 'nightmarket',
    accessories => 'accessories',
    bundles => 'bundles',
  };
}

/// TAB 1 "Cửa hàng" (S10–S13). Route `/store[?segment=…]`.
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key, this.initialSegment = StoreSegment.daily});

  final StoreSegment initialSegment;

  @override
  Widget build(BuildContext context) {
    return const TabPageScaffold(
      title: StoreStrings.title,
      body: FeaturePlaceholder(),
    );
  }
}
