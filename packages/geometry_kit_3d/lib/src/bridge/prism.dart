import 'package:geometry_kit/geometry_kit.dart';

import '../math/aabb.dart';
import '../math/plane.dart';
import '../math/point3.dart';
import '../math/ray3.dart';
import '../mesh/mesh.dart';
import '../mesh/triangulate.dart';
import '../solid/solid.dart';

/// A right prism: a 2D [base] polygon pushed [height] along its frame's
/// normal.
///
/// The bridge from 2D floor plans to 3D rooms. [base] may be concave (an
/// L-shaped room) but must not self-intersect.
///
/// ```dart
/// final plan = Polygon([
///   Point(0, 0), Point(6, 0), Point(6, 3),
///   Point(3.5, 3), Point(3.5, 5), Point(0, 5),
/// ]);
/// final room = Prism.extrude(plan, height: 2.7);
/// print(plan.area);         // 25.0 m²
/// print(room.volume);       // 67.5 m³
/// print(room.lateralArea);  // 59.4 m² of wall
/// ```
class Prism implements Solid {
  /// The 2D cross-section, in [frame] coordinates.
  final Polygon base;

  /// Where the base sits in 3D; the prism grows along `frame.normal`.
  final PlaneFrame frame;

  /// Extrusion distance.
  final double height;

  /// Creates a prism.
  const Prism({
    required this.base,
    required this.height,
    this.frame = PlaneFrame.ground,
  }) : assert(height >= 0);

  /// Extrudes a 2D [polygon] by [height].
  ///
  /// With the default [PlaneFrame.ground] the polygon lies on the floor and
  /// the prism grows up +Y; 2D x maps to 3D x and 2D y to 3D −z, so the
  /// plan looks like its 2D drawing when seen from above.
  factory Prism.extrude(
    Polygon polygon, {
    required double height,
    PlaneFrame frame = PlaneFrame.ground,
  }) =>
      Prism(base: polygon, height: height, frame: frame);

  List<Point> get _ccw {
    final v = base.vertices;
    return signedArea2d(v) < 0 ? v.reversed.toList() : v;
  }

  /// Area of the side walls (perimeter × height).
  double get lateralArea => base.perimeter * height;

  /// Bottom face corners in world space.
  List<Point3> get bottomVertices =>
      [for (final p in base.vertices) frame.toWorld(p)];

  /// Top face corners in world space.
  List<Point3> get topVertices {
    final up = frame.normal * height;
    return [for (final p in bottomVertices) p + up];
  }

  @override
  double get volume => base.area * height;

  @override
  double get surfaceArea => 2 * base.area + lateralArea;

  @override
  Aabb get bounds => Aabb.fromPoints([...bottomVertices, ...topVertices]);

  @override
  bool contains(Point3 point) {
    final h = frame.heightOf(point);
    if (h < -1e-12 || h > height + 1e-12) return false;
    return polygonContains(base.vertices, frame.toLocal(point));
  }

  @override
  Point3 closestPoint(Point3 point) {
    // A prism is polygon × interval, so the closest point splits the same way.
    final local = frame.toLocal(point);
    final q = polygonContains(base.vertices, local)
        ? local
        : closestPointOnPolygonBoundary(base.vertices, local);
    final h = frame.heightOf(point).clamp(0.0, height);
    return frame.toWorld(q) + frame.normal * h;
  }

  @override
  double distanceTo(Point3 point) => closestPoint(point).distanceTo(point);

  @override
  RayHit? intersectRay(Ray3 ray) {
    final n = frame.normal;
    const eps = 1e-9;
    var bestT = double.infinity;
    Point3? bestN;

    // Bottom and top caps.
    for (final (h, outward) in [(0.0, -n), (height, n)]) {
      final denom = n.dot(ray.direction);
      if (denom.abs() < 1e-15) continue;
      final t = (h - frame.heightOf(ray.origin)) / denom;
      if (t < eps || t >= bestT) continue;
      if (polygonContains(base.vertices, frame.toLocal(ray.pointAt(t)))) {
        bestT = t;
        bestN = outward;
      }
    }

    // Side walls.
    final v = _ccw;
    for (var i = 0; i < v.length; i++) {
      final a = v[i], b = v[(i + 1) % v.length];
      final edge = b - a;
      final len = edge.magnitude;
      if (len == 0) continue;
      final out2 = Point(edge.y / len, -edge.x / len); // right of CCW edge
      final outward = frame.u * out2.x + frame.v * out2.y;
      final wall = Plane.fromPointNormal(frame.toWorld(a), outward);
      final denom = outward.dot(ray.direction);
      if (denom.abs() < 1e-15) continue;
      final t = (wall.constant - outward.dot(ray.origin)) / denom;
      if (t < eps || t >= bestT) continue;
      final p = ray.pointAt(t);
      final h = frame.heightOf(p);
      if (h < -eps || h > height + eps) continue;
      final s = (frame.toLocal(p) - a).dot(edge) / (len * len);
      if (s < -eps || s > 1 + eps) continue;
      bestT = t;
      bestN = outward;
    }
    if (bestN == null) return null;
    return RayHit(
        distance: bestT, point: ray.pointAt(bestT), normal: bestN, solid: this);
  }

  @override
  Prism translate({double x = 0, double y = 0, double z = 0}) => Prism(
      base: base, height: height, frame: frame.translate(x: x, y: y, z: z));

  @override
  Prism scale(double factor) => Prism(
        base: base.scale(factor.abs()),
        height: height * factor.abs(),
        frame: frame.scaleOrigin(factor),
      );

  @override
  Prism rotate(Point3 axis, double deg, {Point3 pivot = Point3.zero}) => Prism(
        base: base,
        height: height,
        frame: frame.rotate(axis, deg, pivot: pivot),
      );

  @override
  Mesh toMesh({int segments = 32}) {
    final v = _ccw;
    final n = v.length;
    final up = frame.normal * height;
    final b = MeshBuilder();
    final bottom = [for (final p in v) b.vertex(frame.toWorld(p))];
    final top = [for (final p in v) b.vertex(frame.toWorld(p) + up)];
    final tris = triangulatePolygon(v);
    for (var i = 0; i < tris.length; i += 3) {
      b.triangle(top[tris[i]], top[tris[i + 1]], top[tris[i + 2]]);
      b.triangle(bottom[tris[i]], bottom[tris[i + 2]], bottom[tris[i + 1]]);
    }
    for (var i = 0; i < n; i++) {
      final j = (i + 1) % n;
      b.quad(bottom[i], bottom[j], top[j], top[i]);
    }
    return b.build();
  }

  @override
  bool operator ==(Object other) =>
      other is Prism &&
      other.frame == frame &&
      other.height == height &&
      _listEq(other.base.vertices, base.vertices);

  @override
  int get hashCode => Object.hash(frame, height, Object.hashAll(base.vertices));

  @override
  String toString() =>
      'Prism(${base.vertices.length}-sided base, height: $height, frame: $frame)';
}

bool _listEq(List<Point> a, List<Point> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
