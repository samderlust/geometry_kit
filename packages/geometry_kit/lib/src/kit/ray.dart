import 'dart:math';

import 'circle.dart';
import 'line.dart';
import 'point.dart';

/// A ray defined by an origin point and a direction.
///
/// A ray starts at [origin] and extends infinitely in the
/// direction of [direction]. Unlike [Line], a ray has no endpoint.
class Ray {
  /// The starting point of the ray
  final Point origin;

  /// The direction of the ray as a point (vector from origin)
  final Point direction;

  const Ray(this.origin, this.direction);

  /// Create a ray from an origin point and an angle in degrees
  factory Ray.fromAngle(Point origin, double deg) {
    final rad = deg * pi / 180;
    return Ray(origin, Point(cos(rad), sin(rad)));
  }

  /// Get the normalized direction vector
  Point get normalizedDirection {
    final mag = sqrt(direction.x * direction.x + direction.y * direction.y);
    if (mag == 0) return Point(0, 0);
    return Point(direction.x / mag, direction.y / mag);
  }

  /// Get a point along the ray at parameter [t]
  ///
  /// [t] = 0 returns [origin], [t] > 0 moves along the ray direction.
  Point pointAt(double t) {
    final nd = normalizedDirection;
    return Point(origin.x + nd.x * t, origin.y + nd.y * t);
  }

  /// Get the intersection point of this ray with a [Line] segment.
  ///
  /// Returns `null` if they don't intersect.
  Point? intersectsLine(Line line) {
    final dx = direction.x;
    final dy = direction.y;

    final x1 = line.a.x;
    final y1 = line.a.y;
    final x2 = line.b.x;
    final y2 = line.b.y;

    final denom = dx * (y2 - y1) - dy * (x2 - x1);
    if (denom == 0) return null;

    final t = ((x1 - origin.x) * (y2 - y1) - (y1 - origin.y) * (x2 - x1)) /
        denom;
    final s = ((x1 - origin.x) * dy - (y1 - origin.y) * dx) / denom;

    if (t >= 0 && s >= 0 && s <= 1) {
      return Point(origin.x + t * dx, origin.y + t * dy);
    }
    return null;
  }

  /// Get intersection points of this ray with a [Circle].
  ///
  /// Returns a list of 0, 1, or 2 intersection points.
  List<Point> intersectsCircle(Circle circle) {
    final nd = normalizedDirection;
    final dx = origin.x - circle.center.x;
    final dy = origin.y - circle.center.y;

    final a = nd.x * nd.x + nd.y * nd.y;
    final b = 2 * (dx * nd.x + dy * nd.y);
    final c = dx * dx + dy * dy - circle.radius * circle.radius;

    final discriminant = b * b - 4 * a * c;

    if (discriminant < 0) return [];

    final results = <Point>[];
    if (discriminant == 0) {
      final t = -b / (2 * a);
      if (t >= 0) results.add(pointAt(t));
    } else {
      final sqrtD = sqrt(discriminant);
      final t1 = (-b - sqrtD) / (2 * a);
      final t2 = (-b + sqrtD) / (2 * a);
      if (t1 >= 0) results.add(pointAt(t1));
      if (t2 >= 0) results.add(pointAt(t2));
    }

    return results;
  }

  /// Translate the ray origin
  Ray translate({double x = 0, double y = 0}) {
    return Ray(origin.translate(x, y), direction);
  }

  /// Rotate the ray by [deg] degrees
  Ray rotate(double deg) {
    return Ray(origin.rotate(deg), direction.rotate(deg));
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Ray && other.origin == origin && other.direction == direction;
  }

  @override
  int get hashCode => origin.hashCode ^ direction.hashCode;

  @override
  String toString() => 'Ray(origin: $origin, direction: $direction)';
}
