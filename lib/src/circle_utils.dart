part of '../geometry_kit.dart';

/// Circle Utils
///
///
class CircleUtils {
  /// Check if a point is inside the Circle
  ///
  ///
  static bool isPointInsideCircle(Circle circle, point) {
    if (circle.center.distanceTo(point) > circle.radius) {
      return false;
    }
    return true;
  }

  static double area(double radius) => pi * pow(radius, 2);
  static double perimeter(double radius) => 2 * pi * radius;
}
