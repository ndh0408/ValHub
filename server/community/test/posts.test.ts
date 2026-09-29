import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { BASE, expectError, JPEG, PNG, setup, SKIN_A, SKIN_B, WEBP, type Env } from './helpers.js';

let e: Env;
beforeEach(() => {
  e = setup();
});
afterEach(() => e.close());

const upload = (token: string, bytes: Uint8Array, type = 'image/png') =>
  e.req('POST', '/v1/media', { token, raw: bytes, headers: { 'content-type': type } });

const storePayload = {
  date: '2026-09-01',
  offers: [
    { skinUuid: SKIN_A, cost: 1775, extra: 'dropped' },
    { skinUuid: SKIN_B, cost: 875 },
  ],
};
const nmPayload = {
  date: '2026-09-01',
  offers: [{ skinUuid: SKIN_A, baseCost: 1775, discountCost: 887, discountPercent: 50 }],
};

describe('media', () => {
  it('uploads png/jpeg/webp and serves them with long cache headers', async () => {
    const { token, user } = await e.login('alice');
    for (const [bytes, type, ext] of [
      [PNG, 'image/png', 'png'],
      [JPEG, 'image/jpeg', 'jpg'],
      [WEBP, 'image/webp', 'webp'],
    ] as const) {
      const res = await upload(token, bytes, type);
      expect(res.status).toBe(200);
      expect(res.json.key).toMatch(new RegExp(`^u/${user.id}/[0-9a-f]{32}\\.${ext}$`));
      expect(res.json.url).toBe(`${BASE}/v1/media/${res.json.key}`);

      const get = await e.req('GET', `/v1/media/${res.json.key}`);
      expect(get.status).toBe(200);
      expect(get.headers.get('content-type')).toBe(type);
      expect(get.headers.get('cache-control')).toContain('max-age=31536000');
      expect(Array.from(get.bytes)).toEqual(Array.from(bytes));
      const cached = await e.req('GET', `/v1/media/${res.json.key}`, {
        headers: { 'if-none-match': get.headers.get('etag')! },
      });
      expect(cached.status).toBe(304);
    }
  });

  it('builds the URL from forwarded tunnel headers', async () => {
    const { token } = await e.login('alice');
    const res = await e.req('POST', '/v1/media', {
      token,
      raw: PNG,
      headers: { 'content-type': 'image/png', 'x-forwarded-proto': 'https', 'x-forwarded-host': 'cd.example.vn' },
    });
    expect(res.json.url).toMatch(/^https:\/\/cd\.example\.vn\/v1\/media\/u\//);
  });

  it('checks magic bytes, type and size', async () => {
    const { token } = await e.login('alice');
    expectError(await upload(token, PNG, 'image/jpeg'), 400, 'invalid_input');
    expectError(await upload(token, new TextEncoder().encode('<svg/>'), 'image/png'), 400, 'invalid_input');
    expectError(await upload(token, PNG, 'image/gif'), 400, 'invalid_input');
    expectError(await upload(token, new Uint8Array(0)), 400, 'invalid_input');
    const big = new Uint8Array(2 * 1024 * 1024 + 1);
    big.set(PNG);
    expectError(await upload(token, big), 400, 'invalid_input');
    const exact = new Uint8Array(2 * 1024 * 1024);
    exact.set(PNG);
    expect((await upload(token, exact)).status).toBe(200);
    expectError(await e.req('POST', '/v1/media', { raw: PNG, headers: { 'content-type': 'image/png' } }), 401, 'unauthorized');
  });

  it('404s unknown or malformed keys (no path traversal)', async () => {
    expectError(await e.req('GET', `/v1/media/u/${'a'.repeat(32)}/${'b'.repeat(32)}.png`), 404, 'not_found');
    expectError(await e.req('GET', '/v1/media/u/..%2F..%2Fcommunity.db'), 404, 'not_found');
    expectError(await e.req('GET', '/v1/media/../../etc/passwd'), 404, 'not_found');
  });
});

describe('posts', () => {
  it('creates each kind with validated payloads', async () => {
    const { token, user } = await e.login('alice');
    const text = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: ' Xin chào ' } });
    expect(text.status).toBe(200);
    expect(text.json).toEqual({
      id: expect.any(String),
      author: expect.objectContaining({ id: user.id }),
      kind: 'text',
      body: 'Xin chào',
      media: [],
      payload: null,
      likes: 0,
      liked: false,
      comments: 0,
      createdAt: new Date(e.clock.t).toISOString(),
    });

    const store = await e.req('POST', '/v1/posts', { token, body: { kind: 'store', payload: storePayload } });
    expect(store.status).toBe(200);
    expect(store.json.body).toBe('');
    expect(store.json.payload).toEqual({
      date: '2026-09-01',
      offers: [
        { skinUuid: SKIN_A, cost: 1775 },
        { skinUuid: SKIN_B, cost: 875 },
      ],
    });

    const nm = await e.req('POST', '/v1/posts', {
      token,
      body: { kind: 'nightmarket', body: 'Chợ Đêm ngon', payload: nmPayload },
    });
    expect(nm.status).toBe(200);
    expect(nm.json.payload).toEqual(nmPayload);

    const got = await e.req('GET', `/v1/posts/${nm.json.id}`, { token });
    expect(got.json).toEqual(nm.json);
  });

  it('rejects invalid posts', async () => {
    const { token } = await e.login('alice');
    const bad: unknown[] = [
      { kind: 'meme', body: 'x' },
      { kind: 'text', body: '' },
      { kind: 'text', body: '   ' },
      { kind: 'text', body: 'x'.repeat(1001) },
      { kind: 'text', body: 'x', payload: storePayload },
      { kind: 'store', body: 'no payload' },
      { kind: 'store', payload: { date: '2026-02-30', offers: storePayload.offers } },
      { kind: 'store', payload: { date: '01/09/2026', offers: storePayload.offers } },
      { kind: 'store', payload: { date: '2026-09-01', offers: [] } },
      { kind: 'store', payload: { date: '2026-09-01', offers: Array(7).fill({ skinUuid: SKIN_A, cost: 1 }) } },
      { kind: 'store', payload: { date: '2026-09-01', offers: [{ skinUuid: 'x', cost: 1 }] } },
      { kind: 'store', payload: { date: '2026-09-01', offers: [{ skinUuid: SKIN_A, cost: -1 }] } },
      { kind: 'store', payload: { date: '2026-09-01', offers: [{ skinUuid: SKIN_A, cost: '1775' }] } },
      { kind: 'nightmarket', payload: storePayload },
      {
        kind: 'nightmarket',
        payload: { date: '2026-09-01', offers: [{ ...nmPayload.offers[0], discountPercent: 101 }] },
      },
      {
        kind: 'nightmarket',
        payload: { date: '2026-09-01', offers: [{ ...nmPayload.offers[0], discountCost: 5000 }] },
      },
      { kind: 'text', body: 'x', media: 'not-an-array' },
      { kind: 'text', body: 'x', media: ['../../etc/passwd'] },
    ];
    for (const body of bad) {
      expectError(await e.req('POST', '/v1/posts', { token, body }), 400, 'invalid_input');
    }
    expect((await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'x'.repeat(1000) } })).status).toBe(
      200,
    );
  });

  it('only accepts media uploaded by the same user (max 4)', async () => {
    const alice = await e.login('alice');
    const bob = await e.login('bob');
    const keys: string[] = [];
    for (let i = 0; i < 5; i++) keys.push((await upload(alice.token, PNG)).json.key);
    const bobKey = (await upload(bob.token, PNG)).json.key;

    const ok = await e.req('POST', '/v1/posts', { token: alice.token, body: { kind: 'text', media: keys.slice(0, 4) } });
    expect(ok.status).toBe(200);
    expect(ok.json.body).toBe('');
    expect(ok.json.media).toEqual(keys.slice(0, 4).map((key) => ({ key, url: `${BASE}/v1/media/${key}` })));

    expectError(await e.req('POST', '/v1/posts', { token: alice.token, body: { kind: 'text', media: keys } }), 400, 'invalid_input');
    expectError(
      await e.req('POST', '/v1/posts', { token: alice.token, body: { kind: 'text', media: [keys[0], keys[0]] } }),
      400,
      'invalid_input',
    );
    expectError(
      await e.req('POST', '/v1/posts', { token: alice.token, body: { kind: 'text', media: [bobKey] } }),
      403,
      'forbidden',
    );
    const ghost = `u/${alice.user.id}/${'c'.repeat(32)}.png`;
    expectError(
      await e.req('POST', '/v1/posts', { token: alice.token, body: { kind: 'text', media: [ghost] } }),
      400,
      'invalid_input',
    );
  });

  it('lists newest first with kind filter and pagination', async () => {
    const { token } = await e.login('alice');
    const ids: string[] = [];
    for (let i = 0; i < 5; i++) {
      e.clock.t += 1000;
      const kind = i % 2 === 0 ? 'text' : 'store';
      const body = kind === 'text' ? { kind, body: `p${i}` } : { kind, payload: storePayload };
      ids.push((await e.req('POST', '/v1/posts', { token, body })).json.id);
    }
    const p1 = await e.req('GET', '/v1/posts?limit=3', { token });
    expect(p1.json.items.map((p: any) => p.id)).toEqual([ids[4], ids[3], ids[2]]);
    const p2 = await e.req('GET', `/v1/posts?limit=3&cursor=${p1.json.nextCursor}`, { token });
    expect(p2.json.items.map((p: any) => p.id)).toEqual([ids[1], ids[0]]);
    expect(p2.json.nextCursor).toBeNull();
    const stores = await e.req('GET', '/v1/posts?kind=store', { token });
    expect(stores.json.items.map((p: any) => p.id)).toEqual([ids[3], ids[1]]);
    expectError(await e.req('GET', '/v1/posts?kind=bad', { token }), 400, 'invalid_input');
    expectError(await e.req('GET', '/v1/posts'), 401, 'unauthorized');
  });

  it('likes and unlikes idempotently', async () => {
    const alice = await e.login('alice');
    const bob = await e.login('bob');
    const id = (await e.req('POST', '/v1/posts', { token: alice.token, body: { kind: 'text', body: 'hi' } })).json.id;
    expect((await e.req('PUT', `/v1/posts/${id}/like`, { token: alice.token })).json).toEqual({ likes: 1, liked: true });
    expect((await e.req('PUT', `/v1/posts/${id}/like`, { token: alice.token })).json).toEqual({ likes: 1, liked: true });
    expect((await e.req('PUT', `/v1/posts/${id}/like`, { token: bob.token })).json).toEqual({ likes: 2, liked: true });
    expect((await e.req('GET', `/v1/posts/${id}`, { token: bob.token })).json).toMatchObject({ likes: 2, liked: true });
    expect((await e.req('DELETE', `/v1/posts/${id}/like`, { token: bob.token })).json).toEqual({
      likes: 1,
      liked: false,
    });
    expect((await e.req('GET', `/v1/posts/${id}`, { token: bob.token })).json).toMatchObject({ likes: 1, liked: false });
    expectError(
      await e.req('PUT', '/v1/posts/00000000-0000-4000-8000-000000000000/like', { token: bob.token }),
      404,
      'not_found',
    );
  });

  it('handles comments (oldest first, counts, own delete)', async () => {
    const alice = await e.login('alice');
    const bob = await e.login('bob');
    const id = (await e.req('POST', '/v1/posts', { token: alice.token, body: { kind: 'text', body: 'hi' } })).json.id;
    const cids: string[] = [];
    for (let i = 0; i < 3; i++) {
      e.clock.t += 1000;
      const c = await e.req('POST', `/v1/posts/${id}/comments`, {
        token: i === 1 ? alice.token : bob.token,
        body: { body: `c${i}` },
      });
      expect(c.status).toBe(200);
      expect(c.json).toMatchObject({ postId: id, body: `c${i}`, author: { gameName: expect.any(String) } });
      cids.push(c.json.id);
    }
    const p1 = await e.req('GET', `/v1/posts/${id}/comments?limit=2`, { token: alice.token });
    expect(p1.json.items.map((c: any) => c.body)).toEqual(['c0', 'c1']);
    const p2 = await e.req('GET', `/v1/posts/${id}/comments?limit=2&cursor=${p1.json.nextCursor}`, {
      token: alice.token,
    });
    expect(p2.json.items.map((c: any) => c.body)).toEqual(['c2']);
    expect(p2.json.nextCursor).toBeNull();
    expect((await e.req('GET', `/v1/posts/${id}`, { token: alice.token })).json.comments).toBe(3);

    expectError(await e.req('DELETE', `/v1/comments/${cids[0]}`, { token: alice.token }), 403, 'forbidden');
    expect((await e.req('DELETE', `/v1/comments/${cids[0]}`, { token: bob.token })).status).toBe(204);
    expect((await e.req('GET', `/v1/posts/${id}`, { token: alice.token })).json.comments).toBe(2);

    expectError(await e.req('POST', `/v1/posts/${id}/comments`, { token: bob.token, body: { body: '' } }), 400, 'invalid_input');
    expectError(
      await e.req('POST', `/v1/posts/${id}/comments`, { token: bob.token, body: { body: 'x'.repeat(501) } }),
      400,
      'invalid_input',
    );
  });

  it('only lets the author delete a post (likes/comments go with it)', async () => {
    const alice = await e.login('alice');
    const bob = await e.login('bob');
    const id = (await e.req('POST', '/v1/posts', { token: alice.token, body: { kind: 'text', body: 'hi' } })).json.id;
    await e.req('PUT', `/v1/posts/${id}/like`, { token: bob.token });
    await e.req('POST', `/v1/posts/${id}/comments`, { token: bob.token, body: { body: 'yo' } });
    expectError(await e.req('DELETE', `/v1/posts/${id}`, { token: bob.token }), 403, 'forbidden');
    expect((await e.req('DELETE', `/v1/posts/${id}`, { token: alice.token })).status).toBe(204);
    expectError(await e.req('GET', `/v1/posts/${id}`, { token: alice.token }), 404, 'not_found');
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM comments').get()).toEqual({ n: 0 });
    expect(e.db.prepare('SELECT COUNT(*) AS n FROM post_likes').get()).toEqual({ n: 0 });
  });
});

