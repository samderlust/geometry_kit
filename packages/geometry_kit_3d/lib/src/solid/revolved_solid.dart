import 'dart:math';

import 'package:geometry_kit/geometry_kit.dart';

import '../math/aabb.dart';
import '../math/point3.dart';
import '../math/ray3.dart';
import '../mesh/mesh.dart';
import '../mesh/triangulate.dart';
import 'solid.dart';

/// Base class for solids made by spinning a 2D region around an axis.
///
/// Subclasses describe the region as a [meridian] polygon in `(r, h)`
/// coordinates: `r` is the distance from the axis (never negative) and `h`
/// the height along [axis] from [origin]. Every query is answered exactly
/// from that polygon, so a cylinder, cone or lathe profile all share the
/// same ray intersection, containment and mesh code.
abstract class RevolvedSolid implements Solid {
  /// Const constructor for subclasses.
  const RevolvedSolid();

  /// Point on the axis where `h = 0`.
  Point3 get origin;

  /// Unit direction of the axis of revolution.
  Point3 get axis;

  /// Closed region in `(r, h)` coordinates, `r >= 0`, any winding.
  List<Point> get meridian;

  /// [meridian] wound clockwise, which makes revolved quads face outward.
  List<Point> get _cw {
    final m = meridian;
    return signedArea2d(m) > 0 ? m.reversed.toList() : m;
  }

  /// First reference direction perpendicular to [axis].
  Point3 get _e1 => axis.anyPerpendicular;

  /// Second reference direction, `e1 × axis`.
  Point3 get _e2 => _e1.cross(axis);

  /// Splits [point] into `(r, h)` plus the unit radial direction.
  (Point, Point3) _toMeridian(Point3 point) {
    final d = point - origin;
    final h = d.dot(axis);
    final radial = d - axis * h;
    final r = radial.magnitude;
    return (Point(r, h), r == 0 ? _e1 : radial / r);
  }

  Point3 _fromMeridian(Point q, Point3 radialDir) =>
      origin + axis * q.y + radialDir * q.x;

  @override
  double get volume {
    // Pappus via Green's theorem: V = (pi / 3) * sum (h2 - h1)(r1² + r1 r2 + r2²)
    final m = meridian;
    var sum = 0.0;
    for (var i = 0; i < m.length; i++) {
      final a = m[i], b = m[(i + 1) % m.length];
      sum += (b.y - a.y) * (a.x * a.x + a.x * b.x + b.x * b.x);
    }
    return (pi / 3 * sum).abs();
  }

  @override
  double get surfaceArea {
    final m = meridian;
    var sum = 0.0;
    for (var i = 0; i < m.length; i++) {
      final a = m[i], b = m[(i + 1) % m.length];
      sum += pi * (a.x + b.x) * a.distanceTo(b);
    }
    return sum;
  }

  @override
  Aabb get bounds {
    // Each meridian vertex sweeps a circle; edges are frusta, which lie
    // inside the convex hull of their end circles.
    final extent = Point3(
      sqrt(max(0, 1 - axis.x * axis.x)),
      sqrt(max(0, 1 - axis.y * axis.y)),
      sqrt(max(0, 1 - axis.z * axis.z)),
    );
    Aabb? box;
    for (final q in meridian) {
      final c = origin + axis * q.y;
      final ring = Aabb.centered(c, extent * q.x);
      box = box == null ? ring : box.union(ring);
    }
    return box!;
  }

  @override
  bool contains(Point3 point) =>
      polygonContains(meridian, _toMeridian(point).$1);

  @override
  Point3 closestPoint(Point3 point) {
    final (q, dir) = _toMeridian(point);
    if (polygonContains(meridian, q)) return point;
    return _fromMeridian(closestPointOnPolygonBoundary(meridian, q), dir);
  }

  @override
  double distanceTo(Point3 point) => closestPoint(point).distanceTo(point);

