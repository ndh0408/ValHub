import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/error_view.dart' show describeError;
import '../../community_strings.dart';
import '../../data/community_models.dart';
import '../../providers/lfg_providers.dart';
import '../widgets/community_widgets.dart';

/// Validates a party code: `null` when valid, else the message.
String? validatePartyCode(String code) {
  final c = code.trim().toUpperCase();
  if (c.isEmpty) return CommunityStrings.codeRequired;
  if (!partyCodePattern.hasMatch(c)) return CommunityStrings.codeInvalid;
  return null;
}

/// Opens the "Tạo tin tìm đồng đội" sheet; resolves to the created post.
Future<LfgPost?> showCreateLfgSheet(
  BuildContext context, {
  required Account account,
  required String region,
  LfgQuery? shownIn,
}) => showModalBottomSheet<LfgPost>(
  context: context,
  isScrollControlled: true,
  useSafeArea: true,
  showDragHandle: true,
  builder: (_) =>
      CreateLfgSheet(account: account, region: region, shownIn: shownIn),
);

/// Mode chips, slots stepper, note, party code (generated from the current
/// party with G-18, or typed) and "Đăng tin".
class CreateLfgSheet extends ConsumerStatefulWidget {
  const CreateLfgSheet({
    super.key,
    required this.account,
    required this.region,
    this.shownIn,
  });

  final Account account;
  final String region;
  final LfgQuery? shownIn;

  @override
  ConsumerState<CreateLfgSheet> createState() => _CreateLfgSheetState();
}

class _CreateLfgSheetState extends ConsumerState<CreateLfgSheet> {
  String _mode = 'competitive';
  int _slots = 1;
  final _note = TextEditingController();
  final _code = TextEditingController();
  String? _codeError;
  bool _generating = false;
  bool _posting = false;

  @override
  void dispose() {
    _note.dispose();
    _code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(CommunityStrings.createLfg, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              CommunityStrings.lfgSheetSubtitle(
                CommunityStrings.regionLabel(widget.region),
              ),
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            const SizedBox(height: 20),
            _label(CommunityStrings.mode),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final m in kLfgModes)
                  CommunityChip(
                    label: CommunityStrings.modeLabel(m),
                    selected: _mode == m,
                    onSelected: () => setState(() => _mode = m),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _label(CommunityStrings.slots),
            _SlotsStepper(
              value: _slots,
              onChanged: (v) => setState(() => _slots = v),
            ),
            const SizedBox(height: 20),
            _label(CommunityStrings.partyCode),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextField(
                    key: const ValueKey('lfg-code'),
                    controller: _code,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    autocorrect: false,
                    enableSuggestions: false,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp('[A-Za-z0-9]')),
                      const _UpperCaseFormatter(),
                    ],
                    style: theme.textTheme.titleMedium?.copyWith(
                      letterSpacing: 3,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    decoration: InputDecoration(
                      hintText: CommunityStrings.partyCodeHint,
                      counterText: '',
                      errorText: _codeError,
                      errorMaxLines: 3,
                    ),
                    onChanged: (_) {
                      if (_codeError != null) {
                        setState(() => _codeError = null);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _generating
                        ? null
                        : () => unawaited(_generate()),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    icon: _generating
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.bolt_rounded),
                    label: const Text(CommunityStrings.generateCode),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _label(CommunityStrings.note),
            TextField(
              controller: _note,
              maxLength: 140,
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: CommunityStrings.noteHint,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _posting ? null : () => unawaited(_submit()),
                icon: _posting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.campaign_rounded),
                label: const Text(CommunityStrings.postLfg),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text.toUpperCase(),
      style: ValText.label.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    ),
  );

  Future<void> _generate() async {
    setState(() {
      _generating = true;
      _codeError = null;
    });
    try {
      final code = await currentPartyCode(ref, widget.account.puuid);
      if (!mounted) return;
      if (code == null) {
        setState(() => _codeError = CommunityStrings.noParty);
      } else {
        _code.text = code;
        ScaffoldMessenger.maybeOf(context)
          ?..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(content: Text(CommunityStrings.codeGenerated)),
          );
      }
    } on Object catch (e) {
      if (mounted) {
        setState(
          () => _codeError = CommunityStrings.noPartyWithReason(
            describeError(e).message,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  Future<void> _submit() async {
    final error = validatePartyCode(_code.text);
    if (error != null) {
      setState(() => _codeError = error);
      return;
    }
    setState(() => _posting = true);
    try {
      final post = await createLfgPost(
        ref,
        puuid: widget.account.puuid,
        region: widget.region,
        mode: _mode,
        partyCode: _code.text.trim().toUpperCase(),
        slots: _slots,
        rankTier: widget.account.rankTier,
        note: _note.text,
        shownIn: widget.shownIn,
      );
      if (mounted) Navigator.of(context).pop(post);
    } on Object catch (e) {
      if (mounted) {
        setState(() => _posting = false);
        showCommunityError(context, e);
      }
    }
  }
}

class _SlotsStepper extends StatelessWidget {
  const _SlotsStepper({required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(ValRadius.small),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: CommunityStrings.decrease,
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          Expanded(
            child: Center(
              child: AnimatedCount(
                value: value,
                format: CommunityStrings.slotsWanted,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            tooltip: CommunityStrings.increase,
            onPressed: value < 4 ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded),
          ),
        ],
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  const _UpperCaseFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => newValue.copyWith(text: newValue.text.toUpperCase());
}
