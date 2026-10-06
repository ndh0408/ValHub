"""Harvest official VALORANT terminology per locale from valorant-api.com.

    python tool/l10n/harvest_glossary.py

Writes tool/l10n/glossary/<arbCode>.json: per category, a list of
{"vi", "en", "term"} triples aligned by UUID, so translators (and reviewers)
use the game client's own words (I18N.md 14.3 b). Content names themselves
are never translated by hand: the app reads them from the API at runtime.
"""
import json
import os
import urllib.request

LOCALES = {  # arbCode -> valorant-api language (AppLocale.apiCode)
    'ar': 'ar-AE', 'de': 'de-DE', 'en': 'en-US', 'es': 'es-ES', 'es_MX': 'es-MX',
    'fr': 'fr-FR', 'id': 'id-ID', 'it': 'it-IT', 'ja': 'ja-JP', 'ko': 'ko-KR',
    'pl': 'pl-PL', 'pt': 'pt-BR', 'ru': 'ru-RU', 'th': 'th-TH', 'tr': 'tr-TR',
    'vi': 'vi-VN', 'zh': 'zh-CN', 'zh_Hant': 'zh-TW',
}
OUT = os.path.join(os.path.dirname(__file__), 'glossary')


def get(path, lang):
    sep = '&' if '?' in path else '?'
    url = f'https://valorant-api.com/v1/{path}{sep}language={lang}'
    with urllib.request.urlopen(url, timeout=60) as r:
        return json.load(r).get('data') or []


def collect(lang):
    """category -> {uuid: text}"""
    out = {}

    def put(cat, uid, text):
        if uid and isinstance(text, str) and text.strip():
            out.setdefault(cat, {})[uid] = text.strip()

    for c in get('currencies', lang):
        put('currencies', c.get('uuid'), c.get('displayName'))
    for t in get('contenttiers', lang):
        put('contentTiers', t.get('uuid'), t.get('displayName'))
    tiers = get('competitivetiers', lang)
    if tiers:
        for t in tiers[-1].get('tiers') or []:
            if (t.get('tier') or 0) >= 3:
                put('rankTiers', str(t.get('tier')), t.get('tierName'))
    for m in get('gamemodes', lang):
        put('gameModes', m.get('uuid'), m.get('displayName'))
    for q in get('gamemodes/queues', lang):
        put('queues', q.get('uuid'), q.get('dropdownText'))
    for a in get('agents?isPlayableCharacter=true', lang):
        r = a.get('role') or {}
        put('agentRoles', r.get('uuid'), r.get('displayName'))
    for w in get('weapons', lang):
        s = w.get('shopData') or {}
        put('weaponCategories', s.get('category'), s.get('categoryText'))
    for g in get('gear', lang):
        put('gear', g.get('uuid'), g.get('displayName'))
    for c in get('contracts', lang):
        put('contracts', c.get('uuid'), c.get('displayName'))
    return out


def main():
    data = {code: collect(lang) for code, lang in LOCALES.items()}
    vi, en = data['vi'], data['en']
    os.makedirs(OUT, exist_ok=True)
    for code, cats in data.items():
        if code == 'vi':
            continue
        doc = {}
        for cat in sorted(en):
            rows, seen = [], set()
            for uid, en_text in en[cat].items():
                term = cats.get(cat, {}).get(uid)
                vi_text = vi.get(cat, {}).get(uid)
                if not term or not vi_text:
                    continue
                triple = (vi_text, en_text, term)
                if triple in seen:
                    continue
                seen.add(triple)
                rows.append({'vi': vi_text, 'en': en_text, 'term': term})
            doc[cat] = rows
        with open(os.path.join(OUT, f'{code}.json'), 'w', encoding='utf-8', newline='\n') as f:
            json.dump(doc, f, ensure_ascii=False, indent=1)
            f.write('\n')
        print(code, {k: len(v) for k, v in doc.items()})


if __name__ == '__main__':
    main()
