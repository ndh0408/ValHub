import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { expectError, setup, SKIN_A, SKIN_B, SKIN_C, WEAPON_1, WEAPON_2, type Env } from './helpers.js';

const DAY = 86400_000;

let e: Env;
beforeEach(() => {
  e = setup();
});
afterEach(() => e.close());

/**
 * vn1, vn2: Vietnam / shard ap / vi   us1: USA / na / en   th1: Thailand / ap / th
 * kr1: Korea / kr / ko                 nc: no country, ap, no language (a client from before v3)
 */
async function cast() {
  e.riotCountries.vn1 = 'vnm';
  e.riotCountries.vn2 = 'vnm';
  e.riotCountries.us1 = 'usa';
  e.riotCountries.th1 = 'tha';
  e.riotCountries.kr1 = 'kor';
  return {
    vn1: await e.login('vn1', { region: 'ap', language: 'vi' }),
    vn2: await e.login('vn2', { region: 'ap', language: 'vi' }),
    us1: await e.login('us1', { region: 'na', language: 'en' }),
    th1: await e.login('th1', { region: 'ap', language: 'th' }),
    kr1: await e.login('kr1', { region: 'kr', language: 'ko' }),
    nc: await e.login('nc', { region: 'ap' }),
  };
}
type Cast = Awaited<ReturnType<typeof cast>>;

const post = (token: string, body: string, extra: Record<string, unknown> = {}) =>
  e.req('POST', '/v1/posts', { token, body: { kind: 'text', body, ...extra } });

const names = (res: { json: any }) => res.json.items.map((i: any) => i.author.gameName.replace('Player ', '')).sort();
const bodies = (res: { json: any }) => res.json.items.map((i: any) => i.body).sort();

