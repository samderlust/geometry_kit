import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_widgets/geometry_kit_widgets.dart';

void main() {
  group('ShapeStyle', () {
    test('value equality', () {
      const a = ShapeStyle.stroked(Color(0xFFFF0000), width: 2);
      const b = ShapeStyle.stroked(Color(0xFFFF0000), width: 2);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('isVisible', () {
      const empty = ShapeStyle(strokeColor: null);
      expect(empty.isVisible, isFalse);
      expect(const ShapeStyle.filled(Color(0xFF000000)).isVisible, isTrue);
    });
  });

  group('CoordinateMapper', () {
    test('identity', () {
      const m = CoordinateMapper.identity;
      expect(m.toCanvas(10, 20), const Offset(10, 20));
      expect(m.fromCanvas(10, 20), const Offset(10, 20));
    });

    test('yUp flips around height', () {
      final m = CoordinateMapper.yUp(const Size(100, 200));
      expect(m.toCanvas(0, 0), const Offset(0, 200));
      expect(m.toCanvas(50, 50), const Offset(50, 150));
    });

    test('centered places origin at midpoint', () {
      final m = CoordinateMapper.centered(const Size(200, 100), yUp: false);
      expect(m.toCanvas(0, 0), const Offset(100, 50));
    });
  });

  group('DashPattern', () {
    test('value equality', () {
      const a = DashPattern([8, 4]);
      const b = DashPattern([8, 4]);
      expect(a, equals(b));
    });
  });

  group('Widgets render', () {
    testWidgets('GeoCircle paints', (tester) async {
      await tester.pumpWidget(const Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: GeoCircle.fromGeometry(
            circle: Circle(center: Point(50, 50), radius: 30),
            size: Size(100, 100),
          ),
        ),
      ));
      expect(find.byType(GeoCircle), findsOneWidget);
    });

    testWidgets('GeometryCanvas paints mixed shapes', (tester) async {
      await tester.pumpWidget(Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: GeometryCanvas(
            size: const Size(200, 200),
            shapes: [
              StyledShape(
                const Circle(center: Point(50, 50), radius: 20),
                style: const ShapeStyle.filled(Color(0xFF0000FF)),
              ),
              StyledShape(
                Triangle(
                  const Point(100, 100),
                  const Point(180, 180),
                  const Point(40, 180),
                ),
                style: const ShapeStyle.stroked(Color(0xFF000000)),
              ),
            ],
          ),
        ),
      ));
      expect(find.byType(GeometryCanvas), findsOneWidget);
    });
  });
}
