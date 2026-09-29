import { canonicalLanguage } from '../geo/languages.js';
import { EN_WORDLIST } from './en-wordlist.js';
import { AR_WORDLIST } from './lists/ar.js';
import { DE_WORDLIST } from './lists/de.js';
import { ES_WORDLIST } from './lists/es.js';
import { FR_WORDLIST } from './lists/fr.js';
import { ID_WORDLIST } from './lists/id.js';
import { IT_WORDLIST } from './lists/it.js';
import { JA_WORDLIST } from './lists/ja.js';
import { KO_WORDLIST } from './lists/ko.js';
import { PL_WORDLIST } from './lists/pl.js';
import { PT_WORDLIST } from './lists/pt.js';
import { RU_WORDLIST } from './lists/ru.js';
import { TH_WORDLIST } from './lists/th.js';
import { TR_WORDLIST } from './lists/tr.js';
import { ZH_WORDLIST } from './lists/zh.js';
import type { LanguageWordlist, ListKey } from './types.js';
import { VI_WORDLIST } from './vi-wordlist.js';

/** All word lists by key. vi and en are reviewed; the other lists are best-effort (see `reviewed`). */
export const WORDLISTS: Readonly<Record<ListKey, LanguageWordlist>> = {
  vi: VI_WORDLIST,
  en: EN_WORDLIST,
  ar: AR_WORDLIST,
  de: DE_WORDLIST,
  es: ES_WORDLIST,
  fr: FR_WORDLIST,
  id: ID_WORDLIST,
  it: IT_WORDLIST,
  ja: JA_WORDLIST,
  ko: KO_WORDLIST,
  pl: PL_WORDLIST,
  pt: PT_WORDLIST,
  ru: RU_WORDLIST,
  th: TH_WORDLIST,
  tr: TR_WORDLIST,
  zh: ZH_WORDLIST,
};

export const LIST_KEYS = Object.keys(WORDLISTS) as ListKey[];

/** Lists that still need a native speaker's review. */
export const LISTS_NEEDING_NATIVE_REVIEW: readonly ListKey[] = LIST_KEYS.filter((k) => !WORDLISTS[k].reviewed);

/** Word list of a content language (any accepted spelling: `pt-BR`, `zh_TW`, ...); null if there is none. */
export function listKeyForLanguage(language: string | null | undefined): ListKey | null {
  const lang = canonicalLanguage(language);
  if (!lang) return null;
  if (lang === 'zh-CN' || lang === 'zh-TW') return 'zh';
  return lang in WORDLISTS ? (lang as ListKey) : null;
}
