import { invalid } from '../errors.js';

/** App / content languages (VALORANT's 18 locales; es-ES and es-MX share `es`). */
export const LANGUAGES = [
  'ar',
  'de',
  'en',
  'es',
  'fr',
  'id',
  'it',
  'ja',
  'ko',
  'pl',
  'pt',
  'ru',
  'th',
  'tr',
  'vi',
  'zh-CN',
  'zh-TW',
] as const;
export type Language = (typeof LANGUAGES)[number];

const SIMPLE = new Set<string>(LANGUAGES.filter((l) => !l.includes('-')));

/**
 * Canonicalises a language code. Accepts the 17 codes in any case, `_` instead of `-`
 * (Flutter's `Locale.toString()` gives `zh_CN`) and region-qualified locales of the simple
 * codes (`pt-BR` → `pt`, `es-MX` → `es`, `vi-VN` → `vi`). Chinese needs the script/region:
 * `zh-CN`, `zh-SG`, `zh-Hans*` → `zh-CN`; `zh-TW`, `zh-HK`, `zh-MO`, `zh-Hant*` → `zh-TW`.
 * Returns null for anything else.
 */
export function canonicalLanguage(v: unknown): Language | null {
  if (typeof v !== 'string') return null;
  const s = v.trim().replace(/_/g, '-').toLowerCase();
  if (s.length === 0 || s.length > 20 || !/^[a-z]{2,3}(-[a-z0-9]{2,8})*$/.test(s)) return null;
  const [base, ...rest] = s.split('-');
  if (base === 'zh') {
    const sub = rest.join('-');
    if (/^(cn|sg|hans)(-|$)/.test(sub)) return 'zh-CN';
    if (/^(tw|hk|mo|hant)(-|$)/.test(sub)) return 'zh-TW';
    return null;
  }
  return base && SIMPLE.has(base) ? (base as Language) : null;
}

/** Validating parser: 400 invalid_input when the value is not one of the 17 languages. */
export function parseLanguage(v: unknown, field: string): Language {
  const lang = canonicalLanguage(v);
  if (!lang) throw invalid(`${field} phải là một trong: ${LANGUAGES.join(', ')}.`);
  return lang;
}

/**
 * Optional per-item `language` (the language the text is written in). Absent or null → the
 * author's language (which itself may be null for clients that never sent one).
 */
export function contentLanguage(body: Record<string, unknown>, authorLanguage: string | null): string | null {
  const v = body.language;
  if (v === undefined || v === null) return authorLanguage ?? null;
  return parseLanguage(v, 'language');
}

/** LFG party language: one of the 17 languages or `any`. */
export function parseLfgLanguage(v: unknown, field: string): Language | 'any' {
  if (typeof v === 'string' && v.trim().toLowerCase() === 'any') return 'any';
  const lang = canonicalLanguage(v);
  if (!lang) throw invalid(`${field} phải là một trong: ${LANGUAGES.join(', ')}, any.`);
  return lang;
}

/**
 * `?language=vi,en` → unique canonical codes. `allowAny` lets LFG accept `any` (returned as the
 * literal 'any' entry). Empty / absent → undefined.
 */
export function parseLanguageList(raw: string | undefined, allowAny = false): string[] | undefined {
  if (raw === undefined || raw.trim() === '') return undefined;
  const parts = raw.split(',').map((p) => p.trim()).filter(Boolean);
  if (parts.length === 0) return undefined;
  if (parts.length > LANGUAGES.length + 1) throw invalid('language có quá nhiều giá trị.');
  const out = new Set<string>();
  for (const p of parts) out.add(allowAny ? parseLfgLanguage(p, 'language') : parseLanguage(p, 'language'));
  return [...out];
}
