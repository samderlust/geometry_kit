import 'dart:math';

class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Point && other.x == x && other.y == y;
  }

  @override
  int get hashCode => x.hashCode ^ y.hashCode;

  Point operator -(Point other) => Point(x - other.x, y - other.y);
  Point operator +(Point other) => Point(x + other.x, y + other.y);
  Point operator *(double scalar) => Point(x * scalar, y * scalar);
  Point operator /(double scalar) => Point(x / scalar, y / scalar);
  double operator %(Point other) => x * other.y - y * other.x;

  @override
  String toString() => 'Point(x: $x, y: $y)';
}
