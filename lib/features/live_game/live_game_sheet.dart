import 'package:material_ui/material_ui.dart';

import '../../core/ui/empty_view.dart';
import 'live_game_strings.dart';

/// Opens S50 "Chi tiết trận" (full-height sheet) for the active account.
Future<void> showLiveGameSheet(BuildContext context) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const LiveGameSheet(),
    );

/// S50 body: header, agent select / rosters, live score, "Rời trận".
class LiveGameSheet extends StatelessWidget {
  const LiveGameSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.9,
      child: Column(
        children: [
          Text(
            LiveGameStrings.sheetTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Expanded(child: FeaturePlaceholder()),
        ],
      ),
    );
  }
}
