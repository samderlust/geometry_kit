import 'dart:math';

import 'point.dart';
import 'units.dart';

/// An arc defined by a center, radius, start angle, and end angle.
///
/// Angles are in radians. The arc sweeps counter-clockwise
/// from [startAngle] to [endAngle].
class Arc {
  /// Center point of the arc's circle
  final Point center;

  /// Radius of the arc's circle
  final double radius;

  /// Start angle in radians
  final Rad startAngle;

  /// End angle in radians
  final Rad endAngle;

  const Arc({
    required this.center,
    required this.radius,
    required this.startAngle,
    required this.endAngle,
  });

  /// Create an arc from degrees instead of radians
  factory Arc.fromDegrees({
    required Point center,
    required double radius,
    required double startDeg,
    required double endDeg,
  }) {
    return Arc(
      center: center,
      radius: radius,
      startAngle: startDeg * pi / 180,
      endAngle: endDeg * pi / 180,
    );
  }

  /// The sweep angle of the arc in radians
  Rad get sweepAngle {
    var sweep = endAngle - startAngle;
    if (sweep < 0) sweep += 2 * pi;
    return sweep;
  }

  /// The length of the arc
  double get length => radius * sweepAngle;

  /// The point at the start of the arc
  Point get startPoint =>
      Point(center.x + radius * cos(startAngle), center.y + radius * sin(startAngle));

  /// The point at the end of the arc
  Point get endPoint =>
      Point(center.x + radius * cos(endAngle), center.y + radius * sin(endAngle));

  /// The midpoint of the arc
  Point get midPoint {
    final midAngle = startAngle + sweepAngle / 2;
    return Point(
      center.x + radius * cos(midAngle),
      center.y + radius * sin(midAngle),
    );
  }

  /// Get a point on the arc at parameter [t] (0 = start, 1 = end)
  Point pointAt(double t) {
    final angle = startAngle + sweepAngle * t;
    return Point(
      center.x + radius * cos(angle),
      center.y + radius * sin(angle),
    );
  }

  /// Check if an angle (in radians) falls within this arc's sweep
  bool containsAngle(Rad angle) {
    var normalized = angle % (2 * pi);
    if (normalized < 0) normalized += 2 * pi;

    var start = startAngle % (2 * pi);
    if (start < 0) start += 2 * pi;

    var end = start + sweepAngle;

    if (normalized >= start && normalized <= end) return true;
    if (end > 2 * pi && normalized <= end - 2 * pi) return true;
    return false;
  }

  /// The area of the sector formed by this arc
  double get sectorArea => 0.5 * radius * radius * sweepAngle;

  /// Translate the arc
  Arc translate({double x = 0, double y = 0}) {
    return Arc(
      center: Point(center.x + x, center.y + y),
      radius: radius,
      startAngle: startAngle,
      endAngle: endAngle,
    );
  }

  /// Scale the arc by [factor]
  Arc scale(double factor) {
    return Arc(
      center: center.scale(factor),
      radius: radius * factor,
      startAngle: startAngle,
      endAngle: endAngle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Arc &&
        other.center == center &&
        other.radius == radius &&
        other.startAngle == startAngle &&
        other.endAngle == endAngle;
  }

  @override
  int get hashCode =>
      center.hashCode ^
      radius.hashCode ^
      startAngle.hashCode ^
      endAngle.hashCode;

  @override
  String toString() =>
      'Arc(center: $center, radius: $radius, startAngle: $startAngle, endAngle: $endAngle)';
}
