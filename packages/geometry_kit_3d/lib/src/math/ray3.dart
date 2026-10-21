import 'point3.dart';

/// A half-line starting at [origin] and going along [direction].
///
/// [direction] is normalized on construction, so the ray parameter `t`
/// in [pointAt] is a true distance.
///
/// ```dart
/// final ray = Ray3(Point3(0, 0, -5), Point3.unitZ);
/// print(ray.pointAt(5)); // Point3(0, 0, 0)
/// ```
class Ray3 {
  /// Start of the ray.
  final Point3 origin;

  /// Unit direction of the ray.
  final Point3 direction;

  /// Creates a ray from [origin] along [direction] (normalized here).
  Ray3(this.origin, Point3 direction) : direction = direction.normalized;

  /// Point at distance [t] along the ray.
  Point3 pointAt(double t) => origin + direction * t;

  /// Point on the ray closest to [point].
  Point3 closestPoint(Point3 point) {
    final t = (point - origin).dot(direction);
    return pointAt(t < 0 ? 0 : t);
  }

  /// Shortest distance from the ray to [point].
  double distanceTo(Point3 point) => closestPoint(point).distanceTo(point);

  /// Point on the infinite line through [linePoint] along [lineDirection]
  /// that comes closest to this ray's line, or `null` when the two are
  /// (nearly) parallel.
  ///
  /// Use it to drag along an axis: cast a ray through the pointer and take
  /// the closest point on the axis.
  Point3? closestPointOnLine(Point3 linePoint, Point3 lineDirection) {
    final u = lineDirection.normalized;
    if (u == Point3.zero) return null;
    final b = direction.dot(u);
    final denom = 1 - b * b;
    if (denom < 1e-9) return null;
    final w = origin - linePoint;
    final s = (u.dot(w) - b * direction.dot(w)) / denom;
    return linePoint + u * s;
  }

  @override
  bool operator ==(Object other) =>
      other is Ray3 && other.origin == origin && other.direction == direction;

  @override
  int get hashCode => Object.hash(origin, direction);

  @override
  String toString() => 'Ray3(origin: $origin, direction: $direction)';
}
