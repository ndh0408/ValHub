import 'package:material_ui/material_ui.dart';

import '../l10n/account_strings.dart';
import '../l10n/common_strings.dart';

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
              title: const Text(AccountStrings.keepLocalData),
              subtitle: const Text(AccountStrings.keepLocalDataHint),
              value: keep,
              onChanged: (v) => setState(() => keep = v ?? false),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(CommonStrings.cancel),
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
