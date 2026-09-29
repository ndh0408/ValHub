import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import {
  cleanUserText,
  containsPhoneNumber,
  findMatches,
  moderate,
  MSG_INAPPROPRIATE,
  MSG_SCAM,
  stripDiacritics,
  stripLinks,
  tokenize,
} from '../src/moderation/filter.js';
import { WORDLIST } from '../src/moderation/vi-wordlist.js';
import { expectError, setup, SKIN_A, WEAPON_1, type Env } from './helpers.js';

const clean = (s: string) => moderate(s);
const masked = (s: string) => moderate(s).text;

describe('normalisation', () => {
  it('strips Vietnamese diacritics including đ', () => {
    expect(stripDiacritics('Đường Đi Làm, Lồn, Cặc, Buổi')).toBe('duong di lam, lon, cac, buoi');
    expect(stripDiacritics('ĐĨ')).toBe('di');
  });

  it('tokenizes with leetspeak, separators and spelled-out dots', () => {
    const t = (s: string) => tokenize(s).map((x) => x.plain);
    expect(t('d1t m3 m4y')).toEqual(['dit', 'me', 'may']);
    expect(t('$hit @ss')).toEqual(['shit', 'ass']);
    expect(t('đ.m v.c.l f*ck d-m đ_m')).toEqual(['dm', 'vcl', 'fck', 'dm', 'dm']);
    // Dots between real words do not merge them; version numbers stay numbers.
    expect(t('ok.đi v1.0 2025')).toEqual(['ok', 'di', 'vi', '0', '2025']);
    expect(t('Hello, world!')).toEqual(['hello', 'world']);
  });

  it('keeps original offsets for masking', () => {
    const [tok] = tokenize('  đ.m  ');
    expect(tok).toMatchObject({ start: 2, end: 5 });
  });
});

describe('profanity is masked', () => {
  it.each([
    ['đm', '***'],
    ['ĐM thằng này', '*** thằng này'],
    ['dm game lag', '*** game lag'],
    ['dmm', '***'],
    ['đcm team', '*** team'],
    ['vcl thật', '*** thật'],
    ['hay vl', 'hay ***'],
    ['vkl', '***'],
    ['clgt vậy', '*** vậy'],
    ['cc', '***'],
    ['ngu vl', '***'],
    ['đĩ', '***'],
    ['con đĩ', '***'],
    ['lồn', '***'],
    ['mặt lồn', '***'],
    ['buồi', '***'],
    ['cặc', '***'],
    ['địt', '***'],
    ['đụ má', '***'],
    ['dit me may', '***'],
    ['du ma', '***'],
    ['đéo biết chơi', '*** biết chơi'],
    ['fuck this', '*** this'],
    ['What The FUCK', 'What The ***'],
    ['you bitch', 'you ***'],
    ['shit happens', '*** happens'],
    ['wtf', '***'],
  ])('%s → %s', (input, out) => {
    const r = clean(input);
    expect(r.rejected).toBeNull();
    expect(r.text).toBe(out);
    expect(r.masked).toBeGreaterThan(0);
  });

  it('handles elongation, leetspeak and separators', () => {
    expect(masked('đmmmmmm')).toBe('***');
    expect(masked('vcllllll')).toBe('***');
    expect(masked('fuuuuuck')).toBe('***');
    expect(masked('lồnnnnn')).toBe('***');
    expect(masked('cccc')).toBe('***');
    expect(masked('đ.m')).toBe('***');
    expect(masked('Đ.C.M')).toBe('***');
    expect(masked('v.c.l')).toBe('***');
    expect(masked('d-m')).toBe('***');
    expect(masked('f*ck')).toBe('***');
    expect(masked('$hit')).toBe('***');
    expect(masked('b1tch')).toBe('***');
    expect(masked('l0z')).toBe('***');
    expect(masked('d1t')).toBe('***');
  });

  it('masks only the matched words and keeps the rest', () => {
    expect(masked('Trận này đm thua, vcl team mình ngu vl')).toBe('Trận này *** thua, *** team mình ***');
    expect(masked('GG! đm lag quá 😡')).toBe('GG! *** lag quá 😡');
    expect(masked('line1\nđm\nline3')).toBe('line1\n***\nline3');
  });
});

