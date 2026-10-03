import type { Hono } from 'hono';
import { AUTH_ATTEMPTS, AUTH_FAILURES, authorFromUser, iso, suspendedError, type Ctx } from '../context.js';
import { hashUserId, SESSION_TTL_SECONDS, signSession } from '../crypto.js';
import { ApiError, invalid, reasonError } from '../errors.js';
import { normalizeAlpha2 } from '../geo/countries.js';
import { parseLanguage } from '../geo/languages.js';
import type { RiotIdentity } from '../riot.js';
import {
  parseOptional,
  parseRankTier,
  parseRegion,
  parseString,
  parseUuid,
  type Region,
} from '../validate.js';

/** Policy / consent version label such as "2026-09" or "1.2": short, printable, no spaces. */
function parseConsentVersion(v: unknown): string {
  if (typeof v !== 'string' || !/^[A-Za-z0-9._-]{1,32}$/.test(v)) {
    throw invalid('consentVersion phải gồm 1-32 ký tự chữ, số, . _ -', 'consent_version_invalid');
  }
  return v;
}

export function registerAuth(app: Hono, x: Ctx): void {
  app.post('/v1/auth/riot', async (c) => {
    // Per client address, in memory (never stored): every attempt counts toward a generous limit (shared carrier
    // addresses), and tokens Riot rejects toward a small one (see AUTH_FAILURES).
    const ip = x.clientIpHash(c);
    if (ip) {
      const at = x.now();
      const all = x.anonLimiter.hit(`auth:${ip}`, AUTH_ATTEMPTS.limit, AUTH_ATTEMPTS.windowMs, at);
      const bad = x.anonLimiter.peek(`authFail:${ip}`, AUTH_FAILURES.limit, AUTH_FAILURES.windowMs, at);
      if (!all.ok || !bad.ok) {
        x.stats.inc('auth429');
        const [bucket, limit, retry] = !all.ok
          ? ['authIp', AUTH_ATTEMPTS.limit, all.retryAfterSeconds]
          : ['authFailures', AUTH_FAILURES.limit, bad.retryAfterSeconds];
        throw reasonError(
          'rate_limited',
          'rate_limited',
          { bucket: bucket as string, limit: limit as number, windowSeconds: AUTH_ATTEMPTS.windowMs / 1000 },
          retry as number,
        );
      }
    }

    const body = await x.readJson(c);
    const accessToken = parseString(body.accessToken, 'accessToken', { min: 1, max: 8192 });
    const region = parseRegion(body.region);
    const cardId = parseOptional(body, 'cardId', (v) => parseUuid(v, 'cardId'));
    const rankTier = parseOptional(body, 'rankTier', parseRankTier);
    // App language (v3). Absent (clients before v3) → keep the stored value; null is not allowed.
    const language = parseOptional(body, 'language', (v) => parseLanguage(v, 'language'));
    if (language === null) throw invalid('language không được để trống.', 'field_empty', { field: 'language' });
    // Policy version the user accepted (optional; only version and time are stored, see CS-34).
    const consentVersion = parseOptional(body, 'consentVersion', parseConsentVersion);
    if (consentVersion === null) throw invalid('consentVersion không được để trống.', 'field_empty', { field: 'consentVersion' });

    let identity: RiotIdentity;
    try {
      identity = await x.deps.riotUserinfo(accessToken);
    } catch {
      // Network failure / timeout talking to Riot: not a token rejection.
      identity = { ok: false, reason: 'unavailable' };
    }
    if (!identity.ok) {
      if (identity.reason === 'unavailable') {
        // 429 / 5xx / timeout / HTML from Riot: the token may be fine, so the client keeps its Riot session.
        throw new ApiError(
          'riot_unavailable',
          'Máy chủ Riot đang bận hoặc không phản hồi, vui lòng thử lại sau ít phút.',
          identity.retryAfter,
        );
      }
      if (ip) x.anonLimiter.hit(`authFail:${ip}`, AUTH_FAILURES.limit, AUTH_FAILURES.windowMs, x.now());
      throw new ApiError('riot_rejected', 'Riot từ chối phiên đăng nhập. Hãy đăng nhập lại.');
    }

    const now = x.now();
    const userId = hashUserId(x.deps.config.pepper, identity.puuid);
    // A banned account gets no session (erasing the account and signing in again yields the same id, so the
    // ban outlives the account row). A restricted account may sign in: it can still read.
    const sanction = x.repo.activeSanction(userId, now);
    if (sanction?.kind === 'ban') {
      x.stats.inc('suspended:ban:signin');
      throw suspendedError(sanction);
    }
    const user = x.repo.upsertUser(
      {
        id: userId,
        gameName: identity.gameName,
        tagLine: identity.tagLine,
        region,
        // Country comes only from Riot and is refreshed on every auth (never client-supplied).
        country: normalizeAlpha2(identity.country),
        language,
        cardId,
        rankTier,
        consentVersion,
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
      ep: user.session_epoch,
    });
    return x.json(c, { token, expiresAt: iso(exp * 1000), user: authorFromUser(user) });
  });

  // Ends every session of the caller (all devices): their tokens carry the old epoch. The app signs in again
  // with its Riot session when it needs to. 204 without a body.
  app.post('/v1/auth/logout', (c) => {
    const user = x.user(c, true);
    x.repo.bumpSessionEpoch(user.id);
    return x.noContent(c);
  });

  app.get('/v1/me', (c) => x.json(c, authorFromUser(x.user(c, true))));

  app.patch('/v1/me', async (c) => {
    const user = x.user(c, true);
    const body = await x.readJson(c);
    // `country` is never taken from the client (it comes from Riot at sign-in): silently ignored, like
    // every other unknown field, so a client that sends its whole profile back keeps working.
    const cardId = parseOptional(body, 'cardId', (v) => parseUuid(v, 'cardId'));
    const rankTier = parseOptional(body, 'rankTier', parseRankTier);
    const regionRaw = parseOptional(body, 'region', parseRegion);
    if (regionRaw === null) throw new ApiError('invalid_input', 'region không được để trống.');
    const region: Region | undefined = regionRaw;
    const languageRaw = parseOptional(body, 'language', (v) => parseLanguage(v, 'language'));
    if (languageRaw === null) throw invalid('language không được để trống.', 'field_empty', { field: 'language' });
    x.assertCurrentUser(c);
    const updated = x.repo.updateUser(user.id, { cardId, rankTier, region, language: languageRaw }, x.now());
    if (!updated) throw new ApiError('unauthorized', 'Tài khoản không tồn tại.');
    return x.json(c, authorFromUser(updated));
  });
}
