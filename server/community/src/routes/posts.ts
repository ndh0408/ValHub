import type { Context, Hono } from 'hono';
import { author, iso, origin, ownHidden, REPORT_MIN_ACCOUNT_AGE_MS, type Ctx } from '../context.js';
import { decodeCursor, page } from '../cursor.js';
import type { AuthorCols, CommentRow, PostView } from '../db/repo.js';
import { forbidden, invalid, notFound } from '../errors.js';
import { contentLanguage, parseLanguageList } from '../geo/languages.js';
import { appliedScope, resolveScope } from '../geo/scope.js';
import { MEDIA_KEY_RE } from '../media.js';
import { postMediaKeys } from '../media-service.js';
import { cleanUserText } from '../moderation/filter.js';
import {
  isObject,
  isUuid,
  parseDate,
  parseEnum,
  parseInt,
  parseLimit,
  parseString,
  parseUuid,
  POST_KINDS,
  REPORT_TARGETS,
  type Json,
  type PostKind,
} from '../validate.js';

const MAX_MEDIA = 4;
const MAX_OFFERS = 6;
const MAX_COST = 1_000_000;
export const REPORT_HIDE_THRESHOLD = 3;

/** Validates and normalises `payload` (unknown fields are dropped). */
export function parsePayload(kind: PostKind, raw: unknown): Json | null {
  if (kind === 'text') {
    if (raw === undefined || raw === null) return null;
    throw invalid('Bài viết loại text không có payload.');
  }
  if (!isObject(raw)) throw invalid(`Bài viết loại ${kind} cần payload.`);
  const date = parseDate(raw.date, 'payload.date');
  if (!Array.isArray(raw.offers) || raw.offers.length < 1 || raw.offers.length > MAX_OFFERS) {
    throw invalid(`payload.offers phải có từ 1 đến ${MAX_OFFERS} mục.`);
  }
  const offers = raw.offers.map((o: unknown, i: number) => {
    const f = `payload.offers[${i}]`;
    if (!isObject(o)) throw invalid(`${f} không hợp lệ.`);
    const skinUuid = parseUuid(o.skinUuid, `${f}.skinUuid`);
    if (kind === 'store') {
      return { skinUuid, cost: parseInt(o.cost, 0, MAX_COST, `${f}.cost`) };
    }
    const baseCost = parseInt(o.baseCost, 0, MAX_COST, `${f}.baseCost`);
    const discountCost = parseInt(o.discountCost, 0, MAX_COST, `${f}.discountCost`);
    const discountPercent = parseInt(o.discountPercent, 0, 100, `${f}.discountPercent`);
    if (discountCost > baseCost) throw invalid(`${f}.discountCost không được lớn hơn baseCost.`);
    return { skinUuid, baseCost, discountCost, discountPercent };
  });
  return { date, offers };
}

function safeJson(text: string | null): unknown {
  if (text === null) return null;
  try {
    return JSON.parse(text);
  } catch {
    return null;
  }
}

