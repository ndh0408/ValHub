import { invalid, reasonError } from './errors.js';

export const REGIONS = ['ap', 'na', 'eu', 'kr', 'latam', 'br'] as const;
export type Region = (typeof REGIONS)[number];

export const LFG_MODES = [
  'competitive',
  'unrated',
  'swiftplay',
  'spikerush',
  'deathmatch',
  'teamdeathmatch',
  'premier',
  'custom',
] as const;
export type LfgMode = (typeof LFG_MODES)[number];

export const POST_KINDS = ['text', 'store', 'nightmarket'] as const;
export type PostKind = (typeof POST_KINDS)[number];

export const REPORT_TARGETS = ['post', 'comment', 'lfg', 'review'] as const;
export type ReportTarget = (typeof REPORT_TARGETS)[number];

export const LFG_ROLES = ['duelist', 'initiator', 'controller', 'sentinel', 'flex'] as const;
export const LFG_STATUSES = ['open', 'full', 'in_game'] as const;

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/;
export const PARTY_CODE_RE = /^[A-Z0-9]{6}$/;

export type Json = Record<string, unknown>;

export function isObject(v: unknown): v is Json {
  return typeof v === 'object' && v !== null && !Array.isArray(v);
}

/** Parses a JSON request body that must be an object. */
export function parseJsonObject(text: string): Json {
  let parsed: unknown;
  try {
    parsed = text.length === 0 ? {} : JSON.parse(text);
  } catch {
    throw reasonError('invalid_input', 'body_invalid_json');
  }
  if (!isObject(parsed)) throw reasonError('invalid_input', 'body_not_object');
  return parsed;
}

/** Length in Unicode code points after NFC, not grapheme clusters. */
export function charLength(s: string): number {
  let n = 0;
  for (const _ of s) n++;
  return n;
}

/** Normalises and validates a UUID (accepts upper-case input, returns lower-case). */
export function parseUuid(v: unknown, field: string): string {
  if (typeof v !== 'string') throw reasonError('invalid_input', 'field_not_uuid', { field });
  const s = v.trim().toLowerCase();
  if (!UUID_RE.test(s)) throw reasonError('invalid_input', 'field_not_uuid', { field });
  return s;
}

export function isUuid(v: string): boolean {
  return UUID_RE.test(v);
}

export function parseEnum<T extends string>(v: unknown, allowed: readonly T[], field: string): T {
  if (typeof v !== 'string' || !(allowed as readonly string[]).includes(v)) {
    throw reasonError('invalid_input', 'field_not_in_list', { field, allowed: allowed.join(', ') });
  }
  return v as T;
}

export function parseInt(v: unknown, min: number, max: number, field: string): number {
  if (typeof v !== 'number' || !Number.isInteger(v) || v < min || v > max) {
    throw reasonError('invalid_input', 'field_not_int', { field, min, max });
  }
  return v;
}

/** `undefined` → field absent, `null` → explicitly cleared. */
export function parseOptional<T>(
  obj: Json,
  key: string,
  parse: (v: unknown) => T,
): T | null | undefined {
  if (!(key in obj) || obj[key] === undefined) return undefined;
  if (obj[key] === null) return null;
  return parse(obj[key]);
}

export function parseString(
  v: unknown,
  field: string,
  opts: { max: number; min?: number },
): string {
  if (typeof v !== 'string') throw reasonError('invalid_input', 'field_not_string', { field });
  if (v.includes('\u0000')) throw reasonError('invalid_input', 'field_bad_chars', { field });
  const s = v.normalize('NFC').trim();
  const len = charLength(s);
  const min = opts.min ?? 0;
  if (len < min) throw reasonError('invalid_input', 'field_empty', { field });
  if (len > opts.max) throw reasonError('invalid_input', 'field_too_long', { field, max: opts.max, unit: 'code_points' });
  return s;
}

export function parseRankTier(v: unknown): number {
  return parseInt(v, 0, 27, 'rankTier');
}

export function parseRegion(v: unknown): Region {
  return parseEnum(v, REGIONS, 'region');
}

/** YYYY-MM-DD that is a real calendar date. */
export function parseDate(v: unknown, field: string): string {
  if (typeof v !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(v)) {
    throw reasonError('invalid_input', 'field_not_date', { field });
  }
  const d = new Date(`${v}T00:00:00Z`);
  if (Number.isNaN(d.getTime()) || d.toISOString().slice(0, 10) !== v) {
    throw reasonError('invalid_input', 'field_bad_date', { field });
  }
  return v;
}

/** Pagination `limit` query param: 1..max, default `def`. */
export function parseLimit(raw: string | undefined, def: number, max: number): number {
  if (raw === undefined || raw === '') return def;
  if (!/^\d{1,4}$/.test(raw)) throw reasonError('invalid_input', 'limit_out_of_range', { max });
  const n = Number(raw);
  if (n < 1 || n > max) throw reasonError('invalid_input', 'limit_out_of_range', { max });
  return n;
}

export function parseBool(v: unknown, field: string): boolean {
  if (typeof v !== 'boolean') throw reasonError('invalid_input', 'field_not_bool', { field });
  return v;
}

/** Array of unique values, each parsed by `parse`, at most `max` entries. */
export function parseUniqueArray<T>(v: unknown, field: string, max: number, parse: (x: unknown) => T): T[] {
  if (!Array.isArray(v) || v.length > max) throw reasonError('invalid_input', 'array_bad_size', { field, max });
  const out = v.map(parse);
  if (new Set(out).size !== out.length) throw reasonError('invalid_input', 'array_duplicates', { field });
  return out;
}
