import type { Hono } from 'hono';
import type { Ctx } from '../context.js';
import { parseEnum } from '../validate.js';

const WEEK_MS = 7 * 24 * 60 * 60_000;

/**
 * `GET /v1/communities?period=week` — countries with community activity: visible posts, LFG
 * posts and their distinct authors in the last 7 days, counted by the author's country at
 * creation time. Sorted by posts (then LFG, then authors, then country code). Public.
 */
export function registerCommunities(app: Hono, x: Ctx): void {
  app.get('/v1/communities', (c) => {
    x.user(c, false); // a present-but-invalid token is still rejected so clients refresh it
    const period = c.req.query('period');
    const p = period ? parseEnum(period, ['week', 'all'] as const, 'period') : 'week';
    const since = p === 'week' ? x.now() - WEEK_MS : 0;
    return x.json(c, { items: x.repo.communities(since) });
  });
}
