/**
 * German (de) word list.
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives, and have a native speaker check every entry for false positives before relying on it.
 * Ambiguous everyday words (e.g. "Schwanz" = tail, "behindert", "Stirb langsam") are left out on purpose.
 * Entry syntax: see ../types.ts. Text is folded first: lower case, ß → ss, diacritics ignored.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const DE_WORDLIST = defineWordlist('de', {
  reviewed: false,
  profanity: [
    'scheiss*', 'arsch*', 'arschloch', 'arschlocher', 'wichser', 'wichsen', 'hurensohn', 'hurensohne',
    'hure', 'huren', 'fotze', 'fotzen', 'votze', 'schlampe', 'schlampen', 'miststuck', 'fick', 'ficken',
    'ficker', 'fickt', 'fick dich', 'verfickt', 'verfickte', 'verfickter', 'gefickt', 'kackbratze',
    'drecksau', 'dreckssack', 'pisser', 'wixer', 'wixxer',
  ],
  hate: [
    'neger', 'kanake', 'kanaken', 'schwuchtel', 'schwuchteln', 'spast', 'spasti', 'spasten', 'mongo',
    'mongos', 'untermensch', 'untermenschen', 'judensau',
  ],
  sexual: [
    'schick nudes', 'schick mir nudes', 'nacktbilder', 'nacktfotos', 'schick nacktbilder', 'vergewaltig*',
    'zeig titten',
  ],
  harassment: [
    'geh sterben', 'bring dich um', 'bring dich selbst um', 'tote dich', 'verrecke', 'verrecken', 'krepier',
    'krepiere', 'hoffe du stirbst', 'hoffe du verreckst',
  ],
  scam: [
    'account verkaufen', 'acc verkaufen', 'konto verkaufen', 'accounts verkaufen', 'verkaufe account',
    'verkaufe acc', 'verkaufe konto', 'verkaufe accounts', 'kaufe account', 'kaufe acc', 'kaufe accounts',
    'account zu verkaufen', 'rang boost', 'rangboost', 'boosting service', 'boost service',
  ],
});
