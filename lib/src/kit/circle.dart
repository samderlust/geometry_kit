import 'dart:math';

import '../interface/shape.dart';
import 'line.dart';
import 'point.dart';

/// Circle
///
///
class Circle implements Shape {
  final double radius;
  final Point center;

  const Circle({
    required this.radius,
    required this.center,
  });

  /// Diameter of this circle
  double get diameter => 2 * radius;

  /// Circumference of this circle (alias for [perimeter])
  double get circumference => perimeter;

  /// Check if a given point is inside of this circle
  bool hasPoint(Point point) {
    return (center.distanceTo(point) <= radius);
  }

  /// Check if a point is inside this circle (alias for [hasPoint])
  bool contains(Point point) => hasPoint(point);

  /// Shortest distance from circle boundary to [point]
  ///
  /// Returns 0 if point is on boundary, negative if inside.
  double distanceTo(Point point) {
    return center.distanceTo(point) - radius;
  }

  /// Check if a line segment intersects this circle
  bool intersectsLine(Line line) {
    return getLineIntersections(line).isNotEmpty;
  }

  /// Get intersection points of a line segment with this circle
  ///
  /// Returns 0, 1, or 2 points.
  List<Point> getLineIntersections(Line line) {
    final dx = line.b.x - line.a.x;
    final dy = line.b.y - line.a.y;
    final fx = line.a.x - center.x;
    final fy = line.a.y - center.y;

    final a = dx * dx + dy * dy;
    final b = 2 * (fx * dx + fy * dy);
    final c = fx * fx + fy * fy - radius * radius;

    final discriminant = b * b - 4 * a * c;
    if (discriminant < 0) return [];

    final results = <Point>[];
    final sqrtD = sqrt(max(0, discriminant));

    final t1 = (-b - sqrtD) / (2 * a);
    final t2 = (-b + sqrtD) / (2 * a);

    if (t1 >= 0 && t1 <= 1) {
      results.add(Point(line.a.x + t1 * dx, line.a.y + t1 * dy));
    }
    if (discriminant > 0 && t2 >= 0 && t2 <= 1) {
      results.add(Point(line.a.x + t2 * dx, line.a.y + t2 * dy));
    }

    return results;
  }

  /// Check if this circle overlaps with [other]
  bool intersectsCircle(Circle other) {
    final dist = center.distanceTo(other.center);
    return dist < radius + other.radius && dist > (radius - other.radius).abs();
  }

  /// Get intersection points of this circle with [other]
  ///
  /// Returns 0, 1, or 2 points.
  List<Point> getCircleIntersections(Circle other) {
    final dist = center.distanceTo(other.center);

    // No intersection
    if (dist > radius + other.radius) return [];
    if (dist < (radius - other.radius).abs()) return [];
    if (dist == 0 && radius == other.radius) return [];

    final a = (radius * radius - other.radius * other.radius + dist * dist) /
        (2 * dist);
    final hSq = radius * radius - a * a;
    if (hSq < 0) return [];
    final h = sqrt(max(0, hSq));

    final px = center.x + a * (other.center.x - center.x) / dist;
    final py = center.y + a * (other.center.y - center.y) / dist;

    if (h < 1e-10) {
      return [Point(px, py)];
    }

    final rx = -h * (other.center.y - center.y) / dist;
    final ry = h * (other.center.x - center.x) / dist;

    return [
      Point(px + rx, py + ry),
      Point(px - rx, py - ry),
    ];
  }

  /// Get tangent line at [point] on boundary
  ///
  /// Returns a line perpendicular to radius at that point.
  /// [point] should be on or near the boundary.
  Line tangentAt(Point point) {
    final dx = point.x - center.x;
    final dy = point.y - center.y;
    // Tangent is perpendicular to radius: rotate direction 90°
    return Line(
      Point(point.x - dy, point.y + dx),
      Point(point.x + dy, point.y - dx),
    );
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
    return Circle(radius: radius * value, center: center.scale(value));
  }

  @override
  Circle translate({double x = 0, double y = 0}) {
    return Circle(radius: radius, center: Point(center.x + x, center.y + y));
  }
}
