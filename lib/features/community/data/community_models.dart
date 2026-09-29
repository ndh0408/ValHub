import 'package:flutter/foundation.dart';

import '../../../core/util/json.dart';

/// Typed models of the ValVN community API (docs/community-api.md). Every
/// parser is defensive: missing / odd fields become `null`, defaults or are
/// skipped; nothing throws.

/// Regions accepted by the server (`region`).
const kCommunityRegions = ['ap', 'na', 'eu', 'kr', 'latam', 'br'];

/// Normalises an account region to a community region (`ap` fallback).
String communityRegion(String? region) {
  final r = region?.toLowerCase().trim();
  return kCommunityRegions.contains(r) ? r! : 'ap';
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
    );
  }

  final String id;
  final String gameName;
  final String tagLine;
  final String? cardId;
  final int? rankTier;
  final String? region;

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
  };

  @override
  bool operator ==(Object other) =>
      other is CommunityAuthor &&
      other.id == id &&
      other.gameName == gameName &&
      other.tagLine == tagLine &&
      other.cardId == cardId &&
      other.rankTier == rankTier &&
      other.region == region;

  @override
  int get hashCode =>
      Object.hash(id, gameName, tagLine, cardId, rankTier, region);

  @override
  String toString() => 'CommunityAuthor($id)';
}

/// A cursor page (`{"items": [...], "nextCursor": "…" | null}`).
@immutable
class CommunityPage<T> {
  const CommunityPage(this.items, {this.nextCursor});

  static CommunityPage<T> fromJson<T>(
    Object? json,
    T? Function(Object? item) parse,
  ) {
    final m = asMap(json);
    final list = m == null ? asList(json) : asList(m['items']);
    return CommunityPage<T>([
      for (final e in list) ?parse(e),
    ], nextCursor: asNonEmptyString(m?['nextCursor']));
  }

  final List<T> items;
  final String? nextCursor;

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
    );
  }

  final String id;
  final String postId;
  final CommunityAuthor author;
  final String body;
  final DateTime? createdAt;
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

/// A looking-for-group post (expires after 30 minutes).
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
  });

  static LfgPost? fromJson(Object? json) {
    final m = asMap(json);
    final id = asNonEmptyString(m?['id']);
    if (m == null || id == null) return null;
    final slots = asInt(m['slots']) ?? 1;
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

  bool isExpired(DateTime now) {
    final at = expiresAt;
    return at != null && !now.isBefore(at);
  }

  bool get hasValidCode => partyCodePattern.hasMatch(partyCode);

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

/// One leaderboard row.
@immutable
class TopSkin {
  const TopSkin({required this.rank, required this.vote, this.weaponUuid});

  static TopSkin? fromJson(Object? json, int index) {
    final vote = SkinVote.fromJson(json);
    if (vote == null) return null;
    final m = asMap(json)!;
    return TopSkin(
      rank: asInt(m['rank']) ?? index + 1,
      vote: vote,
      weaponUuid: lowerUuid(m['weaponUuid']),
    );
  }

  final int rank;
  final SkinVote vote;
  final String? weaponUuid;

  String get skinUuid => vote.skinUuid;
}

/// Leaderboard periods.
enum TopPeriod {
  all,
  week;

  String get query => name;
}
