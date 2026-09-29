import { ApiError } from '../errors.js';
import type { ListKey, WordCategory } from './types.js';
import { SHORTENER_DOMAINS } from './vi-wordlist.js';
import { listKeyForLanguage, WORDLISTS } from './wordlists.js';

/**
 * Multi-language content filter for user text (post bodies, comments, review bodies, LFG notes).
 *
 * - profanity            → matched words are replaced by "***", the rest is kept
 * - hate / sexual / harassment → rejected (400 "Nội dung chứa từ ngữ không phù hợp")
 * - scam phrases, phone numbers → rejected (account selling / boosting ads are forbidden)
 * - links: http://, www. (no https) and URL-shortener links are stripped; other https links are kept
 *   and never altered by the word filter.
 *
 * The filter runs per language: English always, plus the list of the text's language (the item's
 * `language`, else the author's), plus lists implied by a cheap script / charset heuristic, and the
 * Vietnamese list for plain-Latin text when the language is unknown (what the service always did).
 * Text in a language without a list is never rejected for that reason: only listed words match.
 */

export const MSG_INAPPROPRIATE = 'Nội dung chứa từ ngữ không phù hợp';
export const MSG_SCAM = 'Không được quảng cáo mua bán tài khoản, cày thuê hoặc để lại số điện thoại.';

const REJECT_CATEGORIES: ReadonlySet<WordCategory> = new Set(['hate', 'sexual', 'harassment']);

// ---- normalisation ---------------------------------------------------------------

const LEET: Record<string, string> = { '0': 'o', '1': 'i', '3': 'e', '4': 'a', '@': 'a', $: 's' };

/**
 * Letter folding shared by text and list entries: lower case, NFC, Arabic letter variants
 * (أ إ آ → ا, ى → ي, ة → ه, tatweel removed), ё → е, ß → ss.
 */
export function canon(s: string): string {
  return s
    .toLowerCase()
    .normalize('NFC')
    .replace(/\u0640/g, '')
    .replace(/[\u0622\u0623\u0625\u0671]/g, '\u0627')
    .replace(/\u0649/g, '\u064A')
    .replace(/\u0629/g, '\u0647')
    .replace(/ё/g, 'е')
    .replace(/ß/g, 'ss');
}

/** canon() plus removal of every diacritic / tone mark (incl. đ → d). */
export function stripDiacritics(s: string): string {
  return canon(s).normalize('NFD').replace(/\p{M}/gu, '').replace(/đ/g, 'd').normalize('NFC');
}

const collapseRuns = (s: string): string => s.replace(/(.)\1+/gu, '$1');

interface Token {
  start: number;
  end: number;
  /** The original characters of the token. */
  raw: string;
  /** canon(), separators removed, leetspeak mapped: keeps diacritics. */
  toned: string;
  /** toned without diacritics. */
  plain: string;
  tonedCollapsed: string;
  plainCollapsed: string;
}

/** Normalised forms of one word (separators removed, leetspeak mapped when the word has letters). */
function makeToken(raw: string, start: number, end: number): Token {
  let s = canon(raw).replace(/[._*-]+/g, '');
  if (/\p{L}/u.test(s)) s = [...s].map((ch) => LEET[ch] ?? ch).join('');
  const plain = stripDiacritics(s);
  return { start, end, raw, toned: s, plain, tonedCollapsed: collapseRuns(s), plainCollapsed: collapseRuns(plain) };
}

/**
 * Maps a match [idx, idx+len) of the normalised token string (toned or plain) back to a range of the
 * original text. Normalisation can drop characters (tone marks, separators), so it is redone per
 * character cluster (base + combining marks); when that does not reproduce the token string exactly,
 * the whole token is returned.
 */
function rawRange(t: Token, hay: string, toned: boolean, idx: number, len: number): [number, number] {
  if (hay.length === t.end - t.start) return [t.start + idx, t.start + idx + len];
  const hasLetters = /\p{L}/u.test(t.raw);
  const clusters = t.raw.match(/\P{M}\p{M}*/gu);
  if (clusters && clusters.join('') === t.raw) {
    let text = '';
    const starts: number[] = []; // per char of `text`: raw offset where its cluster starts
    const ends: number[] = []; // ... and ends
    let at = 0;
    for (const c of clusters) {
      let piece = canon(c).replace(/[._*-]+/g, '');
      if (hasLetters) piece = [...piece].map((ch) => LEET[ch] ?? ch).join('');
      if (!toned) piece = stripDiacritics(piece);
      for (let k = 0; k < piece.length; k++) {
        starts.push(at);
        ends.push(at + c.length);
      }
      text += piece;
      at += c.length;
    }
    if (text === hay && len > 0 && idx + len <= text.length) {
      return [t.start + starts[idx]!, t.start + ends[idx + len - 1]!];
    }
  }
  return [t.start, t.end];
}

