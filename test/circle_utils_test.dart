import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  final circle = Circle(radius: 10, center: Point(0, 0));
  group('Test Circle Utils', () {
    test('point inside circle', () {
      final point = Point<num>(1, 1);
      expect(CircleUtils.isPointInsideCircle(circle, point), true);
    });

    test('point outside circle', () {
      final point = Point<num>(10, 1);
      expect(CircleUtils.isPointInsideCircle(circle, point), false);
    });

    test('point on the edge circle', () {
      final point = Point<num>(9, 1);
      expect(CircleUtils.isPointInsideCircle(circle, point), true);
    });

    test('area', () {
      expect(CircleUtils.area(circle.radius), pow(circle.radius, 2) * pi);
    });

    test('perimeter', () {
      expect(CircleUtils.perimeter(circle.radius), circle.radius * 2 * pi);
    });
  });
}
