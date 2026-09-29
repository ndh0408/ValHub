/**
 * Chinese (zh) word list, shared by zh-CN (Simplified) and zh-TW (Traditional): both scripts are listed.
 * Chinese is written without spaces, so entries are substrings (`*part*`).
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives (homophones, pinyin, emoji substitutions), and have native speakers (mainland China,
 * Taiwan, Hong Kong) check every entry for false positives before relying on it. Short or ambiguous
 * strings are left out on purpose: "我操" (also "我操心" = I worry), "逼", "幹", "傻" alone, "棒子",
 * "阿三", "收号", "上分", "代打", "妓女", "变态".
 * Entry syntax: see ../types.ts.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const ZH_WORDLIST = defineWordlist('zh', {
  reviewed: false,
  profanity: [
    '*他妈的*', '*他媽的*', '*妈的*', '*媽的*', '*操你妈*', '*操你媽*', '*草泥马*', '*草泥馬*', '*傻逼*', '*傻屄*',
    '*煞笔*', '*傻b*', '*婊子*', '*狗娘养*', '*狗娘養*', '*屌*', '*鸡巴*', '*雞巴*', '*鸡吧*', '*操你大爷*',
    '*干你娘*', '*幹你娘*', '*干你妈*', '*去你妈的*', '*去你媽的*', '*滚你妈*', '*滾你媽*', '*贱人*', '*賤人*',
    '*臭婊子*', '*骚货*', '*騷貨*', '*你妈逼*', '*你媽逼*', '*妈逼*', '*媽逼*', '*马勒戈壁*', '*肏*',
  ],
  hate: [
    '*智障*', '*脑残*', '*腦殘*', '*黑鬼*', '*日本鬼子*', '*小日本*', '*高丽棒子*', '*高麗棒子*', '*支那*',
    '*台巴子*', '*死基佬*', '*死同性恋*', '*死同性戀*', '*穆畜*', '*犹太猪*', '*猶太豬*',
  ],
  sexual: ['*约炮*', '*約炮*', '*裸聊*', '*求裸照*', '*发裸照*', '*發裸照*', '*强奸*', '*強姦*', '*轮奸*', '*輪姦*', '*援交*'],
  harassment: [
    '*去死吧*', '*你去死*', '*去死啦*', '*去死好了*', '*死全家*', '*杀你全家*', '*殺你全家*', '*自杀吧*', '*自殺吧*',
    '*不去死*', '*我杀了你*', '*我殺了你*', '*弄死你*', '*宰了你*', '*你妈死了*', '*你媽死了*', '*全家死光*',
  ],
  scam: [
    '*出售账号*', '*出售賬號*', '*出售帐号*', '*账号出售*', '*賬號出售*', '*帐号出售*', '*卖号*', '*賣號*', '*租号*',
    '*代练*', '*代練*', '*账号交易*', '*賬號交易*', '*代充*',
  ],
});
