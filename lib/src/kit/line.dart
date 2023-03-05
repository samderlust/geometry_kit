import 'dart:math';

import 'point.dart';
import 'units.dart';

class Line {
  final Point a;
  final Point b;

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

    if (a1 != double.nan && a2 != double.nan) {
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

    final t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) /
        ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));

    if (t >= 0 && t <= 1) {
      return Point(x1 + t * (x2 - x1), y1 + t * (y2 - y1));
    } else {
      return null;
    }
  }

  /// Check if a point is belong to this line
  bool hasPoint(Point point) {
    final ac = point.distanceTo(a);
    final bc = point.distanceTo(b);
    final ab = a.distanceTo(b);
    return ac + bc == ab;
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
  double get slope => (b.y - a.y) / (b.x - a.x);

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
