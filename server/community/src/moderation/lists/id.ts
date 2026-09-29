/**
 * Indonesian / Malay (id) word list.
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives, and have a native speaker check every entry for false positives before relying on it.
 * "anjing" (dog), "babi" (pig), "tai" (as in Tai Chi), "joki" (jockey), "bunuh diri" (news reports),
 * "beli akun" and "suka" are ordinary words and are only matched inside insulting phrases.
 * Entry syntax: see ../types.ts. Diacritics are ignored unless the entry itself carries them.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const ID_WORDLIST = defineWordlist('id', {
  reviewed: false,
  profanity: [
    'anjg', 'anjrit', 'ajg', 'asu', 'bangsat', 'bgst', 'bajingan', 'kontol', 'kntl', 'kntol', 'memek', 'ngentot',
    'ngntd', 'entot', 'jancok', 'jancuk', 'dancok', 'diancok', 'pepek', 'pantek', 'tempik', 'kimak', 'cukimai',
    'sundal', 'lonte', 'perek', 'keparat', 'sialan', 'brengsek', 'kampret', 'ngewe', 'anjing lu', 'anjing lo',
    'anjing kau', 'anjing kamu', 'dasar anjing', 'dasar babi', 'babi lu', 'babi lo',
  ],
  hate: ['bencong', 'cokin'],
  sexual: [
    'kirim nude', 'kirim foto bugil', 'foto bugil', 'video bugil', 'open bo', 'jasa bo', 'memperkosa',
    'pemerkosaan', 'perkosa',
  ],
  harassment: [
    'bunuh diri sana', 'bunuh diri aja', 'bunuh diri lu', 'mati aja lu', 'mati aja lo', 'mati aja kamu',
    'semoga kamu mati', 'semoga lu mati',
  ],
  scam: [
    'jual akun', 'jual acc', 'jual account', 'akun dijual', 'akun di jual', 'jasa joki', 'joki rank',
    'joki valorant', 'order joki', 'jual beli akun', 'jasa boost', 'boost rank',
  ],
});
