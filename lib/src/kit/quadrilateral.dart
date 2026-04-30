import 'dart:math';

import '../interface/shape.dart';
import 'line.dart';
import 'point.dart';

/// A quadrilateral defined by four vertices in order.
///
/// Provides classification checks for common quadrilateral types:
/// parallelogram, rhombus, trapezoid, kite, and rectangle.
class Quadrilateral implements Shape {
  /// Vertex A.
  final Point a;

  /// Vertex B.
  final Point b;

  /// Vertex C.
  final Point c;

  /// Vertex D.
  final Point d;

  static const double _epsilon = 1e-4;

  /// Creates a quadrilateral from four vertices in order.
  const Quadrilateral(this.a, this.b, this.c, this.d);

  /// The four vertices in order
  List<Point> get vertices => [a, b, c, d];

  /// Side from a to b
  Line get AB => Line(a, b);

  /// Side from b to c
  Line get BC => Line(b, c);

  /// Side from c to d
  Line get CD => Line(c, d);

  /// Side from d to a
  Line get DA => Line(d, a);

  /// The four sides in order
  List<Line> get sides => [AB, BC, CD, DA];

  /// Diagonal from a to c
  Line get diagonalAC => Line(a, c);

  /// Diagonal from b to d
  Line get diagonalBD => Line(b, d);

  /// Area of this quadrilateral using the shoelace formula.
  @override
  double get area {
    // Shoelace formula
    final sum = a.x * b.y - b.x * a.y +
        b.x * c.y - c.x * b.y +
        c.x * d.y - d.x * c.y +
        d.x * a.y - a.x * d.y;
    return sum.abs() / 2;
  }

  /// Perimeter of this quadrilateral (sum of all four side lengths).
  @override
  double get perimeter =>
      AB.length + BC.length + CD.length + DA.length;

  /// Center point (average of vertices)
  Point get center => Point(
        (a.x + b.x + c.x + d.x) / 4,
        (a.y + b.y + c.y + d.y) / 4,
      );

  /// Whether this is a parallelogram
  ///
  /// Both pairs of opposite sides are parallel.
  bool get isParallelogram {
    return AB.isParallelTo(CD) && BC.isParallelTo(DA);
  }

  /// Whether this is a rhombus
  ///
  /// All four sides have equal length (and it's a parallelogram).
  bool get isRhombus {
    if (!isParallelogram) return false;
    final len = AB.length;
    return (BC.length - len).abs() < _epsilon &&
        (CD.length - len).abs() < _epsilon &&
        (DA.length - len).abs() < _epsilon;
  }

  /// Whether this is a trapezoid (trapezium)
  ///
  /// At least one pair of opposite sides is parallel.
  bool get isTrapezoid {
    return AB.isParallelTo(CD) || BC.isParallelTo(DA);
  }

  /// Whether this is a kite
  ///
  /// Two pairs of consecutive sides are equal in length.
  bool get isKite {
    final ab = AB.length, bc = BC.length, cd = CD.length, da = DA.length;
    // Pair 1: AB==BC and CD==DA, or Pair 2: AB==DA and BC==CD
    return ((ab - bc).abs() < _epsilon && (cd - da).abs() < _epsilon) ||
        ((ab - da).abs() < _epsilon && (bc - cd).abs() < _epsilon);
  }

  /// Whether this is a rectangle
  ///
  /// A parallelogram with all right angles (diagonals equal length).
  bool get isRectangle {
    if (!isParallelogram) return false;
    return (diagonalAC.length - diagonalBD.length).abs() < _epsilon;
  }

  /// Whether this is a square
  ///
  /// A rectangle with all sides equal.
  bool get isSquare => isRectangle && isRhombus;

  /// Whether this quadrilateral is convex
  bool get isConvex {
    final pts = vertices;
    bool? positive;
    for (int i = 0; i < 4; i++) {
      final p1 = pts[i];
      final p2 = pts[(i + 1) % 4];
      final p3 = pts[(i + 2) % 4];
      final cross =
          (p2.x - p1.x) * (p3.y - p2.y) - (p2.y - p1.y) * (p3.x - p2.x);
      if (cross != 0) {
        if (positive == null) {
          positive = cross > 0;
        } else if ((cross > 0) != positive) {
          return false;
        }
      }
    }
    return true;
  }

  /// Check if a point is inside this quadrilateral
  ///
  /// Uses the sign-based triangle decomposition method.
  bool contains(Point p) {
    // Split into two triangles: (a,b,c) and (a,c,d)
    return _inTriangle(p, a, b, c) || _inTriangle(p, a, c, d);
  }

  static double _sign(Point p1, Point p2, Point p3) {
    return (p1.x - p3.x) * (p2.y - p3.y) - (p2.x - p3.x) * (p1.y - p3.y);
  }

  static bool _inTriangle(Point p, Point v1, Point v2, Point v3) {
    final d1 = _sign(p, v1, v2);
    final d2 = _sign(p, v2, v3);
    final d3 = _sign(p, v3, v1);
    final hasNeg = (d1 < 0) || (d2 < 0) || (d3 < 0);
    final hasPos = (d1 > 0) || (d2 > 0) || (d3 > 0);
    return !(hasNeg && hasPos);
  }

  /// Rotate all vertices by [deg] degrees around the origin.
  @override
  Quadrilateral rotate(double deg) {
    return Quadrilateral(
      a.rotate(deg),
      b.rotate(deg),
      c.rotate(deg),
      d.rotate(deg),
    );
  }

  /// Scale all vertices by [value].
  @override
  Quadrilateral scale(double value) {
    return Quadrilateral(
      a.scale(value),
      b.scale(value),
      c.scale(value),
      d.scale(value),
    );
  }

  /// Translate all vertices by [x] horizontally and [y] vertically.
  @override
  Quadrilateral translate({double x = 0, double y = 0}) {
    return Quadrilateral(
      a.translate(x, y),
      b.translate(x, y),
      c.translate(x, y),
      d.translate(x, y),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Quadrilateral &&
        other.a == a &&
        other.b == b &&
        other.c == c &&
        other.d == d;
  }

  @override
  int get hashCode => a.hashCode ^ b.hashCode ^ c.hashCode ^ d.hashCode;

  @override
  String toString() => 'Quadrilateral($a, $b, $c, $d)';
}
