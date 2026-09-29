import type { Context, Hono } from 'hono';
import { author, iso, type Ctx } from '../context.js';
import { decodeCursor, page } from '../cursor.js';
import type { LfgPatch, LfgRow, LfgView } from '../db/repo.js';
import { forbidden, invalid, notFound } from '../errors.js';
import { parseLanguageList, parseLfgLanguage } from '../geo/languages.js';
import { appliedScope, resolveScope } from '../geo/scope.js';
import { cleanUserText } from '../moderation/filter.js';
import {
  isUuid,
  LFG_MODES,
  LFG_ROLES,
  LFG_STATUSES,
  parseBool,
  parseEnum,
  parseInt,
  parseLimit,
  parseOptional,
  parseRankTier,
  parseRegion,
  parseString,
  parseUniqueArray,
  parseUuid,
  PARTY_CODE_RE,
  type Json,
} from '../validate.js';

export const LFG_TTL_MS = 30 * 60_000;

function jsonArray(text: string): string[] {
  try {
    const v: unknown = JSON.parse(text);
    return Array.isArray(v) ? v.filter((x): x is string => typeof x === 'string') : [];
  } catch {
    return [];
  }
}

function serialize(r: LfgView) {
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
    rankMin: r.rank_min,
    rankMax: r.rank_max,
    roles: jsonArray(r.roles),
    mic: r.mic === 1,
    language: r.language,
    partySize: r.party_size ?? Math.max(1, 5 - r.slots),
    agents: jsonArray(r.agents),
    status: r.status,
    joins: r.joins,
    updatedAt: iso(r.updated_at ?? r.created_at),
    country: r.country ?? null,
  };
}

const parseNote = (body: Json, language: string | null, country: string | null) => {
  const v = parseOptional(body, 'note', (x) =>
    cleanUserText(parseString(x, 'note', { max: 140 }), language, country).trim(),
  );
  return v === undefined ? undefined : v ? v : null;
};

