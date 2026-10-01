"""Public-flow QA for a freshly provisioned emulator (never seeds Riot accounts).

Install the normal release APK, assert accessible UI after native intents/back,
and collect screenshots/XML/results. Run the integration suite separately to
exercise real preferences/Keystore/notification plugins. No pm clear/uninstall.
"""

import argparse
import json
from pathlib import Path
import re
import subprocess
import time
import xml.etree.ElementTree as ET


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--adb', required=True)
    parser.add_argument('--serial', required=True)
    parser.add_argument('--apk', type=Path, required=True)
    parser.add_argument('--out', type=Path, required=True)
    args = parser.parse_args()
    args.out.mkdir(parents=True, exist_ok=True)
    results = []
    failure = None

    def adb(*arguments):
        return subprocess.check_output(
            [args.adb, '-s', args.serial, *arguments],
            encoding='utf-8', errors='replace', timeout=45,
        )

    def nodes():
        adb('shell', 'uiautomator', 'dump', '/sdcard/valvn-qa.xml')
        xml = adb('shell', 'cat', '/sdcard/valvn-qa.xml')
        return list(ET.fromstring(xml).iter('node'))

    def labels():
        return '\n'.join(
            n.get('content-desc', '') + ' ' + n.get('text', '') for n in nodes()
        )

    def wait_for(label, timeout=20):
        until = time.monotonic() + timeout
        while time.monotonic() < until:
            if label in labels():
                return
            time.sleep(0.5)
        raise AssertionError(f'Accessible UI did not contain: {label}')

    def tap(label):
        for n in nodes():
            if label not in (n.get('content-desc', ''), n.get('text', '')):
                continue
            x0, y0, x1, y1 = map(int, re.findall(r'\d+', n.get('bounds', '')))
            adb('shell', 'input', 'tap', str((x0+x1)//2), str((y0+y1)//2))
            return
        raise AssertionError(f'Cannot tap: {label}')

    def snapshot(name):
        adb('shell', 'screencap', '-p', '/sdcard/valvn-qa.png')
        adb('pull', '/sdcard/valvn-qa.png', str(args.out / f'{name}.png'))
        adb('shell', 'uiautomator', 'dump', '/sdcard/valvn-qa.xml')
        adb('pull', '/sdcard/valvn-qa.xml', str(args.out / f'{name}.xml'))

    def record(name):
        snapshot(name)
        results.append({'case': name, 'result': 'passed'})
        print(f'PASS: {name}', flush=True)

    def launch(uri=None, cold=False):
        if cold:
            adb('shell', 'am', 'force-stop', 'vn.valvn.app')
        if uri is None:
            adb('shell', 'am', 'start', '-W', '-n',
                'vn.valvn.app/vn.valvn.valvn.MainActivity')
        else:
            adb('shell', 'am', 'start', '-W', '-a',
                'android.intent.action.VIEW', '-d', uri, 'vn.valvn.app')

    def back():
        adb('shell', 'input', 'keyevent', '4')

    adb('install', '-r', str(args.apk.resolve()))
    original_scale = adb('shell', 'settings', 'get', 'system', 'font_scale').strip()
    original_rotation = adb('shell', 'settings', 'get', 'system', 'user_rotation').strip()
    original_auto = adb('shell', 'settings', 'get', 'system', 'accelerometer_rotation').strip()
    try:
        launch(cold=True)
        wait_for('Đăng nhập bằng tài khoản Riot')
        record('release-cold-welcome')
        tap('Chính sách quyền riêng tư')
        wait_for('Phiên bản 1.1')
        record('release-privacy-1.1')
        back()
        wait_for('Đăng nhập bằng tài khoản Riot')
        tap('Điều khoản sử dụng')
        wait_for('Điều khoản sử dụng')
        record('release-terms')
        back()
        wait_for('Đăng nhập bằng tài khoản Riot')
        tap('Đăng nhập bằng tài khoản Riot')
        wait_for('Đăng nhập Riot')
        record('release-riot-webview')
        launch('valvn://community')
        wait_for('Đăng nhập Riot')
        # Guard must retain the WebView, not just keep a stale title underneath.
        assert 'Đăng nhập bằng tài khoản Riot' not in labels()
        record('release-warm-link-deferred-during-login')
        back()
        wait_for('Đăng nhập bằng tài khoản Riot')
        record('release-login-cancel-and-resume-pending-link')
        launch('valvn://store', cold=True)
        wait_for('Đăng nhập bằng tài khoản Riot')
        record('release-cold-link-without-account')
        launch('valvn://login', cold=True)
        wait_for('Đăng nhập bằng tài khoản Riot')
        assert 'Đăng nhập Riot' not in labels()
        record('release-reject-auth-scheme-destination')
        adb('shell', 'settings', 'put', 'system', 'font_scale', '2.0')
        adb('shell', 'settings', 'put', 'system', 'accelerometer_rotation', '0')
        adb('shell', 'settings', 'put', 'system', 'user_rotation', '1')
        launch(cold=True)
        for _ in range(8):
            if 'Đăng nhập bằng tài khoản Riot' in labels():
                break
            adb('shell', 'input', 'swipe', '1200', '850', '1200', '160', '450')
        wait_for('Đăng nhập bằng tài khoản Riot')
        record('release-landscape-font200-cta-reachable')
        tap('Đăng nhập bằng tài khoản Riot')
        wait_for('Đăng nhập Riot')
        record('release-landscape-font200-login-opens')
        pid = adb('shell', 'pidof', 'vn.valvn.app').strip()
        errors = adb('logcat', '-d', f'--pid={pid}', '-s', 'flutter:E', 'AndroidRuntime:E')
        (args.out / 'runtime-errors.log').write_text(errors, encoding='utf-8')
        assert not any(s in errors for s in ['FATAL EXCEPTION', 'Unhandled Exception'])
    except Exception as error:
        failure = f'{type(error).__name__}: {error}'
        snapshot('failure')
        raise
    finally:
        for key, value in [('font_scale', original_scale),
                           ('user_rotation', original_rotation),
                           ('accelerometer_rotation', original_auto)]:
            if value == 'null':
                adb('shell', 'settings', 'delete', 'system', key)
            else:
                adb('shell', 'settings', 'put', 'system', key, value)
        (args.out / 'results.json').write_text(
            json.dumps({'status': 'passed' if failure is None else 'failed',
                        'failure': failure, 'cases': results,
                        'scope': 'public routes; no live authenticated E2E'},
                       ensure_ascii=False, indent=2) + '\n', encoding='utf-8',
        )


if __name__ == '__main__':
    main()
