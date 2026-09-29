/**
 * Thai (th) word list. Thai is written without spaces, so entries are substrings (`*part*`).
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives (tone-mark / vowel spelling variants), and have a native speaker check every entry for
 * false positives before relying on it. Short or ambiguous strings are left out on purpose:
 * "หี" (also "หีบ" = chest), "สัส" (also "สัสดี"), "แม่ง" (also "แม่งาน"), "เชี่ย" (also "เชี่ยวชาญ"),
 * "ห่า" (also "ห่าง"), "ควาย" (water buffalo).
 * Tone marks and vowel signs are matched exactly as written. Entry syntax: see ../types.ts.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const TH_WORDLIST = defineWordlist('th', {
  reviewed: false,
  // "เหี้ยม" (cruel, as in "โหดเหี้ยม") contains "เหี้ย" but is an ordinary word.
  exceptions: ['*เหี้ยม*'],
  profanity: [
    '*ควย*', '*เหี้ย*', '*ไอ้สัส*', '*อีสัส*', '*สัดหมา*', '*เย็ด*', '*ชิบหาย*', '*ระยำ*', '*อีดอก*', '*ดอกทอง*',
    '*หน้าหี*', '*ไอ้สัตว์*', '*อีสัตว์*', '*ห่ากิน*', '*ไอ้ห่า*', '*อีห่า*', '*ไอ้เวร*', '*ตอแหล*',
  ],
  hate: ['*ไอ้ตุ๊ด*', '*อีตุ๊ด*', '*ไอ้ดำ*', '*ไอ้พิการ*', '*ไอ้ปัญญาอ่อน*'],
  sexual: ['*ขอนู้ด*', '*ส่งนู้ด*', '*ขอรูปโป๊*', '*รูปโป๊*', '*ขายตัว*', '*ข่มขืน*'],
  harassment: ['*ไปตายซะ*', '*ไปตายเถอะ*', '*ไปตายไป*', '*ไปฆ่าตัวตาย*', '*ฆ่าตัวตายไป*', '*ขอให้ตาย*', '*ตายไปเลย*'],
  scam: [
    '*ขายไอดี*', '*ขายแอค*', '*ขายบัญชี*', '*รับตีแรงค์*', '*รับดันแรงค์*', '*รับดันแรงก์*', '*บริการดันแรงค์*',
    '*รับปั๊มแรงค์*', '*ซื้อไอดี*', '*รับซื้อไอดี*', '*รับซื้อแอค*',
  ],
});
