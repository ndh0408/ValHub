import type { Hono } from 'hono';
import { buildExport, deleteAccount } from '../account.js';
import type { Ctx } from '../context.js';
import { ApiError } from '../errors.js';

/** Data rights: erasure (`DELETE /v1/me`) and export (`GET /v1/me/export`). */
export function registerAccount(app: Hono, x: Ctx): void {
  app.get('/v1/me/export', (c) => {
    const user = x.user(c, true);
    x.rateLimit('accountExport', user.id);
    const data = x.repo.accountData(user.id);
    if (!data) throw new ApiError('unauthorized', 'Tài khoản không tồn tại.');
    const body = JSON.stringify(buildExport(data, x.baseUrl(c), x.now()), null, 2);
    return c.body(body, 200, {
      'content-type': 'application/json; charset=utf-8',
      'content-disposition': 'attachment; filename="valvn-community-export.json"',
      'cache-control': 'no-store',
    });
  });

  app.delete('/v1/me', async (c) => {
    const user = x.user(c, true);
    x.rateLimit('accountDelete', user.id);
    await deleteAccount(x.mediaDeps, user.id);
    return c.body(null, 204, { 'cache-control': 'no-store' });
  });
}
