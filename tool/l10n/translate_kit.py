"""Translation work kit for the 17 non-template locales (I18N.md 14).

    python tool/l10n/translate_kit.py export <workdir>        chunks of app_vi.arb
    python tool/l10n/translate_kit.py check  <workdir> <code> [chunk]
    python tool/l10n/translate_kit.py merge  <workdir> <code> [keys] -> lib/l10n/arb/app_<code>.arb
        (keeps messages already in the file; comma-separated [keys] are
        re-applied from the work dir)

Chunks are `<workdir>/src/<NN>.json` (key, vi, description, placeholders...);
translations are `<workdir>/out/<code>/<NN>.json` ({key: text}). `check` is a
fast pre-check for translators; `dart run tool/l10n_check.dart` and
`flutter gen-l10n` remain the authoritative gates.
"""
import json
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
ARB_DIR = os.path.join(ROOT, 'lib', 'l10n', 'arb')
TEMPLATE = os.path.join(ARB_DIR, 'app_vi.arb')
CHUNK = 160

PLURAL = {
    'ar': {'zero', 'one', 'two', 'few', 'many', 'other'},
    'ru': {'one', 'few', 'many', 'other'},
    'pl': {'one', 'few', 'many', 'other'},
    'en': {'one', 'other'}, 'de': {'one', 'other'}, 'tr': {'one', 'other'},
    'fr': {'one', 'other'}, 'es': {'one', 'other'}, 'es_MX': {'one', 'other'},
    'it': {'one', 'other'}, 'pt': {'one', 'other'},
    'id': {'other'}, 'ja': {'other'}, 'ko': {'other'}, 'th': {'other'},
    'zh': {'other'}, 'zh_Hant': {'other'}, 'vi': {'other'},
}
OPTIONAL = {'fr': {'many'}, 'es': {'many'}, 'es_MX': {'many'}, 'it': {'many'},
            'pt': {'many'}}
SPACELESS = {'ja', 'zh', 'zh_Hant', 'th'}
SCRIPT = {  # non-Latin locales: a translated message must contain this script
    'ar': r'[؀-ۿ]', 'ru': r'[Ѐ-ӿ]', 'th': r'[฀-๿]',
    'ja': r'[぀-ヿ一-鿿]', 'ko': r'[가-힯]',
    'zh': r'[一-鿿]', 'zh_Hant': r'[一-鿿]',
}
# Letters that occur in Vietnamese but in none of the other 17 languages
# (ã/Ã are Portuguese too).
VI_ONLY = re.compile(
    '[ạảầấậẩẫằắặẳẵẹẻẽềếệểễỉĩịọỏồốộổỗơờớợởỡụủũưừứựửữỳỵỷỹđăĂ'
    'ẠẢẦẤẬẨẪẰẮẶẲẴẸẺẼỀẾỆỂỄỈĨỊỌỎỒỐỘỔỖƠỜỚỢỞỠỤỦŨƯỪỨỰỬỮỲỴỶỸĐ]')
# A message made only of capitals, digits, symbols and placeholders ("VP",
# "{a}/{b}", "K/D/A") legitimately has no character of the target script.
# The publisher's legal name keeps its Vietnamese spelling in every locale.
PUBLISHER = 'Nguyễn Đức Huy'
SCRIPT_FREE_OK = re.compile(r'^[A-Z0-9\s\W_]*$')
def _number_word():
    path = os.path.join(ROOT, 'tool', 'l10n', 'allowlist.yaml')
    if not os.path.exists(path):
        return set()
    with open(path, encoding='utf-8') as f:
        return {line.strip()[2:].strip() for line in f if line.strip().startswith('- ')}


NUMBER_WORD = _number_word()
NAME = re.compile(r'[A-Za-z_][A-Za-z0-9_]*')
SELECTOR = re.compile(r'=?[A-Za-z0-9_]+')


def load(path):
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def template():
    j = load(TEMPLATE)
    return j, [k for k in j if not k.startswith('@')]


class IcuError(Exception):
    pass


