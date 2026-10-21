import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';
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

  testWidgets('a swatch recolours the selection, and undo restores it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: EditorDemo())),
    );
    Color? fillOf(String id) => tester
        .widget<GeoScene>(find.byType(GeoScene))
        .children
        .whereType<GeoSolid>()
        .firstWhere((n) => n.id == id)
        .style
        .fillColor;

    // Nothing selected: swatches are disabled.
    await tester.tap(find.byTooltip('Red'));
    await tester.pump();

    await tester.tap(find.text('Box')); // adds and selects box-1
    await tester.pump();
    final before = fillOf('box-1');
    await tester.tap(find.byTooltip('Red'));
    await tester.pump();
    expect(fillOf('box-1'), const Color(0xFFD94B4B));
    expect(fillOf('crate'), isNot(const Color(0xFFD94B4B)));

    await tester.tap(find.text('Undo'));
    await tester.pump();
    expect(fillOf('box-1'), before);
  });
}
