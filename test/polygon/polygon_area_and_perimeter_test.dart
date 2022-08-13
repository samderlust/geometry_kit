import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Test polygon area and perimeter', () {
    test('area of irregular polygon', () {
      final polygon = [
        Point(125, -15),
        Point(113, -22),
        Point(154, -27),
        Point(144, -15),
      ];

      expect(PolygonUtils.area(polygon), 287.5);
    });
  });
}
