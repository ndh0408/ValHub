import type { Hono } from 'hono';
import type { Ctx } from '../context.js';
import type { RatingStats } from '../db/repo.js';
import { invalid, reasonError } from '../errors.js';
import { appliedScope, resolveScope } from '../geo/scope.js';
import { parseEnum, parseLimit, parseUuid } from '../validate.js';

export const WEEK_MS = 7 * 24 * 60 * 60_000;
const MAX_IDS = 50;
/** Bayesian prior weight C and minimum number of ratings for sort=rating. */
export const BAYES_C = 15;
export const MIN_RATINGS_FOR_RANK = 10;

/** Average rounded to 1 decimal, or null without ratings. */
export function ratingAvg(s: RatingStats | undefined): number | null {
  if (!s || s.count === 0) return null;
  return Math.round((s.sum / s.count) * 10) / 10;
}

export function registerSkins(app: Hono, x: Ctx): void {
  /** The uuid votes / reviews of a skin are stored under: its base skin uuid when the catalog knows it. */
  const canonId = (uuid: string): string => x.canonSkin(uuid)?.skinUuid ?? uuid;

  // `skinUuid` in the answer is the one the client asked about; the counts are those of the canonical skin.
  const voteResponse = (skinUuid: string, voted: boolean) => ({
    skinUuid,
    votes: x.repo.voteCounts([canonId(skinUuid)]).get(canonId(skinUuid)) ?? 0,
    voted,
  });

  app.put('/v1/skins/:skinUuid/vote', async (c) => {
    const user = x.user(c, true);
    const skinUuid = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    const body = await x.readJson(c);
    const weaponUuid = parseUuid(body.weaponUuid, 'weaponUuid');
    x.rateLimit('votes', user.id);
    await x.assertContent('skin', skinUuid, 'skinUuid');
    await x.assertContent('weapon', weaponUuid, 'weaponUuid');
    x.assertCurrentUser(c);
    // One vote per account per skin, whatever uuid the client uses (skin, level or chroma): stored under the base
    // skin uuid with the weapon the catalog says it belongs to (the client's weapon is only used when the catalog
    // cannot answer, and the sweeper re-canonicalises such rows once it can).
    const canon = x.canonSkin(skinUuid);
    x.repo.voteSkin(
      user.id,
      canon?.skinUuid ?? skinUuid,
      canon?.weaponUuid ?? weaponUuid,
      x.now(),
      { country: user.country, region: user.region },
      canon !== null,
    );
    return x.json(c, voteResponse(skinUuid, true));
  });

  app.delete('/v1/skins/:skinUuid/vote', (c) => {
    const user = x.user(c, true);
    const skinUuid = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    x.rateLimit('votes', user.id);
    x.repo.unvoteSkin(user.id, canonId(skinUuid));
    if (canonId(skinUuid) !== skinUuid) x.repo.unvoteSkin(user.id, skinUuid); // a vote stored before canonicalisation
    return x.json(c, voteResponse(skinUuid, false));
  });

  app.get('/v1/skins/top', (c) => {
    const user = x.user(c, false);
    const q = c.req.query();
    const weaponUuid = q.weapon ? parseUuid(q.weapon, 'weapon') : undefined;
    const period = q.period ? parseEnum(q.period, ['all', 'week'] as const, 'period') : 'all';
    const sort = q.sort ? parseEnum(q.sort, ['votes', 'rating', 'reviews'] as const, 'sort') : 'votes';
    const limit = parseLimit(q.limit, 20, 100);
    const since = period === 'week' ? x.now() - WEEK_MS : undefined;
    // v3: votes / ratings are counted by the voter's / reviewer's country or region (default: everyone).
    const geo = resolveScope(q, user, 'global');

    let rows: { skinUuid: string; weaponUuid: string }[];
    let votes: Map<string, number>;
    if (sort === 'votes') {
      const top = x.repo.topSkins({ weaponUuid, since, limit, geo });
      rows = top;
      votes = new Map(top.map((r) => [r.skinUuid, r.votes]));
    } else {
      rows =
        sort === 'rating'
          ? x.repo.topRatedSkins({ weaponUuid, since, limit, c: BAYES_C, minCount: MIN_RATINGS_FOR_RANK, geo })
          : x.repo.topReviewedSkins({ weaponUuid, since, limit, geo });
      votes = x.repo.voteCounts(
        rows.map((r) => r.skinUuid),
        since,
        geo,
      );
    }
    const ids = rows.map((r) => r.skinUuid);
    const stats = x.repo.ratingStats(ids, since, geo);
    const voted = user ? x.repo.userVotes(user.id, ids) : new Set<string>();
    return x.json(c, {
      items: rows.map((r, i) => {
        const s = stats.get(r.skinUuid);
        return {
          rank: i + 1,
          skinUuid: r.skinUuid,
          weaponUuid: r.weaponUuid,
          votes: votes.get(r.skinUuid) ?? 0,
          voted: voted.has(r.skinUuid),
          ratingAvg: ratingAvg(s),
          ratingCount: s?.count ?? 0,
          reviewCount: s?.reviewCount ?? 0,
        };
      }),
      appliedScope: appliedScope(geo),
    });
  });

  app.get('/v1/skins/votes', (c) => {
    const user = x.user(c, false);
    const raw = c.req.query('ids') ?? '';
    const parts = raw.split(',').filter((s) => s.trim() !== '');
    if (parts.length === 0) throw reasonError('invalid_input', 'field_empty', { field: 'ids' });
    if (parts.length > MAX_IDS) throw reasonError('invalid_input', 'array_bad_size', { field: 'ids', max: MAX_IDS });
    const ids = [...new Set(parts.map((p) => parseUuid(p, 'ids')))];
    // Levels and chromas count as their base skin; each item keeps the uuid that was asked for.
    const canon = ids.map(canonId);
    const lookup = [...new Set(canon)];
    const geo = resolveScope(c.req.query(), user, 'global');
    const counts = x.repo.voteCounts(lookup, undefined, geo);
    const stats = x.repo.ratingStats(lookup, undefined, geo);
    const voted = user ? x.repo.userVotes(user.id, lookup) : new Set<string>();
    return x.json(c, {
      items: ids.map((id, i) => {
        const key = canon[i]!;
        return {
          skinUuid: id,
          votes: counts.get(key) ?? 0,
          voted: voted.has(key),
          ratingAvg: ratingAvg(stats.get(key)),
          ratingCount: stats.get(key)?.count ?? 0,
        };
      }),
      appliedScope: appliedScope(geo),
    });
  });
}
