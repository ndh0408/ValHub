"""Git Bash bridge for two installed Claude plugins used by Codex on Windows.

Installed locally by install_windows_hook_compat.ps1. Ordinary shell commands
pass through unchanged. Plugin security decisions, stderr, and exit codes are
preserved; only Claude telemetry fields unsupported by Codex are translated.
"""

import datetime
import json
import os
from pathlib import Path
import re
import subprocess
import sys

EVENTS = {'SessionStart', 'UserPromptSubmit', 'PreToolUse', 'PostToolUse',
          'PermissionRequest', 'Stop', 'SubagentStop'}
COMMON = {'continue', 'stopReason', 'suppressOutput', 'systemMessage',
          'decision', 'reason', 'hookSpecificOutput'}


def normalize_path(value):
    value = value.replace('\\', '/')
    match = re.match(r'^/([a-zA-Z])/(.*)$', value)
    if match:
        value = match[1] + ':/' + match[2]
    return value.rstrip('/').casefold()


def translate_output(raw, event):
    """Fail closed on unknown/malformed formats: retain their original bytes."""
    if event not in EVENTS:
        return raw
    try:
        value = json.loads(raw)
    except (ValueError, UnicodeDecodeError):
        return raw
    if not isinstance(value, dict) or not ({'metrics', 'rewakeSummary'} & value.keys()):
        return raw
    if set(value) - COMMON - {'metrics', 'rewakeSummary'}:
        return raw
    if 'metrics' in value and not isinstance(value['metrics'], dict):
        return raw
    if 'rewakeSummary' in value and not isinstance(value['rewakeSummary'], str):
        return raw
    for name in ('continue', 'suppressOutput'):
        if name in value and not isinstance(value[name], bool):
            return raw
    for name in ('systemMessage', 'stopReason', 'reason'):
        if name in value and not isinstance(value[name], str):
            return raw
    if 'decision' in value and value['decision'] != 'block':
        return raw
    specific = value.get('hookSpecificOutput')
    if specific is not None:
        if not isinstance(specific, dict) or specific.get('hookEventName') != event:
            return raw
        # Only the output shapes emitted by these two plugin scripts are adapted.
        allowed = {'hookEventName', 'additionalContext'}
        if event == 'PermissionRequest':
            allowed |= {'decision'}
        if set(specific) - allowed:
            return raw
        if 'additionalContext' in specific and not isinstance(specific['additionalContext'], str):
            return raw
    converted = dict(value)
    converted.pop('metrics', None)
    summary = converted.pop('rewakeSummary', '')
    if summary:
        existing = converted.get('systemMessage', '')
        converted['systemMessage'] = existing + ('\n' if existing else '') + summary
    return (json.dumps(converted, ensure_ascii=False) + '\n').encode('utf8')


def main():
    if len(sys.argv) < 2 or sys.argv[1] not in ('bash', 'sh'):
        raise SystemExit('Expected bash or sh followed by original shell arguments')
    home = Path(__file__).resolve().parent
    config = json.loads((home / 'config.json').read_text(encoding='utf8'))
    shell = sys.argv[1]
    args = sys.argv[2:]
    command = [config[shell], *args]
    known = bool(args) and normalize_path(args[0]) in {
        normalize_path(path) for path in config['plugin_scripts']
    }
    if not known:
        return subprocess.call(command)
    incoming = sys.stdin.buffer.read()
    try:
        event = json.loads(incoming).get('hook_event_name')
    except (ValueError, AttributeError):
        event = None
    result = subprocess.run(command, input=incoming, stdout=subprocess.PIPE,
                            stderr=subprocess.PIPE)
    converted = translate_output(result.stdout, event)
    sys.stdout.buffer.write(converted)
    sys.stdout.buffer.flush()
    sys.stderr.buffer.write(result.stderr)
    sys.stderr.buffer.flush()
    # No hook inputs, findings, paths, tokens, or stdout/stderr are logged.
    record = {'time': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'event': event if event in EVENTS else 'unknown',
              'exit_code': result.returncode,
              'translated': converted != result.stdout}
    try:
        with (home / 'audit.jsonl').open('a', encoding='utf8') as audit:
            audit.write(json.dumps(record) + '\n')
    except OSError:
        pass
    return result.returncode


if __name__ == '__main__':
    raise SystemExit(main())
