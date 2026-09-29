/**
 * Korean (ko) word list. Korean attaches particles to words ("병신이", "시발놈"), so entries are
 * word prefixes (`stem*`); look-alike ordinary words are handled through `exceptions`.
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives, and have a native speaker check every entry for false positives before relying on it.
 * Ordinary words are left out on purpose: "보지" (also "don't look": 보지 마세요), "자지" (also "don't
 * sleep"), "씹" (to chew), "새끼" (offspring), "죽어라" (do something desperately), "뒤져" (rummage),
 * "니미" (also Nimitz), "홍어" (skate fish).
 * Entry syntax: see ../types.ts.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const KO_WORDLIST = defineWordlist('ko', {
  reviewed: false,
  // 병신년 = the year "byeongsin" of the sexagenary cycle; 시발점 / 시발역 = starting point / station.
  exceptions: ['병신년*', '시발점*', '시발역*', '시발지*'],
  profanity: [
    '시발*', '씨발*', '씨팔*', '시팔*', 'ㅅㅂ*', 'ㅆㅂ*', '병신*', 'ㅂㅅ*', 'ㅄ*', '지랄*', 'ㅈㄹ*', '좆*', '존나*', 'ㅈㄴ*',
    '개새끼*', '개새기*', '씹새끼*', '씹년*', '썅*', '엠창*', '느금마*', '니미럴*', '니미랄*', '미친놈*', '미친년*',
    '쌍놈*', '쌍년*', '창녀*',
  ],
  hate: [
    '짱깨*', '쪽바리*', '쪽발이*', '똥남아*', '김치녀*', '된장녀*', '한남충*', '맘충*', '틀딱*', '조센징*', '깜둥이*',
    '검둥이*', '전라디언*',
  ],
  sexual: [
    '몸캠*', '조건만남*', '누드사진*', '노출사진*', '벗은 사진*', '가슴 사진*', '누드 보내*', '강간*', '성폭행*',
  ],
  harassment: [
    '자살해*', '자살하세요*', '자살하라*', '뒈져*', '뒤져라*', '디져라*', '죽어버려*', '죽여버*', '뒤질래*',
  ],
  scam: [
    '계정 판매*', '계정판매*', '계정 팔*', '계정팔*', '아이디 판매*', '아이디판매*', '계정 삽니다*', '계정 매입*',
    '대리 랭크*', '랭크 대리*', '대리랭크*', '랭크대리*', '대리 티어*', '티어 대리*', '부스팅*', '배치 대리*',
  ],
});
