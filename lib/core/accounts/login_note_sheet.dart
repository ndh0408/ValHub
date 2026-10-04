import 'package:valvn/core/l10n/account_labels.dart';

import 'dart:async';

import 'secret_access.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../theme/app_theme.dart';
import '../ui/adaptive.dart';
import '../ui/error_view.dart';
import '../ui/sub_page.dart';
import 'account.dart';
import 'account_widgets.dart';
import 'login_note.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Opens the "Ghi chú đăng nhập" sheet of [account]: view, copy, edit or
/// delete the saved Riot username / password.
Future<void> showLoginNoteSheet(BuildContext context, Account account) =>
    showValSheet<void>(
      context,
      title: context.l10n.accountLoginNote,
      subtitle: account.displayRiotId(context.l10n),
      leading: AccountAvatar(account: account, size: 40, circle: true),
      builder: (context, _) => LoginNoteSheet(account: account),
    );

class LoginNoteSheet extends ConsumerStatefulWidget {
  const LoginNoteSheet({super.key, required this.account});

  final Account account;

  @override
  ConsumerState<LoginNoteSheet> createState() => _LoginNoteSheetState();
}

class _LoginNoteSheetState extends ConsumerState<LoginNoteSheet>
    with WidgetsBindingObserver {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _loaded = false;
  bool _saving = false;
  bool _opened = false;

  String get _puuid => widget.account.puuid;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(setSecretPrivacy(true));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_opened) return;
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      _username.clear();
      _password.clear();
      _loaded = false;
      _obscure = true;
      _opened = false;
      ref.invalidate(loginNoteProvider(_puuid));
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(setSecretPrivacy(false));
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
    final l10n = context.l10n;
    if (!await ref.read(secretUnlockProvider)() || !mounted) return;
    await ref.read(secretClipboardProvider).copy(text);
    if (mounted) showAppSnackBar(context, l10n.commonCopied);
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    await ref
        .read(loginNoteProvider(_puuid).notifier)
        .save(LoginNote(username: _username.text, password: _password.text));
    navigator.pop();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.accountLoginNoteSaved)));
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final ok = await showConfirmDialog(
      context,
      title: l10n.accountDeleteLoginNote,
      message: l10n.accountDeleteLoginNoteConfirm,
      confirmLabel: l10n.commonDelete,
      destructive: true,
      icon: Icons.delete_outline,
    );
    if (!ok || !mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    final navigator = Navigator.of(context);
    await ref.read(loginNoteProvider(_puuid).notifier).clear();
    navigator.pop();
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(l10n.accountLoginNoteDeleted)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    if (!_opened) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: FilledButton(
          onPressed: () async {
            ref.invalidate(loginNoteProvider(_puuid));
            final note = await ref.read(loginNoteProvider(_puuid).future);
            if (mounted) {
              _fill(note);
              setState(() => _opened = true);
            }
          },
          child: Text(context.l10n.accountLoginNoteLocked),
        ),
      );
    }
    final async = ref.watch(loginNoteProvider(_puuid));
    if (async.hasValue) _fill(async.value);
    final hasNote = async.value != null;
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PrivacyNote(text: context.l10n.accountLoginNoteHint),
          const SizedBox(height: 16),
          if (!async.hasValue)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator.adaptive()),
            )
          else ...[
            TextField(
              controller: _username,
              autocorrect: false,
              enableSuggestions: false,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: context.l10n.accountLoginNoteUsername,
                prefixIcon: const Icon(Icons.person_outline),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.copy_rounded),
                  tooltip: context.l10n.accountCopyUsername,
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
                labelText: context.l10n.accountLoginNotePassword,
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
                          ? context.l10n.accountShowPassword
                          : context.l10n.accountHidePassword,
                      onPressed: () async {
                        if (!_obscure ||
                            await ref.read(secretUnlockProvider)()) {
                          if (mounted) setState(() => _obscure = !_obscure);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded),
                      tooltip: context.l10n.accountCopyPassword,
                      onPressed: () => unawaited(_copy(_password.text)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
              onPressed: _saving ? null : () => unawaited(_save()),
              child: Text(context.l10n.commonSave),
            ),
            if (hasNote) ...[
              const SizedBox(height: 4),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: scheme.error,
                  minimumSize: const Size(0, 48),
                ),
                onPressed: _saving ? null : () => unawaited(_delete()),
                icon: const Icon(Icons.delete_outline),
                label: Text(context.l10n.accountDeleteLoginNote),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

/// "Chỉ lưu trên thiết bị này…": lock in a tinted disc + the explanation on
/// an `s2` card.
class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final win = valColorsOf(context).win;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: valColorsOf(context).surface2,
        borderRadius: BorderRadius.circular(ValRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: win.withValues(alpha: 0.14),
              ),
              child: Icon(Icons.lock_outline, size: 19, color: win),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
