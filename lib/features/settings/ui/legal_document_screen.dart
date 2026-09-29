import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../core/l10n/common_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../legal/legal_documents.dart';
import '../legal/legal_strings.dart';

/// Native reader of one [LegalDocument] (Terms, Privacy Policy, …): large
/// title, version + effective-date chips, a tappable table of contents,
/// numbered sections and selectable text. Routes `/settings/about/<id>`.
///
/// Everything is laid out eagerly (documents are a few screens long) so the
/// table of contents can jump to any section with [Scrollable.ensureVisible].
class LegalDocumentScreen extends StatefulWidget {
  const LegalDocumentScreen({super.key, required this.document});

  final LegalDocument document;

  @override
  State<LegalDocumentScreen> createState() => _LegalDocumentScreenState();
}

class _LegalDocumentScreenState extends State<LegalDocumentScreen> {
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
  void didUpdateWidget(LegalDocumentScreen oldWidget) {
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

  void _jumpTo(int index) {
    final target = _sectionKeys[index].currentContext;
    if (target == null) return;
    unawaited(
      Scrollable.ensureVisible(
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
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder<bool>(
          valueListenable: _scrolled,
          builder: (context, scrolled, child) => AnimatedOpacity(
            opacity: scrolled ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: child,
          ),
          child: Text(doc.title, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
      ),
      floatingActionButton: ValueListenableBuilder<bool>(
        valueListenable: _scrolled,
        builder: (context, scrolled, _) => AnimatedScale(
          scale: scrolled ? 1 : 0,
          duration: const Duration(milliseconds: 180),
          child: FloatingActionButton.small(
            heroTag: null,
            tooltip: LegalStrings.backToTop,
            onPressed: scrolled ? _toTop : null,
            child: const Icon(Icons.arrow_upward),
          ),
        ),
      ),
      body: Scrollbar(
        controller: _scroll,
        child: SelectionArea(
          child: SingleChildScrollView(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 96),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
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
                    const _Footer(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.document});

  final LegalDocument document;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LegalStrings.kicker,
            style: ValText.label.copyWith(color: ValColors.red),
          ),
          const SizedBox(height: 6),
          Semantics(
            header: true,
            child: Text(
              document.title,
              style: theme.textTheme.headlineMedium?.copyWith(height: 1.15),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(
                icon: Icons.sell_outlined,
                label: LegalStrings.version(document.version),
              ),
              _MetaChip(
                icon: Icons.event_outlined,
                label: LegalStrings.effectiveFrom(document.effectiveDate),
              ),
            ],
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
                LegalStrings.tocTitle,
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
                              color: ValColors.red,
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
                    style: const TextStyle(color: ValColors.red),
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
  const _Footer();

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
            '${CommonStrings.appName} · ${LegalInfo.copyrightNotice}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
