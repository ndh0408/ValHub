import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/features/community/providers/hidden_authors.dart';

import '../../../helpers/test_prefs.dart';

void main() {
  test(
    'visibility choices survive reload, stay per account and can be undone',
    () async {
      final prefs = await createTestPrefs();
      const a = Account(
        puuid: 'a',
        gameName: '',
        tagLine: '',
        region: 'ap',
        shard: 'ap',
      );
      const b = Account(
        puuid: 'b',
        gameName: '',
        tagLine: '',
        region: 'ap',
        shard: 'ap',
      );
      ProviderContainer container() => ProviderContainer.test(
        overrides: [
          prefsProvider.overrideWithValue(prefs),
          accountProvider('a').overrideWithValue(a),
          accountProvider('b').overrideWithValue(b),
        ],
      );
      final first = container();
      await first
          .read(hiddenAuthorsProvider('a').notifier)
          .hide('author', 'Name#TAG', AuthorVisibilityRule.blocked);
      expect(first.read(hiddenAuthorsProvider('b')), isEmpty);
      first.dispose();
      final next = container();
      expect(
        next.read(hiddenAuthorsProvider('a'))['author']!.rule,
        AuthorVisibilityRule.blocked,
      );
      await next.read(hiddenAuthorsProvider('a').notifier).unhide('author');
      expect(next.read(hiddenAuthorsProvider('a')), isEmpty);
      next.dispose();
    },
  );
  test('removed accounts cannot create a visibility preference', () async {
    final prefs = await createTestPrefs();
    final c = ProviderContainer.test(
      overrides: [
        prefsProvider.overrideWithValue(prefs),
        accountProvider('gone').overrideWithValue(null),
      ],
    );
    await c
        .read(hiddenAuthorsProvider('gone').notifier)
        .hide('author', 'Name', AuthorVisibilityRule.muted);
    expect(
      prefs.containsKey(PrefKeys.account('gone', 'community.hiddenAuthors')),
      false,
    );
    c.dispose();
  });
}
