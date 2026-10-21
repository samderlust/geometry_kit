import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometry_kit_widgets_example/demos3d/editor_demo.dart';

void main() {
  for (final width in [375.0, 1000.0]) {
    testWidgets('editor demo renders and adds at $width', (tester) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: EditorDemo())),
      );
      await tester.tap(find.text('Box'));
      await tester.pump();
      expect(find.textContaining('box-1'), findsOneWidget);
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(find.textContaining('box-1'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
