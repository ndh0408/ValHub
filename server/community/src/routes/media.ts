import type { Hono } from 'hono';
import type { Ctx } from '../context.js';
import { randomHex } from '../crypto.js';
import { ApiError, invalid, notFound } from '../errors.js';
import { ImageError, sanitizeImage } from '../imaging.js';
import { CONTENT_TYPES, MAX_MEDIA_BYTES, MEDIA_KEY_RE, sniffImage, type ImageExt } from '../media.js';

const ALLOWED: Record<string, ImageExt> = {
  'image/jpeg': 'jpg',
  'image/png': 'png',
  'image/webp': 'webp',
};

const tooLarge = () => invalid('Ảnh tối đa 2 MB.');

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
    if (!declared) throw invalid('Chỉ hỗ trợ ảnh JPEG, PNG hoặc WebP.');
    const len = c.req.header('content-length');
    if (len !== undefined && Number(len) > MAX_MEDIA_BYTES) throw tooLarge();
    x.rateLimit('media', user.id);

    const raw = await readLimited(c.req.raw.body, MAX_MEDIA_BYTES);
    if (raw.length === 0) throw invalid('Không có dữ liệu ảnh.');
    const sniffed = sniffImage(raw);
    if (sniffed === null || sniffed !== declared) {
      throw invalid('Dữ liệu không phải ảnh hợp lệ hoặc không khớp content-type.');
    }

    // Strip EXIF / GPS and every other kind of metadata; refuse malformed or huge images.
    let clean;
    try {
      clean = sanitizeImage(raw);
    } catch (e) {
      if (e instanceof ImageError) throw invalid('Không đọc được ảnh (tệp hỏng hoặc kích thước quá lớn).');
      throw e;
    }

    // Storage limits: per user (their problem: 400) and total (ours: 507).
    const { mediaUserQuotaBytes: userQuota, mediaMaxTotalBytes: totalCap } = x.tuning;
    if (x.repo.mediaBytes(user.id) + clean.bytes.length > userQuota) {
      throw invalid(
        `Bạn đã dùng hết dung lượng ảnh (${mb(userQuota)} MB). Hãy xóa bớt bài viết có ảnh rồi thử lại.`,
      );
    }
    if (x.repo.mediaBytes() + clean.bytes.length > totalCap) {
      throw new ApiError('storage_full', 'Kho ảnh của máy chủ đã đầy, vui lòng thử lại sau.');
    }

    const key = `u/${user.id}/${randomHex(16)}.${clean.ext}`;
    await x.deps.media.put(key, clean.bytes);
    x.repo.insertMedia({
      key,
      user_id: user.id,
      content_type: CONTENT_TYPES[clean.ext],
      size: clean.bytes.length,
      created_at: x.now(),
    });
    return x.json(c, { key, url: x.mediaUrl(x.baseUrl(c), key) });
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