describe('feed scopes', () => {
  let c: Cast;
  beforeEach(async () => {
    c = await cast();
    for (const [name, u] of Object.entries(c)) {
      e.clock.t += 1000;
      await post(u.token, `post ${name}`);
    }
  });

  it('stores the author country / region / language at creation', async () => {
    const list = await e.req('GET', '/v1/posts?scope=global', { token: c.vn1.token });
    const byBody = Object.fromEntries(list.json.items.map((p: any) => [p.body, p]));
    expect(byBody['post vn1']).toMatchObject({ country: 'VN', region: 'ap', language: 'vi' });
    expect(byBody['post us1']).toMatchObject({ country: 'US', region: 'na', language: 'en' });
    expect(byBody['post kr1']).toMatchObject({ country: 'KR', region: 'kr', language: 'ko' });
    expect(byBody['post nc']).toMatchObject({ country: null, region: 'ap', language: null });
  });

  it('defaults to the viewer country', async () => {
    const res = await e.req('GET', '/v1/posts', { token: c.vn1.token });
    expect(bodies(res)).toEqual(['post vn1', 'post vn2']);
    expect(res.json.appliedScope).toEqual({ scope: 'country', country: 'VN', region: null });
    expect(names(await e.req('GET', '/v1/posts', { token: c.us1.token }))).toEqual(['us1']);
  });

  it('falls back to the viewer region when the viewer has no country', async () => {
    const res = await e.req('GET', '/v1/posts', { token: c.nc.token });
    expect(bodies(res)).toEqual(['post nc', 'post th1', 'post vn1', 'post vn2']);
    expect(res.json.appliedScope).toEqual({ scope: 'region', country: null, region: 'ap' });
  });

  it('is global without a session (the feed is public)', async () => {
    const res = await e.req('GET', '/v1/posts');
    expect(res.status).toBe(200);
    expect(res.json.items).toHaveLength(6);
    expect(res.json.appliedScope).toEqual({ scope: 'global', country: null, region: null });
    // Single posts and comments are readable without a session too; liked is false.
    const id = res.json.items[0].id;
    expect((await e.req('GET', `/v1/posts/${id}`)).json.liked).toBe(false);
    expect((await e.req('GET', `/v1/posts/${id}/comments`)).status).toBe(200);
    // An invalid token is still refused so the client refreshes it.
    expectError(await e.req('GET', '/v1/posts', { token: 'garbage' }), 401, 'unauthorized');
  });

  it('honours scope / country / region', async () => {
    const t = c.vn1.token;
    expect((await e.req('GET', '/v1/posts?scope=global', { token: t })).json.items).toHaveLength(6);
    expect(names(await e.req('GET', '/v1/posts?scope=country&country=US', { token: t }))).toEqual(['us1']);
    expect(names(await e.req('GET', '/v1/posts?country=kr', { token: t }))).toEqual(['kr1']);
    expect(names(await e.req('GET', '/v1/posts?scope=region&region=na', { token: t }))).toEqual(['us1']);
    expect(names(await e.req('GET', '/v1/posts?region=ap', { token: t }))).toEqual(['nc', 'th1', 'vn1', 'vn2']);
    // scope=region without a param uses the viewer's shard.
    expect(names(await e.req('GET', '/v1/posts?scope=region', { token: c.kr1.token }))).toEqual(['kr1']);
    // A country nobody posted from is simply empty.
    expect((await e.req('GET', '/v1/posts?country=JP', { token: t })).json.items).toEqual([]);
    // scope=country for a viewer without country falls back like the default does.
    expect(names(await e.req('GET', '/v1/posts?scope=country', { token: c.nc.token }))).toEqual(['nc', 'th1', 'vn1', 'vn2']);
    expect(names(await e.req('GET', '/v1/posts?scope=country'))).toHaveLength(6);
  });

  it('validates scope params', async () => {
    const t = c.vn1.token;
    for (const qs of ['scope=planet', 'country=usa', 'country=ZZ', 'region=mars', 'language=xx', 'language=vi,xx']) {
      expectError(await e.req('GET', `/v1/posts?${qs}`, { token: t }), 400, 'invalid_input');
    }
  });

  it('filters by language (comma list) in any scope; rows without a language are excluded by the filter', async () => {
    const t = c.vn1.token;
    expect(names(await e.req('GET', '/v1/posts?scope=global&language=vi', { token: t }))).toEqual(['vn1', 'vn2']);
    expect(names(await e.req('GET', '/v1/posts?scope=global&language=vi,en', { token: t }))).toEqual(['us1', 'vn1', 'vn2']);
    expect(names(await e.req('GET', '/v1/posts?scope=global&language=th,ko', { token: t }))).toEqual(['kr1', 'th1']);
    expect(names(await e.req('GET', '/v1/posts?scope=global&language=zh-CN', { token: t }))).toEqual([]);
    // Combined with country scope.
    expect(names(await e.req('GET', '/v1/posts?scope=country&country=VN&language=en', { token: t }))).toEqual([]);
    // No filter → the language-less post is visible.
    expect(names(await e.req('GET', '/v1/posts?scope=global', { token: t }))).toContain('nc');
  });

  it('accepts a per-item language that overrides the author language', async () => {
    const p = await post(c.vn1.token, 'hello from vn', { language: 'en' });
    expect(p.json).toMatchObject({ language: 'en', country: 'VN', author: { language: 'vi' } });
    const res = await e.req('GET', '/v1/posts?scope=country&country=VN&language=en', { token: c.vn1.token });
    expect(bodies(res)).toEqual(['hello from vn']);
  });

  it('paginates inside a scope', async () => {
    for (let i = 0; i < 4; i++) {
      e.clock.t += 1000;
      await post(c.vn1.token, `more ${i}`);
    }
    const p1 = await e.req('GET', '/v1/posts?limit=2', { token: c.vn2.token });
    expect(p1.json.items).toHaveLength(2);
    const seen: string[] = [...p1.json.items.map((p: any) => p.body)];
    let cursor = p1.json.nextCursor;
    while (cursor) {
      const next = await e.req('GET', `/v1/posts?limit=2&cursor=${cursor}`, { token: c.vn2.token });
      seen.push(...next.json.items.map((p: any) => p.body));
      cursor = next.json.nextCursor;
    }
    expect(seen.sort()).toEqual(['more 0', 'more 1', 'more 2', 'more 3', 'post vn1', 'post vn2']);
  });

  it('keeps creation-time values when the author later moves or changes language', async () => {
    e.riotCountries.vn1 = 'usa';
    const moved = await e.login('vn1', { region: 'na', language: 'en' });
    expect(moved.user).toMatchObject({ country: 'US', region: 'na', language: 'en' });
    const now = await post(moved.token, 'after the move');
    expect(now.json).toMatchObject({ country: 'US', region: 'na', language: 'en' });
    const all = await e.req('GET', '/v1/posts?scope=global', { token: moved.token });
    const old = all.json.items.find((p: any) => p.body === 'post vn1');
    expect(old).toMatchObject({ country: 'VN', region: 'ap', language: 'vi' });
    // The old post is still found under VN, the new one under US.
    expect(bodies(await e.req('GET', '/v1/posts?country=VN', { token: moved.token }))).toEqual(['post vn1', 'post vn2']);
    expect(bodies(await e.req('GET', '/v1/posts?country=US', { token: moved.token }))).toEqual(['after the move', 'post us1']);
  });

  it('stores country / region / language on comments', async () => {
    const id = (await post(c.vn1.token, 'thread')).json.id;
    const cm = await e.req('POST', `/v1/posts/${id}/comments`, { token: c.th1.token, body: { body: 'สวัสดี' } });
    expect(cm.json).toMatchObject({ country: 'TH', region: 'ap', language: 'th' });
    const cm2 = await e.req('POST', `/v1/posts/${id}/comments`, {
      token: c.th1.token,
      body: { body: 'hello', language: 'en' },
    });
    expect(cm2.json.language).toBe('en');
    const list = await e.req('GET', `/v1/posts/${id}/comments`);
    expect(list.json.items.map((i: any) => i.country)).toEqual(['TH', 'TH']);
  });
});

