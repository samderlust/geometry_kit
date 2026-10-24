import 'dart:math';

import 'package:geometry_kit/src/kit/ellipse.dart';
import 'package:geometry_kit/src/kit/point.dart';
import 'package:test/test.dart';

const epsilon = 0.01;

void main() {
  group('Ellipse', () {
    final ellipse = Ellipse(center: Point(0, 0), radiusX: 5, radiusY: 3);
    final circle = Ellipse.circular(center: Point(0, 0), radius: 4);

    group('constructors', () {
      test('default constructor', () {
        expect(ellipse.center, Point(0, 0));
        expect(ellipse.radiusX, 5);
        expect(ellipse.radiusY, 3);
      });

      test('circular factory', () {
        expect(circle.radiusX, 4);
        expect(circle.radiusY, 4);
        expect(circle.isCircle, isTrue);
      });
    });

    group('properties', () {
      test('isCircle false for ellipse', () {
        expect(ellipse.isCircle, isFalse);
      });

      test('semiMajor', () {
        expect(ellipse.semiMajor, 5);
      });

      test('semiMinor', () {
        expect(ellipse.semiMinor, 3);
      });

      test('eccentricity of circle is 0', () {
        expect(circle.eccentricity, closeTo(0, epsilon));
      });

      test('eccentricity of ellipse between 0 and 1', () {
        expect(ellipse.eccentricity, greaterThan(0));
        expect(ellipse.eccentricity, lessThan(1));
      });

      test('foci lie on major axis', () {
        final foci = ellipse.foci;
        expect(foci, hasLength(2));
        // Major axis is x since radiusX > radiusY
        expect(foci[0].y, closeTo(0, epsilon));
        expect(foci[1].y, closeTo(0, epsilon));
        // Symmetric around center
        expect(foci[0].x, closeTo(-foci[1].x, epsilon));
      });

      test('foci of circle are at center', () {
        final foci = circle.foci;
        expect(foci[0].x, closeTo(0, epsilon));
        expect(foci[1].x, closeTo(0, epsilon));
      });
    });

    group('area', () {
      test('ellipse area', () {
        expect(ellipse.area, closeTo(pi * 5 * 3, epsilon));
      });

      test('circular ellipse area matches circle formula', () {
        expect(circle.area, closeTo(pi * 16, epsilon));
      });
    });

    group('perimeter', () {
      test('circular ellipse perimeter matches circle', () {
        expect(circle.perimeter, closeTo(2 * pi * 4, epsilon));
      });

      test('ellipse perimeter is reasonable', () {
        // Perimeter should be between circumscribed and inscribed circle
        expect(ellipse.perimeter, greaterThan(2 * pi * 3));
        expect(ellipse.perimeter, lessThan(2 * pi * 5));
      });
    });

    group('pointAt', () {
      test('point at 0 radians', () {
        final p = ellipse.pointAt(0);
        expect(p.x, closeTo(5, epsilon));
        expect(p.y, closeTo(0, epsilon));
      });

      test('point at pi/2 radians', () {
        final p = ellipse.pointAt(pi / 2);
        expect(p.x, closeTo(0, epsilon));
        expect(p.y, closeTo(3, epsilon));
      });
    });

    group('contains', () {
      test('center is inside', () {
        expect(ellipse.contains(Point(0, 0)), isTrue);
      });

      test('point inside', () {
        expect(ellipse.contains(Point(2, 1)), isTrue);
      });

      test('point on boundary', () {
        expect(ellipse.contains(Point(5, 0)), isTrue);
      });

      test('point outside', () {
        expect(ellipse.contains(Point(6, 0)), isFalse);
      });

      test('point outside on minor axis', () {
        expect(ellipse.contains(Point(0, 4)), isFalse);
      });
    });

    group('translate', () {
      test('moves center', () {
        final moved = ellipse.translate(x: 3, y: 4);
        expect(moved.center, Point(3, 4));
        expect(moved.radiusX, 5);
        expect(moved.radiusY, 3);
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final scaled = ellipse.scale(2);
        expect(scaled.radiusX, 10);
        expect(scaled.radiusY, 6);
        expect(scaled.center, Point(0, 0));
      });

      test('scale quadruples area', () {
        final scaled = ellipse.scale(2);
        expect(scaled.area, closeTo(ellipse.area * 4, epsilon));
      });
    });

    group('equality', () {
      test('same ellipses are equal', () {
        final e1 = Ellipse(center: Point(0, 0), radiusX: 5, radiusY: 3);
        final e2 = Ellipse(center: Point(0, 0), radiusX: 5, radiusY: 3);
        expect(e1 == e2, isTrue);
      });

      test('different ellipses are not equal', () {
        final e1 = Ellipse(center: Point(0, 0), radiusX: 5, radiusY: 3);
        final e2 = Ellipse(center: Point(0, 0), radiusX: 5, radiusY: 4);
        expect(e1 == e2, isFalse);
      });
    });

    test('toString', () {
      expect(ellipse.toString(),
          'Ellipse(center: Point(x: 0.0, y: 0.0), radiusX: 5.0, radiusY: 3.0)');
    });
  });
}
