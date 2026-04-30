import 'dart:math';

import 'package:geometry_kit/src/kit/circle.dart';
import 'package:geometry_kit/src/kit/line.dart';
import 'package:geometry_kit/src/kit/point.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Circle', () {
    final unit = Circle(radius: 1, center: Point(0, 0));
    final c = Circle(radius: 5, center: Point(3, 4));

    group('area', () {
      test('unit circle area is pi', () {
        expect(unit.area, closeTo(pi, epsilon));
      });

      test('circle with radius 5', () {
        expect(c.area, closeTo(25 * pi, epsilon));
      });
    });

    group('perimeter', () {
      test('unit circle perimeter is 2*pi', () {
        expect(unit.perimeter, closeTo(2 * pi, epsilon));
      });

      test('circle with radius 5', () {
        expect(c.perimeter, closeTo(10 * pi, epsilon));
      });
    });

    group('hasPoint', () {
      test('center is inside', () {
        expect(c.hasPoint(Point(3, 4)), isTrue);
      });

      test('point inside circle', () {
        expect(c.hasPoint(Point(4, 5)), isTrue);
      });

      test('point on boundary is inside', () {
        expect(c.hasPoint(Point(8, 4)), isTrue);
      });

      test('point outside circle', () {
        expect(c.hasPoint(Point(20, 20)), isFalse);
      });

      test('point just outside', () {
        expect(unit.hasPoint(Point(1.1, 0)), isFalse);
      });
    });

    group('scale', () {
      test('scale doubles radius and center', () {
        final scaled = unit.scale(2);
        expect(scaled.radius, 2.0);
        expect(scaled.center, Point(0, 0));
      });

      test('scale with non-origin center', () {
        final scaled = c.scale(2);
        expect(scaled.radius, 10.0);
        expect(scaled.center, Point(6, 8));
      });

      test('scale by 0.5', () {
        final scaled = c.scale(0.5);
        expect(scaled.radius, 2.5);
        expect(scaled.center, Point(1.5, 2.0));
      });
    });

    group('translate', () {
      test('translate moves center', () {
        final moved = c.translate(x: 2, y: 3);
        expect(moved.center, Point(5, 7));
        expect(moved.radius, 5);
      });

      test('translate with default values', () {
        final moved = c.translate();
        expect(moved.center, c.center);
      });

      test('translate negative', () {
        final moved = c.translate(x: -3, y: -4);
        expect(moved.center, Point(0, 0));
      });
    });

    group('rotate', () {
      test('rotate returns same circle (rotation symmetry)', () {
        final rotated = c.rotate(45);
        expect(rotated, c);
      });
    });

    group('diameter', () {
      test('diameter is 2*radius', () {
        expect(unit.diameter, 2.0);
        expect(c.diameter, 10.0);
      });
    });

    group('circumference', () {
      test('alias for perimeter', () {
        expect(unit.circumference, unit.perimeter);
        expect(c.circumference, c.perimeter);
      });
    });

    group('contains', () {
      test('alias for hasPoint', () {
        expect(c.contains(Point(3, 4)), isTrue);
        expect(c.contains(Point(20, 20)), isFalse);
      });
    });

    group('distanceTo', () {
      test('point outside circle', () {
        // center (3,4), radius 5, point (13,4) => dist 10, boundary dist 5
        expect(c.distanceTo(Point(13, 4)), closeTo(5, epsilon));
      });

      test('point on boundary', () {
        expect(c.distanceTo(Point(8, 4)), closeTo(0, epsilon));
      });

      test('point inside is negative', () {
        expect(c.distanceTo(Point(3, 4)), closeTo(-5, epsilon));
      });
    });

    group('intersectsLine', () {
      test('line through circle', () {
        final line = Line(Point(-10, 4), Point(20, 4));
        expect(c.intersectsLine(line), isTrue);
      });

      test('line missing circle', () {
        final line = Line(Point(0, 20), Point(10, 20));
        expect(c.intersectsLine(line), isFalse);
      });

      test('line segment too short to reach circle', () {
        final line = Line(Point(-20, 4), Point(-10, 4));
        expect(c.intersectsLine(line), isFalse);
      });
    });

    group('getLineIntersections', () {
      test('line through center returns 2 points', () {
        final line = Line(Point(-10, 4), Point(20, 4));
        final hits = c.getLineIntersections(line);
        expect(hits, hasLength(2));
        // x = 3-5=-2 and x = 3+5=8
        expect(hits[0].x, closeTo(-2, epsilon));
        expect(hits[1].x, closeTo(8, epsilon));
      });

      test('tangent line returns 1 point', () {
        // Horizontal line at y=9, circle center (3,4) r=5 => tangent at top
        final line = Line(Point(-10, 9), Point(20, 9));
        final hits = c.getLineIntersections(line);
        expect(hits, hasLength(1));
        expect(hits[0].x, closeTo(3, epsilon));
        expect(hits[0].y, closeTo(9, epsilon));
      });

      test('miss returns empty', () {
        final line = Line(Point(0, 20), Point(10, 20));
        expect(c.getLineIntersections(line), isEmpty);
      });
    });

    group('intersectsCircle', () {
      test('overlapping circles', () {
        final other = Circle(radius: 3, center: Point(10, 4));
        expect(c.intersectsCircle(other), isTrue);
      });

      test('separate circles', () {
        final other = Circle(radius: 2, center: Point(20, 20));
        expect(c.intersectsCircle(other), isFalse);
      });

      test('one inside other', () {
        final other = Circle(radius: 1, center: Point(3, 4));
        expect(c.intersectsCircle(other), isFalse);
      });

      test('touching externally', () {
        // distance = 8, r1+r2 = 5+3 = 8 => touching
        final other = Circle(radius: 3, center: Point(11, 4));
        expect(c.intersectsCircle(other), isFalse);
      });
    });

    group('getCircleIntersections', () {
      test('two intersection points', () {
        final other = Circle(radius: 5, center: Point(9, 4));
        final hits = c.getCircleIntersections(other);
        expect(hits, hasLength(2));
      });

      test('tangent circles return 1 point', () {
        // distance = 8, r1=5, r2=3, 5+3=8 => tangent
        final other = Circle(radius: 3, center: Point(11, 4));
        final hits = c.getCircleIntersections(other);
        expect(hits, hasLength(1));
      });

      test('no intersection returns empty', () {
        final other = Circle(radius: 1, center: Point(20, 20));
        expect(c.getCircleIntersections(other), isEmpty);
      });

      test('concentric circles return empty', () {
        final other = Circle(radius: 2, center: Point(3, 4));
        expect(c.getCircleIntersections(other), isEmpty);
      });
    });

    group('tangentAt', () {
      test('tangent at top is horizontal', () {
        final circ = Circle(radius: 5, center: Point(0, 0));
        final tan = circ.tangentAt(Point(0, 5));
        // Tangent at top should be horizontal
        expect(tan.a.y, closeTo(tan.b.y, epsilon));
      });

      test('tangent at right is vertical', () {
        final circ = Circle(radius: 5, center: Point(0, 0));
        final tan = circ.tangentAt(Point(5, 0));
        // Tangent at right should be vertical
        expect(tan.a.x, closeTo(tan.b.x, epsilon));
      });

      test('tangent is perpendicular to radius', () {
        final circ = Circle(radius: 5, center: Point(0, 0));
        final p = Point(3, 4);
        final tan = circ.tangentAt(p);
        final radiusLine = Line(circ.center, p);
        expect(radiusLine.isPerpendicularTo(tan), isTrue);
      });
    });

    group('equality', () {
      test('same circle', () {
        final c1 = Circle(radius: 5, center: Point(0, 0));
        final c2 = Circle(radius: 5, center: Point(0, 0));
        expect(c1 == c2, isTrue);
      });

      test('different radius', () {
        final c1 = Circle(radius: 5, center: Point(0, 0));
        final c2 = Circle(radius: 3, center: Point(0, 0));
        expect(c1 == c2, isFalse);
      });

      test('different center', () {
        final c1 = Circle(radius: 5, center: Point(0, 0));
        final c2 = Circle(radius: 5, center: Point(1, 0));
        expect(c1 == c2, isFalse);
      });
    });
  });
}
