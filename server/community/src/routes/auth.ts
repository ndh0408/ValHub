import type { Hono } from 'hono';
import { authorFromUser, iso, type Ctx } from '../context.js';
import { hashUserId, SESSION_TTL_SECONDS, signSession } from '../crypto.js';
import { ApiError } from '../errors.js';
import type { RiotIdentity } from '../riot.js';
import {
  parseOptional,
  parseRankTier,
  parseRegion,
  parseString,
  parseUuid,
  type Region,
} from '../validate.js';

export function registerAuth(app: Hono, x: Ctx): void {
  app.post('/v1/auth/riot', async (c) => {
    const ip = x.clientIpHash(c);
    if (ip) x.rateLimit('authIp', ip);

    const body = await x.readJson(c);
    const accessToken = parseString(body.accessToken, 'accessToken', { min: 1, max: 8192 });
    const region = parseRegion(body.region);
    const cardId = parseOptional(body, 'cardId', (v) => parseUuid(v, 'cardId'));
    const rankTier = parseOptional(body, 'rankTier', parseRankTier);

    let identity: RiotIdentity;
    try {
      identity = await x.deps.riotUserinfo(accessToken);
    } catch {
      // Network failure / timeout talking to Riot (not a token rejection).
      throw new ApiError('server_error', 'Không kết nối được tới máy chủ Riot.');
    }
    if (!identity.ok) throw new ApiError('riot_rejected', 'Riot từ chối phiên đăng nhập. Hãy đăng nhập lại.');

    const now = x.now();
    const user = x.repo.upsertUser(
      {
        id: hashUserId(x.deps.config.pepper, identity.puuid),
        gameName: identity.gameName,
        tagLine: identity.tagLine,
        region,
        cardId,
        rankTier,
      },
      now,
    );

    const iat = Math.floor(now / 1000);
    const exp = iat + SESSION_TTL_SECONDS;
    const token = signSession(x.deps.config.sessionSecret, {
      sub: user.id,
      name: user.game_name,
      tag: user.tag_line,
      iat,
      exp,
    });
    return x.json(c, { token, expiresAt: iso(exp * 1000), user: authorFromUser(user) });
  });

  app.get('/v1/me', (c) => x.json(c, authorFromUser(x.user(c, true))));

  app.patch('/v1/me', async (c) => {
    const user = x.user(c, true);
    const body = await x.readJson(c);
    const cardId = parseOptional(body, 'cardId', (v) => parseUuid(v, 'cardId'));
    const rankTier = parseOptional(body, 'rankTier', parseRankTier);
    const regionRaw = parseOptional(body, 'region', parseRegion);
    if (regionRaw === null) throw new ApiError('invalid_input', 'region không được để trống.');
    const region: Region | undefined = regionRaw;
    const updated = x.repo.updateUser(user.id, { cardId, rankTier, region }, x.now());
    if (!updated) throw new ApiError('unauthorized', 'Tài khoản không tồn tại.');
    return x.json(c, authorFromUser(updated));
  });
}
