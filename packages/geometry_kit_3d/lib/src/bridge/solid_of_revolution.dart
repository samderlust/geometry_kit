import 'package:geometry_kit/geometry_kit.dart';

import '../math/point3.dart';
import '../solid/revolved_solid.dart';

/// A solid made by spinning a 2D [profile] around an axis (a lathe).
///
/// Each profile point is `Point(r, h)`: `r` is the distance from the axis
/// and `h` the height along [axis] from [origin]. The region is closed
/// along the axis at both ends, so a vase profile becomes a solid whose
/// [volume] is its capacity up to the rim.
///
/// ```dart
/// final profile = Spline([
///   Point(0.55, 0), Point(0.85, 0.7), Point(0.32, 1.5), Point(0.5, 1.9),
/// ]);
/// final vase = SolidOfRevolution(profile.sample(48));
/// print(vase.volume); // in dm³ (litres) when units are decimetres
/// final mesh = vase.toMesh(segments: 48);
/// ```
class SolidOfRevolution extends RevolvedSolid {
  /// Profile points `(r, h)`, in order. `r` must not be negative.
  final List<Point> profile;

  @override
  final Point3 origin;

  @override
  final Point3 axis;

  /// Creates a solid of revolution. [axis] is normalized.
  SolidOfRevolution(
    this.profile, {
    this.origin = Point3.zero,
    Point3 axis = Point3.unitY,
  })  : assert(profile.length >= 2),
        assert(profile.every((p) => p.x >= 0), 'r must not be negative'),
        axis = axis.normalized;

  @override
  List<Point> get meridian => [
        if (profile.first.x != 0) Point(0, profile.first.y),
        ...profile,
        if (profile.last.x != 0) Point(0, profile.last.y),
      ];

  @override
  SolidOfRevolution translate({double x = 0, double y = 0, double z = 0}) =>
      SolidOfRevolution(profile,
          origin: origin.translate(x: x, y: y, z: z), axis: axis);

  @override
  SolidOfRevolution scale(double factor) => SolidOfRevolution(
        [for (final p in profile) p * factor.abs()],
        origin: origin * factor,
        axis: axis,
      );

  @override
  SolidOfRevolution rotate(Point3 axis, double deg,
          {Point3 pivot = Point3.zero}) =>
      SolidOfRevolution(
        profile,
        origin: origin.rotate(axis, deg, pivot: pivot),
        axis: this.axis.rotate(axis, deg),
      );

  @override
  bool operator ==(Object other) {
    if (other is! SolidOfRevolution ||
        other.origin != origin ||
        other.axis != axis ||
        other.profile.length != profile.length) {
      return false;
    }
    for (var i = 0; i < profile.length; i++) {
      if (other.profile[i] != profile[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(origin, axis, Object.hashAll(profile));

  @override
  String toString() =>
      'SolidOfRevolution(${profile.length} profile points, origin: $origin, axis: $axis)';
}