export function registerPosts(app: Hono, x: Ctx): void {
  const serializePost = (p: PostView, base: string, viewerId = '') => {
    const keys = safeJson(p.media);
    return {
      id: p.id,
      author: author(p),
      kind: p.kind,
      body: p.body,
      media: (Array.isArray(keys) ? keys : [])
        .filter((k): k is string => typeof k === 'string')
        .map((key) => ({ key, url: x.mediaUrl(base, key) })),
      payload: safeJson(p.payload),
      likes: p.likes,
      liked: p.liked === 1,
      comments: p.comments,
      createdAt: iso(p.created_at),
      ...origin(p),
      // Only the author is told whether (and why) their post is hidden.
      ...(p.user_id === viewerId ? ownHidden(p) : {}),
    };
  };

  const serializeComment = (r: CommentRow & AuthorCols) => ({
    id: r.id,
    postId: r.post_id,
    author: author(r),
    body: r.body,
    createdAt: iso(r.created_at),
    ...origin(r),
  });

  /** Visible (not hidden) post or 404. */
  const visiblePost = (rawId: string, viewerId: string): PostView => {
    const id = rawId.toLowerCase();
    const p = isUuid(id) ? x.repo.getPost(id, viewerId) : null;
    if (!p || p.hidden) throw notFound('Không tìm thấy bài viết.');
    return p;
  };

  // ---- posts -----------------------------------------------------------------

  // v3: the feed is readable without a session (global scope); a session enables `liked`
  // and the country/region defaults.
  app.get('/v1/posts', (c) => {
    const user = x.user(c, false);
    const q = c.req.query();
    const kind = q.kind ? parseEnum(q.kind, POST_KINDS, 'kind') : undefined;
    const geo = resolveScope(q, user, 'country');
    const languages = parseLanguageList(q.language);
    const cursor = decodeCursor(q.cursor);
    const limit = parseLimit(q.limit, 20, 50);
    const rows = x.repo.listPosts({ kind, cursor, limit, viewerId: user?.id ?? '', geo, languages });
    const base = x.baseUrl(c);
    return x.json(c, {
      ...page(rows, limit, (p) => serializePost(p, base, user?.id ?? '')),
      appliedScope: appliedScope(geo),
    });
  });

  // The caller's own posts, newest first, including the ones that are hidden (with `hidden` / `hiddenReason`), so an
  // author can see what was hidden and why (and appeal by email).
  app.get('/v1/me/posts', (c) => {
    const user = x.user(c, true);
    const q = c.req.query();
    const cursor = decodeCursor(q.cursor);
    const limit = parseLimit(q.limit, 20, 50);
    const rows = x.repo.listPosts({ cursor, limit, viewerId: user.id, ownOf: user.id });
    const base = x.baseUrl(c);
    return x.json(c, page(rows, limit, (p) => serializePost(p, base, user.id)));
  });

  app.get('/v1/posts/:id', (c) => {
    const viewerId = x.user(c, false)?.id ?? '';
    // A hidden post answers 404 to everyone (its author finds it, with the reason, in GET /v1/me/posts).
    return x.json(c, serializePost(visiblePost(c.req.param('id'), viewerId), x.baseUrl(c), viewerId));
  });

  app.post('/v1/posts', async (c) => {
    const user = x.user(c, true);
    const body = await x.readJson(c);
    const kind = parseEnum(body.kind, POST_KINDS, 'kind');
    const language = contentLanguage(body, user.language);
    const rawText =
      body.body === undefined || body.body === null ? '' : parseString(body.body, 'body', { max: 1000 });

    let media: string[] = [];
    if (body.media !== undefined && body.media !== null) {
      if (!Array.isArray(body.media) || body.media.length > MAX_MEDIA) {
        throw invalid(`media phải là mảng tối đa ${MAX_MEDIA} key.`);
      }
      media = body.media.map((k: unknown) => {
        if (typeof k !== 'string' || !MEDIA_KEY_RE.test(k)) throw invalid('media chứa key không hợp lệ.');
        return k;
      });
      if (new Set(media).size !== media.length) throw invalid('media có key trùng lặp.');
    }
    const payload = parsePayload(kind, body.payload);
    if (rawText === '' && media.length === 0 && payload === null) {
      throw invalid('Bài viết không được để trống.');
    }

    // Rate limit BEFORE the expensive work (text filter, database checks, catalog lookups): an over-limit request
    // costs almost nothing, and an attempt the filter rejects still counts (CS-03).
    x.rateLimit('posts', user.id);

    const text = cleanUserText(rawText, language, user.country);
    if (text === '' && media.length === 0 && payload === null) {
      throw invalid('Bài viết không được để trống.');
    }

    if (media.length > 0) {
      const found = new Map(x.repo.getMediaMany(media).map((m) => [m.key, m]));
      for (const k of media) {
        const m = found.get(k);
        if (!m || m.status !== 'active') throw invalid('Ảnh không tồn tại, hãy tải lên lại.');
        if (m.user_id !== user.id) throw forbidden('Bạn chỉ có thể dùng ảnh do chính mình tải lên.');
        if (m.post_id !== null) throw invalid('Ảnh này đã được dùng ở một bài viết khác, hãy tải lên lại.');
      }
    }
    // Shared stores / Night Market: only real VALORANT skins.
    if (payload !== null) {
      const offers = (payload as { offers?: { skinUuid: string }[] }).offers ?? [];
      for (const [i, o] of offers.entries()) await x.assertContent('skin', o.skinUuid, `payload.offers[${i}].skinUuid`);
    }

    const id = crypto.randomUUID();
    x.repo.insertPost({
      id,
      user_id: user.id,
      kind,
      body: text,
      media: JSON.stringify(media),
      payload: payload === null ? null : JSON.stringify(payload),
      hidden: 0,
      created_at: x.now(),
      country: user.country,
      region: user.region,
      language,
    });
    return x.json(c, serializePost(x.repo.getPost(id, user.id)!, x.baseUrl(c), user.id));
  });

  app.delete('/v1/posts/:id', async (c) => {
    const user = x.user(c, true);
    const id = c.req.param('id').toLowerCase();
    const p = isUuid(id) ? x.repo.getPost(id, user.id) : null;
    if (!p) throw notFound('Không tìm thấy bài viết.');
    if (p.user_id !== user.id) throw forbidden('Bạn chỉ có thể xóa bài viết của chính mình.');
    x.repo.deletePost(id);
    // Its images go with it (files and rows), including quarantined copies.
    await x.deleteMedia(postMediaKeys(p.media));
    return x.noContent(c);
  });

  // ---- likes -------------------------------------------------------------------

  const like = (liked: boolean) => (c: Context) => {
    const user = x.user(c, true);
    const p = visiblePost(c.req.param('id') ?? '', user.id);
    x.rateLimit('likes', user.id);
    x.repo.setLike(p.id, user.id, liked, x.now());
    return x.json(c, { likes: x.repo.likeCount(p.id), liked });
  };
  app.put('/v1/posts/:id/like', like(true));
  app.delete('/v1/posts/:id/like', like(false));

  // ---- comments ------------------------------------------------------------------

  app.get('/v1/posts/:id/comments', (c) => {
    const viewerId = x.user(c, false)?.id ?? '';
    const p = visiblePost(c.req.param('id'), viewerId);
    const q = c.req.query();
    const cursor = decodeCursor(q.cursor);
    const limit = parseLimit(q.limit, 20, 50);
    return x.json(c, page(x.repo.listComments({ postId: p.id, cursor, limit }), limit, serializeComment));
  });

  app.post('/v1/posts/:id/comments', async (c) => {
    const user = x.user(c, true);
    const p = visiblePost(c.req.param('id'), user.id);
    const body = await x.readJson(c);
    const language = contentLanguage(body, user.language);
    const rawText = parseString(body.body, 'body', { min: 1, max: 500 });
    x.rateLimit('comments', user.id); // before the text filter (CS-03)
    const text = cleanUserText(rawText, language, user.country);
    if (text === '') throw invalid('body không được để trống.');
    const id = crypto.randomUUID();
    x.repo.insertComment({
      id,
      post_id: p.id,
      user_id: user.id,
      body: text,
      hidden: 0,
      created_at: x.now(),
      country: user.country,
      region: user.region,
      language,
    });
    return x.json(c, serializeComment(x.repo.getComment(id)!));
  });

  app.delete('/v1/comments/:id', (c) => {
    const user = x.user(c, true);
    const id = c.req.param('id').toLowerCase();
    const cm = isUuid(id) ? x.repo.getComment(id) : null;
    if (!cm) throw notFound('Không tìm thấy bình luận.');
    if (cm.user_id !== user.id) throw forbidden('Bạn chỉ có thể xóa bình luận của chính mình.');
    x.repo.deleteComment(id);
    return x.noContent(c);
  });

  // ---- reports ---------------------------------------------------------------------

  app.post('/v1/reports', async (c) => {
    const user = x.user(c, true);
    const body = await x.readJson(c);
    const type = parseEnum(body.targetType, REPORT_TARGETS, 'targetType');
    const targetId = parseUuid(body.targetId, 'targetId');
    const reason = parseString(body.reason, 'reason', { min: 1, max: 200 });
    x.rateLimit('reports', user.id);
    const owner = x.repo.reportTargetOwner(type, targetId);
    if (owner === null) throw notFound('Không tìm thấy nội dung cần báo cáo.');
    // Self-reports are accepted but not counted. The answer is always the same 204: the reporter
    // learns nothing about other reporters, whether their report counted, or whether it hid the content.
    if (owner !== user.id) {
      const out = x.repo.addReport(
        { type, targetId, reporterId: user.id, reason, now: x.now() },
        REPORT_HIDE_THRESHOLD,
        REPORT_MIN_ACCOUNT_AGE_MS,
      );
      if (out.newlyHidden && type === 'post') {
        // Hidden posts leave public serving; their files are kept privately for moderators for 30 days.
        const post = x.repo.getPost(targetId, '');
        if (post) await x.quarantineMedia(postMediaKeys(post.media));
      }
    }
    return x.noContent(c);
  });
}