describe('LFG scopes', () => {
  let c: Cast;
  const lfg = (u: { token: string }, extra: Record<string, unknown> = {}) =>
    e.req('POST', '/v1/lfg', {
      token: u.token,
      body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 2, ...extra },
    });
  const lnames = (res: { json: any }) => names(res);

  beforeEach(async () => {
    c = await cast();
    e.clock.t += 1000;
    await lfg(c.vn1); // ap, party language vi (author's)
    await lfg(c.th1); // ap, th
    await lfg(c.us1, { region: 'na' }); // na, en
    await lfg(c.kr1, { region: 'kr', language: 'any' });
    await lfg(c.nc, { language: 'vi' }); // no country, ap
  });

  it('stores the author country and defaults the party language to the author language', async () => {
    const mine = await e.req('GET', '/v1/lfg/mine', { token: c.th1.token });
    expect(mine.json).toMatchObject({ country: 'TH', region: 'ap', language: 'th' });
    expect((await e.req('GET', '/v1/lfg/mine', { token: c.nc.token })).json).toMatchObject({
      country: null,
      language: 'vi',
    });
    // A client without a known language keeps the old default (vi).
    const old = await e.login('oldclient');
    expect((await lfg(old)).json.language).toBe('vi');
  });

  it('defaults to the viewer region (the people you can party with)', async () => {
    const res = await e.req('GET', '/v1/lfg', { token: c.vn2.token });
    expect(lnames(res)).toEqual(['nc', 'th1', 'vn1']);
    expect(res.json.appliedScope).toEqual({ scope: 'region', country: null, region: 'ap' });
    expect(lnames(await e.req('GET', '/v1/lfg', { token: c.us1.token }))).toEqual(['us1']);
  });

  it('keeps the old region param working', async () => {
    const t = c.vn2.token;
    expect(lnames(await e.req('GET', '/v1/lfg?region=na', { token: t }))).toEqual(['us1']);
    expect(lnames(await e.req('GET', '/v1/lfg?region=kr', { token: t }))).toEqual(['kr1']);
    expect(lnames(await e.req('GET', '/v1/lfg?region=ap&mode=unrated', { token: t }))).toEqual(['nc', 'th1', 'vn1']);
    expect(lnames(await e.req('GET', '/v1/lfg?region=ap&mode=competitive', { token: t }))).toEqual([]);
  });

  it('supports scope=country and scope=global', async () => {
    const t = c.vn2.token;
    expect(lnames(await e.req('GET', '/v1/lfg?scope=global', { token: t }))).toEqual(['kr1', 'nc', 'th1', 'us1', 'vn1']);
    expect(lnames(await e.req('GET', '/v1/lfg?scope=country', { token: t }))).toEqual(['vn1']);
    expect(lnames(await e.req('GET', '/v1/lfg?country=TH', { token: t }))).toEqual(['th1']);
    expect(lnames(await e.req('GET', '/v1/lfg?scope=country&country=us', { token: t }))).toEqual(['us1']);
    expectError(await e.req('GET', '/v1/lfg?scope=planet', { token: t }), 400, 'invalid_input');
    expectError(await e.req('GET', '/v1/lfg?country=USA', { token: t }), 400, 'invalid_input');
    // LFG still needs a session.
    expectError(await e.req('GET', '/v1/lfg'), 401, 'unauthorized');
  });

  it('filters by party language: 17 codes, comma lists, any', async () => {
    const t = c.vn2.token;
    const g = '/v1/lfg?scope=global';
    // 'any' parties (kr1) match every language filter; 'any' as a filter disables it.
    expect(lnames(await e.req('GET', `${g}&language=th`, { token: t }))).toEqual(['kr1', 'th1']);
    expect(lnames(await e.req('GET', `${g}&language=vi`, { token: t }))).toEqual(['kr1', 'nc', 'vn1']);
    expect(lnames(await e.req('GET', `${g}&language=th,en`, { token: t }))).toEqual(['kr1', 'th1', 'us1']);
    expect(lnames(await e.req('GET', `${g}&language=ja`, { token: t }))).toEqual(['kr1']);
    expect(lnames(await e.req('GET', `${g}&language=any`, { token: t }))).toHaveLength(5);
    expect(lnames(await e.req('GET', `${g}&language=vi,any`, { token: t }))).toHaveLength(5);
    expectError(await e.req('GET', `${g}&language=xx`, { token: t }), 400, 'invalid_input');
  });

  it('accepts the 17 languages, any and the old vi | en | any on POST', async () => {
    for (const language of ['vi', 'en', 'any', 'ar', 'de', 'es', 'fr', 'id', 'it', 'ja', 'ko', 'pl', 'pt', 'ru', 'th', 'tr', 'zh-CN', 'zh-TW']) {
      e.clock.t += 11 * 60_000; // stay under the 6 posts / 10 min limit
      const res = await lfg(c.vn1, { language });
      expect(res.status, language).toBe(200);
      expect(res.json.language).toBe(language);
    }
    e.clock.t += 11 * 60_000;
    expect((await lfg(c.vn1, { language: 'pt-BR' })).json.language).toBe('pt');
    expect((await lfg(c.vn1, { language: 'ANY' })).json.language).toBe('any');
    for (const language of ['xx', 'zh', 5, 'english']) {
      expectError(await lfg(c.vn1, { language }), 400, 'invalid_input');
    }
  });

  it('the LFG post keeps its own region even when the author is on another shard', async () => {
    await lfg(c.us1, { region: 'eu' });
    const res = await e.req('GET', '/v1/lfg?region=eu', { token: c.vn1.token });
    expect(res.json.items).toHaveLength(1);
    expect(res.json.items[0]).toMatchObject({ region: 'eu', country: 'US', author: { region: 'na' } });
  });
});

