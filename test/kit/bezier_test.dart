import 'package:geometry_kit/src/kit/bezier.dart';
import 'package:geometry_kit/src/kit/point.dart';
import 'package:test/test.dart';

const epsilon = 0.01;

void main() {
  group('QuadraticBezier', () {
    final quad = QuadraticBezier(
      start: Point(0, 0),
      control: Point(5, 10),
      end: Point(10, 0),
    );

    group('pointAt', () {
      test('t=0 returns start', () {
        expect(quad.pointAt(0), quad.start);
      });

      test('t=1 returns end', () {
        expect(quad.pointAt(1), quad.end);
      });

      test('t=0.5 is at peak', () {
        final mid = quad.pointAt(0.5);
        expect(mid.x, closeTo(5, epsilon));
        expect(mid.y, closeTo(5, epsilon));
      });
    });

    group('boundingBox', () {
      test('contains all sampled points', () {
        final bb = quad.boundingBox;
        for (double t = 0; t <= 1; t += 0.1) {
          final p = quad.pointAt(t);
          expect(p.x, greaterThanOrEqualTo(bb.x - epsilon));
          expect(p.x, lessThanOrEqualTo(bb.x + bb.width + epsilon));
          expect(p.y, greaterThanOrEqualTo(bb.y - epsilon));
          expect(p.y, lessThanOrEqualTo(bb.y + bb.height + epsilon));
        }
      });
    });

    group('length', () {
      test('positive length', () {
        expect(quad.length, greaterThan(0));
      });

      test('straight line bezier equals distance', () {
        final straight = QuadraticBezier(
          start: Point(0, 0),
          control: Point(5, 0),
          end: Point(10, 0),
        );
        expect(straight.length, closeTo(10, epsilon));
      });
    });

    group('split', () {
      test('split at 0.5 produces two curves', () {
        final parts = quad.split(0.5);
        expect(parts, hasLength(2));
      });

      test('split point is shared', () {
        final parts = quad.split(0.5);
        expect(parts[0].end.x, closeTo(parts[1].start.x, epsilon));
        expect(parts[0].end.y, closeTo(parts[1].start.y, epsilon));
      });

      test('split preserves endpoints', () {
        final parts = quad.split(0.3);
        expect(parts[0].start, quad.start);
        expect(parts[1].end, quad.end);
      });
    });

    group('translate', () {
      test('moves all points', () {
        final moved = quad.translate(x: 10, y: 20);
        expect(moved.start, Point(10, 20));
        expect(moved.end, Point(20, 20));
      });
    });

    group('equality', () {
      test('same curves equal', () {
        final q1 = QuadraticBezier(start: Point(0, 0), control: Point(5, 10), end: Point(10, 0));
        final q2 = QuadraticBezier(start: Point(0, 0), control: Point(5, 10), end: Point(10, 0));
        expect(q1 == q2, isTrue);
      });
    });
  });

  group('CubicBezier', () {
    final cubic = CubicBezier(
      start: Point(0, 0),
      control1: Point(3, 10),
      control2: Point(7, 10),
      end: Point(10, 0),
    );

    group('pointAt', () {
      test('t=0 returns start', () {
        expect(cubic.pointAt(0), cubic.start);
      });

      test('t=1 returns end', () {
        expect(cubic.pointAt(1), cubic.end);
      });

      test('t=0.5 is near peak', () {
        final mid = cubic.pointAt(0.5);
        expect(mid.x, closeTo(5, epsilon));
        expect(mid.y, greaterThan(0));
      });
    });

    group('boundingBox', () {
      test('contains all control points', () {
        final bb = cubic.boundingBox;
        for (final p in [cubic.start, cubic.control1, cubic.control2, cubic.end]) {
          expect(p.x, greaterThanOrEqualTo(bb.x - epsilon));
          expect(p.x, lessThanOrEqualTo(bb.x + bb.width + epsilon));
        }
      });
    });

    group('length', () {
      test('positive length', () {
        expect(cubic.length, greaterThan(0));
      });

      test('straight line bezier equals distance', () {
        final straight = CubicBezier(
          start: Point(0, 0),
          control1: Point(3, 0),
          control2: Point(7, 0),
          end: Point(10, 0),
        );
        expect(straight.length, closeTo(10, epsilon));
      });
    });

    group('split', () {
      test('split at 0.5 produces two curves', () {
        final parts = cubic.split(0.5);
        expect(parts, hasLength(2));
      });

      test('split preserves endpoints', () {
        final parts = cubic.split(0.4);
        expect(parts[0].start, cubic.start);
        expect(parts[1].end, cubic.end);
      });

      test('split point shared between halves', () {
        final parts = cubic.split(0.5);
        expect(parts[0].end.x, closeTo(parts[1].start.x, epsilon));
        expect(parts[0].end.y, closeTo(parts[1].start.y, epsilon));
      });
    });

    group('translate', () {
      test('moves all points', () {
        final moved = cubic.translate(x: 5, y: 5);
        expect(moved.start, Point(5, 5));
        expect(moved.end, Point(15, 5));
      });
    });

    group('equality', () {
      test('same curves equal', () {
        final c1 = CubicBezier(
          start: Point(0, 0), control1: Point(3, 10),
          control2: Point(7, 10), end: Point(10, 0),
        );
        final c2 = CubicBezier(
          start: Point(0, 0), control1: Point(3, 10),
          control2: Point(7, 10), end: Point(10, 0),
        );
        expect(c1 == c2, isTrue);
      });
    });
  });
}
