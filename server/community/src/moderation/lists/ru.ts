/**
 * Russian (ru) word list. Russian is heavily inflected, so many entries are word stems (`stem*`).
 * Cyrillic text is also covered for Ukrainian / Bulgarian / Serbian speakers where the words are shared;
 * common Latin transliterations ("blyat", "cyka", "nahuy") are included.
 *
 * !!! NEEDS NATIVE REVIEW !!! Best-effort list written without a native speaker: expect false
 * negatives, and have native speakers check every entry for false positives before relying on it.
 * Ordinary words are left out on purpose ("сукно" = cloth, "хачапури", "трахея", "шлюз", "мандарин",
 * "бляшка", "жидкость", "петух", "хохол", "косоглазие", "отсос", "тварь", "жопа").
 * Text is folded first: ё → е. Entry syntax: see ../types.ts.
 */
import { defineWordlist } from '../types.js';

export const NEEDS_NATIVE_REVIEW = true;

export const RU_WORDLIST = defineWordlist('ru', {
  reviewed: false,
  profanity: [
    'бля', 'бляд*', 'блят*', 'сука', 'суки', 'суку', 'сукой', 'сучка', 'сучки', 'сучку', 'сучара', 'сучье',
    'пизд*', 'пздц', 'хуй*', 'хуя*', 'хуе*', 'хую*', 'нахуй', 'нахуя', 'похуй*', 'охуе*', 'ахуе*', 'нихуя',
    'ебан*', 'ебат*', 'ебал*', 'ебл*', 'ебну*', 'ебуч*', 'заеб*', 'наеб*', 'уеб*', 'выеб*', 'поеб*', 'съеб*',
    'разъеб*', 'отъеб*', 'долбоеб*', 'мудак*', 'мудил*', 'мудозвон*', 'мразь', 'мрази', 'мразот*', 'гандон*',
    'гондон*', 'залуп*', 'манда', 'шлюх*', 'шалав*', 'дроч*', 'говн*', 'ублюд*', 'выблядок',
    // Latin transliterations
    'blyat', 'blyad', 'cyka', 'suka blyat', 'cyka blyat', 'nahuy', 'nahui', 'nahuj', 'pohuy', 'pizdec', 'pizda',
    'mudak', 'ebat', 'ebal', 'yebat', 'gandon', 'ublyudok', 'zalupa',
  ],
  hate: [
    'пидор*', 'пидар*', 'пидрил*', 'педик*', 'хач', 'хачи', 'хачей', 'хача', 'чурка', 'чурки', 'чурок', 'жид',
    'жиды', 'жидов', 'жида', 'жидовск*', 'черножоп*', 'черномаз*', 'нигер', 'ниггер*', 'узкоглаз*', 'даун',
    'дауны', 'дауна', 'дауну', 'pidor', 'pidoras',
  ],
  sexual: [
    'отсоси', 'отсоси мне', 'соси хуй', 'скинь нюдсы', 'скинь нюдс', 'скинь фото голой', 'скинь фотки голой',
    'нюдсы', 'нюдс', 'нюдсов', 'изнасил*',
  ],
  harassment: [
    'сдохни', 'сдохните', 'сдохни тварь', 'сдохни сука', 'убей себя', 'убейся', 'убейте себя', 'иди убей себя',
    'вскройся', 'повесься', 'выпились', 'зарежься', 'иди умри', 'чтоб ты сдох', 'чтоб ты сдохла',
    'надеюсь ты сдохнешь', 'убью тебя',
  ],
  scam: [
    'продам аккаунт', 'продам акк', 'продаю аккаунт', 'продаю акк', 'аккаунт продам', 'аккаунт продаю',
    'куплю аккаунт', 'куплю акк', 'продажа аккаунт*', 'буст ранга', 'буст ранг*', 'услуги буста',
    'прокачка ранга', 'накрутка ранга', 'разгон ранга',
  ],
});
