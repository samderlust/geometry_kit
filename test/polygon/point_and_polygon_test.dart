import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Test point and polygon', () {
    final polygon = [
      Point(1, 0),
      Point(0, 2),
      Point(0, 3),
      Point(2, 5),
      Point(3, 5),
      Point(5, 3),
      Point(5, 1),
      Point(3, 0),
    ];

    test('point on the side', () {
      final point = Point(5, 2);

      expect(PolygonUtils.isInsidePolygon(point, polygon), true);
    });
    test('point on vertex', () {
      final point = Point(0, 2);

      expect(PolygonUtils.isInsidePolygon(point, polygon), true);
    });

    test('point in polygon', () {
      final point = Point(2.0, 2);

      expect(PolygonUtils.isInsidePolygon(point, polygon), true);
    });

    test('point out on the left', () {
      final point = Point(-12, 2);

      expect(PolygonUtils.isInsidePolygon(point, polygon), false);
    });

    test('point out on the right', () {
      final point = Point(9, 2);

      expect(PolygonUtils.isInsidePolygon(point, polygon), false);
    });

    test('point out on the top', () {
      final point = Point(2, 6);

      expect(PolygonUtils.isInsidePolygon(point, polygon), false);
    });

    test('point out of the bottom', () {
      final point = Point(2, -1);

      expect(PolygonUtils.isInsidePolygon(point, polygon), false);
    });
  });
}
