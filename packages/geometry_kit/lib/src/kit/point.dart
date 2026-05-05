import 'dart:math';

/// An immutable 2D point (or vector) with x and y coordinates.
///
/// Supports arithmetic operators for vector math:
/// - `+` / `-` for addition and subtraction
/// - `*` / `/` for scalar multiplication and division
/// - `%` for cross product
///
/// ```dart
/// final p = Point(3, 4);
/// print(p.magnitude); // 5.0
/// print(p.normalized); // Point(0.6, 0.8)
/// ```
class Point {
  /// X coordinate.
  final double x;

  /// Y coordinate.
  final double y;

  /// Creates a point at ([x], [y]).
  const Point(this.x, this.y);

  /// Euclidean distance from this point to [other].
  double distanceTo(Point other) {
    var dx = x - other.x;
    var dy = y - other.y;
    return sqrt(dx * dx + dy * dy);
  }

  /// Get the point at a distance to this point
  ///
  /// result of the other point is depended on the distance and the angle between them 2
  /// default angle is 0
  Point pointAtDistance(double distance, [double angle = 0]) {
    final x1 = x + distance * cos(angle);
    final y1 = y + distance * sin(angle);
    return Point(x1, y1);
  }

  ///generates a point at a specified angle and distance from a center point
  Point pointAtAngle(double radius, double angle) {
    double x = this.x + radius * cos(angle);
    double y = this.y + radius * sin(angle);
    return Point(x, y);
  }

  /// translate the point with [x] in horizontally and [y] vertically
  Point translate(double x, double y) {
    return Point(this.x + x, this.y + y);
  }

  /// move the point my scale factor
  ///
  /// to use in scaling shapes
  Point scale(double factor) {
    return Point(x * factor, y * factor);
  }

  /// rotate the point by [deg] degrees
  ///
  ///
  Point rotate(double deg) {
    final radians = deg * pi / 180.0; // Convert degrees to radians
    final cosTheta = cos(radians);
    final sinTheta = sin(radians);
    final newX = x * cosTheta - y * sinTheta;
    final newY = x * sinTheta + y * cosTheta;
    return Point(newX, newY);
  }

  /// Angle from this point to [other] in radians
  ///
  /// Returns `atan2(dy, dx)`, range (-pi, pi].
  double angleTo(Point other) {
    return atan2(other.y - y, other.x - x);
  }

  /// Dot product with [other]
  double dot(Point other) => x * other.x + y * other.y;

  /// Distance from origin (vector magnitude)
  double get magnitude => sqrt(x * x + y * y);

  /// Unit vector (magnitude 1) in same direction
  ///
  /// Returns `Point(0, 0)` if magnitude is zero.
  Point get normalized {
    final m = magnitude;
    if (m == 0) return Point(0, 0);
    return Point(x / m, y / m);
  }

  /// Midpoint between this point and [other]
  Point midPointTo(Point other) {
    return Point((x + other.x) / 2, (y + other.y) / 2);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Point && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  /// Subtract [other] from this point (vector subtraction).
  Point operator -(Point other) => Point(x - other.x, y - other.y);

  /// Add [other] to this point (vector addition).
  Point operator +(Point other) => Point(x + other.x, y + other.y);

  /// Multiply this point by [scalar] (scalar multiplication).
  Point operator *(double scalar) => Point(x * scalar, y * scalar);

  /// Divide this point by [scalar] (scalar division).
  Point operator /(double scalar) => Point(x / scalar, y / scalar);

  /// Cross product of this point and [other] (2D pseudo cross product).
  double operator %(Point other) => x * other.y - y * other.x;

  @override
  String toString() => 'Point(x: $x, y: $y)';
}
