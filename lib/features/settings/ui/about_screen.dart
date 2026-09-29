import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/skeleton.dart';
import '../providers/settings_providers.dart';
import '../settings_strings.dart';
import 'widgets/settings_widgets.dart';

/// S72 "Giới thiệu & pháp lý": version, credits (valorant-api.com, Riot,
/// community API docs), legal notice. Route `/settings/about`.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

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
    return Scaffold(
      appBar: AppBar(title: const Text(SettingsStrings.aboutTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          const SizedBox(height: 24),
          Column(
            children: [
              Container(
                width: 72,
                height: 72,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: ValColors.red,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  SettingsStrings.logoSuffix,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                CommonStrings.appName.toUpperCase(),
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 4),
              Text(
                CommonStrings.tagline,
                style: theme.textTheme.bodyMedium?.copyWith(color: muted),
              ),
              const SizedBox(height: 8),
              switch (packageInfo) {
                AsyncData(:final value) => Text(
                  value.buildNumber.isEmpty
                      ? SettingsStrings.version(value.version)
                      : '${SettingsStrings.version(value.version)} · '
                            '${SettingsStrings.buildNumber(value.buildNumber)}',
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                AsyncError() => Text(
                  SettingsStrings.version(CommonStrings.dash),
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
                _ => const Skeleton(width: 120, height: 12),
              },
            ],
          ),
          const SizedBox(height: 8),
          SettingsGroup(
            title: SettingsStrings.aboutCreditsHeader,
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
            ],
          ),
          SettingsGroup(
            title: SettingsStrings.aboutLegalHeader,
            footer: Text(
              CommonStrings.riotDisclaimer,
              style: theme.textTheme.bodySmall?.copyWith(
                color: muted,
                height: 1.45,
              ),
            ),
            children: [
              ListTile(
                leading: const SettingsIcon(Icons.privacy_tip_outlined),
                title: const Text(SettingsStrings.privacyPolicy),
                trailing: const SettingsChevron(),
                onTap: () => unawaited(
                  showSettingsTextSheet(
                    context,
                    title: SettingsStrings.privacyPolicy,
                    body: SettingsStrings.privacyPolicyBody,
                  ),
                ),
              ),
              ListTile(
                leading: const SettingsIcon(Icons.gavel_outlined),
                title: const Text(SettingsStrings.terms),
                trailing: const SettingsChevron(),
                onTap: () => unawaited(
                  showSettingsTextSheet(
                    context,
                    title: SettingsStrings.terms,
                    body: SettingsStrings.termsBody,
                  ),
                ),
              ),
              ListTile(
                leading: const SettingsIcon(Icons.description_outlined),
                title: const Text(SettingsStrings.licenses),
                trailing: const SettingsChevron(),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: CommonStrings.appName,
                  applicationVersion: packageInfo.value?.version,
                  applicationLegalese: CommonStrings.riotDisclaimer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