const TOKEN_RE = /[\p{L}\p{M}\p{N}@$]+(?:[._*-]+[\p{L}\p{M}\p{N}@$]+)*/gu;

/**
 * Splits text into word tokens. Separators `_ - *` inside a word are dropped ("đ-m", "f*ck");
 * dots are only dropped when every piece is a single character ("đ.m", "v.c.l"), so ordinary
 * text like "ok.đi" or "v1.0" stays separate words. Ranges in `skip` (kept links) are ignored.
 */
export function tokenize(text: string, skip: [number, number][] = []): Token[] {
  const tokens: Token[] = [];
  const inSkip = (a: number, b: number) => skip.some(([s, e]) => a < e && b > s);
  for (const m of text.matchAll(TOKEN_RE)) {
    const raw = m[0];
    const at = m.index;
    if (inSkip(at, at + raw.length)) continue;
    const pieces = raw.split(/[._*-]+/);
    const spelledOut = pieces.every((p) => [...p].length === 1);
    if (raw.includes('.') && !spelledOut) {
      for (const sub of raw.matchAll(/[^.]+/g)) {
        tokens.push(makeToken(sub[0], at + sub.index, at + sub.index + sub[0].length));
      }
    } else {
      tokens.push(makeToken(raw, at, at + raw.length));
    }
  }
  return tokens;
}

// ---- word list compilation -----------------------------------------------------------

interface PatternWord {
  word: string;
  /** Written with diacritics → must match the accented form exactly. */
  toned: boolean;
  /** `stem*`: the token only has to start with the word. */
  prefix: boolean;
  collapsed: string;
}

interface Exceptions {
  /** Whole words / prefixes: a token matching one is never matched by `stem*` / `*part*` entries. */
  words: PatternWord[];
  /** `*part*`: a match lying inside an occurrence of it is dropped. */
  parts: { toned: string; plain: string }[];
}

interface Pattern {
  words: PatternWord[];
  /** `*part*`: substring match inside a token (single word). */
  substring: boolean;
  category: WordCategory;
  source: string;
  list: ListKey;
  exceptions: Exceptions;
}

function parseWord(entry: string): { word: PatternWord; substring: boolean } | null {
  const e = canon(entry.trim());
  if (e.length === 0) return null;
  const substring = e.length > 2 && e.startsWith('*') && e.endsWith('*');
  const prefix = !substring && e.length > 1 && e.endsWith('*');
  const word = substring ? e.slice(1, -1) : prefix ? e.slice(0, -1) : e;
  if (word.length === 0) return null;
  return { word: { word, toned: stripDiacritics(word) !== word, prefix, collapsed: collapseRuns(word) }, substring };
}

function compileExceptions(entries: readonly string[]): Exceptions {
  const ex: Exceptions = { words: [], parts: [] };
  for (const entry of entries) {
    const p = parseWord(entry);
    if (!p) continue;
    if (p.substring) ex.parts.push({ toned: p.word.word, plain: stripDiacritics(p.word.word) });
    else ex.words.push(p.word);
  }
  return ex;
}

const COMPILED = new Map<ListKey, Pattern[]>();

function compileList(key: ListKey): Pattern[] {
  const cached = COMPILED.get(key);
  if (cached) return cached;
  const list = WORDLISTS[key];
  const exceptions = compileExceptions(list.exceptions);
  const out: Pattern[] = [];
  for (const [category, entries] of Object.entries(list.words) as [WordCategory, readonly string[]][]) {
    for (const entry of entries) {
      const trimmed = entry.trim();
      const single = parseWord(trimmed);
      if (single?.substring) {
        out.push({ words: [single.word], substring: true, category, source: entry, list: key, exceptions });
        continue;
      }
      const words = trimmed
        .split(/\s+/)
        .map((w) => parseWord(w)?.word)
        .filter((w): w is PatternWord => w !== undefined);
      if (words.length > 0) out.push({ words, substring: false, category, source: entry, list: key, exceptions });
    }
  }
  COMPILED.set(key, out);
  return out;
}

const PLAN_CACHE = new Map<string, { words: Pattern[]; substrings: Pattern[] }>();

