import fs from 'node:fs/promises';
import path from 'node:path';
import { afterEach, describe, expect, it, vi } from 'vitest';
import { drillBackup, stageBackup, verifyBackup } from '../src/backup.js';
import { deleteAccount } from '../src/account.js';
import { ErasureLedger } from '../src/erasures.js';
import { guardRiotUserinfo, fetchRiotUserinfo } from '../src/riot.js';
import { moderate } from '../src/moderation/filter.js';
import { BAYES_C, MIN_RATINGS_FOR_RANK } from '../src/routes/skins.js';
import { setup, SKIN_A, WEAPON_1, PNG, type Env } from './helpers.js';

let e: Env;
afterEach(() => { e?.close(); vi.unstubAllGlobals(); });

describe('WP-SRV integrity', () => {
  it('stores new-account choices, only counts established accounts, excludes sanctioned voters', async () => {
    e = setup();
    const a = await e.login('alice');
    await e.req('PUT', `/v1/skins/${SKIN_A}/vote`, { token: a.token, body: { weaponUuid: WEAPON_1 } });
    await e.req('PUT', `/v1/skins/${SKIN_A}/review`, { token: a.token, body: { weaponUuid: WEAPON_1, rating: 5 } });
    const summary = () => e.req('GET', `/v1/skins/${SKIN_A}/summary`, { token: a.token });
    expect((await summary()).json).toMatchObject({ votes: 0, voted: true, ratingCount: 0, myReview: { rating: 5 } });
    e.clock.t += 86400_000;
    expect((await summary()).json).toMatchObject({ votes: 1, voted: true, ratingCount: 1 });
    expect(MIN_RATINGS_FOR_RANK).toBeGreaterThanOrEqual(10);
    expect(BAYES_C).toBe(15);
    e.repo.addSanction({ userId: a.user.id, kind: 'restrict', until: null, reason: 'spam', now: e.clock.t });
    expect((await summary()).json).toMatchObject({ votes: 0, ratingCount: 0 });
  });

  it('caps automatic hides from the same reporter set at three per UTC day', async () => {
    e = setup();
    const author = await e.login('author');
    const reporters = await Promise.all(['r1', 'r2', 'r3'].map((name) => e.login(name)));
    reporters.forEach((r) => e.mature(r.user.id));
    const targets: string[] = [];
    for (let i = 0; i < 4; i++) {
      const p = await e.req('POST', '/v1/posts', { token: author.token, body: { kind: 'text', body: `target ${i}` } });
      targets.push(p.json.id);
      for (const reporter of reporters) {
        const response = await e.req('POST', '/v1/reports', { token: reporter.token, body: { targetType: 'post', targetId: p.json.id, reason: 'spam' } });
        expect(response.status).toBe(204);
        expect(response.bytes.length).toBe(0);
      }
    }
    expect(targets.map((id) => e.repo.getPost(id, author.user.id)?.hidden)).toEqual([1, 1, 1, 0]);
    expect((await e.req('GET', '/v1/me/posts', { token: author.token })).json.items.filter((p: any) => p.hidden).length).toBe(3);
  });

  it('confirmed reports earn extra weight without allowing self-reports', async () => {
    e = setup();
    const a = await e.login('author');
    const reporters = await Promise.all(['r1', 'r2'].map((n) => e.login(n)));
    reporters.forEach((r) => e.mature(r.user.id));
    const post = async () => (await e.req('POST', '/v1/posts', { token: a.token, body: { kind: 'text', body: 'target' } })).json.id;
    const old = await post();
    for (const r of reporters) e.repo.addReport({ type: 'post', targetId: old, reporterId: r.user.id, reason: 'spam', now: e.clock.t }, 3, 86400_000);
    e.repo.hideTarget('post', old); // moderator confirms this report
    const next = await post();
    for (const r of reporters) e.repo.addReport({ type: 'post', targetId: next, reporterId: r.user.id, reason: 'spam', now: e.clock.t }, 3, 86400_000);
    expect(e.repo.getPost(next, a.user.id)?.hidden).toBe(1);
  });

  it('returns a party code on join; keeps list compatibility by default and supports hiding it', async () => {
    e = setup({ config: { lfgCodeInList: false } });
    const owner = await e.login('owner');
    const viewer = await e.login('viewer');
    const p = await e.req('POST', '/v1/lfg', { token: owner.token, body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 2 } });
    expect((await e.req('GET', '/v1/lfg', { token: viewer.token })).json.items[0].partyCode).toBe('');
    expect((await e.req('GET', '/v1/lfg/mine', { token: owner.token })).json.partyCode).toBe('ABCDEF');
    expect((await e.req('POST', `/v1/lfg/${p.json.id}/join`, { token: viewer.token, body: {} })).json.partyCode).toBe('ABCDEF');
    await e.req('POST', '/v1/lfg', { token: owner.token, body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 2 } });
    expect(e.repo.updateLfg(p.json.id, {}, e.clock.t, e.clock.t + 1800000, owner.user.id)).toBe(false);
  });

  it('preserves English gaming abbreviations; sanitizes bidi and combining/newline floods', () => {
    for (const language of ['en', 'fr', undefined]) expect(moderate('DM me, CC please', { language }).text).toBe('DM me, CC please');
    expect(moderate('dm cc', { language: 'vi' }).text).toBe('*** ***');
    expect(moderate('dm cc', { language: 'en', country: 'VN' }).text).toBe('*** ***');
    expect(moderate('hi\u202e\u2066\n\n\n\nthere', { language: 'en' }).text).toBe('hi\n\nthere');
    expect(moderate(`a${'\u0301'.repeat(12)}`).rejected).toBe('complex');
    expect(moderate('👩‍👩‍👧‍👦', { language: 'en' }).text).toBe('👩‍👩‍👧‍👦');
  });

  it('checks staged backup and replays erasures during the restore drill', async () => {
    e = setup();
    const a = await e.login('alice');
    await e.db.backup(path.join(e.dataDir, 'community.db'));
    const ledger = new ErasureLedger(path.join(e.dataDir, 'erasures.jsonl'));
    await deleteAccount({ ...e.mediaDeps(), erasureLedger: ledger }, a.user.id);
    const stage = path.join(e.dataDir, 'stage');
    await stageBackup(e.dataDir, stage);
    expect((await verifyBackup(stage)).users).toBe(1);
    expect((await drillBackup(stage)).users).toBe(0);
    await fs.writeFile(path.join(stage, 'snap.db'), 'invalid database');
    await expect(verifyBackup(stage)).rejects.toThrow();
  });

  it('bounds Riot concurrency, honors cooldown and caches rejected token hashes', async () => {
    let time = 0;
    let release!: () => void;
    const gate = new Promise<void>((resolve) => { release = resolve; });
    const verify = vi.fn(async () => { await gate; return { ok: false, reason: 'unavailable', retryAfter: 12 } as const; });
    const guarded = guardRiotUserinfo(verify, () => time, 1);
    const first = guarded('secret1');
    expect(await guarded('secret2')).toMatchObject({ ok: false, reason: 'unavailable' });
    expect(verify).toHaveBeenCalledTimes(1);
    release(); await first;
    expect(await guarded('secret3')).toMatchObject({ retryAfter: 12 });
    time = 12000;
    await guarded('secret4');
    expect(verify).toHaveBeenCalledTimes(2);
    const reject = vi.fn(async () => ({ ok: false, reason: 'rejected' } as const));
    const g = guardRiotUserinfo(reject, () => time);
    await g('bad'); await g('bad');
    expect(reject).toHaveBeenCalledTimes(1);
    time += 60000; await g('bad'); expect(reject).toHaveBeenCalledTimes(2);
  });

  it('Riot fetch refuses redirects and oversized bodies without forwarding credentials', async () => {
    const fetcher = vi.fn(async () => new Response('x'.repeat(65537), { headers: { 'content-length': '65537' } }));
    vi.stubGlobal('fetch', fetcher);
    expect(await fetchRiotUserinfo('secret')).toMatchObject({ reason: 'unavailable' });
    expect(fetcher.mock.calls[0]).toHaveLength(2);
    expect((fetcher.mock.calls[0] as unknown as [string, RequestInit])[1].redirect).toBe('manual');
  });
});
