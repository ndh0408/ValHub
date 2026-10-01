import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../../../core/l10n/locale.dart';
import '../../../core/accounts/account.dart';

import '../../../core/util/json.dart';

/// Typed models of the ValVN community API (docs/community-api.md). Every
/// parser is defensive: missing / odd fields become `null`, defaults or are
/// skipped; nothing throws.

/// Regions accepted by the server (`region`).
const kCommunityRegions = ['ap', 'na', 'eu', 'kr', 'latam', 'br'];

/// Unknown regions remain unresolved; never route an unknown account to AP.
String communityRegion(String? region) {
  final r = region?.toLowerCase().trim();
  return kCommunityRegions.contains(r) ? r! : '';
}

/// Community/LFG identity follows Riot's detection, independently of a local connection override.
String communityAccountRegion(Account? account) =>
    communityRegion(account?.detectedRegion ?? account?.region);

/// ISO 3166-1 alpha-2 country code (upper case) or `null`.
String? countryCode(Object? value) {
  final s = asNonEmptyString(value)?.toUpperCase();
  return s != null && RegExp(r'^[A-Z]{2}$').hasMatch(s) ? s : null;
}

/// Flag emoji of an alpha-2 country code ("VN" → 🇻🇳), empty when unknown.
String flagEmoji(String? alpha2) {
  final c = countryCode(alpha2);
  if (c == null) return '';
  return String.fromCharCodes([
    for (final unit in c.codeUnits) 0x1F1E6 + unit - 0x41,
  ]);
}

/// Public author object (everywhere a user is shown).
@immutable
class CommunityAuthor {
  const CommunityAuthor({
    required this.id,
    this.gameName = '',
    this.tagLine = '',
    this.cardId,
    this.rankTier,
    this.region,
    this.country,
    this.language,
  });

  /// Placeholder when a body has no author.
  static const unknown = CommunityAuthor(id: '');

  static CommunityAuthor? fromJson(Object? json) {
    final m = asMap(json);
    final id = asNonEmptyString(m?['id']);
    if (m == null || id == null) return null;
    return CommunityAuthor(
      id: id,
      gameName: asNonEmptyString(m['gameName']) ?? '',
      tagLine: asNonEmptyString(m['tagLine']) ?? '',
      cardId: lowerUuid(m['cardId']),
      rankTier: asInt(m['rankTier']),
      region: asNonEmptyString(m['region'])?.toLowerCase(),
      country: countryCode(m['country']),
      language: lfgLanguageCode(m['language']),
    );
  }

  final String id;
  final String gameName;
  final String tagLine;
  final String? cardId;
  final int? rankTier;
  final String? region;

  /// ISO alpha-2 country from the Riot account (not user-editable).
  final String? country;

  /// App language of the author.
  final String? language;

  bool get isUnknown => id.isEmpty;

  /// `Name#TAG` or just the name; `null` when unknown.
  String? get riotId => gameName.isEmpty
      ? null
      : (tagLine.isEmpty ? gameName : '$gameName#$tagLine');

  JsonMap toJson() => {
    'id': id,
    'gameName': gameName,
    'tagLine': tagLine,
    'cardId': cardId,
    'rankTier': rankTier,
    'region': region,
    'country': country,
    'language': language,
  };

  @override
  bool operator ==(Object other) =>
      other is CommunityAuthor &&
      other.id == id &&
      other.gameName == gameName &&
      other.tagLine == tagLine &&
      other.cardId == cardId &&
      other.rankTier == rankTier &&
      other.region == region &&
      other.country == country &&
      other.language == language;

  @override
  int get hashCode => Object.hash(
    id,
    gameName,
    tagLine,
    cardId,
    rankTier,
    region,
    country,
    language,
  );

  @override
  String toString() => 'CommunityAuthor($id)';
}

// ----------------------------------------------------------------- scopes

/// Community scopes (v3): one country, one VALORANT shard, or everyone.
enum CommunityScope {
  country,
  region,
  global;

  static CommunityScope? tryParse(String? value) => switch (value) {
    'country' => country,
    'region' => region,
    'global' => global,
    _ => null,
  };
}

