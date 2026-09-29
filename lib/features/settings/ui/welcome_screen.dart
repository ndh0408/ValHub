import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/auth/auth_routes.dart';
import '../../../core/l10n/auth_strings.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../settings_strings.dart';
import 'widgets/legal_widgets.dart';

/// S01 "Chào mừng" (shown when no account is signed in). Top-level route
/// `/welcome`.
///
/// Text logo, tagline, three feature bullets, the Riot sign-in button, the
/// privacy footnote and the Riot legal disclaimer. Scrolls on short phones;
/// on tall ones the button sits at the bottom.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.alphaBlend(
                scheme.primary.withValues(alpha: 0.10),
                scheme.surface,
              ),
              scheme.surface,
              scheme.surfaceContainerLowest,
            ],
            stops: const [0, 0.45, 1],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                sliver: SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _Logo(),
                      const SizedBox(height: 8),
                      Text(
                        CommonStrings.tagline,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 36),
                      const _Bullet(
                        icon: Icons.storefront_outlined,
                        text: SettingsStrings.welcomeBulletStore,
                      ),
                      const _Bullet(
                        icon: Icons.military_tech_outlined,
                        text: SettingsStrings.welcomeBulletProfile,
                      ),
                      const _Bullet(
                        icon: Icons.favorite_border,
                        text: SettingsStrings.welcomeBulletWishlist,
                      ),
                      const Spacer(),
                      const SizedBox(height: 32),
                      FilledButton.icon(
                        style: FilledButton.styleFrom(
                          minimumSize: const Size.fromHeight(52),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.login),
                        label: const Text(
                          AuthStrings.signInCta,
                          textAlign: TextAlign.center,
                        ),
                        onPressed: () =>
                            unawaited(context.push(AuthRoutes.login)),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Icon(
                              Icons.lock_outline,
                              size: 16,
                              color: scheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              SettingsStrings.welcomeFootnote,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LegalConsentText(
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: scheme.onSurfaceVariant,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        CommonStrings.riotDisclaimer,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.8),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// "ValVN" in Anton with a red accent bar and a red "VN".
class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium?.copyWith(
      color: theme.colorScheme.onSurface,
      height: 1,
    );
    return Semantics(
      header: true,
      label: CommonStrings.appName,
      excludeSemantics: true,
      child: Row(
        children: [
          Container(width: 6, height: 44, color: ValColors.red),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: SettingsStrings.logoPrefix),
                    TextSpan(
                      text: SettingsStrings.logoSuffix,
                      style: const TextStyle(color: ValColors.red),
                    ),
                  ],
                ),
                style: style,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: scheme.primary.withValues(alpha: 0.3)),
            ),
            child: Icon(icon, size: 22, color: scheme.primary),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
        ],
      ),
    );
  }
}
