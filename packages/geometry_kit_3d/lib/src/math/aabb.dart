import 'dart:math' as math;

import 'point3.dart';
import 'ray3.dart';

/// An axis-aligned bounding box from [min] to [max].
///
/// Cheap to test against, so it is the broad-phase check before exact
/// solid-vs-solid or ray-vs-solid tests.
///
/// ```dart
/// final a = Aabb(Point3(0, 0, 0), Point3(1, 1, 1));
/// final b = Aabb(Point3(0.5, 0.5, 0.5), Point3(2, 2, 2));
/// print(a.overlaps(b)); // true
/// ```
class Aabb {
  /// Corner with the smallest coordinates.
  final Point3 min;

  /// Corner with the largest coordinates.
  final Point3 max;

  /// Creates a box from [min] to [max].
  const Aabb(this.min, this.max);

  /// The smallest box containing every point in [points].
  factory Aabb.fromPoints(Iterable<Point3> points) {
    final it = points.iterator;
    if (!it.moveNext()) {
      throw ArgumentError('Cannot build an Aabb from no points.');
    }
    var lo = it.current, hi = it.current;
    while (it.moveNext()) {
      final p = it.current;
      lo =
          Point3(math.min(lo.x, p.x), math.min(lo.y, p.y), math.min(lo.z, p.z));
      hi =
          Point3(math.max(hi.x, p.x), math.max(hi.y, p.y), math.max(hi.z, p.z));
    }
    return Aabb(lo, hi);
  }

  /// A box centred on [center] with [halfSize] on each side.
  factory Aabb.centered(Point3 center, Point3 halfSize) =>
      Aabb(center - halfSize, center + halfSize);

  /// Centre of the box.
  Point3 get center => min.midPointTo(max);

  /// Edge lengths along x, y and z.
  Point3 get size => max - min;

  /// Volume of the box.
  double get volume {
    final s = size;
    return s.x * s.y * s.z;
  }

  /// The eight corners.
  List<Point3> get corners => [
        for (final x in [min.x, max.x])
          for (final y in [min.y, max.y])
            for (final z in [min.z, max.z]) Point3(x, y, z),
      ];

  /// Whether [point] lies inside or on the box.
  bool contains(Point3 point) =>
      point.x >= min.x &&
      point.x <= max.x &&
      point.y >= min.y &&
      point.y <= max.y &&
      point.z >= min.z &&
      point.z <= max.z;

  /// Whether this box and [other] touch or overlap.
  bool overlaps(Aabb other) =>
      min.x <= other.max.x &&
      max.x >= other.min.x &&
      min.y <= other.max.y &&
      max.y >= other.min.y &&
      min.z <= other.max.z &&
      max.z >= other.min.z;

  /// The smallest box containing this box and [other].
  Aabb union(Aabb other) => Aabb(
        Point3(math.min(min.x, other.min.x), math.min(min.y, other.min.y),
            math.min(min.z, other.min.z)),
        Point3(math.max(max.x, other.max.x), math.max(max.y, other.max.y),
            math.max(max.z, other.max.z)),
      );

  /// This box grown by [amount] on every side.
  Aabb expand(double amount) {
    final d = Point3(amount, amount, amount);
    return Aabb(min - d, max + d);
  }

  /// Point inside or on the box closest to [point].
  Point3 closestPoint(Point3 point) => Point3(
        point.x.clamp(min.x, max.x),
        point.y.clamp(min.y, max.y),
        point.z.clamp(min.z, max.z),
      );

  /// Distance along [ray] to where it enters the box (0 when the ray starts
  /// inside), or `null` if it misses.
  double? intersectRay(Ray3 ray) {
    final range = slab(ray, min, max);
    if (range == null) return null;
    return range.$1 > 0 ? range.$1 : 0;
  }

  /// Ray-vs-box slab test. Returns the entry and exit distances, or `null`
  /// when the ray misses or the box is entirely behind the ray.
  static (double, double)? slab(Ray3 ray, Point3 min, Point3 max) {
    var t0 = double.negativeInfinity, t1 = double.infinity;
    for (var k = 0; k < 3; k++) {
      final o = ray.origin[k], d = ray.direction[k];
      if (d.abs() < 1e-15) {
        if (o < min[k] || o > max[k]) return null;
        continue;
      }
      var a = (min[k] - o) / d, b = (max[k] - o) / d;
      if (a > b) (a, b) = (b, a);
      if (a > t0) t0 = a;
      if (b < t1) t1 = b;
      if (t0 > t1) return null;
    }
    if (t1 < 0) return null;
    return (t0, t1);
  }

  @override
  bool operator ==(Object other) =>
      other is Aabb && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);

  @override
  String toString() => 'Aabb(min: $min, max: $max)';
}
