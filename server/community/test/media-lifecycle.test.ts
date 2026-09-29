import fs from 'node:fs';
import path from 'node:path';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { deleteMedia, quarantineMedia } from '../src/media-service.js';
import { expectError, JPEG, PNG, setup, WEBP, type Env } from './helpers.js';
import { containsAnySecret, makeJpeg, makePng, makeWebp } from './fixtures.js';

const HOUR = 3600_000;

let e: Env;
beforeEach(() => {
  e = setup();
});
afterEach(() => e.close());

const upload = (token: string, bytes: Uint8Array, type = 'image/png') =>
  e.req('POST', '/v1/media', { token, raw: bytes, headers: { 'content-type': type } });

const publicFile = (key: string) => path.join(e.mediaDir, ...key.split('/'));
const quarantineFile = (key: string) => path.join(e.quarantineDir, ...key.split('/'));
const postWith = (token: string, media: string[], body = 'ảnh') =>
  e.req('POST', '/v1/posts', { token, body: { kind: 'text', body, media } });

describe('uploads are sanitised', () => {
  it.each([
    ['image/jpeg', () => makeJpeg({ exif: { orientation: 6, gps: true } })],
    ['image/png', () => makePng()],
    ['image/webp', () => makeWebp({ exif: { orientation: 3 } })],
  ])('%s: EXIF / GPS / text never reach the disk or the response', async (type, make) => {
    const { token } = await e.login('alice');
    const input = make();
    expect(containsAnySecret(input)).not.toBeNull();
    const res = await upload(token, input, type);
    expect(res.status).toBe(200);
    const onDisk = new Uint8Array(fs.readFileSync(publicFile(res.json.key)));
    expect(containsAnySecret(onDisk)).toBeNull();
    const served = await e.req('GET', `/v1/media/${res.json.key}`);
    expect(containsAnySecret(served.bytes)).toBeNull();
    expect(Buffer.from(served.bytes).equals(Buffer.from(onDisk))).toBe(true);
    // The stored size is the sanitised size (that is what the quota counts).
    expect(e.repo.getMedia(res.json.key)).toMatchObject({ size: onDisk.length, status: 'active', post_id: null });
  });

  it('refuses images that are not structurally valid, or too large in pixels', async () => {
    const { token } = await e.login('alice');
    const magicOnly = new Uint8Array([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0, 0, 0, 13, 1, 2, 3]);
    expectError(await upload(token, magicOnly), 400, 'invalid_input');
    expectError(await upload(token, makePng({ ihdrWidth: 30000, ihdrHeight: 30000 })), 400, 'invalid_input');
    expectError(await upload(token, makeJpeg({ width: 20000, height: 20000 }), 'image/jpeg'), 400, 'invalid_input');
    const truncated = makeJpeg();
    expectError(await upload(token, truncated.subarray(0, 30), 'image/jpeg'), 400, 'invalid_input');
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM media').get()).toEqual({ n: 0 });
  });

  it('serves media with hardened headers', async () => {
    const { token } = await e.login('alice');
    const up = await upload(token, PNG);
    const res = await e.req('GET', `/v1/media/${up.json.key}`);
    expect(res.status).toBe(200);
    expect(res.headers.get('content-type')).toBe('image/png');
    expect(res.headers.get('content-disposition')).toBe('inline');
    expect(res.headers.get('x-content-type-options')).toBe('nosniff');
    expect(res.headers.get('content-security-policy')).toContain("default-src 'none'");
    expect(res.headers.get('content-security-policy')).toContain('sandbox');
    expect(res.headers.get('cache-control')).toContain('max-age=31536000');
    expect(res.headers.get('referrer-policy')).toBe('no-referrer');
    // 304s carry the same protections.
    const cached = await e.req('GET', `/v1/media/${up.json.key}`, { headers: { 'if-none-match': res.headers.get('etag')! } });
    expect(cached.status).toBe(304);
    expect(cached.headers.get('content-security-policy')).toContain("default-src 'none'");
  });

  it('only serves files that have an active row (stray files are 404)', async () => {
    const { token, user } = await e.login('alice');
    const up = await upload(token, PNG);
    e.db.prepare('DELETE FROM media WHERE key = ?').run(up.json.key);
    expect(fs.existsSync(publicFile(up.json.key))).toBe(true);
    expectError(await e.req('GET', `/v1/media/${up.json.key}`), 404, 'not_found');
    const stray = `u/${user.id}/${'d'.repeat(32)}.png`;
    await e.media.put(stray, PNG);
    expectError(await e.req('GET', `/v1/media/${stray}`), 404, 'not_found');
  });
});

