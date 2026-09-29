import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import { expectError, setup, type Env } from './helpers.js';

let e: Env;
beforeEach(() => {
  e = setup();
});
afterEach(() => e.close());

describe('country from Riot /userinfo', () => {
  it('maps the alpha-3 country to alpha-2 and returns it in the Author', async () => {
    e.riotCountries.alice = 'vnm';
    const { token, user } = await e.login('alice', { language: 'vi' });
    expect(user).toMatchObject({ country: 'VN', language: 'vi', region: 'ap' });
    const me = await e.req('GET', '/v1/me', { token });
    expect(me.json).toMatchObject({ country: 'VN', language: 'vi' });
  });

  it.each([
    ['usa', 'US'],
    ['gbr', 'GB'],
    ['kor', 'KR'],
    ['bra', 'BR'],
    ['VNM', 'VN'],
  ])('%s → %s', async (a3, a2) => {
    e.riotCountries.bob = a3;
    expect((await e.login('bob')).user.country).toBe(a2);
  });

  it('is null when Riot sends nothing or an unknown code', async () => {
    expect((await e.login('nocountry')).user.country).toBeNull();
    e.riotCountries.weird = 'zzz';
    expect((await e.login('weird')).user.country).toBeNull();
  });

  it('is refreshed on every auth (never taken from the client)', async () => {
    e.riotCountries.alice = 'vnm';
    expect((await e.login('alice')).user.country).toBe('VN');
    e.riotCountries.alice = 'usa';
    expect((await e.login('alice')).user.country).toBe('US');
    // The client cannot fake it, whatever it sends.
    const faked = await e.req('POST', '/v1/auth/riot', {
      body: { accessToken: 'good-alice', region: 'ap', country: 'JP', countryCode: 'JPN' },
    });
    expect(faked.json.user.country).toBe('US');
    // Riot reporting no (known) country clears it.
    e.riotCountries.alice = undefined;
    expect((await e.login('alice')).user.country).toBeNull();
  });

  it('is not editable through PATCH /v1/me (ignored)', async () => {
    e.riotCountries.alice = 'vnm';
    const { token } = await e.login('alice');
    // Ignored (like any unknown field), never applied.
    const res = await e.req('PATCH', '/v1/me', { token, body: { country: 'US', rankTier: 4 } });
    expect(res.status).toBe(200);
    expect(res.json).toMatchObject({ country: 'VN', rankTier: 4 });
    expect((await e.req('PATCH', '/v1/me', { token, body: { country: null } })).json.country).toBe('VN');
    expect((await e.req('GET', '/v1/me', { token })).json.country).toBe('VN');
  });
});

describe('app language', () => {
  it('is accepted by POST /v1/auth/riot in any accepted spelling and canonicalised', async () => {
    for (const [sent, stored] of [
      ['vi', 'vi'],
      ['pt-BR', 'pt'],
      ['zh_CN', 'zh-CN'],
      ['ZH-tw', 'zh-TW'],
      ['ja', 'ja'],
    ] as const) {
      expect((await e.login(`u-${sent}`, { language: sent })).user.language, sent).toBe(stored);
    }
  });

  it('is kept when a later auth does not send one (clients before v3), and replaced when it does', async () => {
    expect((await e.login('alice', { language: 'th' })).user.language).toBe('th');
    expect((await e.login('alice')).user.language).toBe('th');
    expect((await e.login('alice', { language: 'ko' })).user.language).toBe('ko');
    // Before any language was ever sent it is null.
    expect((await e.login('old')).user.language).toBeNull();
  });

  it('is validated before Riot is called', async () => {
    for (const language of ['xx', 'english', 'zh', 5, null, '']) {
      const res = await e.req('POST', '/v1/auth/riot', { body: { accessToken: 'good-alice', region: 'ap', language } });
      expectError(res, 400, 'invalid_input');
    }
    expect(e.riotTokens).toEqual([]);
  });

  it('is updatable via PATCH /v1/me', async () => {
    const { token } = await e.login('alice', { language: 'vi' });
    const res = await e.req('PATCH', '/v1/me', { token, body: { language: 'ja' } });
    expect(res.json.language).toBe('ja');
    // Other fields untouched; language untouched by other patches.
    const other = await e.req('PATCH', '/v1/me', { token, body: { rankTier: 3 } });
    expect(other.json).toMatchObject({ language: 'ja', rankTier: 3 });
    expectError(await e.req('PATCH', '/v1/me', { token, body: { language: 'xx' } }), 400, 'invalid_input');
    expectError(await e.req('PATCH', '/v1/me', { token, body: { language: null } }), 400, 'invalid_input');
    expect((await e.req('GET', '/v1/me', { token })).json.language).toBe('ja');
  });
});

describe('Author everywhere', () => {
  it('carries country and language in posts, comments, reviews, LFG and votes', async () => {
    e.riotCountries.alice = 'vnm';
    const { token, user } = await e.login('alice', { language: 'vi' });
    const post = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'hi' } });
    const comment = await e.req('POST', `/v1/posts/${post.json.id}/comments`, { token, body: { body: 'yo' } });
    const review = await e.req('PUT', '/v1/skins/11111111-1111-4111-8111-111111111111/review', {
      token,
      body: { weaponUuid: 'aaaaaaaa-aaaa-4aaa-8aaa-aaaaaaaaaaaa', rating: 5 },
    });
    const lfg = await e.req('POST', '/v1/lfg', {
      token,
      body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 1 },
    });
    for (const a of [post.json.author, comment.json.author, review.json.author, lfg.json.author]) {
      expect(a).toEqual({ ...user, country: 'VN', language: 'vi' });
    }
  });
});
