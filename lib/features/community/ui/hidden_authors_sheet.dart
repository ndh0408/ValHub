import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account_providers.dart';
import '../../settings/ui/widgets/settings_widgets.dart';
import '../community_strings.dart';
import '../providers/hidden_authors.dart';

class SettingsHiddenAuthorsSection extends ConsumerWidget {
  const SettingsHiddenAuthorsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final account = ref.watch(activeAccountProvider);
    if (account == null) return const SizedBox.shrink();
    return SettingsGroup(
      title: CommunityStrings.hiddenAuthors,
      children: [
        ListTile(
          leading: const SettingsIcon(Icons.visibility_off_outlined),
          title: const Text(CommunityStrings.hiddenAuthors),
          subtitle: const Text(CommunityStrings.hiddenAuthorsHint),
          onTap: () => unawaited(
            showModalBottomSheet<void>(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => HiddenAuthorsSheet(puuid: account.puuid),
            ),
          ),
        ),
      ],
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
              CommunityStrings.hiddenAuthors,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(CommunityStrings.hiddenAuthorsHint),
          ),
          Expanded(
            child: rows.isEmpty
                ? const Center(child: Text(CommunityStrings.hiddenAuthorsEmpty))
                : ListView.builder(
                    itemCount: rows.length,
                    itemBuilder: (context, i) {
                      final author = rows[i];
                      return ListTile(
                        title: Text(author.name),
                        subtitle: Text(
                          author.rule == AuthorVisibilityRule.blocked
                              ? CommunityStrings.blockAuthor
                              : CommunityStrings.muteAuthor,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.undo),
                          tooltip: CommunityStrings.unhideAuthor,
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
