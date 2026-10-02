# Localization migration tools

Run with the Flutter-pinned Dart SDK, after `flutter pub get` at the repository root and `dart pub get` here.
Commands discover the containing ValVN checkout; `--root` and `--sdk` can select an explicit checkout/SDK.

```
dart run bin/l10n.dart scan
dart run bin/l10n.dart extract
dart run bin/l10n.dart parity
dart run bin/l10n.dart extract --check
dart run bin/l10n.dart parity --check
dart run bin/l10n.dart rewrite --only 'lib/features/store/ui/**'
dart run bin/l10n.dart rewrite --only 'lib/features/store/ui/**' --apply
dart run bin/l10n.dart rewrite --only 'lib/features/store/ui/**' --capture-async
dart run bin/l10n.dart verify
dart run bin/l10n.dart verify --ci
```

`extract` resolves Dart symbols and writes the Vietnamese ARB and `manifest.json`, with unsupported members listed
explicitly. `parity` compares generated text against legacy members, covering integer branch boundaries, empty and
Unicode strings, braces and newlines. It formats its generated Dart file using the same SDK. Both checks are byte
stable after regeneration; no timestamp is injected.

`rewrite` requires an explicit file selection. It is a dry run by default and writes its report to
`reports/rewrite.json`. It plans resolved references and removes enclosing expression/local `const` where needed,
then validates edit ranges and rechecks source content before writing. Only references with an in-scope
BuildContext and a mechanically extracted message are changed. Nested calls and method tearoffs are supported.
It preserves collection lookups, domain/providers without context, defaults/enums, fields, lifecycle captures,
named/optional signatures and reads after await for structural migration by default.
The opt-in `--capture-async` plans one collision-safe resource capture before suspension only for a block async
function with its own explicit BuildContext parameter. Nested closures, State.context and lifecycle captures
remain manual. The scope, dry-run and source-change guards still apply. It does not introduce a global locale
holder. Apply on an isolated checkout, format and run `dart fix --apply` for unused legacy imports, then analyze
and test the selected package and shared widgets before broadening the selection.

`verify` uses the resolved scan to report actual remaining production references/literals and analyzer errors.
`--ci` exits 1 while cutover is incomplete; this is expected during W2–W4 and must not be presented as green.
Generated localizations/parity are excluded from the scan so they cannot pollute the inventory. Reports are
regenerated locally and ignored by Git; the reviewed extraction manifest is committed.

The `rtl` command is still scheduled for W7. No command here claims translations for 18 UI languages, complete
domain restructuring, migration of every async consumer or the final cutover. See `docs/design/I18N.md` for those gates.