describe('storage quotas', () => {
  it('per-user quota: refused as invalid_input with a readable message; deleting a post frees space', async () => {
    e.close();
    const size = PNG.length;
    e = setup({ tuning: { mediaUserQuotaBytes: size * 2 + 10 } });
    const { token } = await e.login('alice');
    const other = await e.login('bob');
    const a = await upload(token, PNG);
    const b = await upload(token, PNG);
    expect(a.status).toBe(200);
    expect(b.status).toBe(200);
    const full = await upload(token, PNG);
    expectError(full, 400, 'invalid_input');
    expect(full.json.error.message).toContain('dung lượng ảnh');
    // Other users are not affected by alice's quota.
    expect((await upload(other.token, PNG)).status).toBe(200);
    // Deleting the post that uses an image gives the space back.
    const post = await postWith(token, [a.json.key]);
    expect(post.status).toBe(200);
    expect((await e.req('DELETE', `/v1/posts/${post.json.id}`, { token })).status).toBe(204);
    expect((await upload(token, PNG)).status).toBe(200);
  });

  it('global cap: 507 storage_full', async () => {
    e.close();
    e = setup({ tuning: { mediaMaxTotalBytes: PNG.length * 2 + 10 } });
    const a = await e.login('alice');
    const b = await e.login('bob');
    expect((await upload(a.token, PNG)).status).toBe(200);
    expect((await upload(b.token, PNG)).status).toBe(200);
    const full = await upload(a.token, PNG);
    expectError(full, 507, 'storage_full');
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM media').get()).toEqual({ n: 2 });
    expect(fs.readdirSync(path.join(e.mediaDir, 'u')).length).toBe(2);
  });

  it('counts quarantined files until they are purged', async () => {
    const { token, user } = await e.login('alice');
    const up = await upload(token, PNG);
    await quarantineMedia(e.mediaDeps(), [up.json.key]);
    expect(e.repo.mediaBytes(user.id)).toBe(PNG.length);
  });
});

describe('attaching files to posts', () => {
  it('attaches on post creation; a file cannot be reused by a second post', async () => {
    const { token } = await e.login('alice');
    const up = await upload(token, PNG);
    expect(e.repo.getMedia(up.json.key)!.post_id).toBeNull();
    const p1 = await postWith(token, [up.json.key]);
    expect(p1.status).toBe(200);
    expect(e.repo.getMedia(up.json.key)!.post_id).toBe(p1.json.id);
    expectError(await postWith(token, [up.json.key], 'again'), 400, 'invalid_input');
  });

  it('a failed post (validation) leaves the upload unattached and reusable', async () => {
    const { token } = await e.login('alice');
    const up = await upload(token, PNG);
    expectError(await e.req('POST', '/v1/posts', { token, body: { kind: 'store', media: [up.json.key] } }), 400, 'invalid_input');
    expect(e.repo.getMedia(up.json.key)!.post_id).toBeNull();
    expect((await postWith(token, [up.json.key])).status).toBe(200);
  });

  it('rejects quarantined or foreign files', async () => {
    const a = await e.login('alice');
    const b = await e.login('bob');
    const up = await upload(a.token, PNG);
    expectError(await postWith(b.token, [up.json.key]), 403, 'forbidden');
    await quarantineMedia(e.mediaDeps(), [up.json.key]);
    expectError(await postWith(a.token, [up.json.key]), 400, 'invalid_input');
  });
});