/// What a list shows: a scope plus its target. `country` / `region` `null`
/// mean "the viewer's own" (resolved before querying).
@immutable
class ScopeFilter {
  const ScopeFilter({
    required this.scope,
    this.country,
    this.region,
    this.languages = const {},
  });

  static const mineCountry = ScopeFilter(scope: CommunityScope.country);
  static const mineRegion = ScopeFilter(scope: CommunityScope.region);
  static const global = ScopeFilter(scope: CommunityScope.global);

  final CommunityScope scope;
  final String? country;
  final String? region;

  /// Language filter of the global scope (empty = all).
  final Set<String> languages;

  /// Query parameters (`scope`, `country`, `region`, `language`).
  Map<String, Object?> get query => {
    'scope': scope.name,
    if (scope == CommunityScope.country) 'country': country,
    if (scope == CommunityScope.region) 'region': region,
    if (scope == CommunityScope.global && languages.isNotEmpty)
      'language': ([...languages]..sort()).join(','),
  };

  ScopeFilter copyWith({
    CommunityScope? scope,
    String? Function()? country,
    String? Function()? region,
    Set<String>? languages,
  }) => ScopeFilter(
    scope: scope ?? this.scope,
    country: country == null ? this.country : country(),
    region: region == null ? this.region : region(),
    languages: languages ?? this.languages,
  );

  @override
  bool operator ==(Object other) =>
      other is ScopeFilter &&
      other.scope == scope &&
      other.country == country &&
      other.region == region &&
      setEquals(other.languages, languages);

  @override
  int get hashCode =>
      Object.hash(scope, country, region, Object.hashAllUnordered(languages));

  @override
  String toString() => 'ScopeFilter(${scope.name}, $country, $region)';
}

/// The scope the server really applied to a list (`appliedScope` of feed /
/// LFG / review lists and skin top / votes / summary). It can differ from
/// what was asked: a `country` scope without a known country falls back to
/// the viewer's `region`, then to `global`.
@immutable
class AppliedScope {
  const AppliedScope({required this.scope, this.country, this.region});

  static const global = AppliedScope(scope: CommunityScope.global);

  /// `null` when the body carries no (valid) `appliedScope` (older server).
  static AppliedScope? fromJson(Object? json) {
    final m = asMap(json);
    final scope = CommunityScope.tryParse(asNonEmptyString(m?['scope']));
    if (m == null || scope == null) return null;
    final country = scope == CommunityScope.country
        ? countryCode(m['country'])
        : null;
    // A country scope always names its country.
    if (scope == CommunityScope.country && country == null) return null;
    final region = asNonEmptyString(m['region'])?.toLowerCase();
    return AppliedScope(
      scope: scope,
      country: country,
      region:
          scope == CommunityScope.region && kCommunityRegions.contains(region)
          ? region
          : null,
    );
  }

  final CommunityScope scope;

  /// Set for the `country` scope.
  final String? country;

  /// Set for the `region` scope.
  final String? region;

  /// Whether the server applied what [asked] means (its country / region
  /// when it named one).
  bool matches(ScopeFilter asked) =>
      scope == asked.scope &&
      (asked.country == null || country == asked.country) &&
      (asked.region == null || region == asked.region);

  @override
  bool operator ==(Object other) =>
      other is AppliedScope &&
      other.scope == scope &&
      other.country == country &&
      other.region == region;

  @override
  int get hashCode => Object.hash(scope, country, region);

  @override
  String toString() => 'AppliedScope(${scope.name}, $country, $region)';
}

/// One active country community (`GET /v1/communities`).
@immutable
class CountryCommunity {
  const CountryCommunity({
    required this.country,
    this.posts = 0,
    this.authors = 0,
    this.lfg = 0,
  });

  static CountryCommunity? fromJson(Object? json) {
    final m = asMap(json);
    final c = countryCode(m?['country']);
    if (m == null || c == null) return null;
    return CountryCommunity(
      country: c,
      posts: _count(m['posts']),
      authors: _count(m['authors']),
      lfg: _count(m['lfg']),
    );
  }

  final String country;
  final int posts;
  final int authors;
  final int lfg;
}

/// A cursor page (`{"items": [...], "nextCursor": "…" | null}`).
@immutable
class CommunityPage<T> {
  const CommunityPage(this.items, {this.nextCursor, this.applied});

