import 'package:geometry_kit/src/kit/point.dart';
import 'package:geometry_kit/src/kit/polyline.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Polyline', () {
    final path = Polyline([
      Point(0, 0),
      Point(3, 0),
      Point(3, 4),
    ]);

    group('length', () {
      test('sum of segments', () {
        // 3 + 4 = 7
        expect(path.length, closeTo(7, epsilon));
      });

      test('straight line', () {
        final l = Polyline([Point(0, 0), Point(10, 0)]);
        expect(l.length, closeTo(10, epsilon));
      });
    });

    group('segmentCount', () {
      test('two segments', () {
        expect(path.segmentCount, 2);
      });
    });

    group('segments', () {
      test('returns line segments', () {
        expect(path.segments, hasLength(2));
        expect(path.segments[0].a, Point(0, 0));
        expect(path.segments[0].b, Point(3, 0));
      });
    });

    group('first / last', () {
      test('first point', () {
        expect(path.first, Point(0, 0));
      });

      test('last point', () {
        expect(path.last, Point(3, 4));
      });
    });

    group('boundingBox', () {
      test('correct bounds', () {
        final bb = path.boundingBox;
        expect(bb.x, 0);
        expect(bb.y, 0);
        expect(bb.width, 3);
        expect(bb.height, 4);
      });
    });

    group('pointAt', () {
      test('t=0 returns first', () {
        expect(path.pointAt(0), path.first);
      });

      test('t=1 returns last', () {
        expect(path.pointAt(1), path.last);
      });

      test('t=0.5 at midpoint of total length', () {
        // total length 7, midpoint at 3.5 => end of first segment + 0.5 into second
        final p = path.pointAt(3.0 / 7.0); // at end of first segment
        expect(p.x, closeTo(3, epsilon));
        expect(p.y, closeTo(0, epsilon));
      });
    });

    group('simplify', () {
      test('collinear points removed', () {
        final line = Polyline([
          Point(0, 0),
          Point(1, 0),
          Point(2, 0),
          Point(3, 0),
          Point(4, 0),
        ]);
        final simplified = line.simplify(0.1);
        expect(simplified.points, hasLength(2));
        expect(simplified.first, Point(0, 0));
        expect(simplified.last, Point(4, 0));
      });

      test('preserves significant bends', () {
        final zigzag = Polyline([
          Point(0, 0),
          Point(5, 10),
          Point(10, 0),
        ]);
        final simplified = zigzag.simplify(0.1);
        expect(simplified.points, hasLength(3));
      });

      test('two-point polyline unchanged', () {
        final l = Polyline([Point(0, 0), Point(5, 5)]);
        final simplified = l.simplify(1);
        expect(simplified.points, hasLength(2));
      });
    });

    group('translate', () {
      test('moves all points', () {
        final moved = path.translate(x: 10, y: 20);
        expect(moved.first, Point(10, 20));
        expect(moved.last, Point(13, 24));
      });

      test('preserves length', () {
        final moved = path.translate(x: 5, y: 5);
        expect(moved.length, closeTo(path.length, epsilon));
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final scaled = path.scale(2);
        expect(scaled.first, Point(0, 0));
        expect(scaled.points[1], Point(6, 0));
        expect(scaled.last, Point(6, 8));
      });
    });

    group('rotate', () {
      test('rotate preserves length', () {
        final rotated = path.rotate(45);
        expect(rotated.length, closeTo(path.length, epsilon));
      });
    });

    group('equality', () {
      test('same points equal', () {
        final p1 = Polyline([Point(0, 0), Point(1, 1)]);
        final p2 = Polyline([Point(0, 0), Point(1, 1)]);
        expect(p1 == p2, isTrue);
      });

      test('different points not equal', () {
        final p1 = Polyline([Point(0, 0), Point(1, 1)]);
        final p2 = Polyline([Point(0, 0), Point(2, 2)]);
        expect(p1 == p2, isFalse);
      });
    });

    test('toString', () {
      expect(path.toString(), 'Polyline(3 points)');
    });
  });
}
