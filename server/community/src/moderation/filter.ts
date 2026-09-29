import { ApiError } from '../errors.js';
import { SHORTENER_DOMAINS, WORDLIST, type WordCategory } from './vi-wordlist.js';

/**
 * Vietnamese-aware content filter for user text (post bodies, comments, review bodies, LFG notes).
 *
 * - profanity            → matched words are replaced by "***", the rest is kept
 * - hate / sexual / harassment → rejected (400 "Nội dung chứa từ ngữ không phù hợp")
 * - scam phrases, phone numbers → rejected (account selling / boosting ads are forbidden)
 * - links: http://, www. (no https) and URL-shortener links are stripped; other https links are kept
 *   and never altered by the word filter.
 */

export const MSG_INAPPROPRIATE = 'Nội dung chứa từ ngữ không phù hợp';
export const MSG_SCAM = 'Không được quảng cáo mua bán tài khoản, cày thuê hoặc để lại số điện thoại.';

const REJECT_CATEGORIES: ReadonlySet<WordCategory> = new Set(['hate', 'sexual', 'harassment']);

// ---- normalisation ---------------------------------------------------------------

const LEET: Record<string, string> = { '0': 'o', '1': 'i', '3': 'e', '4': 'a', '@': 'a', $: 's' };

/** Lower-case, remove Vietnamese diacritics (incl. đ → d). */
export function stripDiacritics(s: string): string {
  return s.toLowerCase().normalize('NFD').replace(/\p{M}/gu, '').replace(/đ/g, 'd').normalize('NFC');
}

const collapseRuns = (s: string): string => s.replace(/(.)\1+/gu, '$1');

interface Token {
  start: number;
  end: number;
  toned: string;
  plain: string;
  tonedCollapsed: string;
  plainCollapsed: string;
}

/** Normalised forms of one word (separators removed, leetspeak mapped when the word has letters). */
function makeToken(raw: string, start: number, end: number): Token {
  let s = raw.toLowerCase().normalize('NFC').replace(/[._*-]+/g, '');
  if (/\p{L}/u.test(s)) s = [...s].map((ch) => LEET[ch] ?? ch).join('');
  const plain = stripDiacritics(s);
  return { start, end, toned: s, plain, tonedCollapsed: collapseRuns(s), plainCollapsed: collapseRuns(plain) };
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
  collapsed: string;
}

interface Pattern {
  words: PatternWord[];
  category: WordCategory;
  source: string;
}

function compile(): Pattern[] {
  const out: Pattern[] = [];
  for (const [category, entries] of Object.entries(WORDLIST) as [WordCategory, readonly string[]][]) {
    for (const entry of entries) {
      const words = entry
        .toLowerCase()
        .normalize('NFC')
        .split(/\s+/)
        .filter(Boolean)
        .map((w) => {
          const toned = stripDiacritics(w) !== w;
          return { word: w, toned, collapsed: collapseRuns(w) };
        });
      if (words.length > 0) out.push({ words, category, source: entry });
    }
  }
  // Longest phrases first so "bú lồn" (sexual) wins over "lồn" (profanity).
  return out.sort((a, b) => b.words.length - a.words.length);
}

const PATTERNS = compile();

function wordMatches(t: Token, w: PatternWord): boolean {
  if (w.toned) {
    return t.toned === w.word || (t.tonedCollapsed !== t.toned && t.tonedCollapsed === w.collapsed);
  }
  // Elongated forms ("đmmmm", "fuuuck") match via the collapsed form, but only when the token
  // really contained a repeated letter — so "as" never matches a collapsed "ass".
  return t.plain === w.word || (t.plainCollapsed !== t.plain && t.plainCollapsed === w.collapsed);
}

export interface WordMatch {
  start: number;
  end: number;
  category: WordCategory;
  source: string;
}

/** Finds word-list matches (whole words / consecutive words only). */
export function findMatches(text: string, skip: [number, number][] = []): WordMatch[] {
  const tokens = tokenize(text, skip);
  const found: WordMatch[] = [];
  let i = 0;
  while (i < tokens.length) {
    let hit: Pattern | undefined;
    for (const p of PATTERNS) {
      if (i + p.words.length > tokens.length) continue;
      if (p.words.every((w, k) => wordMatches(tokens[i + k]!, w))) {
        hit = p;
        break;
      }
    }
    if (hit) {
      found.push({
        start: tokens[i]!.start,
        end: tokens[i + hit.words.length - 1]!.end,
        category: hit.category,
        source: hit.source,
      });
      i += hit.words.length;
    } else {
      i++;
    }
  }
  return found;
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
const PHONE_RE = /(?<!\p{N})(?:\+?\s?84|0)[\s.-]?[35789](?:[\s.-]?\d){8}(?!\p{N})/u;

export function containsPhoneNumber(text: string): boolean {
  return PHONE_RE.test(text);
}

// ---- public API ------------------------------------------------------------------------------

export type RejectReason = 'hate' | 'sexual' | 'harassment' | 'scam' | 'phone';

export interface ModerationResult {
  /** Cleaned text (links stripped, profanity masked). */
  text: string;
  /** Set when the text must be rejected. */
  rejected: RejectReason | null;
  /** Number of masked profanity spans. */
  masked: number;
  linksRemoved: number;
}

export function moderate(input: string): ModerationResult {
  const nfc = input.normalize('NFC');
  const { text, removed } = stripLinks(nfc);
  const skip = linkRanges(text);
  const matches = findMatches(text, skip);

  const reject = matches.find((m) => REJECT_CATEGORIES.has(m.category));
  if (reject) return { text, rejected: reject.category as RejectReason, masked: 0, linksRemoved: removed };
  if (matches.some((m) => m.category === 'scam')) return { text, rejected: 'scam', masked: 0, linksRemoved: removed };
  const unlinked = skip.reduceRight((s, [a, b]) => s.slice(0, a) + ' '.repeat(b - a) + s.slice(b), text);
  if (containsPhoneNumber(unlinked)) return { text, rejected: 'phone', masked: 0, linksRemoved: removed };

  const profane = matches.filter((m) => m.category === 'profanity');
  let out = text;
  for (const m of [...profane].reverse()) out = `${out.slice(0, m.start)}***${out.slice(m.end)}`;
  return { text: out, rejected: null, masked: profane.length, linksRemoved: removed };
}

/** Applies the filter to user text; throws 400 invalid_input when the text is not allowed. */
export function cleanUserText(input: string): string {
  if (input === '') return input;
  const r = moderate(input);
  if (r.rejected === 'scam' || r.rejected === 'phone') throw new ApiError('invalid_input', MSG_SCAM);
  if (r.rejected) throw new ApiError('invalid_input', MSG_INAPPROPRIATE);
  return r.text;
}