/** Word patterns (longest phrases first, so "bú lồn" wins over "lồn") and substring patterns of some lists. */
function planFor(lists: readonly ListKey[]) {
  const id = [...lists].sort().join(',');
  const cached = PLAN_CACHE.get(id);
  if (cached) return cached;
  const all = lists.flatMap((k) => compileList(k));
  const plan = {
    words: all.filter((p) => !p.substring).sort((a, b) => b.words.length - a.words.length),
    substrings: all.filter((p) => p.substring),
  };
  PLAN_CACHE.set(id, plan);
  return plan;
}

function wordMatches(t: Token, w: PatternWord): boolean {
  if (w.prefix) return (w.toned ? t.toned : t.plain).startsWith(w.word);
  if (w.toned) {
    return t.toned === w.word || (t.tonedCollapsed !== t.toned && t.tonedCollapsed === w.collapsed);
  }
  // Elongated forms ("đmmmm", "fuuuck") match via the collapsed form, but only when the token
  // really contained a repeated letter — so "as" never matches a collapsed "ass".
  return t.plain === w.word || (t.plainCollapsed !== t.plain && t.plainCollapsed === w.collapsed);
}

/** Token-level exceptions: excepted whole words / prefixes, or a token containing an excepted `*part*`. */
function tokenExcepted(t: Token, ex: Exceptions): boolean {
  if (ex.words.some((w) => wordMatches(t, w))) return true;
  return ex.parts.some((p) => t.toned.includes(p.toned) || t.plain.includes(p.plain));
}

/** True when [idx, idx+len) of `hay` lies inside an occurrence of an excepted `*part*`. */
function insideExceptionPart(hay: string, idx: number, len: number, toned: boolean, ex: Exceptions): boolean {
  for (const p of ex.parts) {
    const part = toned ? p.toned : p.plain;
    if (part.length < len) continue;
    let from = 0;
    for (;;) {
      const at = hay.indexOf(part, from);
      if (at < 0) break;
      if (at <= idx && idx + len <= at + part.length) return true;
      from = at + 1;
    }
  }
  return false;
}

export interface WordMatch {
  start: number;
  end: number;
  category: WordCategory;
  source: string;
  list: ListKey;
}

/** Finds word-list matches of the given lists (whole words, prefixes and substrings; see types.ts). */
export function findMatches(text: string, lists: readonly ListKey[], skip: [number, number][] = []): WordMatch[] {
  const tokens = tokenize(text, skip);
  const plan = planFor(lists);
  const found: WordMatch[] = [];

  // Whole words, prefixes and phrases.
  let i = 0;
  while (i < tokens.length) {
    let hit: Pattern | undefined;
    for (const p of plan.words) {
      if (i + p.words.length > tokens.length) continue;
      const first = tokens[i]!;
      if (!p.words.every((w, k) => wordMatches(tokens[i + k]!, w))) continue;
      if (p.words.some((w) => w.prefix) && tokenExcepted(first, p.exceptions)) continue;
      hit = p;
      break;
    }
    if (hit) {
      found.push({
        start: tokens[i]!.start,
        end: tokens[i + hit.words.length - 1]!.end,
        category: hit.category,
        source: hit.source,
        list: hit.list,
      });
      i += hit.words.length;
    } else {
      i++;
    }
  }

  // Substrings inside a token (scripts written without spaces).
  if (plan.substrings.length > 0) {
    for (const t of tokens) {
      for (const p of plan.substrings) {
        const w = p.words[0]!;
        const hay = w.toned ? t.toned : t.plain;
        if (hay.length < w.word.length) continue;
        if (p.exceptions.words.some((x) => wordMatches(t, x))) continue;
        let from = 0;
        for (;;) {
          const idx = hay.indexOf(w.word, from);
          if (idx < 0) break;
          from = idx + 1;
          if (insideExceptionPart(hay, idx, w.word.length, w.toned, p.exceptions)) continue;
          const [start, end] = rawRange(t, hay, w.toned, idx, w.word.length);
          found.push({
            start,
            end,
            category: p.category,
            source: p.source,
            list: p.list,
          });
        }
      }
    }
  }
  return found;
}

// ---- which lists apply --------------------------------------------------------------------

const SCRIPT = {
  hangul: /[\u1100-\u11FF\u3130-\u318F\uAC00-\uD7AF]/u,
  kana: /[\u3040-\u30FF\u31F0-\u31FF\uFF66-\uFF9F]/u,
  han: /\p{Script=Han}/u,
  thai: /\p{Script=Thai}/u,
  arabic: /\p{Script=Arabic}/u,
  cyrillic: /\p{Script=Cyrillic}/u,
  otherNonLatin: /[\p{Script=Greek}\p{Script=Hebrew}\p{Script=Devanagari}\p{Script=Bengali}\p{Script=Tamil}\p{Script=Georgian}\p{Script=Armenian}]/u,
  // Letters that only Vietnamese uses (Latin Extended Additional, đ, ơ, ư, ă).
  vi: /[\u1EA0-\u1EF9đơưă]/iu,
  de: /ß/u,
  es: /[ñ¿¡]/u,
  pl: /[ąęłśźż]/iu,
  tr: /[ğışİ]/iu,
} as const;

