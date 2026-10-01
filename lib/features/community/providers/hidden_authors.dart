import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/accounts/account_providers.dart';
import '../../../core/storage/prefs.dart';
import '../../../core/util/json.dart';

enum AuthorVisibilityRule { muted, blocked }

class HiddenAuthor {
  const HiddenAuthor(this.id, this.name, this.rule);
  final String id;
  final String name;
  final AuthorVisibilityRule rule;
  JsonMap toJson() => {'id': id, 'name': name, 'rule': rule.name};
}

/// Device-only Community controls, isolated per Riot account. They hide
/// content locally; they do not claim to restrict another user's server access.
final hiddenAuthorsProvider =
    NotifierProvider.family<HiddenAuthors, Map<String, HiddenAuthor>, String>(
      HiddenAuthors.new,
    );

class HiddenAuthors extends Notifier<Map<String, HiddenAuthor>> {
  HiddenAuthors(this.puuid);
  final String puuid;
  String get key => PrefKeys.account(puuid, 'community.hiddenAuthors');
  @override
  Map<String, HiddenAuthor> build() {
    if (ref.watch(accountProvider(puuid)) == null) return const {};
    final rows = asList(ref.watch(prefsProvider).getJson(key));
    return Map.unmodifiable({
      for (final raw in rows)
        if (asMap(raw) case final JsonMap row)
          if (asNonEmptyString(row['id']) case final String id)
            id: HiddenAuthor(
              id,
              asString(row['name']) ?? id,
              row['rule'] == 'blocked'
                  ? AuthorVisibilityRule.blocked
                  : AuthorVisibilityRule.muted,
            ),
    });
  }

  Future<void> hide(String id, String name, AuthorVisibilityRule rule) async {
    if (ref.read(accountProvider(puuid)) == null ||
        id.isEmpty ||
        id.length > 128) {
      return;
    }
    if (state.length >= 500 && !state.containsKey(id)) return;
    final next = {...state, id: HiddenAuthor(id, name, rule)};
    await ref
        .read(prefsProvider)
        .setJson(key, next.values.map((v) => v.toJson()).toList());
    if (ref.mounted && ref.read(accountProvider(puuid)) != null) {
      state = Map.unmodifiable(next);
    }
  }

  Future<void> unhide(String id) async {
    if (ref.read(accountProvider(puuid)) == null) return;
    final next = {...state}..remove(id);
    await ref
        .read(prefsProvider)
        .setJson(key, next.values.map((v) => v.toJson()).toList());
    if (ref.mounted && ref.read(accountProvider(puuid)) != null) {
      state = Map.unmodifiable(next);
    }
  }
}
