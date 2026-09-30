import { reasonError } from '../errors.js';
import { REASONS } from '../reasons.js';
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

export const MSG_INAPPROPRIATE = REASONS.content_inappropriate.vi;
export const MSG_SCAM = REASONS.content_scam.vi;

/**
 * Work caps (CS-03). The fields that reach the filter are at most 1,000 code points, but the cost of one call grows
 * with the number of words and isolated letters, so a text beyond these caps is refused instead of scanned: a
 * legitimate 1,000-character text has ~200 words and no isolated-letter runs worth mentioning.
 */
export const MAX_INPUT_CHARS = 4000;
export const MAX_TOKENS = 400;
export const MAX_UNITS = 300;

/** Thrown by the scanners when a text is beyond the caps above; `moderate()` turns it into a rejection. */
export class TextTooComplexError extends Error {
  constructor() {
    super('text too complex for the content filter');
    this.name = 'TextTooComplexError';
  }
}

const REJECT_CATEGORIES: ReadonlySet<WordCategory> = new Set(['hate', 'sexual', 'harassment']);

// ---- normalisation ---------------------------------------------------------------

/** Leetspeak, applied only inside words that contain letters ("sh1t", "$hit", "5hit"). */
const LEET: Record<string, string> = { '0': 'o', '1': 'i', '3': 'e', '4': 'a', '5': 's', '7': 't', '@': 'a', $: 's' };

/**
 * Invisible / formatting characters that are pasted into words to defeat filters: soft hyphen, combining
 * grapheme joiner, Arabic letter mark, Hangul / Khmer fillers, Mongolian separators, zero-width space /
 * (non-)joiner, LRM / RLM, bidi controls and isolates, word joiner and the invisible operators, Hangul
 * filler, variation selectors, BOM, half-width Hangul filler, tag characters.
 */
const IGN =
  '\\u00AD\\u034F\\u061C\\u115F\\u1160\\u17B4\\u17B5\\u180B-\\u180F\\u200B-\\u200F\\u202A-\\u202E\\u2060-\\u206F\\u3164\\uFE00-\\uFE0F\\uFEFF\\uFFA0\\u{E0000}-\\u{E007F}\\u{E0100}-\\u{E01EF}';
const IGNORABLE = new RegExp(`[${IGN}]`, 'gu');
const HAS_IGNORABLE = new RegExp(`[${IGN}]`, 'u');

/**
 * Letter folding shared by text and list entries: invisible characters removed, NFKC (full-width, math /
 * circled / stylised letters and digits become plain ones; half-width kana widened), lower case, NFC,
 * Arabic letter variants (أ إ آ → ا, ى → ي, ة → ه, tatweel removed), ё → е, ß → ss.
 */
const ASCII_ONLY = /^[\u0000-\u007F]*$/;

export function canon(s: string): string {
  // Plain ASCII has no invisible characters and nothing to compose or fold: only the case changes.
  if (ASCII_ONLY.test(s)) return s.toLowerCase();
  return s
    .replace(IGNORABLE, '')
    .normalize('NFKC')
    .toLowerCase()
    .normalize('NFC')
    .replace(/ـ/g, '')
    .replace(/[آأإٱ]/g, 'ا')
    .replace(/ى/g, 'ي')
    .replace(/ة/g, 'ه')
    .replace(/ё/g, 'е')
    .replace(/ß/g, 'ss');
}

/** canon() plus removal of every diacritic / tone mark (incl. đ → d). */
export function stripDiacritics(s: string): string {
  const c = canon(s);
  if (ASCII_ONLY.test(c)) return c;
  return c.normalize('NFD').replace(/\p{M}/gu, '').replace(/đ/g, 'd').normalize('NFC');
}

const collapseRuns = (s: string): string => s.replace(/(.)\1+/gu, '$1');

/**
 * Look-alike letters. Cyrillic / Greek letters that pass for Latin ones ("fuсk" with a Cyrillic с,
 * "dіt" with a Cyrillic і, "fοck" with a Greek ο) are folded to Latin, and Latin letters inside a
 * Cyrillic word ("xуй") to Cyrillic, as ADDITIONAL forms of the token: the token still matches as written.
 */
