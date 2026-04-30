import 'package:geometry_kit/geometry_kit.dart';
import 'package:test/test.dart';

const epsilon = 0.01;

void main() {
  group('Spline', () {
    final straight = Spline([Point(0, 0), Point(4, 0), Point(8, 0)]);
    final curve = Spline([Point(0, 0), Point(2, 4), Point(4, 0), Point(6, 4)]);

    group('constructors', () {
      test('stores control points', () {
        expect(straight.controlPoints, hasLength(3));
      });

      test('default alpha is 0.5', () {
        expect(straight.alpha, 0.5);
      });

      test('custom alpha', () {
        final s = Spline([Point(0, 0), Point(1, 1)], alpha: 1.0);
        expect(s.alpha, 1.0);
      });
    });

    group('length and segmentCount', () {
      test('length is number of control points', () {
        expect(straight.length, 3);
      });

      test('segmentCount', () {
        expect(straight.segmentCount, 2);
        expect(curve.segmentCount, 3);
      });
    });

    group('pointAt', () {
      test('t=0 returns first control point', () {
        final p = straight.pointAt(0);
        expect(p.x, closeTo(0, epsilon));
        expect(p.y, closeTo(0, epsilon));
      });

      test('t=segmentCount returns last control point', () {
        final p = straight.pointAt(2);
        expect(p.x, closeTo(8, epsilon));
        expect(p.y, closeTo(0, epsilon));
      });

      test('t=1 returns second control point', () {
        final p = straight.pointAt(1);
        expect(p.x, closeTo(4, epsilon));
        expect(p.y, closeTo(0, epsilon));
      });

      test('midpoint of segment on straight line', () {
        final p = straight.pointAt(0.5);
        expect(p.x, closeTo(2.0, 0.5));
        expect(p.y, closeTo(0.0, 0.5));
      });

      test('curve passes through control points', () {
        final p0 = curve.pointAt(0);
        final p1 = curve.pointAt(1);
        final p2 = curve.pointAt(2);
        final p3 = curve.pointAt(3);
        expect(p0.x, closeTo(0, epsilon));
        expect(p1.x, closeTo(2, epsilon));
        expect(p1.y, closeTo(4, epsilon));
        expect(p2.x, closeTo(4, epsilon));
        expect(p3.x, closeTo(6, epsilon));
      });
    });

    group('sample', () {
      test('sample returns correct count', () {
        final pts = straight.sample(10);
        expect(pts, hasLength(10));
      });

      test('first sample is first control point', () {
        final pts = straight.sample(5);
        expect(pts.first.x, closeTo(0, epsilon));
      });

      test('last sample is last control point', () {
        final pts = straight.sample(5);
        expect(pts.last.x, closeTo(8, epsilon));
      });

      test('sample 1 returns first point', () {
        final pts = straight.sample(1);
        expect(pts, hasLength(1));
        expect(pts.first.x, closeTo(0, epsilon));
      });
    });

    group('approximateLength', () {
      test('straight line length', () {
        final len = straight.approximateLength(samples: 200);
        expect(len, closeTo(8.0, 0.1));
      });

      test('curve is longer than straight distance', () {
        final len = curve.approximateLength();
        final directDist = curve.controlPoints.first
            .distanceTo(curve.controlPoints.last);
        expect(len, greaterThan(directDist));
      });
    });

    group('boundingBox', () {
      test('straight line bounding box', () {
        final bb = straight.boundingBox();
        expect(bb.min.x, closeTo(0, epsilon));
        expect(bb.min.y, closeTo(0, epsilon));
        expect(bb.max.x, closeTo(8, epsilon));
        expect(bb.max.y, closeTo(0, epsilon));
      });

      test('curve bounding box contains control points', () {
        final bb = curve.boundingBox();
        for (final p in curve.controlPoints) {
          expect(p.x, greaterThanOrEqualTo(bb.min.x - epsilon));
          expect(p.y, greaterThanOrEqualTo(bb.min.y - epsilon));
          expect(p.x, lessThanOrEqualTo(bb.max.x + epsilon));
          expect(p.y, lessThanOrEqualTo(bb.max.y + epsilon));
        }
      });
    });

    group('toPolyline', () {
      test('returns list of line segments', () {
        final lines = straight.toPolyline(samplesPerSegment: 10);
        expect(lines, isNotEmpty);
        // Consecutive lines share endpoints
        for (var i = 1; i < lines.length; i++) {
          expect(lines[i].a.x, closeTo(lines[i - 1].b.x, epsilon));
          expect(lines[i].a.y, closeTo(lines[i - 1].b.y, epsilon));
        }
      });
    });

    group('tangentAt', () {
      test('tangent on straight horizontal line points right', () {
        final t = straight.tangentAt(1);
        expect(t.x, closeTo(1, 0.1));
        expect(t.y, closeTo(0, 0.1));
      });
    });

    group('equality', () {
      test('same spline is equal', () {
        final s2 = Spline([Point(0, 0), Point(4, 0), Point(8, 0)]);
        expect(straight, equals(s2));
      });

      test('different spline is not equal', () {
        final s2 = Spline([Point(0, 0), Point(4, 1), Point(8, 0)]);
        expect(straight, isNot(equals(s2)));
      });
    });

    group('toString', () {
      test('contains point count', () {
        expect(straight.toString(), contains('3 points'));
      });
    });

    group('two-point spline', () {
      test('two points creates single segment', () {
        final s = Spline([Point(0, 0), Point(10, 0)]);
        expect(s.segmentCount, 1);
        expect(s.pointAt(0).x, closeTo(0, epsilon));
        expect(s.pointAt(1).x, closeTo(10, epsilon));
      });
    });
  });
}
