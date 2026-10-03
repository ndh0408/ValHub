import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/accounts/account.dart';
import '../../../core/accounts/account_providers.dart';
import '../../../core/accounts/account_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/util/format.dart';
import '../data/community_api.dart';
import '../data/community_exception.dart';
import '../data/community_models.dart';
import '../data/compose_draft.dart';
import '../data/image_source.dart';
import '../providers/community_providers.dart';
import '../providers/feed_providers.dart';
import 'feed/offers_grid.dart';
import 'consent/consent_sheet.dart';
import 'widgets/community_widgets.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Maximum post length (server limit).
const kMaxPostLength = 1000;

/// Maximum images per post.
const kMaxPostImages = 4;

/// Validation of the composer (pure, unit-tested).
enum ComposeProblem { empty, tooLong }

ComposeProblem? validateCompose({
  required String body,
  required int images,
  required bool hasAttachment,
}) {
  if (body.characters.length > kMaxPostLength) return ComposeProblem.tooLong;
  if (body.trim().isEmpty && images == 0 && !hasAttachment) {
    return ComposeProblem.empty;
  }
  return null;
}

/// "Bài viết mới": text with a live counter, up to 4 images (resized by the
/// picker, uploaded first) and an optional store / Night Market attachment.
class ComposeScreen extends ConsumerStatefulWidget {
  const ComposeScreen({super.key, this.draft});

  final ComposeDraft? draft;

  @override
  ConsumerState<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends ConsumerState<ComposeScreen> {
  late final String? _draftOwner = ref.read(activePuuidProvider);

  @override
  Widget build(BuildContext context) {
    final puuid = ref.watch(activePuuidProvider);
    return _ComposerAccountScreen(
      key: ValueKey(puuid),
      draft: puuid == _draftOwner ? widget.draft : null,
    );
  }
}

/// Dispose pending UI callbacks and private edits when the account changes.
/// A store attachment passed by the launcher belongs only to its account.
class _ComposerAccountScreen extends ConsumerStatefulWidget {
  const _ComposerAccountScreen({super.key, this.draft});

  final ComposeDraft? draft;

