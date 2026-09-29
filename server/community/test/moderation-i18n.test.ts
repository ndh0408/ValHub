import fs from 'node:fs';
import path from 'node:path';
import { afterEach, beforeEach, describe, expect, it } from 'vitest';
import {
  cleanUserText,
  containsPhoneNumber,
  findMatches,
  listsFor,
  moderate,
  MSG_INAPPROPRIATE,
  MSG_SCAM,
  type RejectReason,
} from '../src/moderation/filter.js';
import { LIST_KEYS, LISTS_NEEDING_NATIVE_REVIEW, listKeyForLanguage, WORDLISTS } from '../src/moderation/wordlists.js';
import { expectError, setup, SKIN_A, WEAPON_1, type Env } from './helpers.js';

interface LangCase {
  language: string;
  /** [input, expected masked output] */
  masked: [string, string][];
  rejected: [string, RejectReason][];
  /** Ordinary sentences (and look-alike words) that must pass untouched. */
  clean: string[];
}

/**
 * Best-effort lists: these samples only pin down what the lists are meant to do (a native speaker
 * must still review the lists themselves). Every sample uses well-known profanity for the "masked"
 * and "rejected" cases, and ordinary text for "clean".
 */
const CASES: LangCase[] = [
  {
    language: 'de',
    masked: [
      ['Du bist so ein Arschloch', 'Du bist so ein ***'],
      ['Scheiße, schon wieder verloren', '***, schon wieder verloren'],
    ],
    rejected: [
      ['Du Spast', 'hate'],
      ['geh sterben', 'harassment'],
      ['Ich verkaufe Account günstig', 'scam'],
    ],
    clean: [
      'Wir treffen uns um acht Uhr',
      'Das Wetter ist heute schön',
      'Ich kaufe einen neuen Skin',
      'Stirb langsam ist ein guter Film',
      'Der Schwanz des Hundes ist lang',
      'Die Scheibe ist kaputt',
    ],
  },
  {
    language: 'es',
    masked: [
      ['Eres un hijo de puta', 'Eres un ***'],
      ['Qué mierda de juego', 'Qué *** de juego'],
    ],
    rejected: [
      ['maricón', 'hate'],
      ['ojalá te mueras', 'harassment'],
      ['Vendo cuenta de Valorant', 'scam'],
    ],
    clean: [
      'Me gusta el cono de helado',
      'La puerta está abierta',
      'Voy a comprar una skin nueva',
      'Compro una cuenta de ahorro en el banco',
      'El niño juega en el parque',
      'El pelo negro es bonito',
    ],
  },
  {
    language: 'fr',
    masked: [
      ['Putain de lag', '*** de lag'],
      ['ferme ta gueule', '***'],
    ],
    rejected: [
      ['sale arabe', 'hate'],
      ['tue toi', 'harassment'],
      ['Je vends compte Valorant', 'scam'],
    ],
    clean: [
      'Nous allons faire un pique-nique demain',
      'Le compte bancaire est ouvert',
      'Je bois un café avec du lait',
      'La chatte dort sur le canapé',
      'Il fait très beau aujourd hui',
    ],
  },
  {
    language: 'pt',
    masked: [
      ['Que merda de jogo', 'Que *** de jogo'],
      ['foda-se', '***'],
    ],
    rejected: [
      ['viado', 'hate'],
      ['vai se matar', 'harassment'],
      ['Vendo conta de Valorant', 'scam'],
    ],
    clean: [
      'A porta está aberta',
      'O jogo começa às oito horas',
      'A conta do restaurante chegou',
      'Ele é um puto de cinco anos',
      'A rola voou pelo céu',
    ],
  },
  {
    language: 'it',
    masked: [
      ['Che cazzo di gioco', 'Che *** di gioco'],
      ['Sei uno stronzo', 'Sei uno ***'],
    ],
    rejected: [
      ['sei un frocio', 'hate'],
      ['ammazzati', 'harassment'],
      ['Vendo account Valorant', 'scam'],
    ],
    clean: [
      'Vado al mercato a comprare la frutta',
      'La guerra di Troia è finita',
      'Il cane ha mangiato la cena',
      'Che culo che hai avuto oggi',
      'La crepa nel muro è profonda',
    ],
  },
  {
    language: 'id',
    masked: [
      ['Dasar bangsat', 'Dasar ***'],
      ['kontol lu', '*** lu'],
      ['anjing lu', '***'],
    ],
    rejected: [
      ['bencong', 'hate'],
      ['mati aja lu', 'harassment'],
      ['Jual akun Valorant murah', 'scam'],
    ],
    clean: [
      'Anjing itu berlari di taman',
      'Saya suka makan nasi goreng',
      'Kami bermain Valorant malam ini',
      'Kita belajar Tai Chi hari ini',
      'Aku beli akun baru kemarin',
    ],
  },
  {
    language: 'pl',
    masked: [
      ['Ale kurwa lag', 'Ale *** lag'],
      ['Ty chuju', 'Ty ***'],
      ['spierdalaj stąd', '*** stąd'],
    ],
    rejected: [
      ['ciota', 'hate'],
      ['zdychaj', 'harassment'],
      ['Sprzedam konto Valorant', 'scam'],
    ],
    clean: [
      'Idziemy dziś do kina',
      'Kurczak z ryżem na obiad',
      'Mam nowy skin do Vandala',
      'Gwałtowna burza nad miastem',
      'Kupiłem nowe konto bankowe',
    ],
  },
  {
    language: 'tr',
    masked: [
      ['Siktir git', '***'],
      ['orospu çocuğu', '*** çocuğu'],
      ['amk oyunu', '*** oyunu'],
    ],
    rejected: [
      ['ibne', 'hate'],
      ['geber', 'harassment'],
      ['Hesap satıyorum Valorant', 'scam'],
    ],
    clean: [
      'Şikayet ediyorum',
      'Bugün hava çok güzel',
      'Yeni bir skin aldım',
      'Sık sık oynuyoruz',
      'Şık bir elbise',
      'Ananas suyu içtim',
    ],
  },
  {
    language: 'ru',
    masked: [
      ['Блядь, опять слив', '***, опять слив'],
      ['Ты сука', 'Ты ***'],
      ['иди нахуй', 'иди ***'],
      ['blyat', '***'],
      ['Он охуенный игрок', 'Он *** игрок'],
    ],
    rejected: [
      ['пидор', 'hate'],
      ['сдохни', 'harassment'],
      ['Продам аккаунт Валорант', 'scam'],
    ],
    clean: [
      'Привет, как дела?',
      'Мы играем в Валорант вечером',
      'Хачапури очень вкусный',
      'Открыли шлюз на реке',
      'Мандарин и сукно',
      'Хуан Карлос приехал',
      'Трахея и бронхи',
      'Я купил новый скин',
    ],
  },
  {
    language: 'ar',
    masked: [
      ['ابن الكلب', '***'],
      ['كس امك', '***'],
      ['يا شرموطة', 'يا ***'],
    ],
    rejected: [
      ['لوطي', 'hate'],
      ['اقتل نفسك', 'harassment'],
      ['حساب للبيع', 'scam'],
    ],
    clean: [
      'مرحبا كيف حالك',
      'الطقس جميل اليوم',
      'كسر الزجاج',
      'كسب المباراة',
      'زبدة وخبز',
      'أنا أحب لعبة فالورانت',
      'ذهبت إلى السوق',
    ],
  },
  {
    language: 'th',
    masked: [
      ['ไอ้เหี้ยนี่', 'ไอ้***นี่'],
      ['ควยอะไรเนี่ย', '***อะไรเนี่ย'],
    ],
    rejected: [
      ['ไปตายซะ', 'harassment'],
      ['ไอ้ตุ๊ด', 'hate'],
      ['ขายไอดี ราคาถูก', 'scam'],
    ],
    clean: [
      'สวัสดีครับ วันนี้อากาศดี',
      'ขอบคุณมากครับ',
      'ฉันชอบเล่นวาโลแรนท์',
      'ไปตลาดซื้อผลไม้',
      'โหดเหี้ยมมาก',
      'เชี่ยวชาญมาก',
      'ห่างไกลจากบ้าน',
    ],
  },
  {
    language: 'ko',
    masked: [
      ['시발 뭐야', '*** 뭐야'],
      ['병신아', '***'],
      ['존나 어렵다', '*** 어렵다'],
    ],
    rejected: [
      ['짱깨', 'hate'],
      ['자살해', 'harassment'],
      ['계정 판매합니다', 'scam'],
    ],
    clean: [
      '안녕하세요 오늘 날씨가 좋네요',
      '저는 발로란트를 좋아해요',
      '2016년은 병신년이었다',
      '이곳이 시작의 시발점이다',
      '보지 마세요',
      '자지 않아요',
      '고기를 씹어 먹었다',
      '존경합니다',
    ],
  },
  {
    language: 'ja',
    masked: [
      ['このクソ野郎', 'この***'],
      ['ファックユー', '***ユー'],
    ],
    rejected: [
      ['死ね', 'harassment'],
      ['キチガイ', 'hate'],
      ['アカウント売ります', 'scam'],
    ],
    clean: [
      'こんにちは、今日はいい天気ですね',
      '一緒にヴァロラントをプレイしませんか',
      'ニクソン大統領が来た',
      'おかまいなく',
      'アブストラクトな絵',
      'カスタムゲームで遊ぼう',
      '死ねない理由がある',
    ],
  },
  {
    language: 'zh-CN',
    masked: [
      ['你这个傻逼', '你这个***'],
      ['他妈的什么游戏', '***什么游戏'],
    ],
    rejected: [
      ['你去死', 'harassment'],
      ['智障', 'hate'],
      ['出售账号', 'scam'],
    ],
    clean: [
      '你好，今天天气很好',
      '我喜欢玩无畏契约',
      '我操心这件事',
      '体操比赛很精彩',
      '我们一起去打游戏吧',
      '傻瓜',
      '卖火柴的小女孩',
    ],
  },
  {
    language: 'zh-TW',
    masked: [['他媽的', '***']],
    rejected: [['殺你全家', 'harassment']],
    clean: ['請問這個賬號怎麼登入', '今天天氣很好'],
  },
];

