import 'dart:math';

import 'package:geometry_kit/src/kit/units.dart';

import 'line.dart';

import '../interface/shape.dart';
import 'point.dart';

class Triangle extends Shape {
  final Point a;
  final Point b;
  final Point c;

  const Triangle(this.a, this.b, this.c) : assert(a != b && b != c && a != c);

  // factory Triangle.equilateral(
  //     {required Point center, required double radius}) {
  //   Point a = center.pointAtAngle(radius, 0);
  //   Point b = center.pointAtAngle(radius, pi / 3);
  //   Point c = center.pointAtAngle(radius, 2 * pi / 3);
  //   return Triangle(a, b, c);
  // }

  @override
  double get area =>
      (a.x * (b.y - c.y) + b.x * (c.y - a.y) + c.x * (a.y - b.y)) / 2;

  @override
  double get perimeter => sides.fold<double>(0.0, (prev, e) => prev + e.length);

  List<Rad> get angles {
    final list = <Rad>[];
    final n = sides.length;
    for (int i = 0; i < n; i++) {
      var nextI = (i + 1) % n;
      list.add(sides[i].innerAngleWith(sides[nextI]));
    }
    print(list.map((e) => e.toDeg.abs()));
    return list;
  }

  /// Check if this triangle is right
  ///
  /// triangle is right when there is an angle equals to 90 degrees
  // bool get isRightTriangle {
  //   return angles.any((a) => a.abs().compareTo(90.0.toRad).abs() < 0.0000001);
  // }

  /// Check is this triangle is equilateral
  ///
  /// true if 3 sides have the same length
  // bool get isEquilateral {
  //   print(sides.map((e) => e.length));
  //   print(vertices);
  //   // return sides.map((e) => e.length).toSet().length == 1;\
  //   return AB.length == AC.length && AC.length == BC.length;
  // }

  /// Check is this triangle is Isosceles
  ///
  /// true if 2 sides have the same length
  // bool get isIsosceles {
  //   return sides.map((e) => e.length).toSet().length == 2;
  // }

  /// Check is this triangle is Acute
  ///
  /// true if this has 3 angles < 90 degrees
  // bool get isAcute {
  //   return angles.every((a) => a.abs().compareTo(90.0.toRad).abs() < 0.0000001);
  // }

  /// Check is this triangle is Obtuse
  ///
  /// true if this has one angles that is > 90 degrees
  // bool get isObtuse {
  //   return angles.any((a) => a.abs() > (90.0.toRad));
  // }

  // /// Get hypotenuse
  // ///
  // /// the longest line of this triangle
  // Line get hypotenuse =>
  //     sides.reduce((cur, next) => cur.length > next.length ? cur : next);

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

  // Line aToBC(){
  //   final intersect = BC.intersect(other)
  // }

  /// Pos vertex
  ///
  /// get the vertex that opposite to the baseline
  Point get posVertex =>
      vertices.firstWhere((p) => p != baseLine.a && p != baseLine.b);

  /// Get orthocenter of this triangle
  ///
  /// The orthocenter of a triangle is the point where the altitudes of the triangle intersect
  Point get orthocenter {
    double slopeAB = (b.y - a.y) / (b.x - a.x);
    double slopeBC = (c.y - b.y) / (c.x - b.x);

    double x = (slopeAB * slopeBC * (a.y - c.y) +
            slopeBC * (a.x + b.x) -
            slopeAB * (b.x + c.x)) /
        (2 * (slopeBC - slopeAB));
    double y = -1 * (x - (a.x + b.x) / 2) / slopeAB + (a.y + b.y) / 2;

    return Point(x, y);
  }
}
