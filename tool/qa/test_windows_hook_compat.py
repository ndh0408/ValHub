"""Security-output compatibility regressions; no real LLM review is invoked."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

spec = importlib.util.spec_from_file_location('compat', Path(__file__).with_name('windows_hook_compat.py'))
compat = importlib.util.module_from_spec(spec)
spec.loader.exec_module(compat)


class OutputTests(unittest.TestCase):
    def translated(self, value, event='PostToolUse'):
        return json.loads(compat.translate_output(json.dumps(value).encode(), event))

    def test_metrics_only_becomes_valid_empty_response(self):
        self.assertEqual(self.translated({'metrics': {'ev': 'tool'}}), {})

    def test_warning_context_and_continue_false_survive(self):
        value = {'metrics': {}, 'continue': False, 'stopReason': 'Review required',
                 'hookSpecificOutput': {'hookEventName': 'PostToolUse',
                                        'additionalContext': 'Unsafe input must be escaped'}}
        expected = dict(value)
        expected.pop('metrics')
        self.assertEqual(self.translated(value), expected)

    def test_stop_block_and_reason_survive(self):
        value = {'metrics': {}, 'rewakeSummary': 'Review required',
                 'decision': 'block', 'reason': 'Finding details'}
        self.assertEqual(self.translated(value, 'Stop'),
                         {'systemMessage': 'Review required', 'decision': 'block',
                          'reason': 'Finding details'})

    def test_summary_preserves_existing_system_warning(self):
        self.assertEqual(self.translated({'metrics': {}, 'systemMessage': 'Original warning',
                                         'rewakeSummary': 'Summary'}),
                         {'systemMessage': 'Original warning\nSummary'})

    def test_permission_deny_survives(self):
        decision = {'behavior': 'deny', 'message': 'Not authorized'}
        self.assertEqual(self.translated({'metrics': {}, 'hookSpecificOutput':
                         {'hookEventName': 'PermissionRequest', 'decision': decision}},
                         'PermissionRequest'), {'hookSpecificOutput':
                         {'hookEventName': 'PermissionRequest', 'decision': decision}})

    def test_standard_output_byte_identical(self):
        raw = b' { "continue" : false, "systemMessage": "warning" }\n'
        self.assertEqual(compat.translate_output(raw, 'PostToolUse'), raw)

    def test_unknown_event_and_fields_are_never_silenced(self):
        for value, event in [({'metrics': {}, 'futureSecurityDecision': 'deny'}, 'PostToolUse'),
                             ({'metrics': {}}, 'FutureEvent')]:
            raw = json.dumps(value).encode()
            self.assertEqual(compat.translate_output(raw, event), raw)

    def test_malformed_plain_empty_and_array_pass_through(self):
        for raw in (b'', b'Warning: block', b'{', b'[]', b'null', b'{"metrics":{}}\nwarning'):
            self.assertEqual(compat.translate_output(raw, 'PostToolUse'), raw)

    def test_invalid_security_field_types_pass_through(self):
        for key, value in [('continue', 'false'), ('decision', 'deny'),
                           ('reason', []), ('rewakeSummary', {}), ('metrics', [])]:
            raw = json.dumps({'metrics': {}, key: value}).encode()
            self.assertEqual(compat.translate_output(raw, 'PostToolUse'), raw)

    def test_unknown_specific_output_passes_through(self):
        for specific in [{'hookEventName': 'PostToolUse', 'futureDecision': 'deny'},
                         {'hookEventName': 'Stop', 'additionalContext': 'block'}]:
            raw = json.dumps({'metrics': {}, 'hookSpecificOutput': specific}).encode()
            self.assertEqual(compat.translate_output(raw, 'PostToolUse'), raw)

    def test_unicode_warning_preserved(self):
        value = {'metrics': {}, 'systemMessage': 'Cảnh báo • تحذير • 警告'}
        self.assertEqual(self.translated(value), {'systemMessage': value['systemMessage']})

    def test_msys_path_normalization_matches_exact_script(self):
        expected = compat.normalize_path(r'C:\Users\Admin\plugin\hooks.sh')
        self.assertEqual(compat.normalize_path('/c/Users/Admin/plugin/hooks.sh'), expected)
        self.assertNotEqual(compat.normalize_path('/c/Users/Admin/other/hooks.sh'), expected)


@unittest.skipUnless(os.name == 'nt' and Path(r'C:\Program Files\Git\bin\bash.exe').exists(),
                     'Windows Git Bash execution checks')
class ExecutionTests(unittest.TestCase):
    def test_known_script_keeps_block_stderr_and_exit_two(self):
        with tempfile.TemporaryDirectory(prefix='vanhub-hook-fixture-') as directory:
            root = Path(directory)
            script = root / 'fixture with spaces.sh'
            script.write_text('''#!/bin/sh
cat >/dev/null
printf '%s\\n' '{"metrics":{},"decision":"block","reason":"Finding","rewakeSummary":"Review required"}'
printf 'original security finding' >&2
exit 2
''', encoding='utf8')
            (root / 'windows_hook_compat.py').write_bytes(Path(compat.__file__).read_bytes())
            (root / 'config.json').write_text(json.dumps({
                'bash': r'C:\Program Files\Git\bin\bash.exe',
                'plugin_scripts': [str(script)]}), encoding='utf8')
            result = subprocess.run([sys.executable, str(root / 'windows_hook_compat.py'),
                                     'bash', str(script)],
                                    input=b'{"hook_event_name":"Stop"}', capture_output=True)
            self.assertEqual(result.returncode, 2)
            self.assertEqual(result.stderr, b'original security finding')
            self.assertEqual(json.loads(result.stdout), {'decision': 'block',
                'reason': 'Finding', 'systemMessage': 'Review required'})

    def test_unrecognized_shell_command_keeps_stdout_stderr_exit(self):
        with tempfile.TemporaryDirectory(prefix='vanhub-shell-fixture-') as directory:
            root = Path(directory)
            (root / 'windows_hook_compat.py').write_bytes(Path(compat.__file__).read_bytes())
            (root / 'config.json').write_text(json.dumps({
                'bash': r'C:\Program Files\Git\bin\bash.exe', 'plugin_scripts': []}), encoding='utf8')
            result = subprocess.run([sys.executable, str(root / 'windows_hook_compat.py'),
                'bash', '-c', 'printf normal; printf error >&2; exit 7'], capture_output=True)
            self.assertEqual((result.returncode, result.stdout, result.stderr), (7, b'normal', b'error'))


if __name__ == '__main__':
    unittest.main()