describe('no false positives', () => {
  it.each([
    'đi làm về muộn',
    'Mai đi chơi không?',
    'hoa cúc đẹp quá',
    'một lon nước ngọt',
    'Admin ơi cho hỏi',
    'dmin',
    'các bạn ơi',
    'buổi chiều leo rank',
    'đeo tai nghe vào',
    'được 20 điểm',
    'đĩa game',
    'đít-cô', // disco, hyphen merged but not in list as "ditco"
    'class assassin',
    'Scunthorpe',
    'cách chơi Jett',
    'chim cu gáy',
    'bà quê lên phố',
    'ốc lớn',
    'hạt óc chó rất bổ',
    'éo le quá',
    'ức hiếp người khác là sai',
    'xoạc chân khởi động',
    'CL tối nay',
    'bị ban acc rồi buồn quá',
    'Phantom 1775 VP',
    'cut skin',
    'cười đau cả bụng',
    'dì ơi',
    'địa điểm',
    'lol GG',
    'as fast as possible',
    'assist 10',
    'shitake nấm',
  ])('"%s" is untouched', (input) => {
    const r = clean(input);
    expect(r.rejected).toBeNull();
    expect(r.masked).toBe(0);
    expect(r.text).toBe(input);
  });

  it('abbreviations never match inside longer words', () => {
    expect(findMatches('admin cmd vlog cclub ccf dmz')).toEqual([]);
  });
});

describe('rejected categories', () => {
  it.each([
    ['hate', 'bọn bắc kỳ'],
    ['hate', 'đồ bê đê'],
    ['hate', 'nigga'],
    ['hate', 'you faggot'],
    ['hate', 'tàu khựa'],
    ['hate', 'n1gger'],
    ['sexual', 'cho xin nude'],
    ['sexual', 'bú lồn'],
    ['sexual', 'chịch không em'],
    ['sexual', 'send nudes'],
    ['sexual', 'hiếp dâm'],
    ['harassment', 'kys'],
    ['harassment', 'kill yourself'],
    ['harassment', 'đi chết đi'],
  ])('%s: %s', (category, input) => {
    expect(clean(input).rejected).toBe(category);
    expect(() => cleanUserText(input)).toThrowError(MSG_INAPPROPRIATE);
  });

  it('a harassment phrase wins over the profanity inside it', () => {
    const m = findMatches('bú lồn');
    expect(m).toHaveLength(1);
    expect(m[0]!.category).toBe('sexual');
  });
});

describe('scams', () => {
  it.each([
    'Bán acc Immortal giá rẻ',
    'bán nick full skin',
    'nhận cày thuê rank',
    'cay thue gia re',
    'boost rank uy tín',
    'sell acc cheap',
    'thu mua acc Valorant',
  ])('rejects "%s"', (input) => {
    expect(clean(input).rejected).toBe('scam');
    expect(() => cleanUserText(input)).toThrowError(MSG_SCAM);
  });

  it.each(['0912345678', '0912 345 678', '091.234.5678', '+84 912 345 678', '84912345678', 'Zalo: 0387-654-321'])(
    'rejects phone number %s',
    (input) => {
      expect(containsPhoneNumber(input)).toBe(true);
      expect(clean(`liên hệ ${input}`).rejected).toBe('phone');
    },
  );

  it.each(['1775 VP', 'rank 25', 'ACS 312', 'Riot ID KAYN#04082', 'năm 2025', '12345678', '0123'])(
    'does not treat %s as a phone number',
    (input) => {
      expect(containsPhoneNumber(input)).toBe(false);
    },
  );
});

describe('links', () => {
  it('strips http, www and shortener links, keeps https', () => {
    expect(stripLinks('xem http://evil.example/login nhé')).toEqual({ text: 'xem nhé', removed: 1 });
    expect(stripLinks('vào www.freevp.com đi')).toEqual({ text: 'vào đi', removed: 1 });
    expect(stripLinks('free VP https://bit.ly/abc123!')).toEqual({ text: 'free VP !', removed: 1 });
    expect(stripLinks('link: bit.ly/xyz')).toEqual({ text: 'link:', removed: 1 });
    expect(stripLinks('https://tinyurl.com/x và https://cutt.ly/y')).toEqual({ text: 'và', removed: 2 });
    expect(stripLinks('xem https://playvalorant.com/vi-vn/news/ nhé')).toEqual({
      text: 'xem https://playvalorant.com/vi-vn/news/ nhé',
      removed: 0,
    });
    expect(stripLinks('HTTPS://Www.Youtube.com/watch?v=1.')).toEqual({
      text: 'HTTPS://Www.Youtube.com/watch?v=1.',
      removed: 0,
    });
  });

  it('never masks inside kept https links', () => {
    const r = moderate('guide https://example.com/dm/vcl đm');
    expect(r.text).toBe('guide https://example.com/dm/vcl ***');
  });

  it('does not see phone numbers inside kept links', () => {
    expect(moderate('https://example.com/video/0912345678').rejected).toBeNull();
  });
});

