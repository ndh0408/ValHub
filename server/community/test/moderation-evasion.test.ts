import { describe, expect, it } from 'vitest';
import { canon, cleanUserText, containsPhoneNumber, moderate, stripDiacritics, tokenize } from '../src/moderation/filter.js';

const ZW = '​';
const masked = (text: string, language?: string) => moderate(text, { language }).text;
const verdict = (text: string, language?: string) => {
  const r = moderate(text, { language });
  return r.rejected ?? (r.masked > 0 ? 'masked' : 'clean');
};

describe('invisible characters do not hide words', () => {
  it.each([
    ['zero-width space', `f${ZW}u${ZW}c${ZW}k`],
    ['zero-width non-joiner / joiner', 'f‌u‍c‌k'],
    ['soft hyphen', 'fu­ck'],
    ['word joiner', 'sh⁠it'],
    ['bidi override / isolate', '‮fuck‬ ⁦shit⁩'],
    ['LRM / RLM', 'fu‎ck sh‏it'],
    ['variation selector', 'f️uck'],
    ['byte order mark', '﻿fuck'],
    ['combining grapheme joiner', 'fu͏ck'],
    ['Hangul filler', 'fㅤuck'],
    ['Mongolian vowel separator', 'fu᠎ck'],
    ['tag character', 'f\u{E0041}uck'],
    ['many at once', `f${ZW}${ZW}⁠u­${ZW}c﻿k`],
  ])('%s', (_name, text) => {
    expect(verdict(text, 'en')).toBe('masked');
  });

  it('works for Vietnamese phrases and in every language', () => {
    expect(masked(`đ${ZW}m thằng này`, 'vi')).toBe('*** thằng này');
    expect(verdict(`d${ZW}i${ZW}t m${ZW}e`, 'vi')).toBe('masked');
    expect(verdict(`địt${ZW}mẹ`, 'vi')).toBe('masked'); // no space at all: read as the phrase
    expect(verdict(`l${ZW}ồ${ZW}n`, 'vi')).toBe('masked');
    expect(verdict(`k${ZW}y${ZW}s`, 'en')).toBe('harassment');
    expect(verdict(`n${ZW}i${ZW}g${ZW}g${ZW}e${ZW}r`, 'en')).toBe('hate');
    expect(verdict(`bán${ZW}acc`, 'vi')).toBe('scam');
    expect(verdict(`cày${ZW}thuê rank`, 'vi')).toBe('scam');
    expect(verdict(`시${ZW}발`, 'ko')).toBe('masked');
    expect(verdict(`傻${ZW}逼`, 'zh-CN')).toBe('masked');
    expect(verdict(`ค${ZW}ว${ZW}ย`, 'th')).toBe('masked');
    expect(verdict(`бл${ZW}ядь`, 'ru')).toBe('masked');
  });

  it('a zero-width space used as a word separator does not merge the word into its neighbour', () => {
    expect(masked(`dm${ZW}hello`, 'vi')).toBe(`***hello`);
    expect(masked(`hello${ZW}dm`, 'vi')).toBe(`hello***`);
    expect(masked(`fuck${ZW}you${ZW}dm`, 'en')).toBe(`***youdm`);
  });

  it('masks exactly the word, not its neighbours', () => {
    expect(masked(`Trận này ${'d'}${ZW}m thua`, 'vi')).toBe('Trận này *** thua');
    expect(masked(`tôi ${'f'}${ZW}u${ZW}c${ZW}k đi`, 'en')).toBe('tôi *** đi');
  });
});