describe.each(CASES)('content filter: $language', ({ language, masked, rejected, clean }) => {
  it.each(masked)('masks "%s"', (input, out) => {
    const r = moderate(input, { language });
    expect(r.rejected).toBeNull();
    expect(r.text).toBe(out);
    expect(r.masked).toBeGreaterThan(0);
  });

  it.each(rejected)('rejects "%s" (%s)', (input, reason) => {
    expect(moderate(input, { language }).rejected).toBe(reason);
    expect(() => cleanUserText(input, language)).toThrowError(reason === 'scam' ? MSG_SCAM : MSG_INAPPROPRIATE);
  });

  it.each(clean)('leaves "%s" untouched', (input) => {
    const r = moderate(input, { language });
    expect(r.rejected).toBeNull();
    expect(r.masked).toBe(0);
    expect(r.text).toBe(input);
  });
});

describe('script detection without a declared language', () => {
  it.each([
    ['Привет, ты сука', 'Привет, ты ***'],
    ['이 병신아', '이 ***'],
    ['你这个傻逼', '你这个***'],
    ['ไอ้เหี้ยนี่', 'ไอ้***นี่'],
    ['ابن الكلب', '***'],
    ['このクソ野郎', 'この***'],
    ['Scheiße ist das', '*** ist das'],
    ['orospu çocuğu', '*** çocuğu'],
    ['co mien nam dm', 'co mien nam ***'],
  ])('masks %s', (input, out) => {
    expect(moderate(input).text).toBe(out);
  });

  it('picks lists from the script and charset', () => {
    expect(listsFor('hello there')).toEqual(['en', 'vi']);
    expect(listsFor('hello there', 'en')).toEqual(['en', 'vi']);
    expect(listsFor('hola amigo', 'es')).toEqual(['en', 'es']);
    expect(listsFor('hola amigo', 'es', 'VN')).toEqual(['en', 'es', 'vi']);
    expect(listsFor('hola amigo', 'en', 'MX')).toEqual(['en', 'vi', 'es']);
    expect(listsFor('hallo', 'de', 'CH')).toEqual(['en', 'de', 'fr', 'it']);
    expect(listsFor('привет', 'en')).toEqual(['en', 'ru']);
    expect(listsFor('привет')).toEqual(['en', 'ru']);
    expect(listsFor('안녕')).toEqual(['en', 'ko']);
    expect(listsFor('こんにちは')).toEqual(['en', 'ja']);
    expect(listsFor('你好')).toEqual(['en', 'zh']);
    expect(listsFor('你好', 'ja')).toEqual(['en', 'ja', 'zh']);
    expect(listsFor('สวัสดี')).toEqual(['en', 'th']);
    expect(listsFor('مرحبا')).toEqual(['en', 'ar']);
    expect(listsFor('tôi là người việt', 'es')).toEqual(['en', 'es', 'vi']);
    expect(listsFor('Straße', 'en')).toEqual(['en', 'de', 'vi']);
    expect(listsFor('¿qué?', 'en')).toEqual(['en', 'es', 'vi']);
    expect(listsFor('łódź')).toEqual(['en', 'pl', 'vi']);
    expect(listsFor('şık', 'en')).toEqual(['en', 'tr', 'vi']);
    expect(listsFor('hello', 'zh-TW')).toEqual(['en', 'zh']);
    expect(listsFor('hello', 'pt-BR')).toEqual(['en', 'pt']);
  });

  it('maps content languages to lists', () => {
    expect(listKeyForLanguage('zh-CN')).toBe('zh');
    expect(listKeyForLanguage('zh_TW')).toBe('zh');
    expect(listKeyForLanguage('pt-BR')).toBe('pt');
    expect(listKeyForLanguage('vi')).toBe('vi');
    expect(listKeyForLanguage('any')).toBeNull();
    expect(listKeyForLanguage(null)).toBeNull();
    expect(listKeyForLanguage('xx')).toBeNull();
  });

  it('only applies a language list to that language (no cross-language false positives)', () => {
    // "sik" is vulgar in Turkish; "asu" is Javanese; "cazzo" is Italian; "fick" is German.
    expect(moderate('sik asu cazzo fick', { language: 'en', country: 'US' }).text).toBe('sik asu cazzo fick');
    expect(moderate('sik asu cazzo fick', { language: 'tr' }).text).toBe('*** asu cazzo fick');
  });
});

