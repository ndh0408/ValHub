import { describe, expect, it } from 'vitest';
import { ApiError } from '../src/errors.js';
import { countryFromAlpha3, ISO_ALPHA2, ISO_ALPHA3_TO_ALPHA2, normalizeAlpha2 } from '../src/geo/countries.js';
import {
  canonicalLanguage,
  contentLanguage,
  LANGUAGES,
  parseLanguage,
  parseLanguageList,
  parseLfgLanguage,
} from '../src/geo/languages.js';
import { appliedScope, resolveScope } from '../src/geo/scope.js';
import { parseUserinfo } from '../src/riot.js';

/** The 249 officially assigned ISO 3166-1 alpha-2 codes. */
const ALPHA2 =
  'AD AE AF AG AI AL AM AO AQ AR AS AT AU AW AX AZ BA BB BD BE BF BG BH BI BJ BL BM BN BO BQ BR BS BT BV BW BY BZ CA CC CD CF CG CH CI CK CL CM CN CO CR CU CV CW CX CY CZ DE DJ DK DM DO DZ EC EE EG EH ER ES ET FI FJ FK FM FO FR GA GB GD GE GF GG GH GI GL GM GN GP GQ GR GS GT GU GW GY HK HM HN HR HT HU ID IE IL IM IN IO IQ IR IS IT JE JM JO JP KE KG KH KI KM KN KP KR KW KY KZ LA LB LC LI LK LR LS LT LU LV LY MA MC MD ME MF MG MH MK ML MM MN MO MP MQ MR MS MT MU MV MW MX MY MZ NA NC NE NF NG NI NL NO NP NR NU NZ OM PA PE PF PG PH PK PL PM PN PR PS PT PW PY QA RE RO RS RU RW SA SB SC SD SE SG SH SI SJ SK SL SM SN SO SR SS ST SV SX SY SZ TC TD TF TG TH TJ TK TL TM TN TO TR TT TV TW TZ UA UG UM US UY UZ VA VC VE VG VI VN VU WF WS YE YT ZA ZM ZW'.split(
    ' ',
  );

describe('ISO 3166-1 alpha-3 → alpha-2 table', () => {
  it('has all 249 entries, well formed', () => {
    expect(ALPHA2).toHaveLength(249);
    const entries = Object.entries(ISO_ALPHA3_TO_ALPHA2);
    expect(entries).toHaveLength(249);
    for (const [a3, a2] of entries) {
      expect(a3, a3).toMatch(/^[a-z]{3}$/);
      expect(a2, a3).toMatch(/^[A-Z]{2}$/);
    }
    // Every alpha-2 code once, and exactly the official list.
    expect([...ISO_ALPHA2].sort()).toEqual([...ALPHA2].sort());
    expect(new Set(Object.values(ISO_ALPHA3_TO_ALPHA2)).size).toBe(249);
  });

  it.each([
    ['vnm', 'VN'],
    ['usa', 'US'],
    ['gbr', 'GB'],
    ['kor', 'KR'],
    ['bra', 'BR'],
    ['jpn', 'JP'],
    ['deu', 'DE'],
    ['fra', 'FR'],
    ['chn', 'CN'],
    ['ind', 'IN'],
    ['idn', 'ID'],
    ['tha', 'TH'],
    ['rus', 'RU'],
    ['tur', 'TR'],
    ['sau', 'SA'],
    ['mex', 'MX'],
    ['arg', 'AR'],
    ['esp', 'ES'],
    ['ita', 'IT'],
    ['pol', 'PL'],
    ['zaf', 'ZA'],
    ['aus', 'AU'],
    ['can', 'CA'],
    ['phl', 'PH'],
    ['sgp', 'SG'],
    ['twn', 'TW'],
    ['hkg', 'HK'],
    ['are', 'AE'],
    ['che', 'CH'],
    ['nld', 'NL'],
    ['swe', 'SE'],
    ['ukr', 'UA'],
    ['egy', 'EG'],
    ['mys', 'MY'],
    ['prk', 'KP'],
    ['cod', 'CD'],
    ['cog', 'CG'],
    ['ssd', 'SS'],
    ['mne', 'ME'],
    ['srb', 'RS'],
  ])('%s → %s', (a3, a2) => {
    expect(countryFromAlpha3(a3)).toBe(a2);
  });

  it('is tolerant of case and whitespace, and returns null for anything unknown', () => {
    expect(countryFromAlpha3('VNM')).toBe('VN');
    expect(countryFromAlpha3(' Vnm ')).toBe('VN');
    for (const bad of ['xxx', 'xkx', 'kos', 'vn', 'vnmx', '', '   ', 'v1m', null, undefined, 84, {}, [], true, 'constructor', 'toString']) {
      expect(countryFromAlpha3(bad), String(bad)).toBeNull();
    }
  });

  it('normalises client alpha-2 codes', () => {
    expect(normalizeAlpha2('vn')).toBe('VN');
    expect(normalizeAlpha2(' us ')).toBe('US');
    for (const bad of ['zz', 'xx', 'usa', 'v', '', null, 1, undefined]) expect(normalizeAlpha2(bad), String(bad)).toBeNull();
  });
});