  static CommunityPage<T> fromJson<T>(
    Object? json,
    T? Function(Object? item) parse,
  ) {
    final m = asMap(json);
    final list = m == null ? asList(json) : asList(m['items']);
    return CommunityPage<T>(
      [for (final e in list) ?parse(e)],
      nextCursor: asNonEmptyString(m?['nextCursor']),
      applied: AppliedScope.fromJson(m?['appliedScope']),
    );
  }

  final List<T> items;
  final String? nextCursor;

  /// The scope the server applied (lists of the scoped endpoints).
  final AppliedScope? applied;

  bool get hasMore => nextCursor != null;
}

/// Community session returned by `POST /v1/auth/riot`.
@immutable
class CommunitySession {
  const CommunitySession({
    required this.token,
    required this.user,
    this.expiresAt,
  });

  static CommunitySession? fromJson(Object? json) {
    final m = asMap(json);
    final token = asNonEmptyString(m?['token']);
    if (m == null || token == null) return null;
    return CommunitySession(
      token: token,
      expiresAt: asDateTime(m['expiresAt']),
      user: CommunityAuthor.fromJson(m['user']) ?? CommunityAuthor.unknown,
    );
  }

  final String token;
  final DateTime? expiresAt;
  final CommunityAuthor user;

  /// Expired (or within a minute of it) at [now].
  bool isExpired(DateTime now) {
    final at = expiresAt;
    return at != null && !now.isBefore(at.subtract(const Duration(minutes: 1)));
  }

  JsonMap toJson() => {
    'token': token,
    'expiresAt': expiresAt?.toUtc().toIso8601String(),
    'user': user.toJson(),
  };

  /// Never prints the token.
  @override
  String toString() => 'CommunitySession(${user.id})';
}

// ------------------------------------------------------------------- feed

/// Feed post kinds.
enum PostKind {
  text,
  store,
  nightmarket;

  static PostKind parse(Object? value) => switch (asString(value)) {
    'store' => store,
    'nightmarket' => nightmarket,
    _ => text,
  };

  bool get hasOffers => this != text;
}

/// An uploaded image (`{"key", "url"}`).
@immutable
class PostMedia {
  const PostMedia({required this.key, required this.url});

  static PostMedia? fromJson(Object? json) {
    final m = asMap(json);
    final url = asNonEmptyString(m?['url']);
    if (m == null || url == null || !_isHttpUrl(url)) return null;
    return PostMedia(key: asNonEmptyString(m['key']) ?? url, url: url);
  }

  final String key;
  final String url;

  @override
  bool operator ==(Object other) =>
      other is PostMedia && other.key == key && other.url == url;

  @override
  int get hashCode => Object.hash(key, url);
}

bool _isHttpUrl(String url) {
  final uri = Uri.tryParse(url);
  return uri != null &&
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.isNotEmpty;
}

/// One skin of a store / Night Market post payload.
@immutable
class PayloadOffer {
  const PayloadOffer({
    required this.skinUuid,
    this.cost,
    this.baseCost,
    this.discountCost,
    this.discountPercent,
  });

  static PayloadOffer? fromJson(Object? json) {
    final m = asMap(json);
    final id = lowerUuid(m?['skinUuid']);
    if (m == null || id == null) return null;
    return PayloadOffer(
      skinUuid: id,
      cost: asNum(m['cost'])?.round(),
      baseCost: asNum(m['baseCost'])?.round(),
      discountCost: asNum(m['discountCost'])?.round(),
      discountPercent: asNum(m['discountPercent'])?.round(),
    );
  }

  /// Skin (or skin level) uuid.
  final String skinUuid;

  /// Daily-shop price (VP).
  final int? cost;

  /// Night Market prices.
  final int? baseCost;
  final int? discountCost;
  final int? discountPercent;

  /// The price actually paid.
  int? get price => discountCost ?? cost;

  JsonMap toJson(PostKind kind) => kind == PostKind.nightmarket
      ? {
          'skinUuid': skinUuid,
          'baseCost': ?baseCost,
          'discountCost': ?discountCost,
          'discountPercent': ?discountPercent,
        }
      : {'skinUuid': skinUuid, 'cost': ?cost};