describe('skin votes by voter country / region', () => {
  let c: Cast;
  const vote = (u: { token: string }, skin: string, weapon = WEAPON_1) =>
    e.req('PUT', `/v1/skins/${skin}/vote`, { token: u.token, body: { weaponUuid: weapon } });
  const top = async (qs = '', token?: string) => (await e.req('GET', `/v1/skins/top${qs}`, { token })).json;
  const tops = (json: any) => json.items.map((i: any) => [i.skinUuid, i.votes]);

  beforeEach(async () => {
    c = await cast();
    // A: vn1 vn2 us1 kr1 nc   B: vn1 th1   C: us1
    for (const u of [c.vn1, c.vn2, c.us1, c.kr1, c.nc]) await vote(u, SKIN_A);
    for (const u of [c.vn1, c.th1]) await vote(u, SKIN_B);
    await vote(c.us1, SKIN_C);
  });

  it('is global by default (as before), whoever is asking', async () => {
    expect(tops(await top())).toEqual([[SKIN_A, 5], [SKIN_B, 2], [SKIN_C, 1]]);
    expect(tops(await top('', c.vn1.token))).toEqual([[SKIN_A, 5], [SKIN_B, 2], [SKIN_C, 1]]);
    expect((await top()).appliedScope).toEqual({ scope: 'global', country: null, region: null });
  });

  it('counts votes by the voter country', async () => {
    expect(tops(await top('?scope=country&country=VN'))).toEqual([[SKIN_A, 2], [SKIN_B, 1]]);
    expect(tops(await top('?country=US'))).toEqual([[SKIN_A, 1], [SKIN_C, 1]]);
    expect(tops(await top('?country=TH'))).toEqual([[SKIN_B, 1]]);
    expect(tops(await top('?country=JP'))).toEqual([]);
    // scope=country with no param uses the viewer's country; the viewer without one falls back to the region.
    expect(tops(await top('?scope=country', c.vn2.token))).toEqual([[SKIN_A, 2], [SKIN_B, 1]]);
    expect((await top('?scope=country', c.vn2.token)).appliedScope).toEqual({ scope: 'country', country: 'VN', region: null });
    expect(tops(await top('?scope=country', c.nc.token))).toEqual([[SKIN_A, 3], [SKIN_B, 2]]);
    expect((await top('?scope=country', c.nc.token)).appliedScope).toEqual({ scope: 'region', country: null, region: 'ap' });
  });

  it('counts votes by the voter region', async () => {
    expect(tops(await top('?scope=region&region=ap'))).toEqual([[SKIN_A, 3], [SKIN_B, 2]]);
    expect(tops(await top('?region=na'))).toEqual([[SKIN_A, 1], [SKIN_C, 1]]);
    expect(tops(await top('?region=kr'))).toEqual([[SKIN_A, 1]]);
    expect(tops(await top('?scope=region', c.us1.token))).toEqual([[SKIN_A, 1], [SKIN_C, 1]]);
  });

  it('works with weapon and period filters', async () => {
    const other = await vote(c.vn2, SKIN_C, WEAPON_2); // weapon of C is pinned by us1's first vote
    expect(other.status).toBe(200);
    expect(tops(await top(`?country=VN&weapon=${WEAPON_1}`))).toEqual([[SKIN_A, 2], [SKIN_B, 1], [SKIN_C, 1]]);
    expect(tops(await top(`?country=VN&weapon=${WEAPON_2}`))).toEqual([]);
    // Old votes fall out of the week; recent ones stay, per country.
    e.clock.t += 8 * DAY;
    await vote(c.vn1, SKIN_C);
    expect(tops(await top('?country=VN&period=week'))).toEqual([[SKIN_C, 1]]);
    expect(tops(await top('?country=US&period=week'))).toEqual([]);
    expect(tops(await top('?country=VN'))).toEqual([[SKIN_A, 2], [SKIN_B, 1], [SKIN_C, 2]].sort((a: any, b: any) => b[1] - a[1] || (a[0] < b[0] ? -1 : 1)));
  });

  it('records the voter country at vote time; moving later does not move old votes; revoting keeps the original', async () => {
    e.riotCountries.vn2 = 'usa';
    const moved = await e.login('vn2', { region: 'na', language: 'en' });
    // vn2 voted A while in VN. Voting again (idempotent) does not change where it counted.
    await vote(moved, SKIN_A);
    await vote(moved, SKIN_B); // new vote, cast from the US
    expect(tops(await top('?country=VN'))).toEqual([[SKIN_A, 2], [SKIN_B, 1]]);
    expect(tops(await top('?country=US'))).toEqual([[SKIN_A, 1], [SKIN_B, 1], [SKIN_C, 1]]);
    // Unvoting removes it from every scope.
    await e.req('DELETE', `/v1/skins/${SKIN_A}/vote`, { token: c.vn1.token });
    expect(tops(await top('?country=VN'))).toEqual([[SKIN_A, 1], [SKIN_B, 1]]);
    expect(tops(await top())).toEqual([[SKIN_A, 4], [SKIN_B, 3], [SKIN_C, 1]]);
  });

  it('counts a vote cast by a user without a country in region and global only', async () => {
    expect(tops(await top('?country=VN'))).toEqual([[SKIN_A, 2], [SKIN_B, 1]]);
    expect(tops(await top('?region=ap'))[0]).toEqual([SKIN_A, 3]); // includes nc
  });

  it('applies to /v1/skins/votes?ids= and the voted flag stays personal', async () => {
    const ids = `${SKIN_A},${SKIN_B},${SKIN_C}`;
    const g = await e.req('GET', `/v1/skins/votes?ids=${ids}`, { token: c.vn1.token });
    expect(g.json.items.map((i: any) => [i.skinUuid, i.votes, i.voted])).toEqual([
      [SKIN_A, 5, true],
      [SKIN_B, 2, true],
      [SKIN_C, 1, false],
    ]);
    const vn = await e.req('GET', `/v1/skins/votes?ids=${ids}&country=VN`, { token: c.us1.token });
    expect(vn.json.items.map((i: any) => [i.skinUuid, i.votes, i.voted])).toEqual([
      [SKIN_A, 2, true], // us1 voted A but it counts under US; voted stays true
      [SKIN_B, 1, false],
      [SKIN_C, 0, true],
    ]);
    expect(vn.json.appliedScope).toEqual({ scope: 'country', country: 'VN', region: null });
    const region = await e.req('GET', `/v1/skins/votes?ids=${SKIN_A}&scope=region&region=kr`);
    expect(region.json.items).toEqual([expect.objectContaining({ skinUuid: SKIN_A, votes: 1, voted: false })]);
  });

  it('applies to the summary', async () => {
    const s = await e.req('GET', `/v1/skins/${SKIN_A}/summary?country=VN`, { token: c.us1.token });
    expect(s.json).toMatchObject({ votes: 2, voted: true, ratingCount: 0 });
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary`)).json.votes).toBe(5);
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary?scope=region&region=ap`)).json.votes).toBe(3);
    expectError(await e.req('GET', `/v1/skins/${SKIN_A}/summary?country=zzz`), 400, 'invalid_input');
  });
});

