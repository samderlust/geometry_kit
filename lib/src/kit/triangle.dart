import 'line.dart';

import '../interface/shape.dart';
import 'point.dart';

class Triangle extends Shape {
  final Point a;
  final Point b;
  final Point c;

  const Triangle(this.a, this.b, this.c) : assert(a != b && b != c && a != c);

  @override
  double get area =>
      (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)) / 2;

  @override
  double get perimeter => sides.fold<double>(0.0, (prev, e) => prev + e.length);

  /// Get baseLine of this triangle
  Line get baseLine =>
      sides.reduce((cur, next) => cur.length > next.length ? cur : next);

  /// Get height value of this triangle
  double get height => baseLine.distanceFromAPoint(posVertex);

  /// Get height Line
  ///
  /// the line that goes from [posVertex] to the midPoint of the [baseLine]
  Line get heightLine => Line(posVertex, baseLine.midPoint);

  /// Get list of 3 vertices of this triangle
  List<Point> get vertices => [a, b, c];

  /// Get 3 sides of this triangle
  List<Line> get sides => [Line(a, b), Line(b, c), Line(c, a)];

  /// Pos vertex
  ///
  /// get the vertex that opposite to the baseline
  Point get posVertex =>
      vertices.firstWhere((p) => p != baseLine.a && p != baseLine.b);
}
