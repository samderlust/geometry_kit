import '../math/aabb.dart';
import '../math/point3.dart';
import '../math/quaternion.dart';
import '../math/ray3.dart';
import '../mesh/mesh.dart';
import 'solid.dart';

/// A rectangular box (cuboid) with any orientation.
///
/// [width], [height] and [depth] are measured along the box's local x, y
/// and z axes, which [rotation] turns into world space.
///
/// ```dart
/// final crate = Box.fromBase(center: Point3.zero, width: 1, depth: 1, height: 2);
/// print(crate.volume);                 // 2.0
/// print(crate.bounds.max.y);           // 2.0
/// final tilted = crate.rotate(Point3.unitZ, 30);
/// ```
class Box implements Solid {
  /// Centre of the box.
  final Point3 center;

  /// Size along the local x axis.
  final double width;

  /// Size along the local y axis.
  final double height;

  /// Size along the local z axis.
  final double depth;

  /// Orientation of the local axes.
  final Quaternion rotation;

  /// Creates a box centred on [center].
  const Box({
    required this.center,
    required this.width,
    required this.height,
    required this.depth,
    this.rotation = Quaternion.identity,
  }) : assert(width >= 0 && height >= 0 && depth >= 0);

  /// An axis-aligned box spanning [min] to [max].
  factory Box.fromMinMax(Point3 min, Point3 max) {
    final s = max - min;
    return Box(
      center: min.midPointTo(max),
      width: s.x.abs(),
      height: s.y.abs(),
      depth: s.z.abs(),
    );
  }

  /// An axis-aligned box standing on the point [center] of its bottom face.
  factory Box.fromBase({
    required Point3 center,
    required double width,
    required double depth,
    required double height,
  }) =>
      Box(
        center: center.translate(y: height / 2),
        width: width,
        height: height,
        depth: depth,
      );

  /// A cube with edge length [size].
  factory Box.cube({required Point3 center, required double size}) =>
      Box(center: center, width: size, height: size, depth: size);

  Point3 get _half => Point3(width / 2, height / 2, depth / 2);

  /// World direction of the local x axis.
  Point3 get axisX => rotation.rotate(Point3.unitX);

  /// World direction of the local y axis.
  Point3 get axisY => rotation.rotate(Point3.unitY);

  /// World direction of the local z axis.
  Point3 get axisZ => rotation.rotate(Point3.unitZ);

  /// Converts a world point to the box's local frame (centre at origin).
  Point3 toLocal(Point3 point) => rotation.conjugate.rotate(point - center);

  /// Converts a local point to world space.
  Point3 toWorld(Point3 local) => center + rotation.rotate(local);

  /// The eight corners in world space.
  ///
  /// Index bits are `x * 4 + y * 2 + z`, where 0 = negative side.
  List<Point3> get corners {
    final h = _half;
    return [
      for (final sx in const [-1.0, 1.0])
        for (final sy in const [-1.0, 1.0])
          for (final sz in const [-1.0, 1.0])
            toWorld(Point3(h.x * sx, h.y * sy, h.z * sz)),
    ];
  }

  @override
  double get volume => width * height * depth;

  @override
  double get surfaceArea =>
      2 * (width * height + width * depth + height * depth);

  @override
  Aabb get bounds => Aabb.fromPoints(corners);

  @override
  bool contains(Point3 point) {
    final l = toLocal(point), h = _half;
    const e = 1e-12;
    return l.x.abs() <= h.x + e && l.y.abs() <= h.y + e && l.z.abs() <= h.z + e;
  }

  @override
  Point3 closestPoint(Point3 point) {
    final l = toLocal(point), h = _half;
    return toWorld(Point3(
      l.x.clamp(-h.x, h.x),
      l.y.clamp(-h.y, h.y),
      l.z.clamp(-h.z, h.z),
    ));
  }

  @override
  double distanceTo(Point3 point) => closestPoint(point).distanceTo(point);

