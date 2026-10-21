import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:test/test.dart';

/// Every solid, placed and oriented so no axis is special.
List<Solid> get _solids {
  final lShape = Polygon(const [
    Point(0, 0),
    Point(6, 0),
    Point(6, 3),
    Point(3.5, 3),
    Point(3.5, 5),
    Point(0, 5),
  ]);
  return [
    const Sphere(center: Point3(1, 2, 3), radius: 1.5),
    Box(center: const Point3(1, -1, 2), width: 2, height: 1, depth: 3)
        .rotate(const Point3(1, 2, 0.5), 33),
    Cylinder(
        baseCenter: const Point3(0, 1, 0),
        radius: 0.7,
        height: 2,
        axis: const Point3(1, 1, 0)),
    Cone(
        baseCenter: const Point3(-1, 0, 1),
        radius: 1,
        height: 2,
        axis: const Point3(0, 1, 1)),
    Prism.extrude(lShape, height: 2.7).rotate(const Point3(0, 1, 0), 20),
    SolidOfRevolution(const [
      Point(0.55, 0),
      Point(0.85, 0.7),
      Point(0.32, 1.5),
      Point(0.5, 1.9),
    ], origin: const Point3(0.2, 0.1, -0.3), axis: const Point3(0.2, 1, 0)),
  ];
}

