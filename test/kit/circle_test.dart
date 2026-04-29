import 'dart:math';

import 'package:geometry_kit/src/kit/circle.dart';
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