describe('reports', () => {
  it('hides a post after 3 distinct reports', async () => {
    const author = await e.login('author');
    const reporters = await Promise.all(['r1', 'r2', 'r3'].map((n) => e.login(n)));
    const id = (await e.req('POST', '/v1/posts', { token: author.token, body: { kind: 'text', body: 'spam' } })).json.id;
    const report = (token: string) =>
      e.req('POST', '/v1/reports', { token, body: { targetType: 'post', targetId: id, reason: 'spam' } });

    expect((await report(reporters[0]!.token)).status).toBe(204);
    expect((await report(reporters[0]!.token)).status).toBe(204); // duplicate, not counted
    expect((await report(author.token)).status).toBe(204); // self-report, not counted
    expect((await report(reporters[1]!.token)).status).toBe(204);
    expect((await e.req('GET', `/v1/posts/${id}`, { token: author.token })).status).toBe(200);

    expect((await report(reporters[2]!.token)).status).toBe(204);
    expectError(await e.req('GET', `/v1/posts/${id}`, { token: author.token }), 404, 'not_found');
    expect((await e.req('GET', '/v1/posts', { token: author.token })).json.items).toEqual([]);
    // The author can still delete their hidden post.
    expect((await e.req('DELETE', `/v1/posts/${id}`, { token: author.token })).status).toBe(204);
  });

  it('hides comments and LFG posts too', async () => {
    const author = await e.login('author');
    const reporters = await Promise.all(['r1', 'r2', 'r3'].map((n) => e.login(n)));
    const postId = (await e.req('POST', '/v1/posts', { token: author.token, body: { kind: 'text', body: 'x' } })).json.id;
    const cid = (await e.req('POST', `/v1/posts/${postId}/comments`, { token: author.token, body: { body: 'bad' } }))
      .json.id;
    const lfgId = (
      await e.req('POST', '/v1/lfg', {
        token: author.token,
        body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 1 },
      })
    ).json.id;
    for (const r of reporters) {
      await e.req('POST', '/v1/reports', { token: r.token, body: { targetType: 'comment', targetId: cid, reason: 'x' } });
      await e.req('POST', '/v1/reports', { token: r.token, body: { targetType: 'lfg', targetId: lfgId, reason: 'x' } });
    }
    expect((await e.req('GET', `/v1/posts/${postId}/comments`, { token: author.token })).json.items).toEqual([]);
    expect((await e.req('GET', `/v1/posts/${postId}`, { token: author.token })).json.comments).toBe(0);
    expect((await e.req('GET', '/v1/lfg', { token: author.token })).json.items).toEqual([]);
  });

  it('validates reports', async () => {
    const { token } = await e.login('a');
    const missing = '00000000-0000-4000-8000-000000000000';
    expectError(
      await e.req('POST', '/v1/reports', { token, body: { targetType: 'post', targetId: missing, reason: 'x' } }),
      404,
      'not_found',
    );
    expectError(
      await e.req('POST', '/v1/reports', { token, body: { targetType: 'user', targetId: missing, reason: 'x' } }),
      400,
      'invalid_input',
    );
    expectError(
      await e.req('POST', '/v1/reports', { token, body: { targetType: 'post', targetId: 'abc', reason: 'x' } }),
      400,
      'invalid_input',
    );
    expectError(
      await e.req('POST', '/v1/reports', { token, body: { targetType: 'post', targetId: missing, reason: '' } }),
      400,
      'invalid_input',
    );
  });
});