  @override
  bool operator ==(Object other) =>
      other is PayloadOffer &&
      other.skinUuid == skinUuid &&
      other.cost == cost &&
      other.baseCost == baseCost &&
      other.discountCost == discountCost &&
      other.discountPercent == discountPercent;

  @override
  int get hashCode =>
      Object.hash(skinUuid, cost, baseCost, discountCost, discountPercent);
}

/// `payload` of store / Night Market posts (max 6 offers).
@immutable
class PostPayload {
  const PostPayload({this.date, this.offers = const []});

  static const maxOffers = 6;

  static PostPayload? fromJson(Object? json) {
    final m = asMap(json);
    if (m == null) return null;
    final offers = [
      for (final o in asList(m['offers'])) ?PayloadOffer.fromJson(o),
    ];
    if (offers.isEmpty) return null;
    return PostPayload(
      date: asNonEmptyString(m['date']),
      offers: offers.take(maxOffers).toList(),
    );
  }

  /// `YYYY-MM-DD`.
  final String? date;
  final List<PayloadOffer> offers;

  /// `28/09` from [date] (as given), or `null`.
  String? get dayMonth {
    final d = date;
    if (d == null) return null;
    final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(d);
    return m == null ? null : '${m.group(3)}/${m.group(2)}';
  }

  int get total => offers.fold(0, (sum, o) => sum + (o.price ?? 0));

  JsonMap toJson(PostKind kind) => {
    'date': ?date,
    'offers': [for (final o in offers.take(maxOffers)) o.toJson(kind)],
  };
}

/// A feed post.
@immutable
class CommunityPost {
  const CommunityPost({
    required this.id,
    required this.author,
    this.kind = PostKind.text,
    this.body = '',
    this.media = const [],
    this.payload,
    this.likes = 0,
    this.liked = false,
    this.comments = 0,
    this.createdAt,
    this.country,
    this.region,
    this.language,
  });

  static CommunityPost? fromJson(Object? json) {
    final m = asMap(json);
    final id = asNonEmptyString(m?['id']);
    if (m == null || id == null) return null;
    final kind = PostKind.parse(m['kind']);
    return CommunityPost(
      id: id,
      author: CommunityAuthor.fromJson(m['author']) ?? CommunityAuthor.unknown,
      kind: kind,
      body: asString(m['body'])?.trim() ?? '',
      media: [for (final e in asList(m['media'])) ?PostMedia.fromJson(e)]
          .take(4)
          .toList(),
      payload: kind.hasOffers ? PostPayload.fromJson(m['payload']) : null,
      likes: _count(m['likes']),
      liked: asBool(m['liked']) ?? false,
      comments: _count(m['comments']),
      createdAt: asDateTime(m['createdAt']),
      country: countryCode(m['country']),
      region: asNonEmptyString(m['region'])?.toLowerCase(),
      language: lfgLanguageCode(m['language']),
    );
  }

  final String id;
  final CommunityAuthor author;
  final PostKind kind;
  final String body;
  final List<PostMedia> media;
  final PostPayload? payload;
  final int likes;
  final bool liked;
  final int comments;
  final DateTime? createdAt;

  /// Author country / shard when posted, and the language of [body].
  final String? country;
  final String? region;
  final String? language;

  CommunityPost copyWith({int? likes, bool? liked, int? comments}) =>
      CommunityPost(
        id: id,
        author: author,
        kind: kind,
        body: body,
        media: media,
        payload: payload,
        likes: likes ?? this.likes,
        liked: liked ?? this.liked,
        comments: comments ?? this.comments,
        createdAt: createdAt,
        country: country,
        region: region,
        language: language,
      );

  /// The like state after tapping the heart (optimistic).
  CommunityPost toggledLike() => copyWith(
    liked: !liked,
    likes: (likes + (liked ? -1 : 1)).clamp(0, 1 << 31),
  );

  @override
  String toString() => 'CommunityPost($id)';
}

int _count(Object? v) {
  final n = asNum(v)?.round() ?? 0;
  return n < 0 ? 0 : n;
}

/// A comment on a post.
@immutable
class CommunityComment {
  const CommunityComment({
    required this.id,
    required this.postId,
    required this.author,
    this.body = '',
    this.createdAt,
    this.language,
  });

