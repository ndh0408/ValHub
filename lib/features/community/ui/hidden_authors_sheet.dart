import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../settings/ui/widgets/settings_widgets.dart';
import '../providers/hidden_authors.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Settings row "Người đã ẩn và chặn" (in the CỘNG ĐỒNG group) opening
/// [HiddenAuthorsSheet] for [puuid].
class HiddenAuthorsRow extends StatelessWidget {
  const HiddenAuthorsRow({super.key, required this.puuid});

  final String puuid;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const SettingsIcon(Icons.visibility_off_outlined),
      title: Text(context.l10n.communityHiddenAuthors),
      subtitle: Text(context.l10n.communityHiddenAuthorsHint),
      trailing: const SettingsChevron(),
      onTap: () => unawaited(
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => HiddenAuthorsSheet(puuid: puuid),
        ),
      ),
    );
  }
}

class HiddenAuthorsSheet extends ConsumerWidget {
  const HiddenAuthorsSheet({super.key, required this.puuid});
  final String puuid;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rows = ref.watch(hiddenAuthorsProvider(puuid)).values.toList();
    return FractionallySizedBox(
      heightFactor: 0.8,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Text(
              context.l10n.communityHiddenAuthors,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(context.l10n.communityHiddenAuthorsHint),
          ),
          Expanded(
            child: rows.isEmpty
                ? Center(child: Text(context.l10n.communityHiddenAuthorsEmpty))
                : ListView.builder(
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
      ),
    );
  }
}