export function registerLfg(app: Hono, x: Ctx): void {
  /** Own post by path id (404 if missing or expired, 403 if someone else's). */
  const ownActivePost = (c: Context, userId: string): LfgView => {
    const id = (c.req.param('id') ?? '').toLowerCase();
    const post = isUuid(id) ? x.repo.getLfg(id) : null;
    if (!post || post.expires_at <= x.now()) throw notFound('Không tìm thấy bài tìm đồng đội.');
    if (post.user_id !== userId) throw forbidden('Bạn chỉ có thể sửa bài của chính mình.');
    return post;
  };

  app.get('/v1/lfg', (c) => {
    const user = x.user(c, true);
    const q = c.req.query();
    const geo = resolveScope(q, user, 'region');
    const mode = q.mode ? parseEnum(q.mode, LFG_MODES, 'mode') : undefined;
    let rank: number | undefined;
    if (q.rank !== undefined && q.rank !== '') {
      if (!/^\d{1,2}$/.test(q.rank)) throw invalid('rank phải là số nguyên từ 0 đến 27.');
      rank = parseRankTier(Number(q.rank));
    }
    const role = q.role ? parseEnum(q.role, LFG_ROLES, 'role') : undefined;
    let mic: boolean | undefined;
    if (q.mic !== undefined && q.mic !== '') {
      if (q.mic !== 'true' && q.mic !== 'false') throw invalid('mic phải là true hoặc false.');
      mic = q.mic === 'true';
    }
    const languages = parseLanguageList(q.language, true);
    const status = q.status ? parseEnum(q.status, LFG_STATUSES, 'status') : 'open';
    const cursor = decodeCursor(q.cursor);
    const limit = parseLimit(q.limit, 20, 50);
    const rows = x.repo.listLfg({ geo, mode, rank, role, mic, languages, status, now: x.now(), cursor, limit });
    return x.json(c, { ...page(rows, limit, serialize), appliedScope: appliedScope(geo) });
  });

  app.get('/v1/lfg/mine', (c) => {
    const user = x.user(c, true);
    const post = x.repo.getActiveLfgForUser(user.id, x.now());
    return x.json(c, post ? serialize(post) : null);
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
    // v2 fields
    const rankMin = parseOptional(body, 'rankMin', (v) => parseInt(v, 0, 27, 'rankMin')) ?? null;
    const rankMax = parseOptional(body, 'rankMax', (v) => parseInt(v, 0, 27, 'rankMax')) ?? null;
    if (rankMin && rankMax && rankMin > rankMax) throw invalid('rankMin không được lớn hơn rankMax.');
    const roles =
      parseOptional(body, 'roles', (v) =>
        parseUniqueArray(v, 'roles', 4, (r) => parseEnum(r, LFG_ROLES, 'roles')),
      ) ?? [];
    const mic = parseOptional(body, 'mic', (v) => parseBool(v, 'mic')) ?? false;
    // Party language: the 17 app languages or 'any'. Default = the author's language, 'vi' when unknown
    // (what clients before v3 always got).
    const language = parseOptional(body, 'language', (v) => parseLfgLanguage(v, 'language')) ?? user.language ?? 'vi';
    const note = parseNote(body, language === 'any' ? user.language : language, user.country) ?? null;
    const partySize = parseOptional(body, 'partySize', (v) => parseInt(v, 1, 5, 'partySize')) ?? Math.max(1, 5 - slots);
    const agents =
      parseOptional(body, 'agents', (v) => parseUniqueArray(v, 'agents', 5, (a) => parseUuid(a, 'agents'))) ?? [];

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
      rank_min: rankMin,
      rank_max: rankMax,
      roles: JSON.stringify(roles),
      mic: mic ? 1 : 0,
      language,
      party_size: partySize,
      agents: JSON.stringify(agents),
      status: 'open',
      updated_at: now,
      country: user.country,
    };
    x.repo.replaceLfg(row);
    return x.json(c, serialize(x.repo.getLfg(row.id)!));
  });

  app.patch('/v1/lfg/:id', async (c) => {
    const user = x.user(c, true);
    const post = ownActivePost(c, user.id);
    const body = await x.readJson(c);
    const patch: LfgPatch = {};
    const partySize = parseOptional(body, 'partySize', (v) => parseInt(v, 1, 5, 'partySize'));
    if (partySize === null) throw invalid('partySize không được để trống.');
    if (partySize !== undefined) patch.party_size = partySize;
    const slots = parseOptional(body, 'slots', (v) => parseInt(v, 1, 4, 'slots'));
    if (slots === null) throw invalid('slots không được để trống.');
    if (slots !== undefined) patch.slots = slots;
    const note = parseNote(body, post.language === 'any' ? user.language : post.language, user.country);
    if (note !== undefined) patch.note = note;
    const status = parseOptional(body, 'status', (v) => parseEnum(v, LFG_STATUSES, 'status'));
    if (status === null) throw invalid('status không được để trống.');
    if (status !== undefined) patch.status = status;

    x.rateLimit('lfgPatch', user.id);
    const now = x.now();
    x.repo.updateLfg(post.id, patch, now, now + LFG_TTL_MS);
    return x.json(c, serialize(x.repo.getLfg(post.id)!));
  });

  app.post('/v1/lfg/:id/join', async (c) => {
    const user = x.user(c, true);
    await x.readJson(c); // body is `{}`; must still be valid JSON if present
    const id = c.req.param('id').toLowerCase();
    const post = isUuid(id) ? x.repo.getLfg(id) : null;
    if (!post || post.hidden || post.expires_at <= x.now()) throw notFound('Không tìm thấy bài tìm đồng đội.');
    if (post.user_id === user.id) throw forbidden('Bạn không thể vào tổ đội của chính mình.');
    x.rateLimit('lfgJoin', user.id);
    return x.json(c, { joins: x.repo.joinLfg(post.id, user.id, x.now()) });
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
