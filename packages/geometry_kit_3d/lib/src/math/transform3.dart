import '../solid/solid.dart';
import 'point3.dart';
import 'quaternion.dart';

/// An immutable placement: uniform [scale], then [rotation], then
/// [position].
///
/// Solids bake transforms into their own fields, so a box rotated twice
/// cannot say how far it was turned. Keep the solid in local space and its
/// placement in a [Transform3] when you need the pose itself, for example
/// to draw a gizmo along the object's axes or to show its rotation.
///
/// ```dart
/// final t = Transform3(
///   position: const Point3(2, 0, 0),
///   rotation: Quaternion.fromAxisAngle(Point3.unitY, 90),
/// );
/// final placed = t.applyTo(Box.cube(center: Point3.zero, size: 1));
/// print(t.apply(Point3.unitX)); // ≈ Point3(2, 0, -1)
/// ```
class Transform3 {
  /// Where the local origin ends up.
  final Point3 position;

  /// Orientation, applied after [scale].
  final Quaternion rotation;

  /// Uniform scale about the local origin; positive.
  final double scale;

  /// Creates a transform. Defaults to the identity.
  const Transform3({
    this.position = Point3.zero,
    this.rotation = Quaternion.identity,
    this.scale = 1,
  }) : assert(scale > 0);

  /// The transform that changes nothing.
  static const identity = Transform3();

  /// [local] moved into world space.
  Point3 apply(Point3 local) => position + rotation.rotate(local * scale);

  /// Direction [local] turned into world space, without scale or position.
  Point3 applyDirection(Point3 local) => rotation.rotate(local);

  /// The transform that undoes this one.
  Transform3 get inverse {
    final r = rotation.conjugate;
    return Transform3(
      position: -r.rotate(position) / scale,
      rotation: r,
      scale: 1 / scale,
    );
  }

  /// Composition: `(a * b).apply(p) == a.apply(b.apply(p))`.
  Transform3 operator *(Transform3 o) => Transform3(
        position: apply(o.position),
        rotation: (rotation * o.rotation).normalized,
        scale: scale * o.scale,
      );

  /// [solid] (given in local space) placed in world space.
  Solid applyTo(Solid solid) {
    var s = solid;
    if (scale != 1) s = s.scale(scale);
    final (:axis, :degrees) = rotation.toAxisAngle();
    if (degrees != 0) s = s.rotate(axis, degrees);
    if (position != Point3.zero) {
      s = s.translate(x: position.x, y: position.y, z: position.z);
    }
    return s;
  }

  /// Moved by [offset] in world space.
  Transform3 translated(Point3 offset) => copyWith(position: position + offset);

  /// Turned by [deg] degrees around world [axis] through [pivot].
  Transform3 rotated(Point3 axis, double deg, {Point3? pivot}) {
    final q = Quaternion.fromAxisAngle(axis, deg);
    final p = pivot ?? position;
    return Transform3(
      position: p + q.rotate(position - p),
      rotation: (q * rotation).normalized,
      scale: scale,
    );
  }

  /// Scaled by [factor] about [pivot], which defaults to [position].
  Transform3 scaled(double factor, {Point3? pivot}) {
    final p = pivot ?? position;
    return Transform3(
      position: p + (position - p) * factor,
      rotation: rotation,
      scale: scale * factor,
    );
  }

  /// Copy with the given fields replaced.
  Transform3 copyWith(
          {Point3? position, Quaternion? rotation, double? scale}) =>
      Transform3(
        position: position ?? this.position,
        rotation: rotation ?? this.rotation,
        scale: scale ?? this.scale,
      );

  /// Whether this and [other] place things the same within [epsilon].
  bool isCloseTo(Transform3 other, [double epsilon = 1e-9]) =>
      position.isCloseTo(other.position, epsilon) &&
      rotation.isCloseTo(other.rotation, epsilon) &&
      (scale - other.scale).abs() <= epsilon;

  @override
  bool operator ==(Object other) =>
      other is Transform3 &&
      other.position == position &&
      other.rotation == rotation &&
      other.scale == scale;

  @override
  int get hashCode => Object.hash(position, rotation, scale);

  @override
  String toString() =>
      'Transform3(position: $position, rotation: $rotation, scale: $scale)';
}
