import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/settings/legal/legal_documents.dart';
import 'package:valvn/features/settings/legal/legal_strings.dart';
import 'package:valvn/features/settings/ui/legal_document_screen.dart';

void main() {
  Future<void> pumpDoc(
    WidgetTester tester,
    LegalDocument doc, {
    Size size = const Size(360, 780),
    double textScale = 1,
    ThemeData? theme,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme ?? buildDarkTheme(),
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: LegalDocumentScreen(document: doc),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows title, version, effective date and every section', (
    tester,
  ) async {
    const doc = LegalDocuments.terms;
    await pumpDoc(tester, doc);

    expect(find.text(LegalStrings.kicker), findsOneWidget);
    // Title (header) + hidden app bar title.
    expect(find.text(doc.title), findsNWidgets(2));
    expect(find.text(LegalStrings.version(doc.version)), findsOneWidget);
    expect(
      find.text(LegalStrings.effectiveFrom(doc.effectiveDate)),
      findsOneWidget,
    );
    expect(find.text(LegalStrings.tocTitle), findsOneWidget);
    for (var i = 0; i < doc.sections.length; i++) {
      // Numbered heading in the body + plain heading in the TOC.
      expect(
        find.text(numberedHeading(i, doc.sections[i]), skipOffstage: false),
        findsOneWidget,
      );
      expect(find.byKey(ValueKey('toc-$i')), findsOneWidget);
    }
    expect(find.byType(SelectionArea), findsOneWidget);
  });

  testWidgets('tapping a table-of-contents entry scrolls to that section', (
    tester,
  ) async {
    const doc = LegalDocuments.privacy;
    await pumpDoc(tester, doc);
    final last = doc.sections.length - 1;
    final heading = find.text(numberedHeading(last, doc.sections[last]));
    final viewportHeight = tester.view.physicalSize.height;

    expect(tester.getTopLeft(heading).dy, greaterThan(viewportHeight));

    await tester.ensureVisible(find.byKey(ValueKey('toc-$last')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(ValueKey('toc-$last')));
    await tester.pumpAndSettle();

    final top = tester.getTopLeft(heading).dy;
    expect(top, greaterThanOrEqualTo(0));
    expect(top, lessThan(viewportHeight));
    // The "back to top" button appears once scrolled and returns to the top.
    await tester.tap(find.byTooltip(LegalStrings.backToTop));
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.text(LegalStrings.kicker)).dy, lessThan(200));
  });

  for (final doc in LegalDocuments.all) {
    testWidgets('${doc.id}: no overflow at 360dp with text scale 2.0', (
      tester,
    ) async {
      await pumpDoc(tester, doc, textScale: 2);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      await tester.fling(
        find.byType(SingleChildScrollView),
        const Offset(0, -20000),
        4000,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('renders in the light theme', (tester) async {
    await pumpDoc(tester, LegalDocuments.community, theme: buildLightTheme());
    expect(find.text(LegalDocuments.community.title), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
