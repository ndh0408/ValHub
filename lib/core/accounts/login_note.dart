import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/secure_store.dart';
import '../util/json.dart';
import 'account.dart';
import 'account_providers.dart';

/// The user's own note of how to sign in to one account (Riot username +
/// password), so a re-login is quick. Opt-in: only saved when the user
/// types it. Lives in secure storage only; never logged, never sent
/// anywhere except typed into Riot's own login page on request.
@immutable
class LoginNote {
  const LoginNote({this.username = '', this.password = ''});

  static LoginNote? tryParse(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    Object? json;
    try {
      json = jsonDecode(raw);
    } on FormatException {
      return null;
    }
    final m = asMap(json);
    if (m == null) return null;
    final note = LoginNote(
      username: asString(m['u']) ?? '',
      password: asString(m['p']) ?? '',
    );
    return note.isEmpty ? null : note;
  }

  final String username;
  final String password;

  bool get isEmpty => username.isEmpty && password.isEmpty;

  String encode() => jsonEncode({'u': username, 'p': password});

  @override
  bool operator ==(Object other) =>
      other is LoginNote &&
      other.username == username &&
      other.password == password;

  @override
  int get hashCode => Object.hash(username, password);

  /// Never prints the secrets.
  @override
  String toString() => 'LoginNote(${isEmpty ? 'empty' : 'set'})';
}

/// Saved [LoginNote] of an account (`null` = none).
///
/// ```dart
/// final note = ref.watch(loginNoteProvider(puuid)).value;
/// await ref.read(loginNoteProvider(puuid).notifier).save(note);
/// ```
final loginNoteProvider = AsyncNotifierProvider.autoDispose
    .family<LoginNoteNotifier, LoginNote?, String>(LoginNoteNotifier.new);

class LoginNoteNotifier extends AsyncNotifier<LoginNote?> {
  LoginNoteNotifier(String puuid) : _puuid = puuid.toLowerCase();

  final String _puuid;

  SecureStore get _store => ref.read(secureStoreProvider);
  String get _key => SecureKeys.loginNote(_puuid);

  @override
  Future<LoginNote?> build() async {
    try {
      return LoginNote.tryParse(await _store.read(_key));
    } on Object {
      return null; // unreadable keystore entry: behave as "no note"
    }
  }

  /// Saves (or clears, when [note] is empty) the note.
  Future<void> save(LoginNote note) async {
    final trimmed = LoginNote(
      username: note.username.trim(),
      password: note.password,
    );
    if (trimmed.isEmpty) return clear();
    await _store.write(_key, trimmed.encode());
    if (ref.mounted) state = AsyncData(trimmed);
  }

  Future<void> clear() async {
    await _store.delete(_key);
    if (ref.mounted) state = const AsyncData(null);
  }
}

/// JavaScript that types [note] into Riot's login form (React inputs need
/// the native value setter + an `input` event). Returns `true` when both
/// fields were found. Values are JSON-encoded, never spliced raw.
String loginNoteFillScript(LoginNote note) {
  final u = jsonEncode(note.username);
  final p = jsonEncode(note.password);
  return '''
(function (u, p) {
  var setter = Object.getOwnPropertyDescriptor(
    HTMLInputElement.prototype, 'value').set;
  function fill(el, v) {
    if (!el || !v) return false;
    el.focus();
    setter.call(el, v);
    el.dispatchEvent(new Event('input', { bubbles: true }));
    el.dispatchEvent(new Event('change', { bubbles: true }));
    return true;
  }
  var user = document.querySelector(
    'input[name="username"], input[autocomplete="username"]');
  var pass = document.querySelector(
    'input[name="password"], input[type="password"]');
  var a = fill(user, u);
  var b = fill(pass, p);
  return a && b;
})($u, $p);
''';
}

/// Accounts that have a saved [LoginNote], for "Điền nhanh" on the login
/// page. [preferPuuid] (the account being signed in again) comes first.
final savedLoginNotesProvider = FutureProvider.autoDispose
    .family<List<(Account, LoginNote)>, String?>((ref, preferPuuid) async {
      final accounts = ref.watch(accountsProvider);
      final notes = await Future.wait([
        for (final a in accounts) ref.watch(loginNoteProvider(a.puuid).future),
      ]);
      final result = <(Account, LoginNote)>[
        for (var i = 0; i < accounts.length; i++)
          if (notes[i] case final note?) (accounts[i], note),
      ];
      final prefer = preferPuuid?.toLowerCase();
      if (prefer != null) {
        final i = result.indexWhere((e) => e.$1.puuid == prefer);
        if (i > 0) result.insert(0, result.removeAt(i));
      }
      return result;
    });
