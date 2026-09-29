/**
 * Polish (pl) word list. Polish is inflected, so many entries are word stems (`stem*`).
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives, and have a native speaker check every entry for false positives before relying on it.
 * Ordinary words are left out on purpose ("suka" = female dog, "szmata" = rag, "pedał" = pedal,
 * "gwałtowny" = sudden, "dupa", "debil", "zajebisty").
 * Entry syntax: see ../types.ts. Diacritics are ignored unless the entry itself carries them.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const PL_WORDLIST = defineWordlist('pl', {
  reviewed: false,
  profanity: [
    'kurw*', 'skurwysyn*', 'skurwiel*', 'chuj*', 'pierdol*', 'pierdal*', 'spierdala*', 'wypierdala*',
    'zapierdala*', 'odpierdol*', 'jeban*', 'jebac', 'jebie', 'jebnij', 'pojeb*', 'zjeb*', 'pizd*', 'cipa',
    'cipka', 'cipy', 'kutas', 'kutasy', 'kutasie', 'dupek', 'cwel', 'cwele', 'dziwka', 'dziwki', 'gowno*',
  ],
  hate: ['ciota', 'cioty', 'czarnuch*', 'żydek', 'polaczek', 'polaczki'],
  sexual: [
    'nudesy', 'pokaz cycki', 'pokaz piersi', 'zdjecia nago', 'gwałt', 'gwałcić', 'zgwałcę', 'zgwałcić', 'gwalt',
    'gwalcic', 'zgwalce', 'zgwalcic',
  ],
  harassment: [
    'zabij sie', 'zdychaj', 'zdechnij', 'idz sie zabij', 'obys zdechl', 'obys zdechla',
  ],
  scam: [
    'sprzedam konto', 'sprzedam acc', 'sprzedam account', 'konto na sprzedaz', 'kupie konto', 'boost rangi',
    'boosting rangi', 'podbijanie rangi',
  ],
});
