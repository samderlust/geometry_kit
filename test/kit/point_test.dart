import 'dart:math';

import 'package:geometry_kit/src/kit/point.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Point', () {
    group('distanceTo', () {
      test('returns correct distance between two points', () {
        final p1 = Point(1, 1);
        final p2 = Point(3, 4);
        expect(p1.distanceTo(p2), closeTo(3.6055, epsilon));
      });

      test('distance to same point is zero', () {
        final p = Point(5, 5);
        expect(p.distanceTo(p), 0);
      });

      test('distance from origin', () {
        final origin = Point(0, 0);
        final p = Point(3, 4);
        expect(origin.distanceTo(p), closeTo(5.0, epsilon));
      });

      test('distance with negative coordinates', () {
        final p1 = Point(-1, -1);
        final p2 = Point(2, 3);
        expect(p1.distanceTo(p2), closeTo(5.0, epsilon));
      });
    });

    group('pointAtDistance', () {
      test('point at distance with default angle (0)', () {
        final p = Point(1, 1);
        final result = p.pointAtDistance(5);
        expect(result.x, closeTo(6, epsilon));
        expect(result.y, closeTo(1, epsilon));
      });

      test('point at distance with 90 degree angle', () {
        final p = Point(0, 0);
        final result = p.pointAtDistance(5, pi / 2);
        expect(result.x, closeTo(0, epsilon));
        expect(result.y, closeTo(5, epsilon));
      });

      test('point at distance with pi angle', () {
        final p = Point(0, 0);
        final result = p.pointAtDistance(3, pi);
        expect(result.x, closeTo(-3, epsilon));
        expect(result.y, closeTo(0, epsilon));
      });
    });

    group('pointAtAngle', () {
      test('point at angle 0', () {
        final center = Point(0, 0);
        final result = center.pointAtAngle(5, 0);
        expect(result.x, closeTo(5, epsilon));
        expect(result.y, closeTo(0, epsilon));
      });

      test('point at angle pi/2', () {
        final center = Point(1, 1);
        final result = center.pointAtAngle(3, pi / 2);
        expect(result.x, closeTo(1, epsilon));
        expect(result.y, closeTo(4, epsilon));
      });
    });

    group('translate', () {
      test('translate positive values', () {
        final p = Point(1, 2);
        final result = p.translate(3, 4);
        expect(result, Point(4, 6));
      });

      test('translate negative values', () {
        final p = Point(5, 5);
        final result = p.translate(-2, -3);
        expect(result, Point(3, 2));
      });

      test('translate by zero', () {
        final p = Point(3, 4);
        final result = p.translate(0, 0);
        expect(result, Point(3, 4));
      });

      test('translate does not mutate original', () {
        final p = Point(1, 1);
        p.translate(5, 5);
        expect(p, Point(1, 1));
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final p = Point(3, 4);
        final result = p.scale(2);
        expect(result, Point(6, 8));
      });

      test('scale by 0.5', () {
        final p = Point(10, 20);
        final result = p.scale(0.5);
        expect(result, Point(5, 10));
      });

      test('scale by 1 returns same values', () {
        final p = Point(3, 4);
        final result = p.scale(1);
        expect(result, Point(3, 4));
      });

      test('scale by 0 returns origin', () {
        final p = Point(3, 4);
        final result = p.scale(0);
        expect(result, Point(0, 0));
      });
    });

    group('rotate', () {
      test('rotate 90 degrees', () {
        final p = Point(1, 0);
        final result = p.rotate(90);
        expect(result.x, closeTo(0, epsilon));
        expect(result.y, closeTo(1, epsilon));
      });

      test('rotate 180 degrees', () {
        final p = Point(1, 0);
        final result = p.rotate(180);
        expect(result.x, closeTo(-1, epsilon));
        expect(result.y, closeTo(0, epsilon));
      });

      test('rotate 360 degrees returns same point', () {
        final p = Point(3, 4);
        final result = p.rotate(360);
        expect(result.x, closeTo(3, epsilon));
        expect(result.y, closeTo(4, epsilon));
      });

      test('rotate 0 degrees returns same point', () {
        final p = Point(3, 4);
        final result = p.rotate(0);
        expect(result.x, closeTo(3, epsilon));
        expect(result.y, closeTo(4, epsilon));
      });
    });

    group('operators', () {
      test('addition', () {
        expect(Point(1, 2) + Point(3, 4), Point(4, 6));
      });

      test('subtraction', () {
        expect(Point(5, 7) - Point(2, 3), Point(3, 4));
      });

      test('multiplication', () {
        expect(Point(3, 4) * 2, Point(6, 8));
      });

      test('division', () {
        expect(Point(6, 8) / 2, Point(3, 4));
      });

      test('cross product (%)', () {
        final p1 = Point(1, 0);
        final p2 = Point(0, 1);
        expect(p1 % p2, 1.0);
      });
    });

    group('equality', () {
      test('same coordinates are equal', () {
        expect(Point(1, 2) == Point(1, 2), isTrue);
      });

      test('different coordinates are not equal', () {
        expect(Point(1, 2) == Point(3, 4), isFalse);
      });

      test('hashCode consistent with equality', () {
        expect(Point(1, 2).hashCode, Point(1, 2).hashCode);
      });
    });

    test('toString', () {
      expect(Point(1, 2).toString(), 'Point(x: 1.0, y: 2.0)');
    });
  });
}
