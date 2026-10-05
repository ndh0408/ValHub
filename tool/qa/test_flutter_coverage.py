import tempfile
import unittest
from pathlib import Path

from flutter_coverage import summarize


class CoverageTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in ['lib/app.dart', 'lib/not_imported.dart',
                     'lib/l10n/gen/app_localizations_vi.dart', 'lib/model.g.dart']:
            path = self.root / name
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text('// fixture\n', encoding='utf-8')

    def test_merges_duplicate_records_without_inflating_denominator(self):
        report = summarize('SF:lib/app.dart\nDA:1,0\nDA:2,1\nend_of_record\n'
                           'SF:lib/app.dart\nDA:1,5,checksum\nDA:2,0\n'
                           'DA:3,0\nend_of_record\n', self.root)
        self.assertEqual((report['covered'], report['instrumented']), (2, 3))
        self.assertEqual(report['percent'], 66.67)
        self.assertEqual(report['uninstrumentedFiles'], ['lib/not_imported.dart'])
        self.assertFalse(report['thresholdEnforced'])

    def test_absolute_and_windows_separator_records_resolve_to_same_source(self):
        report = summarize('SF:lib\\app.dart\nDA:1,0\nend_of_record\n'
                           f'SF:{self.root / "lib/app.dart"}\nDA:1,2\n'
                           'end_of_record\n', self.root)
        self.assertEqual(report['files'], [
            {'path': 'lib/app.dart', 'covered': 1, 'instrumented': 1}])

    def test_generated_and_outside_sources_do_not_inflate_coverage(self):
        records = ['lib/app.dart', 'lib/l10n/gen/app_localizations_vi.dart',
                   'lib/model.g.dart', '../outside.dart']
        report = summarize(''.join(f'SF:{name}\nDA:1,1\nend_of_record\n'
                                   for name in records), self.root)
        self.assertEqual(report['instrumented'], 1)
        self.assertEqual(report['ignoredRecordCount'], 3)

    def test_malformed_or_incomplete_reports_fail(self):
        for data in ['', 'DA:1,1\n', 'SF:lib/app.dart\nDA:1,1\n',
                     'SF:lib/app.dart\nSF:lib/app.dart\n',
                     'SF:lib/app.dart\nDA:0,1\nend_of_record\n',
                     'SF:lib/app.dart\nDA:1,-1\nend_of_record\n',
                     'SF:lib/app.dart\nDA:1,nope\nend_of_record\n',
                     'SF:lib/missing.dart\nDA:1,1\nend_of_record\n']:
            with self.subTest(data=data), self.assertRaises(ValueError):
                summarize(data, self.root)


if __name__ == '__main__':
    unittest.main()
