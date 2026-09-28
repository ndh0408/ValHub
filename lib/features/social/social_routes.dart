import 'package:go_router/go_router.dart';

import 'ui/chat_screen.dart';
import 'ui/friends_screen.dart';
import 'ui/party_screen.dart';

/// Locations of the party & social feature (nested under `/profile`).
abstract final class SocialRoutes {
  static const party = '/profile/party';
  static const friends = '/profile/friends';

  static String chat(String friendPuuid) => '$friends/$friendPuuid/chat';
}

/// Relative sub-routes nested by the app router under `/profile`.
List<RouteBase> get socialRoutes => [
  GoRoute(path: 'party', builder: (context, state) => const PartyScreen()),
  GoRoute(
    path: 'friends',
    builder: (context, state) => const FriendsScreen(),
    routes: [
      GoRoute(
        path: ':puuid/chat',
        builder: (context, state) =>
            ChatScreen(friendPuuid: state.pathParameters['puuid'] ?? ''),
      ),
    ],
  ),
];