  @override
  RayHit? intersectRay(Ray3 ray) {
    final local =
        Ray3(toLocal(ray.origin), rotation.conjugate.rotate(ray.direction));
    final h = _half;
    final range = Aabb.slab(local, -h, h);
    if (range == null) return null;
    final t = range.$1 >= 0 ? range.$1 : range.$2;
    final lp = local.pointAt(t);
    // The face hit is the axis where the point is closest to the boundary.
    var best = 0;
    var bestRatio = -1.0;
    for (var k = 0; k < 3; k++) {
      final size = h[k];
      final ratio = size == 0 ? 1.0 : (lp[k].abs() / size);
      if (ratio > bestRatio) {
        bestRatio = ratio;
        best = k;
      }
    }
    final sign = lp[best] >= 0 ? 1.0 : -1.0;
    final ln = switch (best) {
      0 => Point3(sign, 0, 0),
      1 => Point3(0, sign, 0),
      _ => Point3(0, 0, sign),
    };
    return RayHit(
      distance: t,
      point: ray.pointAt(t),
      normal: rotation.rotate(ln),
      solid: this,
    );
  }

  /// Whether this box touches or overlaps [other] (separating axis test).
  bool intersectsBox(Box other) {
    if (!bounds.overlaps(other.bounds)) return false;
    final a = [axisX, axisY, axisZ],
        b = [other.axisX, other.axisY, other.axisZ];
    final axes = <Point3>[...a, ...b];
    for (final u in a) {
      for (final v in b) {
        final c = u.cross(v);
        if (c.magnitudeSquared > 1e-12) axes.add(c.normalized);
      }
    }
    final d = other.center - center;
    final ha = _half, hb = other._half;
    for (final axis in axes) {
      final ra = ha.x * a[0].dot(axis).abs() +
          ha.y * a[1].dot(axis).abs() +
          ha.z * a[2].dot(axis).abs();
      final rb = hb.x * b[0].dot(axis).abs() +
          hb.y * b[1].dot(axis).abs() +
          hb.z * b[2].dot(axis).abs();
      if (d.dot(axis).abs() > ra + rb + 1e-12) return false;
    }
    return true;
  }

  @override
  Box translate({double x = 0, double y = 0, double z = 0}) => Box(
        center: center.translate(x: x, y: y, z: z),
        width: width,
        height: height,
        depth: depth,
        rotation: rotation,
      );

  @override
  Box scale(double factor) => Box(
        center: center * factor,
        width: width * factor.abs(),
        height: height * factor.abs(),
        depth: depth * factor.abs(),
        rotation: rotation,
      );

  @override
  Box rotate(Point3 axis, double deg, {Point3 pivot = Point3.zero}) => Box(
        center: center.rotate(axis, deg, pivot: pivot),
        width: width,
        height: height,
        depth: depth,
        rotation: (Quaternion.fromAxisAngle(axis, deg) * rotation).normalized,
      );

  @override
  Mesh toMesh({int segments = 32}) {
    final c = corners;
    final b = MeshBuilder();
    final idx = [for (final p in c) b.vertex(p)];
    void face(List<int> q, Point3 outward) {
      final n = (c[q[1]] - c[q[0]]).cross(c[q[2]] - c[q[0]]);
      final ordered = n.dot(outward) >= 0 ? q : q.reversed.toList();
      b.quad(
          idx[ordered[0]], idx[ordered[1]], idx[ordered[2]], idx[ordered[3]]);
    }

    face([4, 6, 7, 5], axisX); // +x
    face([0, 1, 3, 2], -axisX); // -x
    face([2, 3, 7, 6], axisY); // +y
    face([0, 4, 5, 1], -axisY); // -y
    face([1, 5, 7, 3], axisZ); // +z
    face([0, 2, 6, 4], -axisZ); // -z
    return b.build();
  }

  @override
  bool operator ==(Object other) =>
      other is Box &&
      other.center == center &&
      other.width == width &&
      other.height == height &&
      other.depth == depth &&
      other.rotation == rotation;

  @override
  int get hashCode => Object.hash(center, width, height, depth, rotation);

  @override
  String toString() => 'Box(center: $center, size: $width × $height × $depth)';
}