describe('look-alike (homoglyph) letters', () => {
  it.each([
    ['Cyrillic с', 'fuсk'],
    ['Cyrillic і', 'shіt'],
    ['Cyrillic ѕ + һ + і', 'ѕһіt'],
    ['Cyrillic о and і', 'bіtch and dіck'],
    ['Greek υ', 'fυck'],
    ['Greek ο + ρ', 'ρussy'],
    ['full-width', 'ｆｕｃｋ'],
    ['math bold', '𝐟𝐮𝐜𝐤'],
    ['math script', '𝓯𝓾𝓬𝓴'],
    ['math double-struck', '𝕗𝕦𝕔𝕜'],
    ['circled', 'ⓕⓤⓒⓚ'],
    ['squared', '🄵🅄🄲🄺'],
    ['upper-case look-alikes', 'FUСK'],
  ])('%s', (_n, text) => {
    expect(verdict(text, 'en')).toBe('masked');
  });

  it('a Cyrillic look-alike does not turn Latin text into "another language"', () => {
    // With a Cyrillic letter inside, the text is still Latin: the Vietnamese teencode rules apply.
    expect(verdict('dіt mе', 'vi')).toBe('masked');
    expect(verdict('vсl', 'en')).toBe('clean');
    expect(verdict('ｄｍ', 'vi')).toBe('masked');
    expect(verdict('ＤＭ', undefined)).toBe('clean');
  });

  it('Latin look-alikes inside a Russian word', () => {
    expect(verdict('xуй', 'ru')).toBe('masked'); // Latin x + Cyrillic у, й
    expect(verdict('наxуй', 'ru')).toBe('masked'); // Latin x
    expect(verdict('пoхуй', 'ru')).toBe('masked'); // Latin o
    expect(verdict('cука', 'ru')).toBe('masked'); // Latin c
    expect(verdict('хуй', 'ru')).toBe('masked'); // untouched Cyrillic still matches
  });

  it('Greek and Cyrillic text is not damaged', () => {
    for (const t of ['Καλημέρα κόσμε, τι κάνεις;', 'Привет, как дела?', 'Привіт, як справи?', 'сообщение о ресурсе', 'Здравей свят']) {
      expect(verdict(t, 'en')).toBe('clean');
      expect(masked(t, undefined)).toBe(t.replace(/\u200b/g, /[\u0e00-\u0e7f]/.test(t) ? '\u200b' : ''));
    }
  });

  it('canon() folds stylised letters, invisibles and Arabic variants', () => {
    expect(canon('ＦＵＣＫ')).toBe('fuck');
    expect(canon('𝐟𝐮𝐜𝐤')).toBe('fuck');
    expect(canon(`a${ZW}b­c`)).toBe('abc');
    expect(canon('ﬁ')).toBe('fi');
    expect(canon('Straße')).toBe('strasse');
    expect(stripDiacritics('Đường ｄｍ')).toBe('duong dm');
  });
});

describe('spelled-out words', () => {
  it.each([
    'f u c k',
    'F  U  C  K',
    'f-u-c-k',
    'f.u.c.k',
    'f,u,c,k',
    'f/u/c/k',
    'f|u|c|k',
    'f_u_c_k',
    'f*u*c*k',
    'f u.c k',
    'f, u, c, k',
    'f🔥u🔥c🔥k',
    'f\nu\nc\nk',
    'f . u . c . k',
    's h i t',
    'b i t c h',
    'f.*.u.*.c.*.k',
    'f--u--c--k',
    'f u u u c c k',
  ])('%j', (text) => {
    expect(verdict(text, 'en')).toBe('masked');
  });

  it('multi-word Vietnamese phrases and abbreviations', () => {
    for (const t of ['đ i t m e', 'd i t  m e', 'đ.i.t.m.e', 'd..i..t m..e', 'dit_me', 'dit-me', 'dit*me', 'đ i t   m ẹ', 'địt_mẹ', 'ngu-vl', 'n g u  v l', 'n g u v l']) {
      expect(verdict(t, 'vi'), t).toBe('masked');
    }
    for (const t of ['v c l', 'v.c.l', 'V C L', 'c l g t', 'd m m', 'l ồ n', 'c ặ c', 'đ ụ  m á']) {
      expect(verdict(t, 'vi'), t).toBe('masked');
    }
  });

  it('rejections are evaded the same way and caught the same way', () => {
    expect(verdict('k y s', 'en')).toBe('harassment');
    expect(verdict('k i l l  y o u r s e l f', 'en')).toBe('harassment');
    expect(verdict('n i g g e r', 'en')).toBe('hate');
    expect(verdict('f a g g o t', 'en')).toBe('hate');
    expect(verdict('r a p e', 'en')).toBe('sexual');
    expect(verdict('b á n  a c c', 'vi')).toBe('scam');
    expect(verdict('c à y  t h u ê', 'vi')).toBe('scam');
    expect(verdict('c.à.y t.h.u.ê rank', 'vi')).toBe('scam');
    expect(verdict('s e l l  a c c', 'en')).toBe('scam');
    expect(() => cleanUserText('k y s', 'en')).toThrowError('Nội dung chứa từ ngữ không phù hợp');
  });

  it('other scripts', () => {
    expect(verdict('他 妈 的', 'zh-CN')).toBe('masked');
    expect(verdict('傻 逼 啊', 'zh-CN')).toBe('masked'); // "傻 逼 啊" → 傻逼啊 contains the word
    expect(verdict('시 발 놈', 'ko')).toBe('masked');
    expect(verdict('ค ว ย', 'th')).toBe('masked');
    expect(verdict('п и з д е ц', 'ru')).toBe('masked');
    expect(masked('この ク ソ 野 郎', 'ja')).toBe('この ***');
  });

  it('masks the whole spelled-out span and nothing else', () => {
    expect(masked('tôi nói f u c k đấy', 'en')).toBe('tôi nói *** đấy');
    expect(masked('a v c l b', 'vi')).toBe('a *** b'); // the word hides inside a longer run of single letters
    expect(masked('I f u c k you', 'en')).toBe('I *** you');
  });

  it('runs are bounded (no quadratic blow-up) and a long spelled sentence is fine', () => {
    const t = Date.now();
    for (const text of ['a '.repeat(500), `${'a '.repeat(30)}f u c k ${'b '.repeat(30)}`, `a${ZW}`.repeat(400), 'x.'.repeat(400)]) {
      moderate(text, { language: 'vi', country: 'VN' });
    }
    expect(Date.now() - t).toBeLessThan(2000);
    expect(verdict(`${'a '.repeat(30)}f u c k`, 'en')).toBe('masked');
  });
});

