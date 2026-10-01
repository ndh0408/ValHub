import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/accounts/login_note.dart';
import 'package:valvn/core/accounts/account.dart';
import 'package:valvn/core/accounts/account_providers.dart';
import 'package:valvn/core/accounts/secret_access.dart';
import 'package:valvn/core/storage/secure_store.dart';

class _MetadataAccounts extends AccountsNotifier {
  @override
  List<Account> build() => [
    const Account(
      puuid: 'a',
      gameName: 'A',
      tagLine: 'TAG',
      region: 'ap',
      shard: 'ap',
    ),
  ];
}

class _TrackedSecrets extends MemorySecureStore {
  int reads = 0;
  int bulkReads = 0;
  @override
  Future<String?> read(String key) async {
    reads++;
    return super.read(key);
  }

  @override
  Future<Set<String>> readAllKeys() async {
    bulkReads++;
    return super.readAllKeys();
  }
}

void main() {
  test('the login-note picker never reads or decrypts note values', () async {
    final secure = _TrackedSecrets();
    secure.values[SecureKeys.loginNote('a')] = const LoginNote(
      password: 'secret',
    ).encode();
    final container = ProviderContainer.test(
      overrides: [
        secureStoreProvider.overrideWithValue(secure),
        accountsProvider.overrideWith(_MetadataAccounts.new),
      ],
    );
    final notes = await container.read(savedLoginNotesProvider(null).future);
    expect(notes.single.$1.puuid, 'a');
    expect(notes.single.$2.isEmpty, isTrue);
    expect(secure.reads, 0);
    expect(secure.bulkReads, 0);
  });

  test('refused authentication cannot decrypt a saved password', () async {
    final secure = MemorySecureStore({
      SecureKeys.loginNote('a'): const LoginNote(password: 'never-reveal')
          .encode(),
    });
    final container = ProviderContainer.test(
      overrides: [
        secureStoreProvider.overrideWithValue(secure),
        secretUnlockProvider.overrideWithValue(() async => false),
      ],
    );
    expect(await container.read(loginNoteProvider('a').future), isNull);
    expect(secure.values[SecureKeys.loginNote('a')], contains('never-reveal'));
  });

  testWidgets('clipboard expires at 45 seconds without clearing a later copy', (
    tester,
  ) async {
    var clipboard = '';
    final service = SecretClipboard(
      write: (value) async => clipboard = value,
      read: () async => clipboard,
    );
    await service.copy('secret');
    await tester.pump(const Duration(seconds: 44));
    expect(clipboard, 'secret');
    await tester.pump(const Duration(seconds: 1));
    expect(clipboard, '');
    await service.copy('another secret');
    clipboard = 'my new copy';
    await tester.pump(const Duration(seconds: 45));
    expect(clipboard, 'my new copy');
  });
}
