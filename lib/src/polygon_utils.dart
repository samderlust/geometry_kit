part of '../geometry_kit.dart';

/// Polygon Utils
///
///
class PolygonUtils {
  /// Get the outer circle
  ///
  /// formed by the outer centroid of the polygon and its radius
  static Circle getPolygonOuterCircle(List<Point> list) {
    assert(list.length >= 3);
    final centroid = getPolygonOuterCircleCentroid(list);

    final radius = centroid.distanceTo(list.first);
    return Circle(radius: radius, center: centroid);
  }

  /// Get the outer circle
  ///
  /// formed by the inner centroid of the polygon and its radius
  static Circle getPolygonInnerCircle<T extends num>(List<Point<T>> list) {
    assert(list.length >= 3);
    final centroid = getPolygonInnerCentroid(list);

    final c =
        Point<T>((list[1].x - list[0].x) as T, (list[1].y - list[0].y) as T);

    final radius = centroid.distanceTo(c);
    return Circle(radius: radius, center: centroid);
  }

  /// Get the furthest vertex
  ///
  /// only used with centroid of inner circle.
  /// since centroid of outer circle always has same distance to all vertices
  static Point<T> getPolygonFurthestVertexFromCentroid<T extends num>(
      List<Point<T>> list, Point<T> centroid) {
    assert(list.length >= 3);
    Point<T> furthest = centroid;

    num distance = 0;
    for (var p in list) {
      final d = centroid.distanceTo(p);
      if (d > distance) {
        distance = d;
        furthest = p;
      }
    }
    return furthest;
  }

  /// Get the centroid of Outer circle
  ///
  /// this centroid is calculated from the distance to the vertices or the polygon.
  static Point<T> getPolygonOuterCircleCentroid<T extends num>(
      List<Point<T>> list) {
    assert(list.length >= 3);

    final n = list.length;
    T a, b;

    var center =
        list.reduce((c, n) => Point((c.x + n.x) as T, (c.y + n.y) as T));

    return Point((center.x / n) as T, (center.y / n) as T);
  }

  /// Get the centroid of inner circle
  ///
  /// this centroid is calculated from the center of all sides of polygon
  static Point<T> getPolygonInnerCentroid<T extends num>(List<Point<T>> list) {
    assert(list.length >= 3);

    final n = list.length;
    var cx = 0.0;
    var cy = 0.0;

    for (var i = 0; i < n; i++) {
      final nextI = (i + 1) % n;
      cx += (list[i].x + list[nextI].x) *
          (list[i].x * list[nextI].y + list[nextI].x + list[i].y);

      cy += (list[i].y + list[nextI].y) *
          (list[i].y * list[nextI].x + list[nextI].y + list[i].x);
    }

    return Point((cx / n) as T, (cy / n) as T);
  }

  /// Check if a point is inside the polygon
  ///
  ///
  static bool isInsidePolygon<T extends num>(
      Point<T> point, List<Point<T>> polygon) {
    assert(polygon.length >= 3);

    if (polygon.any((p) => p == point)) return true;

    if (point.x < getMostLeftPoint(polygon).x) return false;
    if (point.y < getBottomPoint(polygon).y) return false;
    if (point.x > getMostRightPoint(polygon).x) return false;
    if (point.y > getTopPoint(polygon).y) return false;

    final sides = getPolygonSides(polygon);

    if (sides.any((s) => LineUtils.isPointBelongToLineSegment(point, s))) {
      return true;
    }

    final ray = Line(point, Point(getMostRightPoint(polygon).x + 2, point.y));
    int intersects = 0;

    for (var s in sides) {
      if (LineUtils.isTwoLineSegmentsIntersect(ray, s)) {
        intersects++;
      }
    }

    return intersects % 2 != 0;
  }

  /// Get the furthest right point of the polygon
  ///
  ///
  static Point<T> getMostRightPoint<T extends num>(List<Point<T>> polygon) {
    assert(polygon.length >= 3);

    return polygon.reduce((cur, next) => cur.x >= next.x ? cur : next);
  }

  /// Get the furthest left point of the polygon
  ///
  ///
  static Point<T> getMostLeftPoint<T extends num>(List<Point<T>> polygon) {
    assert(polygon.length >= 3);

    return polygon.reduce((cur, next) => cur.x <= next.x ? cur : next);
  }

  /// Get the furthest top point of the polygon
  ///
  ///
  static Point<T> getTopPoint<T extends num>(List<Point<T>> polygon) {
    assert(polygon.length >= 3);

    return polygon.reduce((cur, next) => cur.y >= next.y ? cur : next);
  }

  /// Get the furthest bottom point of the polygon
  ///
  ///
  static Point<T> getBottomPoint<T extends num>(List<Point<T>> polygon) {
    assert(polygon.length >= 3);

    return polygon.reduce((cur, next) => cur.y <= next.y ? cur : next);
  }

  /// Get all the boundary of the polygon
  ///
  static List<Point<T>> getPolygonBound<T extends num>(List<Point<T>> polygon) {
    assert(polygon.length >= 3);

    Set<Point<T>> list = {};

    list.add(getMostLeftPoint(polygon));
    list.add(getTopPoint(polygon));
    list.add(getMostRightPoint(polygon));
    list.add(getBottomPoint(polygon));
    return list.toList();
  }

  /// Get all sides of the polygon
  ///
  ///
  static List<Line> getPolygonSides<T extends num>(List<Point> polygon) {
    assert(polygon.length >= 3);

    final n = polygon.length;
    List<Line> sides = [];

    for (var i = 0; i < n; i++) {
      final nextI = (i + 1) % n;
      final newSide = Line(polygon[i], polygon[nextI]);
      sides.add(newSide);
    }

    return sides;
  }

  // static List<Triangle> triangulate(List<Point> polygon) {
  //   assert(polygon.length >= 4);
  //   Set<Triangle> triangles = {};
  //   final basePoint = polygon.first;

  //   for (var i = 1; i < polygon.length - 1; i++) {
  //     var newTriangle = Triangle(basePoint, polygon[i], polygon[i + 1]);
  //     triangles.add(newTriangle);
  //   }

  //   return triangles.toList();
  // }

  /// Get Polygon perimeter
  ///
  ///
  static double perimeter(List<Point> polygon) {
    assert(polygon.length >= 3);

    final sides = getPolygonSides(polygon);

    return sides.fold(0, (prev, e) => prev + e.length);
  }

  // static double area2(List<Point> polygon) {
  //   assert(polygon.length >= 3);
  //   final triangles = triangulate(polygon);
  //   double area = 0;
  //   for (var t in triangles) {
  //     area += TriangleUtils.area(t.values);
  //   }
  //   return area;
  // }

  /// Get Polygon area
  ///
  /// This algorithm could be wrong when work with polygon that contains crossed lines
  static double area(List<Point> polygon) {
    assert(polygon.length >= 3);

    final n = polygon.length;
    num x = 0, y = 0;

    for (var i = 0; i < n; i++) {
      final nextI = (i + 1) % n;
      x += polygon[i].x * polygon[nextI].y;
      y += polygon[i].y * polygon[nextI].x;
    }

    return (x - y) / 2;
  }
}