const LOOKALIKE_TO_LATIN: Record<string, string> = {
  а: 'a', в: 'b', е: 'e', і: 'i', ї: 'i', ј: 'j', к: 'k', м: 'm', н: 'h', о: 'o', р: 'p', с: 'c', т: 't',
  у: 'y', х: 'x', ѕ: 's', һ: 'h', ԁ: 'd', ԛ: 'q', ԝ: 'w', ө: 'o', ɡ: 'g',
  α: 'a', β: 'b', ε: 'e', ι: 'i', κ: 'k', ν: 'v', ο: 'o', ρ: 'p', τ: 't', υ: 'u', χ: 'x', ω: 'w', η: 'n',
};
const LATIN_TO_CYRILLIC: Record<string, string> = {
  a: 'а', b: 'в', c: 'с', e: 'е', h: 'н', k: 'к', m: 'м', o: 'о', p: 'р', t: 'т', x: 'х', y: 'у',
};
const foldWith = (s: string, map: Record<string, string>): string => [...s].map((ch) => map[ch] ?? ch).join('');
const HAS_LOOKALIKE_SCRIPT = /[\p{Script=Cyrillic}\p{Script=Greek}]/u;

/** One normalised spelling of a token. */
interface Form {
  /** canon(), separators removed, leetspeak mapped: keeps diacritics. */
  toned: string;
  /** toned without diacritics. */
  plain: string;
  tonedCollapsed: string;
  plainCollapsed: string;
}

interface Token extends Form {
  start: number;
  end: number;
  /** The original characters of the token. */
  raw: string;
  /** Letters were joined across separators / invisible characters / spaces: multi-word phrases may match the run. */
  squash: boolean;
  /** Made of several source tokens: a match always covers the whole span. */
  whole: boolean;
  /** Look-alike-folded spellings. */
  alts: Form[];
  /** The single letters this token is made of ("d", "u.c"), when it is a spelled-out piece of a word. */
  pieces?: string[];
}

const makeForm = (toned: string): Form => {
  const plain = stripDiacritics(toned);
  return { toned, plain, tonedCollapsed: collapseRuns(toned), plainCollapsed: collapseRuns(plain) };
};

/** Normalised forms of one word (separators removed, leetspeak mapped when the word has letters). */
function makeToken(raw: string, start: number, end: number): Token {
  const c = canon(raw);
  let s = c.replace(/[._*-]+/g, '');
  const squash = s.length !== c.length || HAS_IGNORABLE.test(raw);
  if (/\p{L}/u.test(s)) s = [...s].map((ch) => LEET[ch] ?? ch).join('');
  const alts: Form[] = [];
  if (HAS_LOOKALIKE_SCRIPT.test(s)) {
    const latin = foldWith(s, LOOKALIKE_TO_LATIN);
    if (latin !== s) alts.push(makeForm(latin));
    if (/\p{Script=Cyrillic}/u.test(s) && /[a-z]/.test(s)) {
      const cyr = foldWith(s, LATIN_TO_CYRILLIC);
      if (cyr !== s) alts.push(makeForm(cyr));
    }
  }
  return { ...makeForm(s), start, end, raw, squash, whole: false, alts, pieces: piecesOf(raw) };
}

/**
 * Maps a match [idx, idx+len) of the normalised token string (toned or plain) back to a range of the
 * original text. Normalisation can drop characters (tone marks, separators, invisible characters), so it
 * is redone per character cluster (base + combining marks); when that does not reproduce the token
 * string exactly, the whole token is returned.
 */