  static CommunityComment? fromJson(Object? json) {
    final m = asMap(json);
    final id = asNonEmptyString(m?['id']);
    if (m == null || id == null) return null;
    return CommunityComment(
      id: id,
      postId: asNonEmptyString(m['postId']) ?? '',
      author: CommunityAuthor.fromJson(m['author']) ?? CommunityAuthor.unknown,
      body: asString(m['body'])?.trim() ?? '',
      createdAt: asDateTime(m['createdAt']),
      language: lfgLanguageCode(m['language']),
    );
  }

  final String id;
  final String postId;
  final CommunityAuthor author;
  final String body;
  final DateTime? createdAt;

  /// Language of [body] (for on-device translation).
  final String? language;
}

/// `{"likes", "liked"}` after a like / unlike.
typedef LikeResult = ({int likes, bool liked});

// -------------------------------------------------------------------- LFG

/// LFG modes (`mode`).
const kLfgModes = [
  'competitive',
  'unrated',
  'swiftplay',
  'spikerush',
  'deathmatch',
  'teamdeathmatch',
  'premier',
  'custom',
];

/// Party codes are 6 uppercase letters / digits.
final RegExp partyCodePattern = RegExp(r'^[A-Z0-9]{6}$');

/// LFG roles (`roles`).
const kLfgRoles = ['duelist', 'initiator', 'controller', 'sentinel', 'flex'];

/// VALORANT client languages accepted by LFG (`language`); `any` = no
/// preference.
const kLfgLanguages = [
  'ar',
  'de',
  'en',
  'es',
  'fr',
  'id',
  'it',
  'ja',
  'ko',
  'pl',
  'pt',
  'ru',
  'th',
  'tr',
  'vi',
  'zh-CN',
  'zh-TW',
];

/// "Any language".
const kLfgAnyLanguage = 'any';

/// Canonical LFG language code for [value] (case-insensitive, `_` or `-`),
/// `any`, or `null` when unknown.
String? lfgLanguageCode(Object? value) {
  final s = asNonEmptyString(value)?.replaceAll('_', '-').toLowerCase();
  if (s == null) return null;
  if (s == kLfgAnyLanguage) return kLfgAnyLanguage;
  for (final code in kLfgLanguages) {
    if (code.toLowerCase() == s) return code;
  }
  return null;
}

/// The LFG language matching an app locale (`zh` → `zh-CN` / `zh-TW`),
/// else `any`.
String lfgLanguageForLocale(String languageCode, {String? scriptOrCountry}) {
  final lang = languageCode.toLowerCase();
  if (lang == 'zh') {
    final region = scriptOrCountry?.toUpperCase();
    return region == 'TW' || region == 'HK' || region == 'HANT'
        ? 'zh-TW'
        : 'zh-CN';
  }
  return lfgLanguageCode(lang) ?? kLfgAnyLanguage;
}

/// LFG post status (`status`).
enum LfgStatus {
  open,
  full,
  inGame;

  static LfgStatus parse(Object? value) => switch (asString(value)) {
    'full' => full,
    'in_game' => inGame,
    _ => open,
  };

  String get query => switch (this) {
    open => 'open',
    full => 'full',
    inGame => 'in_game',
  };
}

/// Largest competitive tier (Radiant).
const kMaxRankTier = 27;

/// A looking-for-group post (expires 30 minutes after the last heartbeat).
@immutable
class LfgPost {
  const LfgPost({
    required this.id,
    required this.author,
    required this.partyCode,
    this.region = 'ap',
    this.mode,
    this.slots = 1,
    this.rankTier,
    this.note = '',
    this.createdAt,
    this.expiresAt,
    this.rankMin,
    this.rankMax,
    this.roles = const [],
    this.mic,
    this.language = kLfgAnyLanguage,
    this.partySize,
    this.agents = const [],
    this.status = LfgStatus.open,
    this.joins = 0,
    this.updatedAt,
  });

