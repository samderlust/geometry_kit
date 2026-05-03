import 'package:geometry_kit/geometry_kit.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Quadrilateral', () {
    // Square: (0,0), (4,0), (4,4), (0,4)
    final square = Quadrilateral(Point(0, 0), Point(4, 0), Point(4, 4), Point(0, 4));

    // Rectangle: (0,0), (6,0), (6,3), (0,3)
    final rect = Quadrilateral(Point(0, 0), Point(6, 0), Point(6, 3), Point(0, 3));

    // Rhombus (non-square): diagonals 4 (horizontal) and 6 (vertical)
    // side length = sqrt(2^2 + 3^2) = sqrt(13)
    final rhombus = Quadrilateral(Point(2, 0), Point(0, 3), Point(-2, 0), Point(0, -3));

    // Parallelogram: (0,0), (5,0), (6,3), (1,3)
    final para = Quadrilateral(Point(0, 0), Point(5, 0), Point(6, 3), Point(1, 3));

    // Trapezoid: (1,0), (5,0), (4,3), (2,3)
    final trap = Quadrilateral(Point(1, 0), Point(5, 0), Point(4, 3), Point(2, 3));

    // Kite: (2,0), (4,2), (2,5), (0,2)
    final kite = Quadrilateral(Point(2, 0), Point(4, 2), Point(2, 5), Point(0, 2));

    group('vertices', () {
      test('returns four vertices', () {
        expect(square.vertices, hasLength(4));
      });
    });

    group('sides', () {
      test('returns four sides', () {
        expect(square.sides, hasLength(4));
      });

      test('named side accessors', () {
        expect(square.AB, Line(Point(0, 0), Point(4, 0)));
        expect(square.BC, Line(Point(4, 0), Point(4, 4)));
        expect(square.CD, Line(Point(4, 4), Point(0, 4)));
        expect(square.DA, Line(Point(0, 4), Point(0, 0)));
      });
    });

    group('diagonals', () {
      test('diagonalAC', () {
        expect(square.diagonalAC, Line(Point(0, 0), Point(4, 4)));
      });

      test('diagonalBD', () {
        expect(square.diagonalBD, Line(Point(4, 0), Point(0, 4)));
      });
    });

    group('area', () {
      test('square area', () {
        expect(square.area, closeTo(16.0, epsilon));
      });

      test('rectangle area', () {
        expect(rect.area, closeTo(18.0, epsilon));
      });

      test('parallelogram area', () {
        expect(para.area, closeTo(15.0, epsilon));
      });
    });

    group('perimeter', () {
      test('square perimeter', () {
        expect(square.perimeter, closeTo(16.0, epsilon));
      });

      test('rectangle perimeter', () {
        expect(rect.perimeter, closeTo(18.0, epsilon));
      });
    });

    group('center', () {
      test('square center', () {
        expect(square.center.x, closeTo(2.0, epsilon));
        expect(square.center.y, closeTo(2.0, epsilon));
      });
    });

    group('isParallelogram', () {
      test('square is parallelogram', () {
        expect(square.isParallelogram, isTrue);
      });

      test('rectangle is parallelogram', () {
        expect(rect.isParallelogram, isTrue);
      });

      test('rhombus is parallelogram', () {
        expect(rhombus.isParallelogram, isTrue);
      });

      test('parallelogram is parallelogram', () {
        expect(para.isParallelogram, isTrue);
      });

      test('trapezoid is not parallelogram', () {
        expect(trap.isParallelogram, isFalse);
      });
    });

    group('isRhombus', () {
      test('rhombus returns true', () {
        expect(rhombus.isRhombus, isTrue);
      });

      test('square is rhombus', () {
        expect(square.isRhombus, isTrue);
      });

      test('rectangle is not rhombus (unless square)', () {
        expect(rect.isRhombus, isFalse);
      });
    });

    group('isTrapezoid', () {
      test('trapezoid returns true', () {
        expect(trap.isTrapezoid, isTrue);
      });

      test('parallelogram is also trapezoid', () {
        expect(para.isTrapezoid, isTrue);
      });
    });

    group('isKite', () {
      test('kite returns true', () {
        expect(kite.isKite, isTrue);
      });

      test('square is kite', () {
        expect(square.isKite, isTrue);
      });

      test('rectangle is not kite (unless square)', () {
        expect(rect.isKite, isFalse);
      });
    });

    group('isRectangle', () {
      test('rectangle returns true', () {
        expect(rect.isRectangle, isTrue);
      });

      test('square is rectangle', () {
        expect(square.isRectangle, isTrue);
      });

      test('rhombus is not rectangle (unless square)', () {
        expect(rhombus.isRectangle, isFalse);
      });
    });

    group('isSquare', () {
      test('square returns true', () {
        expect(square.isSquare, isTrue);
      });

      test('rectangle is not square', () {
        expect(rect.isSquare, isFalse);
      });

      test('rhombus is not square', () {
        expect(rhombus.isSquare, isFalse);
      });
    });

    group('isConvex', () {
      test('square is convex', () {
        expect(square.isConvex, isTrue);
      });

      test('concave quadrilateral', () {
        // "arrow" shape
        final concave =
            Quadrilateral(Point(0, 0), Point(4, 0), Point(2, 1), Point(2, 4));
        expect(concave.isConvex, isFalse);
      });
    });

    group('contains', () {
      test('center is inside', () {
        expect(square.contains(square.center), isTrue);
      });

      test('vertex is on boundary', () {
        expect(square.contains(Point(0, 0)), isTrue);
      });

      test('point outside', () {
        expect(square.contains(Point(10, 10)), isFalse);
      });

      test('point inside parallelogram', () {
        expect(para.contains(Point(3, 1.5)), isTrue);
      });
    });

    group('translate', () {
      test('translate moves all vertices', () {
        final moved = square.translate(x: 5, y: 10);
        expect(moved.a, Point(5, 10));
        expect(moved.b, Point(9, 10));
        expect(moved.c, Point(9, 14));
        expect(moved.d, Point(5, 14));
      });

      test('translate preserves area', () {
        final moved = square.translate(x: 100, y: 200);
        expect(moved.area, closeTo(square.area, epsilon));
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final scaled = square.scale(2);
        expect(scaled.a, Point(0, 0));
        expect(scaled.b, Point(8, 0));
        expect(scaled.c, Point(8, 8));
        expect(scaled.d, Point(0, 8));
      });

      test('scale quadruples area', () {
        final scaled = square.scale(2);
        expect(scaled.area, closeTo(square.area * 4, epsilon));
      });
    });

    group('rotate', () {
      test('rotate 360 returns approximately same', () {
        final rotated = square.rotate(360);
        expect(rotated.a.x, closeTo(square.a.x, epsilon));
        expect(rotated.a.y, closeTo(square.a.y, epsilon));
      });
    });

    group('equality', () {
      test('same quadrilateral is equal', () {
        final q2 =
            Quadrilateral(Point(0, 0), Point(4, 0), Point(4, 4), Point(0, 4));
        expect(square, equals(q2));
      });

      test('different quadrilateral is not equal', () {
        expect(square, isNot(equals(rect)));
      });

      test('hashCode consistent', () {
        final q2 =
            Quadrilateral(Point(0, 0), Point(4, 0), Point(4, 4), Point(0, 4));
        expect(square.hashCode, equals(q2.hashCode));
      });
    });

    group('toString', () {
      test('contains Quadrilateral', () {
        expect(square.toString(), contains('Quadrilateral'));
      });
    });
  });
}
