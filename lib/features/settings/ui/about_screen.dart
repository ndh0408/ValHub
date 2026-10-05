import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../legal/legal_documents.dart';
import '../legal/legal_providers.dart';
import '../providers/settings_providers.dart';
import '../settings_routes.dart';
import '../settings_strings.dart';
import 'sections/app_info_sections.dart';
import 'widgets/app_icon_mark.dart';
import 'widgets/legal_widgets.dart';
import 'widgets/settings_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// S72 "Giới thiệu & pháp lý" hub (docs/design/IA.md "Pháp lý"): the app
/// icon, name, version and a one-line intro; PHÁP LÝ (privacy policy, terms,
/// community standards, Riot legal notice, third-party libraries); LIÊN HỆ
/// (email, feedback); the copyright line and the Riot
/// disclaimer at the bottom. Route `/settings/about`.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static IconData _iconOf(LegalDocumentRef doc) => switch (doc.id) {
    'privacy' => Icons.privacy_tip_outlined,
    'terms' => Icons.gavel_outlined,
    'community' => Icons.diversity_3_outlined,
    _ => Icons.policy_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final mailto = LegalInfo.contactMailto;
    return SubPageScaffold(
      title: context.l10n.settingsAboutTitle,
      slivers: [
        SliverList.list(
          children: [
            _Identity(packageInfo: packageInfo),
            SettingsGroup(
              title: context.l10n.legalLegalHeader,
              children: [
                for (final doc in LegalDocuments.all)
                  _LegalRow(document: doc, icon: _iconOf(doc)),
                ListTile(
                  leading: const SettingsIcon(Icons.library_books_outlined),
                  title: Text(context.l10n.legalThirdPartyLicenses),
                  subtitle: Text(context.l10n.legalThirdPartyLicensesBody),
                  trailing: const SettingsChevron(),
                  onTap: () => showThirdPartyLicenses(
                    context,
                    version: packageInfo.value?.version,
                  ),
                ),
              ],
            ),
            SettingsGroup(
              title: context.l10n.legalContactHeader,
              children: [
                ListTile(
                  leading: const SettingsIcon(Icons.mail_outline),
                  title: Text(context.l10n.legalContact),
                  subtitle: Text(context.l10n.legalContactBody),
                  trailing: mailto == null
                      ? null
                      : const SettingsChevron(icon: Icons.open_in_new),
                  onTap: mailto == null
                      ? null
                      : () => unawaited(openSettingsLink(context, ref, mailto)),
                ),
                ListTile(
                  leading: const SettingsIcon(Icons.forum_outlined),
                  title: Text(context.l10n.settingsFeedback),
                  subtitle: Text(context.l10n.settingsFeedbackSubtitle),
                  trailing: const SettingsChevron(icon: Icons.open_in_new),
                  onTap: () => unawaited(
                    openSettingsLink(context, ref, SettingsLinks.feedback),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.legalLicensePageLegalese,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    context.l10n.commonRiotDisclaimer,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: muted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _LegalRow extends ConsumerWidget {
  const _LegalRow({required this.document, required this.icon});

  final LegalDocumentRef document;
  final IconData icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = (document: document, locale: context.l10n.localeName);
    final value = ref.watch(legalDocumentProvider(request));
    if (value.hasError) {
      return ListTile(
        leading: SettingsIcon(icon),
        title: Text(context.l10n.legalContentUnavailable),
        subtitle: TextButton(
          onPressed: () => ref.invalidate(legalDocumentProvider(request)),
          child: Text(context.l10n.commonRetry),
        ),
      );
    }
    final doc = value.value;
    return ListTile(
      leading: SettingsIcon(icon),
      title: doc == null
          ? const Skeleton(width: 180, height: 16)
          : Text(doc.title),
      subtitle: doc == null
          ? const Skeleton(width: 240, height: 12)
          : Text(doc.summary),
      trailing: const SettingsChevron(),
      onTap: doc == null
          ? null
          : () => unawaited(context.push(SettingsRoutes.legal(document))),
    );
  }
}

/// App icon, "ValHub" wordmark, tagline, version pill and a short intro.
class _Identity extends StatelessWidget {
  const _Identity({required this.packageInfo});

  final AsyncValue<PackageInfo> packageInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final muted = scheme.onSurfaceVariant;
    final versionStyle = theme.textTheme.labelMedium?.copyWith(
      color: muted,
      fontWeight: FontWeight.w600,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 4),
      child: Column(
        children: [
          const AppIconMark(size: 88),
          const SizedBox(height: 16),
          Semantics(
            header: true,
            label: context.l10n.commonAppName,
            excludeSemantics: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(text: context.l10n.settingsLogoPrefix),
                  TextSpan(
                    text: context.l10n.settingsLogoSuffix,
                    style: TextStyle(
                      color: legibleAccent(context, ValColors.red),
                    ),
                  ),
                ],
              ),
              style: ValText.screenTitle.copyWith(color: scheme.onSurface),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.commonTagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 12),
          DecoratedBox(
            decoration: BoxDecoration(
              color: scheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(ValRadius.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: switch (packageInfo) {
                AsyncData(:final value) => Text(
                  value.buildNumber.isEmpty
                      ? context.l10n.settingsVersion(value.version)
                      : '${context.l10n.settingsVersion(value.version)} · '
                            '${context.l10n.settingsBuildNumber(value.buildNumber)}',
                  textAlign: TextAlign.center,
                  style: versionStyle,
                ),
                AsyncError() => Text(
                  context.l10n.settingsVersion(context.l10n.commonDash),
                  style: versionStyle,
                ),
                _ => const Skeleton(width: 120, height: 12),
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.legalAboutIntro,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: muted,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
