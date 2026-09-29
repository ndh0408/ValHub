import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/error_view.dart';
import '../../../settings/ui/widgets/settings_widgets.dart';
import '../../community_strings.dart';
import '../../data/community_exception.dart';
import '../../providers/community_providers.dart';
import '../../providers/consent_providers.dart';
import '../../providers/data_rights_providers.dart';

/// Settings group "DỮ LIỆU CỘNG ĐỒNG CỦA BẠN": download, delete or stop
/// sharing what the account has on the Community server. Only shown for the
/// active account when it agreed to join (an account that never joined has
/// nothing there), and never while the Community is switched off.
class CommunityDataSection extends ConsumerStatefulWidget {
  const CommunityDataSection({super.key});

  @override
  ConsumerState<CommunityDataSection> createState() =>
      _CommunityDataSectionState();
}

class _CommunityDataSectionState extends ConsumerState<CommunityDataSection> {
  /// The action in progress (its row shows a spinner, all rows are locked).
  _DataAction? _busy;

  Future<void> _run(_DataAction action, Future<void> Function() body) async {
    if (_busy != null) return;
    setState(() => _busy = action);
    try {
      await body();
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  void _fail(BuildContext context, Object error) {
    // A missing consent is not a failure to explain here: the group is gone
    // (or is about to be) and the Community tab asks again when needed.
    if (error is CommunityException &&
        error.code == CommunityException.consentRequired) {
      return;
    }
    showAppSnackBar(context, describeCommunityError(error).message);
  }

  Future<void> _export(BuildContext context, Account account) async {
    final box = context.findRenderObject();
    final origin = box is RenderBox && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;
    await _run(_DataAction.export, () async {
      try {
        await ref
            .read(communityDataRightsProvider)
            .exportAndShare(account.puuid, origin: origin);
      } on Object catch (e) {
        if (context.mounted) _fail(context, e);
      }
    });
  }

  Future<void> _delete(BuildContext context, Account account) async {
    final ok = await confirmSettingsAction(
      context,
      title: CommunityStrings.deleteDataConfirmTitle,
      message: CommunityStrings.deleteDataConfirmBody(account.riotId),
      confirmLabel: CommunityStrings.deleteDataConfirm,
      destructive: true,
      icon: Icons.delete_forever_outlined,
    );
    if (!ok || !context.mounted) return;
    // The group disappears once consent is gone: keep what the snackbar needs.
    final messenger = ScaffoldMessenger.maybeOf(context);
    await _run(_DataAction.delete, () async {
      try {
        await ref.read(communityDataRightsProvider).deleteAll(account.puuid);
        Haptics.heavy();
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text(CommunityStrings.dataDeleted)),
          );
      } on Object catch (e) {
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(describeCommunityError(e).message)),
          );
      }
    });
  }

  Future<void> _withdraw(BuildContext context, Account account) async {
    final ok = await confirmSettingsAction(
      context,
      title: CommunityStrings.withdrawConfirmTitle,
      message: CommunityStrings.withdrawConfirmBody(account.riotId),
      confirmLabel: CommunityStrings.withdrawConfirm,
      icon: Icons.logout_rounded,
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    await _run(_DataAction.withdraw, () async {
      await ref
          .read(communityDataRightsProvider)
          .withdrawConsent(account.puuid);
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(CommunityStrings.consentWithdrawn)),
        );
    });
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    if (account == null || !ref.watch(communityEnabledProvider)) {
      return const SizedBox.shrink();
    }
    final joined =
        ref.watch(communityConsentProvider(account.puuid)) ==
        CommunityConsent.granted;
    if (!joined) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final busy = _busy;

    Widget spinner() => const SizedBox.square(
      dimension: 20,
      child: CircularProgressIndicator(strokeWidth: 2.5),
    );

    return SettingsGroup(
      title: CommunityStrings.dataTitle,
      footer: Text(
        CommunityStrings.dataFooter(account.riotId),
        style: theme.textTheme.bodySmall?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),
      children: [
        Builder(
          builder: (rowContext) => ListTile(
            key: const ValueKey('community-data-export'),
            enabled: busy == null,
            leading: const SettingsIcon(Icons.download_outlined),
            title: const Text(CommunityStrings.exportTitle),
            subtitle: Text(
              busy == _DataAction.export
                  ? CommunityStrings.exportPreparing
                  : CommunityStrings.exportSubtitle,
            ),
            trailing: busy == _DataAction.export
                ? spinner()
                : const SettingsChevron(icon: Icons.ios_share_outlined),
            onTap: () => unawaited(_export(rowContext, account)),
          ),
        ),
        ListTile(
          key: const ValueKey('community-data-delete'),
          enabled: busy == null,
          leading: SettingsIcon(
            Icons.delete_forever_outlined,
            color: scheme.error,
          ),
          title: Text(
            CommunityStrings.deleteDataTitle,
            style: TextStyle(color: scheme.error),
          ),
          subtitle: const Text(CommunityStrings.deleteDataSubtitle),
          trailing: busy == _DataAction.delete ? spinner() : null,
          onTap: () => unawaited(_delete(context, account)),
        ),
        ListTile(
          key: const ValueKey('community-data-withdraw'),
          enabled: busy == null,
          leading: const SettingsIcon(Icons.logout_rounded),
          title: const Text(CommunityStrings.withdrawTitle),
          subtitle: const Text(CommunityStrings.withdrawSubtitle),
          trailing: busy == _DataAction.withdraw ? spinner() : null,
          onTap: () => unawaited(_withdraw(context, account)),
        ),
      ],
    );
  }
}

enum _DataAction { export, delete, withdraw }