describe('post deleted by its author', () => {
  it('deletes the files and rows (public and quarantined copies), and nobody else’s', async () => {
    const a = await e.login('alice');
    const b = await e.login('bob');
    const k1 = (await upload(a.token, PNG)).json.key;
    const k2 = (await upload(a.token, JPEG, 'image/jpeg')).json.key;
    const kBob = (await upload(b.token, PNG)).json.key;
    const post = await postWith(a.token, [k1, k2]);
    await postWith(b.token, [kBob], 'bob');
    expect(fs.existsSync(publicFile(k1))).toBe(true);

    expect((await e.req('DELETE', `/v1/posts/${post.json.id}`, { token: a.token })).status).toBe(204);
    for (const k of [k1, k2]) {
      expect(fs.existsSync(publicFile(k)), k).toBe(false);
      expect(e.repo.getMedia(k)).toBeNull();
      expectError(await e.req('GET', `/v1/media/${k}`), 404, 'not_found');
    }
    expect(fs.existsSync(publicFile(kBob))).toBe(true);
    expect((await e.req('GET', `/v1/media/${kBob}`)).status).toBe(200);
  });

  it('removes quarantined files of a hidden post the author then deletes', async () => {
    const a = await e.login('alice');
    const reporters = await Promise.all(['r1', 'r2', 'r3'].map((n) => e.login(n)));
    reporters.forEach((r) => e.mature(r.user.id));
    const key = (await upload(a.token, PNG)).json.key;
    const post = await postWith(a.token, [key]);
    for (const r of reporters) {
      await e.req('POST', '/v1/reports', { token: r.token, body: { targetType: 'post', targetId: post.json.id, reason: 'x' } });
    }
    expect(fs.existsSync(quarantineFile(key))).toBe(true);
    expect((await e.req('DELETE', `/v1/posts/${post.json.id}`, { token: a.token })).status).toBe(204);
    expect(fs.existsSync(quarantineFile(key))).toBe(false);
    expect(e.repo.getMedia(key)).toBeNull();
  });
});

describe('content hidden by reports', () => {
  it('moves the files to quarantine and stops serving them (404), keeping them privately', async () => {
    const a = await e.login('alice');
    const reporters = await Promise.all(['r1', 'r2', 'r3'].map((n) => e.login(n)));
    reporters.forEach((r) => e.mature(r.user.id));
    const key = (await upload(a.token, PNG)).json.key;
    const post = await postWith(a.token, [key]);
    const report = (t: string) =>
      e.req('POST', '/v1/reports', { token: t, body: { targetType: 'post', targetId: post.json.id, reason: 'spam' } });

    await report(reporters[0]!.token);
    await report(reporters[1]!.token);
    expect((await e.req('GET', `/v1/media/${key}`)).status).toBe(200); // not hidden yet
    await report(reporters[2]!.token);

    expectError(await e.req('GET', `/v1/media/${key}`), 404, 'not_found');
    expect(fs.existsSync(publicFile(key))).toBe(false);
    expect(fs.existsSync(quarantineFile(key))).toBe(true);
    expect(e.repo.getMedia(key)).toMatchObject({ status: 'quarantined', quarantined_at: e.clock.t });
    // The bytes are intact for moderators, and the post is hidden from lists.
    expect(Buffer.from(fs.readFileSync(quarantineFile(key))).equals(Buffer.from(PNG))).toBe(true);
    expectError(await e.req('GET', `/v1/posts/${post.json.id}`, { token: a.token }), 404, 'not_found');
  });

  it('a moderator can put quarantined files back', async () => {
    const a = await e.login('alice');
    const key = (await upload(a.token, PNG)).json.key;
    await quarantineMedia(e.mediaDeps(), [key]);
    expect((await e.req('GET', `/v1/media/${key}`)).status).toBe(404);
    expect(await e.media.restore(key)).toBe(true);
    e.repo.setMediaActive([key]);
    expect((await e.req('GET', `/v1/media/${key}`)).status).toBe(200);
    expect(await e.media.restore(key)).toBe(false); // nothing left to restore
  });
});

describe('media helpers', () => {
  it('deleteMedia / quarantineMedia tolerate missing files and empty lists', async () => {
    const { token } = await e.login('alice');
    const key = (await upload(token, PNG)).json.key;
    await deleteMedia(e.mediaDeps(), []);
    await quarantineMedia(e.mediaDeps(), []);
    fs.unlinkSync(publicFile(key)); // file already gone
    await deleteMedia(e.mediaDeps(), [key, `u/${'a'.repeat(32)}/${'b'.repeat(32)}.png`]);
    expect(e.repo.getMedia(key)).toBeNull();
  });

  it('a failing store never throws out of the helpers (errors are logged)', async () => {
    const { token } = await e.login('alice');
    const key = (await upload(token, PNG)).json.key;
    const failing = { ...e.mediaDeps(), media: { ...e.media, delete: async () => { throw new Error('disk'); }, deleteQuarantined: async () => false, quarantine: async () => { throw new Error('disk'); } } as never, logError: (m: string) => e.errors.push(m) };
    await deleteMedia(failing, [key]);
    expect(e.errors.some((m) => m.includes('media delete failed'))).toBe(true);
    void HOUR;
    void WEBP;
  });
});