def parse(msg):
    """(argument names, [(plural name, cases)], [(select name, cases)])."""
    args, plurals, selects = set(), [], []
    bodies = {}
    pos = [0]

    def ws():
        while pos[0] < len(msg) and msg[pos[0]].isspace():
            pos[0] += 1

    def read(pattern, what):
        m = pattern.match(msg, pos[0])
        if not m:
            raise IcuError(f'expected {what} at {pos[0]}: {msg[pos[0]:pos[0] + 15]!r}')
        pos[0] = m.end()
        return m.group(0)

    def message(nested):
        while pos[0] < len(msg):
            c = msg[pos[0]]
            if c == '{':
                pos[0] += 1
                argument()
            elif c == '}':
                if nested:
                    return
                raise IcuError(f'unbalanced }} at {pos[0]}')
            else:
                pos[0] += 1
        if nested:
            raise IcuError('unterminated {')

    def argument():
        ws()
        name = read(NAME, 'a placeholder name')
        ws()
        args.add(name)
        if pos[0] < len(msg) and msg[pos[0]] == '}':
            pos[0] += 1
            return
        if pos[0] >= len(msg) or msg[pos[0]] != ',':
            raise IcuError(f'expected , or }} after {name}')
        pos[0] += 1
        ws()
        kind = read(NAME, 'plural/select')
        ws()
        if kind not in ('plural', 'select'):
            raise IcuError(f'unsupported argument type {kind}')
        if pos[0] >= len(msg) or msg[pos[0]] != ',':
            raise IcuError('expected , after the argument type')
        pos[0] += 1
        cases = set()
        while True:
            ws()
            if pos[0] < len(msg) and msg[pos[0]] == '}':
                pos[0] += 1
                break
            sel = read(SELECTOR, 'a case selector')
            ws()
            if pos[0] >= len(msg) or msg[pos[0]] != '{':
                raise IcuError(f'expected {{ after selector {sel}')
            pos[0] += 1
            start = pos[0]
            message(True)
            bodies[(name, sel)] = msg[start:pos[0]]
            pos[0] += 1
            cases.add(sel)
        (plurals if kind == 'plural' else selects).append((name, cases))

    message(False)
    parse.bodies = bodies
    return args, plurals, selects


_GLOSSARY = {}


def glossary_terms(code):
    """Latin-script official terms of [code] (tool/l10n/glossary), longest
    first, plus Riot's own game titles."""
    if code not in _GLOSSARY:
        terms = {'League of Legends', 'Legends of Runeterra', 'Teamfight Tactics',
                 '2XKO', 'Riot Games', 'Riot ID', 'VALORANT', 'ValHub'}
        path = os.path.join(ROOT, 'tool', 'l10n', 'glossary', f'{code}.json')
        if os.path.exists(path):
            for rows in load(path).values():
                for row in rows:
                    term = row.get('term') or ''
                    if term and re.fullmatch(r"[A-Za-z0-9 .:/&'-]+", term):
                        for t in (term, term.title(), term.capitalize()):
                            terms.add(t)
                            # Single words build composed labels
                            # ("{shortName} Edition", "Deluxe").
                            terms.update(w for w in t.split() if len(w) > 2)
        _GLOSSARY[code] = sorted(terms, key=len, reverse=True)
    return _GLOSSARY[code]


def ws_shape(s):
    return (s[:1].isspace(), s[-1:].isspace(), s.count('\n'), s.endswith('…'))


