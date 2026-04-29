import 'dart:math';

import 'package:geometry_kit/src/kit/line.dart';
import 'package:geometry_kit/src/kit/point.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Line', () {
    group('slope', () {
      test('positive slope', () {
        final l = Line(Point(0, 0), Point(2, 2));
        expect(l.slope, 1.0);
      });

      test('negative slope', () {
        final l = Line(Point(0, 2), Point(2, 0));
        expect(l.slope, -1.0);
      });

      test('horizontal line has slope 0', () {
        final l = Line(Point(0, 5), Point(10, 5));
        expect(l.slope, 0.0);
      });

      test('vertical line going up returns infinity', () {
        final l = Line(Point(3, 0), Point(3, 10));
        expect(l.slope, double.infinity);
      });

      test('vertical line going down returns negative infinity', () {
        final l = Line(Point(3, 10), Point(3, 0));
        expect(l.slope, double.negativeInfinity);
      });

      test('fractional slope', () {
        final l = Line(Point(0, 0), Point(4, 2));
        expect(l.slope, 0.5);
      });
    });

    group('length', () {
      test('horizontal line', () {
        final l = Line(Point(0, 0), Point(5, 0));
        expect(l.length, 5.0);
      });

      test('vertical line', () {
        final l = Line(Point(0, 0), Point(0, 3));
        expect(l.length, 3.0);
      });

      test('diagonal line (3-4-5 triangle)', () {
        final l = Line(Point(0, 0), Point(3, 4));
        expect(l.length, closeTo(5.0, epsilon));
      });

      test('zero length line', () {
        final l = Line(Point(2, 2), Point(2, 2));
        expect(l.length, 0.0);
      });
    });

    group('midPoint', () {
      test('midpoint of horizontal line', () {
        final l = Line(Point(0, 0), Point(10, 0));
        expect(l.midPoint, Point(5, 0));
      });

      test('midpoint of diagonal line', () {
        final l = Line(Point(0, 0), Point(4, 4));
        expect(l.midPoint, Point(2, 2));
      });

      test('midpoint with negative coordinates', () {
        final l = Line(Point(-2, -2), Point(2, 2));
        expect(l.midPoint, Point(0, 0));
      });
    });

    group('yIntercept', () {
      test('line through origin', () {
        final l = Line(Point(0, 0), Point(2, 2));
        expect(l.yIntercept, closeTo(0, epsilon));
      });

      test('line with positive y-intercept', () {
        final l = Line(Point(0, 3), Point(1, 5));
        expect(l.yIntercept, closeTo(3, epsilon));
      });

      test('vertical line returns NaN', () {
        final l = Line(Point(3, 0), Point(3, 5));
        expect(l.yIntercept.isNaN, isTrue);
      });
    });

    group('xIntercept', () {
      test('line through origin', () {
        final l = Line(Point(0, 0), Point(2, 2));
        expect(l.xIntercept, closeTo(0, epsilon));
      });

      test('line with positive x-intercept', () {
        final l = Line(Point(2, 0), Point(4, 2));
        expect(l.xIntercept, closeTo(2, epsilon));
      });

      test('horizontal line returns NaN', () {
        final l = Line(Point(0, 5), Point(10, 5));
        expect(l.xIntercept.isNaN, isTrue);
      });
    });

    group('distanceFromAPoint', () {
      test('point on the line has zero distance', () {
        final l = Line(Point(0, 0), Point(10, 0));
        expect(l.distanceFromAPoint(Point(5, 0)), closeTo(0, epsilon));
      });

      test('point above horizontal line', () {
        final l = Line(Point(0, 0), Point(10, 0));
        expect(l.distanceFromAPoint(Point(5, 3)), closeTo(3, epsilon));
      });

      test('point beside vertical line', () {
        final l = Line(Point(0, 0), Point(0, 10));
        expect(l.distanceFromAPoint(Point(4, 5)), closeTo(4, epsilon));
      });
    });

    group('getIntersectPoint', () {
      test('crossing segments return intersection point', () {
        final l1 = Line(Point(0, 0), Point(2, 2));
        final l2 = Line(Point(0, 2), Point(2, 0));
        final point = l1.getIntersectPoint(l2);
        expect(point, isNotNull);
        expect(point!.x, closeTo(1, epsilon));
        expect(point.y, closeTo(1, epsilon));
      });

      test('non-crossing segments return null', () {
        final l1 = Line(Point(0, 0), Point(1, 1));
        final l2 = Line(Point(5, 5), Point(6, 4));
        expect(l1.getIntersectPoint(l2), isNull);
      });

      test('parallel lines return null', () {
        final l1 = Line(Point(0, 0), Point(2, 2));
        final l2 = Line(Point(0, 1), Point(2, 3));
        expect(l1.getIntersectPoint(l2), isNull);
      });

      test('segments that would intersect if extended return null', () {
        // These two segments don't cross as segments,
        // but their infinite extensions would
        final l1 = Line(Point(0, 0), Point(1, 1));
        final l2 = Line(Point(3, 0), Point(4, -1));
        expect(l1.getIntersectPoint(l2), isNull);
      });

      test('T-shaped intersection', () {
        final l1 = Line(Point(0, 1), Point(4, 1));
        final l2 = Line(Point(2, 0), Point(2, 2));
        final point = l1.getIntersectPoint(l2);
        expect(point, isNotNull);
        expect(point!.x, closeTo(2, epsilon));
        expect(point.y, closeTo(1, epsilon));
      });
    });

    group('intersect', () {
      test('crossing lines return true', () {
        final l1 = Line(Point(0, 0), Point(2, 2));
        final l2 = Line(Point(0, 2), Point(2, 0));
        expect(l1.intersect(l2), isTrue);
      });

      test('non-crossing lines return false', () {
        final l1 = Line(Point(0, 0), Point(1, 1));
        final l2 = Line(Point(5, 5), Point(6, 4));
        expect(l1.intersect(l2), isFalse);
      });
    });

    group('angles', () {
      test('perpendicular lines have pi/2 inner angle', () {
        final l1 = Line(Point(0, 0), Point(5, 0));
        final l2 = Line(Point(0, 0), Point(0, 5));
        expect(l1.innerAngleWith(l2), closeTo(pi / 2, epsilon));
      });

      test('inner + outer angle = pi', () {
        final l1 = Line(Point(0, 0), Point(3, 0));
        final l2 = Line(Point(0, 0), Point(3, 3));
        final inner = l1.innerAngleWith(l2);
        final outer = l1.outerAngleWith(l2);
        expect(inner + outer, closeTo(pi, epsilon));
      });
    });

    group('points', () {
      test('returns list of two endpoints', () {
        final a = Point(1, 2);
        final b = Point(3, 4);
        final l = Line(a, b);
        expect(l.points, [a, b]);
      });
    });

    group('equality', () {
      test('same endpoints are equal', () {
        final l1 = Line(Point(0, 0), Point(1, 1));
        final l2 = Line(Point(0, 0), Point(1, 1));
        expect(l1 == l2, isTrue);
      });

      test('reversed endpoints are not equal', () {
        final l1 = Line(Point(0, 0), Point(1, 1));
        final l2 = Line(Point(1, 1), Point(0, 0));
        expect(l1 == l2, isFalse);
      });

      test('hashCode consistent with equality', () {
        final l1 = Line(Point(0, 0), Point(1, 1));
        final l2 = Line(Point(0, 0), Point(1, 1));
        expect(l1.hashCode, l2.hashCode);
      });
    });

    group('translate', () {
      test('translate moves both endpoints', () {
        final l = Line(Point(1, 2), Point(3, 4));
        final moved = l.translate(x: 5, y: 10);
        expect(moved.a, Point(6, 12));
        expect(moved.b, Point(8, 14));
      });

      test('translate preserves length', () {
        final l = Line(Point(0, 0), Point(3, 4));
        final moved = l.translate(x: 10, y: 20);
        expect(moved.length, closeTo(l.length, epsilon));
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final l = Line(Point(1, 2), Point(3, 4));
        final scaled = l.scale(2);
        expect(scaled.a, Point(2, 4));
        expect(scaled.b, Point(6, 8));
      });

      test('scale doubles length', () {
        final l = Line(Point(0, 0), Point(3, 4));
        final scaled = l.scale(2);
        expect(scaled.length, closeTo(l.length * 2, epsilon));
      });
    });

    group('rotate', () {
      test('rotate 90 degrees', () {
        final l = Line(Point(1, 0), Point(2, 0));
        final rotated = l.rotate(90);
        expect(rotated.a.x, closeTo(0, epsilon));
        expect(rotated.a.y, closeTo(1, epsilon));
        expect(rotated.b.x, closeTo(0, epsilon));
        expect(rotated.b.y, closeTo(2, epsilon));
      });

      test('rotate preserves length', () {
        final l = Line(Point(0, 0), Point(3, 4));
        final rotated = l.rotate(45);
        expect(rotated.length, closeTo(l.length, epsilon));
      });
    });

    test('toString', () {
      final l = Line(Point(1, 2), Point(3, 4));
      expect(l.toString(), 'Line(a: Point(x: 1.0, y: 2.0), b: Point(x: 3.0, y: 4.0))');
    });
  });
}
