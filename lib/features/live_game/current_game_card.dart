import 'dart:async';

import 'package:material_ui/material_ui.dart';

import 'live_game_sheet.dart';
import 'live_game_strings.dart';

/// R7 "Trận hiện tại" card shown on the profile tab: state line
/// ("Không trong trận", "Đang chọn đặc vụ · Ascent", "Đang đấu · Lotus · 8 – 4")
/// with a refresh ring. Tap opens [showLiveGameSheet].
class CurrentGameCard extends StatelessWidget {
  const CurrentGameCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.sports_esports_outlined),
        title: const Text(LiveGameStrings.currentGame),
        subtitle: const Text(LiveGameStrings.notInGame),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => unawaited(showLiveGameSheet(context)),
      ),
    );
  }
}
