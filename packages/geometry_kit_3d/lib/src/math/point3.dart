import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';

/// An immutable 3D point (or vector) with x, y and z coordinates.
///
/// The coordinate system is right-handed with Y pointing up.
///
/// Supports arithmetic operators for vector math:
/// - `+` / `-` for addition and subtraction
/// - `*` / `/` for scalar multiplication and division
/// - `%` for the cross product (same as [cross])
///
/// ```dart
/// final p = Point3(1, 2, 2);
/// print(p.magnitude);                       // 3.0
/// print(Point3.unitX % Point3.unitY);       // Point3(0, 0, 1)
/// print(Point3.unitX.rotate(Point3.unitY, 90)); // ≈ Point3(0, 0, -1)
/// ```
class Point3 {
  /// X coordinate.
  final double x;

  /// Y coordinate (up).
  final double y;

  /// Z coordinate.
  final double z;

  /// Creates a point at ([x], [y], [z]).
  const Point3(this.x, this.y, this.z);

  /// The origin `(0, 0, 0)`.
  static const zero = Point3(0, 0, 0);

  /// Unit vector along the X axis.
  static const unitX = Point3(1, 0, 0);

  /// Unit vector along the Y axis (up).
  static const unitY = Point3(0, 1, 0);

  /// Unit vector along the Z axis.
  static const unitZ = Point3(0, 0, 1);

  /// Lifts a 2D [point] onto the plane `z = [z]`.
  factory Point3.fromPoint(Point point, [double z = 0]) =>
      Point3(point.x, point.y, z);

  /// Euclidean distance from this point to [other].
  double distanceTo(Point3 other) => (this - other).magnitude;

  /// Squared distance to [other]; cheaper than [distanceTo] for comparisons.
  double distanceSquaredTo(Point3 other) => (this - other).magnitudeSquared;

  /// Dot product with [other].
  double dot(Point3 other) => x * other.x + y * other.y + z * other.z;

  /// Cross product with [other] (right-handed).
  Point3 cross(Point3 other) => Point3(
        y * other.z - z * other.y,
        z * other.x - x * other.z,
        x * other.y - y * other.x,
      );

  /// Distance from origin (vector length).
  double get magnitude => sqrt(magnitudeSquared);

  /// Squared vector length.
  double get magnitudeSquared => x * x + y * y + z * z;

  /// Unit vector in the same direction.
  ///
  /// Returns [zero] if magnitude is zero.
  Point3 get normalized {
    final m = magnitude;
    if (m == 0) return zero;
    return Point3(x / m, y / m, z / m);
  }

  /// Any unit vector perpendicular to this one.
  ///
  /// Returns [unitX] for the zero vector.
  Point3 get anyPerpendicular {
    final n = normalized;
    if (n == zero) return unitX;
    final helper = n.x.abs() < 0.9 ? unitX : unitY;
    return n.cross(helper).normalized;
  }

  /// Midpoint between this point and [other].
  Point3 midPointTo(Point3 other) => lerp(other, 0.5);

  /// Linear interpolation towards [other]; `t = 0` is this point, `t = 1`
  /// is [other].
  Point3 lerp(Point3 other, double t) => Point3(
        x + (other.x - x) * t,
        y + (other.y - y) * t,
        z + (other.z - z) * t,
      );

  /// Angle between this vector and [other] in radians, range 0 to π.
  double angleTo(Point3 other) {
    final m = magnitude * other.magnitude;
    if (m == 0) return 0;
    return acos((dot(other) / m).clamp(-1.0, 1.0));
  }

  /// Translate by [x], [y] and [z].
  Point3 translate({double x = 0, double y = 0, double z = 0}) =>
      Point3(this.x + x, this.y + y, this.z + z);

  /// Scale every coordinate by [factor] (about the origin).
  Point3 scale(double factor) => this * factor;

  /// Rotate by [deg] degrees around [axis] through [pivot].
  ///
  /// Positive angles rotate counter-clockwise when looking from the tip of
  /// [axis] towards the pivot (right-hand rule).
  Point3 rotate(Point3 axis, double deg, {Point3 pivot = zero}) {
    final k = axis.normalized;
    if (k == zero) return this;
    final rad = deg * pi / 180;
    final c = cos(rad), s = sin(rad);
    final v = this - pivot;
    // Rodrigues' rotation formula.
    final rotated = v * c + k.cross(v) * s + k * (k.dot(v) * (1 - c));
    return rotated + pivot;
  }

  /// Drops the z coordinate.
  Point get xy => Point(x, y);

  /// Whether every coordinate is within [epsilon] of [other].
  bool isCloseTo(Point3 other, [double epsilon = 1e-9]) =>
      (x - other.x).abs() <= epsilon &&
      (y - other.y).abs() <= epsilon &&
      (z - other.z).abs() <= epsilon;

  /// Coordinate by index: 0 = x, 1 = y, 2 = z.
  double operator [](int i) => switch (i) {
        0 => x,
        1 => y,
        2 => z,
        _ => throw RangeError.index(i, this, 'index', null, 3),
      };

  /// Vector addition.
  Point3 operator +(Point3 other) =>
      Point3(x + other.x, y + other.y, z + other.z);

  /// Vector subtraction.
  Point3 operator -(Point3 other) =>
      Point3(x - other.x, y - other.y, z - other.z);

  /// Negation.
  Point3 operator -() => Point3(-x, -y, -z);

  /// Scalar multiplication.
  Point3 operator *(double scalar) =>
      Point3(x * scalar, y * scalar, z * scalar);

  /// Scalar division.
  Point3 operator /(double scalar) =>
      Point3(x / scalar, y / scalar, z / scalar);

  /// Cross product (same as [cross]).
  Point3 operator %(Point3 other) => cross(other);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Point3 && other.x == x && other.y == y && other.z == z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => 'Point3(x: $x, y: $y, z: $z)';
}
