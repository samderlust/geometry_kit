import 'dart:math';

import 'package:geometry_kit/src/kit/units.dart';

import '../interface/shape.dart';
import 'circle.dart';
import 'line.dart';
import 'point.dart';

/// A triangle defined by three vertices [a], [b], and [c].
///
/// Implements [Shape] and provides classification checks (right, equilateral,
/// isosceles, scalene, acute, obtuse), special points (centroid, circumcenter,
/// incenter, orthocenter), and inscribed/circumscribed circle computation.
///
/// ```dart
/// final t = Triangle(Point(0, 0), Point(4, 0), Point(2, 3));
/// print(t.area);        // 6.0
/// print(t.isAcute);     // true
/// print(t.centroid);    // Point(2, 1)
/// ```
class Triangle implements Shape {
  /// First vertex.
  final Point a;

  /// Second vertex.
  final Point b;

  /// Third vertex.
  final Point c;

  /// Creates a triangle from three vertices.
  ///
  /// All three points must be distinct.
  const Triangle(this.a, this.b, this.c) : assert(a != b && b != c && a != c);

  /// Creates an equilateral triangle inscribed in a circle with given
  /// [center] and [radius].
  factory Triangle.equilateral(
      {required Point center, required double radius}) {
    Point a = center.pointAtAngle(radius, 0);
    Point b = center.pointAtAngle(radius, 2 * pi / 3);
    Point c = center.pointAtAngle(radius, 4 * pi / 3);
    return Triangle(a, b, c);
  }

