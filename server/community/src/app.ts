import { Hono } from 'hono';
import { bodyLimit } from 'hono/body-limit';
import { Ctx, type AppDeps } from './context.js';
import { ApiError, errorBody, invalid } from './errors.js';
import { registerAuth } from './routes/auth.js';
import { registerLfg } from './routes/lfg.js';
import { registerMedia } from './routes/media.js';
import { registerPosts } from './routes/posts.js';
import { registerReviews } from './routes/reviews.js';
import { registerSkins } from './routes/skins.js';

export type { AppDeps } from './context.js';

const MAX_JSON_BYTES = 64 * 1024;

const jsonBodyLimit = bodyLimit({
  maxSize: MAX_JSON_BYTES,
  onError: () => {
    throw invalid('Nội dung yêu cầu quá lớn.');
  },
});

/** Builds the HTTP app. Everything external (DB, disk, Riot, clock) comes from `deps`. */
export function createApp(deps: AppDeps): Hono {
  const x = new Ctx(deps);
  const logError = deps.logError ?? ((msg: string) => console.error(msg));
  const app = new Hono();

  app.use('*', async (c, next) => {
    if (c.req.method === 'POST' && c.req.path === '/v1/media') return next();
    return jsonBodyLimit(c, next);
  });

  app.options('*', (c) =>
    c.body(null, 204, { allow: 'GET, HEAD, POST, PUT, PATCH, DELETE, OPTIONS' }),
  );

  app.get('/healthz', (c) => {
    let ok = false;
    try {
      ok = deps.repo.ping();
    } catch {
      ok = false;
    }
    return x.json(c, { ok }, ok ? 200 : (500 as 200));
  });

  registerAuth(app, x);
  registerLfg(app, x);
  registerSkins(app, x);
  registerReviews(app, x);
  registerPosts(app, x);
  registerMedia(app, x);

  app.notFound((c) => {
    const err = new ApiError('not_found', 'Không tìm thấy đường dẫn.');
    return c.body(JSON.stringify(errorBody(err)), 404, {
      'content-type': 'application/json; charset=utf-8',
    });
  });

  app.onError((e, c) => {
    let err: ApiError;
    if (e instanceof ApiError) {
      err = e;
    } else {
      // Only the error name/message is logged — never headers, bodies or tokens.
      logError(`[${c.req.method} ${c.req.routePath}] ${e.name}: ${e.message}`);
      err = new ApiError('server_error', 'Máy chủ gặp lỗi, vui lòng thử lại sau.');
    }
    const headers: Record<string, string> = { 'content-type': 'application/json; charset=utf-8' };
    if (err.retryAfter !== undefined) headers['retry-after'] = String(err.retryAfter);
    return c.body(JSON.stringify(errorBody(err)), err.status as 400, headers);
  });

  return app;
}
