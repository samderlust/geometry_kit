import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Capsule', () {
    // Horizontal capsule: axis from (0,0) to (4,0), radius 1
    final hCap = Capsule(medialAxis: Line(Point(0, 0), Point(4, 0)), radius: 1);

    group('constructors', () {
      test('default constructor', () {
        expect(hCap.medialAxis.a, Point(0, 0));
        expect(hCap.medialAxis.b, Point(4, 0));
        expect(hCap.radius, 1);
      });

      test('fromRect horizontal', () {
        final c = Capsule.fromRect(
          center: Point(2, 0),
          width: 6,
          height: 2,
        );
        expect(c.radius, closeTo(1.0, epsilon));
        expect(c.axisLength, closeTo(4.0, epsilon));
        expect(c.center.x, closeTo(2.0, epsilon));
        expect(c.center.y, closeTo(0.0, epsilon));
      });

      test('fromRect vertical', () {
        final c = Capsule.fromRect(
          center: Point(0, 3),
          width: 2,
          height: 8,
        );
        expect(c.radius, closeTo(1.0, epsilon));
        expect(c.axisLength, closeTo(6.0, epsilon));
      });

      test('fromRect square becomes circle-like', () {
        final c = Capsule.fromRect(
          center: Point(0, 0),
          width: 4,
          height: 4,
        );
        expect(c.radius, closeTo(2.0, epsilon));
        expect(c.axisLength, closeTo(0.0, epsilon));
      });

      test('circle factory', () {
        final c = Capsule.circle(center: Point(1, 2), radius: 3);
        expect(c.center.x, closeTo(1.0, epsilon));
        expect(c.center.y, closeTo(2.0, epsilon));
        expect(c.axisLength, closeTo(0.0, epsilon));
        expect(c.radius, 3);
      });
    });

    group('properties', () {
      test('center', () {
        expect(hCap.center.x, closeTo(2.0, epsilon));
        expect(hCap.center.y, closeTo(0.0, epsilon));
      });

      test('axisLength', () {
        expect(hCap.axisLength, closeTo(4.0, epsilon));
      });

      test('totalLength', () {
        // axis(4) + diameter(2) = 6
        expect(hCap.totalLength, closeTo(6.0, epsilon));
      });

      test('totalWidth', () {
        expect(hCap.totalWidth, closeTo(2.0, epsilon));
      });
    });

    group('area', () {
      test('horizontal capsule area', () {
        // pi*r^2 + 2*r*axisLength = pi + 8
        expect(hCap.area, closeTo(pi + 8, epsilon));
      });

      test('circle capsule area equals pi*r^2', () {
        final c = Capsule.circle(center: Point(0, 0), radius: 2);
        expect(c.area, closeTo(pi * 4, epsilon));
      });
    });

    group('perimeter', () {
      test('horizontal capsule perimeter', () {
        // 2*pi*r + 2*axisLength = 2*pi + 8
        expect(hCap.perimeter, closeTo(2 * pi + 8, epsilon));
      });

      test('circle capsule perimeter equals 2*pi*r', () {
        final c = Capsule.circle(center: Point(0, 0), radius: 3);
        expect(c.perimeter, closeTo(2 * pi * 3, epsilon));
      });
    });

    group('contains', () {
      test('center is inside', () {
        expect(hCap.contains(hCap.center), isTrue);
      });

      test('point on medial axis inside', () {
        expect(hCap.contains(Point(1, 0)), isTrue);
      });

      test('point within radius of axis', () {
        expect(hCap.contains(Point(2, 0.5)), isTrue);
      });

      test('point on boundary', () {
        expect(hCap.contains(Point(2, 1)), isTrue);
      });

      test('point outside', () {
        expect(hCap.contains(Point(2, 2)), isFalse);
      });

      test('point in semicircle cap', () {
        expect(hCap.contains(Point(-0.5, 0)), isTrue);
      });

      test('point outside cap', () {
        expect(hCap.contains(Point(-2, 0)), isFalse);
      });
    });

    group('boundingBox', () {
      test('horizontal capsule bounding box', () {
        final bb = hCap.boundingBox;
        expect(bb.x, closeTo(-1.0, epsilon));
        expect(bb.y, closeTo(-1.0, epsilon));
        expect(bb.width, closeTo(6.0, epsilon));
        expect(bb.height, closeTo(2.0, epsilon));
      });

      test('circle capsule bounding box', () {
        final c = Capsule.circle(center: Point(0, 0), radius: 2);
        final bb = c.boundingBox;
        expect(bb.x, closeTo(-2.0, epsilon));
        expect(bb.y, closeTo(-2.0, epsilon));
        expect(bb.width, closeTo(4.0, epsilon));
        expect(bb.height, closeTo(4.0, epsilon));
      });
    });

    group('endCaps', () {
      test('returns two circles at endpoints', () {
        final caps = hCap.endCaps;
        expect(caps, hasLength(2));
        expect(caps[0].center, Point(0, 0));
        expect(caps[1].center, Point(4, 0));
        expect(caps[0].radius, 1);
      });
    });

    group('translate', () {
      test('translate moves capsule', () {
        final moved = hCap.translate(x: 5, y: 10);
        expect(moved.medialAxis.a, Point(5, 10));
        expect(moved.medialAxis.b, Point(9, 10));
        expect(moved.radius, 1);
      });

      test('translate preserves area', () {
        final moved = hCap.translate(x: 100, y: 200);
        expect(moved.area, closeTo(hCap.area, epsilon));
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final scaled = hCap.scale(2);
        expect(scaled.radius, closeTo(2.0, epsilon));
        expect(scaled.axisLength, closeTo(8.0, epsilon));
      });

      test('scale quadruples area', () {
        final scaled = hCap.scale(2);
        expect(scaled.area, closeTo(hCap.area * 4, epsilon));
      });
    });

    group('rotate', () {
      test('rotate 360 returns approximately same capsule', () {
        final rotated = hCap.rotate(360);
        expect(rotated.medialAxis.a.x, closeTo(hCap.medialAxis.a.x, epsilon));
        expect(rotated.medialAxis.a.y, closeTo(hCap.medialAxis.a.y, epsilon));
        expect(rotated.medialAxis.b.x, closeTo(hCap.medialAxis.b.x, epsilon));
        expect(rotated.medialAxis.b.y, closeTo(hCap.medialAxis.b.y, epsilon));
      });
    });

    group('equality', () {
      test('same capsule is equal', () {
        final c2 =
            Capsule(medialAxis: Line(Point(0, 0), Point(4, 0)), radius: 1);
        expect(hCap, equals(c2));
      });

      test('different capsule is not equal', () {
        final c2 =
            Capsule(medialAxis: Line(Point(0, 0), Point(4, 0)), radius: 2);
        expect(hCap, isNot(equals(c2)));
      });
    });

    group('toString', () {
      test('includes medialAxis and radius', () {
        final s = hCap.toString();
        expect(s, contains('Capsule'));
        expect(s, contains('radius'));
      });
    });
  });
}