function rawRange(t: Token, hay: string, toned: boolean, idx: number, len: number): [number, number] {
  if (t.whole) return [t.start, t.end];
  if (hay.length === t.end - t.start && hay === (toned ? t.toned : t.plain)) {
    // Same length as the source: offsets map 1:1 unless something was substituted in place; verify below.
    if (t.raw.length === hay.length && canon(t.raw) === t.raw) return [t.start + idx, t.start + idx + len];
  }
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

// Letters, marks, digits, @ $ and the circled / squared Latin letters (Ⓕ 🄵) that NFKC turns into plain ones.
const WORD_CH = '\\p{L}\\p{M}\\p{N}@$\\u24B6-\\u24E9\\u{1F130}-\\u{1F149}';
const TOKEN_RE_IGNORE = new RegExp(`[${WORD_CH}${IGN}]+(?:[._*-]+[${WORD_CH}${IGN}]+)*`, 'gu');
const TOKEN_RE_SPLIT = new RegExp(`[${WORD_CH}]+(?:[._*-]+[${WORD_CH}]+)*`, 'gu');

/**
 * Splits text into word tokens. Separators `_ - *` inside a word are dropped ("đ-m", "f*ck");
 * dots are only dropped when every piece is a single character ("đ.m", "v.c.l"), so ordinary
 * text like "ok.đi" or "v1.0" stays separate words. Ranges in `skip` (kept links) are ignored.
 *
 * Invisible characters (zero-width space, soft hyphen, ...) either belong to the word they sit in
 * (`mode = 'ignore'`, "d​m" → "dm") or separate words (`mode = 'split'`, "dm​hello" → "dm", "hello"):
 * text that contains them is matched both ways.
 */
export function tokenize(text: string, skip: [number, number][] = [], mode: 'ignore' | 'split' = 'ignore'): Token[] {
  const tokens: Token[] = [];
  const inSkip = (a: number, b: number) => skip.some(([s, e]) => a < e && b > s);
  const re = mode === 'ignore' ? TOKEN_RE_IGNORE : TOKEN_RE_SPLIT;
  for (const m of text.matchAll(re)) {
    const raw = m[0];
    const at = m.index;
    if (inSkip(at, at + raw.length)) continue;
    const pieces = raw.split(/[._*-]+/);
    const spelledOut = pieces.every((p) => [...canon(p)].length === 1);
    if (raw.includes('.') && !spelledOut) {
      for (const sub of raw.matchAll(/[^.]+/g)) {
        tokens.push(makeToken(sub[0], at + sub.index, at + sub.index + sub[0].length));
      }
    } else {
      tokens.push(makeToken(raw, at, at + raw.length));
    }
  }
  return tokens.filter((t) => t.toned.length > 0); // a run of invisible characters is not a word
}

const GAP_RE = /^[^\p{L}\p{N}]{1,3}$/u;
const SINGLE_RE = /^[\p{L}\p{N}]\p{M}*$/u;
/** Longest run of single letters read as one word, and longest window inside a run tried as a word. */
const MAX_RUN_UNITS = 64;
const MAX_WINDOW_UNITS = 24;

/** One spelled-out letter: a single-letter token, or one piece of a "d.i.t"-style token. */
interface Unit {
  /** canon()-ed letter. */
  piece: string;
  start: number;
  end: number;
  /** Index of the token it belongs to. */
  token: number;
}

/**
 * The single letters of a token ("d", "u.c" → u, c), or undefined when the token is a normal word.
 * Separators inside a token were already accepted by the tokenizer.
 */
function piecesOf(raw: string): string[] | undefined {
  const out: string[] = [];
  for (const m of raw.matchAll(/[^._*-]+/g)) {
    const c = canon(m[0]);
    if (c.length === 0) continue; // only invisible characters
    if (!SINGLE_RE.test(c)) return undefined;
    out.push(c);
  }
  return out.length > 0 ? out : undefined;
}

function unitsOf(tokens: Token[]): Unit[] {
  const out: Unit[] = [];
  tokens.forEach((t, token) => {
    if (!t.pieces || t.whole) return;
    for (const m of t.raw.matchAll(/[^._*-]+/g)) {
      const piece = canon(m[0]);
      if (piece.length === 0) continue;
      out.push({ piece, start: t.start + m.index, end: t.start + m.index + m[0].length, token });
    }
  });
  return out;
}

/**
 * "d i t m e", "f.u.c.k", "f,u,c,k", "s|h|i|t", "d🔥i🔥t": runs of at least three single letters / digits
 * separated by 1–3 non-alphanumeric characters (or by the dots / dashes of one token).
 */
function runsOf(units: Unit[], text: string): Unit[][] {
  const runs: Unit[][] = [];
  let i = 0;
  while (i < units.length) {
    let j = i;
    while (
      j + 1 < units.length &&
      j - i + 1 < MAX_RUN_UNITS &&
      (units[j]!.token === units[j + 1]!.token || GAP_RE.test(text.slice(units[j]!.end, units[j + 1]!.start)))
    ) {
      j++;
    }
    if (j - i + 1 >= 3) runs.push(units.slice(i, j + 1));
    i = j + 1;
  }
  return runs;
}

/** Each run read as one word: the run's tokens replaced by a single merged token (phrases may then span it). */
function mergedStream(tokens: Token[], runs: Unit[][], text: string): Token[] | null {
  if (runs.length === 0) return null;
  const replace = new Map<number, Token | null>(); // token index → merged token (first) / null (swallowed)
  for (const run of runs) {
    const first = run[0]!.token;
    const last = run[run.length - 1]!.token;
    const ownsFirst = unitsOf([tokens[first]!]).length === 0 ? false : run[0]!.start === tokens[first]!.start;
    const ownsLast = run[run.length - 1]!.end === tokens[last]!.end;
    if (!ownsFirst || !ownsLast) continue; // cut inside a token by the length cap: leave it to the windows
    const raw = run.map((u) => text.slice(u.start, u.end)).join('');
    const merged = makeToken(raw, run[0]!.start, run[run.length - 1]!.end);
    merged.squash = true;
    merged.whole = true;
    for (let k = first; k <= last; k++) replace.set(k, k === first ? merged : null);
  }
  if (replace.size === 0) return null;
  const out: Token[] = [];
  tokens.forEach((t, k) => {
    if (!replace.has(k)) out.push(t);
    else {
      const m = replace.get(k);
      if (m) out.push(m);
    }
  });
  return out;
}

/** Every reading of the text that is matched against the word lists, plus its spelled-out runs. */
function streamsOf(text: string, skip: [number, number][]): { streams: Token[][]; runs: Unit[][] } {
  const bases = [tokenize(text, skip, 'ignore')];
  if (HAS_IGNORABLE.test(text)) bases.push(tokenize(text, skip, 'split'));
  const streams = [...bases];
  const runs: Unit[][] = [];
  for (const b of bases) {
    if (b.length > MAX_TOKENS) throw new TextTooComplexError();
    const units = unitsOf(b);
    if (units.length > MAX_UNITS) throw new TextTooComplexError();
    const r = runsOf(units, text);
    runs.push(...r);
    const merged = mergedStream(b, r, text);
    if (merged) streams.push(merged);
  }
  return { streams, runs };
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
  /** The words' letters joined without spaces ("dit me" -> "ditme"), and whether any word carries diacritics. */
  joined: string;
  joinedCollapsed: string;
  joinedToned: boolean;
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
        out.push({
          words: [single.word],
          joined: single.word.word,
          joinedCollapsed: collapseRuns(single.word.word),
          joinedToned: single.word.toned,
          substring: true,
          category,
          source: entry,
          list: key,
          exceptions,
        });
        continue;
      }
      const words = trimmed
        .split(/\s+/)
        .map((w) => parseWord(w)?.word)
        .filter((w): w is PatternWord => w !== undefined);
      if (words.length > 0) {
        const joined = words.map((w) => w.word).join('');
        out.push({
          words,
          joined,
          joinedCollapsed: collapseRuns(joined),
          joinedToned: words.some((w) => w.toned),
          substring: false,
          category,
          source: entry,
          list: key,
          exceptions,
        });
      }
    }
  }
  COMPILED.set(key, out);
  return out;
}

