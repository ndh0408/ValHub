import { commitCreate } from '../idempotency.js';
import type { Hono } from 'hono';
import type { Ctx } from '../context.js';
import { randomHex } from '../crypto.js';
import { ApiError, invalid, notFound, reasonError } from '../errors.js';
import { ImageError } from '../imaging.js';
import { decodeImage } from '../image-decoder.js';
import { CONTENT_TYPES, MAX_MEDIA_BYTES, MEDIA_KEY_RE, sniffImage, type ImageExt } from '../media.js';

const ALLOWED: Record<string, ImageExt> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

const tooLarge = () => reasonError('invalid_input', 'media_too_large', { maxMb: 2 });

/** Reads a request body, aborting as soon as it exceeds `max` bytes. */
async function readLimited(body: ReadableStream<Uint8Array> | null, max: number): Promise<Uint8Array> {
  if (!body) return new Uint8Array(0);
  const reader = body.getReader();
  const chunks: Uint8Array[] = [];
  let total = 0;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    total += value.byteLength;
    if (total > max) {
      await reader.cancel().catch(() => {});
      throw tooLarge();
    }
    chunks.push(value);
  }
  const out = new Uint8Array(total);
  let off = 0;
  for (const ch of chunks) {
    out.set(ch, off);
    off += ch.byteLength;
  }
  return out;
}

const mb = (bytes: number) => Math.round(bytes / (1024 * 1024));

export function registerMedia(app: Hono, x: Ctx): void {
  app.post('/v1/media', async (c) => {
    // Auth, content-type and rate limit are checked before the body is read.
    const user = x.user(c, true);
    const ct = (c.req.header('content-type') ?? '').split(';')[0]!.trim().toLowerCase();
    const declared = ALLOWED[ct];
    if (!declared) throw invalid('Chỉ hỗ trợ ảnh JPEG, PNG hoặc WebP tĩnh.', 'media_type_unsupported');
    const len = c.req.header('content-length');
    if (len !== undefined && Number(len) > MAX_MEDIA_BYTES) throw tooLarge();
    x.rateLimit('media', user.id);

    const raw = await readLimited(c.req.raw.body, MAX_MEDIA_BYTES);
    if (raw.length === 0) throw reasonError('invalid_input', 'media_empty');
    const sniffed = sniffImage(raw);
    if (sniffed === null || sniffed !== declared) {
      throw reasonError('invalid_input', 'media_invalid');
    }

    // Strip EXIF / GPS and every other kind of metadata; refuse malformed or huge images.
    let clean;
    try {
      clean = await decodeImage(raw);
    } catch (e) {
      if (e instanceof ImageError) throw reasonError('invalid_input', 'media_invalid');
      throw e;
    }

    // Storage limits: per user (their problem: 400) and total (ours: 507).
    x.assertCurrentUser(c);
    const { mediaUserQuotaBytes: userQuota, mediaMaxTotalBytes: totalCap } = x.tuning;
    // Same reason codes as the transactional check in the repo, so the app shows the right message.
    if (x.repo.mediaBytes(user.id) + clean.bytes.length > userQuota) {
      throw reasonError('invalid_input', 'quota_exceeded', { maxMb: mb(userQuota) });
    }
    if (x.repo.mediaBytes() + clean.bytes.length > totalCap) {
      throw reasonError('storage_full', 'storage_full');
    }

    const key = `u/${user.id}/${randomHex(16)}.${clean.ext}`;
    await x.deps.media.put(key, clean.bytes);
    try {
      const response = commitCreate(c, x, () => {
        x.repo.insertMedia({
          key,
          user_id: user.id,
          content_type: CONTENT_TYPES[clean.ext],
          size: clean.bytes.length,
          created_at: x.now(),
        }, { user: userQuota, total: totalCap });
        return { key, url: x.mediaUrl(x.baseUrl(c), key) };
      });
      if (!x.repo.getMedia(key)) await x.deps.media.delete(key);
      return response;
    } catch (e) {
      await x.deps.media.delete(key).catch(() => {});
      throw e;
    }
  });

  app.get('/v1/media/:key{.+}', async (c) => {
    const key = c.req.param('key');
    if (!MEDIA_KEY_RE.test(key)) throw notFound('Không tìm thấy ảnh.');
    // Only files with an active row are served: deleted, quarantined (hidden by reports) and stray
    // files are 404 even if the bytes are still on disk.
    const row = x.repo.getMedia(key);
    if (!row || row.status !== 'active') throw notFound('Không tìm thấy ảnh.');
    const etag = `"${key.slice(key.lastIndexOf('/') + 1)}"`;
    const edge = x.tuning.mediaEdgeCacheSeconds;
    const headers = {
      // Devices keep the file for a year; Cloudflare's edge must NOT (it caches by extension and would keep
      // serving deleted / quarantined images): Cloudflare-CDN-Cache-Control overrides Cache-Control there.
      'cache-control': 'public, max-age=31536000, immutable',
      'cloudflare-cdn-cache-control': edge > 0 ? `max-age=${edge}` : 'no-store',
      etag,
      'x-content-type-options': 'nosniff',
      'content-disposition': 'inline',
      // A picture needs no scripts, styles, frames or network: lock everything down.
      'content-security-policy': "default-src 'none'; img-src 'self' data:; sandbox",
      'cross-origin-resource-policy': 'cross-origin',
      'referrer-policy': 'no-referrer',
    };
    if (c.req.header('if-none-match') === etag) return c.body(null, 304, headers);
    const bytes = await x.deps.media.get(key);
    if (!bytes) throw notFound('Không tìm thấy ảnh.');
    const ext = key.slice(key.lastIndexOf('.') + 1) as ImageExt;
    return c.body(bytes as Uint8Array<ArrayBuffer>, 200, {
      ...headers,
      'content-type': CONTENT_TYPES[ext],
      'content-length': String(bytes.length),
    });
  });
}
