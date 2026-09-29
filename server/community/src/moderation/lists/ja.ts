/**
 * Japanese (ja) word list. Japanese is written without spaces, so entries are substrings (`*part*`).
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives, and have a native speaker check every entry for false positives before relying on it.
 * Short or ambiguous strings are left out on purpose: bare "クソ" (also "ニクソン" = Nixon), "カス"
 * ("カスタム" = custom), "ブス" ("アブストラクト"), "ガイジ" ("ガイジン"), "チョン" ("チョンマゲ"),
 * "ホモ" ("ホモサピエンス"), "シコ", "馬鹿", "ゴミ", "しね" (hiragana matches inside ordinary words).
 * Entry syntax: see ../types.ts.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const JA_WORDLIST = defineWordlist('ja', {
  reviewed: false,
  // "おかまいなく" (please don't trouble yourself) contains "おかま"; "死ねない" etc. are ordinary phrases.
  exceptions: ['*おかまい*', '*死ねない*', '*死ねば*', '*死ねる*', '*死ねなか*'],
  profanity: [
    '*クソ野郎*', '*くそ野郎*', '*糞野郎*', '*クソゲー*', '*クソ雑魚*', '*クソが*', '*くそが*', '*ファック*',
    '*ファッキン*', '*ちんこ*', '*チンコ*', '*まんこ*', '*マンコ*', '*チンポ*', '*ちんぽ*', '*ビッチ*',
    '*くそったれ*', '*クソったれ*', '*売女*', '*やりまん*', '*ヤリマン*', '*ヤリチン*', '*クソアマ*',
  ],
  hate: ['*キチガイ*', '*きちがい*', '*気違い*', '*ジャップ*', '*ニガー*', '*オカマ*', '*おかま*', '*池沼*'],
  sexual: ['*ヌード送*', '*エロ画像送*', '*裸の写真*', '*裸の画像*', '*レイプ*', '*強姦*', '*輪姦*', '*援交*', '*援助交際*', '*裸チャット*'],
  harassment: [
    '*死ね*', '*死んでしまえ*', '*自殺しろ*', '*自殺しなよ*', '*首吊れ*', '*くたばれ*', '*ぶっ殺*', '*殺すぞ*',
    '*ころすぞ*', '*殺してやる*',
  ],
  scam: [
    '*アカウント売*', '*アカ売*', '*アカウント販売*', '*アカウント買取*', '*アカ買取*', '*ランク代行*',
    '*ブースト代行*', '*アカウント譲渡*', 'rmt',
  ],
});
