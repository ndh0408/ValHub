import type { Context, Hono } from 'hono';
import { author, iso, origin, ownHidden, type Ctx } from '../context.js';
import { decodeCursor, page } from '../cursor.js';
import type { ReviewView } from '../db/repo.js';
import { forbidden, invalid, notFound, reasonError } from '../errors.js';
import { contentLanguage, parseLanguageList } from '../geo/languages.js';
import { appliedScope, resolveScope } from '../geo/scope.js';
import { cleanUserText } from '../moderation/filter.js';
import { isUuid, parseEnum, parseInt, parseLimit, parseString, parseUuid } from '../validate.js';
import { ratingAvg } from './skins.js';
import { hashUserId } from '../crypto.js';

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
    ownershipVerifiedAt: r.ownership_verified_at === null ? null : iso(r.ownership_verified_at),
    ...origin(r),
    // Only the author is told whether (and why) their review is hidden.
    ...(r.user_id === viewerId ? ownHidden(r) : {}),
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
    const language = contentLanguage(body, user.language);
    const rawText =
      body.body === undefined || body.body === null ? '' : parseString(body.body, 'body', { max: 500 });
    // Rate limit BEFORE the catalog lookups and the text filter (CS-03).
    x.rateLimit('reviews', user.id);
    await x.assertContent('skin', skinUuid, 'skinUuid');
    await x.assertContent('weapon', weaponUuid, 'weaponUuid');
    const text = cleanUserText(rawText, language, user.country);
    // One review per account per skin, whatever uuid the client uses: stored under the base skin uuid with the
    // catalog's weapon (see PUT vote).
    const canon = x.canonSkin(skinUuid);
    const accessToken = parseString(body.accessToken, 'accessToken', { min: 1, max: 8192 });
    // The Community bearer identifies the author. The fresh Riot token must
    // resolve to the SAME author, then inventory is queried with that subject.
    // Client PUUID/owned flags have no authority.
    let identity;
    try { identity = await x.deps.riotUserinfo(accessToken); }
    catch { throw reasonError('riot_unavailable', 'riot_unavailable'); }
    if (!identity.ok) throw reasonError(identity.reason === 'unavailable' ? 'riot_unavailable' : 'riot_rejected', identity.reason === 'unavailable' ? 'riot_unavailable' : 'riot_rejected');
    if (hashUserId(x.deps.config.pepper, identity.puuid) !== user.id) throw forbidden();
    let ownership;
    try {
      ownership = await x.deps.riotOwnership?.({accessToken, puuid: identity.puuid, region: user.region,
        skinUuid: canon?.skinUuid ?? skinUuid, resolveSkin: (id) => x.canonSkin(id)});
    } catch { ownership = 'unavailable'; }
    if (ownership === 'rejected') throw reasonError('riot_rejected', 'riot_rejected');
    if (ownership === 'not_owned') throw reasonError('forbidden', 'skin_not_owned');
    if (ownership !== 'owned') throw reasonError('riot_unavailable', 'ownership_unavailable');
    x.assertCurrentUser(c);
    const id = x.repo.upsertReview({
      userId: user.id,
      skinUuid: canon?.skinUuid ?? skinUuid,
      weaponUuid: canon?.weaponUuid ?? weaponUuid,
      authoritativeWeapon: canon !== null,
      rating,
      body: text,
      now: x.now(),
      ownershipVerifiedAt: x.now(),
      // The reviewer's country / region at review time (kept when the review is edited).
      origin: { country: user.country, region: user.region },
      language,
      // An edit keeps the stored text language unless the client sends one.
      updateLanguage: body.language !== undefined && body.language !== null,
    });
    return x.json(c, serialize(x.repo.getReview(id, user.id)!, user.id));
  });

  app.delete('/v1/skins/:skinUuid/review', (c) => {
    const user = x.user(c, true);
    const skinUuid = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    const canonical = x.canonSkin(skinUuid)?.skinUuid ?? skinUuid;
    x.repo.deleteUserReview(user.id, canonical);
    if (canonical !== skinUuid) x.repo.deleteUserReview(user.id, skinUuid); // stored before canonicalisation
    return x.noContent(c);
  });

  app.get('/v1/skins/:skinUuid/reviews', (c) => {
    const user = x.user(c, false);
    const viewerId = user?.id ?? '';
    const asked = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    const skinUuid = x.canonSkin(asked)?.skinUuid ?? asked;
    const q = c.req.query();
    const sort = q.sort ? parseEnum(q.sort, ['new', 'top'] as const, 'sort') : 'new';
    const geo = resolveScope(q, user, 'global');
    const languages = parseLanguageList(q.language);
    const cursor = decodeCursor(q.cursor);
    if (cursor && (sort === 'top') !== (cursor.likes !== undefined)) throw reasonError('invalid_input', 'cursor_invalid');
    const limit = parseLimit(q.limit, 20, 50);
    const rows = x.repo.listReviews({ skinUuid, sort, cursor, limit, viewerId, geo, languages });
    return x.json(c, {
      ...page(
        rows,
        limit,
        (r) => serialize(r, viewerId),
        sort === 'top' ? (r) => r.like_count : undefined,
      ),
      appliedScope: appliedScope(geo),
    });
  });

  app.get('/v1/skins/:skinUuid/summary', (c) => {
    const user = x.user(c, false);
    const asked = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    const skinUuid = x.canonSkin(asked)?.skinUuid ?? asked;
    const geo = resolveScope(c.req.query(), user, 'global');
    const stats = x.repo.ratingStats([skinUuid], undefined, geo).get(skinUuid);
    // The author always sees their own review (even if hidden by reports), whatever the scope.
    const mine = user ? x.repo.getUserReview(user.id, skinUuid) : null;
    return x.json(c, {
      skinUuid: asked,
      weaponUuid: x.repo.skinWeapon(skinUuid),
      votes: x.repo.voteCounts([skinUuid], undefined, geo).get(skinUuid) ?? 0,
      voted: user ? x.repo.userVotes(user.id, [skinUuid]).has(skinUuid) : false,
      ratingAvg: ratingAvg(stats),
      ratingCount: stats?.count ?? 0,
      distribution: x.repo.ratingDistribution(skinUuid, geo),
      reviewCount: stats?.reviewCount ?? 0,
      myReview: mine && user ? serialize(mine, user.id) : null,
      appliedScope: appliedScope(geo),
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