def check_one(code, vi, text, meta, key=''):
    if not isinstance(text, str) or not text.strip():
        return ['empty or not a string']
    try:
        a_vi, _, s_vi = parse(vi)
        a_t, p_t, s_t = parse(text)
    except IcuError as e:
        return [f'ICU: {e}']
    bodies = parse.bodies
    errs = []
    for name, cases in p_t:
        for sel in cases:
            if (not sel.startswith('=') and '{' + name + '}' not in bodies[(name, sel)]
                    and f'{code}.{key}.{sel}' not in NUMBER_WORD):
                errs.append(f'plural {name}: the "{sel}" branch drops {{{name}}}; keep the '
                            f'number (or ask for an allowlist entry if the wording says it)')
    if a_t != a_vi:
        errs.append(f'placeholders {sorted(a_t)} != source {sorted(a_vi)}')
    types = {k: (v or {}).get('type')
             for k, v in (meta.get('placeholders') or {}).items()}
    for name, cases in p_t:
        if types.get(name) not in ('int', 'num', 'double'):
            errs.append(f'plural on {name} needs a numeric placeholder (it is '
                        f'{types.get(name)}); rephrase without a plural')
        named = {c for c in cases if not c.startswith('=')}
        missing = PLURAL[code] - named
        if missing:
            errs.append(f'plural {name} misses {sorted(missing)}')
        extra = named - PLURAL[code] - OPTIONAL.get(code, set())
        if extra:
            errs.append(f'plural {name} uses categories {code} does not have: {sorted(extra)}')
    src_selects = dict(s_vi)
    for name, cases in s_t:
        if name in src_selects and cases != src_selects[name]:
            errs.append(f'select {name} cases {sorted(cases)} != source {sorted(src_selects[name])}')
    shape_t, shape_v = ws_shape(text), ws_shape(vi)
    if code in SPACELESS:  # may drop (not add) a leading/trailing space
        shape_t = (shape_t[0] or shape_v[0] and not text[:1].isspace(),
                   shape_t[1] or shape_v[1] and not text[-1:].isspace(),
                   shape_t[2], shape_t[3])
    if shape_t != shape_v:
        errs.append('whitespace/ellipsis shape differs from the source '
                    '(leading/trailing space, newline count, trailing …)')
    if (code != 'vi' and not meta.get('x-locked')
            and VI_ONLY.search(text.replace(PUBLISHER, ''))):
        errs.append('contains Vietnamese letters')
    if meta.get('x-locked') and text != vi:
        errs.append('locked message must be copied verbatim')
    pat = SCRIPT.get(code)
    if pat and not meta.get('x-locked'):
        plain = re.sub(r'\{[A-Za-z0-9_]+\}', '', text)
        # Official terms the locale's game client keeps in Latin letters
        # ("Competitive", "Radiant") are not untranslated text.
        for term in glossary_terms(code):
            plain = plain.replace(term, '')
        if (text != vi and len(plain.strip()) > 3 and not re.search(pat, plain)
                and not SCRIPT_FREE_OK.match(plain)):
            errs.append('no character of the target script')
    return errs


def export(work):
    j, keys = template()
    os.makedirs(os.path.join(work, 'src'), exist_ok=True)
    for n in range(0, len(keys), CHUNK):
        rows = []
        for k in keys[n:n + CHUNK]:
            m = j.get('@' + k, {})
            row = {'key': k, 'vi': j[k], 'description': m.get('description', '')}
            if m.get('placeholders'):
                row['placeholders'] = m['placeholders']
            for x in ('x-example', 'x-max-length', 'x-locked'):
                if x in m:
                    row[x] = m[x]
            rows.append(row)
        path = os.path.join(work, 'src', f'{n // CHUNK:02d}.json')
        with open(path, 'w', encoding='utf-8', newline='\n') as f:
            json.dump(rows, f, ensure_ascii=False, indent=1)
    print(f'{len(keys)} keys -> {(len(keys) - 1) // CHUNK + 1} chunks in {work}/src')


def check(work, code, only=None):
    j, _ = template()
    total = bad = 0
    for c in sorted(os.listdir(os.path.join(work, 'src'))):
        stem = c[:-5]
        if only and stem != only:
            continue
        src = load(os.path.join(work, 'src', c))
        out_path = os.path.join(work, 'out', code, c)
        if not os.path.exists(out_path):
            print(f'{stem}: MISSING {out_path}')
            bad += 1
            continue
        try:
            out = load(out_path)
        except Exception as e:  # noqa: BLE001
            print(f'{stem}: invalid JSON: {e}')
            bad += 1
            continue
        want = {r['key'] for r in src}
        for k in sorted(set(out) - want):
            print(f'{stem}:{k}: unknown key')
            bad += 1
        for r in src:
            k = r['key']
            if k not in out:
                if code != 'es_MX':  # es_MX is a delta over es
                    print(f'{stem}:{k}: missing')
                    bad += 1
                continue
            total += 1
            for e in check_one(code, r['vi'], out[k], j.get('@' + k, {}), k):
                print(f'{stem}:{k}: {e}')
                bad += 1
    print(f'{code}: {total} messages checked, {bad} problems')
    return bad