  static LfgPost? fromJson(Object? json) {
    final m = asMap(json);
    final id = asNonEmptyString(m?['id']);
    if (m == null || id == null) return null;
    final slots = asInt(m['slots']) ?? 1;
    int? tier(Object? v) {
      final n = asInt(v);
      return n == null || n <= 0 ? null : n.clamp(0, kMaxRankTier);
    }

    var rankMin = tier(m['rankMin']);
    var rankMax = tier(m['rankMax']);
    if (rankMin != null && rankMax != null && rankMin > rankMax) {
      (rankMin, rankMax) = (rankMax, rankMin);
    }
    final partySize = asInt(m['partySize']);
    return LfgPost(
      id: id,
      author: CommunityAuthor.fromJson(m['author']) ?? CommunityAuthor.unknown,
      region: asNonEmptyString(m['region'])?.toLowerCase() ?? 'ap',
      mode: asNonEmptyString(m['mode'])?.toLowerCase(),
      partyCode: asNonEmptyString(m['partyCode'])?.toUpperCase() ?? '',
      slots: slots.clamp(1, 4),
      rankTier: asInt(m['rankTier']),
      note: asString(m['note'])?.trim() ?? '',
      createdAt: asDateTime(m['createdAt']),
      expiresAt: asDateTime(m['expiresAt']),
      rankMin: rankMin,
      rankMax: rankMax,
      roles: <String>{
        for (final r in asStringList(m['roles']))
          if (kLfgRoles.contains(r.toLowerCase())) r.toLowerCase(),
      }.toList(),
      mic: asBool(m['mic']),
      language: lfgLanguageCode(m['language']) ?? kLfgAnyLanguage,
      partySize: partySize?.clamp(1, 5),
      agents: [for (final a in asStringList(m['agents'])) ?lowerUuid(a)]
          .take(5)
          .toList(),
      status: LfgStatus.parse(m['status']),
      joins: _count(m['joins']),
      updatedAt: asDateTime(m['updatedAt']),
    );
  }

  final String id;
  final CommunityAuthor author;
  final String region;
  final String? mode;
  final String partyCode;
  final int slots;
  final int? rankTier;
  final String note;
  final DateTime? createdAt;
  final DateTime? expiresAt;

  /// Accepted rank range (`null` = any).
  final int? rankMin;
  final int? rankMax;

  /// Roles still needed.
  final List<String> roles;

  /// Voice chat required (`null` = not specified).
  final bool? mic;
  final String language;
  final int? partySize;

  /// Agents already picked by the party (uuids).
  final List<String> agents;
  final LfgStatus status;
  final int joins;
  final DateTime? updatedAt;

  bool isExpired(DateTime now) {
    final at = expiresAt;
    return at != null && !now.isBefore(at);
  }

  bool get hasValidCode => partyCodePattern.hasMatch(partyCode);

  bool get hasRankRange => rankMin != null || rankMax != null;

  /// Current party size (explicit, else derived from the open slots).
  int get currentPartySize => partySize ?? (5 - slots).clamp(1, 4);

  /// Whether a player of [tier] fits the rank range (unknown rank or no
  /// range → fits).
  bool acceptsRank(int? tier) {
    if (tier == null || tier <= 2 || !hasRankRange) return true;
    return tier >= (rankMin ?? 0) && tier <= (rankMax ?? kMaxRankTier);
  }

  LfgPost copyWith({
    int? slots,
    int? partySize,
    LfgStatus? status,
    int? joins,
    DateTime? expiresAt,
  }) => LfgPost(
    id: id,
    author: author,
    partyCode: partyCode,
    region: region,
    mode: mode,
    slots: slots ?? this.slots,
    rankTier: rankTier,
    note: note,
    createdAt: createdAt,
    expiresAt: expiresAt ?? this.expiresAt,
    rankMin: rankMin,
    rankMax: rankMax,
    roles: roles,
    mic: mic,
    language: language,
    partySize: partySize ?? this.partySize,
    agents: agents,
    status: status ?? this.status,
    joins: joins ?? this.joins,
    updatedAt: updatedAt,
  );

  @override
  String toString() => 'LfgPost($id)';
}

// ------------------------------------------------------------ skin votes

/// Vote state of one skin.
@immutable
class SkinVote {
  const SkinVote({required this.skinUuid, this.votes = 0, this.voted = false});

