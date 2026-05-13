import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rouillon_isabelle/main.dart';

void main() {
  testWidgets('bottom navigation opens the lead board', (tester) async {
    await tester.pumpWidget(
      OperationsApp(store: MemoryOpsStore(), useScreenshotData: true),
    );
    await tester.pumpAndSettle();

    expect(find.text('Operations control room'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.trending_up_outlined));
    await tester.pumpAndSettle();

    expect(find.text('Lead Board'), findsWidgets);
    expect(find.text('New exporter onboarding'), findsOneWidget);
  });

  testWidgets('new shipment record can be saved locally', (tester) async {
    final store = MemoryOpsStore();
    await tester.pumpWidget(
      OperationsApp(store: store, useScreenshotData: false),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.add).last);
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('titleField')),
      'North depot handoff',
    );
    await tester.enterText(
      find.byKey(const ValueKey('referenceField')),
      'NDP-501',
    );
    await tester.enterText(
      find.byKey(const ValueKey('contactField')),
      'Warehouse lead',
    );
    await tester.enterText(
      find.byKey(const ValueKey('notesField')),
      'Check carton count before releasing the carrier.',
    );

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    final saved = await store.loadRecords();
    expect(
      saved.any((record) => record.title == 'North depot handoff'),
      isTrue,
    );
  });
}
