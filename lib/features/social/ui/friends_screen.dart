import 'package:material_ui/material_ui.dart';

import '../../../core/ui/empty_view.dart';
import '../social_strings.dart';

/// S60 "Bạn bè & trò chuyện". Route `/profile/friends`.
class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(SocialStrings.friendsTitle)),
      body: const FeaturePlaceholder(),
    );
  }
}
