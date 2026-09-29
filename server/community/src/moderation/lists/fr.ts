/**
 * French (fr) word list.
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives, and have a native speaker check every entry for false positives before relying on it.
 * Ordinary words are left out on purpose ("con", "chatte", "bite", "batard", "tapette", "raton", "crève").
 * "négro" only matches with the accent (Spanish / Portuguese "negro" = black is not affected).
 * Entry syntax: see ../types.ts. Diacritics are ignored unless the entry itself carries them.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const FR_WORDLIST = defineWordlist('fr', {
  reviewed: false,
  profanity: [
    'putain', 'putains', 'ptn', 'merde', 'merdes', 'mrd', 'connard', 'connards', 'connasse', 'connasses',
    'salope', 'salopes', 'salaud', 'salauds', 'encule', 'enculer', 'encules', 'ntm', 'nique', 'niquer',
    'nique ta mere', 'niquetamere', 'nique sa mere', 'fdp', 'fils de pute', 'ta gueule', 'ferme ta gueule',
    'pute', 'putes', 'petasse', 'petasses', 'trouduc', 'trou du cul', 'couille', 'couilles', 'branleur',
    'va te faire foutre', 'vas te faire enculer', 'va te faire enculer',
  ],
  hate: [
    'négro', 'négros', 'negre', 'negresse', 'bamboula', 'bougnoule', 'bougnoules', 'youpin', 'youpine',
    'sale arabe', 'sale noir', 'sale juif', 'sale race', 'pédé', 'pédés', 'tarlouze', 'tarlouzes', 'gouine',
    'gouines', 'travelo', 'travelos',
  ],
  sexual: [
    'envoie nudes', 'envoie des nudes', 'envoie ta photo nue', 'photos nues', 'viol', 'violer', 'violeur',
    'violeurs', 'suce ma bite', 'montre tes seins',
  ],
  harassment: [
    'suicide toi', 'tue toi', 'va te tuer', 'vas te tuer', 'espere que tu meurs', 'espere que tu creves',
  ],
  scam: [
    'vends compte', 'vend compte', 'vends mon compte', 'vends acc', 'compte a vendre', 'vente de compte',
    'vente compte', 'achete compte', 'boost de rang', 'boost rank',
  ],
});