  static SkinVote? fromJson(Object? json) {
    final m = asMap(json);
    final id = lowerUuid(m?['skinUuid']);
    if (m == null || id == null) return null;
    return SkinVote(
      skinUuid: id,
      votes: _count(m['votes']),
      voted: asBool(m['voted']) ?? false,
    );
  }

  final String skinUuid;
  final int votes;
  final bool voted;

  SkinVote toggled() => SkinVote(
    skinUuid: skinUuid,
    voted: !voted,
    votes: (votes + (voted ? -1 : 1)).clamp(0, 1 << 31),
  );

  @override
  bool operator ==(Object other) =>
      other is SkinVote &&
      other.skinUuid == skinUuid &&
      other.votes == votes &&
      other.voted == voted;

  @override
  int get hashCode => Object.hash(skinUuid, votes, voted);
}

/// Star rating aggregate of a skin.
@immutable
class SkinRating {
  const SkinRating({this.average, this.count = 0, this.reviewCount = 0});

  static const none = SkinRating();

  factory SkinRating.fromJson(Object? json) {
    final m = asMap(json);
    final avg = asDouble(m?['ratingAvg']);
    return SkinRating(
      average: avg == null || !avg.isFinite || avg <= 0
          ? null
          : avg.clamp(1.0, 5.0),
      count: _count(m?['ratingCount']),
      reviewCount: _count(m?['reviewCount']),
    );
  }

  /// 1.0–5.0, `null` when nobody rated.
  final double? average;
  final int count;

  /// Reviews with text.
  final int reviewCount;

  bool get hasRatings => average != null && count > 0;

  @override
  bool operator ==(Object other) =>
      other is SkinRating &&
      other.average == average &&
      other.count == count &&
      other.reviewCount == reviewCount;

  @override
  int get hashCode => Object.hash(average, count, reviewCount);
}

/// `4.56` → `4,6`: one decimal with the app locale's separator.
String formatRating(double value) =>
    NumberFormat('0.0', appIntlLocale).format(value);

/// Votes + rating of one skin (`/v1/skins/votes` items).
@immutable
class SkinStats {
  const SkinStats({
    required this.vote,
    this.rating = SkinRating.none,
    this.applied,
  });

  static SkinStats? fromJson(Object? json, {AppliedScope? applied}) {
    final vote = SkinVote.fromJson(json);
    if (vote == null) return null;
    return SkinStats(
      vote: vote,
      rating: SkinRating.fromJson(json),
      applied: applied,
    );
  }

  final SkinVote vote;
  final SkinRating rating;

  /// The scope the numbers were counted for (the response's `appliedScope`).
  final AppliedScope? applied;

  String get skinUuid => vote.skinUuid;
}

/// Leaderboard sort (`sort`).
enum TopSort {
  votes,
  rating,
  reviews;

  String get query => name;
}

/// One leaderboard row.
@immutable
class TopSkin {
  const TopSkin({
    required this.rank,
    required this.vote,
    this.weaponUuid,
    this.rating = SkinRating.none,
  });

  static TopSkin? fromJson(Object? json, int index) {
    final vote = SkinVote.fromJson(json);
    if (vote == null) return null;
    final m = asMap(json)!;
    return TopSkin(
      rank: asInt(m['rank']) ?? index + 1,
      vote: vote,
      weaponUuid: lowerUuid(m['weaponUuid']),
      rating: SkinRating.fromJson(m),
    );
  }

  final int rank;
  final SkinVote vote;
  final String? weaponUuid;
  final SkinRating rating;

  String get skinUuid => vote.skinUuid;
}

/// `GET /v1/skins/top`: the rows plus the scope the server applied.
@immutable
class TopSkinsResult {
  const TopSkinsResult(this.rows, {this.applied});

  final List<TopSkin> rows;
  final AppliedScope? applied;

  bool get isEmpty => rows.isEmpty;
}

/// Leaderboard periods.
enum TopPeriod {
  all,
  week;

  String get query => name;
}

// ----------------------------------------------------------- skin reviews

/// Review list order (`sort`).
enum ReviewSort {
  newest,
  top;

  String get query => this == newest ? 'new' : 'top';
}

/// Maximum review text length.
const kMaxReviewLength = 500;

