import 'package:go_router/go_router.dart';

import 'legal/legal_documents.dart';
import 'ui/about_screen.dart';
import 'ui/legal_document_screen.dart';
import 'ui/server_status_screen.dart';
import 'ui/session_log_screen.dart';
import 'ui/settings_screen.dart';
import 'ui/welcome_screen.dart';

/// Locations of the settings / onboarding feature.
abstract final class SettingsRoutes {
  static const root = '/settings';
  static const log = '/settings/log';
  static const about = '/settings/about';

  /// "Trạng thái máy chủ" (X-1 maintenances and incidents per region).
  static const status = '/settings/status';
  static const welcome = '/welcome';

  /// `/settings/about/<id>` of a legal document: `privacy`, `terms`,
  /// `community`, `notice`.
  static String legal(LegalDocument doc) => '$about/${doc.id}';
}

/// Branch 4 of the tab shell.
List<RouteBase> get settingsBranchRoutes => [
  GoRoute(
    path: SettingsRoutes.root,
    builder: (context, state) => const SettingsScreen(),
    routes: [
      GoRoute(
        path: 'log',
        builder: (context, state) => const SessionLogScreen(),
      ),
      GoRoute(
        path: 'status',
        builder: (context, state) => const ServerStatusScreen(),
      ),
      GoRoute(
        path: 'about',
        builder: (context, state) => const AboutScreen(),
        routes: [
          for (final doc in LegalDocuments.all)
            GoRoute(
              path: doc.id,
              builder: (context, state) => LegalDocumentScreen(document: doc),
            ),
        ],
      ),
    ],
  ),
];

/// Top-level routes of the settings feature (outside the tab shell).
List<RouteBase> get settingsTopLevelRoutes => [
  GoRoute(
    path: SettingsRoutes.welcome,
    builder: (context, state) => const WelcomeScreen(),
  ),
];