describe('skin reviews by reviewer country / region / language', () => {
  let c: Cast;
  const review = (u: { token: string }, skin: string, rating: number, body = '', extra: Record<string, unknown> = {}) =>
    e.req('PUT', `/v1/skins/${skin}/review`, { token: u.token, body: { weaponUuid: WEAPON_1, rating, body, ...extra } });

  beforeEach(async () => {
    c = await cast();
  });

  it('stores the reviewer country / region / language at review time (edits keep them)', async () => {
    const r = await review(c.vn1, SKIN_A, 5, 'tuyệt vời');
    expect(r.json).toMatchObject({ country: 'VN', region: 'ap', language: 'vi' });
    const withLang = await review(c.us1, SKIN_A, 4, 'nice', { language: 'en' });
    expect(withLang.json).toMatchObject({ country: 'US', region: 'na', language: 'en' });

    e.riotCountries.vn1 = 'usa';
    const moved = await e.login('vn1', { region: 'na', language: 'en' });
    const edited = await review(moved, SKIN_A, 3, 'edited');
    expect(edited.json).toMatchObject({ rating: 3, country: 'VN', region: 'ap', language: 'vi' });
    const edited2 = await review(moved, SKIN_A, 3, 'edited again', { language: 'en' });
    expect(edited2.json).toMatchObject({ country: 'VN', language: 'en' });
  });

  it('summarises per country / region and lists per scope and language', async () => {
    e.clock.t += 1000;
    await review(c.vn1, SKIN_A, 5, 'tốt');
    await review(c.vn2, SKIN_A, 4, 'ổn', { language: 'vi' });
    await review(c.us1, SKIN_A, 1, 'bad');
    await review(c.th1, SKIN_A, 3);
    await review(c.nc, SKIN_A, 2, 'no country');

    const all = await e.req('GET', `/v1/skins/${SKIN_A}/summary`);
    expect(all.json).toMatchObject({ ratingAvg: 3, ratingCount: 5, distribution: [1, 1, 1, 1, 1], reviewCount: 4 });
    const vn = await e.req('GET', `/v1/skins/${SKIN_A}/summary?country=VN`, { token: c.us1.token });
    expect(vn.json).toMatchObject({ ratingAvg: 4.5, ratingCount: 2, distribution: [0, 0, 0, 1, 1], reviewCount: 2 });
    expect(vn.json.myReview).toMatchObject({ rating: 1, mine: true }); // own review regardless of scope
    const ap = await e.req('GET', `/v1/skins/${SKIN_A}/summary?scope=region&region=ap`);
    expect(ap.json).toMatchObject({ ratingCount: 4, distribution: [0, 1, 1, 1, 1] });
    expect((await e.req('GET', `/v1/skins/${SKIN_A}/summary?country=JP`)).json).toMatchObject({
      ratingAvg: null,
      ratingCount: 0,
      distribution: [0, 0, 0, 0, 0],
    });

    const sorted = (a: string[]) => [...a].sort();
    const list = async (qs: string) =>
      (await e.req('GET', `/v1/skins/${SKIN_A}/reviews${qs}`)).json.items.map((r: any) => r.body).sort();
    expect(await list('')).toEqual(sorted(['', 'bad', 'no country', 'ổn', 'tốt']));
    expect(await list('?country=VN')).toEqual(sorted(['tốt', 'ổn']));
    expect(await list('?scope=region&region=ap')).toEqual(sorted(['', 'no country', 'ổn', 'tốt']));
    expect(await list('?language=vi')).toEqual(sorted(['ổn', 'tốt']));
    expect(await list('?language=en,vi')).toEqual(sorted(['bad', 'ổn', 'tốt']));
    expect(await list('?country=VN&language=en')).toEqual([]);
    expect(await list('?scope=global&language=th')).toEqual(['']);
    expectError(await e.req('GET', `/v1/skins/${SKIN_A}/reviews?language=xx`), 400, 'invalid_input');
    expectError(await e.req('GET', `/v1/skins/${SKIN_A}/reviews?scope=x`), 400, 'invalid_input');
    // sort=top with a scope keeps working with cursors.
    const p1 = await e.req('GET', `/v1/skins/${SKIN_A}/reviews?country=VN&sort=top&limit=1`);
    expect(p1.json.items).toHaveLength(1);
    const p2 = await e.req('GET', `/v1/skins/${SKIN_A}/reviews?country=VN&sort=top&limit=1&cursor=${p1.json.nextCursor}`);
    expect(p2.json.items).toHaveLength(1);
    expect(p2.json.nextCursor).toBeNull();
  });

  it('ranks by Bayesian rating within a country', async () => {
    // VN: A 5,5,5 and B 1,1,1;  US: A 1,1,1 and B 5,5,5 (needs 3 users each).
    e.riotCountries.vn3 = 'vnm';
    e.riotCountries.us2 = 'usa';
    e.riotCountries.us3 = 'usa';
    const vn3 = await e.login('vn3', { region: 'ap', language: 'vi' });
    const us2 = await e.login('us2', { region: 'na', language: 'en' });
    const us3 = await e.login('us3', { region: 'na', language: 'en' });
    for (const u of [c.vn1, c.vn2, vn3]) {
      await review(u, SKIN_A, 5);
      await review(u, SKIN_B, 1);
    }
    for (const u of [c.us1, us2, us3]) {
      await review(u, SKIN_A, 1);
      await review(u, SKIN_B, 5);
    }
    const order = async (qs: string) =>
      (await e.req('GET', `/v1/skins/top?sort=rating${qs}`)).json.items.map((i: any) => [i.skinUuid, i.ratingAvg, i.ratingCount]);
    expect(await order('&country=VN')).toEqual([[SKIN_A, 5, 3], [SKIN_B, 1, 3]]);
    expect(await order('&country=US')).toEqual([[SKIN_B, 5, 3], [SKIN_A, 1, 3]]);
    // Globally they tie on 3 average; the tie-break is the skin uuid.
    expect(await order('')).toEqual([[SKIN_A, 3, 6], [SKIN_B, 3, 6]]);
    // A country with fewer than 3 ratings per skin has no rating leaderboard.
    expect(await order('&country=TH')).toEqual([]);
    expect(await order('&region=na')).toEqual([[SKIN_B, 5, 3], [SKIN_A, 1, 3]]);
    // Reviews leaderboard by country too.
    const rev = (await e.req('GET', '/v1/skins/top?sort=reviews&country=VN')).json.items.map((i: any) => [i.skinUuid, i.ratingCount]);
    expect(rev).toEqual([[SKIN_A, 3], [SKIN_B, 3]]);
  });

  it('period=week counts only recent reviews in the chosen scope', async () => {
    await review(c.vn1, SKIN_A, 5, 'old');
    e.clock.t += 8 * DAY;
    await review(c.vn2, SKIN_A, 3, 'new');
    const week = await e.req('GET', '/v1/skins/top?sort=reviews&country=VN&period=week');
    expect(week.json.items).toEqual([expect.objectContaining({ skinUuid: SKIN_A, ratingCount: 1, ratingAvg: 3 })]);
    expect((await e.req('GET', '/v1/skins/top?sort=reviews&country=VN')).json.items[0]).toMatchObject({ ratingCount: 2 });
  });
});

