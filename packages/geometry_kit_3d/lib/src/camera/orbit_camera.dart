import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';

import '../math/point3.dart';
import '../math/ray3.dart';

/// A perspective camera that circles a [target] point.
///
/// [yaw] turns around the vertical axis and [pitch] tilts up or down, both
/// in degrees. Screen coordinates follow Flutter: origin at the top-left,
/// y pointing down.
///
/// ```dart
/// const camera = OrbitCamera(yaw: 30, pitch: 20, distance: 8);
/// final screen = camera.project(Point3.zero, 400, 300); // Point(200, 150)
/// final ray = camera.rayThrough(Point(200, 150), 400, 300);
/// ```
class OrbitCamera {
  /// Point the camera looks at and orbits around.
  final Point3 target;

  /// Rotation around the vertical axis, in degrees. 0 looks along −Z.
  final double yaw;

  /// Elevation in degrees; positive looks down from above. Kept within
  /// ±89° so "up" stays defined.
  final double pitch;

  /// Distance from [target] to the camera.
  final double distance;

  /// Vertical field of view in degrees.
  final double fov;

  /// Points closer to the camera than this are not projected.
  final double near;

  /// Creates a camera.
  const OrbitCamera({
    this.target = Point3.zero,
    this.yaw = 30,
    this.pitch = 20,
    this.distance = 8,
    this.fov = 45,
    this.near = 0.05,
  });

  double get _pitchClamped => pitch.clamp(-89.0, 89.0);

  /// World position of the camera.
  Point3 get position {
    final y = yaw * pi / 180, p = _pitchClamped * pi / 180;
    return target + Point3(cos(p) * sin(y), sin(p), cos(p) * cos(y)) * distance;
  }

  /// Unit view direction, from the camera towards [target].
  Point3 get forward => (target - position).normalized;

  /// Unit vector pointing to the right of the view.
  Point3 get right => forward.cross(Point3.unitY).normalized;

  /// Unit vector pointing up in the view.
  Point3 get up => right.cross(forward);

  /// Focal length in pixels for a viewport [height].
  double focalLength(double height) => height / (2 * tan(fov * pi / 360));

  /// [point] in camera space: x right, y up, z = depth in front of the
  /// camera.
  Point3 toView(Point3 point) {
    final d = point - position;
    return Point3(d.dot(right), d.dot(up), d.dot(forward));
  }

  /// Screen position of [point] in a [width] × [height] viewport, or
  /// `null` when it is behind the camera (closer than [near]).
  Point? project(Point3 point, double width, double height) {
    final v = toView(point);
    if (v.z < near) return null;
    final f = focalLength(height);
    return Point(width / 2 + f * v.x / v.z, height / 2 - f * v.y / v.z);
  }

  /// Ray from the camera through [screen] in a [width] × [height] viewport.
  /// Use it to find what the user tapped.
  Ray3 rayThrough(Point screen, double width, double height) {
    final f = focalLength(height);
    final x = (screen.x - width / 2) / f;
    final y = -(screen.y - height / 2) / f;
    return Ray3(position, right * x + up * y + forward);
  }

  /// Camera turned by [yaw] and tilted by [pitch] degrees.
  OrbitCamera orbit({double yaw = 0, double pitch = 0}) => copyWith(
        yaw: (this.yaw + yaw) % 360,
        pitch: (this.pitch + pitch).clamp(-89.0, 89.0),
      );

  /// Camera moved closer (`factor < 1`) or further (`factor > 1`).
  OrbitCamera zoom(double factor) => copyWith(distance: distance * factor);

  /// Copy with the given fields replaced.
  OrbitCamera copyWith({
    Point3? target,
    double? yaw,
    double? pitch,
    double? distance,
    double? fov,
    double? near,
  }) =>
      OrbitCamera(
        target: target ?? this.target,
        yaw: yaw ?? this.yaw,
        pitch: pitch ?? this.pitch,
        distance: distance ?? this.distance,
        fov: fov ?? this.fov,
        near: near ?? this.near,
      );

  @override
  bool operator ==(Object other) =>
      other is OrbitCamera &&
      other.target == target &&
      other.yaw == yaw &&
      other.pitch == pitch &&
      other.distance == distance &&
      other.fov == fov &&
      other.near == near;

  @override
  int get hashCode => Object.hash(target, yaw, pitch, distance, fov, near);

  @override
  String toString() =>
      'OrbitCamera(target: $target, yaw: $yaw, pitch: $pitch, distance: $distance, fov: $fov)';
}
