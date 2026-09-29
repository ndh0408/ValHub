/**
 * Spanish (es) word list (Spain + Latin America).
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives, and have native speakers (Spain, Mexico, Argentina, Colombia, Chile...) check every
 * entry for false positives. Words that are also ordinary words are left out on purpose
 * ("negro", "zorra", "polla", "hostia", "concha", "moro", "bollera", "retrasado").
 * Entries with an ñ ("coño") only match with the ñ (without it, "cono" = cone).
 * Entry syntax: see ../types.ts.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const ES_WORDLIST = defineWordlist('es', {
  reviewed: false,
  profanity: [
    'puta', 'putas', 'puto', 'putos', 'mierda', 'mierdas', 'cabron', 'cabrona', 'cabrones', 'coño', 'joder',
    'jodete', 'gilipollas', 'hijo de puta', 'hijoputa', 'hijueputa', 'hdp', 'pendejo', 'pendeja', 'pendejos',
    'verga', 'vergas', 'chinga', 'chingada', 'chingado', 'chingar', 'chinga tu madre', 'chingatumadre',
    'culero', 'culera', 'malparido', 'malparida', 'concha de tu madre', 'conchatumadre', 'conchatumare',
    'conchesumadre', 'ctm', 'ptm', 'pelotudo', 'pelotuda', 'mamaguevo', 'mamahuevo', 'huevon', 'weon', 'aweonao',
    'culiao', 'follar',
  ],
  hate: [
    'maricon', 'maricones', 'joto', 'jotos', 'sudaca', 'sudacas', 'mongolo', 'mongola', 'mongolos', 'mongolico',
    'travelo', 'travelos', 'tortillera', 'tortilleras', 'sidoso', 'negro de mierda', 'moro de mierda',
    'gitano de mierda', 'retrasado mental',
  ],
  sexual: [
    'manda nudes', 'mandame nudes', 'pasa nudes', 'pasame nudes', 'enviame nudes', 'envia nudes',
    'fotos desnuda', 'fotos desnudo', 'chupamela', 'chupame la', 'mamamela', 'te voy a violar',
  ],
  harassment: [
    'suicidate', 'matate', 'muerete', 'vete a morir', 'que te mueras', 'ojala te mueras', 'ojala mueras',
    'te voy a matar',
  ],
  scam: [
    'vendo cuenta', 'vendo cuentas', 'vendo acc', 'vendo account', 'cuenta en venta', 'cuentas en venta',
    'compro cuenta', 'compro cuentas', 'compro acc', 'boost de rango', 'subo rango', 'subo tu rango',
    'subida de rango', 'servicio de boost',
  ],
});
