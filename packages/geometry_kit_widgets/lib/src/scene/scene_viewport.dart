import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';
import 'package:geometry_kit/geometry_kit.dart' show Point;
import 'package:geometry_kit_3d/geometry_kit_3d.dart';

import 'scene_node.dart';

/// A camera looking into a viewport of a given size: the bridge between
/// pointer positions and the 3D world.
///
/// [GeoScene] builds one per layout and hands it to its [SceneInteraction],
/// so tools can cast rays, project points and pick nodes without knowing
/// how the scene is drawn.
///
/// ```dart
/// final viewport = SceneViewport(camera, const Size(400, 300));
/// final hit = viewport.pick(nodes, details.localPosition);
/// final screen = viewport.project(Point3.zero); // Offset(200, 150)
/// ```
@immutable
class SceneViewport {
  /// The viewpoint.
  final OrbitCamera camera;

  /// Viewport size in logical pixels.
  final Size size;

  /// The camera's view transform for [size], computed once.
  final CameraView view;

  /// Creates a viewport for [camera] at [size].
  SceneViewport(this.camera, this.size)
    : view = camera.view(size.width, size.height);

  /// Ray from the camera through [local], a position in the viewport.
  Ray3 rayAt(Offset local) => view.rayThrough(Point(local.dx, local.dy));

  /// Viewport position of [point], or `null` when it is behind the camera.
  Offset? project(Point3 point) {
    final p = view.project(point);
    return p == null ? null : Offset(p.x, p.y);
  }

  /// The nearest pickable [GeoSolid] under [local], or `null`.
  SceneHit? pick(Iterable<SceneNode> nodes, Offset local) {
    final ray = rayAt(local);
    SceneHit? best;
    for (final node in nodes) {
      if (node is! GeoSolid || !node.pickable) continue;
      final hit = node.worldSolid.intersectRay(ray);
      if (hit != null && (best == null || hit.distance < best.hit.distance)) {
        best = SceneHit(node, hit);
      }
    }
    return best;
  }

  /// The [GeoHandle] whose dot is under [local], within its radius plus
  /// [slop] pixels, or `null`. When dots overlap, the one drawn last wins.
  GeoHandle? pickHandle(
    Iterable<SceneNode> nodes,
    Offset local, {
    double slop = 6,
  }) {
    GeoHandle? best;
    for (final node in nodes) {
      if (node is! GeoHandle) continue;
      final s = project(node.position);
      if (s == null) continue;
      if ((s - local).distance <= node.radius + slop) best = node;
    }
    return best;
  }

  /// Where the ray through [local] meets [plane], or `null` when it runs
  /// parallel or the plane is behind the camera.
  Point3? onPlane(Offset local, Plane plane) {
    final ray = rayAt(local);
    final t = plane.intersectRay(ray);
    return t == null ? null : ray.pointAt(t);
  }

  /// A plane through [point] to drag on.
  ///
  /// Uses the plane with [normal] (horizontal by default) unless the camera
  /// sees it nearly edge-on, within [minAngle] degrees, where a pointer
  /// move would fling the point far away. Then it falls back to the plane
  /// facing the camera.
  Plane dragPlane(
    Point3 point, {
    Point3 normal = Point3.unitY,
    double minAngle = 12,
  }) {
    final n = normal.normalized;
    final facing = n.dot(view.forward).abs();
    if (facing >= math.sin(minAngle * math.pi / 180)) {
      return Plane.fromPointNormal(point, n);
    }
    return Plane.fromPointNormal(point, -view.forward);
  }

  @override
  bool operator ==(Object other) =>
      other is SceneViewport && other.camera == camera && other.size == size;

  @override
  int get hashCode => Object.hash(camera, size);
}
