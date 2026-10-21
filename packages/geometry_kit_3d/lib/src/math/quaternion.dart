import 'dart:math';

import 'point3.dart';

/// An immutable rotation quaternion `w + xi + yj + zk`.
///
/// Used to store the orientation of solids such as [Box] without the
/// gimbal problems of Euler angles.
///
/// ```dart
/// final q = Quaternion.fromAxisAngle(Point3.unitY, 90);
/// print(q.rotate(Point3.unitX)); // ≈ Point3(0, 0, -1)
/// ```
class Quaternion {
  /// Scalar part.
  final double w;

  /// i component.
  final double x;

  /// j component.
  final double y;

  /// k component.
  final double z;

  /// Creates a quaternion from its four components.
  const Quaternion(this.w, this.x, this.y, this.z);

  /// The identity rotation.
  static const identity = Quaternion(1, 0, 0, 0);

  /// Rotation of [deg] degrees around [axis] (right-hand rule).
  factory Quaternion.fromAxisAngle(Point3 axis, double deg) {
    final n = axis.normalized;
    if (n == Point3.zero) return identity;
    final half = deg * pi / 360;
    final s = sin(half);
    return Quaternion(cos(half), n.x * s, n.y * s, n.z * s);
  }

  /// Length of the quaternion; 1 for a pure rotation.
  double get magnitude => sqrt(w * w + x * x + y * y + z * z);

  /// Unit quaternion in the same direction.
  Quaternion get normalized {
    final m = magnitude;
    if (m == 0) return identity;
    return Quaternion(w / m, x / m, y / m, z / m);
  }

  /// The inverse rotation (for unit quaternions).
  Quaternion get conjugate => Quaternion(w, -x, -y, -z);

  /// Rotates [v] by this quaternion.
  Point3 rotate(Point3 v) {
    // v' = v + 2w(q × v) + 2 q × (q × v), with q the vector part.
    final q = Point3(x, y, z);
    final t = q.cross(v) * 2;
    return v + t * w + q.cross(t);
  }

  /// Composition: `(a * b).rotate(v) == a.rotate(b.rotate(v))`.
  Quaternion operator *(Quaternion o) => Quaternion(
        w * o.w - x * o.x - y * o.y - z * o.z,
        w * o.x + x * o.w + y * o.z - z * o.y,
        w * o.y - x * o.z + y * o.w + z * o.x,
        w * o.z + x * o.y - y * o.x + z * o.w,
      );

  /// Whether this and [other] describe the same rotation within [epsilon].
  bool isCloseTo(Quaternion other, [double epsilon = 1e-9]) {
    // q and -q are the same rotation.
    final d = (w * other.w + x * other.x + y * other.y + z * other.z).abs();
    return (1 - d).abs() <= epsilon;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quaternion &&
        other.w == w &&
        other.x == x &&
        other.y == y &&
        other.z == z;
  }

  @override
  int get hashCode => Object.hash(w, x, y, z);

  @override
  String toString() => 'Quaternion(w: $w, x: $x, y: $y, z: $z)';
}
