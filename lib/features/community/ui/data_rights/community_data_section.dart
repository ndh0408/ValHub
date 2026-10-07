import 'package:valvn/core/l10n/account_labels.dart';
import 'package:valvn/features/community/ui/community_error.dart';

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/accounts/account_providers.dart';
import '../../../../core/ui/adaptive.dart';
import '../../../../core/ui/error_view.dart';
import '../../../settings/ui/widgets/settings_widgets.dart';
import '../../data/community_exception.dart';
import '../../providers/community_providers.dart';
import '../../providers/consent_providers.dart';
import '../../providers/data_rights_providers.dart';

import 'package:valvn/core/l10n/l10n.dart';

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
    showAppSnackBar(
      context,
      describeCommunityError(context.l10n, error).message,
    );
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
    final l10nBeforeAwait = context.l10n;

    final l10n = context.l10n;
    final ok = await confirmSettingsAction(
      context,
      title: l10nBeforeAwait.communityDeleteDataConfirmTitle,
      message: l10nBeforeAwait.communityDeleteDataConfirmBody(
        account.displayRiotId(l10nBeforeAwait),
      ),
      confirmLabel: l10nBeforeAwait.communityDeleteDataConfirm,
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
          ..showSnackBar(SnackBar(content: Text(l10n.communityDataDeleted)));
      } on Object catch (e) {
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(describeCommunityError(l10n, e).message)),
          );
      }
    });
  }

  Future<void> _withdraw(BuildContext context, Account account) async {
    final l10nBeforeAwait2 = context.l10n;

    final ok = await confirmSettingsAction(
      context,
      title: l10nBeforeAwait2.communityWithdrawConfirmTitle,
      message: l10nBeforeAwait2.communityWithdrawConfirmBody(
        account.displayRiotId(l10nBeforeAwait2),
      ),
      confirmLabel: l10nBeforeAwait2.communityWithdrawConfirm,
      icon: Icons.logout_rounded,
    );
    if (!ok || !context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    await _run(_DataAction.withdraw, () async {
      try {
        await ref
            .read(communityDataRightsProvider)
            .withdrawConsent(account.puuid);
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(l10nBeforeAwait2.communityConsentWithdrawn)),
          );
      } on Object catch (e) {
        // A failure used to vanish silently: say why, like export / delete.
        messenger
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                describeCommunityError(l10nBeforeAwait2, e).message,
              ),
            ),
          );
      }
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
      title: context.l10n.communityDataTitle,
      footer: Text(
        context.l10n.communityDataFooter(account.displayRiotId(context.l10n)),
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
            title: Text(rowContext.l10n.communityExportTitle),
            subtitle: Text(
              busy == _DataAction.export
                  ? rowContext.l10n.communityExportPreparing
                  : rowContext.l10n.communityExportSubtitle,
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
            context.l10n.communityDeleteDataTitle,
            style: TextStyle(color: scheme.error),
          ),
          subtitle: Text(context.l10n.communityDeleteDataSubtitle),
          trailing: busy == _DataAction.delete ? spinner() : null,
          onTap: () => unawaited(_delete(context, account)),
        ),
        ListTile(
          key: const ValueKey('community-data-withdraw'),
          enabled: busy == null,
          leading: const SettingsIcon(Icons.logout_rounded),
          title: Text(context.l10n.communityWithdrawTitle),
          subtitle: Text(context.l10n.communityWithdrawSubtitle),
          trailing: busy == _DataAction.withdraw ? spinner() : null,
          onTap: () => unawaited(_withdraw(context, account)),
        ),
      ],
    );
  }
}

enum _DataAction { export, delete, withdraw }
