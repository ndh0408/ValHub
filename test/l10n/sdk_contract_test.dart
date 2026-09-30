import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// SDK facts the i18n design relies on (docs/design/I18N.md 18.4), pinned so a
/// Flutter upgrade that changes them fails here and not in a user's hands.
void main() {
  group('V14: SemanticsService.sendAnnouncement', () {
    testWidgets('announces a message for a view with a text direction', (
      tester,
    ) async {
      final sent = <Object?>[];
      final messenger = tester.binding.defaultBinaryMessenger;
      messenger.setMockDecodedMessageHandler<dynamic>(
        SystemChannels.accessibility,
        (message) async {
          sent.add(message);
          return null;
        },
      );
      addTearDown(
        () => messenger.setMockDecodedMessageHandler<dynamic>(
          SystemChannels.accessibility,
          null,
        ),
      );

      // The exact call wave W5 makes after a language switch (I18N.md 6.5,
      // step 7): the view comes from View.of, the direction from the new
      // language. `announce` is deprecated since Flutter 3.35.
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            SemanticsService.sendAnnouncement(
              View.of(context),
              'announced text',
              TextDirection.rtl,
            ).ignore();
            return const SizedBox.shrink();
          },
        ),
      );
      await tester.pump();

      expect(sent, hasLength(1));
      final event = sent.single! as Map<Object?, Object?>;
      expect(event['type'], 'announce');
      final data = event['data']! as Map<Object?, Object?>;
      expect(data['message'], 'announced text');
      expect(data['textDirection'], TextDirection.rtl.index);
      expect(data['viewId'], tester.view.viewId);
    });
  });
}
