import type { Hono } from 'hono';
import { author, iso, type Ctx } from '../context.js';
import { decodeCursor, page } from '../cursor.js';
import type { AuthorCols, LfgRow } from '../db/repo.js';
import { forbidden, invalid, notFound } from '../errors.js';
import {
  isUuid,
  LFG_MODES,
  parseEnum,
  parseInt,
  parseLimit,
  parseOptional,
  parseRankTier,
  parseRegion,
  parseString,
  PARTY_CODE_RE,
} from '../validate.js';

export const LFG_TTL_MS = 30 * 60_000;

function serialize(r: LfgRow & AuthorCols) {
  return {
    id: r.id,
    author: author(r),
    region: r.region,
    mode: r.mode,
    partyCode: r.party_code,
    slots: r.slots,
    rankTier: r.rank_tier,
    note: r.note,
    createdAt: iso(r.created_at),
    expiresAt: iso(r.expires_at),
  };
}

export function registerLfg(app: Hono, x: Ctx): void {
  app.get('/v1/lfg', (c) => {
    x.user(c, true);
    const q = c.req.query();
    const region = q.region ? parseRegion(q.region) : undefined;
    const mode = q.mode ? parseEnum(q.mode, LFG_MODES, 'mode') : undefined;
    const cursor = decodeCursor(q.cursor);
    const limit = parseLimit(q.limit, 20, 50);
    const rows = x.repo.listLfg({ region, mode, now: x.now(), cursor, limit });
    return x.json(c, page(rows, limit, serialize));
  });

  app.post('/v1/lfg', async (c) => {
    const user = x.user(c, true);
    const body = await x.readJson(c);
    const region = parseRegion(body.region);
    const mode = parseEnum(body.mode, LFG_MODES, 'mode');
    if (typeof body.partyCode !== 'string' || !PARTY_CODE_RE.test(body.partyCode)) {
      throw invalid('partyCode phải gồm đúng 6 chữ in hoa hoặc số.');
    }
    const partyCode = body.partyCode;
    const slots = parseInt(body.slots, 1, 4, 'slots');
    const rankTier = parseOptional(body, 'rankTier', parseRankTier);
    const noteRaw = parseOptional(body, 'note', (v) => parseString(v, 'note', { max: 140 }));
    const note = noteRaw ? noteRaw : null;

    x.rateLimit('lfg', user.id);

    const now = x.now();
    const row: LfgRow = {
      id: crypto.randomUUID(),
      user_id: user.id,
      region,
      mode,
      party_code: partyCode,
      slots,
      rank_tier: rankTier === undefined ? user.rank_tier : rankTier,
      note,
      hidden: 0,
      created_at: now,
      expires_at: now + LFG_TTL_MS,
    };
    x.repo.replaceLfg(row);
    return x.json(c, serialize(x.repo.getLfg(row.id)!));
  });

  app.delete('/v1/lfg/:id', (c) => {
    const user = x.user(c, true);
    const id = c.req.param('id').toLowerCase();
    if (!isUuid(id)) throw notFound('Không tìm thấy bài tìm đồng đội.');
    const post = x.repo.getLfg(id);
    if (!post) throw notFound('Không tìm thấy bài tìm đồng đội.');
    if (post.user_id !== user.id) throw forbidden('Bạn chỉ có thể xóa bài của chính mình.');
    x.repo.deleteLfg(id);
    return x.noContent(c);
  });
}
