import 'package:material_ui/material_ui.dart';

import '../../core/ui/empty_view.dart';
import 'live_game_strings.dart';

/// Opens S51 "Trang bị của người chơi" for [playerPuuid] in [matchId].
Future<void> showPlayerLoadoutSheet(
  BuildContext context, {
  required String matchId,
  required String playerPuuid,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  builder: (_) =>
      PlayerLoadoutSheet(matchId: matchId, playerPuuid: playerPuuid),
);

/// S51: equipped skins / chromas, buddies, card, title, sprays of a player.
class PlayerLoadoutSheet extends StatelessWidget {
  const PlayerLoadoutSheet({
    super.key,
    required this.matchId,
    required this.playerPuuid,
  });

  final String matchId;
  final String playerPuuid;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 480,
      child: Column(
        children: [
          Text(
            LiveGameStrings.playerLoadoutTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const Expanded(child: FeaturePlaceholder()),
        ],
      ),
    );
  }
}
