import 'dart:async';

import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/account_strings.dart';
import '../l10n/common_strings.dart';
import '../ui/error_view.dart';
import 'account.dart';
import 'account_widgets.dart';
import 'login_note.dart';

/// Opens the "Ghi chú đăng nhập" sheet of [account]: view, copy, edit or
/// delete the saved Riot username / password.
Future<void> showLoginNoteSheet(BuildContext context, Account account) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => LoginNoteSheet(account: account),
    );

class LoginNoteSheet extends ConsumerStatefulWidget {
  const LoginNoteSheet({super.key, required this.account});

  final Account account;

  @override
  ConsumerState<LoginNoteSheet> createState() => _LoginNoteSheetState();
}

class _LoginNoteSheetState extends ConsumerState<LoginNoteSheet> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loaded = false;
  bool _saving = false;

  String get _puuid => widget.account.puuid;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _fill(LoginNote? note) {
    if (_loaded) return;
    _loaded = true;
    _username.text = note?.username ?? '';
    _password.text = note?.password ?? '';
  }

  Future<void> _copy(String text) async {
    if (text.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) showAppSnackBar(context, CommonStrings.copied);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    await ref
        .read(loginNoteProvider(_puuid).notifier)
        .save(LoginNote(username: _username.text, password: _password.text));
    navigator.pop();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(AccountStrings.loginNoteSaved)),
      );
  }

  Future<void> _delete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AccountStrings.deleteLoginNote),
        content: const Text(AccountStrings.deleteLoginNoteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(CommonStrings.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(CommonStrings.delete),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    await ref.read(loginNoteProvider(_puuid).notifier).clear();
    navigator.pop();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text(AccountStrings.loginNoteDeleted)),
      );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final async = ref.watch(loginNoteProvider(_puuid));
    if (async.hasValue) _fill(async.value);
    final hasNote = async.value != null;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                AccountAvatar(account: widget.account, size: 36, circle: true),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AccountStrings.loginNote,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        widget.account.riotId,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              AccountStrings.loginNoteHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            if (!async.hasValue)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              )
            else ...[
              TextField(
                controller: _username,
                autocorrect: false,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: AccountStrings.loginNoteUsername,
                  prefixIcon: const Icon(Icons.person_outline),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.copy_rounded),
                    tooltip: AccountStrings.copyUsername,
                    onPressed: () => unawaited(_copy(_username.text)),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: _obscure,
                autocorrect: false,
                enableSuggestions: false,
                keyboardType: TextInputType.visiblePassword,
                decoration: InputDecoration(
                  labelText: AccountStrings.loginNotePassword,
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _obscure
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        tooltip: _obscure
                            ? AccountStrings.showPassword
                            : AccountStrings.hidePassword,
                        onPressed: () => setState(() => _obscure = !_obscure),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded),
                        tooltip: AccountStrings.copyPassword,
                        onPressed: () => unawaited(_copy(_password.text)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  if (hasNote)
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: theme.colorScheme.error,
                      ),
                      onPressed: _saving ? null : () => unawaited(_delete()),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text(AccountStrings.deleteLoginNote),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: _saving ? null : () => unawaited(_save()),
                    child: const Text(CommonStrings.save),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
