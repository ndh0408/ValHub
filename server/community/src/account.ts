import { iso } from './context.js';
import type { AccountData } from './db/repo.js';
import { deleteMedia, postMediaKeys, type MediaDeps } from './media-service.js';

/**
 * Right to erasure: hard-deletes the account and everything that cascades from it (posts and their
 * comments / likes, comments, reviews and their likes, likes, votes, LFG posts and joins, media rows);
 * reports about its content are deleted, reports it filed are anonymised. Image files (public and
 * quarantined) are removed too. Backups keep older copies for at most their retention (README).
 * Returns false when there is no such user.
 */
export async function deleteAccount(d: MediaDeps, userId: string): Promise<boolean> {
  if (!d.repo.getUser(userId)) return false;
  const keys = d.repo.mediaOfUser(userId).map((m) => m.key);
  d.repo.deleteAccountRows(userId);
  await deleteMedia(d, keys); // rows are already gone with the user; this removes the files
  return true;
}

const parseJson = (text: string | null): unknown => {
  if (text === null) return null;
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
};

/** Everything stored about the account, as plain JSON (media as URLs). No PUUID or IP is ever stored. */
export function buildExport(data: AccountData, baseUrl: string, now: number) {
  const u = data.user;
  const url = (key: string) => `${baseUrl}/v1/media/${key}`;
  return {
    format: 'valvn-community-export/1',
    exportedAt: iso(now),
    profile: {
      id: u.id,
      gameName: u.game_name,
      tagLine: u.tag_line,
      cardId: u.card_id,
      rankTier: u.rank_tier,
      region: u.region,
      country: u.country,
      language: u.language,
      createdAt: iso(u.created_at),
      updatedAt: iso(u.updated_at),
    },
    posts: data.posts.map((p) => ({
      id: p.id,
      kind: p.kind,
      body: p.body,
      media: postMediaKeys(p.media).map((key) => ({ key, url: url(key) })),
      payload: parseJson(p.payload),
      hidden: p.hidden === 1,
      country: p.country,
      region: p.region,
      language: p.language,
      createdAt: iso(p.created_at),
    })),
    comments: data.comments.map((c) => ({
      id: c.id,
      postId: c.post_id,
      body: c.body,
      hidden: c.hidden === 1,
      country: c.country,
      region: c.region,
      language: c.language,
      createdAt: iso(c.created_at),
    })),
    reviews: data.reviews.map((r) => ({
      id: r.id,
      skinUuid: r.skin_uuid,
      weaponUuid: r.weapon_uuid,
      rating: r.rating,
      body: r.body,
      hidden: r.hidden === 1,
      likes: r.like_count,
      country: r.country,
      region: r.region,
      language: r.language,
      createdAt: iso(r.created_at),
      updatedAt: iso(r.updated_at),
    })),
    postLikes: data.postLikes.map((l) => ({ postId: l.post_id, createdAt: iso(l.created_at) })),
    reviewLikes: data.reviewLikes.map((l) => ({ reviewId: l.review_id, createdAt: iso(l.created_at) })),
    skinVotes: data.votes.map((v) => ({
      skinUuid: v.skin_uuid,
      weaponUuid: v.weapon_uuid,
      country: v.country,
      region: v.region,
      createdAt: iso(v.created_at),
    })),
    lfgPosts: data.lfgPosts.map((l) => ({
      id: l.id,
      region: l.region,
      country: l.country,
      mode: l.mode,
      partyCode: l.party_code,
      slots: l.slots,
      rankTier: l.rank_tier,
      note: l.note,
      rankMin: l.rank_min,
      rankMax: l.rank_max,
      roles: parseJson(l.roles),
      mic: l.mic === 1,
      language: l.language,
      partySize: l.party_size,
      agents: parseJson(l.agents),
      status: l.status,
      hidden: l.hidden === 1,
      createdAt: iso(l.created_at),
      expiresAt: iso(l.expires_at),
      updatedAt: iso(l.updated_at ?? l.created_at),
    })),
    lfgJoins: data.lfgJoins.map((j) => ({ lfgId: j.lfg_id, createdAt: iso(j.created_at) })),
    reportsFiled: data.reportsFiled.map((r) => ({
      targetType: r.target_type,
      targetId: r.target_id,
      reason: r.reason,
      createdAt: iso(r.created_at),
    })),
    media: data.media.map((m) => ({
      key: m.key,
      url: url(m.key),
      contentType: m.content_type,
      size: m.size,
      status: m.status,
      attachedToPost: m.post_id,
      createdAt: iso(m.created_at),
    })),
  };
}
