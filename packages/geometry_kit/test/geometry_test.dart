import 'package:geometry_kit/geometry_kit.dart';
import 'package:test/test.dart';

void main() {
  final all = <Geometry>[
    const Circle(center: Point(0, 0), radius: 2),
    const Ellipse(center: Point(0, 0), radiusX: 3, radiusY: 1),
    const Rectangle(x: 0, y: 0, width: 4, height: 2),
    Triangle(const Point(0, 0), const Point(4, 0), const Point(0, 3)),
    const Quadrilateral(Point(0, 0), Point(4, 0), Point(4, 2), Point(0, 2)),
    Polygon(const [Point(0, 0), Point(4, 0), Point(2, 3)]),
    const Capsule(medialAxis: Line(Point(0, 0), Point(4, 0)), radius: 1),
    const Line(Point(0, 0), Point(4, 3)),
    Polyline(const [Point(0, 0), Point(1, 1), Point(2, 0)]),
    Arc.fromDegrees(
      center: const Point(0, 0),
      radius: 2,
      startDeg: 0,
      endDeg: 90,
    ),
    Ray.fromAngle(const Point(0, 0), 30),
    const Ring(center: Point(0, 0), innerRadius: 1, outerRadius: 2),
    const QuadraticBezier(
      start: Point(0, 0),
      control: Point(1, 2),
      end: Point(2, 0),
    ),
    const CubicBezier(
      start: Point(0, 0),
      control1: Point(0, 2),
      control2: Point(2, 2),
      end: Point(2, 0),
    ),
    Spline(const [Point(0, 0), Point(1, 2), Point(3, 1)]),
  ];

  group('Geometry', () {
    test('every 2D type is a Geometry; only closed ones are Shapes', () {
      final shapes = all.whereType<Shape>().map((g) => g.runtimeType);
      expect(shapes, [
        Circle,
        Ellipse,
        Rectangle,
        Triangle,
        Quadrilateral,
        Polygon,
        Capsule,
      ]);
    });

    test('translate keeps the concrete type', () {
      for (final g in all) {
        expect(g.translate(x: 1, y: 2).runtimeType, g.runtimeType);
      }
    });

    test('translate by zero is equal, with an equal hash', () {
      for (final g in all) {
        final copy = g.translate();
        expect(copy, g, reason: '${g.runtimeType}');
        expect(copy.hashCode, g.hashCode, reason: '${g.runtimeType}');
      }
    });

    test('Spline hash follows its points, not the list instance', () {
      // Used to hash the list's identity, so equal splines hashed apart.
      final a = Spline([const Point(0, 0), const Point(1, 2)]);
      final b = Spline([const Point(0, 0), const Point(1, 2)]);
      expect(a, b);
      expect({a, b}, hasLength(1));
    });

    test('hashes are order-sensitive, matching ==', () {
      // XOR folds made swapped or repeated parts collide.
      expect(const Point(1, 2).hashCode, isNot(const Point(2, 1).hashCode));
      expect(
        const Line(Point(0, 0), Point(1, 1)).hashCode,
        isNot(const Line(Point(1, 1), Point(0, 0)).hashCode),
      );
      expect(
        Polygon(const [Point(0, 0), Point(1, 0), Point(0, 0), Point(1, 0)])
            .hashCode,
        isNot(0),
      );
    });

    test('Triangle and Polygon compare by vertices, in order', () {
      Triangle tri() => Triangle(
            const Point(0, 0),
            const Point(4, 0),
            const Point(0, 3),
          );
      expect(tri(), tri());
      expect(tri().hashCode, tri().hashCode);
      expect(
        tri(),
        isNot(
            Triangle(const Point(4, 0), const Point(0, 3), const Point(0, 0))),
      );

      Polygon poly() => Polygon(const [Point(0, 0), Point(4, 0), Point(2, 3)]);
      expect(poly(), poly());
      expect(poly().hashCode, poly().hashCode);
      expect(
        poly(),
        isNot(Polygon(const [Point(0, 0), Point(4, 0), Point(2, 4)])),
      );
      expect(
        poly(),
        isNot(Polygon(
            const [Point(0, 0), Point(4, 0), Point(2, 3), Point(1, 1)])),
      );
    });

    test('Spline.translate moves every control point', () {
      final s = Spline(const [Point(0, 0), Point(1, 2)], alpha: 0.25);
      final moved = s.translate(x: 3, y: -1);
      expect(moved.controlPoints, const [Point(3, -1), Point(4, 1)]);
      expect(moved.alpha, 0.25);
    });
  });
}
