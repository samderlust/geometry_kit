import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';

import '../bridge/cross_section.dart';
import '../math/aabb.dart';
import '../math/plane.dart';
import '../math/point3.dart';
import '../math/ray3.dart';
import '../mesh/mesh.dart';
import 'solid.dart';

/// A sphere defined by its [center] and [radius].
///
/// ```dart
/// final ball = Sphere(center: Point3(0, 1, 0), radius: 1);
/// print(ball.volume);                         // ~4.19
/// print(ball.contains(Point3(0, 1.5, 0)));    // true
/// ```
class Sphere implements Solid {
  /// Centre of the sphere.
  final Point3 center;

  /// Radius of the sphere.
  final double radius;

  /// Creates a sphere.
  const Sphere({required this.center, required this.radius})
      : assert(radius >= 0);

  /// Diameter.
  double get diameter => radius * 2;

  @override
  double get volume => 4 / 3 * pi * radius * radius * radius;

  @override
  double get surfaceArea => 4 * pi * radius * radius;

  @override
  Aabb get bounds => Aabb.centered(center, Point3(radius, radius, radius));

  @override
  bool contains(Point3 point) =>
      point.distanceSquaredTo(center) <= radius * radius;

  @override
  Point3 closestPoint(Point3 point) {
    final d = point - center;
    final m = d.magnitude;
    if (m <= radius) return point;
    return center + d * (radius / m);
  }

  @override
  double distanceTo(Point3 point) => max(0, point.distanceTo(center) - radius);

  @override
  RayHit? intersectRay(Ray3 ray) {
    final oc = ray.origin - center;
    final b = oc.dot(ray.direction);
    final c = oc.magnitudeSquared - radius * radius;
    final disc = b * b - c;
    if (disc < 0) return null;
    final s = sqrt(disc);
    var t = -b - s;
    if (t < 0) t = -b + s;
    if (t < 0) return null;
    final p = ray.pointAt(t);
    final n = radius == 0 ? -ray.direction : (p - center) / radius;
    return RayHit(distance: t, point: p, normal: n, solid: this);
  }

  /// Whether this sphere touches or overlaps [other].
  ///
  /// Exact for every solid in this package: it compares the distance from
  /// [center] to [other] against [radius].
  bool intersects(Solid other) {
    if (!bounds.overlaps(other.bounds)) return false;
    if (other is Sphere) {
      final r = radius + other.radius;
      return center.distanceSquaredTo(other.center) <= r * r;
    }
    return other.distanceTo(center) <= radius;
  }

  /// Cross-section of this sphere with [plane]: a circle, or empty.
  CrossSection slice(Plane plane, {int samples = 128}) {
    final d = plane.signedDistanceTo(center);
    final frame = plane.frame();
    if (d.abs() > radius) return EmptySection(frame);
    final c = plane.project(center);
    final circle = Circle(
      center: frame.toLocal(c),
      radius: sqrt(radius * radius - d * d),
    );
    return CircleSection(frame, circle, samples: samples);
  }

  @override
  Sphere translate({double x = 0, double y = 0, double z = 0}) =>
      Sphere(center: center.translate(x: x, y: y, z: z), radius: radius);

  @override
  Sphere scale(double factor) =>
      Sphere(center: center * factor, radius: radius * factor.abs());

  @override
  Sphere rotate(Point3 axis, double deg, {Point3 pivot = Point3.zero}) =>
      Sphere(center: center.rotate(axis, deg, pivot: pivot), radius: radius);

  @override
  Mesh toMesh({int segments = 32}) {
    final seg = max(3, segments);
    final rings = max(2, seg ~/ 2);
    final b = MeshBuilder();
    final top = b.vertex(center + Point3(0, radius, 0));
    final rows = <List<int>>[List.filled(seg, top)];
    for (var j = 1; j < rings; j++) {
      final theta = pi * j / rings;
      final y = cos(theta) * radius, r = sin(theta) * radius;
      rows.add([
        for (var i = 0; i < seg; i++)
          b.vertex(center +
              Point3(r * cos(2 * pi * i / seg), y, r * sin(2 * pi * i / seg))),
      ]);
    }
    final bottom = b.vertex(center - Point3(0, radius, 0));
    rows.add(List.filled(seg, bottom));
    for (var j = 0; j < rings; j++) {
      for (var i = 0; i < seg; i++) {
        final i2 = (i + 1) % seg;
        b.quad(rows[j][i], rows[j][i2], rows[j + 1][i2], rows[j + 1][i]);
      }
    }
    return b.build();
  }

  @override
  bool operator ==(Object other) =>
      other is Sphere && other.center == center && other.radius == radius;

  @override
  int get hashCode => Object.hash(center, radius);

  @override
  String toString() => 'Sphere(center: $center, radius: $radius)';
}