/** Whole-word patterns looked up by their letters with the spaces removed ("dit me" → "ditme"), for spelled-out runs. */
interface SquashIndex {
  toned: Map<string, Pattern[]>;
  plain: Map<string, Pattern[]>;
  tonedCollapsed: Map<string, Pattern[]>;
  plainCollapsed: Map<string, Pattern[]>;
  /** Entries whose last word is a `stem*`, by their joined letters (toned entries / untoned entries). */
  prefixToned: Map<string, Pattern[]>;
  prefixPlain: Map<string, Pattern[]>;
  /** Distinct lengths of the keys above (a window of n letters is tried against each length <= n). */
  prefixLens: number[];
}

/** Whole-word patterns of one list set, looked up by their FIRST word (a token is matched by hash, not by scanning). */
interface FirstIndex {
  tonedExact: Map<string, Pattern[]>;
  tonedCollapsed: Map<string, Pattern[]>;
  plainExact: Map<string, Pattern[]>;
  plainCollapsed: Map<string, Pattern[]>;
  /** Patterns whose first word is a `stem*`: few, checked one by one. */
  prefixFirst: Pattern[];
}

interface Plan {
  words: Pattern[];
  /** Position of each pattern in `words` (first match in this order wins: longest phrases first). */
  order: Map<Pattern, number>;
  substrings: Pattern[];
  squash: SquashIndex;
  first: FirstIndex;
  /** Multi-word patterns that a spelled-out / separator-joined token may match (see squashMatches). */
  squashable: Pattern[];
}