/// One user's review of a skin (1–5 stars + optional text).
@immutable
class SkinReview {
  const SkinReview({
    required this.id,
    required this.skinUuid,
    required this.author,
    required this.rating,
    this.body = '',
    this.likes = 0,
    this.liked = false,
    this.mine = false,
    this.createdAt,
    this.updatedAt,
    this.language,
  });

  static SkinReview? fromJson(Object? json) {
    final m = asMap(json);
    final id = asNonEmptyString(m?['id']);
    final rating = asNum(m?['rating'])?.round();
    if (m == null || id == null || rating == null) return null;
    return SkinReview(
      id: id,
      skinUuid: lowerUuid(m['skinUuid']) ?? '',
      author: CommunityAuthor.fromJson(m['author']) ?? CommunityAuthor.unknown,
      rating: rating.clamp(1, 5),
      body: asString(m['body'])?.trim() ?? '',
      likes: _count(m['likes']),
      liked: asBool(m['liked']) ?? false,
      mine: asBool(m['mine']) ?? false,
      createdAt: asDateTime(m['createdAt']),
      updatedAt: asDateTime(m['updatedAt']),
      language: lfgLanguageCode(m['language']),
    );
  }

  final String id;
  final String skinUuid;
  final CommunityAuthor author;
  final int rating;
  final String body;
  final int likes;
  final bool liked;

  /// The viewer's own review (server flag).
  final bool mine;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  /// Language of [body] (for on-device translation).
  final String? language;

  bool get edited =>
      updatedAt != null &&
      createdAt != null &&
      updatedAt!.difference(createdAt!) > const Duration(minutes: 1);

  SkinReview copyWith({int? likes, bool? liked}) => SkinReview(
    id: id,
    skinUuid: skinUuid,
    author: author,
    rating: rating,
    body: body,
    likes: likes ?? this.likes,
    liked: liked ?? this.liked,
    mine: mine,
    createdAt: createdAt,
    updatedAt: updatedAt,
    language: language,
  );

  SkinReview toggledLike() => copyWith(
    liked: !liked,
    likes: (likes + (liked ? -1 : 1)).clamp(0, 1 << 31),
  );

  @override
  String toString() => 'SkinReview($id)';
}

/// `GET /v1/skins/{uuid}/summary`.
@immutable
class SkinSummary {
  const SkinSummary({
    required this.skinUuid,
    this.weaponUuid,
    this.vote,
    this.rating = SkinRating.none,
    this.distribution = const [0, 0, 0, 0, 0],
    this.myReview,
    this.applied,
  });

  static SkinSummary fromJson(Object? json, String skinUuid) {
    final m = asMap(json);
    final id = lowerUuid(m?['skinUuid']) ?? skinUuid.toLowerCase();
    final raw = asList(m?['distribution']);
    return SkinSummary(
      skinUuid: id,
      weaponUuid: lowerUuid(m?['weaponUuid']),
      vote: SkinVote(
        skinUuid: id,
        votes: _count(m?['votes']),
        voted: asBool(m?['voted']) ?? false,
      ),
      rating: SkinRating.fromJson(m),
      distribution: [
        for (var i = 0; i < 5; i++) i < raw.length ? _count(raw[i]) : 0,
      ],
      myReview: SkinReview.fromJson(m?['myReview']),
      applied: AppliedScope.fromJson(m?['appliedScope']),
    );
  }

  final String skinUuid;
  final String? weaponUuid;
  final SkinVote? vote;
  final SkinRating rating;

  /// Counts of 1★ … 5★ ratings (always 5 entries).
  final List<int> distribution;
  final SkinReview? myReview;

  /// The scope the counts were made for.
  final AppliedScope? applied;

  int get distributionTotal => distribution.fold(0, (a, b) => a + b);

  /// Share (0–1) of [stars]-star ratings.
  double share(int stars) {
    final total = distributionTotal;
    if (total == 0 || stars < 1 || stars > 5) return 0;
    return distribution[stars - 1] / total;
  }

  SkinSummary withMyReview(SkinReview? review) => SkinSummary(
    skinUuid: skinUuid,
    weaponUuid: weaponUuid,
    vote: vote,
    rating: rating,
    distribution: distribution,
    myReview: review,
    applied: applied,
  );
}
