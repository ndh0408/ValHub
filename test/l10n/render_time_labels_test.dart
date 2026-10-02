import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/app/shell.dart';
import 'package:valvn/core/domain/competitive/match_models.dart';
import 'package:valvn/core/l10n/l10n.dart';
import 'package:valvn/core/network/riot_exception.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/core/ui/error_view.dart';
import 'package:valvn/features/home/data/home_card.dart';
import 'package:valvn/features/home/ui/home_card_frame.dart';
import 'package:valvn/features/profile/ui/widgets/profile_widgets.dart';
import 'package:valvn/l10n/gen/app_localizations_vi.dart';

import '../helpers/test_prefs.dart';

// Synthetic resource reload: does not claim an unshipped translation exists.
class _Messages extends AppLocalizationsVi {
  _Messages(this.version);
  final String version;
  @override
  String get commonTabHome => 'home-$version';
  @override
  String get homeCardStore => 'store-card-$version';
  @override
  String get competitiveVictory => 'victory-$version';
  @override
  String get commonErrorNetwork => 'network-$version';
}

class _MessagesDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _MessagesDelegate(this.messages);
  final AppLocalizations messages;
  @override
  bool isSupported(Locale locale) => locale.languageCode == 'vi';
  @override
  Future<AppLocalizations> load(Locale locale) => SynchronousFuture(messages);
  @override
  bool shouldReload(_MessagesDelegate old) => messages != old.messages;
}

void main() {
  testWidgets(
    'shell, home metadata, match tags and errors follow resource reload',
    (tester) async {
      final prefs = await createTestPrefs();
      final messages = ValueNotifier<AppLocalizations>(_Messages('first'));
      addTearDown(messages.dispose);
      final router = GoRouter(
        initialLocation: '/t0',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, shell) =>
                AppShell(navigationShell: shell),
            branches: [
              for (var i = 0; i < AppTab.values.length; i++)
                StatefulShellBranch(
                  routes: [
                    GoRoute(
                      path: '/t$i',
                      builder: (context, state) => i == 0
                          ? const Column(
                              children: [
                                HomeCardFrame(
                                  card: HomeCardId.store,
                                  showMenu: false,
                                  child: SizedBox(),
                                ),
                                OutcomeTag(MatchOutcome.win),
                                ErrorView(
                                  error: TransientException(reason: 'network'),
                                  compact: true,
                                ),
                              ],
                            )
                          : Text('branch-$i'),
                    ),
                  ],
                ),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [prefsProvider.overrideWithValue(prefs)],
          child: ValueListenableBuilder<AppLocalizations>(
            valueListenable: messages,
            builder: (context, value, child) => MaterialApp.router(
              locale: const Locale('vi'),
              supportedLocales: const [Locale('vi')],
              localizationsDelegates: [
                _MessagesDelegate(value),
                ...appLocalizationsDelegates,
              ],
              theme: buildDarkTheme(),
              routerConfig: router,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      for (final name in ['home', 'store-card', 'victory', 'network']) {
        expect(find.text('$name-first'), findsWidgets);
      }
      messages.value = _Messages('second');
      await tester.pumpAndSettle();
      for (final name in ['home', 'store-card', 'victory', 'network']) {
        expect(find.text('$name-first'), findsNothing);
        expect(find.text('$name-second'), findsWidgets);
      }
      expect(router.routeInformationProvider.value.uri.path, '/t0');
      expect(tester.takeException(), isNull);
    },
  );
}
