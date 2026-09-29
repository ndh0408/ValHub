/**
 * Arabic (ar) word list (Modern Standard + common dialect insults; Arabizi transliterations included).
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives (dialects, clitics, spelling variants), and have native speakers check every entry for
 * false positives before relying on it. Ordinary words are left out on purpose: "كلب" (dog), "حمار",
 * "نيك" alone (also the name Nick), "شاذ" (irregular), "شواذ" (grammatical exceptions), "منغولي" (Mongolian).
 * Text and entries are folded first: tashkeel removed, أ إ آ → ا, ى → ي, ة → ه, tatweel removed.
 * Entries are therefore written in that folded spelling. Entry syntax: see ../types.ts.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const AR_WORDLIST = defineWordlist('ar', {
  reviewed: false,
  profanity: [
    'كس', 'كسمك', 'كس امك', 'كس امه', 'كسختك', 'كس اختك', 'كسك', 'زب', 'زبي', 'زبك', 'طيز', 'طيزك', 'ينيك',
    'نيكمك', 'انيك', 'انيكك', 'منيوك', 'منيك', 'شرموطه', 'شرموط', 'شراميط', 'قحبه', 'قحاب', 'عاهره',
    'ابن الكلب', 'ابن الحرام', 'ابن العاهره', 'ابن الشرموطه', 'ابن القحبه', 'ولد الحرام', 'خرا', 'خراء',
    'ايري', 'ايرك', 'يلعن ابوك', 'يلعن دينك', 'يلعن امك', 'عرص', 'متناك', 'متناكه', 'ديوث',
    // Arabizi
    'kosomak', 'kos omak', 'kos ummak', 'kos ukhtak', 'sharmouta', 'sharmoota', 'sharmuta', 'ibn el sharmouta',
    'ibn el kalb',
  ],
  hate: ['زنجي', 'زنوج', 'لوطي', 'لوطيين', 'خول', 'يهودي قذر', 'كلب يهودي', 'كلاب اليهود'],
  sexual: [
    'ارسل صور عاريه', 'ارسلي صورك عاريه', 'صور عاريه', 'نودز', 'ارسل نودز', 'اغتصاب', 'اغتصب*', 'سكس',
    'فيديو سكس',
  ],
  harassment: ['اقتل نفسك', 'اقتلي نفسك', 'روح انتحر', 'ساقتلك', 'اتمنى موتك', 'اتمنى ان تموت', 'روح موت'],
  scam: [
    'حساب للبيع', 'حسابات للبيع', 'اشتري حساب', 'شراء حسابات', 'بيع حساب', 'بيع حسابات', 'ابيع حسابي',
    'ابيع حساب', 'رفع رانك', 'رفع الرانك', 'خدمه بوست', 'بوست رانك', 'بوست الرانك',
  ],
});