describe('phone numbers with obfuscation', () => {
  it.each([
    '０９１２３４５６７８',
    '09​12​345​678',
    '0.9.1.2.3.4.5.6.7.8',
    '0 9 1 2 3 4 5 6 7 8',
    '0-9-1-2-3-4-5-6-7-8',
    '0912.345.678',
    '0912 345 678',
    '091·234·5678',
    '+84 91 234 5678',
    '＋８４ ９１２３４５６７８',
    '+62​812-3456-7890',
    '＋６２ ８１２３４５６７８９０',
  ])('%j is a phone number', (text) => {
    expect(containsPhoneNumber(`gọi ${text} nhé`)).toBe(true);
    expect(verdict(`gọi ${text} nhé`, 'vi')).toBe('phone');
  });

  it.each(['2025-09-01', '09/12/2025', '1 2 3 4 5 6 7 8 9 10', '1775 VP', 'rank 25', '12345678', '5 v 5', '0123', '+100 VP'])(
    '%j is not',
    (text) => {
      expect(containsPhoneNumber(text)).toBe(false);
    },
  );
});

describe('legitimate text is not damaged', () => {
  it('ordinary text with the same characters', () => {
    for (const t of [
      'Bạn ơi cho hỏi về skin Vandal',
      'Mình thích chơi Valorant vào buổi tối',
      'The quick brown fox jumps over the lazy dog',
      'Kỳ này đi làm về muộn, đừng đợi cơm nhé',
    ]) {
      expect(masked(t, 'vi')).toBe(t);
    }
  });

  it('spelled-out letters that are not listed words', () => {
    for (const t of ['U S A', 'N B A', 'I O S', 'A B C D', 'Q & A', 'R G B', 'S M S', 'T V', 'M T V', 'C V', 'W W W', 'H T M L', 'A K A', 'X Y Z', 'P R O', 'G G W P', 'a b c d e f g', '1 2 3', 'V 1 . 0', '5 a m', 'G P S']) {
      expect(verdict(t, 'en'), t).toBe('clean');
      expect(verdict(t, 'vi'), t).toBe('clean');
    }
  });

  it('emoji sequences, keycaps, flags, ZWJ families and skin tones', () => {
    for (const t of ['👨‍👩‍👧‍👦 gia đình', '🏳️‍🌈 pride', '👍🏽 ok', '❤️ yêu', '1️⃣ 2️⃣ 3️⃣', '🇻🇳 Việt Nam', 'GG 🔥🔥🔥']) {
      expect(masked(t, 'vi')).toBe(t);
    }
  });

  it('scripts that legitimately use zero-width characters', () => {
    for (const t of ['می‌خواهم بروم', 'नमस्ते‍ दुनिया', 'สวัสดีครับ​วันนี้อากาศดี', '你好​世界', 'ಕನ್ನಡ ಭಾಷೆ']) {
      expect(masked(t, undefined)).toBe(t.replace(/\u200b/g, /[\u0e00-\u0e7f]/.test(t) ? '\u200b' : ''));
    }
  });

  it('hyphens, underscores, dots and slashes inside normal words', () => {
    for (const t of ['pique-nique', 'co-op', 'e-mail', 'user_name', 'v1.0', 'www.example.com', 'a.b.c', 'd.m.y', 'end-to-end', 'well-known', 'x-ray', '24/7', 'r&d', 'tam_biet']) {
      expect(verdict(t, 'en'), t).toBe('clean');
    }
  });

  it('tokenize keeps its behaviour for plain text', () => {
    const t = (s: string) => tokenize(s).map((x) => x.plain);
    expect(t('Hello, world!')).toEqual(['hello', 'world']);
    expect(t('ok.đi v1.0')).toEqual(['ok', 'di', 'vi', '0']);
    expect(t('đ.m v.c.l f*ck d-m')).toEqual(['dm', 'vcl', 'fck', 'dm']);
    expect(tokenize(`a${ZW}b`)).toHaveLength(1); // read as one word
    expect(tokenize(`a${ZW}b`, [], 'split')).toHaveLength(2); // ... or as two
    expect(tokenize(`${ZW}${ZW}`)).toEqual([]);
  });
});
