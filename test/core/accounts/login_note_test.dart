import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/login_note.dart';
import 'package:valvn/core/accounts/login_note_sheet.dart';
import 'package:valvn/core/auth/auth_providers.dart';
import 'package:valvn/core/auth/session_manager.dart';
import 'package:valvn/core/l10n/account_strings.dart';
import 'package:valvn/core/l10n/common_strings.dart';
import 'package:valvn/core/storage/prefs.dart';
import 'package:valvn/core/storage/secure_store.dart';
import 'package:valvn/core/theme/app_theme.dart';

import '../../helpers/test_prefs.dart';

class MockSessions extends Mock implements SessionManager {}

String _puuid(int i) =>
    '00000000-0000-0000-0000-${i.toString().padLeft(12, '0')}';

Account _account(int i) => Account(
  puuid: _puuid(i),
  gameName: 'P$i',
  tagLine: 'VN',
  region: 'ap',
  shard: 'ap',
);

void main() {
  group('LoginNote', () {
    test('round trip; odd stored values read as no note', () {
      const note = LoginNote(username: 'mikono', password: 'p"a\\ss');
      expect(LoginNote.tryParse(note.encode()), note);
      expect(LoginNote.tryParse(null), isNull);
      expect(LoginNote.tryParse(''), isNull);
      expect(LoginNote.tryParse('<html>'), isNull);
      expect(LoginNote.tryParse('[1]'), isNull);
      expect(LoginNote.tryParse('{"u":"","p":""}'), isNull);
      expect(
        LoginNote.tryParse('{"u":"a","p":[5]}'),
        const LoginNote(username: 'a'),
      );
    });

    test('toString never prints the secrets', () {
      const note = LoginNote(username: 'mikono', password: 'secret');
      expect(note.toString(), isNot(contains('mikono')));
      expect(note.toString(), isNot(contains('secret')));
    });

    test('deleted with the account (part of the per-account secrets)', () {
      expect(
        SecureKeys.allFor(_puuid(1)),
        contains(SecureKeys.loginNote(_puuid(1))),
      );
    });

    test('fill script JSON-escapes the values', () {
      const note = LoginNote(username: "a'b", password: '");alert(1);("');
      final js = loginNoteFillScript(note);
      expect(js, contains('"a\'b"'));
      expect(js, contains(r'"\");alert(1);(\""'));
    });
  });

  late Prefs prefs;
  late MemorySecureStore secure;
  late MockSessions sessions;

  setUp(() async {
    prefs = await createTestPrefs();
    await prefs.setJson(PrefKeys.accounts, [
      _account(1).toJson(),
      _account(2).toJson(),
      _account(3).toJson(),
    ]);
    secure = MemorySecureStore();
    sessions = MockSessions();
    when(() => sessions.events).thenAnswer((_) => const Stream.empty());
  });

  List<Override> overrides() => [
    prefsProvider.overrideWithValue(prefs),
    secureStoreProvider.overrideWithValue(secure),
    sessionManagerProvider.overrideWithValue(sessions),
  ];

  test('save trims the username, clear deletes, empty = clear', () async {
    final c = ProviderContainer.test(overrides: overrides());
    final sub = c.listen(loginNoteProvider(_puuid(1)), (_, _) {});
    expect(await c.read(loginNoteProvider(_puuid(1)).future), isNull);

    final notifier = c.read(loginNoteProvider(_puuid(1)).notifier);
    await notifier.save(const LoginNote(username: ' mikono ', password: 'pw'));
    expect(
      sub.read().value,
      const LoginNote(username: 'mikono', password: 'pw'),
    );
    expect(
      LoginNote.tryParse(secure.values[SecureKeys.loginNote(_puuid(1))]),
      const LoginNote(username: 'mikono', password: 'pw'),
    );

    await notifier.save(const LoginNote(username: '  '));
    expect(sub.read().value, isNull);
    expect(secure.values.containsKey(SecureKeys.loginNote(_puuid(1))), isFalse);
  });

  test(
    'saved notes: only accounts with a note, re-login account first',
    () async {
      secure.values[SecureKeys.loginNote(_puuid(1))] = const LoginNote(
        username: 'one',
      ).encode();
      secure.values[SecureKeys.loginNote(_puuid(3))] = const LoginNote(
        username: 'three',
      ).encode();
      final c = ProviderContainer.test(overrides: overrides());
      final all = await c.read(savedLoginNotesProvider(null).future);
      expect(all.map((e) => e.$2.username), ['one', 'three']);
      final relogin = await c.read(savedLoginNotesProvider(_puuid(3)).future);
      expect(relogin.map((e) => e.$2.username), ['three', 'one']);
    },
  );

  testWidgets('sheet: password hidden by default, reveal, save', (
    tester,
  ) async {
    secure.values[SecureKeys.loginNote(_puuid(1))] = const LoginNote(
      username: 'mikono',
      password: 'hunter2',
    ).encode();
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showLoginNoteSheet(context, _account(1)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    expect(find.text(AccountStrings.loginNote), findsOneWidget);
    expect(find.text('mikono'), findsOneWidget);
    final password = find.widgetWithText(TextField, 'hunter2');
    expect(tester.widget<TextField>(password).obscureText, isTrue);

    await tester.tap(find.byTooltip(AccountStrings.showPassword));
    await tester.pump();
    expect(tester.widget<TextField>(password).obscureText, isFalse);

    await tester.enterText(password, 'newpass');
    await tester.tap(find.text(CommonStrings.save));
    await tester.pumpAndSettle();
    expect(find.text(AccountStrings.loginNoteSaved), findsOneWidget);
    expect(
      LoginNote.tryParse(secure.values[SecureKeys.loginNote(_puuid(1))]),
      const LoginNote(username: 'mikono', password: 'newpass'),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('sheet: "Xóa ghi chú" asks first, then clears the note', (
    tester,
  ) async {
    secure.values[SecureKeys.loginNote(_puuid(1))] = const LoginNote(
      username: 'mikono',
      password: 'hunter2',
    ).encode();
    await tester.pumpWidget(
      ProviderScope(
        overrides: overrides(),
        child: MaterialApp(
          theme: buildDarkTheme(),
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showLoginNoteSheet(context, _account(1)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    // The shared sheet chrome: title, the Riot ID and a close button.
    expect(find.text(AccountStrings.loginNote), findsOneWidget);
    expect(find.text('P1#VN'), findsOneWidget);
    expect(find.byTooltip(CommonStrings.close), findsOneWidget);

    await tester.tap(find.text(AccountStrings.deleteLoginNote));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(AccountStrings.deleteLoginNoteConfirm), findsOneWidget);

    // Cancelling keeps the note.
    await tester.tap(find.text(CommonStrings.cancel));
    await tester.pumpAndSettle();
    expect(secure.values.containsKey(SecureKeys.loginNote(_puuid(1))), isTrue);

    await tester.tap(find.text(AccountStrings.deleteLoginNote));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, CommonStrings.delete));
    await tester.pumpAndSettle();
    expect(find.text(AccountStrings.loginNoteDeleted), findsOneWidget);
    expect(secure.values.containsKey(SecureKeys.loginNote(_puuid(1))), isFalse);
    expect(tester.takeException(), isNull);
  });
}
