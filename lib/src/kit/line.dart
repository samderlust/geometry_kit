import 'dart:math' as m;
import 'dart:math';

import 'package:geometry_kit/src/models/line.dart';

import '../interface/line_interface.dart';
import 'point.dart';

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
    return m.atan2(pa.y - pb.y, pa.x - pb.x);
  }

  /// Get the angle between this line and another line
  ///
  /// result is in radian
  double angleWith(Line other) {
    final a1 = _getAtan2(this);
    final a2 = _getAtan2(other);

    if (a1 != double.nan && a2 != double.nan) {
      return a2 - a1;
    }
    return double.nan;
  }

  /// get the distance from this line to a point
  double distanceToAPoint(Point point) {
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

  /// check if a point is belong to this line
  bool hasPoint(Point point) {
    final ac = point.distanceTo(a);
    final bc = point.distanceTo(b);
    final ab = a.distanceTo(b);
    return ac + bc == ab;
  }

  ///check if this line and other line intersect
  bool intersect(Line other) {
    final point = getIntersectPoint(other);
    return point != null;
  }

  /// length of this line
  double get length => a.distanceTo(b);

  /// the midpoint of the line
  Point get midPoint => Point((a.x + b.x) / 2, (a.y + b.y) / 2);
}
