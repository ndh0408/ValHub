/**
 * English word list. English profanity is common in every community's gaming chat, so this list is
 * applied to all text regardless of language. Matching rules: see vi-wordlist.ts / types.ts
 * (whole words only, leetspeak and elongation tolerant: "f*ck", "$hit", "fuuuck").
 */
import { defineWordlist } from './types.js';

export const EN_WORDLIST = defineWordlist('en', {
  reviewed: true,
  profanity: [
    'fuck', 'fucking', 'fucker', 'fuckers', 'fucked', 'fucks', 'fuk', 'fck', 'fcking', 'fvck', 'fuckin',
    'motherfucker', 'motherfuckers', 'wtf', 'stfu', 'gtfo',
    'shit', 'shitty', 'bullshit', 'bitch', 'bitches', 'asshole', 'assholes',
    'dick', 'dickhead', 'pussy', 'cunt', 'cunts', 'bastard', 'slut', 'whore', 'twat', 'wanker',
  ],
  hate: [
    'nigger', 'niggers', 'nigga', 'niggas', 'faggot', 'faggots', 'fag', 'fags', 'retard', 'retards',
    'retarded', 'chink', 'chinks', 'gook', 'gooks', 'tranny', 'kike', 'spic',
  ],
  sexual: ['rape', 'raped', 'send nudes', 'nudes', 'blowjob', 'suck my dick'],
  harassment: ['kys', 'kill yourself', 'killyourself'],
  scam: [
    'sell acc', 'selling acc', 'selling account', 'buy acc', 'boost rank', 'rank boost', 'elo boost',
    'elo boosting',
    'acc for sale', 'account for sale', 'accounts for sale', 'selling accounts', 'buy account', 'buy accounts',
  ],
});
