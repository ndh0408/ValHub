import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/l10n/common_strings.dart';
import '../../../../core/ui/skeleton.dart';
import '../../data/cache_stats.dart';
import '../../legal/legal_documents.dart';
import '../../providers/settings_providers.dart';
import '../../settings_routes.dart';
import '../../settings_strings.dart';
import '../widgets/legal_widgets.dart';
import '../widgets/settings_widgets.dart';

/// "ỨNG DỤNG" (S70, X2): version, clear cache (with its size), session log.
class SettingsAppSection extends ConsumerStatefulWidget {
  const SettingsAppSection({super.key});

  @override
  ConsumerState<SettingsAppSection> createState() => _SettingsAppSectionState();
}

class _SettingsAppSectionState extends ConsumerState<SettingsAppSection> {
  bool _clearing = false;

  Future<void> _clearCache() async {
    setState(() => _clearing = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    String message;
    try {
      final freed = await ref.read(cacheServiceProvider).clear();
      message = SettingsStrings.cacheCleared(formatBytes(freed));
    } on Object {
      message = SettingsStrings.clearCacheFailed;
    }
    if (!mounted) return;
    ref.invalidate(cacheSizeBytesProvider);
    setState(() => _clearing = false);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final packageInfo = ref.watch(packageInfoProvider);
    final cacheSize = ref.watch(cacheSizeBytesProvider);
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    return SettingsGroup(
      title: SettingsStrings.appHeader,
      children: [
        ListTile(
          leading: const SettingsIcon(Icons.info_outline),
          title: switch (packageInfo) {
            AsyncData(:final value) => Text(
              SettingsStrings.version(value.version),
            ),
            AsyncError() => Text(SettingsStrings.version(CommonStrings.dash)),
            _ => const Align(
              alignment: AlignmentDirectional.centerStart,
              child: Skeleton(width: 120, height: 14),
            ),
          },
          subtitle: switch (packageInfo) {
            AsyncData(:final value) when value.buildNumber.isNotEmpty => Text(
              SettingsStrings.buildNumber(value.buildNumber),
            ),
            _ => null,
          },
        ),
        ListTile(
          leading: const SettingsIcon(Icons.cleaning_services_outlined),
          title: const Text(SettingsStrings.clearCache),
          subtitle: const Text(SettingsStrings.clearCacheSubtitle),
          enabled: !_clearing,
          trailing: _clearing
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : switch (cacheSize) {
                  AsyncData(:final value) => Text(
                    formatBytes(value),
                    style: TextStyle(color: muted),
                  ),
                  AsyncError() => Text(
                    CommonStrings.dash,
                    style: TextStyle(color: muted),
                  ),
                  _ => const Skeleton(width: 48, height: 14),
                },
          onTap: _clearing ? null : () => unawaited(_clearCache()),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.receipt_long_outlined),
          title: const Text(SettingsStrings.exportLog),
          subtitle: const Text(SettingsStrings.exportLogNote),
          trailing: const SettingsChevron(),
          onTap: () => unawaited(context.push(SettingsRoutes.log)),
        ),
      ],
    );
  }
}

/// "THÔNG TIN" (S70): privacy, terms, feedback, licenses, About (S72) and
/// the Riot legal disclaimer.
class SettingsAboutSection extends ConsumerWidget {
  const SettingsAboutSection({super.key});

  Future<void> _openFeedback(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final ok = await ref.read(externalUrlOpenerProvider)(
      SettingsLinks.feedback,
    );
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
    final version = ref.watch(packageInfoProvider).value?.version;
    final theme = Theme.of(context);
    return SettingsGroup(
      title: SettingsStrings.aboutHeader,
      footer: Text(
        CommonStrings.riotDisclaimer,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
      children: [
        ListTile(
          leading: const SettingsIcon(Icons.privacy_tip_outlined),
          title: const Text(SettingsStrings.privacyPolicy),
          trailing: const SettingsChevron(),
          onTap: () => unawaited(
            context.push(SettingsRoutes.legal(LegalDocuments.privacy)),
          ),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.gavel_outlined),
          title: const Text(SettingsStrings.terms),
          trailing: const SettingsChevron(),
          onTap: () => unawaited(
            context.push(SettingsRoutes.legal(LegalDocuments.terms)),
          ),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.forum_outlined),
          title: const Text(SettingsStrings.feedback),
          subtitle: const Text(SettingsStrings.feedbackSubtitle),
          trailing: const SettingsChevron(icon: Icons.open_in_new),
          onTap: () => unawaited(_openFeedback(context, ref)),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.description_outlined),
          title: const Text(SettingsStrings.licenses),
          trailing: const SettingsChevron(),
          onTap: () => showThirdPartyLicenses(context, version: version),
        ),
        ListTile(
          leading: const SettingsIcon(Icons.info_outline),
          title: const Text(SettingsStrings.aboutTitle),
          trailing: const SettingsChevron(),
          onTap: () => unawaited(context.push(SettingsRoutes.about)),
        ),
      ],
    );
  }
}
