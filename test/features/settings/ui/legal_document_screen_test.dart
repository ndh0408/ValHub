import 'dart:convert';
import 'dart:io';

import 'package:valvn/core/l10n/l10n.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:valvn/core/theme/app_theme.dart';
import 'package:valvn/features/settings/legal/legal_documents.dart';
import 'package:valvn/features/settings/legal/legal_strings.dart';
import 'package:valvn/features/settings/legal/legal_providers.dart';
import 'package:valvn/features/settings/ui/legal_document_screen.dart';

import '../legal/legal_test_documents.dart';

void main() {
  Future<void> pumpDoc(
    WidgetTester tester,
    LegalDocumentRef doc, {
    Size size = const Size(360, 780),
    double textScale = 1,
    ThemeData? theme,
    LegalRepository? repository,
    LegalDocument? documentOverride,
    TextDirection direction = TextDirection.ltr,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          if (repository != null)
            legalRepositoryProvider.overrideWithValue(repository),
          if (documentOverride != null)
            legalDocumentProvider((document: doc, locale: 'vi'))
                .overrideWith((ref) async => documentOverride),
        ],
        child: MaterialApp(
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: const [Locale('vi')],
          theme: theme ?? buildDarkTheme(),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context)
                .copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: Directionality(
            textDirection: direction,
            child: LegalDocumentScreen(document: doc),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows title, version, effective date and every section', (
    tester,
  ) async {
    final doc = legalTestDocument(LegalDocuments.terms);
    await pumpDoc(tester, LegalDocuments.terms);

    // Large title (the bar title only appears once scrolled).
    expect(find.text(doc.title), findsOneWidget);
    expect(find.text(doc.summary), findsOneWidget);
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
    final doc = legalTestDocument(LegalDocuments.privacy);
    await pumpDoc(tester, LegalDocuments.privacy);
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
    expect(tester.getTopLeft(find.text(doc.title).first).dy, lessThan(200));
  });

  for (final doc in LegalDocuments.all) {
    testWidgets('${doc.id}: no overflow at 360dp with text scale 2.0', (
      tester,
    ) async {
      await pumpDoc(tester, doc, textScale: 2);
      expect(tester.takeException(), isNull);
      await tester.pumpAndSettle();
      await tester.fling(
        find.byType(CustomScrollView),
        const Offset(0, -20000),
        4000,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'invalid bundled content shows retry and never an empty legal page',
    (tester) async {
      var failed = true;
      final repository = LegalRepository((path) async {
        if (failed) return '{invalid';
        return File(path).readAsStringSync();
      });
      await pumpDoc(tester, LegalDocuments.terms, repository: repository);
      expect(find.byType(SelectionArea), findsNothing);
      expect(
        find.text(
          lookupAppLocalizations(const Locale('vi')).legalContentUnavailable,
        ),
        findsOneWidget,
      );
      expect(
        find.text(lookupAppLocalizations(const Locale('vi')).commonRetry),
        findsOneWidget,
      );
      failed = false;
      await tester.tap(
        find.text(lookupAppLocalizations(const Locale('vi')).commonRetry),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SelectionArea), findsOneWidget);
      expect(
        find.text(legalTestDocument(LegalDocuments.terms).title),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'fallback displays actual source language without claiming approval',
    (tester) async {
      final json = jsonDecode(
        File('assets/legal/vi/notice.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      json['locale'] =
          'en'; // Fixture tests the banner, not translation quality.
      await pumpDoc(
        tester,
        LegalDocuments.notice,
        documentOverride: LegalDocument.fromJson(json),
      );
      expect(
        find.text(
          lookupAppLocalizations(const Locale('vi'))
              .legalDocumentLanguage('English'),
        ),
        findsOneWidget,
      );
    },
  );

  for (final width in [320.0, 393.0, 600.0]) {
    for (final direction in TextDirection.values) {
      testWidgets(
        'privacy $width dp / 200% / $direction fits and preserves all sections',
        (tester) async {
          await pumpDoc(
            tester,
            LegalDocuments.privacy,
            size: Size(width, 780),
            textScale: 2,
            direction: direction,
          );
          final doc = legalTestDocument(LegalDocuments.privacy);
          for (var i = 0; i < doc.sections.length; i++) {
            expect(find.byKey(ValueKey('toc-$i')), findsOneWidget);
          }
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('renders in the light theme', (tester) async {
    await pumpDoc(tester, LegalDocuments.community, theme: buildLightTheme());
    expect(
      find.text(legalTestDocument(LegalDocuments.community).title),
      findsWidgets,
    );
    expect(tester.takeException(), isNull);
  });
}