  @override
  RayHit? intersectRay(Ray3 ray) {
    final e1 = _e1, e2 = _e2;
    final d0 = ray.origin - origin;
    // Ray in local coordinates: (a, b) radial plane, h along the axis.
    final oa = d0.dot(e1), ob = d0.dot(e2), oh = d0.dot(axis);
    final da = ray.direction.dot(e1),
        db = ray.direction.dot(e2),
        dh = ray.direction.dot(axis);
    const eps = 1e-9;
    final m = _cw;
    var bestT = double.infinity;
    Point? bestNormal;

    void consider(double t, int edge) {
      if (t < eps || t >= bestT) return;
      final a = m[edge], b = m[(edge + 1) % m.length];
      final n = Point(-(b.y - a.y), b.x - a.x); // outward for clockwise
      bestT = t;
      bestNormal = n.normalized;
    }

    for (var i = 0; i < m.length; i++) {
      final p1 = m[i], p2 = m[(i + 1) % m.length];
      final r1 = p1.x, h1 = p1.y, r2 = p2.x, h2 = p2.y;
      if (r1 == 0 && r2 == 0) continue; // edge on the axis
      if ((h2 - h1).abs() < 1e-12) {
        // Flat ring (disk or annulus) at height h1.
        if (dh.abs() < 1e-15) continue;
        final t = (h1 - oh) / dh;
        final x = oa + da * t, y = ob + db * t;
        final rho = sqrt(x * x + y * y);
        if (rho >= min(r1, r2) - eps && rho <= max(r1, r2) + eps) {
          consider(t, i);
        }
        continue;
      }
      // Frustum: r(h) = c0 + k h.
      final k = (r2 - r1) / (h2 - h1);
      final c0 = r1 - k * h1;
      final rr = c0 + k * oh;
      final qa = da * da + db * db - k * k * dh * dh;
      final qb = 2 * (oa * da + ob * db - rr * k * dh);
      final qc = oa * oa + ob * ob - rr * rr;
      final roots = <double>[];
      if (qa.abs() < 1e-14) {
        if (qb.abs() > 1e-14) roots.add(-qc / qb);
      } else {
        final disc = qb * qb - 4 * qa * qc;
        if (disc >= 0) {
          final s = sqrt(disc);
          roots
            ..add((-qb - s) / (2 * qa))
            ..add((-qb + s) / (2 * qa));
        }
      }
      for (final t in roots) {
        final h = oh + dh * t;
        final s = (h - h1) / (h2 - h1);
        if (s < -eps || s > 1 + eps) continue;
        if (c0 + k * h < -eps) continue; // mirror nappe of the cone
        consider(t, i);
      }
    }
    if (bestNormal == null) return null;
    final p = ray.pointAt(bestT);
    final (_, dir) = _toMeridian(p);
    final n = (dir * bestNormal!.x + axis * bestNormal!.y).normalized;
    return RayHit(distance: bestT, point: p, normal: n, solid: this);
  }

  @override
  Mesh toMesh({int segments = 32}) {
    final seg = max(3, segments);
    final e1 = _e1, e2 = _e2;
    final m = _cw;
    final b = MeshBuilder();
    final rings = <List<int>>[];
    for (final q in m) {
      if (q.x == 0) {
        final v = b.vertex(origin + axis * q.y);
        rings.add(List.filled(seg, v));
      } else {
        rings.add([
          for (var i = 0; i < seg; i++)
            b.vertex(origin +
                axis * q.y +
                (e1 * cos(2 * pi * i / seg) + e2 * sin(2 * pi * i / seg)) *
                    q.x),
        ]);
      }
    }
    for (var j = 0; j < m.length; j++) {
      final a = rings[j], c = rings[(j + 1) % m.length];
      if (m[j].x == 0 && m[(j + 1) % m.length].x == 0) continue;
      for (var i = 0; i < seg; i++) {
        final i2 = (i + 1) % seg;
        b.quad(a[i], a[i2], c[i2], c[i]);
      }
    }
    return b.build();
  }
}
