import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../social_strings.dart';

/// S61 "Trò chuyện" with one friend. Route `/profile/friends/:puuid/chat`.
class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.friendPuuid});

  final String friendPuuid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(SocialStrings.chatTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