  @override
  ConsumerState<_ComposerAccountScreen> createState() =>
      _ComposerAccountScreenState();
}

class _ComposerAccountScreenState
    extends ConsumerState<_ComposerAccountScreen> {
  late final _text = TextEditingController(text: widget.draft?.body ?? '');
  final List<PickedImage> _images = [];
  late ComposeDraft? _draft = widget.draft;
  bool _busy = false;

  bool get _hasAttachment => _draft?.hasAttachment ?? false;

  bool get _dirty =>
      _text.text.trim().isNotEmpty || _images.isNotEmpty || _hasAttachment;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final account = ref.watch(activeAccountProvider);
    final problem = validateCompose(
      body: _text.text,
      images: _images.length,
      hasAttachment: _hasAttachment,
    );
    final canPost = account != null && problem == null && !_busy;
    return PopScope(
      canPop: !_dirty || _busy,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_confirmDiscard());
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: context.l10n.commonClose,
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          title: Text(context.l10n.communityComposerTitle),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: FilledButton(
                style: FilledButton.styleFrom(
                  minimumSize: const Size(72, 40),
                  shape: const StadiumBorder(),
                ),
                onPressed: canPost ? () => unawaited(_publish(account)) : null,
                child: _busy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(context.l10n.communityPublish),
              ),
            ),
          ],
        ),
        body: account == null
            ? EmptyView(
                message: context.l10n.commonErrorNoAccount,
                icon: Icons.person_off_outlined,
              )
            : Column(
                children: [
                  Expanded(child: _editor(account, problem)),
                  _toolbar(),
                ],
              ),
      ),
    );
  }

  Widget _editor(Account account, ComposeProblem? problem) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    final length = _text.text.characters.length;
    final draft = _draft;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        Row(
          children: [
            AccountAvatar(account: account, size: 40, circle: true),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                account.riotId,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _text,
          autofocus: draft == null || !draft.hasAttachment,
          minLines: 4,
          maxLines: null,
          maxLengthEnforcement: MaxLengthEnforcement.none,
          textCapitalization: TextCapitalization.sentences,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
          decoration: InputDecoration(
            hintText: context.l10n.communityComposerHint,
            filled: false,
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Text(
            context.l10n.communityCharCount(
              formatNumber(length),
              formatNumber(kMaxPostLength),
            ),
            style: theme.textTheme.labelSmall?.copyWith(
              color: problem == ComposeProblem.tooLong ? ValColors.red : muted,
              fontWeight: FontWeight.w600,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
        if (problem == ComposeProblem.tooLong)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              context.l10n.communityTooLong(kMaxPostLength),
              style: theme.textTheme.bodySmall?.copyWith(color: ValColors.red),
            ),
          ),
        if (draft != null && draft.hasAttachment) ...[
          const SizedBox(height: 16),
          Stack(
            children: [
              OffersGrid(
                kind: draft.kind,
                payload: draft.payload!,
                interactive: false,
              ),
              Positioned(
                top: 4,
                right: 4,
                child: _RemoveButton(
                  tooltip: context.l10n.communityRemoveAttachment,
                  onTap: () => setState(() => _draft = null),
                ),
              ),
            ],
          ),
        ],
        if (_images.isNotEmpty) ...[
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var i = 0; i < _images.length; i++)
                _Thumb(
                  key: ObjectKey(_images[i]),
                  image: _images[i],
                  onRemove: () => setState(() => _images.removeAt(i)),
                ),
            ],
          ),
        ],
        if (problem == ComposeProblem.empty && _text.text.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              context.l10n.communityEmptyPost,
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
          ),
      ],
    );
  }

  Widget _toolbar() {
    final theme = Theme.of(context);
    final full = _images.length >= kMaxPostImages;
    return Material(
      color: theme.colorScheme.surfaceContainerLow,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: full || _busy ? null : () => unawaited(_pick()),
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(context.l10n.communityAddPhotos),
              ),
              const Spacer(),
              if (_busy)
                Text(
                  context.l10n.communityPublishing,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                Text(
                  context.l10n.communityPhotoCount(
                    _images.length,
                    kMaxPostImages,
                  ),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pick() async {
    if (!mounted) return;
    final l10n = context.l10n;
    final remaining = kMaxPostImages - _images.length;
    if (remaining <= 0) return;
    try {
      final picked = await ref
          .read(communityImagePickerProvider)
          .pick(limit: remaining);
      if (!mounted || picked.isEmpty) return;
      final ok = <PickedImage>[];
      Object? problem;
      for (final p in picked.take(remaining)) {
        if (imageMimeType(p.bytes) == null) {
          problem = const CommunityException(CommunityException.imageType);
        } else if (p.bytes.length > CommunityApi.maxMediaBytes) {
          problem = const CommunityException(CommunityException.imageTooLarge);
        } else {
          ok.add(p);
        }
      }
      setState(() => _images.addAll(ok));
      if (problem != null) showCommunityError(context, problem);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.maybeOf(context)
          ?..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(l10n.communityErrorPickImage)));
      }
    }
  }

  Future<void> _publish(Account account) async {
    if (!mounted || _busy) return;
    final l10n = context.l10n;
    FocusScope.of(context).unfocus();
    // Posting needs a community session: ask (once) before any network call.
    if (!await ensureCommunityConsent(context, account, askAgain: true)) return;
    if (!mounted || ref.read(activePuuidProvider) != account.puuid) return;
    setState(() => _busy = true);
    final api = ref.read(communityApiProvider);
    final draft = _draft;
    try {
      final post = await publishPost(
        api,
        account.puuid,
        kind: draft?.hasAttachment ?? false ? draft!.kind : PostKind.text,
        body: _text.text,
        payload: draft?.hasAttachment ?? false ? draft!.payload : null,
        language: ref.read(communityAppLanguageProvider),
        uploads: [
          for (final img in _images)
            () => api.uploadMedia(account.puuid, img.bytes),
        ],
        canContinue: () =>
            mounted && ref.read(activePuuidProvider) == account.puuid,
      );
      if (!mounted || ref.read(activePuuidProvider) != account.puuid) return;
      prependToFeed(ref, account.puuid, post);
      final messenger = ScaffoldMessenger.maybeOf(context);
      setState(() {
        _busy = false;
        _images.clear();
        _text.clear();
        _draft = null;
      });
      Navigator.of(context).pop(post);
      messenger
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.communityPosted)));
    } on Object catch (e) {
      if (!mounted || ref.read(activePuuidProvider) != account.puuid) return;
      setState(() => _busy = false);
      showCommunityError(context, e);
    }
  }

  Future<void> _confirmDiscard() async {
    if (!mounted) return;
    final l10n = context.l10n;
    final discard = await confirmCommunityAction(
      context,
      title: l10n.communityDiscardTitle,
      body: l10n.communityDiscardBody,
      confirmLabel: l10n.communityDiscard,
    );
    if (!discard || !mounted) return;
    setState(() {
      _images.clear();
      _text.clear();
      _draft = null;
    });
    Navigator.of(context).pop();
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb({super.key, required this.image, required this.onRemove});

  final PickedImage image;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final dpr = MediaQuery.devicePixelRatioOf(context);
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(ValRadius.small),
              child: Image.memory(
                image.bytes,
                fit: BoxFit.cover,
                cacheWidth: (96 * dpr).round(),
                gaplessPlayback: true,
                errorBuilder: (context, _, _) => ColoredBox(
                  color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  child: const Icon(Icons.broken_image_outlined),
                ),
              ),
            ),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: _RemoveButton(
              tooltip: context.l10n.communityRemovePhoto,
              onTap: onRemove,
            ),
          ),
        ],
      ),
    );
  }
}

class _RemoveButton extends StatelessWidget {
  const _RemoveButton({required this.tooltip, required this.onTap});

  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.black.withValues(alpha: 0.6),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(5),
            child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
