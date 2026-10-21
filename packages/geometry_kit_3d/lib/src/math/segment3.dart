import 'point3.dart';

/// A straight line segment between [a] and [b].
class Segment3 {
  /// Start point.
  final Point3 a;

  /// End point.
  final Point3 b;

  /// Creates a segment from [a] to [b].
  const Segment3(this.a, this.b);

  /// Length of the segment.
  double get length => a.distanceTo(b);

  /// Midpoint of the segment.
  Point3 get midPoint => a.midPointTo(b);

  /// Vector from [a] to [b].
  Point3 get vector => b - a;

  /// Point at parameter [t]; `0` is [a], `1` is [b].
  Point3 pointAt(double t) => a.lerp(b, t);

  /// Point on the segment closest to [point].
  Point3 closestPoint(Point3 point) {
    final d = vector;
    final l2 = d.magnitudeSquared;
    if (l2 == 0) return a;
    final t = ((point - a).dot(d) / l2).clamp(0.0, 1.0);
    return pointAt(t);
  }

  /// Shortest distance from the segment to [point].
  double distanceTo(Point3 point) => closestPoint(point).distanceTo(point);

  /// Translate both ends.
  Segment3 translate({double x = 0, double y = 0, double z = 0}) =>
      Segment3(a.translate(x: x, y: y, z: z), b.translate(x: x, y: y, z: z));

  /// Rotate both ends by [deg] degrees around [axis] through [pivot].
  Segment3 rotate(Point3 axis, double deg, {Point3 pivot = Point3.zero}) =>
      Segment3(
          a.rotate(axis, deg, pivot: pivot), b.rotate(axis, deg, pivot: pivot));

  /// Scale both ends about the origin.
  Segment3 scale(double factor) => Segment3(a * factor, b * factor);

  @override
  bool operator ==(Object other) =>
      other is Segment3 && other.a == a && other.b == b;

  @override
  int get hashCode => Object.hash(a, b);

  @override
  String toString() => 'Segment3($a, $b)';
}
