import type { Hono } from 'hono';
import { author, iso, origin, type Ctx } from '../context.js';
import { decodeCursor, page } from '../cursor.js';
import type { AuthorCols, SkinCommentRow } from '../db/repo.js';
import { forbidden, invalid, notFound } from '../errors.js';
import { contentLanguage } from '../geo/languages.js';
import { commitCreate } from '../idempotency.js';
import { cleanUserText } from '../moderation/filter.js';
import { parseLimit, parseString, parseUuid } from '../validate.js';

/** Public discussion never supplies or changes a star rating. */
export function registerSkinComments(app: Hono, x: Ctx): void {
  const serialize = (r: SkinCommentRow & AuthorCols) => ({
    id: r.id, skinUuid: r.skin_uuid, author: author(r), body: r.body,
    createdAt: iso(r.created_at), ...origin(r),
  });

  app.get('/v1/skins/:skinUuid/comments', async (c) => {
    x.user(c, false); // Missing session is public; invalid/expired session is rejected.
    const asked = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    const q = c.req.query();
    const cursor = decodeCursor(q.cursor);
    const limit = parseLimit(q.limit, 20, 50);
    await x.assertContent('skin', asked, 'skinUuid');
    const skinUuid = x.canonSkin(asked)?.skinUuid ?? asked;
    return x.json(c, page(x.repo.listSkinComments({ skinUuid, cursor, limit }), limit, serialize));
  });

  app.post('/v1/skins/:skinUuid/comments', async (c) => {
    const user = x.user(c, true);
    const asked = parseUuid(c.req.param('skinUuid'), 'skinUuid');
    const body = await x.readJson(c);
    const language = contentLanguage(body, user.language);
    const rawText = parseString(body.body, 'body', { min: 1, max: 500 });
    // Shared with post comments: no way to double the allowance across surfaces.
    x.rateLimit('comments', user.id);
    await x.assertContent('skin', asked, 'skinUuid');
    const text = cleanUserText(rawText, language, user.country);
    if (!text) throw invalid('body không được để trống.', 'field_empty', { field: 'body' });
    return commitCreate(c, x, () => {
      const id = crypto.randomUUID();
      x.repo.insertSkinComment({
        id, skin_uuid: x.canonSkin(asked)?.skinUuid ?? asked, user_id: user.id,
        body: text, hidden: 0, created_at: x.now(), country: user.country,
        region: user.region, language,
      });
      return serialize(x.repo.getSkinComment(id)!);
    });
  });

  app.delete('/v1/skin-comments/:id', (c) => {
    const user = x.user(c, true);
    const id = parseUuid(c.req.param('id'), 'id');
    const comment = x.repo.getSkinComment(id);
    if (!comment) throw notFound('Không tìm thấy bình luận.');
    if (comment.user_id !== user.id) throw forbidden('Bạn chỉ có thể xóa bình luận của chính mình.');
    x.repo.deleteTarget('skin_comment', id); // Delete its reports in the same transaction.
    return x.noContent(c);
  });
}
