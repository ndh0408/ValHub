import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/skeleton.dart';
import '../legal/legal_documents.dart';
import '../legal/legal_strings.dart';
import '../providers/settings_providers.dart';
import '../settings_routes.dart';
import '../settings_strings.dart';
import 'widgets/legal_widgets.dart';
import 'widgets/settings_widgets.dart';

/// S72 "Giới thiệu & pháp lý" hub: app identity (icon, name, version,
/// tagline), short intro, key features, every legal document, data-source
/// credits, third-party licences and contact. Route `/settings/about`.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  static const _features = <(IconData, String, String)>[
    (
      Icons.storefront_outlined,
      LegalStrings.featureStore,
      LegalStrings.featureStoreBody,
    ),
    (
      Icons.favorite_border,
      LegalStrings.featureWishlist,
      LegalStrings.featureWishlistBody,
    ),
    (
      Icons.military_tech_outlined,
      LegalStrings.featureProfile,
      LegalStrings.featureProfileBody,
    ),
    (
      Icons.inventory_2_outlined,
      LegalStrings.featureCollection,
      LegalStrings.featureCollectionBody,
    ),
    (
      Icons.groups_outlined,
      LegalStrings.featureSocial,
      LegalStrings.featureSocialBody,
    ),
  ];

  static IconData _iconOf(LegalDocument doc) => switch (doc.id) {
    'terms' => Icons.gavel_outlined,
    'privacy' => Icons.privacy_tip_outlined,
    'community' => Icons.diversity_3_outlined,
    'license' => Icons.verified_user_outlined,
    _ => Icons.policy_outlined,
  };

  Future<void> _open(BuildContext context, WidgetRef ref, Uri uri) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final ok = await ref.read(externalUrlOpenerProvider)(uri);
    if (!ok) {
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(SettingsStrings.linkOpenFailed)),
        );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final packageInfo = ref.watch(packageInfoProvider);
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final mailto = LegalInfo.contactMailto;
    return Scaffold(
      appBar: AppBar(title: const Text(SettingsStrings.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          _Identity(packageInfo: packageInfo),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Text(
              LegalStrings.aboutIntro,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: muted,
                height: 1.55,
              ),
            ),
          ),
          SettingsGroup(
            title: LegalStrings.featuresHeader,
            children: [
              for (final (icon, title, body) in _features)
                ListTile(
                  leading: SettingsIcon(icon, color: ValColors.red),
                  title: Text(title),
                  subtitle: Text(body),
                ),
            ],
          ),
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
            ],
          ),
          SettingsGroup(
            title: LegalStrings.creditsHeader,
            children: [
              ListTile(
                leading: const SettingsIcon(Icons.data_object_outlined),
                title: const Text(SettingsStrings.aboutCreditContent),
                subtitle: const Text(SettingsStrings.aboutCreditContentBody),
                trailing: const SettingsChevron(icon: Icons.open_in_new),
                onTap: () =>
                    unawaited(_open(context, ref, SettingsLinks.valorantApi)),
              ),
              const ListTile(
                leading: SettingsIcon(Icons.videogame_asset_outlined),
                title: Text(SettingsStrings.aboutCreditRiot),
                subtitle: Text(SettingsStrings.aboutCreditRiotBody),
              ),
              ListTile(
                leading: const SettingsIcon(Icons.menu_book_outlined),
                title: const Text(SettingsStrings.aboutCreditDocs),
                subtitle: const Text(SettingsStrings.aboutCreditDocsBody),
                trailing: const SettingsChevron(icon: Icons.open_in_new),
                onTap: () =>
                    unawaited(_open(context, ref, SettingsLinks.apiDocs)),
              ),
              ListTile(
                leading: const SettingsIcon(Icons.description_outlined),
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
            title: LegalStrings.supportHeader,
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
                    : () => unawaited(_open(context, ref, mailto)),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  LegalInfo.copyrightNotice,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: muted,
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
    );
  }
}

/// Icon tile, name, tagline and "Phiên bản 1.2.3 · Bản dựng 42".
class _Identity extends StatelessWidget {
  const _Identity({required this.packageInfo});

  final AsyncValue<PackageInfo> packageInfo;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final versionStyle = theme.textTheme.labelMedium?.copyWith(color: muted);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [ValColors.red, Color(0xFFBD3944)],
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(
                  color: ValColors.red.withValues(alpha: 0.35),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Text(
              SettingsStrings.logoSuffix,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Semantics(
            header: true,
            child: Text(
              CommonStrings.appName,
              style: theme.textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            CommonStrings.tagline,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(color: muted),
          ),
          const SizedBox(height: 10),
          DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(ValRadius.pill),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
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
        ],
      ),
    );
  }
}
