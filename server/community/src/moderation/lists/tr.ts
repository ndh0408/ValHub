/**
 * Turkish (tr) word list.
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives, and have a native speaker check every entry for false positives before relying on it.
 * Dotted / dotless i matters: "sik" (vulgar) must not match "şık" (chic) or "sık sık" (often), and
 * "şikayet" (complaint) must not match; so only whole words are listed, never a "sik*" stem.
 * "mal", "salak", "aptal", "zenci", "top", "bok" are ordinary/mild words and are left out.
 * Entry syntax: see ../types.ts. Diacritics are ignored unless the entry itself carries them
 * (entries with ç / ö / ş / ğ are listed in both spellings where the plain spelling is safe).
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const TR_WORDLIST = defineWordlist('tr', {
  reviewed: false,
  profanity: [
    'amk', 'aq', 'sik', 'siktir', 'siktirgit', 'siktir git', 'sikerim', 'sikeyim', 'sikik', 'sikim', 'sikmek',
    'sikiyim', 'siktim', 'siktigimin', 'sikerler', 'orospu', 'orospular', 'piç', 'yarrak', 'yarak', 'dalyarak',
    'dalyarrak', 'amina', 'aminakoyim', 'aminakoyayim', 'amina koyayim', 'amina koyim', 'amcik', 'amcık', 'anani',
    'ananı', 'gotveren', 'göt', 'götü', 'gavat', 'pezevenk', 'kahpe', 'yavsak', 'serefsiz', 'şerefsiz',
    'ananisikeyim', 'sicmak', 'sıçmak', 'sıçtım',
  ],
  hate: ['ibne', 'ibneler', 'pust', 'pustlar', 'ermeni tohumu'],
  sexual: [
    'nude at', 'nude gonder', 'nudes gonder', 'goguslerini goster', 'tecavuz', 'tecavuzcu',
  ],
  harassment: ['geber', 'gebersin', 'intihar et', 'kendini oldur', 'oldurecegim'],
  scam: [
    'hesap satilik', 'hesap satılık', 'hesap satarim', 'hesap satarım', 'hesap satiyorum', 'hesap satıyorum',
    'hesap alinir', 'hesap alınır', 'hesap alirim', 'hesap alırım', 'boost hizmeti',
  ],
});
