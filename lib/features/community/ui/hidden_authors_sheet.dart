import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/ui/sub_page.dart';
import '../../settings/ui/widgets/settings_widgets.dart';
import '../providers/hidden_authors.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Settings row "Người đã ẩn và chặn" (in the CỘNG ĐỒNG group) opening
/// [HiddenAuthorsSheet] for [puuid].
class HiddenAuthorsRow extends ConsumerWidget {
  const HiddenAuthorsRow({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // How many, not the rules: the sheet explains what hiding does.
    final count = ref.watch(hiddenAuthorsProvider(puuid)).length;
    return ListTile(
      leading: const SettingsIcon(Icons.visibility_off_outlined),
      title: Text(context.l10n.communityHiddenAuthors),
      subtitle: Text(
        count == 0
            ? context.l10n.communityHiddenAuthorsEmpty
            : context.l10n.communityHiddenAuthorsCount(count),
      ),
      trailing: const SettingsChevron(),
      onTap: () => unawaited(
        showValSheet<void>(
          context,
          title: context.l10n.communityHiddenAuthors,
          scrollable: true,
          initialSize: 0.8,
          builder: (_, controller) =>
              HiddenAuthorsSheet(puuid: puuid, controller: controller),
        ),
      ),
    );
  }
}

class HiddenAuthorsSheet extends ConsumerWidget {
  const HiddenAuthorsSheet({super.key, required this.puuid, this.controller});
  final String puuid;

  /// Scroll controller of the draggable sheet.
  final ScrollController? controller;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(hiddenAuthorsProvider(puuid)).values.toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(context.l10n.communityHiddenAuthorsHint),
        ),
        Expanded(
          child: rows.isEmpty
              ? ListView(
                  controller: controller,
                  padding: const EdgeInsets.all(32),
                  children: [
                    Center(
                      child: Text(context.l10n.communityHiddenAuthorsEmpty),
                    ),
                  ],
                )
              : ListView.builder(
                  controller: controller,
                  itemCount: rows.length,
                  itemBuilder: (context, i) {
                    final author = rows[i];
                    return ListTile(
                      title: Text(author.name),
                      subtitle: Text(
                        author.rule == AuthorVisibilityRule.blocked
                            ? context.l10n.communityBlockAuthor
                            : context.l10n.communityMuteAuthor,
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.undo),
                        tooltip: context.l10n.communityUnhideAuthor,
                        onPressed: () => unawaited(
                          ref
                              .read(hiddenAuthorsProvider(puuid).notifier)
                              .unhide(author.id),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
