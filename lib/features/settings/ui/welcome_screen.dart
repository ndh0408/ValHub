import 'dart:async';

import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/auth/auth_routes.dart';
import '../../../core/l10n/auth_strings.dart';
import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/adaptive.dart';
import '../../../core/ui/val_widgets.dart';
import '../settings_strings.dart';

/// S01 "Chào mừng" (shown when no account is signed in). Top-level route
/// `/welcome`.
///
/// Hero backdrop (red glow + diagonal stripes), kicker, Anton logo, tagline,
/// a card with the three highlights, the Riot sign-in button, the privacy
/// footnote and the Riot legal disclaimer. Scrolls on short phones; on tall
/// ones the button sits at the bottom.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  scheme.surface,
                  scheme.surface,
                  scheme.surfaceContainerLowest,
                ],
                stops: const [0, 0.55, 1],
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(1.1, -1.05),
                radius: 1.1,
                colors: [
                  scheme.primary.withValues(alpha: 0.30),
                  scheme.primary.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          RepaintBoundary(
            child: CustomPaint(
              painter: _StripesPainter(scheme.primary.withValues(alpha: 0.07)),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                  sliver: SliverFillRemaining(
                    hasScrollBody: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          SettingsStrings.welcomeKicker,
                          style: ValText.label.copyWith(
                            color: scheme.primary,
                            letterSpacing: 1.6,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const _Logo(),
                        const SizedBox(height: 10),
                        Text(
                          CommonStrings.tagline,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 28),
                        const _FeatureCard(),
                        const Spacer(),
                        const SizedBox(height: 28),
                        const _SignInButton(),
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
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          CommonStrings.riotDisclaimer,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: scheme.onSurfaceVariant,
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
        ],
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
    final accent = theme.colorScheme.primary;
    final style = ValText.display(
      64,
      color: theme.colorScheme.onSurface,
    ).copyWith(height: 1);
    return Semantics(
      header: true,
      label: CommonStrings.appName,
      excludeSemantics: true,
      child: Row(
        children: [
          Container(
            width: 6,
            height: 56,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 14),
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
                      style: TextStyle(color: accent),
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

/// The three highlights on one card, each with a tinted icon tile.
class _FeatureCard extends StatelessWidget {
  const _FeatureCard();

  @override
  Widget build(BuildContext context) {
    final hairline = valColorsOf(context).hairline;
    const items = [
      (
        Icons.storefront_outlined,
        ValColors.red,
        SettingsStrings.welcomeBulletStore,
        SettingsStrings.welcomeBulletStoreDetail,
      ),
      (
        Icons.military_tech_outlined,
        ValColors.gold,
        SettingsStrings.welcomeBulletProfile,
        SettingsStrings.welcomeBulletProfileDetail,
      ),
      (
        Icons.favorite_border,
        TierColors.premium,
        SettingsStrings.welcomeBulletWishlist,
        SettingsStrings.welcomeBulletWishlistDetail,
      ),
    ];
    return ValCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: Theme.of(context).colorScheme.surfaceContainer
          .withValues(alpha: 0.88),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 70, color: hairline),
            _Bullet(
              icon: items[i].$1,
              color: items[i].$2,
              text: items[i].$3,
              detail: items[i].$4,
            ),
          ],
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({
    required this.icon,
    required this.color,
    required this.text,
    required this.detail,
  });

  final IconData icon;
  final Color color;
  final String text;
  final String detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = legibleAccent(context, color, min: 3);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(ValRadius.small),
            ),
            child: Icon(icon, size: 22, color: tint),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width red CTA (56 dp) with a soft glow.
class _SignInButton extends StatelessWidget {
  const _SignInButton();

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(ValRadius.small),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(56),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        icon: const Icon(Icons.login),
        label: const Text(AuthStrings.signInCta, textAlign: TextAlign.center),
        onPressed: () {
          Haptics.light();
          unawaited(context.push(AuthRoutes.login));
        },
      ),
    );
  }
}

/// Three bold diagonal stripes in the top-right corner.
class _StripesPainter extends CustomPainter {
  _StripesPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 14;
    for (var i = 0; i < 3; i++) {
      final x = size.width - 40.0 - i * 34;
      canvas.drawLine(Offset(x, -10), Offset(x + 160, 170), paint);
    }
  }

  @override
  bool shouldRepaint(_StripesPainter oldDelegate) => oldDelegate.color != color;
}
