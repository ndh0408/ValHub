import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/ui/sub_page.dart';
import '../legal/legal_documents.dart';
import '../legal/legal_strings.dart';
import '../providers/settings_providers.dart';
import '../settings_routes.dart';
import '../settings_strings.dart';
import 'sections/app_info_sections.dart';
import 'widgets/app_icon_mark.dart';
import 'widgets/legal_widgets.dart';
import 'widgets/settings_widgets.dart';

/// S72 "Giới thiệu & pháp lý" hub (docs/design/IA.md "Pháp lý"): the app
/// icon, name, version and a one-line intro; PHÁP LÝ (privacy policy, terms,
/// community standards, Riot legal notice, third-party libraries); LIÊN HỆ
/// (email, feedback); the copyright line and the Riot
/// disclaimer at the bottom. Route `/settings/about`.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static IconData _iconOf(LegalDocument doc) => switch (doc.id) {
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
      title: SettingsStrings.aboutTitle,
      slivers: [
        SliverList.list(
          children: [
            _Identity(packageInfo: packageInfo),
            SettingsGroup(
              title: LegalStrings.legalHeader,
              children: [
                for (final doc in LegalDocuments.all)
                  ListTile(
                    leading: SettingsIcon(_iconOf(doc)),
                    title: Text(doc.title),
                    subtitle: Text(doc.summary),
                    trailing: const SettingsChevron(),
                    onTap: () =>
                        unawaited(context.push(SettingsRoutes.legal(doc))),
                  ),
                ListTile(
                  leading: const SettingsIcon(Icons.library_books_outlined),
                  title: const Text(LegalStrings.thirdPartyLicenses),
                  subtitle: const Text(LegalStrings.thirdPartyLicensesBody),
                  trailing: const SettingsChevron(),
                  onTap: () => showThirdPartyLicenses(
                    context,
                    version: packageInfo.value?.version,
                  ),
                ),
              ],
            ),
            SettingsGroup(
              title: LegalStrings.contactHeader,
              children: [
                ListTile(
                  leading: const SettingsIcon(Icons.mail_outline),
                  title: const Text(LegalStrings.contact),
                  subtitle: const Text(LegalStrings.contactBody),
                  trailing: mailto == null
                      ? null
                      : const SettingsChevron(icon: Icons.open_in_new),
                  onTap: mailto == null
                      ? null
                      : () => unawaited(openSettingsLink(context, ref, mailto)),
                ),
                ListTile(
                  leading: const SettingsIcon(Icons.forum_outlined),
                  title: const Text(SettingsStrings.feedback),
                  subtitle: const Text(SettingsStrings.feedbackSubtitle),
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
                    LegalInfo.copyrightNotice,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    CommonStrings.riotDisclaimer,
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

/// App icon, "VanHub" wordmark, tagline, version pill and a short intro.
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
            label: CommonStrings.appName,
            excludeSemantics: true,
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(text: SettingsStrings.logoPrefix),
                  TextSpan(
                    text: SettingsStrings.logoSuffix,
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
            CommonStrings.tagline,
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
                      ? SettingsStrings.version(value.version)
                      : '${SettingsStrings.version(value.version)} · '
                            '${SettingsStrings.buildNumber(value.buildNumber)}',
                  textAlign: TextAlign.center,
                  style: versionStyle,
                ),
                AsyncError() => Text(
                  SettingsStrings.version(CommonStrings.dash),
                  style: versionStyle,
                ),
                _ => const Skeleton(width: 120, height: 12),
              },
            ),
          ),
          const SizedBox(height: 16),
          Text(
            LegalStrings.aboutIntro,
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
