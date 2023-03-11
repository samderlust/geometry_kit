import 'dart:math';

import '../interface/shape.dart';
import 'point.dart';

/// Circle
///
///
class Circle extends Shape {
  final double radius;
  final Point center;

  const Circle({
    required this.radius,
    required this.center,
  });

  /// Check if a given point is inside of this circle
  bool hasPoint(point) {
    return (center.distanceTo(point) > radius);
  }

  /// Get area of circle
  @override
  double get area => pi * pow(radius, 2);

  /// Get perimeter of circle
  @override
  double get perimeter => 2 * pi * radius;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Circle && other.radius == radius && other.center == center;
  }

  @override
  int get hashCode => radius.hashCode ^ center.hashCode;

  @override
  Circle rotate(double deg) {
    return this;
  }

  @override
  Circle scale(double value) {
    return Circle(radius: radius, center: center);
  }

  @override
  Circle translate({double x = 0, double y = 0}) {
    return Circle(radius: radius, center: Point(center.x + x, center.y + y));
  }
}