void main() {
  group('closed-form measures', () {
    test('sphere', () {
      const s = Sphere(center: Point3.zero, radius: 2);
      expect(s.volume, closeTo(32 / 3 * pi, 1e-12));
      expect(s.surfaceArea, closeTo(16 * pi, 1e-12));
    });

    test('box', () {
      const b = Box(center: Point3.zero, width: 2, height: 3, depth: 4);
      expect(b.volume, 24);
      expect(b.surfaceArea, 52);
      expect(
          Box.fromBase(center: Point3.zero, width: 1, depth: 1, height: 2)
              .bounds,
          const Aabb(Point3(-0.5, 0, -0.5), Point3(0.5, 2, 0.5)));
    });

    test('cylinder and cone agree with the meridian formulas', () {
      final c = Cylinder(baseCenter: Point3.zero, radius: 1, height: 2);
      expect(c.volume, closeTo(2 * pi, 1e-12));
      expect(c.surfaceArea, closeTo(6 * pi, 1e-12));
      final k = Cone(baseCenter: Point3.zero, radius: 1, height: 2);
      expect(k.volume, closeTo(2 * pi / 3, 1e-12));
      expect(k.halfAngle, closeTo(26.565051177, 1e-6));
      // RevolvedSolid's generic formulas must match the closed forms.
      final generic = SolidOfRevolution(const [Point(1, 0), Point(0, 2)]);
      expect(generic.volume, closeTo(k.volume, 1e-12));
      expect(generic.surfaceArea, closeTo(k.surfaceArea, 1e-12));
    });

    test('prism from an L-shaped plan', () {
      final plan = Polygon(const [
        Point(0, 0),
        Point(6, 0),
        Point(6, 3),
        Point(3.5, 3),
        Point(3.5, 5),
        Point(0, 5),
      ]);
      final room = Prism.extrude(plan, height: 2.7);
      expect(room.volume, closeTo(67.5, 1e-9));
      expect(room.lateralArea, closeTo(59.4, 1e-9));
      expect(room.contains(const Point3(1, 1, -1)), isTrue);
      expect(
          room.contains(const Point3(5, 1, -4)), isFalse); // the cut-out corner
      expect(room.bounds, const Aabb(Point3(0, 0, -5), Point3(6, 2.7, 0)));
    });
  });

  group('every solid', () {
    for (final solid in _solids) {
      final name = solid.runtimeType.toString();

      test('$name mesh is closed, outward, and matches volume and area', () {
        final mesh = solid.toMesh(segments: 256);
        expect(mesh.volume, greaterThan(0),
            reason: 'triangles must face outward');
        expect(mesh.volume, closeTo(solid.volume, solid.volume * 2e-3));
        expect(mesh.surfaceArea,
            closeTo(solid.surfaceArea, solid.surfaceArea * 2e-3));
      });

      test('$name bounds contain the mesh', () {
        final b = solid.bounds.expand(1e-9);
        expect(solid.toMesh(segments: 48).positions.every(b.contains), isTrue);
      });

      test('$name ray hits agree with contains and normals face the ray', () {
        final rnd = Random(7);
        final box = solid.bounds;
        final c = box.center;
        var hits = 0;
        for (var i = 0; i < 200; i++) {
          final dir = Point3(rnd.nextDouble() - .5, rnd.nextDouble() - .5,
                  rnd.nextDouble() - .5)
              .normalized;
          final aim = c +
              Point3(rnd.nextDouble() - .5, rnd.nextDouble() - .5,
                      rnd.nextDouble() - .5) *
                  box.size.magnitude *
                  0.4;
          final ray = Ray3(aim - dir * 20, dir);
          final hit = solid.intersectRay(ray);
          if (hit == null) continue;
          hits++;
          // Just before the hit we are outside, just after we are inside.
          expect(solid.contains(ray.pointAt(hit.distance - 1e-4)), isFalse);
          expect(solid.contains(ray.pointAt(hit.distance + 1e-4)), isTrue);
          expect(hit.normal.magnitude, closeTo(1, 1e-9));
          expect(hit.normal.dot(ray.direction), lessThan(1e-9));
          expect(solid.distanceTo(hit.point), closeTo(0, 1e-6));
        }
        expect(hits, greaterThan(20));
      });

      test('$name closestPoint is the nearest point of the solid', () {
        final rnd = Random(3);
        final b = solid.bounds;
        final surface = solid.toMesh(segments: 64).positions;
        for (var i = 0; i < 60; i++) {
          final p = b.center +
              Point3(rnd.nextDouble() - .5, rnd.nextDouble() - .5,
                      rnd.nextDouble() - .5) *
                  b.size.magnitude *
                  3;
          final q = solid.closestPoint(p);
          if (solid.contains(p)) {
            expect(q, p);
            continue;
          }
          expect(solid.distanceTo(q), closeTo(0, 1e-9));
          final d = q.distanceTo(p);
          for (final v in surface) {
            expect(v.distanceTo(p), greaterThanOrEqualTo(d - 1e-9));
          }
        }
      });

      test('$name transforms keep measures', () {
        final moved = solid.translate(x: 1, y: -2, z: 0.5).rotate(
            const Point3(0.3, 1, 0.2), 71,
            pivot: const Point3(1, 1, 1));
        expect(moved.volume, closeTo(solid.volume, 1e-9 * solid.volume));
        final scaled = solid.scale(2);
        expect(
            scaled.volume, closeTo(solid.volume * 8, 1e-9 * solid.volume * 8));
      });
    }
  });

  group('rays', () {
    test('sphere hit distance and normal', () {
      const s = Sphere(center: Point3.zero, radius: 1);
      final hit = s.intersectRay(Ray3(const Point3(0, 0, -5), Point3.unitZ))!;
      expect(hit.distance, closeTo(4, 1e-12));
      expect(hit.normal, const Point3(0, 0, -1));
      expect(
          s.intersectRay(Ray3(const Point3(0, 2, -5), Point3.unitZ)), isNull);
      final inside = s.intersectRay(Ray3(Point3.zero, Point3.unitX))!;
      expect(inside.distance, closeTo(1, 1e-12));
    });

    test('rotated box hit lands on its face', () {
      final b = const Box(center: Point3.zero, width: 2, height: 2, depth: 2)
          .rotate(Point3.unitY, 45);
      final hit = b.intersectRay(Ray3(const Point3(-5, 0, 0), Point3.unitX))!;
      expect(hit.distance, closeTo(5 - sqrt2, 1e-9));
    });

    test('cone side and base', () {
      final k = Cone(baseCenter: Point3.zero, radius: 1, height: 2);
      final base =
          k.intersectRay(Ray3(const Point3(0.2, -3, 0), Point3.unitY))!;
      expect(base.distance, closeTo(3, 1e-9));
      expect(base.normal, closeToPoint3(const Point3(0, -1, 0)));
      final side = k.intersectRay(Ray3(const Point3(-5, 1, 0), Point3.unitX))!;
      expect(side.point.x, closeTo(-0.5, 1e-9));
      // Above the apex the mirror nappe must not count.
      expect(
          k.intersectRay(Ray3(const Point3(-5, 3, 0), Point3.unitX)), isNull);
    });

    test('nearestHit picks the closest solid', () {
      const near = Sphere(center: Point3(0, 0, 2), radius: 0.5);
      const far = Sphere(center: Point3(0, 0, 6), radius: 0.5);
      final hit =
          nearestHit(Ray3(Point3.zero, Point3.unitZ), const [far, near])!;
      expect(hit.solid, near);
    });
  });

  group('contact', () {
    test('sphere against each solid', () {
      final crate =
          Box.fromMinMax(const Point3(0, 0, 0), const Point3(1, 1, 1));
      expect(
          const Sphere(center: Point3(1.2, 0.5, 0.5), radius: 0.3)
              .intersects(crate),
          isTrue);
      expect(
          const Sphere(center: Point3(1.4, 0.5, 0.5), radius: 0.3)
              .intersects(crate),
          isFalse);
      // Near the corner the box test must be exact, not just its bounds.
      expect(
          const Sphere(center: Point3(1.2, 1.2, 1.2), radius: 0.3)
              .intersects(crate),
          isFalse);
      final can = Cylinder(baseCenter: Point3.zero, radius: 1, height: 1);
      expect(
          const Sphere(center: Point3(1.5, 0.5, 0), radius: 0.6)
              .intersects(can),
          isTrue);
    });

    test('box separating axis test', () {
      const a = Box(center: Point3.zero, width: 2, height: 2, depth: 2);
      final b =
          const Box(center: Point3(2.2, 0, 0), width: 2, height: 2, depth: 2);
      expect(a.intersectsBox(b), isFalse);
      // Turned 45°, b's corner reaches into a.
      expect(
          a.intersectsBox(b.rotate(Point3.unitY, 45, pivot: b.center)), isTrue);
    });
  });
}

Matcher closeToPoint3(Point3 p, [double eps = 1e-9]) =>
    predicate<Point3>((q) => q.isCloseTo(p, eps), 'close to $p');
