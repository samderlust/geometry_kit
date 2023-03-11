import 'dart:math';

import '../interface/shape.dart';
import 'circle.dart';
import 'line.dart';
import 'point.dart';

class Polygon extends Shape {
  /// List of vertices of polygon
  ///
  /// a polygon must have more than 3 vertices to distinct itself from triangle
  final List<Point> vertices;

  const Polygon(this.vertices) : assert(vertices.length > 2);

  @override
  double get area {
    double x = 0, y = 0;
    final n = vertices.length;

    for (var i = 0; i < n; i++) {
      final nextI = (i + 1) % n;
      x += vertices[i].x * vertices[nextI].y;
      y += vertices[i].y * vertices[nextI].x;
    }

    return (x - y) / 2;
  }

  @override
  double get perimeter => edges.fold(0, (prev, e) => prev + e.length);

  /// Get all edges of this polygon
  List<Line> get edges {
    final list = <Line>[];
    final n = vertices.length;

    for (int i = 0; i < n; i++) {
      var current = vertices[i];
      var next = vertices[(i + 1) % n];

      list.add(Line(current, next));
    }

    return list;
  }

  /// Get the furthest right point of the polygon
  ///
  ///
  Point get mostRightPoint =>
      vertices.reduce((cur, next) => cur.x >= next.x ? cur : next);

  /// Get the furthest left point of the polygon
  ///
  ///
  Point get mostLeftPoint =>
      vertices.reduce((cur, next) => cur.x <= next.x ? cur : next);

  /// Get the furthest top point of the polygon
  ///
  ///
  Point get topPoint =>
      vertices.reduce((cur, next) => cur.y >= next.y ? cur : next);

  /// Get the furthest bottom point of the polygon
  ///
  ///
  Point get bottomPoint =>
      vertices.reduce((cur, next) => cur.y <= next.y ? cur : next);

  /// Get all the boundary of the polygon
  ///
  Polygon getBound() {
    return Polygon([mostLeftPoint, topPoint, mostRightPoint, bottomPoint]);
  }

  /// Check if a point is inside this polygon
  ///
  /// return `false` when:
  ///   - point is out side of the polygon
  ///   - point is on any sides or vertices
  bool contains(Point point) {
    if (vertices.any((p) => p == point)) return true;

    if (point.x < mostLeftPoint.x) return false;
    if (point.y < bottomPoint.y) return false;
    if (point.x > mostRightPoint.x) return false;
    if (point.y > topPoint.y) return false;

    if (edges.any((s) => s.hasPoint(point))) {
      return true;
    }

    final ray = Line(point, Point(mostRightPoint.x + 2, point.y));
    int intersects = 0;

    for (var s in edges) {
      if (ray.intersect(s)) {
        intersects++;
      }
    }

    return intersects % 2 != 0;
  }

  /// Get the centroid of Outer circle
  ///
  /// this centroid is calculated from the distance to the vertices or the polygon.
  Point getCircumCentroid() {
    final n = vertices.length;

    var center = vertices.reduce((c, n) => Point((c.x + n.x), (c.y + n.y)));

    return Point((center.x / n), (center.y / n));
  }

  /// Get the outer circle
  ///
  /// formed by the outer centroid of the polygon and its radius
  Circle getCircumCircle(List<Point> list) {
    assert(list.length >= 3);
    final centroid = getCircumCentroid();

    final radius = centroid.distanceTo(list.first);
    return Circle(radius: radius, center: centroid);
  }

  /// Get the centroid of inner circle
  ///
  /// this centroid is calculated from the center of all sides of polygon
  Point getInnerCentroid() {
    final n = vertices.length;
    var cx = 0.0;
    var cy = 0.0;

    for (var i = 0; i < n; i++) {
      final nextI = (i + 1) % n;
      cx += (vertices[i].x + vertices[nextI].x) *
          (vertices[i].x * vertices[nextI].y +
              vertices[nextI].x +
              vertices[i].y);

      cy += (vertices[i].y + vertices[nextI].y) *
          (vertices[i].y * vertices[nextI].x +
              vertices[nextI].y +
              vertices[i].x);
    }

    return Point((cx / n), (cy / n));
  }

  /// Get the outer circle
  ///
  /// formed by the inner centroid of the polygon and its radius
  Circle getInnerCircle() {
    final centroid = getInnerCentroid();

    int n = vertices.length;
    double radius = 0;
    for (int i = 0; i < n; i++) {
      int nextI = (i + 1) % n;
      int nextI2 = (i + 2) % n;

      Point a = vertices[i];
      Point b = vertices[nextI];
      double d = a.distanceTo(b);
      Point c = vertices[nextI2];
      double s = (b - a) % (c - a) / 2;
      Point p = (a + b) / 2;
      radius = max(radius, centroid.distanceTo(p) * d / s / 3);
    }
    return Circle(radius: radius, center: centroid);
  }

  /// Get closet vertex to the point
  Point getClosetVertex(Point point) {
    return vertices.fold<Point>(vertices.first,
        (v1, v2) => point.distanceTo(v1) > point.distanceTo(v2) ? v2 : v1);
  }

  /// Get furthest vertex to the point
  Point getFurthestVertex(Point point) {
    return vertices.fold<Point>(vertices.first,
        (v1, v2) => point.distanceTo(v1) < point.distanceTo(v2) ? v2 : v1);
  }
}
