import 'package:cupertino_ui/cupertino_ui.dart'
    show CupertinoAlertDialog, CupertinoDialogAction, CupertinoSwitch;
import 'package:material_ui/material_ui.dart';

import '../ui/adaptive.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// null = dismissed, false = erase, true = explicitly keep local data.
///
/// A native alert on iOS (switch for "keep the data", red action) and a
/// Material one elsewhere (checkbox, red action): it removes an account.
Future<bool?> chooseSignOutRetention(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) => showAdaptiveDialog<bool>(
  context: context,
  barrierDismissible: true,
  builder: (context) {
    var keep = false;
    final cupertino = isCupertino(context);
    return StatefulBuilder(
      builder: (context, setState) {
        if (cupertino) {
          final theme = Theme.of(context);
          return CupertinoAlertDialog(
            title: Text(title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(message),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.accountKeepLocalData,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            context.l10n.accountKeepLocalDataHint,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                    CupertinoSwitch(
                      value: keep,
                      onChanged: (v) => setState(() => keep = v),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(),
                child: Text(context.l10n.commonCancel),
              ),
              CupertinoDialogAction(
                isDestructiveAction: true,
                onPressed: () => Navigator.of(context).pop(keep),
                child: Text(confirmLabel),
              ),
            ],
          );
        }
        return AlertDialog(
          title: Text(title),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(context.l10n.accountKeepLocalData),
                subtitle: Text(context.l10n.accountKeepLocalDataHint),
                value: keep,
                onChanged: (v) => setState(() => keep = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.l10n.commonCancel),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => Navigator.of(context).pop(keep),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
  },
);
