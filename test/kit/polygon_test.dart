import 'dart:math';

import 'package:geometry_kit/src/kit/circle.dart';
import 'package:geometry_kit/src/kit/line.dart';
import 'package:geometry_kit/src/kit/point.dart';
import 'package:geometry_kit/src/kit/polygon.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Polygon', () {
    // Unit square (CW order)
    final square = Polygon([
      Point(0, 0),
      Point(4, 0),
      Point(4, 4),
      Point(0, 4),
    ]);

    // Complex polygon from example
    final complex = Polygon([
      Point(1, 0),
      Point(0, 2),
      Point(0, 3),
      Point(2, 5),
      Point(3, 5),
      Point(5, 3),
      Point(5, 1),
      Point(3, 0),
    ]);

    group('area', () {
      test('square area', () {
        expect(square.area, closeTo(16.0, epsilon));
      });

      test('complex polygon area', () {
        expect(complex.area, closeTo(19.0, epsilon));
      });
    });

    group('perimeter', () {
      test('square perimeter', () {
        expect(square.perimeter, closeTo(16.0, epsilon));
      });
    });

    group('edges', () {
      test('square has 4 edges', () {
        expect(square.edges, hasLength(4));
      });

      test('complex polygon has 8 edges', () {
        expect(complex.edges, hasLength(8));
      });

      test('edges form closed loop', () {
        final edges = square.edges;
        for (int i = 0; i < edges.length; i++) {
          final nextI = (i + 1) % edges.length;
          expect(edges[i].b, edges[nextI].a);
        }
      });
    });

    group('boundary points', () {
      test('mostRightPoint', () {
        expect(square.mostRightPoint, Point(4, 0));
      });

      test('mostLeftPoint', () {
        expect(square.mostLeftPoint, Point(0, 0));
      });

      test('topPoint', () {
        expect(square.topPoint, Point(4, 4));
      });

      test('bottomPoint', () {
        expect(square.bottomPoint, Point(0, 0));
      });
    });

    group('getBound', () {
      test('bounding box has 4 vertices', () {
        final bound = square.getBound();
        expect(bound.vertices, hasLength(4));
      });
    });

    group('contains', () {
      test('point inside polygon', () {
        expect(square.contains(Point(2, 2)), isTrue);
      });

      test('point outside polygon', () {
        expect(square.contains(Point(10, 10)), isFalse);
      });

      test('vertex is inside', () {
        expect(square.contains(Point(0, 0)), isTrue);
      });

      test('point far left is outside', () {
        expect(square.contains(Point(-1, 2)), isFalse);
      });

      test('point far right is outside', () {
        expect(square.contains(Point(5, 2)), isFalse);
      });

      test('point above is outside', () {
        expect(square.contains(Point(2, 5)), isFalse);
      });

      test('point below is outside', () {
        expect(square.contains(Point(2, -1)), isFalse);
      });

      test('complex polygon inside point', () {
        expect(complex.contains(Point(2, 2)), isTrue);
      });

      test('complex polygon outside point', () {
        expect(complex.contains(Point(9, 2)), isFalse);
      });
    });

    group('intersectsLine', () {
      test('line crossing square', () {
        final line = Line(Point(-1, 2), Point(5, 2));
        expect(square.intersectsLine(line), isTrue);
      });

      test('line inside square', () {
        final line = Line(Point(1, 1), Point(3, 3));
        expect(square.intersectsLine(line), isTrue);
      });

      test('line outside square', () {
        final line = Line(Point(10, 10), Point(15, 15));
        expect(square.intersectsLine(line), isFalse);
      });
    });

    group('intersectsCircle', () {
      test('circle overlapping square', () {
        final c = Circle(radius: 2, center: Point(5, 2));
        expect(square.intersectsCircle(c), isTrue);
      });

      test('circle inside square', () {
        final c = Circle(radius: 1, center: Point(2, 2));
        expect(square.intersectsCircle(c), isTrue);
      });

      test('circle far outside', () {
        final c = Circle(radius: 1, center: Point(20, 20));
        expect(square.intersectsCircle(c), isFalse);
      });
    });

    group('getCircumCentroid', () {
      test('square centroid is at center', () {
        final centroid = square.getCircumCentroid();
        expect(centroid.x, closeTo(2, epsilon));
        expect(centroid.y, closeTo(2, epsilon));
      });
    });

    group('getInnerCentroid', () {
      test('square inner centroid is at center', () {
        final centroid = square.getInnerCentroid();
        expect(centroid.x, closeTo(2, epsilon));
        expect(centroid.y, closeTo(2, epsilon));
      });
    });

    group('centroid', () {
      test('square centroid at center', () {
        final c = square.centroid;
        expect(c.x, closeTo(2, epsilon));
        expect(c.y, closeTo(2, epsilon));
      });
    });

    group('isConvex', () {
      test('square is convex', () {
        expect(square.isConvex, isTrue);
      });

      test('concave polygon is not convex', () {
        // L-shaped polygon
        final concave = Polygon([
          Point(0, 0),
          Point(4, 0),
          Point(4, 2),
          Point(2, 2),
          Point(2, 4),
          Point(0, 4),
        ]);
        expect(concave.isConvex, isFalse);
      });

      test('regular hexagon is convex', () {
        final hex = Polygon.regular(sides: 6, radius: 5, center: Point(0, 0));
        expect(hex.isConvex, isTrue);
      });
    });

    group('isClockwise', () {
      test('CW square', () {
        // (0,0)->(4,0)->(4,4)->(0,4) is CCW in standard math coords
        expect(square.isClockwise, isFalse);
      });

      test('reversed square is CW', () {
        final cw = Polygon([
          Point(0, 0),
          Point(0, 4),
          Point(4, 4),
          Point(4, 0),
        ]);
        expect(cw.isClockwise, isTrue);
      });
    });

    group('getClosestVertex', () {
      test('closest to origin', () {
        expect(square.getClosestVertex(Point(0, 0)), Point(0, 0));
      });

      test('closest to (5,5)', () {
        expect(square.getClosestVertex(Point(5, 5)), Point(4, 4));
      });
    });

    group('getClosetVertex (deprecated)', () {
      test('still works', () {
        // ignore: deprecated_member_use_from_same_package
        expect(square.getClosetVertex(Point(0, 0)), Point(0, 0));
      });
    });

    group('getFurthestVertex', () {
      test('furthest from origin', () {
        expect(square.getFurthestVertex(Point(0, 0)), Point(4, 4));
      });

      test('furthest from (5,5)', () {
        expect(square.getFurthestVertex(Point(5, 5)), Point(0, 0));
      });
    });

    group('translate', () {
      test('translate moves all vertices', () {
        final moved = square.translate(x: 10, y: 20);
        expect(moved.vertices[0], Point(10, 20));
        expect(moved.vertices[1], Point(14, 20));
        expect(moved.vertices[2], Point(14, 24));
        expect(moved.vertices[3], Point(10, 24));
      });

      test('translate preserves area', () {
        final moved = square.translate(x: 5, y: 5);
        expect(moved.area.abs(), closeTo(square.area, epsilon));
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final scaled = square.scale(2);
        expect(scaled.vertices[0], Point(0, 0));
        expect(scaled.vertices[1], Point(8, 0));
        expect(scaled.vertices[2], Point(8, 8));
        expect(scaled.vertices[3], Point(0, 8));
      });

      test('scale doubles perimeter', () {
        final scaled = square.scale(2);
        expect(scaled.perimeter, closeTo(square.perimeter * 2, epsilon));
      });

      test('scale quadruples area', () {
        final scaled = square.scale(2);
        expect(scaled.area.abs(), closeTo(square.area * 4, epsilon));
      });
    });

    group('rotate', () {
      test('rotate 360 returns approximately same polygon', () {
        final rotated = square.rotate(360);
        for (int i = 0; i < square.vertices.length; i++) {
          expect(rotated.vertices[i].x,
              closeTo(square.vertices[i].x, epsilon));
          expect(rotated.vertices[i].y,
              closeTo(square.vertices[i].y, epsilon));
        }
      });
    });

    group('Polygon.regular', () {
      test('triangle has 3 vertices', () {
        final tri = Polygon.regular(sides: 3, radius: 5, center: Point(0, 0));
        expect(tri.vertices, hasLength(3));
      });

      test('hexagon has 6 vertices', () {
        final hex = Polygon.regular(sides: 6, radius: 5, center: Point(0, 0));
        expect(hex.vertices, hasLength(6));
      });

      test('all vertices at equal distance from center', () {
        final hex = Polygon.regular(sides: 6, radius: 5, center: Point(0, 0));
        for (final v in hex.vertices) {
          expect(v.distanceTo(Point(0, 0)), closeTo(5, epsilon));
        }
      });

      test('square has equal sides', () {
        final sq = Polygon.regular(sides: 4, radius: 5, center: Point(0, 0));
        final edges = sq.edges;
        final firstLen = edges.first.length;
        for (final e in edges) {
          expect(e.length, closeTo(firstLen, epsilon));
        }
      });

      test('regular polygon centered at non-origin', () {
        final center = Point(10, 20);
        final hex = Polygon.regular(sides: 6, radius: 3, center: center);
        for (final v in hex.vertices) {
          expect(v.distanceTo(center), closeTo(3, epsilon));
        }
      });

      test('area of regular hexagon', () {
        // Area of regular hexagon = (3*sqrt(3)/2) * s^2
        // s = side length = radius for regular hexagon
        final hex = Polygon.regular(sides: 6, radius: 5, center: Point(0, 0));
        final expectedArea = 3 * sqrt(3) / 2 * 25;
        expect(hex.area, closeTo(expectedArea, 0.1));
      });
    });
  });
}
