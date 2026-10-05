"""Summarize instrumented Flutter line coverage without inventing a gate.

Run after `flutter test --coverage`. Generated localization is excluded;
uninstrumented source files are listed separately, never treated as covered.
"""

import argparse
import json
from pathlib import Path


def eligible(path):
    return (path.startswith('lib/') and path.endswith('.dart')
            and not path.startswith('lib/l10n/gen/')
            and not path.endswith(('.g.dart', '.freezed.dart')))


def summarize(lcov, root):
    root = root.resolve()
    lines_by_file = {}
    ignored = set()
    source = None
    active_record = False
    for number, row in enumerate(lcov.splitlines(), 1):
        if row.startswith('SF:'):
            if active_record:
                raise ValueError(f'Unterminated LCOV record at line {number}')
            raw = row[3:].replace('\\', '/')
            candidate = Path(raw)
            if not candidate.is_absolute():
                candidate = root / candidate
            try:
                normalized = candidate.resolve().relative_to(root).as_posix()
            except ValueError:
                normalized = None
            if normalized is not None and eligible(normalized):
                if not candidate.is_file():
                    raise ValueError(f'Missing coverage source: {normalized}')
                source = normalized
                lines_by_file.setdefault(source, {})
            else:
                source = None
                ignored.add(raw)
            active_record = True
        elif row.startswith('DA:'):
            if not active_record:
                raise ValueError(f'Coverage data before SF at line {number}')
            parts = row[3:].split(',')
            if len(parts) not in (2, 3):
                raise ValueError(f'Invalid DA at line {number}')
            line, hits = int(parts[0]), int(parts[1])
            if line <= 0 or hits < 0:
                raise ValueError(f'Invalid coverage count at line {number}')
            if source is not None:
                previous = lines_by_file[source].get(line, 0)
                lines_by_file[source][line] = previous + hits
        elif row == 'end_of_record':
            source = None
            active_record = False
    if active_record:
        raise ValueError('Unterminated final LCOV record')
    entries = []
    for source, lines in sorted(lines_by_file.items()):
        if not lines:
            continue
        entries.append({'path': source, 'covered': sum(n > 0 for n in lines.values()),
                        'instrumented': len(lines)})
    total = sum(e['instrumented'] for e in entries)
    if not total:
        raise ValueError('No instrumented application lines in LCOV')
    covered = sum(e['covered'] for e in entries)
    all_sources = {p.relative_to(root).as_posix() for p in (root / 'lib').rglob('*.dart')
                   if eligible(p.relative_to(root).as_posix())}
    instrumented = {e['path'] for e in entries}
    return {'schema': 1, 'scope': 'instrumented application lines',
            'covered': covered, 'instrumented': total,
            'percent': round(covered / total * 100, 2),
            'excludedGenerated': ['lib/l10n/gen/**', '*.g.dart', '*.freezed.dart'],
            'ignoredRecordCount': len(ignored), 'files': entries,
            'uninstrumentedFiles': sorted(all_sources - instrumented),
            'thresholdEnforced': False}


def markdown(result):
    return ('# Flutter line coverage\n\n'
            f"{result['covered']:,} / {result['instrumented']:,} instrumented lines "
            f"covered (**{result['percent']:.2f}%**).\n\n"
            f"Instrumented files: {len(result['files'])}; "
            f"source files absent from LCOV: {len(result['uninstrumentedFiles'])}.\n\n"
            'Generated localization, .g.dart and .freezed.dart are excluded. '
            'No percentage threshold is enforced. This measures executed lines, '
            'not branch coverage, mutation resistance, device acceptance or '
            'whole-product completeness. See summary.json for per-file counts '
            'and uninstrumented source files.\n')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--lcov', type=Path, default=Path('coverage/lcov.info'))
    parser.add_argument('--root', type=Path, default=Path.cwd())
    parser.add_argument('--out', type=Path, default=Path('coverage'))
    args = parser.parse_args()
    try:
        result = summarize(args.lcov.read_text(encoding='utf-8'), args.root)
    except (OSError, ValueError) as error:
        parser.exit(1, f'coverage: {error}\n')
    args.out.mkdir(parents=True, exist_ok=True)
    (args.out / 'summary.json').write_text(json.dumps(result, indent=2) + '\n',
                                         encoding='utf-8')
    (args.out / 'summary.md').write_text(markdown(result), encoding='utf-8')
    print(markdown(result))


if __name__ == '__main__':
    main()