describe('GET /v1/communities', () => {
  let c: Cast;
  const communities = async (qs = '', token?: string) => (await e.req('GET', `/v1/communities${qs}`, { token })).json.items;
  const lfg = (u: { token: string }, extra: Record<string, unknown> = {}) =>
    e.req('POST', '/v1/lfg', { token: u.token, body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 2, ...extra } });

  beforeEach(async () => {
    c = await cast();
  });

  it('lists countries with activity in the last 7 days, sorted by posts', async () => {
    await post(c.vn1.token, 'a');
    await post(c.vn1.token, 'b');
    await post(c.vn2.token, 'c');
    await post(c.us1.token, 'd');
    await post(c.nc.token, 'no country: not listed');
    await lfg(c.th1); // LFG-only country
    await lfg(c.us1, { region: 'na' });
    expect(await communities()).toEqual([
      { country: 'VN', posts: 3, authors: 2, lfg: 0 },
      { country: 'US', posts: 1, authors: 1, lfg: 1 },
      { country: 'TH', posts: 0, authors: 1, lfg: 1 },
    ]);
    // Public: same answer with a session; an invalid token is refused.
    expect(await communities('?period=week', c.kr1.token)).toHaveLength(3);
    expectError(await e.req('GET', '/v1/communities', { token: 'bad' }), 401, 'unauthorized');
  });

  it('counts distinct authors across posts and LFG, and breaks ties by lfg, authors, then code', async () => {
    await post(c.vn1.token, 'a');
    await post(c.us1.token, 'b');
    await post(c.th1.token, 'c');
    await lfg(c.th1);
    await lfg(c.vn2); // second VN author, via LFG only
    await post(c.kr1.token, 'd');
    expect(await communities()).toEqual([
      { country: 'TH', posts: 1, authors: 1, lfg: 1 },
      { country: 'VN', posts: 1, authors: 2, lfg: 1 },
      { country: 'KR', posts: 1, authors: 1, lfg: 0 },
      { country: 'US', posts: 1, authors: 1, lfg: 0 },
    ].sort((a, b) => b.posts - a.posts || b.lfg - a.lfg || b.authors - a.authors || (a.country < b.country ? -1 : 1)));
  });

  it('uses the last 7 days by default and period=all for everything; hidden posts do not count', async () => {
    await post(c.vn1.token, 'old');
    e.clock.t += 8 * DAY;
    const fresh = await post(c.us1.token, 'fresh');
    const spam = await post(c.us1.token, 'spam');
    for (const u of [c.vn1, c.vn2, c.th1]) {
      e.mature(u.user.id);
      await e.req('POST', '/v1/reports', { token: u.token, body: { targetType: 'post', targetId: spam.json.id, reason: 'spam' } });
    }
    expect(fresh.status).toBe(200);
    expect(await communities()).toEqual([{ country: 'US', posts: 1, authors: 1, lfg: 0 }]);
    expect(await communities('?period=week')).toEqual([{ country: 'US', posts: 1, authors: 1, lfg: 0 }]);
    expect(await communities('?period=all')).toEqual([
      { country: 'US', posts: 1, authors: 1, lfg: 0 },
      { country: 'VN', posts: 1, authors: 1, lfg: 0 },
    ]);
    expectError(await e.req('GET', '/v1/communities?period=month'), 400, 'invalid_input');
  });

  it('counts a replaced LFG post as activity but not an expired-and-cleaned one', async () => {
    await lfg(c.vn1);
    e.clock.t += 60_000;
    await lfg(c.vn1, { partyCode: 'ZZZZZZ' }); // replaces the first; both were posted this week
    expect(await communities()).toEqual([{ country: 'VN', posts: 0, authors: 1, lfg: 2 }]);
    // Only one is active.
    expect((await e.req('GET', '/v1/lfg?scope=global', { token: c.vn2.token })).json.items).toHaveLength(1);
    e.clock.t += 9 * DAY;
    e.repo.cleanup(e.clock.t);
    expect(await communities('?period=all')).toEqual([]);
  });

  it('is empty when nothing happened', async () => {
    expect(await communities()).toEqual([]);
  });
});

