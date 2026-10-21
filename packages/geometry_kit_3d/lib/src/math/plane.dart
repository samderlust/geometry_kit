import 'package:geometry_kit/geometry_kit.dart';

import 'point3.dart';
import 'ray3.dart';
import 'segment3.dart';

/// An infinite plane: every point `p` with `normal · p == constant`.
///
/// ```dart
/// final ground = Plane.fromPointNormal(Point3.zero, Point3.unitY);
/// print(ground.signedDistanceTo(Point3(0, 2, 0))); // 2.0
/// ```
class Plane {
  /// Unit normal of the plane.
  final Point3 normal;

  /// Signed distance from the origin along [normal].
  final double constant;

  /// Creates a plane from a [normal] (normalized here) and [constant].
  Plane(Point3 normal, double constant)
      : normal = normal.normalized,
        constant = constant / (normal.magnitude == 0 ? 1 : normal.magnitude);

  /// The plane through [point] facing [normal].
  factory Plane.fromPointNormal(Point3 point, Point3 normal) {
    final n = normal.normalized;
    return Plane(n, n.dot(point));
  }

  /// The plane through three points; the normal follows `(b - a) × (c - a)`.
  ///
  /// Throws [ArgumentError] when the points are collinear.
  factory Plane.fromPoints(Point3 a, Point3 b, Point3 c) {
    final n = (b - a).cross(c - a);
    if (n.magnitudeSquared == 0) {
      throw ArgumentError('Points are collinear; they do not define a plane.');
    }
    return Plane.fromPointNormal(a, n);
  }

  /// A point on the plane (the one closest to the origin).
  Point3 get origin => normal * constant;

  /// Signed distance from [point]; positive on the side [normal] points to.
  double signedDistanceTo(Point3 point) => normal.dot(point) - constant;

  /// Absolute distance from [point].
  double distanceTo(Point3 point) => signedDistanceTo(point).abs();

  /// Orthogonal projection of [point] onto the plane.
  Point3 project(Point3 point) => point - normal * signedDistanceTo(point);

  /// Distance along [ray] to the plane, or `null` if the ray is parallel
  /// to it or points away from it.
  double? intersectRay(Ray3 ray) {
    final denom = normal.dot(ray.direction);
    if (denom.abs() < 1e-12) return null;
    final t = (constant - normal.dot(ray.origin)) / denom;
    return t < 0 ? null : t;
  }

  /// Point where [segment] crosses the plane, or `null` if it does not.
  Point3? intersectSegment(Segment3 segment) {
    final da = signedDistanceTo(segment.a);
    final db = signedDistanceTo(segment.b);
    if ((da > 0 && db > 0) || (da < 0 && db < 0)) return null;
    if (da == db) return da == 0 ? segment.a : null;
    return segment.pointAt(da / (da - db));
  }

  /// The same plane facing the other way.
  Plane get flipped => Plane(-normal, -constant);

  /// A 2D coordinate frame lying in this plane.
  ///
  /// [uHint] picks the direction of the frame's u axis; it is projected
  /// onto the plane. When omitted, an arbitrary in-plane direction is used.
  PlaneFrame frame({Point3? uHint}) {
    var u = uHint == null ? Point3.zero : uHint - normal * normal.dot(uHint);
    if (u.magnitudeSquared < 1e-18) u = normal.anyPerpendicular;
    u = u.normalized;
    return PlaneFrame(origin, u, normal.cross(u));
  }

  @override
  bool operator ==(Object other) =>
      other is Plane && other.normal == normal && other.constant == constant;

  @override
  int get hashCode => Object.hash(normal, constant);

  @override
  String toString() => 'Plane(normal: $normal, constant: $constant)';
}

/// A 2D coordinate system embedded in 3D space.
///
/// Maps geometry_kit 2D [Point]s to [Point3]s and back:
/// `world = origin + u * p.x + v * p.y`. The frame's [normal] is `u × v`.
///
/// [PlaneFrame.ground] maps a 2D plan onto the floor (XZ plane) so that the
/// plan looks the same as its 2D drawing when seen from above: 2D x → 3D x,
/// 2D y → 3D −z.
class PlaneFrame {
  /// World position of the 2D origin.
  final Point3 origin;

  /// World direction of the 2D x axis (unit length).
  final Point3 u;

  /// World direction of the 2D y axis (unit length, perpendicular to [u]).
  final Point3 v;

  /// Creates a frame. [u] and [v] should be perpendicular unit vectors.
  const PlaneFrame(this.origin, this.u, this.v);

  /// The floor frame: 2D x → +X, 2D y → −Z, normal +Y.
  static const ground = PlaneFrame(Point3.zero, Point3.unitX, Point3(0, 0, -1));

  /// The XY frame: 2D x → +X, 2D y → +Y, normal +Z.
  static const xy = PlaneFrame(Point3.zero, Point3.unitX, Point3.unitY);

  /// Unit normal, `u × v`.
  Point3 get normal => u.cross(v);

  /// The plane this frame lies in.
  Plane get plane => Plane.fromPointNormal(origin, normal);

  /// Maps a 2D point in this frame to world space.
  Point3 toWorld(Point point) => origin + u * point.x + v * point.y;

  /// Maps a world point to 2D frame coordinates (dropping the normal part).
  Point toLocal(Point3 point) {
    final d = point - origin;
    return Point(d.dot(u), d.dot(v));
  }

  /// Distance of [point] above the frame along [normal].
  double heightOf(Point3 point) => (point - origin).dot(normal);

  /// Translate the frame.
  PlaneFrame translate({double x = 0, double y = 0, double z = 0}) =>
      PlaneFrame(origin.translate(x: x, y: y, z: z), u, v);

  /// Rotate the frame by [deg] degrees around [axis] through [pivot].
  PlaneFrame rotate(Point3 axis, double deg, {Point3 pivot = Point3.zero}) =>
      PlaneFrame(
        origin.rotate(axis, deg, pivot: pivot),
        u.rotate(axis, deg),
        v.rotate(axis, deg),
      );

  /// Scale the frame's origin about the world origin. Axes stay unit length.
  PlaneFrame scaleOrigin(double factor) => PlaneFrame(origin * factor, u, v);

  @override
  bool operator ==(Object other) =>
      other is PlaneFrame &&
      other.origin == origin &&
      other.u == u &&
      other.v == v;

  @override
  int get hashCode => Object.hash(origin, u, v);

  @override
  String toString() => 'PlaneFrame(origin: $origin, u: $u, v: $v)';
}
