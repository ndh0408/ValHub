import type { Hono } from 'hono';
import type { Ctx } from '../context.js';
import type { RatingStats } from '../db/repo.js';
import { invalid } from '../errors.js';
import { appliedScope, resolveScope } from '../geo/scope.js';
import { parseEnum, parseLimit, parseUuid } from '../validate.js';

export const WEEK_MS = 7 * 24 * 60 * 60_000;
const MAX_IDS = 50;
/** Bayesian prior weight C and minimum number of ratings for sort=rating. */
export const BAYES_C = 5;
export const MIN_RATINGS_FOR_RANK = 3;

/** Average rounded to 1 decimal, or null without ratings. */
export function ratingAvg(s: RatingStats | undefined): number | null {
  if (!s || s.count === 0) return null;
  return Math.round((s.sum / s.count) * 10) / 10;
}

export function registerSkins(app: Hono, x: Ctx): void {
  const voteResponse = (skinUuid: string, voted: boolean) => ({
    skinUuid,
    votes: x.repo.voteCounts([skinUuid]).get(skinUuid) ?? 0,
    voted,
  });

  app.put('/v1/skins/:skinUuid/vote', async (c) => {
    const user = x.user(c, true);
    const skinUuid = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    const body = await x.readJson(c);
    const weaponUuid = parseUuid(body.weaponUuid, 'weaponUuid');
    x.rateLimit('votes', user.id);
    x.repo.voteSkin(user.id, skinUuid, weaponUuid, x.now(), {
      country: user.country,
      region: user.region,
    });
    return x.json(c, voteResponse(skinUuid, true));
  });

  app.delete('/v1/skins/:skinUuid/vote', (c) => {
    const user = x.user(c, true);
    const skinUuid = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    x.rateLimit('votes', user.id);
    x.repo.unvoteSkin(user.id, skinUuid);
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
    if (parts.length === 0) throw invalid('ids không được để trống.');
    if (parts.length > MAX_IDS) throw invalid(`ids tối đa ${MAX_IDS} UUID.`);
    const ids = [...new Set(parts.map((p) => parseUuid(p, 'ids')))];
    const geo = resolveScope(c.req.query(), user, 'global');
    const counts = x.repo.voteCounts(ids, undefined, geo);
    const stats = x.repo.ratingStats(ids, undefined, geo);
    const voted = user ? x.repo.userVotes(user.id, ids) : new Set<string>();
    return x.json(c, {
      items: ids.map((id) => ({
        skinUuid: id,
        votes: counts.get(id) ?? 0,
        voted: voted.has(id),
        ratingAvg: ratingAvg(stats.get(id)),
        ratingCount: stats.get(id)?.count ?? 0,
      })),
      appliedScope: appliedScope(geo),
    });
  });
}
