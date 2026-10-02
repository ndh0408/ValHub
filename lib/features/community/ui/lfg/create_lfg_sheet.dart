import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/accounts/account.dart';
import '../../../../core/content/content_db.dart';
import '../../../../core/content/content_repository.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/ui/rank_badge.dart';
import '../../../../core/util/clock.dart';
import '../../community_strings.dart';
import '../../data/community_models.dart';
import '../../data/lfg_sync.dart';
import '../../providers/lfg_providers.dart';
import '../widgets/community_widgets.dart';
import 'lfg_bits.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Validates a typed party code: `null` when valid, else the message.
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

/// Mode, rank range, roles, mic, language, party size (from the live
/// party), open slots, note and an optional party code (generated from the
/// game party on "Đăng tin" when empty).
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
  int _partySize = 1;
  int _slots = 1;
  int? _rankMin;
  int? _rankMax;
  final Set<String> _roles = {};
  bool _mic = false;

  /// Picked language; `null` = the app's current language.
  String? _languageChoice;

  String get _language => _languageChoice ?? communityAppLanguage(context);
  bool _sizeFromGame = false;
  final _note = TextEditingController();
  final _code = TextEditingController();
  String? _codeError;
  String? _formError;
  bool _posting = false;

  @override
  void initState() {
    super.initState();
    unawaited(_prefillPartySize());
  }

  /// Party size from the live party (G-12/G-13), when the game runs.
  Future<void> _prefillPartySize() async {
    final party = await readLiveParty(ref, widget.account.puuid);
    if (!mounted || party == null) return;
    setState(() {
      _partySize = party.size.clamp(1, 4);
      _slots = _slots.clamp(1, 5 - _partySize);
      _sizeFromGame = true;
      final code = party.inviteCode;
      if (code != null && _code.text.isEmpty) _code.text = code;
    });
  }

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
    final db = ref.watch(contentProvider).value ?? ContentDb.empty();
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final suggestion = suggestedRankRange(lfgViewerRank(widget.account));
    final maxSlots = (5 - _partySize).clamp(1, 4);
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.communityCreateLfg,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              context.l10n.communityLfgSheetSubtitle(
                CommunityStrings.regionLabel(widget.region),
              ),
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            const SizedBox(height: 20),
            _label(context.l10n.communityMode),
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
            _label(context.l10n.communityRankRange),
            Row(
              children: [
                Expanded(
                  child: _RankButton(
                    key: const ValueKey('rank-min'),
                    caption: context.l10n.communityRankFrom,
                    tier: _rankMin,
                    onTap: () => unawaited(_pickRank(db, min: true)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _RankButton(
                    key: const ValueKey('rank-max'),
                    caption: context.l10n.communityRankTo,
                    tier: _rankMax,
                    onTap: () => unawaited(_pickRank(db, min: false)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                CommunityChip(
                  label: context.l10n.communityAnyRank,
                  selected: _rankMin == null && _rankMax == null,
                  onSelected: () => setState(() {
                    _rankMin = null;
                    _rankMax = null;
                  }),
                ),
                if (suggestion != null)
                  CommunityChip(
                    key: const ValueKey('rank-suggest'),
                    icon: Icons.auto_awesome_rounded,
                    label: rankRangeLabel(
                      context.l10n,
                      db,
                      suggestion.min,
                      suggestion.max,
                    ),
                    selected:
                        _rankMin == suggestion.min &&
                        _rankMax == suggestion.max,
                    onSelected: () => setState(() {
                      _rankMin = suggestion.min;
                      _rankMax = suggestion.max;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            _label(context.l10n.communityRoles),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final r in kLfgRoles)
                  CommunityChip(
                    label: lfgRoleLabel(context.l10n, r),
                    selected: _roles.contains(r),
                    onSelected: () => setState(() {
                      if (!_roles.remove(r) && _roles.length < 4) _roles.add(r);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _mic,
              onChanged: (v) => setState(() => _mic = v),
              secondary: const Icon(Icons.mic_rounded),
              title: Text(context.l10n.communityMic),
            ),
            _label(context.l10n.communityLanguage),
            Material(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(ValRadius.small),
              child: ListTile(
                key: const ValueKey('lfg-language'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(ValRadius.small),
                ),
                leading: const Icon(Icons.translate_rounded),
                title: Text(CommunityStrings.languageLabel(_language)),
                trailing: const Icon(Icons.expand_more_rounded),
                onTap: () => unawaited(_pickLanguage()),
              ),
            ),
            const SizedBox(height: 20),
            _label(context.l10n.communityPartySize),
            _Stepper(
              key: const ValueKey('party-size'),
              value: _partySize,
              min: 1,
              max: 4,
              format: context.l10n.communityPartySizeValue,
              onChanged: (v) => setState(() {
                _partySize = v;
                _slots = _slots.clamp(1, 5 - v);
                _sizeFromGame = false;
              }),
            ),
            if (_sizeFromGame)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  context.l10n.communityPartySizeFromGame,
                  style: theme.textTheme.labelSmall?.copyWith(color: muted),
                ),
              ),
            const SizedBox(height: 16),
            _label(context.l10n.communitySlots),
            _Stepper(
              key: const ValueKey('slots'),
              value: _slots,
              min: 1,
              max: maxSlots,
              format: context.l10n.communitySlotsWanted,
              onChanged: (v) => setState(() => _slots = v),
            ),
            const SizedBox(height: 20),
            _label(context.l10n.communityPartyCode),
            TextField(
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
              style: theme.textTheme.titleMedium?.copyWith(letterSpacing: 3),
              decoration: InputDecoration(
                hintText: context.l10n.communityPartyCodeHint,
                counterText: '',
                helperText: context.l10n.communityCodeAuto,
                helperMaxLines: 3,
                errorText: _codeError,
                errorMaxLines: 3,
              ),
              onChanged: (_) {
                if (_codeError != null) setState(() => _codeError = null);
              },
            ),
            const SizedBox(height: 12),
            _label(context.l10n.communityNote),
            TextField(
              controller: _note,
              maxLength: 140,
              minLines: 2,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: context.l10n.communityNoteHint,
              ),
            ),
            if (_formError != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _formError!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            const SizedBox(height: 8),
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
                label: Text(context.l10n.communityPostLfg),
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

  Future<void> _pickLanguage() async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, controller) => ListView(
          controller: controller,
          children: [
            for (final code in [kLfgAnyLanguage, ...kLfgLanguages])
              ListTile(
                key: ValueKey('lang-$code'),
                title: Text(CommunityStrings.languageLabel(code)),
                trailing: code == _language
                    ? const Icon(Icons.check_rounded)
                    : null,
                onTap: () => Navigator.of(context).pop(code),
              ),
          ],
        ),
      ),
    );
    if (picked != null && mounted) setState(() => _languageChoice = picked);
  }

  Future<void> _pickRank(ContentDb db, {required bool min}) async {
    final tiers = <int>{
      for (final t
          in db.tierTableForSeason(null)?.tiers ?? const <CompetitiveTier>[])
        if (t.tier > 2 && !t.isUnranked) t.tier,
    }.toList()..sort();
    final picked = await showModalBottomSheet<int>(
      context: context,
      useSafeArea: true,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        builder: (context, controller) => ListView(
          controller: controller,
          children: [
            ListTile(
              leading: const Icon(Icons.all_inclusive_rounded),
              title: const Text(CommunityStrings.anyRank),
              onTap: () => Navigator.of(context).pop(0),
            ),
            for (final t in tiers)
              ListTile(
                key: ValueKey('tier-$t'),
                title: RankBadge(tier: t, size: 28),
                onTap: () => Navigator.of(context).pop(t),
              ),
          ],
        ),
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      final v = picked == 0 ? null : picked;
      if (min) {
        _rankMin = v;
      } else {
        _rankMax = v;
      }
      _formError = null;
    });
  }

  Future<void> _submit() async {
    final problem = validateLfgForm(
      rankMin: _rankMin,
      rankMax: _rankMax,
      partySize: _partySize,
      slots: _slots,
      code: _code.text,
      mode: _mode,
    );
    if (problem != null) {
      setState(() {
        switch (problem) {
          case LfgProblem.rankRange:
            _formError = context.l10n.communityRankRangeInvalid;
          case LfgProblem.tooManyPlayers:
            _formError = context.l10n.communitySlotsTooMany(5 - _partySize);
          case LfgProblem.codeInvalid:
            _codeError = context.l10n.communityCodeInvalid;
        }
      });
      return;
    }
    setState(() {
      _posting = true;
      _formError = null;
      _codeError = null;
    });
    try {
      final post = await createLfgPost(
        ref,
        puuid: widget.account.puuid,
        region: widget.region,
        mode: _mode,
        partyCode: _code.text,
        slots: _slots,
        rankTier: widget.account.rankTier,
        note: _note.text,
        rankMin: _rankMin,
        rankMax: _rankMax,
        roles: [
          for (final r in kLfgRoles)
            if (_roles.contains(r)) r,
        ],
        mic: _mic,
        language: _language,
        partySize: _partySize,
        shownIn: widget.shownIn,
        now: ref.read(clockProvider).now(),
      );
      if (mounted) Navigator.of(context).pop(post);
    } on LfgCodeUnavailable {
      if (mounted) {
        setState(() {
          _posting = false;
          _codeError = CommunityStrings.codeAutoFailed;
        });
      }
    } on Object catch (e) {
      if (mounted) {
        setState(() => _posting = false);
        showCommunityError(context, e);
      }
    }
  }
}

class _RankButton extends StatelessWidget {
  const _RankButton({
    super.key,
    required this.caption,
    required this.tier,
    required this.onTap,
  });

  final String caption;
  final int? tier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = tier;
    return Material(
      color: theme.colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(ValRadius.small),
      child: InkWell(
        borderRadius: BorderRadius.circular(ValRadius.small),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                caption,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              if (t == null)
                Text(
                  context.l10n.communityAnyRank,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                )
              else
                RankBadge(tier: t, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.format,
    required this.onChanged,
  });

  final int value;
  final int min;
  final int max;
  final String Function(int) format;
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
            tooltip: context.l10n.communityDecrease,
            onPressed: value > min ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded),
          ),
          Expanded(
            child: Center(
              child: AnimatedCount(
                value: value,
                format: format,
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),
          IconButton(
            tooltip: context.l10n.communityIncrease,
            onPressed: value < max ? () => onChanged(value + 1) : null,
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
