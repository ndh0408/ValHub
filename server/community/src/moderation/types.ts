/**
 * Categories:
 * - profanity  → the matched words are masked with *** (content is kept)
 * - hate       → rejected (slurs against ethnicity, region, religion, gender, sexuality, disability)
 * - sexual     → rejected (sexual harassment / solicitation)
 * - harassment → rejected (telling people to kill themselves, threats)
 * - scam       → rejected (account selling / boosting ads; the community guidelines forbid them)
 */
export type WordCategory = 'profanity' | 'hate' | 'sexual' | 'harassment' | 'scam';

export const WORD_CATEGORIES: readonly WordCategory[] = ['profanity', 'hate', 'sexual', 'harassment', 'scam'];

/** Keys of the word lists. zh-CN and zh-TW share `zh` (Simplified and Traditional forms). */
export type ListKey =
  | 'vi'
  | 'en'
  | 'ar'
  | 'de'
  | 'es'
  | 'fr'
  | 'id'
  | 'it'
  | 'ja'
  | 'ko'
  | 'pl'
  | 'pt'
  | 'ru'
  | 'th'
  | 'tr'
  | 'zh';

/**
 * Entry syntax (one string per entry, lower case):
 * - `word`         a whole word. Written WITHOUT diacritics it matches any accenting ("dm" ↔ "đm");
 *                  written WITH diacritics it only matches that exact form ("đĩ" never matches "đi").
 * - `two words`    consecutive words.
 * - `stem*`        any word that STARTS with the stem (inflected languages: Russian, Polish, Korean...).
 * - `*part*`       the text anywhere inside a word (scripts written without spaces: Chinese, Japanese, Thai).
 * Combine `stem*` inside phrases freely ("ngu vl", "мать*"), but `*part*` is single-token only.
 */
export interface LanguageWordlist {
  key: ListKey;
  /**
   * false = best-effort list written without a native speaker: it NEEDS NATIVE REVIEW before it is
   * relied on (false negatives are expected; check for false positives too).
   */
  reviewed: boolean;
  /** Whole words / word prefixes (`stem*`) that must never trigger `stem*` / `*part*` entries of this list. */
  exceptions: readonly string[];
  words: Record<WordCategory, readonly string[]>;
}

export function defineWordlist(
  key: ListKey,
  o: {
    reviewed?: boolean;
    exceptions?: readonly string[];
    profanity?: readonly string[];
    hate?: readonly string[];
    sexual?: readonly string[];
    harassment?: readonly string[];
    scam?: readonly string[];
  },
): LanguageWordlist {
  return {
    key,
    reviewed: o.reviewed ?? false,
    exceptions: o.exceptions ?? [],
    words: {
      profanity: o.profanity ?? [],
      hate: o.hate ?? [],
      sexual: o.sexual ?? [],
      harassment: o.harassment ?? [],
      scam: o.scam ?? [],
    },
  };
}
