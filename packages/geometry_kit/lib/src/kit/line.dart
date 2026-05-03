import 'dart:math';

import 'point.dart';
import 'units.dart';

/// A line segment defined by two endpoints [a] and [b].
///
/// Provides geometric operations including slope, intercepts,
/// intersection detection, distance calculations, and projections.
///
/// ```dart
/// final line = Line(Point(0, 0), Point(4, 3));
/// print(line.length);   // 5.0
/// print(line.midPoint);  // Point(2, 1.5)
/// ```
class Line {
  /// First endpoint.
  final Point a;

  /// Second endpoint.
  final Point b;

  /// Creates a line segment from point [a] to point [b].
  const Line(this.a, this.b);

  double _getAtan2(Line other) {
    // Get the point that closer to x-axis
    Point pa, pb;
    if (other.a.x > other.b.x) {
      pa = other.a;
      pb = other.b;
    } else {
      pa = other.b;
      pb = other.a;
    }
    return atan2(pa.y - pb.y, pa.x - pb.x);
  }

  /// Get the inner angle between this line and another line
  ///
  /// result is in radian
  Rad innerAngleWith(Line other) {
    final angle = getAngleWith(other);
    return min(angle, pi - angle);
  }

  /// Get the outer angle between this line and another line
  ///
  /// result is in radian
  Rad outerAngleWith(Line other) {
    final angle = innerAngleWith(other);
    return pi - angle;
  }

  /// Get the  angle between this line and another line
  ///
  /// result is in radian
  Rad getAngleWith(Line other) {
    // return atan2(other.slope - slope, 1 + slope * other.slope);
    final a1 = _getAtan2(this);
    final a2 = _getAtan2(other);

    if (!a1.isNaN && !a2.isNaN) {
      return a2 - a1;
    }
    return double.nan;
  }

  /// get the distance from a points to this line
  ///
  ///
  double distanceFromAPoint(Point point) {
    final distance =
        ((b.x - a.x) * (a.y - point.y) - (a.x - point.x) * (b.y - a.y)).abs() /
            sqrt(pow((b.x - a.x), 2) + pow((b.y - a.y), 2));

    return distance;
  }

  /// Get Intersect point of this line and another line
  Point? getIntersectPoint(Line other) {
    final x1 = a.x;
    final x2 = b.x;
    final x3 = other.a.x;
    final x4 = other.b.x;

    final y1 = a.y;
    final y2 = b.y;
    final y3 = other.a.y;
    final y4 = other.b.y;

    final denom = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4);
    if (denom == 0) return null;

    final t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / denom;
    final s = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / denom;

    if (t >= 0 && t <= 1 && s >= 0 && s <= 1) {
      return Point(x1 + t * (x2 - x1), y1 + t * (y2 - y1));
    } else {
      return null;
    }
  }

  /// Get the y-intercept of this line
  ///
  /// Returns `double.nan` for vertical lines (undefined y-intercept).
  double get yIntercept {
    final dx = b.x - a.x;
    if (dx == 0) return double.nan;
    return a.y - slope * a.x;
  }

  /// Get the x-intercept of this line
  ///
  /// Returns `double.nan` for horizontal lines (undefined x-intercept).
  double get xIntercept {
    final dy = b.y - a.y;
    if (dy == 0) return double.nan;
    return a.x - a.y / slope;
  }

  /// Check if a point is belong to this line
  bool hasPoint(Point point) {
    final ac = point.distanceTo(a);
    final bc = point.distanceTo(b);
    final ab = a.distanceTo(b);
    return (ac + bc - ab).abs() < 1e-10;
  }

  /// Check if this line and other line intersect
  bool intersect(Line other) {
    final point = getIntersectPoint(other);
    return point != null;
  }

  /// Length of this line
  double get length => a.distanceTo(b);

  /// The midpoint of the line
  Point get midPoint => Point((a.x + b.x) / 2, (a.y + b.y) / 2);

  /// Get list of points
  List<Point> get points => [a, b];

  /// Get slope of this line
  ///
  /// The slope of a line is defined as the change in y coordinate
  /// with respect to the change in x coordinate of that line.
  double get slope {
    final dx = b.x - a.x;
    if (dx == 0) {
      return (b.y - a.y) >= 0 ? double.infinity : double.negativeInfinity;
    }
    return (b.y - a.y) / dx;
  }

  /// Whether this line segment is vertical (same x for both endpoints)
  bool get isVertical => a.x == b.x;

  /// Whether this line segment is horizontal (same y for both endpoints)
  bool get isHorizontal => a.y == b.y;

  /// Check if this line is parallel to [other]
  ///
  /// Two lines are parallel if they have the same slope,
  /// or both are vertical.
  bool isParallelTo(Line other) {
    final dx1 = b.x - a.x;
    final dy1 = b.y - a.y;
    final dx2 = other.b.x - other.a.x;
    final dy2 = other.b.y - other.a.y;
    // Cross product == 0 means parallel
    return (dx1 * dy2 - dy1 * dx2).abs() < 1e-10;
  }

  /// Check if this line is perpendicular to [other]
  ///
  /// Two lines are perpendicular if their dot product is zero.
  bool isPerpendicularTo(Line other) {
    final dx1 = b.x - a.x;
    final dy1 = b.y - a.y;
    final dx2 = other.b.x - other.a.x;
    final dy2 = other.b.y - other.a.y;
    return (dx1 * dx2 + dy1 * dy2).abs() < 1e-10;
  }

  /// Get closest point on this line segment to [point]
  ///
  /// Returns the perpendicular projection clamped to the segment.
  Point projectPoint(Point point) {
    final dx = b.x - a.x;
    final dy = b.y - a.y;
    final lenSq = dx * dx + dy * dy;
    if (lenSq == 0) return a;

    var t = ((point.x - a.x) * dx + (point.y - a.y) * dy) / lenSq;
    t = t.clamp(0.0, 1.0);
    return Point(a.x + t * dx, a.y + t * dy);
  }

  /// Get point at parameter [t] along segment
  ///
  /// [t] = 0 returns [a], [t] = 1 returns [b], [t] = 0.5 returns [midPoint].
  Point lerp(double t) {
    return Point(a.x + t * (b.x - a.x), a.y + t * (b.y - a.y));
  }

  /// Return new line extended by [amount] from both ends
  Line extend(double amount) {
    final len = length;
    if (len == 0) return this;
    final dx = (b.x - a.x) / len;
    final dy = (b.y - a.y) / len;
    return Line(
      Point(a.x - dx * amount, a.y - dy * amount),
      Point(b.x + dx * amount, b.y + dy * amount),
    );
  }

  /// Translate the line by [x] horizontally and [y] vertically
  Line translate({double x = 0, double y = 0}) {
    return Line(a.translate(x, y), b.translate(x, y));
  }

  /// Scale the line by [factor]
  Line scale(double factor) {
    return Line(a.scale(factor), b.scale(factor));
  }

  /// Rotate the line by [deg] degrees
  Line rotate(double deg) {
    return Line(a.rotate(deg), b.rotate(deg));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Line && other.a == a && other.b == b;
  }

  @override
  int get hashCode => a.hashCode ^ b.hashCode;

  @override
  String toString() => 'Line(a: $a, b: $b)';
}