describe('unsupported languages are never rejected for being unsupported', () => {
  it.each([
    ['Hindi', 'नमस्ते, आप कैसे हैं? आज मौसम अच्छा है'],
    ['Greek', 'Γεια σου κόσμε, τι κάνεις σήμερα;'],
    ['Hebrew', 'שלום עולם, מה שלומך היום?'],
    ['Swahili', 'Habari yako rafiki, leo ni siku nzuri'],
    ['Ukrainian', 'Привіт світе, як справи сьогодні?'],
    ['Dutch', 'Hallo wereld, hoe gaat het vandaag met je?'],
    ['Bengali', 'হ্যালো বিশ্ব, আপনি কেমন আছেন'],
    ['Emoji only', '🔥🔥🎮'],
  ])('%s passes unchanged', (_name, input) => {
    for (const language of [undefined, 'en', 'vi', 'ru', 'ko']) {
      const r = moderate(input, { language });
      expect(r.rejected, `${language}`).toBeNull();
      expect(r.text).toBe(input);
    }
  });

  it('English profanity is still caught inside unsupported-language text', () => {
    expect(moderate('Habari fuck rafiki').text).toBe('Habari *** rafiki');
  });
});

describe('phone numbers (international)', () => {
  it.each(['+1 415 555 2671', '+1 (415) 555-2671', '+62 812-3456-7890', '+7 999 123 45 67', '+44 7911 123456', '+84 912 345 678'])(
    'rejects %s',
    (input) => {
      expect(containsPhoneNumber(input)).toBe(true);
      expect(moderate(`gọi ${input}`).rejected).toBe('phone');
    },
  );

  it.each(['+100 VP', '+1000 RR', 'rank +5', '10:30', '1775 VP', '+12', 'a+b=12345678'])('does not reject %s', (input) => {
    expect(containsPhoneNumber(input)).toBe(false);
  });
});

