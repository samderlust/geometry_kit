part of '../geometry_kit.dart';

/// Line utils
///
///
class LineUtils {
  // static bool isTwoLineIntersect(Line line1, Line line2) {
  //   final det = line1.aVal * line2.bVal - line2.aVal * line1.bVal;

  //   return det != 0;
  // }

  // static Point? getIntersect(Line line1, Line line2) {
  //   final det = line1.aVal * line2.bVal - line2.aVal * line1.bVal;
  //   if (det == 0) {
  //     return null;
  //   } else {
  //     final x = line2.bVal * line1.cVal - line1.bVal * line2.cVal;
  //     final y = line1.aVal * line2.cVal - line2.aVal * line1.cVal;
  //     return Point(x, y);
  //   }
  // }

  /// Check if 2 lines segments intersects
  ///
  ///
  static bool isTwoLineSegmentsIntersect(Line line1, Line line2) {
    final x1 = line1.x1;
    final x2 = line1.x2;
    final x3 = line2.x1;
    final x4 = line2.x2;

    final y1 = line1.y1;
    final y2 = line1.y2;
    final y3 = line2.y1;
    final y4 = line2.y2;

    final t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) /
        ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));

    return t >= 0 && t <= 1;
  }

  /// Get intersect of 2 line segments
  ///
  ///
  static Point? getSegmentIntersect(Line line1, Line line2) {
    final x1 = line1.x1;
    final x2 = line1.x2;
    final x3 = line2.x1;
    final x4 = line2.x2;

    final y1 = line1.y1;
    final y2 = line1.y2;
    final y3 = line2.y1;
    final y4 = line2.y2;

    final t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) /
        ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));

    // final u = ((x1 - x3) * (y1 - y2) - (y1 - y3) * (x1 - x2)) /
    //     ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4));

    if (t >= 0 && t <= 1) {
      return Point(x1 + t * (x2 - x1), y1 + t * (y2 - y1));
    } else {
      return null;
    }
  }

  static double pointToLineDistance(Point point, Line line) {
    final p1 = line.p1;
    final p2 = line.p2;
    final distance =
        ((p2.x - p1.x) * (p1.y - point.y) - (p1.x - point.x) * (p2.y - p1.y))
                .abs() /
            sqrt(pow((p2.x - p1.x), 2) + pow((p2.y - p1.y), 2));

    return distance;
  }

  /// Check if a point is belonged to the segment
  ///
  ///
  static bool isPointBelongToLineSegment(Point point, Line line) {
    final ac = point.distanceTo(line.p1);
    final bc = point.distanceTo(line.p2);
    final ab = line.p1.distanceTo(line.p2);
    return ac + bc == ab;
  }

  /// Get the angle between 2 lines
  ///
  /// result is in radian
  static double angleOf2Lines(Line line1, line2) {
    final a1 = _getAtan2(line1);
    final a2 = _getAtan2(line2);

    if (a1 != double.nan && a2 != double.nan) {
      return a2 - a1;
    }

    return double.nan;
  }

  static double _getAtan2(Line line) {
    // Get the point that closer to x-axis
    Point<num> pa, pb;
    if (line.p1.x > line.p2.x) {
      pa = line.p1;
      pb = line.p2;
    } else {
      pa = line.p2;
      pb = line.p1;
    }
    return atan2(pa.y - pb.y, pa.x - pb.x);
  }

  /// Calculate length of line segment
  static double lineLength(Line line) => line.p1.distanceTo(line.p2);

  /// Get mid point of line segment
  static Point midPoint(Line line) =>
      Point((line.p1.x + line.p2.x) / 2, (line.p1.y + line.p2.y) / 2);
}
