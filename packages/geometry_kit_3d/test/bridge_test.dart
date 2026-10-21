import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';
import 'package:geometry_kit_3d/geometry_kit_3d.dart';
import 'package:test/test.dart';

/// Plane through [point], tilted [deg] from horizontal around the z axis.
Plane tilted(double deg, [Point3 point = Point3.zero]) =>
    Plane.fromPointNormal(point, Point3.unitY.rotate(Point3.unitZ, deg));

void main() {
  // Unit cone from the demo: base at y = -1, apex at y = 1, half-angle 26.57°.
  final cone = Cone(baseCenter: const Point3(0, -1, 0), radius: 1, height: 2);

  /// Distance from [p] to the cone's lateral surface, measured radially.
  double offSurface(Point3 p) {
    final h = p.y + 1;
    final expected = (2 - h) / 2; // radius shrinks linearly to the apex
    return (sqrt(p.x * p.x + p.z * p.z) - expected).abs();
  }

  group('Cone.slice', () {
    test('horizontal plane gives a circle with the right radius', () {
      final s = cone.slice(tilted(0));
      expect(s, isA<CircleSection>());
      expect((s as CircleSection).circle.radius, closeTo(0.5, 1e-12));
      expect(s.area, closeTo(pi / 4, 1e-12));
    });

    test('plane above the apex is empty', () {
      expect(
          cone.slice(tilted(0, const Point3(0, 1.5, 0))), isA<EmptySection>());
      expect(cone.slice(tilted(0, const Point3(0, 1.5, 0))).isEmpty, isTrue);
    });

    test('30° tilt is an exact, unclipped ellipse on the cone surface', () {
      final s = cone.slice(tilted(30));
      expect(s, isA<EllipseSection>());
      final e = s as EllipseSection;
      expect(e.clipped, isFalse);
      expect(e.ellipse.radiusX, greaterThan(e.ellipse.radiusY));
      for (final p in s.toPoints3()) {
        expect(tilted(30).distanceTo(p), closeTo(0, 1e-9));
        expect(offSurface(p), closeTo(0, 1e-9));
      }
      expect(
          s.area, closeTo(pi * e.ellipse.radiusX * e.ellipse.radiusY, 1e-12));
    });

    test('steep ellipse running through the base is clipped', () {
      final s = cone.slice(tilted(55, const Point3(0, -0.6, 0)));
      expect(s, isA<EllipseSection>());
      expect((s as EllipseSection).clipped, isTrue);
      expect(s.area, lessThan(pi * s.ellipse.radiusX * s.ellipse.radiusY));
    });

    test('tilt equal to 90° − half-angle is a parabola, steeper is a hyperbola',
        () {
      final parallel = 90 - cone.halfAngle;
      expect(cone.slice(tilted(parallel, const Point3(0, -0.2, 0))),
          isA<ParabolaSection>());
      expect(cone.slice(tilted(80, const Point3(0, -0.2, 0))),
          isA<HyperbolaSection>());
    });

    test('open sections lie in the plane and inside the cone', () {
      final plane = tilted(80, const Point3(0.1, -0.2, 0));
      final s = cone.slice(plane);
      expect(s.outline.length, greaterThan(10));
      for (final p in s.toPoints3()) {
        expect(plane.distanceTo(p), closeTo(0, 1e-9));
        expect(cone.distanceTo(p), closeTo(0, 1e-9));
      }
      expect(s.toPolygon().area, closeTo(s.area, 1e-9));
    });

    test('works for a cone on a tilted axis', () {
      final c =
          cone.rotate(const Point3(1, 0, 1), 40, pivot: const Point3(0, -1, 0));
      final perpendicular =
          Plane.fromPointNormal(c.baseCenter + c.axis * 1, c.axis);
      final s = c.slice(perpendicular);
      expect(s, isA<CircleSection>());
      expect((s as CircleSection).circle.radius, closeTo(0.5, 1e-9));
    });
  });

  group('Sphere.slice', () {
    test('circle radius from the plane distance', () {
      const ball = Sphere(center: Point3(0, 0, 0), radius: 5);
      final s = ball
          .slice(Plane.fromPointNormal(const Point3(0, 3, 0), Point3.unitY));
      expect((s as CircleSection).circle.radius, closeTo(4, 1e-12));
      expect(
          ball.slice(
              Plane.fromPointNormal(const Point3(0, 6, 0), Point3.unitY)),
          isA<EmptySection>());
    });
  });

  group('SolidOfRevolution', () {
    test('a revolved rectangle is a cylinder', () {
      final s = SolidOfRevolution(const [Point(2, 0), Point(2, 3)]);
      expect(s.volume, closeTo(pi * 4 * 3, 1e-9));
      expect(s.surfaceArea, closeTo(2 * pi * 2 * (2 + 3), 1e-9));
    });

    test('vase from a 2D spline, in litres', () {
      final profile = Spline(const [
        Point(0.55, 0),
        Point(0.85, 0.7),
        Point(0.32, 1.5),
        Point(0.5, 1.9),
      ]);
      final vase = SolidOfRevolution(profile.sample(64));
      expect(vase.volume, inInclusiveRange(1.5, 4));
      expect(vase.contains(const Point3(0, 0.7, 0)), isTrue);
      expect(vase.contains(const Point3(0.9, 0.7, 0)), isFalse);
      final mesh = vase.toMesh(segments: 128);
      expect(mesh.volume, closeTo(vase.volume, vase.volume * 1e-3));
    });
  });

  group('Mesh', () {
    final cube =
        const Box(center: Point3.zero, width: 2, height: 2, depth: 2).toMesh();

    test('cube counts', () {
      expect(cube.vertexCount, 8);
      expect(cube.triangleCount, 12);
      expect(cube.volume, closeTo(8, 1e-12));
      expect(cube.surfaceArea, closeTo(24, 1e-12));
      expect(cube.positionsFloat32.length, 24);
      expect(cube.indicesUint32.length, 36);
    });

    test('OBJ export', () {
      final obj = cube.toObj(name: 'cube');
      expect(obj, contains('o cube'));
      expect('v '.allMatches(obj).length, 8);
      expect(RegExp(r'^f ', multiLine: true).allMatches(obj).length, 12);
      expect(obj, contains('v -1 -1 -1'));
    });

    test('STL export', () {
      final stl = cube.toStl(name: 'cube');
      expect(stl, startsWith('solid cube'));
      expect('facet normal'.allMatches(stl).length, 12);
      expect(stl.trim(), endsWith('endsolid cube'));
    });

    test('merge and transforms', () {
      final two = Mesh.merge([cube, cube.translate(x: 5)]);
      expect(two.triangleCount, 24);
      expect(two.volume, closeTo(16, 1e-9));
      expect(cube.scale(-1).volume, closeTo(8, 1e-12));
      expect(cube.rotate(Point3.unitY, 30).volume, closeTo(8, 1e-9));
    });

    test('concave prism caps triangulate without spilling outside', () {
      final plan = Polygon(const [
        Point(0, 0),
        Point(6, 0),
        Point(6, 3),
        Point(3.5, 3),
        Point(3.5, 5),
        Point(0, 5),
      ]);
      final mesh = Prism.extrude(plan, height: 1).toMesh();
      // 6 side quads + 2 caps of (6 - 2) triangles each.
      expect(mesh.triangleCount, 12 + 8);
      expect(mesh.volume, closeTo(25, 1e-9));
    });
  });
}