describe('word lists', () => {
  it('ship for all 16 lists; every list covers profanity', () => {
    expect([...LIST_KEYS].sort()).toEqual(
      ['ar', 'de', 'en', 'es', 'fr', 'id', 'it', 'ja', 'ko', 'pl', 'pt', 'ru', 'th', 'tr', 'vi', 'zh'].sort(),
    );
    for (const key of LIST_KEYS) {
      expect(WORDLISTS[key].words.profanity.length, key).toBeGreaterThan(5);
      expect(WORDLISTS[key].key).toBe(key);
    }
  });

  it('vi and en are reviewed; the other 14 are marked as needing native review, in code', () => {
    expect(WORDLISTS.vi.reviewed).toBe(true);
    expect(WORDLISTS.en.reviewed).toBe(true);
    expect([...LISTS_NEEDING_NATIVE_REVIEW].sort()).toEqual(
      ['ar', 'de', 'es', 'fr', 'id', 'it', 'ja', 'ko', 'pl', 'pt', 'ru', 'th', 'tr', 'zh'].sort(),
    );
    for (const key of LISTS_NEEDING_NATIVE_REVIEW) {
      expect(WORDLISTS[key].reviewed, key).toBe(false);
      const src = fs.readFileSync(path.join(__dirname, '..', 'src', 'moderation', 'lists', `${key}.ts`), 'utf8');
      expect(src, key).toContain('NEEDS NATIVE REVIEW');
      expect(src, key).toContain('NEEDS_NATIVE_REVIEW = true');
    }
  });

  it('every entry of every list matches itself, in its own category', () => {
    for (const key of LIST_KEYS) {
      for (const [category, entries] of Object.entries(WORDLISTS[key].words)) {
        for (const entry of entries) {
          const sample = entry.startsWith('*') && entry.endsWith('*') ? entry.slice(1, -1) : entry.replace(/\*/g, '');
          const m = findMatches(sample, [key]);
          expect(
            m.some((x) => x.category === category),
            `${key}: ${entry}`,
          ).toBe(true);
        }
      }
    }
  });

  it('has no duplicated entries inside a list and no entry that is an exception of its own list', () => {
    for (const key of LIST_KEYS) {
      const all = Object.values(WORDLISTS[key].words).flat();
      expect(new Set(all).size, key).toBe(all.length);
    }
  });
});