const PLAN_CACHE = new Map<string, Plan>();

const putInto = (m: Map<string, Pattern[]>, k: string, p: Pattern) => {
  const list = m.get(k);
  if (list) list.push(p);
  else m.set(k, [p]);
};

function buildSquashIndex(words: Pattern[]): SquashIndex {
  const idx: SquashIndex = {
    toned: new Map(),
    plain: new Map(),
    tonedCollapsed: new Map(),
    plainCollapsed: new Map(),
    prefixToned: new Map(),
    prefixPlain: new Map(),
    prefixLens: [],
  };
  const lens = new Set<number>();
  for (const p of words) {
    if (p.words.slice(0, -1).some((w) => w.prefix)) continue;
    const joined = p.words.map((w) => w.word).join('');
    const toned = p.words.some((w) => w.toned);
    if (p.words[p.words.length - 1]!.prefix) {
      putInto(toned ? idx.prefixToned : idx.prefixPlain, joined, p);
      lens.add(joined.length);
      continue;
    }
    putInto(toned ? idx.toned : idx.plain, joined, p);
    putInto(toned ? idx.tonedCollapsed : idx.plainCollapsed, collapseRuns(joined), p);
  }
  idx.prefixLens = [...lens].sort((a, b) => a - b);
  return idx;
}

function buildFirstIndex(words: Pattern[]): FirstIndex {
  const idx: FirstIndex = {
    tonedExact: new Map(),
    tonedCollapsed: new Map(),
    plainExact: new Map(),
    plainCollapsed: new Map(),
    prefixFirst: [],
  };
  for (const p of words) {
    const w = p.words[0]!;
    if (w.prefix) {
      idx.prefixFirst.push(p);
      continue;
    }
    if (w.toned) {
      putInto(idx.tonedExact, w.word, p);
      putInto(idx.tonedCollapsed, w.collapsed, p);
    } else {
      putInto(idx.plainExact, w.word, p);
      putInto(idx.plainCollapsed, w.collapsed, p);
    }
  }
  return idx;
}

/** Word patterns (longest phrases first, so "bú lồn" wins over "lồn") and substring patterns of some lists. */
function planFor(lists: readonly ListKey[]): Plan {
  const id = [...lists].sort().join(',');
  const cached = PLAN_CACHE.get(id);
  if (cached) return cached;
  const all = lists.flatMap((k) => compileList(k));
  const words = all.filter((p) => !p.substring).sort((a, b) => b.words.length - a.words.length);
  const plan: Plan = {
    words,
    order: new Map(words.map((p, i) => [p, i] as [Pattern, number])),
    substrings: all.filter((p) => p.substring),
    squash: buildSquashIndex(words),
    first: buildFirstIndex(words),
    squashable: words.filter((p) => p.words.length >= 2 && !p.words.slice(0, -1).some((w) => w.prefix)),
  };
  PLAN_CACHE.set(id, plan);
  return plan;
}

function matchForm(t: Form, w: PatternWord): boolean {
  if (w.prefix) return (w.toned ? t.toned : t.plain).startsWith(w.word);
  if (w.toned) {
    return t.toned === w.word || (t.tonedCollapsed !== t.toned && t.tonedCollapsed === w.collapsed);
  }
  // Elongated forms ("đmmmm", "fuuuck") match via the collapsed form, but only when the token
  // really contained a repeated letter — so "as" never matches a collapsed "ass".
  return t.plain === w.word || (t.plainCollapsed !== t.plain && t.plainCollapsed === w.collapsed);
}

function wordMatches(t: Token, w: PatternWord): boolean {
  return matchForm(t, w) || t.alts.some((a) => matchForm(a, w));
}

/**
 * A run joined across separators ("dit_me", "d i t m e", "ngu-vl") matches a multi-word entry written
 * with spaces ("dit me", "ngu vl") when the letters are the same.
 */
