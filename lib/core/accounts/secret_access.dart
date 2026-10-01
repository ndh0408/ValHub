import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../l10n/account_strings.dart';

const _secretChannel = MethodChannel('valvn/secrets');

Future<void> setSecretPrivacy(bool enabled) async {
  if (!Platform.isAndroid) return;
  try {
    await _secretChannel.invokeMethod<void>('privacy', enabled);
  } on Object {
    // Tests and platforms without the native adapter.
  }
}

Future<void> _copySecret(String text) async {
  if (Platform.isAndroid) {
    try {
      await _secretChannel.invokeMethod<void>('copy', text);
      return;
    } on Object {
      // Fall back to Flutter's clipboard when the adapter is unavailable.
    }
  }
  await Clipboard.setData(ClipboardData(text: text));
}

final secretUnlockProvider = Provider<Future<bool> Function()>((ref) {
  final auth = LocalAuthentication();
  return () async {
    try {
      return await auth.authenticate(
        localizedReason: AccountStrings.unlockLoginNote,
      );
    } on Object {
      return false;
    }
  };
});

/// Expires only our own clipboard contents; closing a sheet keeps the timer.
class SecretClipboard {
  SecretClipboard({
    Future<void> Function(String)? write,
    Future<String?> Function()? read,
    this.expiry = const Duration(seconds: 45),
  }) : _write = write ?? _copySecret,
       _read =
           read ?? (() async => (await Clipboard.getData('text/plain'))?.text);

  final Future<void> Function(String) _write;
  final Future<String?> Function() _read;
  final Duration expiry;
  Timer? _timer;
  int _generation = 0;

  Future<void> copy(String text) async {
    final generation = ++_generation;
    _timer?.cancel();
    await _write(text);
    _timer = Timer(expiry, () async {
      try {
        if (generation == _generation && await _read() == text) {
          await _write('');
        }
      } on Object {
        // Clipboard reads may be refused in the background.
      }
    });
  }
}

final secretClipboardProvider = Provider<SecretClipboard>(
  (ref) => SecretClipboard(),
);
