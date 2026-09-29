import type { Hono } from 'hono';
import type { Ctx } from '../context.js';
import { randomHex } from '../crypto.js';
import { invalid, notFound } from '../errors.js';
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

    const bytes = await readLimited(c.req.raw.body, MAX_MEDIA_BYTES);
    if (bytes.length === 0) throw invalid('Không có dữ liệu ảnh.');
    const sniffed = sniffImage(bytes);
    if (sniffed === null || sniffed !== declared) {
      throw invalid('Dữ liệu không phải ảnh hợp lệ hoặc không khớp content-type.');
    }
    const key = `u/${user.id}/${randomHex(16)}.${sniffed}`;
    await x.deps.media.put(key, bytes);
    x.repo.insertMedia({
      key,
      user_id: user.id,
      content_type: CONTENT_TYPES[sniffed],
      size: bytes.length,
      created_at: x.now(),
    });
    return x.json(c, { key, url: x.mediaUrl(x.baseUrl(c), key) });
  });

  app.get('/v1/media/:key{.+}', async (c) => {
    const key = c.req.param('key');
    if (!MEDIA_KEY_RE.test(key)) throw notFound('Không tìm thấy ảnh.');
    const etag = `"${key.slice(key.lastIndexOf('/') + 1)}"`;
    const cacheHeaders = {
      'cache-control': 'public, max-age=31536000, immutable',
      etag,
      'x-content-type-options': 'nosniff',
    };
    if (c.req.header('if-none-match') === etag) return c.body(null, 304, cacheHeaders);
    const bytes = await x.deps.media.get(key);
    if (!bytes) throw notFound('Không tìm thấy ảnh.');
    const ext = key.slice(key.lastIndexOf('.') + 1) as ImageExt;
    return c.body(bytes as Uint8Array<ArrayBuffer>, 200, {
      ...cacheHeaders,
      'content-type': CONTENT_TYPES[ext],
      'content-length': String(bytes.length),
    });
  });
}
