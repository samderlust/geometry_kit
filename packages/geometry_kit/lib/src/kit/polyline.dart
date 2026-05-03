import 'dart:math';

import 'line.dart';
import 'point.dart';
import 'rectangle.dart';

/// An open path defined by a sequence of connected points.
///
/// Unlike [Polygon], a polyline is not closed — the last point
/// does not connect back to the first.
class Polyline {
  /// Ordered list of points forming the path
  final List<Point> points;

  const Polyline(this.points) : assert(points.length >= 2);

  /// Total length of the polyline (sum of all segment lengths)
  double get length {
    double total = 0;
    for (int i = 0; i < points.length - 1; i++) {
      total += points[i].distanceTo(points[i + 1]);
    }
    return total;
  }

  /// Number of segments in this polyline
  int get segmentCount => points.length - 1;

  /// Get all line segments
  List<Line> get segments {
    final list = <Line>[];
    for (int i = 0; i < points.length - 1; i++) {
      list.add(Line(points[i], points[i + 1]));
    }
    return list;
  }

  /// First point of the path
  Point get first => points.first;

  /// Last point of the path
  Point get last => points.last;

  /// Axis-aligned bounding box of this polyline
  Rectangle get boundingBox {
    double minX = points.first.x, maxX = points.first.x;
    double minY = points.first.y, maxY = points.first.y;
    for (final p in points) {
      minX = min(minX, p.x);
      maxX = max(maxX, p.x);
      minY = min(minY, p.y);
      maxY = max(maxY, p.y);
    }
    return Rectangle(x: minX, y: minY, width: maxX - minX, height: maxY - minY);
  }

  /// Get point at parameter [t] along the entire polyline
  ///
  /// [t] = 0 returns first point, [t] = 1 returns last point.
  Point pointAt(double t) {
    if (t <= 0) return points.first;
    if (t >= 1) return points.last;

    final targetLen = t * length;
    double accumulated = 0;

    for (int i = 0; i < points.length - 1; i++) {
      final segLen = points[i].distanceTo(points[i + 1]);
      if (accumulated + segLen >= targetLen) {
        final localT = (targetLen - accumulated) / segLen;
        return Line(points[i], points[i + 1]).lerp(localT);
      }
      accumulated += segLen;
    }
    return points.last;
  }

  /// Simplify polyline using Ramer-Douglas-Peucker algorithm
  ///
  /// Removes points closer than [tolerance] to the simplified line.
  Polyline simplify(double tolerance) {
    if (points.length <= 2) return this;
    return Polyline(_rdpSimplify(points, tolerance));
  }

  static List<Point> _rdpSimplify(List<Point> pts, double tolerance) {
    if (pts.length <= 2) return pts;

    final line = Line(pts.first, pts.last);
    double maxDist = 0;
    int maxIdx = 0;

    for (int i = 1; i < pts.length - 1; i++) {
      final d = line.distanceFromAPoint(pts[i]);
      if (d > maxDist) {
        maxDist = d;
        maxIdx = i;
      }
    }

    if (maxDist > tolerance) {
      final left = _rdpSimplify(pts.sublist(0, maxIdx + 1), tolerance);
      final right = _rdpSimplify(pts.sublist(maxIdx), tolerance);
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [pts.first, pts.last];
    }
  }

  /// Translate the polyline
  Polyline translate({double x = 0, double y = 0}) {
    return Polyline(points.map((p) => p.translate(x, y)).toList());
  }

  /// Scale the polyline
  Polyline scale(double factor) {
    return Polyline(points.map((p) => p.scale(factor)).toList());
  }

  /// Rotate the polyline by [deg] degrees
  Polyline rotate(double deg) {
    return Polyline(points.map((p) => p.rotate(deg)).toList());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Polyline) return false;
    if (points.length != other.points.length) return false;
    for (int i = 0; i < points.length; i++) {
      if (points[i] != other.points[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => points.fold(0, (h, p) => h ^ p.hashCode);

  @override
  String toString() => 'Polyline(${points.length} points)';
}
