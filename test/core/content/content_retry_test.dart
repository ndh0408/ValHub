import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valvn/core/content/content_db.dart';
import 'package:valvn/core/content/content_repository.dart';
import 'package:valvn/core/network/riot_exception.dart';

void main() {
  testWidgets('retryContentIfFailed reloads a failed content load only', (
    tester,
  ) async {
    var loads = 0;
    late WidgetRef widgetRef;
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          contentProvider.overrideWith((ref) async {
            loads++;
            if (loads == 1) {
              throw const TransientException(reason: 'content_unavailable');
            }
            return ContentDb.empty();
          }),
        ],
        child: Consumer(
          builder: (context, ref, _) {
            widgetRef = ref;
            ref.watch(contentProvider);
            return const SizedBox();
          },
        ),
      ),
    );
    await tester.pump();
    expect(widgetRef.read(contentProvider).hasError, isTrue);

    widgetRef.retryContentIfFailed();
    await tester.pump();
    await tester.pump();
    expect(loads, 2);
    expect(widgetRef.read(contentProvider).hasValue, isTrue);

    widgetRef.retryContentIfFailed(); // loaded: no reload
    await tester.pump();
    expect(loads, 2);
  });
}
