import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/auth/auth_routes.dart';
import '../../../core/l10n/auth_strings.dart';
import '../../../core/l10n/common_strings.dart';
import '../settings_strings.dart';

/// S01 "Chào mừng" (shown when no account is signed in). Top-level route
/// `/welcome`.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
          children: [
            Text(
              CommonStrings.appName.toUpperCase(),
              style: theme.textTheme.displayMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(CommonStrings.tagline, style: theme.textTheme.titleMedium),
            const SizedBox(height: 32),
            for (final (icon, text) in const [
              (Icons.storefront_outlined, SettingsStrings.welcomeBulletStore),
              (
                Icons.military_tech_outlined,
                SettingsStrings.welcomeBulletProfile,
              ),
              (Icons.favorite_border, SettingsStrings.welcomeBulletWishlist),
            ])
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(icon, color: theme.colorScheme.primary),
                title: Text(text),
              ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: () => unawaited(context.push(AuthRoutes.login)),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(AuthStrings.signInCta),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              SettingsStrings.welcomeFootnote,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              CommonStrings.riotDisclaimer,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
