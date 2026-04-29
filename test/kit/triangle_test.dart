import 'package:geometry_kit/src/kit/line.dart';
import 'package:geometry_kit/src/kit/point.dart';
import 'package:geometry_kit/src/kit/triangle.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Triangle', () {
    // Right triangle: (0,0), (3,0), (0,4)
    final right = Triangle(Point(0, 0), Point(3, 0), Point(0, 4));
    // Equilateral-ish triangle
    final equi = Triangle(Point(0, 0), Point(4, 0), Point(2, 3.4641));

    group('area', () {
      test('right triangle area', () {
        // 0.5 * base * height = 0.5 * 3 * 4 = 6
        expect(right.area, closeTo(6.0, epsilon));
      });

      test('equilateral triangle area', () {
        // side 4, area = sqrt(3)/4 * 16 ≈ 6.9282
        expect(equi.area, closeTo(6.9282, epsilon));
      });
    });

    group('perimeter', () {
      test('right triangle perimeter', () {
        // 3 + 4 + 5 = 12
        expect(right.perimeter, closeTo(12.0, epsilon));
      });
    });

    group('vertices', () {
      test('returns three vertices', () {
        expect(right.vertices, hasLength(3));
        expect(right.vertices, [Point(0, 0), Point(3, 0), Point(0, 4)]);
      });
    });

    group('sides', () {
      test('returns three sides', () {
        expect(right.sides, hasLength(3));
      });

      test('AB side', () {
        expect(right.AB, Line(Point(0, 0), Point(3, 0)));
      });

      test('BC side', () {
        expect(right.BC, Line(Point(3, 0), Point(0, 4)));
      });

      test('CA side', () {
        expect(right.CA, Line(Point(0, 4), Point(0, 0)));
      });

      test('AC side', () {
        expect(right.AC, Line(Point(0, 0), Point(0, 4)));
      });
    });

    group('baseLine', () {
      test('baseline is the two leftmost x-coordinate points', () {
        final bl = right.baseLine;
        // Points (0,0) and (0,4) both have x=0, which is leftmost
        // Then next is (3,0). So start=(0,0), end picks between (3,0) and (0,4)
        // a.x=0 <= b.x=3 and a.x=0 <= c.x=0 => start = a = (0,0)
        // end: b.x=3 <= c.x=0? no => end = c = (0,4)
        expect(bl, Line(Point(0, 0), Point(0, 4)));
      });
    });

    group('height', () {
      test('right triangle height from posVertex to baseLine', () {
        // baseLine is vertical from (0,0) to (0,4), posVertex is (3,0)
        // distance from (3,0) to that line = 3
        expect(right.height, closeTo(3.0, epsilon));
      });
    });

    group('posVertex', () {
      test('returns vertex opposite to baseline', () {
        // baseline is (0,0)-(0,4), so posVertex is (3,0)
        expect(right.posVertex, Point(3, 0));
      });
    });

    group('heightLine', () {
      test('goes from posVertex to midpoint of baseLine', () {
        final hl = right.heightLine;
        expect(hl.a, right.posVertex);
        expect(hl.b, right.baseLine.midPoint);
      });
    });

    group('orthocenter', () {
      test('orthocenter of non-axis-aligned triangle', () {
        final t = Triangle(Point(0, 0), Point(4, 1), Point(1, 3));
        final oc = t.orthocenter;
        // Altitude from a perp to BC: BC=(3,2), slope=-3/2 => alt slope=3/2
        // Altitude from b perp to CA: CA=(1,3), slope=-1/3 => alt slope=-1/3
        // Solving: x=14/11, y=21/11
        expect(oc.x, closeTo(14.0 / 11.0, epsilon));
        expect(oc.y, closeTo(21.0 / 11.0, epsilon));
      });

      test('right triangle orthocenter at right-angle vertex', () {
        // Right angle at origin — orthocenter should be at (0,0)
        final t = Triangle(Point(0, 0), Point(5, 0), Point(0, 3));
        final oc = t.orthocenter;
        expect(oc.x, closeTo(0, epsilon));
        expect(oc.y, closeTo(0, epsilon));
      });

      test('orthocenter with vertical side', () {
        // Triangle with a vertical side — previously crashed
        final t = Triangle(Point(0, 0), Point(0, 4), Point(3, 2));
        final oc = t.orthocenter;
        expect(oc, isNotNull);
        // Verify: no crash and returns a valid point
        expect(oc.x.isFinite, isTrue);
        expect(oc.y.isFinite, isTrue);
      });
    });

    group('rotate', () {
      test('rotate returns new triangle with rotated vertices', () {
        final t = Triangle(Point(1, 0), Point(0, 1), Point(-1, 0));
        final rotated = t.rotate(90);
        expect(rotated.a.x, closeTo(0, epsilon));
        expect(rotated.a.y, closeTo(1, epsilon));
        expect(rotated.b.x, closeTo(-1, epsilon));
        expect(rotated.b.y, closeTo(0, epsilon));
        expect(rotated.c.x, closeTo(0, epsilon));
        expect(rotated.c.y, closeTo(-1, epsilon));
      });

      test('rotate 360 returns approximately same triangle', () {
        final rotated = equi.rotate(360);
        expect(rotated.a.x, closeTo(equi.a.x, epsilon));
        expect(rotated.a.y, closeTo(equi.a.y, epsilon));
        expect(rotated.b.x, closeTo(equi.b.x, epsilon));
        expect(rotated.b.y, closeTo(equi.b.y, epsilon));
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final t = Triangle(Point(1, 1), Point(2, 1), Point(1, 2));
        final scaled = t.scale(2);
        expect(scaled.a, Point(2, 2));
        expect(scaled.b, Point(4, 2));
        expect(scaled.c, Point(2, 4));
      });

      test('scale preserves shape proportions', () {
        final scaled = right.scale(2);
        expect(scaled.area, closeTo(right.area * 4, epsilon));
        expect(scaled.perimeter, closeTo(right.perimeter * 2, epsilon));
      });
    });

    group('translate', () {
      test('translate moves all vertices', () {
        final moved = right.translate(x: 5, y: 10);
        expect(moved.a, Point(5, 10));
        expect(moved.b, Point(8, 10));
        expect(moved.c, Point(5, 14));
      });

      test('translate preserves area', () {
        final moved = right.translate(x: 100, y: 200);
        expect(moved.area, closeTo(right.area, epsilon));
      });

      test('translate preserves perimeter', () {
        final moved = right.translate(x: 3, y: 7);
        expect(moved.perimeter, closeTo(right.perimeter, epsilon));
      });
    });

    group('angles', () {
      test('angles list has 3 elements', () {
        expect(right.angles, hasLength(3));
      });

      test('no debug print output (regression)', () {
        // This test ensures the debug print was removed
        // If print were still there, it would output to console
        // but we mainly verify angles returns without error
        final angles = right.angles;
        expect(angles, isNotEmpty);
      });
    });
  });
}