describe('applied to user content in every language', () => {
  let e: Env;
  beforeEach(() => {
    e = setup();
  });
  afterEach(() => e.close());

  it('uses the item language, then the author language, then the author country', async () => {
    const ru = await e.login('ruser', { language: 'ru' });
    const en = await e.login('euser', { language: 'en' });

    // Author language (ru): Russian profanity masked.
    const p1 = await e.req('POST', '/v1/posts', { token: ru.token, body: { kind: 'text', body: 'ну ты и сука' } });
    expect(p1.json.body).toBe('ну ты и ***');
    expect(p1.json.language).toBe('ru');

    // Item language overrides the author's: Korean text from an English-language author.
    const p2 = await e.req('POST', '/v1/posts', {
      token: en.token,
      body: { kind: 'text', body: '시발 뭐야', language: 'ko' },
    });
    expect(p2.json.body).toBe('*** 뭐야');
    expect(p2.json.language).toBe('ko');

    // Script heuristic works even when the language is wrong.
    const p3 = await e.req('POST', '/v1/posts', {
      token: en.token,
      body: { kind: 'text', body: '你这个傻逼', language: 'en' },
    });
    expect(p3.json.body).toBe('你这个***');

    // Comments, LFG notes and reviews are filtered too.
    const cm = await e.req('POST', `/v1/posts/${p1.json.id}/comments`, {
      token: en.token,
      body: { body: 'Scheiße', language: 'de' },
    });
    expect(cm.json.body).toBe('***');
    const lfg = await e.req('POST', '/v1/lfg', {
      token: ru.token,
      body: { region: 'eu', mode: 'unrated', partyCode: 'ABCDEF', slots: 2, note: 'ищу нормальных, без блядь' },
    });
    expect(lfg.json.note).toBe('ищу нормальных, без ***');
    const rv = await e.req('PUT', `/v1/skins/${SKIN_A}/review`, {
      token: en.token,
      body: { weaponUuid: WEAPON_1, rating: 2, body: 'kurwa nie polecam', language: 'pl' },
    });
    expect(rv.json.body).toBe('*** nie polecam');
    expect(rv.json.language).toBe('pl');
  });

  it('rejects hate / scam in any language and never rejects unsupported-language text', async () => {
    const { token } = await e.login('alice', { language: 'ko' });
    const hate = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: '짱깨 꺼져' } });
    expectError(hate, 400, 'invalid_input');
    expect(hate.json.error.message).toBe(MSG_INAPPROPRIATE);
    const scam = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: '계정 판매합니다 카톡 주세요' } });
    expectError(scam, 400, 'invalid_input');
    expect(scam.json.error.message).toBe(MSG_SCAM);
    const phone = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'Call +62 812-3456-7890' } });
    expect(phone.json.error.message).toBe(MSG_SCAM);
    // Swahili text (no list) is accepted as is.
    const sw = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'Habari yako rafiki', language: 'en' } });
    expect(sw.status).toBe(200);
    expect(sw.json.body).toBe('Habari yako rafiki');
  });

  it('validates the optional language of content', async () => {
    const { token } = await e.login('alice');
    for (const language of ['xx', 'english', 5, '', 'any', 'zh']) {
      expectError(
        await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'hi', language } }),
        400,
        'invalid_input',
      );
    }
    for (const language of ['vi-VN', 'zh_CN', 'pt-BR', 'ZH-tw', 'en']) {
      expect((await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'hi', language } })).status).toBe(200);
    }
    const norm = await e.req('POST', '/v1/posts', { token, body: { kind: 'text', body: 'hi', language: 'zh_CN' } });
    expect(norm.json.language).toBe('zh-CN');
  });
});