describe('Riot /userinfo country', () => {
  it('maps the alpha-3 country to alpha-2', () => {
    expect(parseUserinfo('{"sub":"a","country":"vnm","acct":{"game_name":"K","tag_line":"1"}}')).toEqual({
      ok: true,
      puuid: 'a',
      gameName: 'K',
      tagLine: '1',
      country: 'VN',
    });
    expect(parseUserinfo('{"sub":"a","acct":{"game_name":"A","tag_line":"X"},"country":"USA"}')).toMatchObject({ country: 'US' });
  });

  it('is null when missing, unknown or malformed', () => {
    for (const c of ['', ',"country":"xyz"', ',"country":12', ',"country":null', ',"country":["vnm"]', ',"country":{"a":1}']) {
      expect(parseUserinfo(`{"sub":"a","acct":{"game_name":"A","tag_line":"X"}${c}}`), c).toMatchObject({ ok: true, country: null });
    }
  });
});

describe('languages', () => {
  it('has the 17 app languages', () => {
    expect([...LANGUAGES]).toEqual([
      'ar', 'de', 'en', 'es', 'fr', 'id', 'it', 'ja', 'ko', 'pl', 'pt', 'ru', 'th', 'tr', 'vi', 'zh-CN', 'zh-TW',
    ]);
  });

  it.each([
    ['vi', 'vi'],
    ['VI', 'vi'],
    [' vi ', 'vi'],
    ['vi-VN', 'vi'],
    ['pt-BR', 'pt'],
    ['pt_PT', 'pt'],
    ['es-MX', 'es'],
    ['en-US', 'en'],
    ['zh-CN', 'zh-CN'],
    ['zh_CN', 'zh-CN'],
    ['zh-Hans', 'zh-CN'],
    ['zh-Hans-CN', 'zh-CN'],
    ['zh-SG', 'zh-CN'],
    ['zh-TW', 'zh-TW'],
    ['zh-HK', 'zh-TW'],
    ['zh-Hant', 'zh-TW'],
    ['ZH-tw', 'zh-TW'],
  ])('canonicalises %s → %s', (input, out) => {
    expect(canonicalLanguage(input)).toBe(out);
  });

  it.each(['zh', 'zh-XX', 'xx', 'english', 'a', '', '   ', 'vi-', '-vi', 'vi--VN', 'vi-x', 5, null, undefined, {}, 'any'])(
    'rejects %j',
    (input) => {
      expect(canonicalLanguage(input)).toBeNull();
    },
  );

  it('parseLanguage / parseLfgLanguage throw invalid_input', () => {
    expect(parseLanguage('pt-BR', 'language')).toBe('pt');
    expect(() => parseLanguage('xx', 'language')).toThrowError(ApiError);
    expect(parseLfgLanguage('ANY', 'language')).toBe('any');
    expect(parseLfgLanguage('vi', 'language')).toBe('vi');
    expect(parseLfgLanguage('zh_TW', 'language')).toBe('zh-TW');
    expect(() => parseLfgLanguage('xx', 'language')).toThrowError(ApiError);
  });

  it('contentLanguage: item override, else the author language', () => {
    expect(contentLanguage({}, 'vi')).toBe('vi');
    expect(contentLanguage({ language: null }, 'vi')).toBe('vi');
    expect(contentLanguage({ language: 'en' }, 'vi')).toBe('en');
    expect(contentLanguage({}, null)).toBeNull();
    expect(() => contentLanguage({ language: 'zh' }, 'vi')).toThrowError(ApiError);
  });

  it('parses ?language= lists', () => {
    expect(parseLanguageList(undefined)).toBeUndefined();
    expect(parseLanguageList('')).toBeUndefined();
    expect(parseLanguageList(' , ')).toBeUndefined();
    expect(parseLanguageList('vi')).toEqual(['vi']);
    expect(parseLanguageList('vi, EN ,vi')).toEqual(['vi', 'en']);
    expect(parseLanguageList('zh-CN,zh_TW')).toEqual(['zh-CN', 'zh-TW']);
    expect(() => parseLanguageList('vi,xx')).toThrowError(ApiError);
    expect(() => parseLanguageList('any')).toThrowError(ApiError);
    expect(parseLanguageList('vi,any', true)).toEqual(['vi', 'any']);
  });
});