/** Latin-script languages implied by the author's country (the app language may differ from what they type). */
const COUNTRY_LATIN_LISTS: Readonly<Record<string, readonly ListKey[]>> = {
  VN: ['vi'],
  ES: ['es'], MX: ['es'], AR: ['es'], CO: ['es'], CL: ['es'], PE: ['es'], VE: ['es'], EC: ['es'], UY: ['es'],
  PY: ['es'], BO: ['es'], CR: ['es'], PA: ['es'], DO: ['es'], GT: ['es'], HN: ['es'], SV: ['es'], NI: ['es'],
  CU: ['es'], PR: ['es'],
  BR: ['pt'], PT: ['pt'], AO: ['pt'], MZ: ['pt'],
  DE: ['de'], AT: ['de'], LI: ['de'], CH: ['de', 'fr', 'it'],
  FR: ['fr'], BE: ['fr'], LU: ['fr'], MC: ['fr'],
  IT: ['it'], SM: ['it'], VA: ['it'],
  PL: ['pl'], TR: ['tr'], ID: ['id'], MY: ['id'], BN: ['id'],
};

/**
 * The lists to apply to `text`:
 * - English always (English profanity is common in every community);
 * - the list of the declared language (`language`: the text's language, else the author's);
 * - lists implied by the script / charset of the text (Hangul → ko, Kana → ja, Han → zh, Thai → th,
 *   Arabic script → ar, Cyrillic → ru, Vietnamese letters → vi, ß → de, ñ ¿ ¡ → es, ą ę ł → pl, ğ ı ş → tr);
 * - for Latin-only text: the Vietnamese list when the language is unknown / vi / en (unaccented
 *   Vietnamese teencode: "dm", "vcl"), and the local-language list implied by the author's country.
 * Text in a language without a list gets English only and is never rejected for being in that language.
 */
export function listsFor(text: string, language?: string | null, country?: string | null): ListKey[] {
  const set = new Set<ListKey>(['en']);
  const declared = listKeyForLanguage(language);
  if (declared) set.add(declared);

  const has = (re: RegExp) => re.test(text);
  const hangul = has(SCRIPT.hangul);
  const kana = has(SCRIPT.kana);
  const han = has(SCRIPT.han);
  const thai = has(SCRIPT.thai);
  const arabic = has(SCRIPT.arabic);
  const cyrillic = has(SCRIPT.cyrillic);
  if (hangul) set.add('ko');
  if (kana) set.add('ja');
  if (han) set.add('zh');
  if (thai) set.add('th');
  if (arabic) set.add('ar');
  if (cyrillic) set.add('ru');
  if (has(SCRIPT.vi)) set.add('vi');
  if (has(SCRIPT.de)) set.add('de');
  if (has(SCRIPT.es)) set.add('es');
  if (has(SCRIPT.pl)) set.add('pl');
  if (has(SCRIPT.tr)) set.add('tr');

  const latinOnly = !(hangul || kana || han || thai || arabic || cyrillic || has(SCRIPT.otherNonLatin));
  if (latinOnly) {
    if (!declared || declared === 'vi' || declared === 'en') set.add('vi');
    for (const k of COUNTRY_LATIN_LISTS[(country ?? '').toUpperCase()] ?? []) set.add(k);
  }
  return [...set];
}

// ---- links and phone numbers -------------------------------------------------------------

const URL_RE = /(?:https?:\/\/|www\.)[^\s<>"'`]+/giu;
const TRAILING_PUNCT_RE = /[.,!?;:)\]}"'…]+$/u;
const SHORTENER_RE = new RegExp(
  `(?<![\\p{L}\\p{N}.-])(?:www\\.)?(?:${SHORTENER_DOMAINS.map((d) => d.replace(/\./g, '\\.')).join('|')})(?:/[^\\s]*)?(?![\\p{L}\\p{N}-])`,
  'giu',
);

function hostOf(url: string): string | null {
  try {
    return new URL(url).hostname.toLowerCase().replace(/^www\./, '');
  } catch {
    return null;
  }
}

const isShortener = (host: string) => SHORTENER_DOMAINS.some((d) => host === d || host.endsWith(`.${d}`));

