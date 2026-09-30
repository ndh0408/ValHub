import 'package:flutter/services.dart' show PlatformException;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:valvn/core/logging/session_log.dart';
import 'package:valvn/core/storage/secure_store.dart';

class _MockStorage extends Mock implements FlutterSecureStorage {}

PlatformException _keystoreError() =>
    PlatformException(code: 'keystore', message: 'secret-do-not-log');

void main() {
  late _MockStorage storage;
  late List<String> reported;
  late FlutterSecureStore store;

  setUp(() {
    storage = _MockStorage();
    reported = [];
    store = FlutterSecureStore(storage)
      ..onError = (operation, error) => reported.add(operation);
  });

  test('the Android keystore is no longer reset silently (AR-022)', () {
    final options = FlutterSecureStore.defaultStorage.aOptions.toMap();
    expect(options['resetOnError'], 'false');
    expect(options['storageNamespace'], 'valvn_secure');
  });

  group('read', () {
    test('returns the value', () async {
      when(() => storage.read(key: 'k')).thenAnswer((_) async => 'v');
      expect(await store.read('k'), 'v');
      expect(reported, isEmpty);
    });

    test(
      'a keystore error reads as "no value", is reported and erases nothing',
      () async {
        when(() => storage.read(key: 'k')).thenThrow(_keystoreError());
        expect(await store.read('k'), isNull);
        expect(reported, ['read']);
        verifyNever(() => storage.deleteAll());
      },
    );
  });

  group('write', () {
    test('a first-try success reports nothing', () async {
      when(() => storage.write(key: 'k', value: 'v')).thenAnswer((_) async {});
      await store.write('k', 'v');
      expect(reported, isEmpty);
      verifyNever(() => storage.deleteAll());
    });

    test('a transient error is retried once, without a reset', () async {
      var calls = 0;
      when(() => storage.write(key: 'k', value: 'v')).thenAnswer((_) async {
        if (++calls == 1) throw _keystoreError();
      });
      await store.write('k', 'v');
      expect(calls, 2);
      expect(reported, ['write']);
      verifyNever(() => storage.deleteAll());
    });

    test(
      'an unusable store is reset visibly, then written once more',
      () async {
        var calls = 0;
        when(() => storage.write(key: 'k', value: 'v')).thenAnswer((_) async {
          if (++calls <= 2) throw _keystoreError();
        });
        when(() => storage.deleteAll()).thenAnswer((_) async {});
        await store.write('k', 'v');
        expect(calls, 3);
        expect(reported, ['write', 'write.retry', 'reset']);
        verify(() => storage.deleteAll()).called(1);
      },
    );

    test('still failing after the reset surfaces the error', () async {
      when(() => storage.write(key: 'k', value: 'v'))
          .thenThrow(_keystoreError());
      when(() => storage.deleteAll()).thenThrow(_keystoreError());
      await expectLater(
        store.write('k', 'v'),
        throwsA(isA<PlatformException>()),
      );
      expect(reported, ['write', 'write.retry', 'reset.failed']);
    });
  });

  test(
    'delete failures are reported and swallowed (the sweeper retries)',
    () async {
      when(() => storage.delete(key: 'k')).thenThrow(_keystoreError());
      await store.delete('k');
      expect(reported, ['delete']);
    },
  );

  group('readAllKeys', () {
    test('lists the keys without exposing values', () async {
      when(() => storage.readAll()).thenAnswer(
        (_) async => {'acct.a.cookies': 'secret', 'acct.b.access': 'tok'},
      );
      expect(await store.readAllKeys(), {'acct.a.cookies', 'acct.b.access'});
    });

    test('an unreadable store yields no keys, so nothing gets swept', () async {
      when(() => storage.readAll()).thenThrow(_keystoreError());
      expect(await store.readAllKeys(), isEmpty);
      expect(reported, ['readAll']);
    });
  });

  test('errors reach the session log without keys or values', () async {
    final log = SessionLog();
    final logged = FlutterSecureStore(storage)..onError = secureErrorToLog(log);
    when(() => storage.read(key: 'acct.p.cookies')).thenThrow(_keystoreError());
    await logged.read('acct.p.cookies');
    final line = log.entries.single;
    expect(line.event, 'secure.error');
    expect(line.detail, 'read PlatformException');
    expect(line.toLine(), isNot(contains('secret-do-not-log')));
    expect(line.toLine(), isNot(contains('acct.p')));
  });

  test('a broken error sink never breaks storage', () async {
    final broken = FlutterSecureStore(storage)
      ..onError = (_, _) => throw StateError('sink');
    when(() => storage.read(key: 'k')).thenThrow(_keystoreError());
    expect(await broken.read('k'), isNull);
  });

  group('MemorySecureStore', () {
    test('readAllKeys lists the keys', () async {
      final memory = MemorySecureStore({'a': '1'});
      await memory.write('b', '2');
      expect(await memory.readAllKeys(), {'a', 'b'});
      await memory.deleteAll();
      expect(await memory.readAllKeys(), isEmpty);
    });
  });

  group('SecureKeys.puuidOf', () {
    test('extracts the owning PUUID of a key', () {
      const id = '41c322a1-b328-495b-a004-5ccd3e45eae8';
      for (final key in SecureKeys.allFor(id)) {
        expect(SecureKeys.puuidOf(key), id, reason: key);
      }
      expect(SecureKeys.puuidOf('acct.${id.toUpperCase()}.cookies'), id);
    });

    test('keys outside the schema have no owner', () {
      expect(SecureKeys.puuidOf('other.key'), isNull);
      expect(SecureKeys.puuidOf('acct.'), isNull);
      expect(SecureKeys.puuidOf(''), isNull);
    });
  });
}