describe('resolveScope', () => {
  const vn = { country: 'VN', region: 'ap' };
  const noCountry = { country: null, region: 'na' };

  it('applies the endpoint default with the viewer, falling back country → region → global', () => {
    expect(resolveScope({}, vn, 'country')).toEqual({ scope: 'country', country: 'VN' });
    expect(resolveScope({}, noCountry, 'country')).toEqual({ scope: 'region', region: 'na' });
    expect(resolveScope({}, null, 'country')).toEqual({ scope: 'global' });
    expect(resolveScope({}, vn, 'region')).toEqual({ scope: 'region', region: 'ap' });
    expect(resolveScope({}, null, 'region')).toEqual({ scope: 'global' });
    expect(resolveScope({}, vn, 'global')).toEqual({ scope: 'global' });
  });

  it('honours explicit scope and params', () => {
    expect(resolveScope({ scope: 'global' }, vn, 'country')).toEqual({ scope: 'global' });
    expect(resolveScope({ scope: 'country', country: 'us' }, vn, 'global')).toEqual({ scope: 'country', country: 'US' });
    expect(resolveScope({ scope: 'country' }, vn, 'global')).toEqual({ scope: 'country', country: 'VN' });
    expect(resolveScope({ scope: 'region', region: 'eu' }, vn, 'global')).toEqual({ scope: 'region', region: 'eu' });
    expect(resolveScope({ scope: 'region' }, vn, 'global')).toEqual({ scope: 'region', region: 'ap' });
    // A country / region param alone implies its scope; the region param keeps working for LFG.
    expect(resolveScope({ country: 'KR' }, vn, 'global')).toEqual({ scope: 'country', country: 'KR' });
    expect(resolveScope({ region: 'kr' }, vn, 'country')).toEqual({ scope: 'region', region: 'kr' });
    // Params of another scope are ignored.
    expect(resolveScope({ scope: 'global', country: 'VN', region: 'ap' }, vn, 'country')).toEqual({ scope: 'global' });
    expect(resolveScope({ scope: 'region', country: 'VN', region: 'eu' }, vn, 'country')).toEqual({
      scope: 'region',
      region: 'eu',
    });
    // A country scope without any country falls back to the region, then to global.
    expect(resolveScope({ scope: 'country' }, noCountry, 'global')).toEqual({ scope: 'region', region: 'na' });
    expect(resolveScope({ scope: 'country' }, null, 'global')).toEqual({ scope: 'global' });
    expect(resolveScope({ scope: 'region' }, null, 'global')).toEqual({ scope: 'global' });
  });

  it('validates', () => {
    for (const q of [{ scope: 'planet' }, { country: 'usa' }, { country: 'ZZ' }, { region: 'mars' }, { scope: 'country', country: '1' }]) {
      expect(() => resolveScope(q, vn, 'global'), JSON.stringify(q)).toThrowError(ApiError);
    }
  });

  it('describes the applied scope', () => {
    expect(appliedScope({ scope: 'global' })).toEqual({ scope: 'global', country: null, region: null });
    expect(appliedScope({ scope: 'country', country: 'VN' })).toEqual({ scope: 'country', country: 'VN', region: null });
    expect(appliedScope({ scope: 'region', region: 'ap' })).toEqual({ scope: 'region', country: null, region: 'ap' });
  });
});
