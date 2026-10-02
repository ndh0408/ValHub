"""Observe and cancel the synthetic integration-test native share chooser."""
import argparse
import json
from pathlib import Path
import re
import subprocess
import time


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--adb', required=True)
    parser.add_argument('--serial', required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)

    def adb(*arguments):
        return subprocess.check_output([args.adb, '-s', args.serial, *arguments],
            encoding='utf8', errors='replace', timeout=30)

    deadline = time.monotonic() + 330
    while time.monotonic() < deadline:
        activity = adb('shell', 'dumpsys', 'activity', 'activities')
        if re.search(r'(?:mResumedActivity:|topResumedActivity=|ResumedActivity:).*'
                     r'(?:ChooserActivity|ResolverActivity)', activity):
            adb('shell', 'uiautomator', 'dump', '/sdcard/vanhub-share-chooser.xml')
            xml = adb('shell', 'cat', '/sdcard/vanhub-share-chooser.xml')
            # Confirm this is our synthetic native test, not an unrelated share.
            if 'VanHub QA' not in xml and 'vanhub-qa-public-post' not in xml:
                raise AssertionError('Native chooser does not show the QA fixture')
            (args.out / 'chooser.xml').write_text(xml, encoding='utf8')
            adb('shell', 'screencap', '-p', '/sdcard/vanhub-share-chooser.png')
            adb('pull', '/sdcard/vanhub-share-chooser.png', str(args.out / 'chooser.png'))
            adb('shell', 'input', 'keyevent', '4')
            report = {'status': 'passed', 'native_chooser_visible': True,
                'synthetic_post_only': True, 'cancelled_with_back': True,
                'destination_selected': False}
            (args.out / 'results.json').write_text(json.dumps(report, indent=2), encoding='utf8')
            print(json.dumps(report))
            return
        time.sleep(1)
    raise TimeoutError('Native share chooser was not observed')


if __name__ == '__main__':
    main()
