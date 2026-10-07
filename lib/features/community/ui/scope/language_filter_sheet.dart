import 'package:valvn/core/l10n/labels/community_labels.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/sub_page.dart';
import '../../data/community_models.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Opens the multi-language filter of the international scope; resolves to
/// the chosen codes (empty = every language) or `null` when dismissed.
Future<Set<String>?> showLanguageFilterSheet(
  BuildContext context, {
  required Set<String> initial,
}) => showValSheet<Set<String>>(
  context,
  title: context.l10n.communityLanguageFilter,
  scrollable: true,
  initialSize: 0.8,
  builder: (_, controller) =>
      LanguageFilterSheet(initial: initial, controller: controller),
);

/// The VALORANT languages by native name, with checkboxes.
class LanguageFilterSheet extends StatefulWidget {
  const LanguageFilterSheet({
    super.key,
    required this.initial,
    this.controller,
  });

  final Set<String> initial;

  /// Scroll controller of the draggable sheet.
  final ScrollController? controller;

  @override
  State<LanguageFilterSheet> createState() => _LanguageFilterSheetState();
}

class _LanguageFilterSheetState extends State<LanguageFilterSheet> {
  late final Set<String> _selected = {...widget.initial};

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            context.l10n.communityLanguageFilterHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            controller: widget.controller,
            children: [
              for (final code in kLfgLanguages)
                CheckboxListTile(
                  key: ValueKey('filter-lang-$code'),
                  value: _selected.contains(code),
                  title: Text(context.l10n.communityLanguageName(code)),
                  onChanged: (v) => setState(() {
                    if (v ?? false) {
                      _selected.add(code);
                    } else {
                      _selected.remove(code);
                    }
                  }),
                ),
            ],
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => setState(_selected.clear),
                    child: Text(context.l10n.communityClearFilter),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop({..._selected}),
                    child: Text(context.l10n.communityApply),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
