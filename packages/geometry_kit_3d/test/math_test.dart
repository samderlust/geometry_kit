import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:test/test.dart';

Matcher closeToPoint(Point3 p, [double eps = 1e-9]) =>
    predicate<Point3>((q) => q.isCloseTo(p, eps), 'close to $p');

void main() {
  group('Point3', () {
    test('arithmetic and length', () {
      const p = Point3(1, 2, 2);
      expect(p.magnitude, 3);
      expect(p + const Point3(1, 1, 1), const Point3(2, 3, 3));
      expect(-p, const Point3(-1, -2, -2));
      expect(p.normalized.magnitude, closeTo(1, 1e-12));
      expect(Point3.zero.normalized, Point3.zero);
    });

    test('cross product is right-handed', () {
      expect(Point3.unitX % Point3.unitY, Point3.unitZ);
      expect(Point3.unitY.cross(Point3.unitZ), Point3.unitX);
    });

    test('rotate follows the right-hand rule', () {
      expect(Point3.unitX.rotate(Point3.unitZ, 90), closeToPoint(Point3.unitY));
      expect(Point3.unitX.rotate(Point3.unitY, 90),
          closeToPoint(const Point3(0, 0, -1)));
      expect(
        const Point3(2, 0, 0)
            .rotate(Point3.unitZ, 180, pivot: const Point3(1, 0, 0)),
        closeToPoint(Point3.zero),
      );
    });

    test('anyPerpendicular is perpendicular and unit', () {
      for (final v in const [Point3.unitX, Point3.unitY, Point3(1, 2, 3)]) {
        final p = v.anyPerpendicular;
        expect(p.dot(v), closeTo(0, 1e-12));
        expect(p.magnitude, closeTo(1, 1e-12));
      }
    });

    test('equality and angle', () {
      expect(const Point3(1, 2, 3), const Point3(1, 2, 3));
      expect(const Point3(1, 2, 3).hashCode, const Point3(1, 2, 3).hashCode);
      expect(Point3.unitX.angleTo(Point3.unitY), closeTo(pi / 2, 1e-12));
    });
  });

  group('Quaternion', () {
    test('matches Point3.rotate', () {
      const v = Point3(1, 2, 3);
      const axis = Point3(1, 1, 0);
      final q = Quaternion.fromAxisAngle(axis, 37);
      expect(q.rotate(v), closeToPoint(v.rotate(axis, 37)));
    });

    test('composition and inverse', () {
      final a = Quaternion.fromAxisAngle(Point3.unitY, 90);
      final b = Quaternion.fromAxisAngle(Point3.unitX, 90);
      const v = Point3(0.3, -1, 2);
      expect((a * b).rotate(v), closeToPoint(a.rotate(b.rotate(v))));
      expect(a.conjugate.rotate(a.rotate(v)), closeToPoint(v));
    });
  });

  group('Plane', () {
    final ground = Plane.fromPointNormal(Point3.zero, Point3.unitY);

    test('distance and projection', () {
      expect(ground.signedDistanceTo(const Point3(3, 2, 1)), 2);
      expect(ground.signedDistanceTo(const Point3(3, -2, 1)), -2);
      expect(ground.project(const Point3(3, 2, 1)), const Point3(3, 0, 1));
    });

    test('fromPoints normal follows winding', () {
      final p = Plane.fromPoints(Point3.zero, Point3.unitX, Point3.unitY);
      expect(p.normal, closeToPoint(Point3.unitZ));
      expect(
          () => Plane.fromPoints(
              Point3.zero, Point3.unitX, const Point3(2, 0, 0)),
          throwsArgumentError);
    });

    test('ray and segment intersection', () {
      final ray = Ray3(const Point3(0, 5, 0), const Point3(0, -1, 0));
      expect(ground.intersectRay(ray), closeTo(5, 1e-12));
      expect(ground.intersectRay(Ray3(const Point3(0, 5, 0), Point3.unitY)),
          isNull);
      final hit = ground
          .intersectSegment(const Segment3(Point3(0, -1, 0), Point3(2, 1, 0)));
      expect(hit, closeToPoint(const Point3(1, 0, 0)));
    });

    test('frame round-trips 2D points', () {
      final tilted =
          Plane.fromPointNormal(const Point3(1, 2, 3), const Point3(1, 1, 1));
      final f = tilted.frame(uHint: Point3.unitX);
      const p = Point(2.5, -1);
      final w = f.toWorld(p);
      expect(tilted.distanceTo(w), closeTo(0, 1e-12));
      final back = f.toLocal(w);
      expect(back.x, closeTo(p.x, 1e-12));
      expect(back.y, closeTo(p.y, 1e-12));
      expect(f.normal, closeToPoint(tilted.normal));
    });

    test('ground frame maps plan y to -z with +Y normal', () {
      expect(
          PlaneFrame.ground.toWorld(const Point(2, 3)), const Point3(2, 0, -3));
      expect(PlaneFrame.ground.normal, closeToPoint(Point3.unitY));
    });
  });

  group('Ray3 and Segment3', () {
    test('closest point', () {
      final r = Ray3(Point3.zero, const Point3(2, 0, 0));
      expect(r.direction, Point3.unitX);
      expect(r.closestPoint(const Point3(3, 4, 0)), const Point3(3, 0, 0));
      expect(r.closestPoint(const Point3(-3, 4, 0)), Point3.zero);
      const s = Segment3(Point3.zero, Point3(2, 0, 0));
      expect(s.closestPoint(const Point3(5, 1, 0)), const Point3(2, 0, 0));
      expect(s.distanceTo(const Point3(1, 3, 4)), 5);
    });
  });

  group('Aabb', () {
    const a = Aabb(Point3.zero, Point3(1, 1, 1));

    test('overlap, union, contains', () {
      expect(a.overlaps(const Aabb(Point3(0.5, 0.5, 0.5), Point3(2, 2, 2))),
          isTrue);
      expect(
          a.overlaps(const Aabb(Point3(1.1, 0, 0), Point3(2, 1, 1))), isFalse);
      expect(a.union(const Aabb(Point3(-1, 0, 0), Point3(0, 3, 0))),
          const Aabb(Point3(-1, 0, 0), Point3(1, 3, 1)));
      expect(a.contains(const Point3(0.5, 1, 0)), isTrue);
      expect(a.corners.length, 8);
      expect(a.volume, 1);
    });

    test('ray', () {
      expect(a.intersectRay(Ray3(const Point3(0.5, 0.5, -2), Point3.unitZ)),
          closeTo(2, 1e-12));
      expect(
          a.intersectRay(Ray3(const Point3(0.5, 0.5, 0.5), Point3.unitZ)), 0);
      expect(
          a.intersectRay(Ray3(const Point3(2, 0.5, -2), Point3.unitZ)), isNull);
    });
  });

  group('OrbitCamera', () {
    const cam =
        OrbitCamera(yaw: 30, pitch: 25, distance: 6, target: Point3(1, 0, 0));

    test('target projects to the viewport centre', () {
      final p = cam.project(cam.target, 400, 300)!;
      expect(p.x, closeTo(200, 1e-9));
      expect(p.y, closeTo(150, 1e-9));
    });

    test('up is up on screen, right is right', () {
      final above = cam.project(cam.target + Point3.unitY, 400, 300)!;
      expect(above.y, lessThan(150));
      final r = cam.project(cam.target + cam.right, 400, 300)!;
      expect(r.x, greaterThan(200));
    });

    test('rayThrough inverts project', () {
      const p = Point3(0.3, 0.8, -0.4);
      final s = cam.project(p, 400, 300)!;
      final ray = cam.rayThrough(s, 400, 300);
      expect(ray.distanceTo(p), closeTo(0, 1e-9));
    });

    test('points behind the camera are not projected', () {
      final behind = cam.position + (cam.position - cam.target);
      expect(cam.project(behind, 400, 300), isNull);
    });

    test('view() matches project, toView and rayThrough', () {
      final v = cam.view(400, 300);
      const p = Point3(0.3, 0.8, -0.4);
      final a = v.project(p)!, b = cam.project(p, 400, 300)!;
      expect(a.x, closeTo(b.x, 1e-12));
      expect(a.y, closeTo(b.y, 1e-12));
      expect(v.toView(p), closeToPoint(cam.toView(p), 1e-12));
      expect(v.rayThrough(a).distanceTo(p), closeTo(0, 1e-9));
      expect(v.projectView(const Point3(1, 1, 0.01)), isNull);
    });

    test('zoom and withDistance stay within min and max distance', () {
      const c = OrbitCamera(distance: 2, minDistance: 0.5, maxDistance: 10);
      expect(c.zoom(0.01).distance, 0.5);
      expect(c.zoom(100).distance, 10);
      expect(c.zoom(2).distance, 4);
      expect(c.withDistance(-3).distance, 0.5);
      // Pinching can never move the camera through the target.
      var z = c;
      for (var i = 0; i < 50; i++) {
        z = z.zoom(0.5);
      }
      expect(z.position.distanceTo(z.target), closeTo(0.5, 1e-9));
    });

    test('orbit clamps pitch', () {
      expect(cam.orbit(pitch: 200).pitch, 89);
      expect(cam.orbit(yaw: 350).yaw, 20);
    });
  });

  group('Quaternion.toAxisAngle', () {
    test('round-trips fromAxisAngle', () {
      const dir = Point3(1, 2, -0.5);
      for (final deg in const [10.0, 90.0, 179.0]) {
        final (:axis, :degrees) =
            Quaternion.fromAxisAngle(dir, deg).toAxisAngle();
        expect(degrees, closeTo(deg, 1e-9));
        expect(axis, closeToPoint(dir.normalized));
      }
    });

    test('keeps tiny angles instead of rounding them to zero', () {
      for (final deg in const [1e-3, 1e-6, 1e-9]) {
        final r = Quaternion.fromAxisAngle(Point3.unitX, deg).toAxisAngle();
        expect(r.degrees, closeTo(deg, deg * 1e-9));
        expect(r.axis, closeToPoint(Point3.unitX));
      }
    });

    test('takes the short way round and handles identity', () {
      final q = Quaternion.fromAxisAngle(Point3.unitZ, 270);
      final r = q.toAxisAngle();
      expect(r.degrees, closeTo(90, 1e-9));
      expect(r.axis, closeToPoint(-Point3.unitZ));
      expect(Quaternion.identity.toAxisAngle().degrees, 0);
    });
  });

  group('Ray3.closestPointOnLine', () {
    test('finds the point on a skew line', () {
      // Ray along -z at x = 2, y = 1; line is the x axis.
      final ray = Ray3(const Point3(2, 1, 5), const Point3(0, 0, -1));
      expect(
        ray.closestPointOnLine(Point3.zero, const Point3(3, 0, 0)),
        closeToPoint(const Point3(2, 0, 0)),
      );
    });

    test('parallel lines give null', () {
      final ray = Ray3(const Point3(0, 1, 0), Point3.unitX);
      expect(ray.closestPointOnLine(Point3.zero, Point3.unitX), isNull);
    });
  });

  group('Transform3', () {
    final t = Transform3(
      position: const Point3(2, -1, 0.5),
      rotation: Quaternion.fromAxisAngle(const Point3(1, 1, 0), 40),
      scale: 1.5,
    );
    const p = Point3(0.3, -0.7, 2);

    test('apply is scale, then rotate, then translate', () {
      expect(t.apply(p), closeToPoint(t.position + t.rotation.rotate(p * 1.5)));
      expect(Transform3.identity.apply(p), p);
    });

    test('inverse undoes it and composition matches nesting', () {
      expect(t.inverse.apply(t.apply(p)), closeToPoint(p));
      expect((t * t.inverse).isCloseTo(Transform3.identity), isTrue);
      final u = Transform3.identity.rotated(Point3.unitZ, 30).translated(
            const Point3(0, 1, 0),
          );
      expect((t * u).apply(p), closeToPoint(t.apply(u.apply(p))));
    });

    test('applyTo matches transforming the solid by hand', () {
      final box = Box(
        center: const Point3(0.2, 0, 0),
        width: 1,
        height: 2,
        depth: 0.5,
      );
      final placed = t.applyTo(box) as Box;
      final (:axis, :degrees) = t.rotation.toAxisAngle();
      final byHand =
          box.scale(1.5).rotate(axis, degrees).translate(x: 2, y: -1, z: 0.5);
      expect(placed.center, closeToPoint(byHand.center));
      expect(placed.center, closeToPoint(t.apply(box.center)));
      expect(placed.width, closeTo(1.5, 1e-12));
      expect(placed.rotation.isCloseTo(t.rotation), isTrue);
      expect(placed.volume, closeTo(box.volume * 1.5 * 1.5 * 1.5, 1e-9));
    });

    test('rotated and scaled default to the position as pivot', () {
      final r = t.rotated(Point3.unitY, 90);
      expect(r.position, t.position);
      final s = t.scaled(2, pivot: Point3.zero);
      expect(s.position, closeToPoint(t.position * 2));
      expect(s.scale, 3);
    });
  });
}