describe('word list', () => {
  it('has no duplicate or empty entries', () => {
    const all = Object.values(WORDLIST).flat();
    expect(all.every((w) => w.trim().length > 0)).toBe(true);
    expect(new Set(all.map((w) => w.trim())).size).toBe(all.length);
  });

  it('every entry matches itself', () => {
    for (const [category, entries] of Object.entries(WORDLIST)) {
      for (const entry of entries) {
        const m = findMatches(entry);
        expect(m.length, entry).toBe(1);
        expect(m[0]!.category, entry).toBe(category);
      }
    }
  });
});

describe('applied to user content', () => {
  let e: Env;
  beforeEach(() => {
    e = setup();
  });
  afterEach(() => e.close());

  it('masks post bodies, comments, review bodies and LFG notes', async () => {
    const { token } = await e.login('alice');
    const post = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'đm lag vcl' } });
    expect(post.json.body).toBe('*** lag ***');
    const cm = await e.req('POST', `/v1/posts/${post.json.id}/comments`, { token, body: { body: 'ngu vl' } });
    expect(cm.json.body).toBe('***');
    const rv = await e.req('PUT', `/v1/skins/${SKIN_A}/review`, {
      token,
      body: { weaponUuid: WEAPON_1, rating: 1, body: 'skin như cứt' },
    });
    expect(rv.json.body).toBe('skin như ***');
    const lfg = await e.req('POST', '/v1/lfg', {
      token,
      body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 1, note: 'vào đi dm' },
    });
    expect(lfg.json.note).toBe('vào đi ***');
    const patched = await e.req('PATCH', `/v1/lfg/${lfg.json.id}`, { token, body: { note: 'fuck' } });
    expect(patched.json.note).toBe('***');
  });

  it('rejects hate / sexual / scam content with invalid_input', async () => {
    const { token } = await e.login('alice');
    const r1 = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'bọn bắc kỳ' } });
    expectError(r1, 400, 'invalid_input');
    expect(r1.json.error.message).toBe(MSG_INAPPROPRIATE);
    const postId = (await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'hi' } })).json.id;
    expectError(
      await e.req('POST', `/v1/posts/${postId}/comments`, { token, body: { body: 'cho xin nude' } }),
      400,
      'invalid_input',
    );
    const scam = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'bán acc zalo 0912345678' } });
    expectError(scam, 400, 'invalid_input');
    expect(scam.json.error.message).toBe(MSG_SCAM);
    expectError(
      await e.req('PUT', `/v1/skins/${SKIN_A}/review`, { token, body: { weaponUuid: WEAPON_1, rating: 5, body: 'kys' } }),
      400,
      'invalid_input',
    );
    expectError(
      await e.req('POST', '/v1/lfg', {
        token,
        body: { region: 'ap', mode: 'unrated', partyCode: 'ABCDEF', slots: 1, note: 'cày thuê giá rẻ' },
      }),
      400,
      'invalid_input',
    );
  });

  it('strips bad links; a post that becomes empty is rejected', async () => {
    const { token } = await e.login('alice');
    const ok = await e.req('POST', '/v1/posts', {
      token,
      body: { kind: 'text', body: 'free skin http://phish.example/x xem https://playvalorant.com' },
    });
    expect(ok.json.body).toBe('free skin xem https://playvalorant.com');
    expectError(
      await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'https://bit.ly/free-vp' } }),
      400,
      'invalid_input',
    );
    const postId = ok.json.id;
    expectError(
      await e.req('POST', `/v1/posts/${postId}/comments`, { token, body: { body: 'bit.ly/abc' } }),
      400,
      'invalid_input',
    );
  });
});
