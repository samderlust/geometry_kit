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

  /// Closest [zoom] and [withDistance] may bring the camera to [target].
  final double minDistance;

  /// Furthest [zoom] and [withDistance] may move the camera from [target].
  final double maxDistance;

  /// Creates a camera.
  const OrbitCamera({
    this.target = Point3.zero,
    this.yaw = 30,
    this.pitch = 20,
    this.distance = 8,
    this.fov = 45,
    this.near = 0.05,
    this.minDistance = 0.5,
    this.maxDistance = 1000,
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

  /// The view transform for a [width] × [height] viewport, computed once.
  ///
  /// Use it when projecting many points: [toView] and [project] on the
  /// camera rebuild the camera axes on every call.
  CameraView view(double width, double height) {
    final pos = position;
    final f = (target - pos).normalized;
    final r = f.cross(Point3.unitY).normalized;
    return CameraView._(pos, r, r.cross(f), f, focalLength(height), width,
        height, near);
  }

  /// [point] in camera space: x right, y up, z = depth in front of the
  /// camera.
  Point3 toView(Point3 point) => view(0, 0).toView(point);

  /// Screen position of [point] in a [width] × [height] viewport, or
  /// `null` when it is behind the camera (closer than [near]).
  Point? project(Point3 point, double width, double height) =>
      view(width, height).project(point);

  /// Ray from the camera through [screen] in a [width] × [height] viewport.
  /// Use it to find what the user tapped.
  Ray3 rayThrough(Point screen, double width, double height) =>
      view(width, height).rayThrough(screen);

  /// Camera turned by [yaw] and tilted by [pitch] degrees.
  OrbitCamera orbit({double yaw = 0, double pitch = 0}) => copyWith(
        yaw: (this.yaw + yaw) % 360,
        pitch: (this.pitch + pitch).clamp(-89.0, 89.0),
      );

  /// Camera moved closer (`factor < 1`) or further (`factor > 1`), kept
  /// between [minDistance] and [maxDistance].
  OrbitCamera zoom(double factor) => withDistance(distance * factor);

  /// Camera at [distance] from [target], kept between [minDistance] and
  /// [maxDistance] so it never passes through the target.
  OrbitCamera withDistance(double distance) =>
      copyWith(distance: distance.clamp(minDistance, maxDistance));

  /// Copy with the given fields replaced.
  OrbitCamera copyWith({
    Point3? target,
    double? yaw,
    double? pitch,
    double? distance,
    double? fov,
    double? near,
    double? minDistance,
    double? maxDistance,
  }) =>
      OrbitCamera(
        target: target ?? this.target,
        yaw: yaw ?? this.yaw,
        pitch: pitch ?? this.pitch,
        distance: distance ?? this.distance,
        fov: fov ?? this.fov,
        near: near ?? this.near,
        minDistance: minDistance ?? this.minDistance,
        maxDistance: maxDistance ?? this.maxDistance,
      );

  @override
  bool operator ==(Object other) =>
      other is OrbitCamera &&
      other.target == target &&
      other.yaw == yaw &&
      other.pitch == pitch &&
      other.distance == distance &&
      other.fov == fov &&
      other.near == near &&
      other.minDistance == minDistance &&
      other.maxDistance == maxDistance;

  @override
  int get hashCode => Object.hash(
      target, yaw, pitch, distance, fov, near, minDistance, maxDistance);

  @override
  String toString() =>
      'OrbitCamera(target: $target, yaw: $yaw, pitch: $pitch, distance: $distance, fov: $fov)';
}

/// An [OrbitCamera]'s view transform for one viewport, with the camera axes
/// computed once. Get one from [OrbitCamera.view].
class CameraView {
  /// Camera position in world space.
  final Point3 position;

  /// Unit right, up and forward axes of the view.
  final Point3 right, up, forward;

  /// Focal length in pixels.
  final double focalLength;

  /// Viewport size in logical pixels.
  final double width, height;

  /// Near plane distance; points closer than this are not projected.
  final double near;

  const CameraView._(this.position, this.right, this.up, this.forward,
      this.focalLength, this.width, this.height, this.near);

  /// [point] in camera space: x right, y up, z = depth.
  Point3 toView(Point3 point) {
    final dx = point.x - position.x,
        dy = point.y - position.y,
        dz = point.z - position.z;
    return Point3(
      dx * right.x + dy * right.y + dz * right.z,
      dx * up.x + dy * up.y + dz * up.z,
      dx * forward.x + dy * forward.y + dz * forward.z,
    );
  }

  /// Screen position of a camera-space point, or `null` closer than [near].
  Point? projectView(Point3 v) {
    if (v.z < near) return null;
    return Point(width / 2 + focalLength * v.x / v.z,
        height / 2 - focalLength * v.y / v.z);
  }

  /// Screen position of a world point, or `null` closer than [near].
  Point? project(Point3 point) => projectView(toView(point));

  /// Ray from the camera through a [screen] position.
  Ray3 rayThrough(Point screen) {
    final x = (screen.x - width / 2) / focalLength;
    final y = -(screen.y - height / 2) / focalLength;
    return Ray3(position, right * x + up * y + forward);
  }
}
