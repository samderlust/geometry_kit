import 'dart:math';

import 'package:geometry_kit/src/kit/circle.dart';
import 'package:geometry_kit/src/kit/line.dart';
import 'package:geometry_kit/src/kit/point.dart';
import 'package:geometry_kit/src/kit/ray.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Ray', () {
    final ray = Ray(Point(0, 0), Point(1, 0)); // rightward

    group('constructors', () {
      test('default constructor', () {
        expect(ray.origin, Point(0, 0));
        expect(ray.direction, Point(1, 0));
      });

      test('fromAngle 0 degrees points right', () {
        final r = Ray.fromAngle(Point(0, 0), 0);
        expect(r.normalizedDirection.x, closeTo(1, epsilon));
        expect(r.normalizedDirection.y, closeTo(0, epsilon));
      });

      test('fromAngle 90 degrees points up', () {
        final r = Ray.fromAngle(Point(0, 0), 90);
        expect(r.normalizedDirection.x, closeTo(0, epsilon));
        expect(r.normalizedDirection.y, closeTo(1, epsilon));
      });
    });

    group('normalizedDirection', () {
      test('already normalized stays same', () {
        final nd = ray.normalizedDirection;
        expect(nd.x, closeTo(1, epsilon));
        expect(nd.y, closeTo(0, epsilon));
      });

      test('unnormalized gets normalized', () {
        final r = Ray(Point(0, 0), Point(3, 4));
        final nd = r.normalizedDirection;
        expect(nd.x, closeTo(0.6, epsilon));
        expect(nd.y, closeTo(0.8, epsilon));
      });
    });

    group('pointAt', () {
      test('t=0 returns origin', () {
        expect(ray.pointAt(0), ray.origin);
      });

      test('t=5 returns (5,0) for rightward ray', () {
        final p = ray.pointAt(5);
        expect(p.x, closeTo(5, epsilon));
        expect(p.y, closeTo(0, epsilon));
      });

      test('diagonal ray', () {
        final r = Ray(Point(0, 0), Point(1, 1));
        final p = r.pointAt(sqrt(2));
        expect(p.x, closeTo(1, epsilon));
        expect(p.y, closeTo(1, epsilon));
      });
    });

    group('intersectsLine', () {
      test('ray hits line segment', () {
        final line = Line(Point(3, -2), Point(3, 2));
        final hit = ray.intersectsLine(line);
        expect(hit, isNotNull);
        expect(hit!.x, closeTo(3, epsilon));
        expect(hit.y, closeTo(0, epsilon));
      });

      test('ray misses line segment', () {
        final line = Line(Point(3, 5), Point(3, 10));
        expect(ray.intersectsLine(line), isNull);
      });

      test('ray pointing away returns null', () {
        final line = Line(Point(-5, -2), Point(-5, 2));
        expect(ray.intersectsLine(line), isNull);
      });

      test('parallel ray returns null', () {
        final line = Line(Point(0, 1), Point(5, 1));
        expect(ray.intersectsLine(line), isNull);
      });
    });

    group('intersectsCircle', () {
      test('ray through circle center returns 2 points', () {
        final c = Circle(radius: 2, center: Point(5, 0));
        final hits = ray.intersectsCircle(c);
        expect(hits, hasLength(2));
        expect(hits[0].x, closeTo(3, epsilon));
        expect(hits[1].x, closeTo(7, epsilon));
      });

      test('ray tangent to circle returns 1 point', () {
        final c = Circle(radius: 1, center: Point(3, 1));
        final hits = ray.intersectsCircle(c);
        expect(hits, hasLength(1));
        expect(hits[0].x, closeTo(3, epsilon));
        expect(hits[0].y, closeTo(0, epsilon));
      });

      test('ray missing circle returns empty', () {
        final c = Circle(radius: 1, center: Point(3, 5));
        expect(ray.intersectsCircle(c), isEmpty);
      });

      test('ray pointing away from circle returns empty', () {
        final c = Circle(radius: 1, center: Point(-5, 0));
        expect(ray.intersectsCircle(c), isEmpty);
      });
    });

    group('translate', () {
      test('moves origin, preserves direction', () {
        final moved = ray.translate(x: 2, y: 3);
        expect(moved.origin, Point(2, 3));
        expect(moved.direction, ray.direction);
      });
    });

    group('rotate', () {
      test('rotate 90 degrees', () {
        final rotated = ray.rotate(90);
        expect(rotated.normalizedDirection.x, closeTo(0, epsilon));
        expect(rotated.normalizedDirection.y, closeTo(1, epsilon));
      });
    });

    group('equality', () {
      test('same rays are equal', () {
        final r1 = Ray(Point(0, 0), Point(1, 0));
        final r2 = Ray(Point(0, 0), Point(1, 0));
        expect(r1 == r2, isTrue);
      });

      test('different rays are not equal', () {
        final r1 = Ray(Point(0, 0), Point(1, 0));
        final r2 = Ray(Point(0, 0), Point(0, 1));
        expect(r1 == r2, isFalse);
      });
    });

    test('toString', () {
      expect(ray.toString(),
          'Ray(origin: Point(x: 0.0, y: 0.0), direction: Point(x: 1.0, y: 0.0))');
    });
  });
}