  @override
  double get area =>
      (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)) / 2;

  @override
  double get perimeter => sides.fold<double>(0.0, (prev, e) => prev + e.length);

  /// Interior angles at vertices [a], [b], [c] in radians.
  List<Rad> get angles {
    return [_angleAt(a, b, c), _angleAt(b, c, a), _angleAt(c, a, b)];
  }

  /// Angle at vertex [vertex] formed by edges to [p1] and [p2]
  static Rad _angleAt(Point vertex, Point p1, Point p2) {
    final v1x = p1.x - vertex.x, v1y = p1.y - vertex.y;
    final v2x = p2.x - vertex.x, v2y = p2.y - vertex.y;
    final dot = v1x * v2x + v1y * v2y;
    final cross = v1x * v2y - v1y * v2x;
    return atan2(cross.abs(), dot);
  }

  static const double _epsilon = 1e-4;

  /// Check if this triangle is right
  ///
  /// triangle is right when there is an angle equals to 90 degrees
  bool get isRightTriangle {
    final rightAngle = (pi / 2);
    return angles.any((a) => (a - rightAngle).abs() < _epsilon);
  }

  /// Check is this triangle is equilateral
  ///
  /// true if 3 sides have the same length
  bool get isEquilateral {
    return (AB.length - BC.length).abs() < _epsilon &&
        (BC.length - CA.length).abs() < _epsilon;
  }

  /// Check is this triangle is Isosceles
  ///
  /// true if at least 2 sides have the same length
  bool get isIsosceles {
    return (AB.length - BC.length).abs() < _epsilon ||
        (BC.length - CA.length).abs() < _epsilon ||
        (AB.length - CA.length).abs() < _epsilon;
  }

  /// Check is this triangle is Acute
  ///
  /// true if this has 3 angles < 90 degrees
  bool get isAcute {
    final rightAngle = (pi / 2);
    return angles.every((a) => a < rightAngle - _epsilon);
  }

  /// Check is this triangle is Obtuse
  ///
  /// true if this has one angle that is > 90 degrees
  bool get isObtuse {
    final rightAngle = (pi / 2);
    return angles.any((a) => a > rightAngle + _epsilon);
  }

  /// Get hypotenuse
  ///
  /// the longest line of this triangle
  Line get hypotenuse =>
      sides.reduce((cur, next) => cur.length > next.length ? cur : next);

  /// Check if this triangle is scalene
  ///
  /// true if all 3 sides have different lengths
  bool get isScalene {
    return (AB.length - BC.length).abs() >= _epsilon &&
        (BC.length - CA.length).abs() >= _epsilon &&
        (AB.length - CA.length).abs() >= _epsilon;
  }

  /// Get centroid of this triangle
  ///
  /// The intersection of medians: ((ax+bx+cx)/3, (ay+by+cy)/3)
  Point get centroid =>
      Point((a.x + b.x + c.x) / 3, (a.y + b.y + c.y) / 3);

  /// Get circumcenter of this triangle
  ///
  /// The point equidistant from all three vertices.
  Point get circumcenter {
    final abx = b.x - a.x, aby = b.y - a.y;
    final acx = c.x - a.x, acy = c.y - a.y;

    final abSq = abx * abx + aby * aby;
    final acSq = acx * acx + acy * acy;

    final d = 2.0 * (abx * acy - aby * acx);

    final ux = (acy * abSq - aby * acSq) / d;
    final uy = (abx * acSq - acx * abSq) / d;

    return Point(a.x + ux, a.y + uy);
  }

  /// Get incenter of this triangle
  ///
  /// The intersection of angle bisectors, weighted by opposite side lengths.
  Point get incenter {
    final la = BC.length; // side opposite vertex a
    final lb = CA.length; // side opposite vertex b
    final lc = AB.length; // side opposite vertex c
    final p = la + lb + lc;
    return Point(
      (la * a.x + lb * b.x + lc * c.x) / p,
      (la * a.y + lb * b.y + lc * c.y) / p,
    );
  }

  /// Check if a point is inside this triangle
  ///
  /// Uses barycentric coordinate method.
  bool contains(Point p) {
    final d1 = _sign(p, a, b);
    final d2 = _sign(p, b, c);
    final d3 = _sign(p, c, a);

    final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);

    return !(hasNeg && hasPos);
  }

  static double _sign(Point p1, Point p2, Point p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
  }

  /// Get the circumscribed circle (circumcircle)
  ///
  /// The circle passing through all three vertices.
  Circle get circumscribedCircle {
    final cc = circumcenter;
    final r = sqrt(pow(cc.x - a.x, 2) + pow(cc.y - a.y, 2));
    return Circle(center: cc, radius: r);
  }

  /// Get the inscribed circle (incircle)
  ///
  /// The largest circle fitting inside the triangle.
  Circle get inscribedCircle {
    final ic = incenter;
    final r = 2 * area.abs() / perimeter;
    return Circle(center: ic, radius: r);
  }

  /// Get baseLine of this triangle
  Line get baseLine {
    Point start, end;
    if (a.x <= b.x && a.x <= c.x) {
      start = a;
      end = b.x <= c.x ? b : c;
    } else if (b.x <= a.x && b.x <= c.x) {
      start = b;
      end = a.x <= c.x ? a : c;
    } else {
      start = c;
      end = a.x <= b.x ? a : b;
    }
    return Line(start, end);
  }

  /// Get height value of this triangle
  double get height => baseLine.distanceFromAPoint(posVertex);

  /// Get height Line
  ///
  /// the line that goes from [posVertex] to the midPoint of the [baseLine]
  Line get heightLine => Line(posVertex, baseLine.midPoint);

  /// Get list of 3 vertices of this triangle
  List<Point> get vertices => [a, b, c];

  /// Get 3 sides of this triangle
  List<Line> get sides => [AB, BC, CA];

  /// Line that goes from a to b;
  Line get AB => Line(a, b);

  /// Line that goes from b to c;
  Line get BC => Line(b, c);

  /// Line that goes from c to a;
  Line get CA => Line(c, a);

  /// Line that goes from a to c;
  Line get AC => Line(a, c);

  /// Pos vertex
  ///
  /// get the vertex that opposite to the baseline
  Point get posVertex =>
      vertices.firstWhere((p) => p != baseLine.a && p != baseLine.b);

  /// Get orthocenter of this triangle
  ///
  /// The orthocenter of a triangle is the point where the altitudes of the triangle intersect.
  /// Uses the relation: orthocenter = a + b + c - 2 * circumcenter.
  Point get orthocenter {
    final cc = circumcenter;
    return Point(
      a.x + b.x + c.x - 2 * cc.x,
      a.y + b.y + c.y - 2 * cc.y,
    );
  }

  /// Rotate all vertices by [deg] degrees around the origin.
  @override
  Triangle rotate(double deg) {
    return Triangle(
      a.rotate(deg),
      b.rotate(deg),
      c.rotate(deg),
    );
  }

  /// Scale all vertices by [value].
  @override
  Triangle scale(double value) {
    return Triangle(
      a.scale(value),
      b.scale(value),
      c.scale(value),
    );
  }

  /// Translate all vertices by [x] horizontally and [y] vertically.
  @override
  Triangle translate({double x = 0, double y = 0}) {
    return Triangle(
      a.translate(x, y),
      b.translate(x, y),
      c.translate(x, y),
    );
  }
}
