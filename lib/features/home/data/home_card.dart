/// The eight cards of the Home dashboard (docs/design/HOME.md §3.2).
library;

/// One Home card. The order of [values] is the IA order ("Trang chủ" 1…8).
enum HomeCardId {
  live('live'),
  store('store'),
  rank('rank'),
  battlePass('battlepass'),
  friends('friends'),
  community('community'),
  otherAccounts('accounts'),
  serverStatus('status');

  const HomeCardId(this.storageId);

  /// Persisted in Prefs and used in `?focus=`. Never rename.
  final String storageId;

  static HomeCardId? tryParse(String? value) {
    final v = value?.trim();
    if (v == null || v.isEmpty) return null;
    for (final c in values) {
      if (c.storageId == v) return c;
    }
    return null;
  }

  /// Nearly always has data: shows a skeleton while loading.
  bool get isCore => this == store || this == rank || this == battlePass;

  /// Needs the active account's Riot session (hidden while it needs login).
  bool get needsRiotSession => switch (this) {
    live || store || rank || battlePass || friends => true,
    _ => false,
  };

  /// Its data is not watched before `homeStartupGateProvider` opens.
  bool get isDeferred =>
      this == friends || this == community || this == otherAccounts;
}

/// IA "Trang chủ" order 1…8.
const kDefaultHomeOrder = HomeCardId.values;

/// Whether a card shows something right now.
enum HomeCardPresence { hidden, loading, visible }

/// Family key of the per-card presence provider.
typedef HomeCardKey = ({String puuid, HomeCardId card});
