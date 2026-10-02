import 'package:material_ui/material_ui.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// null = dismissed, false = erase, true = explicitly keep local data.
Future<bool?> chooseSignOutRetention(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
}) => showDialog<bool>(
  context: context,
  builder: (context) {
    var keep = false;
    return StatefulBuilder(
      builder: (context, setState) => AlertDialog(
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
            onPressed: () => Navigator.of(context).pop(keep),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  },
);