_EXACT = {'=0': 'zero', '=1': 'one', '=2': 'two'}


def _branch_span(msg, start):
    """End index (exclusive) of the `{...}` branch body opening at [start]."""
    depth = 0
    for i in range(start, len(msg)):
        if msg[i] == '{':
            depth += 1
        elif msg[i] == '}':
            depth -= 1
            if depth == 0:
                return i + 1
    raise IcuError('unterminated branch')


def drop_colliding_exact_cases(msg):
    """gen-l10n maps =0/=1/=2 onto zero/one/two: when both exist the exact
    case is silently overridden, so drop it (the category text stays)."""
    for exact, category in _EXACT.items():
        while True:
            m = re.search(r'(?<![\w=])' + exact + r'\s*\{', msg)
            if not m or not re.search(r'(?<![\w=])' + category + r'\s*\{', msg):
                break
            end = _branch_span(msg, m.end() - 1)
            msg = (msg[:m.start()].rstrip() + ' ' + msg[end:].lstrip()).replace(', ', ', ', 1)
            msg = re.sub(r',\s*plural,\s+', ', plural, ', msg)
    return msg


_CJK = re.compile('[　-ヿ一-鿿＀-￯]')


def trim_cjk_edges(code, text):
    """ja/zh: drop a template edge space that sits next to CJK text
    ("、 " -> "、"); Latin neighbours (ValHub, {name}) keep theirs."""
    if code not in ('ja', 'zh', 'zh_Hant'):
        return text
    if text.endswith(' ') and len(text) > 1 and _CJK.match(text[-2]):
        text = text.rstrip(' ')
    if text.startswith(' ') and len(text) > 1 and _CJK.match(text[1]):
        text = text.lstrip(' ')
    return text


def merge(work, code, overwrite=()):
    """Writes app_<code>.arb for the template's keys. Messages already in
    the file are KEPT (another session may have added or fixed them there);
    work-dir translations only fill keys the file lacks, plus the keys
    listed in [overwrite] (re-translations after a template change)."""
    _, keys = template()
    merged = {}
    folder = os.path.join(work, 'out', code)
    for c in sorted(os.listdir(folder)):
        if c.endswith('.json'):
            merged.update(load(os.path.join(folder, c)))
    path = os.path.join(ARB_DIR, f'app_{code}.arb')
    existing = load(path) if os.path.exists(path) else {}
    j, _ = template()
    doc = {'@@locale': code}
    for k in keys:
        if j.get('@' + k, {}).get('x-locked'):
            if code != 'es_MX':  # es_MX inherits locked keys from es
                doc[k] = j[k]
        elif k in existing and k not in overwrite:
            doc[k] = existing[k]
        elif k in merged:
            # Translators may strip the accents of the publisher's legal name.
            doc[k] = trim_cjk_edges(code, drop_colliding_exact_cases(
                merged[k].replace('Nguyen Duc Huy', PUBLISHER)))
    with open(path, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(doc, f, ensure_ascii=False, indent=2)
        f.write('\n')
    print(f'{path}: {len(doc) - 1} messages')


if __name__ == '__main__':
    cmd, work = sys.argv[1], sys.argv[2]
    if cmd == 'export':
        export(work)
    elif cmd == 'check':
        only = sys.argv[4] if len(sys.argv) > 4 else None
        sys.exit(1 if check(work, sys.argv[3], only) else 0)
    elif cmd == 'merge':
        # merge <work> <code> [key1,key2,...]: listed keys are re-applied.
        keys = sys.argv[4].split(',') if len(sys.argv) > 4 else ()
        merge(work, sys.argv[3], overwrite=set(keys))
    else:
        sys.exit(f'unknown command {cmd}')
