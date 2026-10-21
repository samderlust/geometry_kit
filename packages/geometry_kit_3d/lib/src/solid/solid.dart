import '../math/aabb.dart';
import '../math/point3.dart';
import '../math/ray3.dart';
import '../mesh/mesh.dart';

/// Base interface for all 3D solids.
///
/// The 3D counterpart of geometry_kit's `Shape`: solids report [volume] and
/// [surfaceArea] instead of area and perimeter, and rotate around an axis
/// instead of a single angle. All solids are immutable; transforms return
/// new instances.
abstract interface class Solid {
  /// Enclosed volume.
  double get volume;

  /// Total area of the outer surface.
  double get surfaceArea;

  /// Axis-aligned bounding box, for broad-phase checks.
  Aabb get bounds;

  /// Whether [point] is inside or on the surface.
  bool contains(Point3 point);

  /// Point of this solid (inside or on the surface) closest to [point].
  ///
  /// Returns [point] itself when it is inside.
  Point3 closestPoint(Point3 point);

  /// Shortest distance from [point] to this solid; 0 when inside.
  double distanceTo(Point3 point);

  /// First place [ray] enters the surface, or `null` when it misses.
  ///
  /// A ray starting inside the solid reports where it exits.
  RayHit? intersectRay(Ray3 ray);

  /// Translate by [x], [y] and [z].
  Solid translate({double x = 0, double y = 0, double z = 0});

  /// Uniform scale about the origin by a positive [factor].
  Solid scale(double factor);

  /// Rotate by [deg] degrees around [axis] through [pivot].
  Solid rotate(Point3 axis, double deg, {Point3 pivot = Point3.zero});

  /// Triangle mesh of the surface. Curved solids use [segments] slices
  /// around their circumference; flat-faced solids ignore it.
  Mesh toMesh({int segments = 32});
}

/// Where a ray hit a solid.
class RayHit {
  /// Distance along the ray.
  final double distance;

  /// World position of the hit.
  final Point3 point;

  /// Outward unit surface normal at [point].
  final Point3 normal;

  /// The solid that was hit.
  final Solid solid;

  /// Creates a hit record.
  const RayHit({
    required this.distance,
    required this.point,
    required this.normal,
    required this.solid,
  });

  @override
  String toString() =>
      'RayHit(distance: $distance, point: $point, normal: $normal)';
}

/// Picks the nearest hit of [ray] among [solids], or `null` if none is hit.
RayHit? nearestHit(Ray3 ray, Iterable<Solid> solids) {
  RayHit? best;
  for (final s in solids) {
    final hit = s.intersectRay(ray);
    if (hit != null && (best == null || hit.distance < best.distance)) {
      best = hit;
    }
  }
  return best;
}