function squashMatches(t: Token, p: Pattern): boolean {
  if (!t.squash || p.substring || p.words.length < 2) return false;
  if (p.words.slice(0, -1).some((w) => w.prefix)) return false;
  const { joined, joinedCollapsed, joinedToned: toned } = p;
  const last = p.words[p.words.length - 1]!;
  const check = (f: Form): boolean => {
    const hay = toned ? f.toned : f.plain;
    if (last.prefix) return hay.startsWith(joined);
    return hay === joined || (toned ? f.tonedCollapsed : f.plainCollapsed) === joinedCollapsed;
  };
  return check(t) || t.alts.some(check);
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

/** Patterns whose FIRST word matches `t` in some reading (hash lookups); the caller verifies the rest. */
function candidatesFor(t: Token, plan: Plan): Pattern[] {
  const idx = plan.first;
  const out: Pattern[] = [];
  const add = (l: Pattern[] | undefined) => {
    if (l) for (const p of l) out.push(p);
  };
  add(idx.tonedExact.get(t.toned));
  if (t.tonedCollapsed !== t.toned) add(idx.tonedCollapsed.get(t.tonedCollapsed));
  add(idx.plainExact.get(t.plain));
  if (t.plainCollapsed !== t.plain) add(idx.plainCollapsed.get(t.plainCollapsed));
  for (const a of t.alts) {
    add(idx.tonedExact.get(a.toned));
    if (a.tonedCollapsed !== a.toned) add(idx.tonedCollapsed.get(a.tonedCollapsed));
    add(idx.plainExact.get(a.plain));
    if (a.plainCollapsed !== a.plain) add(idx.plainCollapsed.get(a.plainCollapsed));
  }
  for (const p of idx.prefixFirst) out.push(p);
  return out;
}

function collect(tokens: Token[], plan: Plan, found: WordMatch[]): void {
  // Whole words, prefixes and phrases.
  let i = 0;
  while (i < tokens.length) {
    let hit: Pattern | undefined;
    let used = 1;
    const first = tokens[i]!;
    if (first.squash) {
      // A token joined across separators / spelled out may also match a multi-word entry: first match in list order.
      for (const p of plan.words) {
        if (squashMatches(first, p)) {
          if (p.words.some((w) => w.prefix) && tokenExcepted(first, p.exceptions)) continue;
          hit = p;
          used = 1;
          break;
        }
        if (i + p.words.length > tokens.length) continue;
        if (!p.words.every((w, k) => wordMatches(tokens[i + k]!, w))) continue;
        if (p.words.some((w) => w.prefix) && tokenExcepted(first, p.exceptions)) continue;
        hit = p;
        used = p.words.length;
        break;
      }
    } else {
      // Ordinary token: only patterns whose first word matches it can hit; the earliest in list order wins.
      let bestOrder = Infinity;
      for (const p of candidatesFor(first, plan)) {
        const order = plan.order.get(p)!;
        if (order >= bestOrder) continue;
        if (i + p.words.length > tokens.length) continue;
        if (!p.words.every((w, k) => wordMatches(tokens[i + k]!, w))) continue;
        if (p.words.some((w) => w.prefix) && tokenExcepted(first, p.exceptions)) continue;
        hit = p;
        used = p.words.length;
        bestOrder = order;
      }
    }
    if (hit) {
      found.push({
        start: tokens[i]!.start,
        end: tokens[i + used - 1]!.end,
        category: hit.category,
        source: hit.source,
        list: hit.list,
      });
      i += used;
    } else {
      i++;
    }
  }

  // Substrings inside a token (scripts written without spaces).
  if (plan.substrings.length > 0) {
    for (const t of tokens) {
      for (const p of plan.substrings) {
        const w = p.words[0]!;
        if (p.exceptions.words.some((x) => wordMatches(t, x))) continue;
        const forms: { form: Form; alt: boolean }[] = [{ form: t, alt: false }, ...t.alts.map((form) => ({ form, alt: true }))];
        for (const { form, alt } of forms) {
          const hay = w.toned ? form.toned : form.plain;
          if (hay.length < w.word.length) continue;
          let from = 0;
          for (;;) {
            const idx = hay.indexOf(w.word, from);
            if (idx < 0) break;
            from = idx + 1;
            if (insideExceptionPart(hay, idx, w.word.length, w.toned, p.exceptions)) continue;
            const [start, end] = alt ? [t.start, t.end] : rawRange(t, hay, w.toned, idx, w.word.length);
            found.push({ start, end, category: p.category, source: p.source, list: p.list });
          }
        }
      }
    }
  }
}

/**
 * Words hidden inside a run of spelled-out letters ("I f u c k you", "a v c l b"): every window of at least
 * three letters is looked up as a word. Each letter's forms are computed once per run and windows are built by
 * concatenation, so a window costs a few hash lookups (no normalisation). Runs with look-alike-script letters or
 * Hangul jamo (which compose across letters) take the exact, slower route.
 */
const NEEDS_EXACT_WINDOWS = /[\p{Script=Cyrillic}\p{Script=Greek}\u1100-\u11FF\u3130-\u318F]/u;

function windowHits(plan: Plan, toned: string, plain: string, tonedC: string, plainC: string, out: Pattern[]): void {
  const sq = plan.squash;
  const add = (list: Pattern[] | undefined) => {
    if (list) for (const p of list) if (!out.includes(p)) out.push(p);
  };
  add(sq.toned.get(toned));
  add(sq.plain.get(plain));
  if (tonedC !== toned) add(sq.tonedCollapsed.get(tonedC));
  if (plainC !== plain) add(sq.plainCollapsed.get(plainC));
  for (const len of sq.prefixLens) {
    if (toned.length >= len) add(sq.prefixToned.get(toned.slice(0, len)));
    if (plain.length >= len) add(sq.prefixPlain.get(plain.slice(0, len)));
  }
}

/** Appends `piece` to a run-collapsed string ("aab" + "bc" -> "abc"): same as collapseRuns(whole) without a regex. */
function appendCollapsed(acc: string, piece: string): string {
  if (piece === '') return acc;
  if (acc === '') return piece;
  const n = acc.length;
  const pair = n >= 2 ? acc.codePointAt(n - 2)! : 0;
  const last = pair > 0xffff ? pair : acc.codePointAt(n - 1)!;
  const first = piece.codePointAt(0)!;
  return last === first ? acc + piece.slice(first > 0xffff ? 2 : 1) : acc + piece;
}

function collectWindows(run: Unit[], plan: Plan, found: WordMatch[]): void {
  const n = run.length;
  const exact = run.some((u) => NEEDS_EXACT_WINDOWS.test(u.piece));
  const raw = run.map((u) => u.piece);
  const leet = raw.map((p) => [...p].map((ch) => LEET[ch] ?? ch).join(''));
  const rawPlain = exact ? raw : raw.map(stripDiacritics);
  const leetPlain = exact ? leet : leet.map(stripDiacritics);
  const letter = raw.map((p) => /\p{L}/u.test(p));
  // Collapsed (elongation-tolerant) forms of each piece; joined incrementally below.
  const rawC = raw.map(collapseRuns);
  const leetC = leet.map(collapseRuns);
  const rawPlC = rawPlain.map(collapseRuns);
  const leetPlC = leetPlain.map(collapseRuns);

  for (let a = 0; a + 2 < n; a++) {
    let rawStr = raw[a]! + raw[a + 1]!;
    let leetStr = leet[a]! + leet[a + 1]!;
    let rawPl = rawPlain[a]! + rawPlain[a + 1]!;
    let leetPl = leetPlain[a]! + leetPlain[a + 1]!;
    let rawCol = appendCollapsed(rawC[a]!, rawC[a + 1]!);
    let leetCol = appendCollapsed(leetC[a]!, leetC[a + 1]!);
    let rawPlCol = appendCollapsed(rawPlC[a]!, rawPlC[a + 1]!);
    let leetPlCol = appendCollapsed(leetPlC[a]!, leetPlC[a + 1]!);
    let hasLetter = letter[a]! || letter[a + 1]!;
    for (let b = a + 2; b < n && b - a < MAX_WINDOW_UNITS; b++) {
      rawStr += raw[b]!;
      leetStr += leet[b]!;
      rawPl += rawPlain[b]!;
      leetPl += leetPlain[b]!;
      rawCol = appendCollapsed(rawCol, rawC[b]!);
      leetCol = appendCollapsed(leetCol, leetC[b]!);
      rawPlCol = appendCollapsed(rawPlCol, rawPlC[b]!);
      leetPlCol = appendCollapsed(leetPlCol, leetPlC[b]!);
      if (letter[b]) hasLetter = true;
      const hits: Pattern[] = [];
      if (!exact) {
        if (hasLetter) windowHits(plan, leetStr, leetPl, leetCol, leetPlCol, hits);
        else windowHits(plan, rawStr, rawPl, rawCol, rawPlCol, hits);
      } else {
        const mapped = hasLetter ? leetStr : rawStr;
        const spellings = [mapped];
        if (HAS_LOOKALIKE_SCRIPT.test(mapped)) {
          const latin = foldWith(mapped, LOOKALIKE_TO_LATIN);
          if (latin !== mapped) spellings.push(latin);
          if (/\p{Script=Cyrillic}/u.test(mapped) && /[a-z]/.test(mapped)) spellings.push(foldWith(mapped, LATIN_TO_CYRILLIC));
        }
        for (const toned of spellings) {
          const plain = stripDiacritics(toned);
          windowHits(plan, toned, plain, collapseRuns(toned), collapseRuns(plain), hits);
        }
      }
      for (const p of hits) {
        found.push({ start: run[a]!.start, end: run[b]!.end, category: p.category, source: p.source, list: p.list });
      }
    }
  }
}

/** Finds word-list matches of the given lists (whole words, prefixes and substrings; see types.ts). */
export function findMatches(text: string, lists: readonly ListKey[], skip: [number, number][] = []): WordMatch[] {
  const plan = planFor(lists);
  const found: WordMatch[] = [];
  const { streams, runs } = streamsOf(text, skip);
  for (const tokens of streams) collect(tokens, plan, found);
  for (const run of runs) collectWindows(run, plan, found);
  // Several readings can find the same word: keep one.
  const seen = new Set<string>();
  return found.filter((m) => {
    const k = `${m.start}:${m.end}:${m.category}:${m.source}`;
    if (seen.has(k)) return false;
    seen.add(k);
    return true;
  });
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

  // Look at the text the way the matcher does: invisible characters gone, full-width / stylised letters plain.
  const seen = text.replace(IGNORABLE, '').normalize('NFKC');
  const has = (re: RegExp) => re.test(seen);
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

  // A Latin word with a few Cyrillic / Greek look-alike letters ("dіt") is still Latin text: the Latin
  // rules (Vietnamese teencode, country language) apply to it too.
  const folded = foldWith(seen.toLowerCase(), LOOKALIKE_TO_LATIN);
  const latinOnly = !(
    hangul ||
    kana ||
    han ||
    thai ||
    arabic ||
    SCRIPT.cyrillic.test(folded) ||
    SCRIPT.otherNonLatin.test(folded)
  );
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
const PHONE_VN_RE = /(?<!\p{N})(?:\+?\s?84|0)[\s.\-_/·•]{0,2}[35789](?:[\s.\-_/·•]{0,2}\d){8}(?!\p{N})/u;
/** International numbers written with a leading "+" and country code: +1 (415) 555-2671, +62 812-3456-7890. */
const PHONE_INTL_RE = /(?<![\p{L}\p{N}])\+\s?\d{1,3}(?:[\s.()-]{0,2}\d){7,12}(?!\p{N})/u;

export function containsPhoneNumber(text: string): boolean {
  // Full-width digits and invisible characters inside the number do not hide it.
  const t = text.replace(IGNORABLE, '').normalize('NFKC');
  return PHONE_VN_RE.test(t) || PHONE_INTL_RE.test(t);
}

// ---- public API ------------------------------------------------------------------------------

export type RejectReason = 'hate' | 'sexual' | 'harassment' | 'scam' | 'phone' | 'complex';

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
  if (input.length > MAX_INPUT_CHARS) {
    return { text: input, rejected: 'complex', masked: 0, linksRemoved: 0, lists: [] };
  }
  const nfc = input.normalize('NFC');
  const { text, removed } = stripLinks(nfc);
  const skip = linkRanges(text);
  const lists = listsFor(text, opts.language, opts.country);
  let matches: WordMatch[];
  try {
    matches = findMatches(text, lists, skip);
  } catch (e) {
    if (e instanceof TextTooComplexError) {
      return { text, rejected: 'complex', masked: 0, linksRemoved: removed, lists };
    }
    throw e;
  }
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
  if (r.rejected === 'complex') throw reasonError('invalid_input', 'content_too_complex');
  if (r.rejected === 'scam' || r.rejected === 'phone') throw reasonError('invalid_input', 'content_scam');
  if (r.rejected) throw reasonError('invalid_input', 'content_inappropriate');
  return r.text;
}
