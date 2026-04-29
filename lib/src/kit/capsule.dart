import 'dart:math';

import '../interface/shape.dart';
import 'circle.dart';
import 'line.dart';
import 'point.dart';
import 'rectangle.dart';

/// A capsule (stadium) shape — a rectangle with semicircle caps on each end.
///
/// Defined by a center [Line] (the medial axis) and a [radius].
/// The total length is the line length plus the diameter (two semicircle caps).
class Capsule implements Shape {
  /// The medial axis of the capsule
  final Line medialAxis;

  /// The radius of the semicircle caps (and half-width of the rectangular body)
  final double radius;

  const Capsule({required this.medialAxis, required this.radius});

  /// Create a capsule from center point, total width, total height.
  ///
  /// The longer dimension becomes the medial axis direction.
  /// If width >= height, the capsule is horizontal; otherwise vertical.
  factory Capsule.fromRect({
    required Point center,
    required double width,
    required double height,
  }) {
    if (width >= height) {
      final r = height / 2;
      final halfAxis = (width / 2) - r;
      return Capsule(
        medialAxis: Line(
          Point(center.x - halfAxis, center.y),
          Point(center.x + halfAxis, center.y),
        ),
        radius: r,
      );
    } else {
      final r = width / 2;
      final halfAxis = (height / 2) - r;
      return Capsule(
        medialAxis: Line(
          Point(center.x, center.y - halfAxis),
          Point(center.x, center.y + halfAxis),
        ),
        radius: r,
      );
    }
  }

  /// Create a capsule that is a perfect circle (medial axis has zero length)
  factory Capsule.circle({required Point center, required double radius}) {
    return Capsule(
      medialAxis: Line(center, center),
      radius: radius,
    );
  }

  /// Center point of the capsule
  Point get center => medialAxis.midPoint;

  /// Length of the medial axis
  double get axisLength => medialAxis.length;

  /// Total length of the capsule (axis + diameter)
  double get totalLength => axisLength + 2 * radius;

  /// Total width perpendicular to the medial axis
  double get totalWidth => 2 * radius;

  @override
  double get area => pi * radius * radius + 2 * radius * axisLength;

  @override
  double get perimeter => 2 * pi * radius + 2 * axisLength;

  /// Check if a point is inside this capsule.
  ///
  /// A point is inside if its distance to the medial axis segment <= radius.
  bool contains(Point p) {
    return _distanceToSegment(p) <= radius;
  }

  /// Shortest distance from [p] to the medial axis segment (not infinite line).
  double _distanceToSegment(Point p) {
    final ax = medialAxis.a.x, ay = medialAxis.a.y;
    final bx = medialAxis.b.x, by = medialAxis.b.y;
    final dx = bx - ax, dy = by - ay;
    final lenSq = dx * dx + dy * dy;

    if (lenSq == 0) return p.distanceTo(medialAxis.a);

    final t = ((p.x - ax) * dx + (p.y - ay) * dy) / lenSq;
    final clamped = t.clamp(0.0, 1.0);
    final projX = ax + clamped * dx;
    final projY = ay + clamped * dy;
    return sqrt(pow(p.x - projX, 2) + pow(p.y - projY, 2));
  }

  /// Get the bounding rectangle of this capsule
  Rectangle get boundingBox {
    final dx = medialAxis.b.x - medialAxis.a.x;
    final dy = medialAxis.b.y - medialAxis.a.y;
    final len = axisLength;

    if (len == 0) {
      return Rectangle(
        x: center.x - radius,
        y: center.y - radius,
        width: 2 * radius,
        height: 2 * radius,
      );
    }

    // Unit direction and perpendicular
    final ux = dx / len, uy = dy / len;
    final px = -uy, py = ux;

    // All four extreme points of the capsule outline
    final points = [
      Point(medialAxis.a.x + px * radius, medialAxis.a.y + py * radius),
      Point(medialAxis.a.x - px * radius, medialAxis.a.y - py * radius),
      Point(medialAxis.b.x + px * radius, medialAxis.b.y + py * radius),
      Point(medialAxis.b.x - px * radius, medialAxis.b.y - py * radius),
      // Semicircle extremes
      Point(medialAxis.a.x - ux * radius, medialAxis.a.y - uy * radius),
      Point(medialAxis.b.x + ux * radius, medialAxis.b.y + uy * radius),
    ];

    final minX = points.map((p) => p.x).reduce(min);
    final minY = points.map((p) => p.y).reduce(min);
    final maxX = points.map((p) => p.x).reduce(max);
    final maxY = points.map((p) => p.y).reduce(max);

    return Rectangle(x: minX, y: minY, width: maxX - minX, height: maxY - minY);
  }

  /// The two semicircle center points (endpoints of the medial axis)
  List<Circle> get endCaps => [
        Circle(center: medialAxis.a, radius: radius),
        Circle(center: medialAxis.b, radius: radius),
      ];

  @override
  Capsule rotate(double deg) {
    return Capsule(
      medialAxis: Line(medialAxis.a.rotate(deg), medialAxis.b.rotate(deg)),
      radius: radius,
    );
  }

  @override
  Capsule scale(double value) {
    return Capsule(
      medialAxis: Line(medialAxis.a.scale(value), medialAxis.b.scale(value)),
      radius: radius * value,
    );
  }

  @override
  Capsule translate({double x = 0, double y = 0}) {
    return Capsule(
      medialAxis: Line(
        medialAxis.a.translate(x, y),
        medialAxis.b.translate(x, y),
      ),
      radius: radius,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Capsule &&
        other.medialAxis == medialAxis &&
        other.radius == radius;
  }

  @override
  int get hashCode => medialAxis.hashCode ^ radius.hashCode;

  @override
  String toString() => 'Capsule(medialAxis: $medialAxis, radius: $radius)';
}
