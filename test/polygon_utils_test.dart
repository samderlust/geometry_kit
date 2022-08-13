import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit/src/models/line.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';

void main() {
  group('Polygon Outer Centroid', () {
    test('all positive value', () {
      final polygon = <Point>[
        Point(0, 1),
        Point(1, 1),
        Point(0, 0),
      ];

      final centroid = PolygonUtils.getPolygonOuterCircleCentroid(polygon);

      expect(centroid, Point(1 / 3, 2 / 3));
    });
    test('some negative value', () {
      final polygon = <Point>[
        Point(-81, 41),
        Point(-88, 36),
        Point(-84, 31),
        Point(-80, 33),
        Point(-77, 39),
      ];

      final centroid = PolygonUtils.getPolygonOuterCircleCentroid(polygon);

      expect(
        centroid,
        Point(-82, 36),
      );
    });

    test('Number of sides must equal to number of point', () {
      final polygon = <Point>[
        Point(-81, 41),
        Point(-88, 36),
        Point(-84, 31),
        Point(-80, 33),
        Point(-77, 39),
      ];
      List<Line> sides = PolygonUtils.getPolygonSides(polygon);
      expect(sides.length, polygon.length);
    });
  });
}
