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
  static Circle getPolygonInnerCircle(List<Point> list) {
    assert(list.length >= 3);
    final centroid = getPolygonInnerCentroid(list);

    final c = Point(list[1].x - list[0].x, list[1].y - list[0].y);

    final radius = centroid.distanceTo(c);
    return Circle(radius: radius, center: centroid);
  }

  /// Get the furthest vertex
  ///
  /// only used with centroid of inner circle.
  /// since centroid of outer circle always has same distance to all vertices
  static Point getPolygonFurthestVertexFromCentroid(
      List<Point> list, Point centroid) {
    assert(list.length >= 3);
    Point furthest = centroid;

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
  static Point getPolygonOuterCircleCentroid(List<Point> list) {
    assert(list.length >= 3);

    final n = list.length;

    var center = list.reduce((c, n) => Point(c.x + n.x, c.y + n.y));

    return Point(center.x / n, center.y / n);
  }

  /// Get the centroid of inner circle
  ///
  /// this centroid is calculated from the center of all sides of polygon
  static Point getPolygonInnerCentroid(List<Point> list) {
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

    return Point(cx / n, cy / n);
  }

  /// Check if a point is inside the polygon
  ///
  ///
  static bool isInsidePolygon(Point point, List<Point> polygon) {
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
  static Point getMostRightPoint(List<Point> polygon) {
    assert(polygon.length >= 3);

    var mostRightPoint =
        Point<num>(double.negativeInfinity, double.negativeInfinity);

    for (var p in polygon) {
      if (p.x > mostRightPoint.x) {
        mostRightPoint = p;
      }
    }

    return mostRightPoint;
  }

  /// Get the furthest left point of the polygon
  ///
  ///
  static Point getMostLeftPoint(List<Point> polygon) {
    assert(polygon.length >= 3);
    var mostLeftPoint = Point<num>(double.infinity, double.infinity);

    for (var p in polygon) {
      if (p.x < mostLeftPoint.x) {
        mostLeftPoint = p;
      }
    }

    return mostLeftPoint;
  }

  /// Get the furthest top point of the polygon
  ///
  ///
  static Point getTopPoint(List<Point> polygon) {
    assert(polygon.length >= 3);
    var topPoint = Point<num>(double.negativeInfinity, double.negativeInfinity);

    for (var p in polygon) {
      if (p.y > topPoint.y) {
        topPoint = p;
      }
    }

    return topPoint;
  }

  /// Get the furthest bottom point of the polygon
  ///
  ///
  static Point getBottomPoint(List<Point> polygon) {
    assert(polygon.length >= 3);
    var bottomPoint = Point<num>(double.infinity, double.infinity);

    for (var p in polygon) {
      if (p.y < bottomPoint.y) {
        bottomPoint = p;
      }
    }

    return bottomPoint;
  }

  /// Get all the boundary of the polygon
  ///
  static List<Point> getPolygonBound(List<Point> polygon) {
    assert(polygon.length >= 3);

    Set<Point> list = {};

    list.add(getMostLeftPoint(polygon));
    list.add(getTopPoint(polygon));
    list.add(getMostRightPoint(polygon));
    list.add(getBottomPoint(polygon));
    return list.toList();
  }

  /// Get all sides of the polygon
  ///
  ///
  static List<Line> getPolygonSides(List<Point> polygon) {
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
