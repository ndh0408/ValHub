/**
 * Curated Vietnamese word list for the community content filter (the original list of the
 * service; written for and used by Vietnamese players). English lives in en-wordlist.ts.
 *
 * How entries are matched (see filter.ts and types.ts):
 * - Matching is per whole word (token), never inside another word, so "dm" does not match "admin".
 * - A phrase is a space-separated sequence of words that must appear as consecutive words.
 * - A word written WITHOUT diacritics matches regardless of accents ("dm" matches "đm", "dm", "ĐM").
 * - A word written WITH diacritics (or đ) only matches that exact accented form. This is how
 *   ambiguous words stay safe: "đĩ" never matches "đi", "lồn" never matches "lon" (lon nước),
 *   "cặc" never matches "các", "buồi" never matches "buổi", "đéo" never matches "đeo".
 * - Input is normalised first: lower-case, leetspeak (0→o 1→i 3→e 4→a @→a $→s), separators
 *   (. _ - *) inside words removed, and elongated letters ("đmmmm", "fuuuck") collapsed.
 */
import { defineWordlist } from './types.js';

export type { WordCategory } from './types.js';

export const VI_WORDLIST = defineWordlist('vi', {
  reviewed: true,
  profanity: [
    // --- abbreviations (unambiguous without accents)
    'dm', 'dmm', 'dmmm', 'dcm', 'dcmm', 'dkm', 'dmcs', 'dmml', 'dmvl',
    'vcl', 'vkl', 'vl', 'vcc', 'vloz', 'vlz', 'vklm',
    'clgt', 'cmm', 'cmn', 'cmnr', 'clm', 'cc', 'loz', 'lozz',
    'djt', 'dit', 'dit me', 'dit me may', 'dit con me', 'dit cu', 'dit bo', 'du ma', 'du me', 'du mia',
    'ngu vl', 'ngu vcl', 'ngu vkl', 'ngu nhu cho', 'ngu nhu bo',
    // --- words that are only profane with their accents
    'địt', 'đjt', 'đệt', 'đụ', 'đụ má', 'đụ mẹ', 'đéo',
    'lồn', 'lìn', 'cái lồn', 'mặt lồn', 'vãi lồn', 'vãi cả lồn',
    'buồi', 'đầu buồi', 'cặc', 'cặk', 'kặc', 'cứt', 'đồ cứt',
    'đĩ', 'đỉ', 'con đĩ', 'đĩ điếm', 'điếm', 'phò', 'con phò',
    'súc vật', 'đồ súc vật', 'óc lợn', 'đồ chó đẻ', 'chó đẻ', 'mẹ kiếp', 'phắc',
  ],
  hate: [
    // regional / ethnic / LGBT slurs
    'bắc kỳ', 'bắc kì', 'bac ky cho', 'parky', 'namki', 'nam kỳ lúa', 'ba que xỏ lá',
    'khựa', 'tàu khựa', 'bọn khựa', 'bê đê', 'pê đê', 'bede', 'bóng lại cái',
  ],
  sexual: [
    'bú cu', 'bú lồn', 'bú cặc', 'bú buồi', 'liếm lồn', 'chịch', 'chịch nhau', 'chịch không',
    'địt nhau', 'đụ nhau', 'hiếp dâm', 'cưỡng hiếp', 'show hàng', 'cho xem hàng',
    'gửi ảnh nóng', 'xin ảnh nóng', 'gửi nude', 'xin nude', 'cho xin nude', 'clip sex',
    'phim sex', 'link sex',
  ],
  harassment: ['đi chết đi', 'chết mẹ mày đi', 'tự tử đi', 'giết cả nhà mày'],
  scam: [
    'bán acc', 'bán nick', 'bán tài khoản', 'bán account', 'bán acount', 'shop acc',
    'mua acc', 'thu mua acc', 'cày thuê', 'cay thue', 'nhận cày', 'nhận cày thuê', 'cày rank thuê',
    'cày hộ', 'cay ho rank', 'boost rank', 'nhận boost',
  ],
});

/** URL shorteners: links to these are always stripped (they hide phishing destinations). */
export const SHORTENER_DOMAINS: readonly string[] = [
  'bit.ly', 'bitly.com', 'tinyurl.com', 'goo.gl', 't.co', 'ow.ly', 'is.gd', 'v.gd', 'buff.ly', 'cutt.ly',
  'shorturl.at', 'rb.gy', 'tiny.cc', 's.id', 'rebrand.ly', 't.ly', 'shorte.st', 'adf.ly', 'bl.ink',
  'lnkd.in', 'short.io', 'tinyurl.vn', 'link1s.com', 'link4m.com', 'linkvertise.com', 'bom.so', 'bom.to',
  'urlz.fr', 'x.co', 'soo.gd', 'clck.ru', 'qr.ae', 'surl.li', 'u.to',
];
