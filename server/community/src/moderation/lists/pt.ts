/**
 * Portuguese (pt) word list (Brazil + Portugal).
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives, and have native speakers (Brazil and Portugal) check every entry for false positives.
 * Ordinary words are left out on purpose ("puto" = boy in Portugal, "pica", "rola", "corno", "piranha",
 * "crioulo" = Creole, "bicha" = queue, "macaco", "retardado").
 * Entry syntax: see ../types.ts. Diacritics are ignored unless the entry itself carries them.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const PT_WORDLIST = defineWordlist('pt', {
  reviewed: false,
  profanity: [
    'caralho', 'caralhos', 'krl', 'crl', 'porra', 'puta', 'putas', 'foda', 'fodase', 'foder', 'fodido', 'fodida',
    'merda', 'merdas', 'buceta', 'boceta', 'arrombado', 'arrombada', 'filho da puta', 'filha da puta', 'fdp',
    'vsf', 'vai se foder', 'vai tomar no cu', 'vtnc', 'tnc', 'pqp', 'puta que pariu', 'pau no cu', 'cuzao',
    'cuzona', 'punheta', 'punheteiro', 'xoxota', 'xereca', 'piroca', 'cacete',
  ],
  hate: ['viado', 'viados', 'sapatao', 'traveco', 'travecos', 'baitola', 'boiola', 'mongoloide', 'mongoloides'],
  sexual: [
    'manda nudes', 'mande nudes', 'me manda nudes', 'manda foto pelada', 'manda foto pelado', 'fotos peladas',
    'estupro', 'estuprar', 'estuprador', 'chupa meu pau',
  ],
  harassment: ['vai se matar', 'espero que voce morra', 'espero que morra', 'vou te matar'],
  scam: [
    'vendo conta', 'vendo contas', 'vendo acc', 'vendo account', 'conta a venda', 'compro conta', 'compro contas',
    'eloboost', 'elo boost', 'boost de elo', 'boost de rank', 'servico de boost', 'vendo perfil',
  ],
});
