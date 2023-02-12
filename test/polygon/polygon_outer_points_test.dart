import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Test Polygon Most Outer Point', () {
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

    test('Get furthest points', () {
      expect(PolygonUtils.getMostLeftPoint(polygon), Point(0, 2));
      expect(PolygonUtils.getMostRightPoint(polygon), Point(5, 3));
      expect(PolygonUtils.getTopPoint(polygon), Point(2, 5));
      expect(PolygonUtils.getBottomPoint(polygon), Point(1, 0));
    });
  });
}
