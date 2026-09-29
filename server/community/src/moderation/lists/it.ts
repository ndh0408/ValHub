/**
 * Italian (it) word list.
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives, and have a native speaker check every entry for false positives before relying on it.
 * Ordinary words are left out on purpose ("troia" = Troy, "culo", "fica", "finocchio" = fennel,
 * "checca", "spastico", "crepa" = crack, "muori").
 * Entry syntax: see ../types.ts. Diacritics are ignored unless the entry itself carries them.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const IT_WORDLIST = defineWordlist('it', {
  reviewed: false,
  profanity: [
    'cazzo', 'cazzi', 'vaffanculo', 'fanculo', 'vaffa', 'stronzo', 'stronza', 'stronzi', 'merda', 'merdoso',
    'puttana', 'puttane', 'minchia', 'coglione', 'coglioni', 'porco dio', 'porcodio', 'dio cane', 'diocane',
    'dio porco', 'porca madonna', 'madonna puttana', 'figlio di puttana', 'figlio di troia', 'bastardo',
    'pezzo di merda', 'testa di cazzo', 'rompicoglioni', 'succhiacazzi', 'pompino', 'pompini',
  ],
  hate: [
    'frocio', 'froci', 'ricchione', 'ricchioni', 'terrone', 'terroni', 'sporco negro', 'sporco ebreo',
    'sporco terrone', 'zingaraccio', 'mongoloide', 'mongoloidi', 'ebreo di merda', 'negro di merda',
  ],
  sexual: ['mandami nudes', 'manda nudes', 'mandami foto nuda', 'foto nuda', 'foto nudo', 'stupro', 'stuprare', 'stupratore'],
  harassment: ['ammazzati', 'suicidati', 'vai a morire', 'spero che muori', 'spero che tu muoia', 'ti ammazzo'],
  scam: [
    'vendo account', 'vendo acc', 'vendo profilo', 'account in vendita', 'compro account', 'compro acc',
    'boost di rank', 'servizio di boost', 'vendo conto',
  ],
});