/** Removes non-https and shortener links. Returns the new text and how many links were removed. */
export function stripLinks(text: string): { text: string; removed: number } {
  let removed = 0;
  let out = text.replace(URL_RE, (m) => {
    const trail = TRAILING_PUNCT_RE.exec(m)?.[0] ?? '';
    const url = trail ? m.slice(0, -trail.length) : m;
    const lower = url.toLowerCase();
    if (lower.startsWith('https://')) {
      const host = hostOf(url);
      if (host && !isShortener(host)) return m; // keep
    }
    removed++;
    return trail;
  });
  out = out.replace(SHORTENER_RE, () => {
    removed++;
    return '';
  });
  if (removed > 0) out = out.replace(/[ \t]{2,}/g, ' ').replace(/ +\n/g, '\n').trim();
  return { text: out, removed };
}

/** Ranges of the (kept, https) links, so the word filter leaves them untouched. */
function linkRanges(text: string): [number, number][] {
  return [...text.matchAll(URL_RE)].map((m) => [m.index, m.index + m[0].length] as [number, number]);
}

/** Vietnamese mobile numbers: 0xxxxxxxxx / +84xxxxxxxxx, digits optionally separated by space . - */
const PHONE_VN_RE = /(?<!\p{N})(?:\+?\s?84|0)[\s.-]?[35789](?:[\s.-]?\d){8}(?!\p{N})/u;
/** International numbers written with a leading "+" and country code: +1 (415) 555-2671, +62 812-3456-7890. */
const PHONE_INTL_RE = /(?<![\p{L}\p{N}])\+\s?\d{1,3}(?:[\s.()-]{0,2}\d){7,12}(?!\p{N})/u;

export function containsPhoneNumber(text: string): boolean {
  return PHONE_VN_RE.test(text) || PHONE_INTL_RE.test(text);
}

// ---- public API ------------------------------------------------------------------------------

export type RejectReason = 'hate' | 'sexual' | 'harassment' | 'scam' | 'phone';

export interface ModerateOptions {
  /** Language of the text (or of its author): one of the 17 app languages; absent / 'any' → unknown. */
  language?: string | null;
  /** Author's country (ISO alpha-2): implies the local language for Latin-script text. */
  country?: string | null;
}

export interface ModerationResult {
  /** Cleaned text (links stripped, profanity masked). */
  text: string;
  /** Set when the text must be rejected. */
  rejected: RejectReason | null;
  /** Number of masked profanity spans. */
  masked: number;
  linksRemoved: number;
  /** Word lists that were applied. */
  lists: ListKey[];
}

export function moderate(input: string, opts: ModerateOptions = {}): ModerationResult {
  const nfc = input.normalize('NFC');
  const { text, removed } = stripLinks(nfc);
  const skip = linkRanges(text);
  const lists = listsFor(text, opts.language, opts.country);
  const matches = findMatches(text, lists, skip);
  const base = { linksRemoved: removed, lists };

  const reject = matches.find((m) => REJECT_CATEGORIES.has(m.category));
  if (reject) return { text, rejected: reject.category as RejectReason, masked: 0, ...base };
  if (matches.some((m) => m.category === 'scam')) return { text, rejected: 'scam', masked: 0, ...base };
  const unlinked = skip.reduceRight((s, [a, b]) => s.slice(0, a) + ' '.repeat(b - a) + s.slice(b), text);
  if (containsPhoneNumber(unlinked)) return { text, rejected: 'phone', masked: 0, ...base };

  // Merge overlapping profanity spans, then mask each with ***.
  const spans = matches
    .filter((m) => m.category === 'profanity')
    .map((m) => [m.start, m.end] as [number, number])
    .sort((a, b) => a[0] - b[0] || a[1] - b[1]);
  const merged: [number, number][] = [];
  for (const s of spans) {
    const last = merged[merged.length - 1];
    if (last && s[0] < last[1]) last[1] = Math.max(last[1], s[1]);
    else merged.push([s[0], s[1]]);
  }
  let out = text;
  for (const [a, b] of [...merged].reverse()) out = `${out.slice(0, a)}***${out.slice(b)}`;
  return { text: out, rejected: null, masked: merged.length, ...base };
}

/**
 * Applies the filter to user text; throws 400 invalid_input when the text is not allowed.
 * `language` is the language of the text (falls back to the author's), `country` the author's country.
 */
export function cleanUserText(input: string, language?: string | null, country?: string | null): string {
  if (input === '') return input;
  const r = moderate(input, { language, country });
  if (r.rejected === 'scam' || r.rejected === 'phone') throw new ApiError('invalid_input', MSG_SCAM);
  if (r.rejected) throw new ApiError('invalid_input', MSG_INAPPROPRIATE);
  return r.text;
}
