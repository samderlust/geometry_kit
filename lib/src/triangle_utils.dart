part of '../geometry_kit.dart';

/// Triangle Utils
class TriangleUtils {
  /// Get the base line of triangle
  ///
  /// In a triangle, baseline is the longest side among the 3.
  static Line getBaseLine(List<Point> triangle) {
    assert(triangle.length == 3);
    final sides = PolygonUtils.getPolygonSides(triangle);
    return sides.reduce((cur, next) => cur.length > next.length ? cur : next);
  }

  /// Get the height of a triangle
  ///
  /// height is the distance from a vertex to the baseline
  static double getHeight(List<Point> triangle) {
    assert(triangle.length == 3);
    final baseLine = getBaseLine(triangle);
    final posVertex =
        triangle.firstWhere((p) => p != baseLine.p1 && p != baseLine.p2);
    final distance = LineUtils.pointToLineDistance(posVertex, baseLine);
    return distance;
  }

  /// get area of a triangle
  ///
  ///
  static double area(List<Point> triangle) {
    assert(triangle.length == 3);
    final baseLine = getBaseLine(triangle);
    final posVertex =
        triangle.firstWhere((p) => p != baseLine.p1 && p != baseLine.p2);
    final distance = LineUtils.pointToLineDistance(posVertex, baseLine);
    return baseLine.length * distance / 2;
  }

  /// get perimeter of a triangle
  ///
  ///
  static double perimeter(List<Point> triangle) {
    assert(triangle.length == 3);
    final sides = PolygonUtils.getPolygonSides(triangle);

    return sides.fold<double>(0.0, (prev, e) => prev + e.length);
  }
}
