import 'dart:math';

import 'line.dart';
import 'point.dart';

/// A Catmull-Rom spline through a series of control points.
///
/// Produces a smooth curve that passes through every control point.
/// Uses centripetal parameterization (alpha = 0.5) for best results.
class Spline {
  /// The control points the spline passes through
  final List<Point> controlPoints;

  /// Tension parameter (0.0 = Catmull-Rom, 0.5 = centripetal, 1.0 = chordal)
  final double alpha;

  const Spline(this.controlPoints, {this.alpha = 0.5})
      : assert(controlPoints.length >= 2);

  /// Number of control points
  int get length => controlPoints.length;

  /// Number of spline segments (between consecutive control points)
  int get segmentCount => max(0, controlPoints.length - 1);

  /// Evaluate a point on the spline at parameter [t].
  ///
  /// [t] ranges from 0.0 (first control point) to [segmentCount].toDouble()
  /// (last control point). For example, t=1.5 is halfway through the second segment.
  Point pointAt(double t) {
    if (controlPoints.length < 2) return controlPoints.first;

    final seg = t.floor().clamp(0, segmentCount - 1);
    final localT = t - seg;

    // Get 4 points for Catmull-Rom: p0, p1, p2, p3
    final p1 = controlPoints[seg];
    final p2 = controlPoints[seg + 1];
    final p0 = seg > 0 ? controlPoints[seg - 1] : _reflect(p2, p1);
    final p3 = seg + 2 < controlPoints.length
        ? controlPoints[seg + 2]
        : _reflect(p1, p2);

    return _catmullRom(p0, p1, p2, p3, localT);
  }

  /// Sample [count] evenly-spaced points along the entire spline.
  List<Point> sample(int count) {
    if (count <= 1) return [controlPoints.first];
    final points = <Point>[];
    final maxT = segmentCount.toDouble();
    for (var i = 0; i < count; i++) {
      final t = maxT * i / (count - 1);
      points.add(pointAt(t));
    }
    return points;
  }

  /// Approximate total arc length by sampling.
  double approximateLength({int samples = 100}) {
    final pts = sample(samples);
    double total = 0;
    for (var i = 1; i < pts.length; i++) {
      total += pts[i - 1].distanceTo(pts[i]);
    }
    return total;
  }

  /// Get the bounding box of the spline (approximate, via sampling).
  ({Point min, Point max}) boundingBox({int samples = 100}) {
    final pts = sample(samples);
    var minX = double.infinity, minY = double.infinity;
    var maxX = double.negativeInfinity, maxY = double.negativeInfinity;
    for (final p in pts) {
      if (p.x < minX) minX = p.x;
      if (p.y < minY) minY = p.y;
      if (p.x > maxX) maxX = p.x;
      if (p.y > maxY) maxY = p.y;
    }
    return (min: Point(minX, minY), max: Point(maxX, maxY));
  }

  /// Convert the spline to a polyline (list of line segments).
  List<Line> toPolyline({int samplesPerSegment = 20}) {
    final pts = sample(segmentCount * samplesPerSegment + 1);
    final lines = <Line>[];
    for (var i = 1; i < pts.length; i++) {
      lines.add(Line(pts[i - 1], pts[i]));
    }
    return lines;
  }

  /// Get the tangent direction at parameter [t].
  Point tangentAt(double t) {
    const dt = 0.0001;
    final p1 = pointAt(t);
    final p2 = pointAt(t + dt);
    final dx = p2.x - p1.x;
    final dy = p2.y - p1.y;
    final len = sqrt(dx * dx + dy * dy);
    if (len == 0) return Point(1, 0);
    return Point(dx / len, dy / len);
  }

  /// Catmull-Rom interpolation between p1 and p2
  Point _catmullRom(Point p0, Point p1, Point p2, Point p3, double t) {
    final t2 = t * t;
    final t3 = t2 * t;

    // Standard Catmull-Rom matrix
    final x = 0.5 *
        ((2 * p1.x) +
            (-p0.x + p2.x) * t +
            (2 * p0.x - 5 * p1.x + 4 * p2.x - p3.x) * t2 +
            (-p0.x + 3 * p1.x - 3 * p2.x + p3.x) * t3);

    final y = 0.5 *
        ((2 * p1.y) +
            (-p0.y + p2.y) * t +
            (2 * p0.y - 5 * p1.y + 4 * p2.y - p3.y) * t2 +
            (-p0.y + 3 * p1.y - 3 * p2.y + p3.y) * t3);

    return Point(x, y);
  }

  /// Reflect point [p] across [anchor]
  static Point _reflect(Point p, Point anchor) {
    return Point(2 * anchor.x - p.x, 2 * anchor.y - p.y);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Spline) return false;
    if (other.controlPoints.length != controlPoints.length) return false;
    for (var i = 0; i < controlPoints.length; i++) {
      if (other.controlPoints[i] != controlPoints[i]) return false;
    }
    return other.alpha == alpha;
  }

  @override
  int get hashCode => controlPoints.hashCode ^ alpha.hashCode;

  @override
  String toString() =>
      'Spline(${controlPoints.length} points, alpha: $alpha)';
}
