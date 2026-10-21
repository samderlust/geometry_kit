import 'package:geometry_kit/geometry_kit.dart';

/// Signed area of a 2D polygon; positive when counter-clockwise.
double signedArea2d(List<Point> polygon) {
  var sum = 0.0;
  for (var i = 0; i < polygon.length; i++) {
    final a = polygon[i], b = polygon[(i + 1) % polygon.length];
    sum += a.x * b.y - b.x * a.y;
  }
  return sum / 2;
}

/// Splits a simple 2D polygon (convex or concave, no holes) into triangles
/// using ear clipping.
///
/// Returns indices into [polygon], three per triangle, each triangle
/// counter-clockwise regardless of the input winding.
List<int> triangulatePolygon(List<Point> polygon) {
  final n = polygon.length;
  if (n < 3) return const [];
  final order = List<int>.generate(n, (i) => i);
  if (signedArea2d(polygon) < 0) {
    order.setAll(0, order.reversed.toList());
  }
  final out = <int>[];
  var guard = 0;
  while (order.length > 3 && guard < n * n) {
    guard++;
    var clipped = false;
    for (var i = 0; i < order.length; i++) {
      final ia = order[(i - 1 + order.length) % order.length];
      final ib = order[i];
      final ic = order[(i + 1) % order.length];
      final a = polygon[ia], b = polygon[ib], c = polygon[ic];
      if (_cross(a, b, c) <= 1e-14) continue; // reflex or flat corner
      var containsOther = false;
      for (final j in order) {
        if (j == ia || j == ib || j == ic) continue;
        if (_inTriangle(polygon[j], a, b, c)) {
          containsOther = true;
          break;
        }
      }
      if (containsOther) continue;
      out.addAll([ia, ib, ic]);
      order.removeAt(i);
      clipped = true;
      break;
    }
    if (!clipped) {
      // Degenerate input (collinear or self-touching); drop a flat vertex.
      var removed = false;
      for (var i = 0; i < order.length; i++) {
        final a = polygon[order[(i - 1 + order.length) % order.length]];
        final b = polygon[order[i]];
        final c = polygon[order[(i + 1) % order.length]];
        if (_cross(a, b, c).abs() <= 1e-14) {
          order.removeAt(i);
          removed = true;
          break;
        }
      }
      if (!removed) break;
    }
  }
  if (order.length == 3) out.addAll(order);
  return out;
}

double _cross(Point a, Point b, Point c) =>
    (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);

bool _inTriangle(Point p, Point a, Point b, Point c) =>
    _cross(a, b, p) >= 0 && _cross(b, c, p) >= 0 && _cross(c, a, p) >= 0;

/// Whether [p] is inside the simple polygon [polygon] (boundary counts as
/// inside within floating-point tolerance).
bool polygonContains(List<Point> polygon, Point p) {
  if (closestPointOnPolygonBoundary(polygon, p).distanceTo(p) <= 1e-12) {
    return true;
  }
  var inside = false;
  for (var i = 0, j = polygon.length - 1; i < polygon.length; j = i++) {
    final a = polygon[i], b = polygon[j];
    if ((a.y > p.y) != (b.y > p.y) &&
        p.x < (b.x - a.x) * (p.y - a.y) / (b.y - a.y) + a.x) {
      inside = !inside;
    }
  }
  return inside;
}

/// Point on the boundary of [polygon] closest to [p].
Point closestPointOnPolygonBoundary(List<Point> polygon, Point p) {
  var best = polygon.first;
  var bestD = double.infinity;
  for (var i = 0; i < polygon.length; i++) {
    final q = closestPointOnSegment2d(
        polygon[i], polygon[(i + 1) % polygon.length], p);
    final d = q.distanceTo(p);
    if (d < bestD) {
      bestD = d;
      best = q;
    }
  }
  return best;
}

/// Point on segment [a]–[b] closest to [p].
Point closestPointOnSegment2d(Point a, Point b, Point p) {
  final d = b - a;
  final l2 = d.dot(d);
  if (l2 == 0) return a;
  final t = ((p - a).dot(d) / l2).clamp(0.0, 1.0);
  return a + d * t;
}
