import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:flutter/rendering.dart' show RenderAbstractViewport;
import 'package:material_ui/material_ui.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/ui/sub_page.dart';
import '../../../core/ui/empty_view.dart';
import '../../../core/ui/skeleton.dart';
import '../../../core/l10n/app_locale.dart';
import '../legal/legal_documents.dart';
import '../legal/legal_providers.dart';

import 'package:valvn/core/l10n/l10n.dart';

/// Native reader of one [LegalDocument] (Terms, Privacy Policy, …) on the
/// shared sub-page chrome: large title that hands over to the bar, the
/// one-line summary, version + effective-date chips, a tappable table of
/// contents, numbered sections and selectable text, and a "Về đầu trang"
/// button once scrolled. Routes `/settings/about/<id>`.
///
/// Everything is laid out eagerly (documents are a few screens long) so the
/// table of contents can jump to any section with [Scrollable.ensureVisible].
class LegalDocumentScreen extends ConsumerWidget {
  const LegalDocumentScreen({super.key, required this.document});

  final LegalDocumentRef document;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final request = (document: document, locale: context.l10n.localeName);
    final value = ref.watch(legalDocumentProvider(request));
    if (value.hasValue && !value.hasError) {
      return _LegalDocumentReader(
        key: ValueKey(request),
        document: value.requireValue,
      );
    }
    return SubPageScaffold(
      title: context.l10n.legalLegalHeader,
      slivers: [
        SliverToBoxAdapter(
          child: value.hasError
              ? EmptyView(
                  message: context.l10n.legalContentUnavailable,
                  icon: Icons.article_outlined,
                  action: OutlinedButton.icon(
                    onPressed: () =>
                        ref.invalidate(legalDocumentProvider(request)),
                    icon: const Icon(Icons.refresh),
                    label: Text(context.l10n.commonRetry),
                  ),
                )
              : const SkeletonList(),
        ),
      ],
    );
  }
}

class _LegalDocumentReader extends StatefulWidget {
  const _LegalDocumentReader({super.key, required this.document});

  final LegalDocument document;

  @override
  State<_LegalDocumentReader> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<_LegalDocumentReader> {
  final _scroll = ScrollController();
  final _scrolled = ValueNotifier<bool>(false);
  late List<GlobalKey> _sectionKeys = _keysFor(widget.document);

  static List<GlobalKey> _keysFor(LegalDocument doc) => [
    for (var i = 0; i < doc.sections.length; i++)
      GlobalKey(debugLabel: '${doc.id}-section-$i'),
  ];

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(_LegalDocumentReader oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.document != widget.document) {
      _sectionKeys = _keysFor(widget.document);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    _scrolled.dispose();
    super.dispose();
  }

  void _onScroll() => _scrolled.value = _scroll.offset > 96;

  /// Scrolls [index]'s heading just below the pinned bar (a plain
  /// `Scrollable.ensureVisible` would tuck it under the bar).
  void _jumpTo(int index) {
    final box = _sectionKeys[index].currentContext?.findRenderObject();
    if (box == null || !_scroll.hasClients) return;
    final viewport = RenderAbstractViewport.maybeOf(box);
    if (viewport == null) return;
    final bar = kToolbarHeight + MediaQuery.paddingOf(context).top;
    final position = _scroll.position;
    final target = (viewport.getOffsetToReveal(box, 0).offset - bar - 8)
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    unawaited(
      _scroll.animateTo(
        target,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      ),
    );
  }

  void _toTop() => unawaited(
    _scroll.animateTo(
      0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    return SubPageScaffold(
      title: doc.title,
      subtitle: doc.summary,
      controller: _scroll,
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _scrolled,
        builder: (context, scrolled, _) => AnimatedScale(
          scale: scrolled ? 1 : 0,
          duration: ValMotion.fast,
          child: FloatingActionButton.small(
            heroTag: null,
            tooltip: context.l10n.legalBackToTop,
            onPressed: scrolled ? _toTop : null,
            child: const Icon(Icons.arrow_upward),
          ),
        ),
      ),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 72),
          sliver: SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: SelectionArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (doc.locale != context.l10n.localeName)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Text(
                            context.l10n.legalDocumentLanguage(
                              AppLocale.values
                                  .where((l) => l.arbCode == doc.locale)
                                  .first
                                  .nativeName,
                            ),
                          ),
                        ),
                      _Header(document: doc),
                      for (final block in doc.preamble) _Block(block: block),
                      const SizedBox(height: 8),
                      _TableOfContents(document: doc, onTap: _jumpTo),
                      const SizedBox(height: 8),
                      for (var i = 0; i < doc.sections.length; i++)
                        _Section(
                          key: _sectionKeys[i],
                          index: i,
                          section: doc.sections[i],
                        ),
                      _Footer(copyright: doc.copyright),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Version and effective-date chips under the title.
class _Header extends StatelessWidget {
  const _Header({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _MetaChip(
            icon: Icons.sell_outlined,
            label: context.l10n.legalVersion(document.version),
          ),
          _MetaChip(
            icon: Icons.event_outlined,
            label: context.l10n.legalEffectiveFrom(document.effectiveDate),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(ValRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: scheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TableOfContents extends StatelessWidget {
  const _TableOfContents({required this.document, required this.onTap});

  final LegalDocument document;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Material(
      color: scheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ValRadius.card),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                context.l10n.legalTocTitle,
                style: ValText.label.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            for (var i = 0; i < document.sections.length; i++)
              InkWell(
                key: ValueKey('toc-$i'),
                onTap: () => onTap(i),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 44),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 32,
                          child: Text(
                            '${i + 1}.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: legibleAccent(context, ValColors.red),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            document.sections[i].heading,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({super.key, required this.index, required this.section});

  final int index;
  final LegalSection section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            header: true,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '${index + 1}. ',
                    style: TextStyle(
                      color: legibleAccent(context, ValColors.red),
                    ),
                  ),
                  TextSpan(text: section.heading),
                ],
              ),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
          ),
          const SizedBox(height: 10),
          for (final block in section.blocks) _Block(block: block),
        ],
      ),
    );
  }
}

/// One paragraph / sub-heading / bullet list / callout.
class _Block extends StatelessWidget {
  const _Block({required this.block});

  final LegalBlock block;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final body = theme.textTheme.bodyLarge?.copyWith(height: 1.6);
    return switch (block) {
      LegalParagraph(:final text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(text, style: body),
      ),
      LegalSubheading(:final text) => Padding(
        padding: const EdgeInsets.only(top: 4, bottom: 8),
        child: Text(
          text,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      LegalCallout(:final text) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: ValColors.red.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(ValRadius.small),
          border: const BorderDirectional(
            start: BorderSide(color: ValColors.red, width: 3),
          ),
        ),
        child: Text(
          text,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
        ),
      ),
      LegalList(:final items) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.only(
                        top: 10,
                        end: 12,
                        start: 2,
                      ),
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: scheme.onSurfaceVariant,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            if (item.lead != null)
                              TextSpan(
                                text: '${item.lead} ',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            TextSpan(text: item.text),
                          ],
                        ),
                        style: body,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    };
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.copyright});

  final String copyright;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Divider(color: valColorsOf(context).hairline),
          const SizedBox(height: 12),
          Text(
            '${context.l10n.commonAppName} · $copyright',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
