/**
 * ISO 3166-1: every officially assigned alpha-3 code (lower case, as Riot's /userinfo returns
 * it in `country`) mapped to its alpha-2 code (upper case, what the API stores and returns).
 * 249 entries. User-assigned codes (e.g. Kosovo "XK"/"XKX") are not part of the standard and
 * map to null like any other unknown value.
 */
export const ISO_ALPHA3_TO_ALPHA2: Readonly<Record<string, string>> = Object.freeze({
  abw: 'AW', // Aruba
  afg: 'AF', // Afghanistan
  ago: 'AO', // Angola
  aia: 'AI', // Anguilla
  ala: 'AX', // Åland Islands
  alb: 'AL', // Albania
  and: 'AD', // Andorra
  are: 'AE', // United Arab Emirates
  arg: 'AR', // Argentina
  arm: 'AM', // Armenia
  asm: 'AS', // American Samoa
  ata: 'AQ', // Antarctica
  atf: 'TF', // French Southern Territories
  atg: 'AG', // Antigua and Barbuda
  aus: 'AU', // Australia
  aut: 'AT', // Austria
  aze: 'AZ', // Azerbaijan
  bdi: 'BI', // Burundi
  bel: 'BE', // Belgium
  ben: 'BJ', // Benin
  bes: 'BQ', // Bonaire, Sint Eustatius and Saba
  bfa: 'BF', // Burkina Faso
  bgd: 'BD', // Bangladesh
  bgr: 'BG', // Bulgaria
  bhr: 'BH', // Bahrain
  bhs: 'BS', // Bahamas
  bih: 'BA', // Bosnia and Herzegovina
  blm: 'BL', // Saint Barthélemy
  blr: 'BY', // Belarus
  blz: 'BZ', // Belize
  bmu: 'BM', // Bermuda
  bol: 'BO', // Bolivia
  bra: 'BR', // Brazil
  brb: 'BB', // Barbados
  brn: 'BN', // Brunei Darussalam
  btn: 'BT', // Bhutan
  bvt: 'BV', // Bouvet Island
  bwa: 'BW', // Botswana
  caf: 'CF', // Central African Republic
  can: 'CA', // Canada
  cck: 'CC', // Cocos (Keeling) Islands
  che: 'CH', // Switzerland
  chl: 'CL', // Chile
  chn: 'CN', // China
  civ: 'CI', // Côte d'Ivoire
  cmr: 'CM', // Cameroon
  cod: 'CD', // Congo, Democratic Republic of the
  cog: 'CG', // Congo
  cok: 'CK', // Cook Islands
  col: 'CO', // Colombia
  com: 'KM', // Comoros
  cpv: 'CV', // Cabo Verde
  cri: 'CR', // Costa Rica
  cub: 'CU', // Cuba
  cuw: 'CW', // Curaçao
  cxr: 'CX', // Christmas Island
  cym: 'KY', // Cayman Islands
  cyp: 'CY', // Cyprus
  cze: 'CZ', // Czechia
  deu: 'DE', // Germany
  dji: 'DJ', // Djibouti
  dma: 'DM', // Dominica
  dnk: 'DK', // Denmark
  dom: 'DO', // Dominican Republic
  dza: 'DZ', // Algeria
  ecu: 'EC', // Ecuador
  egy: 'EG', // Egypt
  eri: 'ER', // Eritrea
  esh: 'EH', // Western Sahara
  esp: 'ES', // Spain
  est: 'EE', // Estonia
  eth: 'ET', // Ethiopia
  fin: 'FI', // Finland
  fji: 'FJ', // Fiji
  flk: 'FK', // Falkland Islands (Malvinas)
  fra: 'FR', // France
  fro: 'FO', // Faroe Islands
  fsm: 'FM', // Micronesia
  gab: 'GA', // Gabon
  gbr: 'GB', // United Kingdom
  geo: 'GE', // Georgia
  ggy: 'GG', // Guernsey
  gha: 'GH', // Ghana
  gib: 'GI', // Gibraltar
  gin: 'GN', // Guinea
  glp: 'GP', // Guadeloupe
  gmb: 'GM', // Gambia
  gnb: 'GW', // Guinea-Bissau
  gnq: 'GQ', // Equatorial Guinea
  grc: 'GR', // Greece
  grd: 'GD', // Grenada
  grl: 'GL', // Greenland
  gtm: 'GT', // Guatemala
  guf: 'GF', // French Guiana
  gum: 'GU', // Guam
  guy: 'GY', // Guyana
  hkg: 'HK', // Hong Kong
  hmd: 'HM', // Heard Island and McDonald Islands
  hnd: 'HN', // Honduras
  hrv: 'HR', // Croatia
  hti: 'HT', // Haiti
  hun: 'HU', // Hungary
  idn: 'ID', // Indonesia
  imn: 'IM', // Isle of Man
  ind: 'IN', // India
  iot: 'IO', // British Indian Ocean Territory
  irl: 'IE', // Ireland
  irn: 'IR', // Iran
  irq: 'IQ', // Iraq
  isl: 'IS', // Iceland
  isr: 'IL', // Israel
  ita: 'IT', // Italy
  jam: 'JM', // Jamaica
  jey: 'JE', // Jersey
  jor: 'JO', // Jordan
  jpn: 'JP', // Japan
  kaz: 'KZ', // Kazakhstan
  ken: 'KE', // Kenya
  kgz: 'KG', // Kyrgyzstan
  khm: 'KH', // Cambodia
  kir: 'KI', // Kiribati
  kna: 'KN', // Saint Kitts and Nevis
  kor: 'KR', // Korea, Republic of
  kwt: 'KW', // Kuwait
  lao: 'LA', // Lao People's Democratic Republic
  lbn: 'LB', // Lebanon
  lbr: 'LR', // Liberia
  lby: 'LY', // Libya
  lca: 'LC', // Saint Lucia
  lie: 'LI', // Liechtenstein
  lka: 'LK', // Sri Lanka
  lso: 'LS', // Lesotho
  ltu: 'LT', // Lithuania
  lux: 'LU', // Luxembourg
  lva: 'LV', // Latvia
  mac: 'MO', // Macao
  maf: 'MF', // Saint Martin (French part)
  mar: 'MA', // Morocco
  mco: 'MC', // Monaco
  mda: 'MD', // Moldova
  mdg: 'MG', // Madagascar
  mdv: 'MV', // Maldives
  mex: 'MX', // Mexico
  mhl: 'MH', // Marshall Islands
  mkd: 'MK', // North Macedonia
  mli: 'ML', // Mali
  mlt: 'MT', // Malta
  mmr: 'MM', // Myanmar
  mne: 'ME', // Montenegro
  mng: 'MN', // Mongolia
  mnp: 'MP', // Northern Mariana Islands
  moz: 'MZ', // Mozambique
  mrt: 'MR', // Mauritania
  msr: 'MS', // Montserrat
  mtq: 'MQ', // Martinique
  mus: 'MU', // Mauritius
  mwi: 'MW', // Malawi
  mys: 'MY', // Malaysia
  myt: 'YT', // Mayotte
  nam: 'NA', // Namibia
  ncl: 'NC', // New Caledonia
  ner: 'NE', // Niger
  nfk: 'NF', // Norfolk Island
  nga: 'NG', // Nigeria
  nic: 'NI', // Nicaragua
  niu: 'NU', // Niue
  nld: 'NL', // Netherlands
  nor: 'NO', // Norway
  npl: 'NP', // Nepal
  nru: 'NR', // Nauru
  nzl: 'NZ', // New Zealand
  omn: 'OM', // Oman
  pak: 'PK', // Pakistan
  pan: 'PA', // Panama
  pcn: 'PN', // Pitcairn
  per: 'PE', // Peru
  phl: 'PH', // Philippines
  plw: 'PW', // Palau
  png: 'PG', // Papua New Guinea
  pol: 'PL', // Poland
  pri: 'PR', // Puerto Rico
  prk: 'KP', // Korea, Democratic People's Republic of
  prt: 'PT', // Portugal
  pry: 'PY', // Paraguay
  pse: 'PS', // Palestine, State of
  pyf: 'PF', // French Polynesia
  qat: 'QA', // Qatar
  reu: 'RE', // Réunion
  rou: 'RO', // Romania
  rus: 'RU', // Russian Federation
  rwa: 'RW', // Rwanda
  sau: 'SA', // Saudi Arabia
  sdn: 'SD', // Sudan
  sen: 'SN', // Senegal
  sgp: 'SG', // Singapore
  sgs: 'GS', // South Georgia and the South Sandwich Islands
  shn: 'SH', // Saint Helena, Ascension and Tristan da Cunha
  sjm: 'SJ', // Svalbard and Jan Mayen
  slb: 'SB', // Solomon Islands
  sle: 'SL', // Sierra Leone
  slv: 'SV', // El Salvador
  smr: 'SM', // San Marino
  som: 'SO', // Somalia
  spm: 'PM', // Saint Pierre and Miquelon
  srb: 'RS', // Serbia
  ssd: 'SS', // South Sudan
  stp: 'ST', // Sao Tome and Principe
  sur: 'SR', // Suriname
  svk: 'SK', // Slovakia
  svn: 'SI', // Slovenia
  swe: 'SE', // Sweden
  swz: 'SZ', // Eswatini
  sxm: 'SX', // Sint Maarten (Dutch part)
  syc: 'SC', // Seychelles
  syr: 'SY', // Syrian Arab Republic
  tca: 'TC', // Turks and Caicos Islands
  tcd: 'TD', // Chad
  tgo: 'TG', // Togo
  tha: 'TH', // Thailand
  tjk: 'TJ', // Tajikistan
  tkl: 'TK', // Tokelau
  tkm: 'TM', // Turkmenistan
  tls: 'TL', // Timor-Leste
  ton: 'TO', // Tonga
  tto: 'TT', // Trinidad and Tobago
  tun: 'TN', // Tunisia
  tur: 'TR', // Türkiye
  tuv: 'TV', // Tuvalu
  twn: 'TW', // Taiwan
  tza: 'TZ', // Tanzania
  uga: 'UG', // Uganda
  ukr: 'UA', // Ukraine
  umi: 'UM', // United States Minor Outlying Islands
  ury: 'UY', // Uruguay
  usa: 'US', // United States of America
  uzb: 'UZ', // Uzbekistan
  vat: 'VA', // Holy See
  vct: 'VC', // Saint Vincent and the Grenadines
  ven: 'VE', // Venezuela
  vgb: 'VG', // Virgin Islands (British)
  vir: 'VI', // Virgin Islands (U.S.)
  vnm: 'VN', // Viet Nam
  vut: 'VU', // Vanuatu
  wlf: 'WF', // Wallis and Futuna
  wsm: 'WS', // Samoa
  yem: 'YE', // Yemen
  zaf: 'ZA', // South Africa
  zmb: 'ZM', // Zambia
  zwe: 'ZW', // Zimbabwe
});

/** Every valid alpha-2 code (upper case). */
export const ISO_ALPHA2: ReadonlySet<string> = new Set(Object.values(ISO_ALPHA3_TO_ALPHA2));

/** Riot `country` (alpha-3, any case) → alpha-2 upper case, or null when missing / unknown. */
export function countryFromAlpha3(v: unknown): string | null {
  if (typeof v !== 'string') return null;
  const key = v.trim().toLowerCase();
  if (!/^[a-z]{3}$/.test(key)) return null;
  return Object.prototype.hasOwnProperty.call(ISO_ALPHA3_TO_ALPHA2, key) ? ISO_ALPHA3_TO_ALPHA2[key]! : null;
}

/** A client-supplied alpha-2 code (any case) → upper case if it is a real ISO code, else null. */
export function normalizeAlpha2(v: unknown): string | null {
  if (typeof v !== 'string') return null;
  const code = v.trim().toUpperCase();
  return /^[A-Z]{2}$/.test(code) && ISO_ALPHA2.has(code) ? code : null;
}
