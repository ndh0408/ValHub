import type { Context, Hono } from 'hono';
import { author, iso, type Ctx } from '../context.js';
import { decodeCursor, page } from '../cursor.js';
import type { ReviewView } from '../db/repo.js';
import { forbidden, invalid, notFound } from '../errors.js';
import { cleanUserText } from '../moderation/filter.js';
import { isUuid, parseEnum, parseInt, parseLimit, parseString, parseUuid } from '../validate.js';
import { ratingAvg } from './skins.js';

export function registerReviews(app: Hono, x: Ctx): void {
  const serialize = (r: ReviewView, viewerId: string) => ({
    id: r.id,
    skinUuid: r.skin_uuid,
    author: author(r),
    rating: r.rating,
    body: r.body,
    likes: r.like_count,
    liked: r.liked === 1,
    createdAt: iso(r.created_at),
    updatedAt: iso(r.updated_at),
    mine: r.user_id === viewerId,
  });

  /** Visible review by path id, or 404. */
  const visibleReview = (c: Context, viewerId: string): ReviewView => {
    const id = (c.req.param('id') ?? '').toLowerCase();
    const r = isUuid(id) ? x.repo.getReview(id, viewerId) : null;
    if (!r || r.hidden) throw notFound('Không tìm thấy đánh giá.');
    return r;
  };

  app.put('/v1/skins/:skinUuid/review', async (c) => {
    const user = x.user(c, true);
    const skinUuid = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    const body = await x.readJson(c);
    const weaponUuid = parseUuid(body.weaponUuid, 'weaponUuid');
    const rating = parseInt(body.rating, 1, 5, 'rating');
    const text =
      body.body === undefined || body.body === null ? '' : cleanUserText(parseString(body.body, 'body', { max: 500 }));
    x.rateLimit('reviews', user.id);
    const id = x.repo.upsertReview({ userId: user.id, skinUuid, weaponUuid, rating, body: text, now: x.now() });
    return x.json(c, serialize(x.repo.getReview(id, user.id)!, user.id));
  });

  app.delete('/v1/skins/:skinUuid/review', (c) => {
    const user = x.user(c, true);
    const skinUuid = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    x.repo.deleteUserReview(user.id, skinUuid);
    return x.noContent(c);
  });

  app.get('/v1/skins/:skinUuid/reviews', (c) => {
    const viewerId = x.user(c, false)?.id ?? '';
    const skinUuid = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    const q = c.req.query();
    const sort = q.sort ? parseEnum(q.sort, ['new', 'top'] as const, 'sort') : 'new';
    const cursor = decodeCursor(q.cursor);
    if (cursor && (sort === 'top') !== (cursor.likes !== undefined)) throw invalid('cursor không hợp lệ.');
    const limit = parseLimit(q.limit, 20, 50);
    const rows = x.repo.listReviews({ skinUuid, sort, cursor, limit, viewerId });
    return x.json(
      c,
      page(
        rows,
        limit,
        (r) => serialize(r, viewerId),
        sort === 'top' ? (r) => r.like_count : undefined,
      ),
    );
  });

  app.get('/v1/skins/:skinUuid/summary', (c) => {
    const user = x.user(c, false);
    const skinUuid = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    const stats = x.repo.ratingStats([skinUuid]).get(skinUuid);
    // The author always sees their own review (even if hidden by reports).
    const mine = user ? x.repo.getUserReview(user.id, skinUuid) : null;
    return x.json(c, {
      skinUuid,
      weaponUuid: x.repo.skinWeapon(skinUuid),
      votes: x.repo.voteCounts([skinUuid]).get(skinUuid) ?? 0,
      voted: user ? x.repo.userVotes(user.id, [skinUuid]).has(skinUuid) : false,
      ratingAvg: ratingAvg(stats),
      ratingCount: stats?.count ?? 0,
      distribution: x.repo.ratingDistribution(skinUuid),
      reviewCount: stats?.reviewCount ?? 0,
      myReview: mine && user ? serialize(mine, user.id) : null,
    });
  });

  const like = (liked: boolean) => (c: Context) => {
    const user = x.user(c, true);
    const r = visibleReview(c, user.id);
    if (r.user_id === user.id) throw forbidden('Bạn không thể đánh dấu hữu ích cho đánh giá của chính mình.');
    x.rateLimit('likes', user.id);
    return x.json(c, { likes: x.repo.setReviewLike(r.id, user.id, liked, x.now()), liked });
  };
  app.put('/v1/reviews/:id/like', like(true));
  app.delete('/v1/reviews/:id/like', like(false));

  app.delete('/v1/reviews/:id', (c) => {
    const user = x.user(c, true);
    const id = c.req.param('id').toLowerCase();
    const r = isUuid(id) ? x.repo.getReview(id, user.id) : null;
    if (!r) throw notFound('Không tìm thấy đánh giá.');
    if (r.user_id !== user.id) throw forbidden('Bạn chỉ có thể xóa đánh giá của chính mình.');
    x.repo.deleteReview(id);
    return x.noContent(c);
  });
}
