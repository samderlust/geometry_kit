import 'package:geometry_kit/src/kit/point.dart';
import 'package:geometry_kit/src/kit/rectangle.dart';
import 'package:test/test.dart';

const epsilon = 0.0001;

void main() {
  group('Rectangle', () {
    final rect = Rectangle(x: 0, y: 0, width: 4, height: 3);

    group('constructors', () {
      test('default constructor', () {
        expect(rect.x, 0);
        expect(rect.y, 0);
        expect(rect.width, 4);
        expect(rect.height, 3);
      });

      test('fromPoints', () {
        final r = Rectangle.fromPoints(Point(1, 1), Point(5, 4));
        expect(r.x, 1);
        expect(r.y, 1);
        expect(r.width, 4);
        expect(r.height, 3);
      });

      test('fromPoints reversed order', () {
        final r = Rectangle.fromPoints(Point(5, 4), Point(1, 1));
        expect(r.x, 1);
        expect(r.y, 1);
        expect(r.width, 4);
        expect(r.height, 3);
      });

      test('fromCenter', () {
        final r = Rectangle.fromCenter(
          center: Point(3, 2),
          width: 6,
          height: 4,
        );
        expect(r.x, 0);
        expect(r.y, 0);
        expect(r.width, 6);
        expect(r.height, 4);
      });

      test('square factory', () {
        final s = Rectangle.square(x: 0, y: 0, size: 5);
        expect(s.width, 5);
        expect(s.height, 5);
        expect(s.isSquare, isTrue);
      });
    });

    group('properties', () {
      test('area', () {
        expect(rect.area, 12);
      });

      test('perimeter', () {
        expect(rect.perimeter, 14);
      });

      test('center', () {
        expect(rect.center, Point(2, 1.5));
      });

      test('corners', () {
        expect(rect.bottomLeft, Point(0, 0));
        expect(rect.bottomRight, Point(4, 0));
        expect(rect.topLeft, Point(0, 3));
        expect(rect.topRight, Point(4, 3));
      });

      test('vertices returns 4 corners', () {
        expect(rect.vertices, hasLength(4));
      });

      test('edges returns 4 edges', () {
        expect(rect.edges, hasLength(4));
      });

      test('diagonal', () {
        expect(rect.diagonal, closeTo(5.0, epsilon));
      });

      test('isSquare false for rectangle', () {
        expect(rect.isSquare, isFalse);
      });

      test('isSquare true for square', () {
        final s = Rectangle(x: 0, y: 0, width: 3, height: 3);
        expect(s.isSquare, isTrue);
      });
    });

    group('contains', () {
      test('point inside', () {
        expect(rect.contains(Point(2, 1)), isTrue);
      });

      test('point outside', () {
        expect(rect.contains(Point(5, 5)), isFalse);
      });

      test('point on corner', () {
        expect(rect.contains(Point(0, 0)), isTrue);
      });

      test('point on edge', () {
        expect(rect.contains(Point(2, 0)), isTrue);
      });
    });

    group('overlaps', () {
      test('overlapping rectangles', () {
        final other = Rectangle(x: 2, y: 1, width: 4, height: 3);
        expect(rect.overlaps(other), isTrue);
      });

      test('non-overlapping rectangles', () {
        final other = Rectangle(x: 10, y: 10, width: 2, height: 2);
        expect(rect.overlaps(other), isFalse);
      });

      test('touching edges do not overlap', () {
        final other = Rectangle(x: 4, y: 0, width: 2, height: 2);
        expect(rect.overlaps(other), isFalse);
      });
    });

    group('toPolygon', () {
      test('returns polygon with 4 vertices', () {
        final poly = rect.toPolygon();
        expect(poly.vertices, hasLength(4));
      });
    });

    group('translate', () {
      test('moves position', () {
        final moved = rect.translate(x: 5, y: 10);
        expect(moved.x, 5);
        expect(moved.y, 10);
        expect(moved.width, 4);
        expect(moved.height, 3);
      });

      test('preserves area', () {
        final moved = rect.translate(x: 100, y: 200);
        expect(moved.area, rect.area);
      });
    });

    group('scale', () {
      test('scale by 2', () {
        final scaled = rect.scale(2);
        expect(scaled.width, 8);
        expect(scaled.height, 6);
        expect(scaled.x, 0);
        expect(scaled.y, 0);
      });

      test('scale quadruples area', () {
        final scaled = rect.scale(2);
        expect(scaled.area, closeTo(rect.area * 4, epsilon));
      });
    });

    group('rotate', () {
      test('rotate 0 returns same dimensions', () {
        final rotated = rect.rotate(0);
        expect(rotated.width, closeTo(rect.width, epsilon));
        expect(rotated.height, closeTo(rect.height, epsilon));
      });

      test('rotate 90 swaps width/height approximately', () {
        final r = Rectangle.fromCenter(
          center: Point(0, 0),
          width: 4,
          height: 2,
        );
        final rotated = r.rotate(90);
        expect(rotated.width, closeTo(2, epsilon));
        expect(rotated.height, closeTo(4, epsilon));
      });
    });

    group('equality', () {
      test('same rectangles are equal', () {
        final r1 = Rectangle(x: 0, y: 0, width: 4, height: 3);
        final r2 = Rectangle(x: 0, y: 0, width: 4, height: 3);
        expect(r1 == r2, isTrue);
      });

      test('different rectangles are not equal', () {
        final r1 = Rectangle(x: 0, y: 0, width: 4, height: 3);
        final r2 = Rectangle(x: 1, y: 0, width: 4, height: 3);
        expect(r1 == r2, isFalse);
      });

      test('hashCode consistent', () {
        final r1 = Rectangle(x: 0, y: 0, width: 4, height: 3);
        final r2 = Rectangle(x: 0, y: 0, width: 4, height: 3);
        expect(r1.hashCode, r2.hashCode);
      });
    });

    test('toString', () {
      expect(rect.toString(), 'Rectangle(x: 0.0, y: 0.0, width: 4.0, height: 3.0)');
    });
  });
}
