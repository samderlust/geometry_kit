import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';
import 'package:geometry_kit_widgets_example/demos/curves_demo.dart';

void main() {
  for (final width in [375.0, 1000.0]) {
    testWidgets('curves demo renders and toggles overlays at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: CurvesDemo())),
      );
      expect(find.byType(GeoArc), findsOneWidget);
      expect(find.byType(GeometryCanvas), findsOneWidget);
      await tester.tap(find.text('dimensions'));
      await tester.tap(find.text('arc sector'));
      await tester.tap(find.text('grid'));
      await tester.pump();
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('dragging the circle commits the move', (tester) async {
    tester.view.physicalSize = const Size(1000, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: CurvesDemo())),
    );
    final circle = find.byType(GeoCircle);
    final before = tester.widget<GeoCircle>(circle).circle.center;
    // Circle center is (60, 70) in the drag card's local space.
    final origin = tester.getTopLeft(circle);
    await tester.dragFrom(origin + const Offset(60, 70), const Offset(50, 0));
    await tester.pump();
    final after = tester.widget<GeoCircle>(circle).circle.center;
    expect(after.x, greaterThan(before.x + 20));
    expect(find.textContaining('last drop: circle'), findsOneWidget);
  });
}
