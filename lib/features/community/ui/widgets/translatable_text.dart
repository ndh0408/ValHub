import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/ui/adaptive.dart';
import '../../community_strings.dart';
import '../../data/community_translator.dart';
import '../../providers/community_providers.dart';
import '../../providers/translation_providers.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// User-authored text with an on-device "Dịch bằng Google" button when it
/// is written in another language than the app's. The first translation of
/// a language pair asks for the model download (with its size); afterwards
/// it works offline. The original stays one tap away.
class TranslatableText extends ConsumerStatefulWidget {
  const TranslatableText(
    this.text, {
    super.key,
    required this.language,
    this.style,
    this.maxLines,
    this.overflow,
  });

  final String text;

  /// Language the text is written in (community code); `null` = unknown, no
  /// button.
  final String? language;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  @override
  ConsumerState<TranslatableText> createState() => _TranslatableTextState();
}

enum _Phase { idle, downloading, translating }

class _TranslatableTextState extends ConsumerState<TranslatableText> {
  _Phase _phase = _Phase.idle;
  String? _translated;
  bool _showTranslated = true;

  @override
  void didUpdateWidget(TranslatableText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.language != widget.language) {
      _translated = null;
      _phase = _Phase.idle;
      _showTranslated = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appLanguage = ref.watch(communityAppLanguageProvider);
    final translator = ref.watch(communityTranslatorProvider);
    final source = widget.language;
    final offer =
        translator.isSupported &&
        source != null &&
        translator.supportsLanguage(source) &&
        translator.supportsLanguage(appLanguage) &&
        shouldOfferTranslation(widget.text, source, appLanguage);
    final cached = offer
        ? ref.watch(
            translationCacheProvider.select(
              (m) => m[translationKey(source, appLanguage, widget.text)],
            ),
          )
        : null;
    final translated = _translated ?? cached;
    final shown = translated != null && _showTranslated
        ? translated
        : widget.text;
    final theme = Theme.of(context);
    final text = Text(
      shown,
      maxLines: widget.maxLines,
      overflow: widget.overflow,
      style: widget.style,
    );
    if (!offer) return text;
    final muted = theme.colorScheme.onSurfaceVariant;
    final busy = _phase != _Phase.idle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        text,
        const SizedBox(height: 4),
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          children: [
            if (translated == null)
              TextButton.icon(
                key: const ValueKey('translate-button'),
                onPressed: busy
                    ? null
                    : () => unawaited(_translate(source, appLanguage)),
                style: _compact,
                icon: busy
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.translate_rounded, size: 16),
                label: Text(switch (_phase) {
                  _Phase.downloading => context.l10n.communityDownloadingModels,
                  _Phase.translating => context.l10n.communityTranslating,
                  _Phase.idle => context.l10n.communityTranslate,
                }),
              )
            else ...[
              InkWell(
                key: const ValueKey('translate-attribution'),
                onTap: () => unawaited(_showDisclaimer()),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Text(
                    context.l10n.communityTranslatedByGoogle,
                    style: theme.textTheme.labelSmall?.copyWith(color: muted),
                  ),
                ),
              ),
              TextButton(
                key: const ValueKey('translate-toggle'),
                onPressed: () =>
                    setState(() => _showTranslated = !_showTranslated),
                style: _compact,
                child: Text(
                  _showTranslated
                      ? context.l10n.communityShowOriginal
                      : context.l10n.communityShowTranslation,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  static final ButtonStyle _compact = TextButton.styleFrom(
    minimumSize: const Size(0, 32),
    padding: const EdgeInsets.symmetric(horizontal: 8),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    visualDensity: VisualDensity.compact,
  );

  Future<void> _translate(String source, String target) async {
    final translator = ref.read(communityTranslatorProvider);
    try {
      final missing = <String>[
        for (final code in {source, target})
          if (!await translator.isDownloaded(code)) code,
      ];
      if (!mounted) return;
      if (missing.isNotEmpty) {
        final ok = await showConfirmDialog(
          context,
          title: CommunityStrings.translateDownloadTitle,
          message: CommunityStrings.translateDownloadBody(
            CommunityStrings.languageLabel(source),
            CommunityStrings.languageLabel(target),
            CommunityStrings.modelSize(kTranslationModelMb * missing.length),
          ),
          confirmLabel: CommunityStrings.download,
          icon: Icons.download_rounded,
        );
        if (!ok || !mounted) return;
        setState(() => _phase = _Phase.downloading);
        for (final code in missing) {
          await translator.download(code);
        }
        if (!mounted) return;
      }
      setState(() => _phase = _Phase.translating);
      final result = await translator.translate(
        widget.text,
        from: source,
        to: target,
      );
      if (!mounted) return;
      ref
          .read(translationCacheProvider.notifier)
          .put(translationKey(source, target, widget.text), result);
      setState(() {
        _translated = result;
        _showTranslated = true;
        _phase = _Phase.idle;
      });
    } on Object {
      if (!mounted) return;
      setState(() => _phase = _Phase.idle);
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text(CommunityStrings.translateFailed)),
        );
    }
  }

  /// Google's required notice about machine translations.
  Future<void> _showDisclaimer() => showAdaptiveDialog<void>(
    context: context,
    builder: (context) => AlertDialog.adaptive(
      title: Text(context.l10n.communityGoogleDisclaimerTitle),
      content: Text(context.l10n.communityGoogleDisclaimer),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(context.l10n.commonClose),
        ),
      ],
    ),
  );
}
