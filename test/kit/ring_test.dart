import 'dart:math';

import 'package:geometry_kit/src/kit/point.dart';
import 'package:geometry_kit/src/kit/ring.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Ring', () {
    final ring = Ring(center: Point(0, 0), innerRadius: 3, outerRadius: 5);

    group('properties', () {
      test('width', () {
        expect(ring.width, 2);
      });

      test('area', () {
        // pi * (25 - 9) = 16*pi
        expect(ring.area, closeTo(16 * pi, epsilon));
      });

      test('outerCircumference', () {
        expect(ring.outerCircumference, closeTo(10 * pi, epsilon));
      });

      test('innerCircumference', () {
        expect(ring.innerCircumference, closeTo(6 * pi, epsilon));
      });

      test('averageRadius', () {
        expect(ring.averageRadius, 4);
      });
    });

    group('contains', () {
      test('point in ring', () {
        expect(ring.contains(Point(4, 0)), isTrue);
      });

      test('point in hole', () {
        expect(ring.contains(Point(1, 0)), isFalse);
      });

      test('point outside', () {
        expect(ring.contains(Point(10, 0)), isFalse);
      });

      test('point on inner boundary', () {
        expect(ring.contains(Point(3, 0)), isTrue);
      });

      test('point on outer boundary', () {
        expect(ring.contains(Point(5, 0)), isTrue);
      });

      test('center is not in ring', () {
        expect(ring.contains(Point(0, 0)), isFalse);
      });
    });

    group('translate', () {
      test('moves center', () {
        final moved = ring.translate(x: 5, y: 10);
        expect(moved.center, Point(5, 10));
        expect(moved.innerRadius, 3);
        expect(moved.outerRadius, 5);
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final scaled = ring.scale(2);
        expect(scaled.innerRadius, 6);
        expect(scaled.outerRadius, 10);
      });

      test('area scales by factor^2', () {
        final scaled = ring.scale(2);
        expect(scaled.area, closeTo(ring.area * 4, epsilon));
      });
    });

    group('equality', () {
      test('same rings', () {
        final r1 = Ring(center: Point(0, 0), innerRadius: 3, outerRadius: 5);
        final r2 = Ring(center: Point(0, 0), innerRadius: 3, outerRadius: 5);
        expect(r1 == r2, isTrue);
      });

      test('different rings', () {
        final r1 = Ring(center: Point(0, 0), innerRadius: 3, outerRadius: 5);
        final r2 = Ring(center: Point(0, 0), innerRadius: 2, outerRadius: 5);
        expect(r1 == r2, isFalse);
      });
    });

    test('toString', () {
      expect(ring.toString(),
          'Ring(center: Point(x: 0.0, y: 0.0), innerRadius: 3.0, outerRadius: 5.0)');
    });
  });
}
