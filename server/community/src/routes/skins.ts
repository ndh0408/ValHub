import type { Hono } from 'hono';
import type { Ctx } from '../context.js';
import { invalid } from '../errors.js';
import { parseEnum, parseLimit, parseUuid } from '../validate.js';

const WEEK_MS = 7 * 24 * 60 * 60_000;
const MAX_IDS = 50;

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
    x.repo.voteSkin(user.id, skinUuid, weaponUuid, x.now());
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
    const limit = parseLimit(q.limit, 20, 100);
    const rows = x.repo.topSkins({
      weaponUuid,
      since: period === 'week' ? x.now() - WEEK_MS : undefined,
      limit,
    });
    const voted = user ? x.repo.userVotes(user.id, rows.map((r) => r.skinUuid)) : new Set<string>();
    return x.json(c, {
      items: rows.map((r, i) => ({
        rank: i + 1,
        skinUuid: r.skinUuid,
        weaponUuid: r.weaponUuid,
        votes: r.votes,
        voted: voted.has(r.skinUuid),
      })),
    });
  });

  app.get('/v1/skins/votes', (c) => {
    const user = x.user(c, false);
    const raw = c.req.query('ids') ?? '';
    const parts = raw.split(',').filter((s) => s.trim() !== '');
    if (parts.length === 0) throw invalid('ids không được để trống.');
    if (parts.length > MAX_IDS) throw invalid(`ids tối đa ${MAX_IDS} UUID.`);
    const ids = [...new Set(parts.map((p) => parseUuid(p, 'ids')))];
    const counts = x.repo.voteCounts(ids);
    const voted = user ? x.repo.userVotes(user.id, ids) : new Set<string>();
    return x.json(c, {
      items: ids.map((id) => ({ skinUuid: id, votes: counts.get(id) ?? 0, voted: voted.has(id) })),
    });
  });
}