describe('old clients keep working', () => {
  it('a client that never sends language, country or scope gets the v1/v2 behaviour', async () => {
    const a = await e.login('olda');
    const b = await e.login('oldb');
    expect(a.user).toMatchObject({ region: 'ap', country: null, language: null });
    // Feed: same shape, everything from the same shard is visible (region fallback), Author has new null fields.
    const p = await post(a.token, 'hello');
    const feed = await e.req('GET', '/v1/posts', { token: b.token });
    expect(feed.json.items.map((i: any) => i.body)).toEqual(['hello']);
    expect(feed.json.nextCursor).toBeNull();
    expect(feed.json.items[0]).toMatchObject({ id: p.json.id, likes: 0, liked: false, comments: 0 });
    // LFG with the old explicit region param and no language.
    await e.req('POST', '/v1/lfg', { token: a.token, body: { region: 'ap', mode: 'competitive', partyCode: 'AB12CD', slots: 2 } });
    const lfg = await e.req('GET', '/v1/lfg?region=ap&mode=competitive', { token: b.token });
    expect(lfg.json.items).toHaveLength(1);
    expect(lfg.json.items[0]).toMatchObject({ language: 'vi', region: 'ap', status: 'open' });
    // Votes and the leaderboard: global by default.
    await e.req('PUT', `/v1/skins/${SKIN_A}/vote`, { token: a.token, body: { weaponUuid: WEAPON_1 } });
    const topRes = await e.req('GET', '/v1/skins/top', { token: b.token });
    expect(topRes.json.items).toEqual([expect.objectContaining({ skinUuid: SKIN_A, votes: 1, voted: false })]);
  });
});
